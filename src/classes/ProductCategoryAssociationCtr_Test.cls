// 
// (c) 2013 Appirio, Inc.
//
// ProductCategoryAssociationCtr_Test
// Test class for ProductCategoryAssociationController class
//
// 29 July 2013     Sandeep Kumar(JDC)       Original
//
@isTest
public class ProductCategoryAssociationCtr_Test {
	static testMethod void unitTest() {
		
		List<Support_Product__c> lstPCategory = new List<Support_Product__c>();
		List<Product2> lstProduct2 = new List<Product2>();
		
		for(Integer i = 0 ; i < 10 ; i++) {
			lstPCategory.add(new Support_Product__c (Name ='test product category '+i));
		}
		
      	insert lstPCategory; // creating test Support_Product__c data
      	
      	for(Integer i = 0 ; i < 10 ; i++) {
			lstProduct2.add(new Product2(Name='Test Product '+i, Part_Number__c = 'i', isActive = true));
		}
		
      	insert lstProduct2;// creating test Product2 data
      	
      	Test.startTest();
      	
      		PageReference pageRef = Page.Product2ProductCategoryAssociation;
        	Test.setCurrentPage(pageRef);
        
            ProductCategoryAssociationController controller = new ProductCategoryAssociationController();
            
            controller.getViewOptions();
            
            //checking assert before Associating Product2 with Support_Product__c
            System.assertEquals([SELECT Id,Support_Product__c FROM Product2 WHERE isActive = true and Support_Product__c != null].size(), 0);
            
            //setting selected Support_Product__c and selcted Product2 to Associate them
            controller.selectedObjId = lstPCategory.get(0).Id;
            controller.listCategoriesOrProducts.get(0).get(0).isSelected = true;
            controller.save(); // calling save function to updated slected Product2
            
            //checking assert after Associating Product2 with Support_Product__c
            System.assertEquals([SELECT Id,Support_Product__c FROM Product2 WHERE isActive = true and Support_Product__c != null].size(), 1);
            
            controller.fetchAssociatedProduct();
            
            // check error case
            controller.selectedObjId = null;
            controller.save(); // calling save function
            
            //checking assert after calling error case no more product Associate with Support_Product__c
            System.assertEquals([SELECT Id,Support_Product__c FROM Product2 WHERE isActive = true and Support_Product__c != null].size(), 1);
            
            controller.searchString = '2';
            controller.filterProducts();
            
            //checking filtered result 
            System.assertEquals(controller.listCategoriesOrProducts.size(), 1);
            
      	Test.stopTest();
	}
}