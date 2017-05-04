/**
 * Class : problemsolutionassociationcontrollerTest 
 * Description :  This is the test class for problemsolutionassociationcontroller.
 * Developed by : Kirti Agarwal
 * Created Date : 7 September, 2013
 */
@isTest
private class problemsolutionassociationcontrollerTest {
    
    //this method test for the translation functionality
    static testMethod void testForTranslation() {
    	  Support_Product__c  productCat = new Support_Product__c (Name ='test product category');
        insert productCat;
        ProblemSolutionAssociationController obj = new ProblemSolutionAssociationController();
        system.assert(obj.fetchData() == null);
        obj.selectedProductCategoryId = productCat.id;
        // It will in itialize the translation record
        obj.initialiseTranslation();
        system.assertEquals(obj.sourceSupportProduct, productCat.Name);
        // It will save the translation record
        obj.saveTranslation();
        List<Translation__c> translationList = new List<Translation__c> ([select id from Translation__c where Support_Product__c =:productCat.id ]);
        system.assert(translationList.size() > 0);       
        obj.selectedTranslationId = translationList[0].id;
        obj.editTranslationAction();
        system.assertEquals(obj.sourceSupportProduct, productCat.Name);
        obj.deleteTranslationAction();
        system.assert(obj.listTranslations.size() == 0);
    }
    
    //this method test for the Solution functionality
    static testMethod void testForSolution() {
    	  Problem_Category__c problemCategory = new Problem_Category__c();
    	  problemCategory.Name = 'test problem category';
    	  insert problemCategory;
    	  
    	  Solution_Category__c SolutionCategory = new Solution_Category__c();
    	  SolutionCategory.Name = 'test solution category';
    	  insert SolutionCategory;
    	  
    	  Problem_Solution_Junction__c junction = new Problem_Solution_Junction__c();
    	  junction.Solution_Category__c = SolutionCategory.id;
    	  junction.Problem_Category__c = problemCategory.id;
    	  insert junction;
    	  
    	  ProblemSolutionAssociationController obj = new ProblemSolutionAssociationController();
    	  obj.selectedProblemCategoryId = problemCategory.id;
    	  obj.fetchSolutionsData();
    	  system.assert(obj.solutionCatList.size() > 0);
    	  obj.selectedJunctionId = junction.id;
    	  obj.deleteProblemSolution();
    	  
    }
    
    //this method test for the Problem functionality
    static testMethod void testForProblemCategory() {
    	 Problem_Category__c problemCategory = new Problem_Category__c();
    	  problemCategory.Name = 'test problem category';
    	  insert problemCategory;
    	  
    	  Solution_Category__c SolutionCategory = new Solution_Category__c();
    	  SolutionCategory.Name = 'test solution category';
    	  insert SolutionCategory;
    	  
    	  Problem_Solution_Junction__c junction = new Problem_Solution_Junction__c();
    	  junction.Solution_Category__c = SolutionCategory.id;
    	  junction.Problem_Category__c = problemCategory.id;
    	  insert junction;
    	  
    	  ProblemSolutionAssociationController obj = new ProblemSolutionAssociationController();
    	  obj.selectedSolutionCategoryId = SolutionCategory.id;
    	  obj.fetchProblemCategory();
    	  system.assert(obj.lstProblemCategory.size() > 0);
    	  
    }
   
     static testMethod void testForDML_Operation() {
     	Support_Product__c  productCat = new Support_Product__c (Name ='test product category');
      insert productCat;
      
     	Problem_Category__c problemCategory = new Problem_Category__c();
	  	problemCategory.Name = 'test problem category';
	  	insert problemCategory;
	  	
	  	Solution_Category__c SolutionCategory = new Solution_Category__c();
	  	SolutionCategory.Name = 'test solution category';
	  	insert SolutionCategory;
    
     	ProblemSolutionAssociationController obj = new ProblemSolutionAssociationController();
     	obj.selectedSObject = 'Problem_Category__c';
     	obj.selectedProblemCategoryId = problemCategory.id;
     	obj.selectedDMLType = 'edit';
     	obj.processDMLOperation();
     	obj.selectedSolutionIdsToAdd = SolutionCategory.id;
     	obj.saveNewSolution();
     	List<Problem_Solution_Junction__c> recList = [select id from Problem_Solution_Junction__c where Solution_Category__c =: SolutionCategory.id];
      system.assert(recList.size() > 0 );
     	obj.selectedSObject = 'Solution_Category__c';
     	obj.selectedSolutionCategoryId = SolutionCategory.id;
     	obj.selectedDMLType = 'child';
     	obj.processDMLOperation();
     	obj.selectedProblemIdsToAdd = problemCategory.id;
     	obj.saveNewSolution();
      recList = [select id from Problem_Solution_Junction__c where Problem_Category__c =: problemCategory.id];
      system.assert(recList.size() > 0 );
     
     	obj.selectedSObject = 'Support_Product__c';
     	obj.selectedProductCategoryId = productCat.id;
     	obj.selectedDMLType = 'sibling';
     	obj.processDMLOperation();
     	obj.fetchMatchingProducts();
     	obj.numberOfRowsToAdd = 1;
     	obj.initialiseRows();
      obj.saveNewSolution();
      
     	
     }
     
     //this method test for other functions
    static testMethod void testForOtherFunction() {
    	ProblemSolutionAssociationController obj = new ProblemSolutionAssociationController();
    	obj.showAddSolutionPanel();
    	system.assert(obj.showSolOperationBlock,true);
    	obj.hideLightBoxAction();
    	system.assertEquals(obj.showSolOperationBlock,false);
    }
    
    static testMethod void testForAddCategoryEdit() {
    	Support_Product__c  productCat = new Support_Product__c (Name ='test product category');
      insert productCat;
      
     	Problem_Category__c problemCategory = new Problem_Category__c();
	  	problemCategory.Name = 'test problem category';
	  	insert problemCategory;
	  	
	  	Solution_Category__c SolutionCategory = new Solution_Category__c();
	  	SolutionCategory.Name = 'test solution category';
	  	insert SolutionCategory;
    
     	ProblemSolutionAssociationController obj = new ProblemSolutionAssociationController();
     	obj.selectedProblemCategoryId = problemCategory.id;
     	obj.selectedSObject = 'Problem_Category__c';
     	obj.getSobjectFields('Problem_Category__c');
     	obj.selectedDMLType = 'edit';
     	obj.processDMLOperation();
     	obj.addCategories();
     	
 	 		obj.selectedSolutionCategoryId = SolutionCategory.id;
     	obj.selectedSObject = 'Solution_Category__c';
     	obj.getSobjectFields('Solution_Category__c');
     	obj.selectedDMLType = 'child';
     	obj.processDMLOperation();
     	obj.addCategories();
     	
     	obj.selectedProductCategoryId = productCat.id;
     	obj.selectedSObject = 'Support_Product__c';
     	obj.getSobjectFields('Support_Product__c');
     	obj.selectedDMLType = 'sibling';
     	obj.processDMLOperation();
     	obj.addCategories();
      
       obj.selectedProductCategoryId = productCat.id;
     	obj.selectedSObject = 'Support_Product__c';
     	obj.getSobjectFields('Support_Product__c');
     	obj.selectedDMLType = 'delete';
     	obj.processDMLOperation();
     	obj.addCategories();
    }
 
}