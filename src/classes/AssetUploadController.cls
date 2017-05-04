/*
*@purpose Allow for an easy way to upload files to amazon s3
*@author  fabian@simpletechs.net
*@version 1.0
*@history
* version                | author                       | changes
* =======================================================================
* 0.1 (15.02.2012)       | fabian.off@onivation.de      | initial version
* 1.0 (16.02.2012)       | fabian.off@onivation.de      | enhanced version
*/

public class AssetUploadController {
    
    //Modify this string variable to be the name of the AWS Credential record that contains the proper AWS keys and secret
    //I'd export this to a custom setting and completely kill the aws-credential object, but this would force you to make an exception in your testing process, I fear.
    private String AWSCredentialName = 'Personal Credentials'; 
    
    //standard stuff
    private ApexPages.StandardController stdController;
    public Asset__c asset {get;set;}
    
    //variables for visualforce-page
    public Map<String, String> formContents {get;set;}
    public String bucket {
                get { if(formContents != null) return formContents.get('bucket'); else return null; } 
                set { if(formContents != null) {
                    formContents.put('bucket', value);
                    asset.bucket__c = value;
                }
            }
        }
    public String filename {get; set;}
    
    //AWS-Toolkit stuff
    private S3.AmazonS3 as3 { get; set; }
    private AWSKeys credentials {get;set;}
    private string secret { get {return credentials.secret;} }
    private string key { get {return credentials.key;} }
    
    //constructor
    public AssetUploadController(ApexPages.StandardController stdController) {
        //save valuable info from constructor, so as to save queries and use std functionality
        this.stdController = stdController;
        asset = (Asset__c)stdController.getRecord();
        
        //get aws credentials (the old way) and login to s3
        try{
            credentials = new AWSKeys(AWSCredentialName);
            
            //we cannot call webservices in test methods
            if(!System.Test.isRunningTest()) {
                as3 = new S3.AmazonS3(credentials.key,credentials.secret);
            }
        } catch (AWSKeys.AWSKeysException AWSEx) {
            System.debug('Caught exception in AssetUploadController: ' + AWSEx);
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, AWSEx.getMessage());
            ApexPages.addMessage(errorMsg);
            return;
        }
        
