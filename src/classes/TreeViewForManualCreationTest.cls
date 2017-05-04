/****************************************************************************************
Class Name		: TreeViewForManualCreationTest
Created By		: Kirti Agarwal
Created Date	: 18th September, 2013
Purpose      	: Test class for TreeViewForManualCreation.
Task         	: T-185695
****************************************************************************************/
@isTest
public class TreeViewForManualCreationTest {
	
	static testmethod void TreeViewForManualCreationTest() {
		Support_Product__c sp1 = createSupportProduct('test P-product1', true);
		Support_Product__c sp2 = createSupportProduct('test P-Product2', false);
		sp2.Parent__c = sp1.id;
		insert sp2;
		
		TreeViewForManualCreation obj = new TreeViewForManualCreation();		
		system.assertEquals(obj.LstOfProductNodes, null);
		obj.ObjectName = 'Support_Product__c';
		obj.init();
		system.assert(obj.LstOfProductNodes.size() > 0);
		obj.fromPageName = 'preChatLinksys';
		obj.init();
		system.assert(obj.LstOfProductNodes.size() > 0);
	}
	
	static testmethod void TestWithAlreadyPresentIds() {
		Support_Product__c sp = createSupportProduct('test product', true);
		TreeViewForManualCreation obj = new TreeViewForManualCreation();
		obj.alreadyPresentIds = sp.id;		
		system.assertEquals(obj.LstOfProductNodes, null);
		obj.ObjectName = 'Support_Product__c';
		obj.init();
		obj.cancel();	
		system.assertEquals(obj.ProductId, null);
		obj.updateCase();
	}
	
	static testmethod void TestWithProductIds() {
		Problem_Category__c pc = createProblemCategory('test problem', true);
		Problem_Category__c pc1 = createProblemCategory('test problem Category1', false);
		pc1.Parent__c = pc.id;
		insert pc1;
		TreeViewForManualCreation obj = new TreeViewForManualCreation();
		system.assertEquals(obj.LstOfProductNodes, null);
		obj.SelectedCategory = 'test problem';
		obj.forPageValue = 'CaseWizard';
		obj.ObjectName = 'Problem_Category__c';
		obj.ProductId = pc.id;
		obj.init();
		obj.cancel();
		system.assert(obj.LstOfProductNodes.size() > 0);
		system.assertEquals(obj.ProductId, null);
	}
	
	// Create Support_Product__c record for test data 
	Static Support_Product__c createSupportProduct(String name, Boolean isInsert){
	  Support_product__c supportProd = new Support_product__c(Name = name);
		if( isInsert ) {
			insert supportProd;
		}
		return supportProd;
	}
	
	// Create Problem_Category__c record for test data 
	Static Problem_Category__c createProblemCategory(String name, Boolean isInsert){
	  Problem_Category__c probCategory = new Problem_Category__c(Name = name);
		if(isInsert) {
			insert probCategory;
		}
		return probCategory;
	}
}