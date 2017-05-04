/*******************************************************************************
 Name          :  TestUtility
 Author        :  Manmeet Manethiya (Appirio Offshore)
 Date          :  July 9, 2013
 Description   :  This class can be called and re-used from other test 
                  classes that need an object created with fields values.
*******************************************************************************/
@isTest 
public with sharing class TestUtility {
  
  
 public static void createTriggerSettings() {
 	Trigger_Settings__c oldTSetting = Trigger_Settings__c.getInstance('Toggle Triggers');
 	if(oldTSetting == null){
	    Trigger_Settings__c tSetting = new Trigger_Settings__c();
	  	tSetting.Name = 'Toggle Triggers';
	  	tSetting.Disable_Account_Triggers__c = false;
	  	insert tSetting;
 	}
  }

public static Support_Product__c createSupportProduct(String name, Boolean isInsert){
	  Support_Product__c sp1 = new Support_product__c();
		sp1.name = name;
		if(isInsert) 
      insert sp1;
    return sp1;
	} 
	
  //----------------------------------------------------------------------------
  //Create Problem Category records
  //----------------------------------------------------------------------------
  public static Problem_Category__c createProblemCategory(String categoryName, Boolean isInsert ) {
    Problem_Category__c pCategory = new Problem_Category__c();
  	pCategory.Name = categoryName;
    if(isInsert) 
      insert pCategory;
    return pCategory;
  }

//================================================================//
    // Create a new Case 
    //================================================================//
    public static Case createCase(String suppliedName, String suppliedPhone, String origin, boolean isInsert){
        Case cases = new Case();
        cases.SuppliedName = suppliedName;        
        cases.SuppliedPhone = suppliedPhone;
        cases.origin = origin;
        if(isInsert) {
            insert cases;
        }
        return cases;
    }

	public static Article_Category__c createArticleCategory(Id caseId, Id articleId, Id pbct,Id sp ,Boolean isInsert) {
   Article_Category__c articleCat = new Article_Category__c();
   articleCat.Article_Id__c = articleId;
   articleCat.Problem_Category__c = pbct;
   articleCat.Support_Product__c = sp;
   
   if( isInsert ) {
			insert articleCat;
		}
		return articleCat;
  }
  
}