        //initialize our hidden map with contents
        formContents = new Map<String, String> {
                'AWSAccessKeyId' => key,
                'key' => '' + asset.contact__c + '/${filename}',
                'acl' => 'public-read',
                'success_action_redirect' => '',
                'policy' => '',
                'signature' => '',
                'bucket' => ''
        };
    }
    
    //this method is called in "action" tag of the page, 
    //return pagereference to object if upload is done OR null to stay on page
    public PageReference redirect() {
        //if upload is done
        if(ApexPages.currentPage().getParameters().get('uploaded') == 'true') {
            //save infos
            asset.etag__c = ApexPages.currentPage().getParameters().get('etag');
            asset.key__c = ApexPages.currentPage().getParameters().get('key');
            update asset;
            
            //try to use retURL, so User gets back to where he came from (like sfdc always does)
            String retURL = ApexPages.currentPage().getParameters().get('retURL');
            if(retURL != null && retURL.length() > 0) {
                return new PageReference(EncodingUtil.urlDecode(retURL, 'UTF-8'));
            }
            //no retURL? so then let's view the asset.
            return stdController.view();
        }
        return null;
    }
    
    //this will save all the values to respective apex-variables and rerender our hidden form
    //user stays on page, so controller keeps state
    public PageReference saveAndStayOnPage() {
        insert asset;
        
        //build url that amazon redirects to after success
        //use std-methods to get server-url + path WITHOUT query
        String redirectUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + System.URL.getCurrentRequestUrl().getPath() + '?uploaded=true&id=' + asset.id + '&retURL=' + ApexPages.currentPage().getParameters().get('retURL');
        formContents.put('success_action_redirect', redirectUrl);
        
        //add policy + siganture to our hidden form, so amazon can verify the upload request
        formContents.put('policy', EncodingUtil.base64Encode(Blob.valueOf(policy)));
        formContents.put('signature', make_sig(EncodingUtil.base64Encode(Blob.valueOf(policy))));
        
        return null;
    }
    
    //private methods for policing
    //policy expires after one day, so request can be pretty large ;-)
    datetime expire = system.now().addDays(1);
    String formattedexpire = expire.formatGmt('yyyy-MM-dd')+'T'+expire.formatGmt('HH:mm:ss')+'.'+expire.formatGMT('SSS')+'Z';           
    
    private string policy { 
        get { 
            return '{' 
                        + '"expiration": "' + formattedexpire + '", '
                        + '"conditions": '
                            + '['
                            + '{"acl": "public-read"},'
                            + '{"bucket": "' + asset.bucket__c + '" },'
                            + '{"success_action_redirect": "' + formContents.get('success_action_redirect') + '"},'
                            + '["starts-with", "$key", "' + asset.contact__c + '/"]'
                            + ']' 
                      + '}';  
            }
    }
    
    //method that will sign our policy
    private String make_sig(string canonicalBuffer) {       
        return EncodingUtil.base64Encode(Crypto.generateMac('HMacSHA1', blob.valueof(canonicalBuffer),blob.valueof(Secret)));
    }
    
    public List<SelectOption> getBucketOptions(){
        try{
            Datetime now = Datetime.now();
            
            S3.ListAllMyBucketsResult allBuckets;
            if(!System.Test.isRunningTest()) {
                allBuckets = as3.ListAllMyBuckets(key,now,as3.signature('ListAllMyBuckets',now));
            } else {
                allBuckets = new S3.ListAllMyBucketsResult();
                allBuckets.Buckets = new S3.ListAllMyBucketsList();
                
                S3.ListAllMyBucketsEntry a = new S3.ListAllMyBucketsEntry();
                a.Name = 'Testbucket';
                allBuckets.Buckets.Bucket = new S3.ListAllMyBucketsEntry[]{a};
            }    
            
            List<SelectOption> options = new List<SelectOption>();
            
            for(S3.ListAllMyBucketsEntry bucket:  allBuckets.Buckets.Bucket ){
                options.add(new SelectOption(bucket.Name,bucket.Name)); 
            }
            return options;
        }catch(Exception ex){
           //System.debug(ex);
           System.debug('caught exception in listallmybuckets');
           ApexPages.addMessages(ex);
           return null; 
        }
    }
    
    TestMethod static void testAssetController() {
        Account acc = new Account(Name = 'Simpletechs.net');
        insert acc;
        Contact c = new Contact(LastName = 'Off', AccountId = acc.Id);
        
        
        System.Test.startTest();
        //initialize controller
        AssetUploadController ctrl;
        
        //test the error case: we cannot find credentials
        ctrl = new AssetUploadController(new Apexpages.Standardcontroller(new Asset__c(Contact__c = c.Id)));
        
        //insert them and test positive case
        AWSKey__c t1 = new AWSKey__c( key__c='s1', secret__c='s1', name='Personal Credentials' );
        insert t1;
        
        ctrl = new AssetUploadController(new Apexpages.Standardcontroller(new Asset__c(Contact__c = c.Id)));
        
        //we will stay on the page, because upload is not yet finished
        System.assertEquals(ctrl.redirect(), null);
        System.assertNotEquals(ctrl.getBucketOptions(), null);
        
        ctrl.bucket = 'MyTestBucket';
        System.assertEquals(ctrl.bucket, 'MyTestBucket');
        System.assertEquals(ctrl.formContents.get('bucket'), 'MyTestBucket');
        
        //build policy and signature
        ctrl.saveAndStayOnPage();
        
        //so let's fake an upload is finished
        ApexPages.currentPage().getParameters().put('uploaded', 'true');
        System.assertNotEquals(ctrl.redirect(), null);
        
        //so let's fake an upload is finished and we have a retURL
        ApexPages.currentPage().getParameters().put('retURL', '/');
        System.assertNotEquals(ctrl.redirect(), null);
        
        System.Test.stopTest();
    }
}