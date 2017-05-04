/***********************************************************************
* Author        : DeveloperAtWork
* Functionality : Cloud Spokes Challenge - 2562
* Description   :  Tree- Like Data Selection for Products on click of
*                  "Search Prouduct" Button available on Case Record.
* This Apex Class is being referenced in VF Page - CS_ShowProductTree.
* CS stands for Cloud Spokes as part of Coding Standards.
************************************************************************/
public with sharing class TreeViewForManualCreation{
    
    /* Declaration of Variables */ 
       
    private static JSONGenerator gen {get; set;}
    public transient List<String> LstOfProductNodes{get;set;} 
    public Boolean dependentValue{get;set;} 
    public String ProblemId{get;set;} 
    // Getter Setter Method for searching input text in Product Tree on VF page.   
    public String InputText{get;set;}
    // Getter Setter Method for passing Selected Product from VF page to Apex Class. 
    public String ProductId{get;set;}  
    
    public String SelectedCategory{get;set;}
    //Manmeeet
    public String forPageValue {get; set;}
    public String alreadyPresentIds {get; set;}
    public Set<String> ids {get; set;}
    
    public String fromPageName{get;set;}
    private boolean isAlreadyCalled = false;
    Map<String,List<SObject>>MapProductAndLstChildren = null;
    
    /* Controller Method Starts here.*/
    public String ObjectName{
        
            get{
                return ObjectName;
            }
            set{
                ObjectName = value;
                LstOfProductNodes=new List<String>();
                //init();
            }
                
    }
    public void init(){
        LstOfProductNodes=new List<String>();
        processTreeStructure();
    }
    
    public void processTreeStructure(){
    	LstOfProductNodes=new List<String>();
        MapProductAndLstChildren = new Map<String,List<sObject>>();
        
            String queryText = 'Select id,Name,parent__c from '+ObjectName;
            queryText += checkForAlreadyPresentIds(true);
            if(ObjectName.equalsIgnoreCase('Support_Product__c')){
                queryText = queryText.replace('Name', 'Name, Product__c, Description__c');
            }
            for(SObject pd:Database.query(queryText)){
                if(!MapProductAndLstChildren.containsKey((String)pd.get('parent__c'))){
                     MapProductAndLstChildren.put((String)pd.get('parent__c'),new List<sObject>());
                }
                MapProductAndLstChildren.get((String)pd.get('parent__c')).add(pd);
            }
            GenerateTreeStructureForProducts();
    }
    /*Controller Method Ends here.*/
    
    /* Action method (called from VF:CS_ShowProductTree) starts here.
       Below method parses all Parent Products and adds them to JSON String 
       which is rendered on VF as Tree Structure. */
    public void GenerateTreeStructureForProducts(){
        
        // Generating Tree Strucutre for all Parent Products.  
        set<string> setOfProblemIds = new set<string>();
        set<Id> setOfSolutionIds = new set<Id>();
        String queryText = 'Select id,Name,parent__c from '+ObjectName+ ' where parent__c = null';
        queryText += checkForAlreadyPresentIds(false);
        if(ObjectName.equalsIgnoreCase('Support_Product__c')){
            queryText = queryText.replace('Name', 'Name, Product__c, Description__c');
        }
        if(String.isNotEmpty(selectedCategory) && !selectedCategory.equalsIgnoreCase('all')){
            queryText += ' AND Name = :selectedCategory';
        }
        List<SObject> recordList= Database.query(queryText);
        recordList.sort();
        for(SObject pd: recordList){    
            
            // Initializing JSON Generator Object.
            gen = JSON.createGenerator(true);
            
            /* Calls CreateTreeStructure method to retrieve Instance of Wrapper Class 
               which contains Parent and Child Nodes for each Product. */
            WrpProductNode node = CreateTreeStructure(pd);
            
            // Calling ConvertNodeToJSON Method. 
            ConvertNodeToJSON(node);
            
            // Creating List of All Product Nodes by adding instance of JSONGenerator as String.
            LstOfProductNodes.add(gen.getAsString());
           
        }
         
        MapProductAndLstChildren = null;
    } /* Action method ends here.*/ 
    
    /* CreateTreeStructure Method starts here : Below method creates Parent and Child Nodes for each Product 
       and returns instance of WrpProductNode (Wrapper class) */
    public  WrpProductNode CreateTreeStructure(SObject prd){            
        WrpProductNode wrpObj=new WrpProductNode(prd);
        //wrpObj.prod=prd;
        if(MapProductAndLstChildren.containsKey(prd.id)){
            wrpObj.hasChildren = true;
            List<WrpProductNode> lstOfChild = new List<WrpProductNode>();
            MapProductAndLstChildren.get(prd.id).sort();
            for(SObject pd:MapProductAndLstChildren.get(prd.id)){
                WrpProductNode temp = CreateTreeStructure(pd);
                lstOfChild.add(temp);
            }
            wrpObj.prodChildNode=lstOfChild;           
        }else{
             wrpObj.hasChildren = false;     
        }
         return wrpObj;        
    } /*CreateTreeStrucure Method Ends here.*/
    
    /*ConvertNodeToJSON method starts here : Below method converts 
    instance of each Product Node(Wrapper class) into JSON.*/
    public void ConvertNodeToJSON(WrpProductNode prodNode){ 
        
        // Creating Product Nodes in JSON format which are also attributes of DynaTree JQuery used in VisualForce.      
        gen.writeStartObject();
        String title = '';
        if(ObjectName.equalsIgnoreCase('Support_Product__c')){          
            if(fromPageName == 'preChatLinksys' && (String)prodNode.Prod.get('Name') != null && (String.valueOf(prodNode.Prod.get('Name'))).contains('P-')) {
                gen.writeStringField('title', String.valueOf(prodNode.Prod.get('Name')).substringAfter('P-') + (String)(prodNode.Prod.get('Description__c') == null ? '' : ' | '+prodNode.Prod.get('Description__c')));
            } else {
                gen.writeStringField('title', (String)(prodNode.Prod.get('Name') == null ? '' : prodNode.Prod.get('Name')) + (String)(prodNode.Prod.get('Description__c') == null ? '' : ' | '+prodNode.Prod.get('Description__c')));
            }           
        }else{
            gen.writeStringField('title', (String)(prodNode.Prod.get('Name') == null ? '' : prodNode.Prod.get('Name')));    
        }
        gen.writeStringField('key', String.valueOf(prodNode.Prod.get('Id')));
        /*
        if(forPageValue == 'CaseWizard' || forPageValue == 'ChatForm'){
            if(ObjectName.equalsIgnoreCase('Support_Product__c')){
                gen.writeStringField('key', String.valueOf(prodNode.Prod.get('Id')) + '-' + (String)(prodNode.Prod.get('Product__c') == null ? '' : prodNode.Prod.get('Product__c')));
            }else{
                gen.writeStringField('key', String.valueOf(prodNode.Prod.get('Id')));
            }
        }*/
        
        if(ProductId != null) {
            for(String prodID : ProductId.split(',')) {
                if(String.isNotBlank(prodID) && prodNode.prod.Id == prodID.trim()){
                    gen.writeBooleanField('select', true);
                }
            }
        }
        // else {
        //    if(String.isNotBlank(ProductId) && prodNode.prod.Id == ProductId){
         //       gen.writeBooleanField('select', true);
         //   }           
       // }
        // Below condition checks for any child Products available for each Parent product.
        if(prodNode.hasChildren ){
            
            // Below line disables Radio buttons for all Parent Products.
            if(forPageValue == 'CaseWizard' || forPageValue == 'ChatForm'){
                gen.writeBooleanField('hideCheckbox',true);
            }
            gen.writeFieldName('children');
            gen.writeStartArray();   
                    
            // Iterating each child product and adding further child products to Tree nodes by calling ConvertNodeToJSON method recursively.
            for(WrpProductNode temp:prodNode.prodChildNode){
               ConvertNodeToJSON(temp);
            }                                    
            gen.writeEndArray();           
        }
       gen.writeEndObject();            
    }/*ConvertNodeToJSON method ends here.*/
    
    /*Wrapper class starts here : Below class wraps Products,List of Child Products 
    and boolean variable for childs present for each Parent Product.*/
    public class WrpProductNode{        
        public List<WrpProductNode>prodChildNode{get;set;}
        public Boolean hasChildren {get; set;}    
        public SObject prod{get;set;}
        public WrpProductNode(SObject prod){
            this.prod = prod;
        }        
    } /*Wrapper Class ends here*/   
    
    /*UpdateCase Method starts here : Below method is triggered by clicking Save button on VF page.*/
    public void updateCase(){   
   
    }
    
    private string checkForAlreadyPresentIds(boolean isFromCreateRecordMap){
        String queryText = '';
        if(alreadyPresentIds != null){
            ids = new Set<String>();
            List<String> idList = alreadyPresentIds.split(',');
            for(String str : idList){
                ids.add(str);
            }
            if(isFromCreateRecordMap){
                queryText += ' where id not in : ids';  
            }else{
                queryText += ' and id not in : ids';
            }
        }
        return queryText;
    }
    
    public void cancel(){
        ProductId = null;
    }
}