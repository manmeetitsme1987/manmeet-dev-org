@isTest
private class ArticleAssociation_v3ControllerTest { 
    static testMethod void  testArticleAssociationForDeleteArticleCategory() {
        Account acc = createAccount(true);
        Support_Product__c sp = TestUtility.createSupportProduct('test',true);
        Asset asset = createAsset(acc, false);
        asset.Support_Product__c = sp.id;
        insert asset;
        Problem_Category__c pbCat = TestUtility.createProblemCategory('Testing', true);
        Case cas = TestUtility.createCase('test case', '4738945', 'Email', false);
        cas.Problem_Category__c = pbCat.id;
        cas.AssetId = asset.id;
        insert cas;
        
        Product2 p2 = new Product2(Name='ACCKITS');
        p2.Part_Number__c = '78';
        p2.Family = 'ACCKITS';
        p2.Support_Product__c = sp.id; 
        p2.Marketing_Parent__c = 'test';        
        insert p2;
        
        Document__kav document = new Document__kav();
        document.Body__c = 'test body';
        document.UrlName = 'testurl';
        document.title ='testArticle';
        insert document;        
        
        Document__kav documentKav = [select articleNumber, ArticleType from Document__kav where id =: document.id limit 1];
        KnowledgeArticle theArticle = [select ID from KnowledgeArticle Where ArticleNumber =:documentKav.articleNumber limit 1];
    Article_Category__c ac = TestUtility.createArticleCategory(cas.id, theArticle.id, pbCat.id, sp.id, false);
    ac.Product2__c = p2.id;
    insert ac;
        ArticleAssociation_v3Controller obj = new ArticleAssociation_v3Controller();            
        obj.selectedKnowledgeArticleId = theArticle.id;
        try{
          obj.createArticle();
        }catch (exception e) {}
      //system.assert(acRecList.size() > 0);
      obj.getLanguages();
      //obj.getNumberOfRecordsInPage();
      obj.selectedProblemIds = pbCat.id;
      obj.selectedProductIds = sp.id;
      obj.selectedArticleIndex = '0' ;
      obj.openTreeViewAction();
      obj.createArticle();
      List<Article_Category__c>  acRecList = [select ID from Article_Category__c where id=:ac.id];
      system.assertEquals(acRecList.size() , 0);      
      obj.createArticleCategoryForProduct2();
    }
    
    static testMethod void  testArticleAssociationForCreateArticleForProduct() {
        Account acc = createAccount(true);
        Support_Product__c sp = TestUtility.createSupportProduct('test',true);
        Asset asset = createAsset(acc, false);
        asset.Support_Product__c = sp.id;
        insert asset;
        Problem_Category__c pbCat = TestUtility.createProblemCategory('Testing', true);
        Case cas = TestUtility.createCase('test case', '4738945', 'Email', false);
        cas.Problem_Category__c = pbCat.id;
        cas.AssetId = asset.id;
        insert cas;
        
        Product2 p2 = new Product2(Name='test');
        p2.Part_Number__c = '78';
        p2.Family = 'ACCKITS';
        p2.Support_Product__c = sp.id;
        insert p2;
        
        Document__kav document = new Document__kav();
        document.Body__c = 'test body';
        document.UrlName = 'testurl';
        document.title ='testArticle';
        insert document;        
        
        Document__kav documentKav = [select articleNumber, ArticleType from Document__kav where id =: document.id limit 1];
        KnowledgeArticle theArticle = [select ID from KnowledgeArticle Where ArticleNumber =:documentKav.articleNumber limit 1];
    Article_Category__c ac = TestUtility.createArticleCategory(cas.id, theArticle.id, pbCat.id, sp.id, false);
    ac.Product2__c = p2.id;
    insert ac;
        ArticleAssociation_v3Controller obj = new ArticleAssociation_v3Controller();            
        obj.selectedKnowledgeArticleId = theArticle.id;
      obj.getLanguages();
      //obj.getNumberOfRecordsInPage();
      obj.selectedProblemIds = pbCat.id;
      obj.selectedProductIds = sp.id;
      obj.selectedArticleIndex = '0' ;
      obj.selectedKnowledgeArticleTitle = 'knowledge title';
      
      // for Product tree view
      obj.selectedTreeView =  'Product'; 
      obj.openTreeViewAction();
      obj.createArticle();
      List<Article_Category__c>  acRecList = [select ID from Article_Category__c where id=:ac.id];
      system.assertEquals(acRecList.size() , 0);    
      acRecList = [select ID from Article_Category__c where Support_Product__c =:sp.id];
      system.assertEquals(acRecList.size() , 1);

    }
    
