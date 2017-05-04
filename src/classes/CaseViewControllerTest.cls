/******************************************************************************
Name            :  CaseViewControllerTest
Created by      :  Kirti Agarwal
Created Date    :  Aug 28, 2013
Description     :  Test class for CaseViewController.
******************************************************************************/
@isTest
private class CaseViewControllerTest {
	
	static testMethod void caseHavePCandSP() {
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
		
		/*
		PKB__c pkb = new PKB__c();
		pkb.Name = 'test pkb';
		insert pkb;
		
		*/
		Document__kav document = new Document__kav();
		document.Body__c = 'test body';
		document.UrlName = 'testurl';
		document.title ='testArticle';
		insert document;		
		
		Document__kav documentKav = [select articleNumber, ArticleType from Document__kav where id =: document.id limit 1];
		KnowledgeArticle theArticle = [select ID from KnowledgeArticle Where ArticleNumber =:documentKav.articleNumber limit 1];
		
		CaseArticle casArticle = new CaseArticle();
		casArticle.CaseId = cas.id; 
		casArticle.KnowledgeArticleId = theArticle.id;
		insert casArticle;	   
		Article_Category__c ac = TestUtility.createArticleCategory(cas.id, theArticle.id, pbCat.id, sp.id, true);
		ApexPages.StandardController controller = new ApexPages.StandardController(cas);
		CaseViewController obj = new CaseViewController(controller);
		obj.attachCase();
		system.assert(obj.listArticleCategories.size() > 0);
		obj.listArticleCategories[0].isSelected = true;
		obj.fetchCaseArticles();
		system.assert(obj.listArticleCategories.size() > 0);
		obj.attachCase();
	}
	
	static testMethod void caseHavePCandNotSP() {
		Account acc = createAccount(true);
		Asset asset = createAsset(acc, true);
		Problem_Category__c pbCat = TestUtility.createProblemCategory('Testing', true);
		Case cas = TestUtility.createCase('test case', '4738945', 'Email', false);
		cas.Problem_Category__c = pbCat.id;
		cas.AssetId = asset.id;
		insert cas;
		
		/*
		PKB__c pkb = new PKB__c();
		pkb.Name = 'test pkb';
		insert pkb;
		*/
		Document__kav document1 = new Document__kav();
		document1.Body__c = 'test body';
		document1.UrlName = 'testurl';
		document1.title ='testArticle';
		insert document1;	
		
		Document__kav document2 = new Document__kav();
		document2.Body__c = 'test body';
		document2.UrlName = 'testurl23';
		document2.title ='testArticle';
		insert document2;		
		
		Document__kav documentKav = [select articleNumber, ArticleType from Document__kav where id =: document1.id limit 1];
		KnowledgeArticle theArticle = [select ID from KnowledgeArticle Where ArticleNumber =:documentKav.articleNumber limit 1];
		documentKav = [select articleNumber, ArticleType from Document__kav where id =: document2.id limit 1];
	  KnowledgeArticle theArticle1 = [select ID from KnowledgeArticle Where ArticleNumber =:documentKav.articleNumber limit 1];
	  
		CaseArticle casArticle = new CaseArticle();
		casArticle.CaseId = cas.id; 
		casArticle.KnowledgeArticleId = theArticle.id;
		insert casArticle;
			 
		Article_Category__c ac1 = TestUtility.createArticleCategory(cas.id, theArticle.id, pbCat.id, null, true);
	
		ApexPages.StandardController controller = new ApexPages.StandardController(cas);
		CaseViewController obj = new CaseViewController(controller);
		system.assert(obj.listArticleCategories.size() > 0);	
		
	}
	
	static Asset createAsset(Account acc, Boolean isInsert) {
		Asset asset = new Asset(Name = 'test Asset', AccountId = acc.id);
		if( isInsert ) {
			insert asset;
		}
		return asset;
	}
	
	static Account createAccount(Boolean isInsert) {
		TestUtility.createTriggerSettings();
		String personAccRecordTypeId = Account.getSObjectType().getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
		Account acc = new Account(Name = 'first name');
		if( isInsert ) {
			insert acc;
		}
		return acc;
	}

}