    static testMethod void  testArticleAssociationForCreateArticleForProblem() {
        Account acc = createAccount(true);
        Support_Product__c sp = TestUtility.createSupportProduct('test',true);
        Asset asset = createAsset(acc, false);
        asset.Support_Product__c = sp.id;
        insert asset;
        Problem_Category__c pbCat = TestUtility.createProblemCategory('Testing', true);
        Case cas = TestUtility.createCase('test case', '4738945', 'Email', false);
        cas.Problem_Category__c = pbCat.id;
        cas.AssetId = asset.id;
        insert cas;
        
        Product2 p2 = new Product2(Name='test');
        p2.Part_Number__c = '78';
        p2.Family = 'ACCKITS';
        p2.Support_Product__c = sp.id;
        insert p2;
        
        Document__kav document = new Document__kav();
        document.Body__c = 'test body';
        document.UrlName = 'testurl';
        document.title ='testArticle';
        insert document;        
        
        Document__kav documentKav = [select articleNumber, ArticleType from Document__kav where id =: document.id limit 1];
        KnowledgeArticle theArticle = [select ID from KnowledgeArticle Where ArticleNumber =:documentKav.articleNumber limit 1];
    Article_Category__c ac = TestUtility.createArticleCategory(cas.id, theArticle.id, pbCat.id, sp.id, false);
    ac.Product2__c = p2.id;
    insert ac;
        ArticleAssociation_v3Controller obj = new ArticleAssociation_v3Controller();            
        obj.selectedKnowledgeArticleId = theArticle.id;
      obj.getLanguages();
      //obj.getNumberOfRecordsInPage();
      obj.selectedProblemIds = pbCat.id;
      obj.selectedProductIds = sp.id;
      obj.selectedArticleIndex = '0' ;
      obj.selectedKnowledgeArticleTitle = 'knowledge title';
      
      // for Product tree view
      obj.selectedTreeView =  'Problem'; 
      obj.openTreeViewAction();
      obj.createArticle();
      List<Article_Category__c>  acRecList = [select ID from Article_Category__c where id=:ac.id];
      system.assertEquals(acRecList.size() , 0);    
      acRecList = [select ID from Article_Category__c where Problem_Category__c =:pbCat.id];
      system.assertEquals(acRecList.size() , 1);
      obj.getPageNumber();
      obj.getListOfWrapperArticle();
      obj.getPageSize();
      obj.getPreviousButtonEnabled();
    obj.getNextButtonDisabled();
    obj.getLastButtonEnabled();
    obj.getFirstButtonEnabled();
    obj.getTotalPageNumber();
    obj.nextBtnClick();
    obj.previousBtnClick();
    obj.jumpBtnClick();
    obj.lastPageBtnClick();
    obj.firstPageBtnClick();
    obj.renderNewRecords();
    obj.checkForLanguageAction();
    obj.fetListOfArticlesAssociated();
    obj.openProduct2List();
    }
 
static Account createAccount(Boolean isInsert) {
    TestUtility.createTriggerSettings();
    //String personAccRecordTypeId = Account.getSObjectType().getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account(Name = 'first name');
        if( isInsert ) {
            insert acc;
        }
        return acc;
    }
    
    static Asset createAsset(Account acc, Boolean isInsert) {
        Asset asset = new Asset(Name = 'test Asset', AccountId = acc.id);
        if( isInsert ) {
            insert asset;
        }
        return asset;
    }
    
}