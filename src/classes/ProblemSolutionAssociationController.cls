/*
Class : ProblemSolutionAssociationController 
Description :  This class is used for Associating Problems with Solutions 
Developed by : Manmeet Manethiya
Created Date : Aug 28, 2013
*/
public without sharing class ProblemSolutionAssociationController {
	public String selectedObjId {get; set;}
	public boolean showOperationBlock {get; set;}
	public List<List<CategoryWrapper>> listCategoriesOrProducts {get; set;}
	public String selectedSObject {get; set;}
	public sObject sObjectToBind {get;set;}
	public List<sObject> additionalSobjrows {get;set;}
	public String parentCategoryId {get;set;}
	public String selectedDMLType {get; set;}
	public List<String> listObjectFields {get;set;}
	public String parentCategory {get;set;}
	public Integer numberOfRowsToAdd {get;set;}
	public String selectedSolutionId {get;set;}
	public List<Problem_Solution_Junction__c> solutionCatList {get ; set ;}
	public String selectedSolutionIdsToAdd {get ; set ;}
	public String selectedProblemIdsToAdd {get ; set ;}
	public String solutionCatIds {get ; set ;}
	public String problemCatIds {get ; set ;}
	public boolean showSolOperationBlock {get; set;}
	public Solution_Category__c newSolutionCat{get; set;}
	public List<SelectOption> lstTypes {get;set;}
	public list<Problem_Solution_Junction__c> lstProblemCategory{get;set;}
	public List<Translation__c> listTranslations {get;set;}
	public String selectedProblemCategoryId {get;set;}
	public String selectedSolutionCategoryId {get;set;}
	public String selectedProductCategoryId {get;set;}
	public String selectedJunctionId {get;set;}
	public String selectedTranslationId {get;set;}
	public boolean isProblemObjEmpty {get;set;}
	public boolean isSolutionObjEmpty {get;set;}
	public Translation__c translation {get;set;}
	public String sourceSupportProduct {get; set;}
	public boolean isCalledAjaxValue {get; set;}
	public boolean isLeafNode{get;set;}
	public boolean isLeafNodeForSolutions{get;set;}
	
	public static Map<String , Schema.SObjectType> globalDescription;
	public static Set<String> fieldApiNamesToShowForAllCategories;
	
	static{
		globalDescription = Schema.getGlobalDescribe();
		fieldApiNamesToShowForAllCategories = new Set<String>();
		fieldApiNamesToShowForAllCategories.add('Name');
		fieldApiNamesToShowForAllCategories.add('Rank__c');
		fieldApiNamesToShowForAllCategories.add('Agent_Visible__c'); 
	}
	
	//Constructor
	public ProblemSolutionAssociationController(){
		showOperationBlock = false;
		showSolOperationBlock = false;
		isCalledAjaxValue = false;
		selectedSObject = 'Problem_Category__c';
		additionalSobjrows = new List<sObject>();
		getSobjectFields(selectedSObject);
		prepareTypePicklist();
		checkForEmptyObject();
	}
	
	private void prepareTypePicklist(){
		lstTypes = new List<SelectOption>();
		lstTypes.add(new SelectOption('Problem_Category__c','Problem'));
		lstTypes.add(new SelectOption('Solution_Category__c','Solution'));
		lstTypes.add(new SelectOption('Support_Product__c','Support Product'));
	}
	
	//this logic is here to check if we are inserting a first record.
	//If we want to insert a first record then we have to remove the atleast one record selection check on VF page
	private void checkForEmptyObject(){
		isProblemObjEmpty = false;
		isSolutionObjEmpty = false;
		if([Select Id from Problem_Category__c limit 1].size() == 0){
			isProblemObjEmpty = true;
		}
		if([Select Id from Solution_Category__c limit 1].size() == 0){
			isSolutionObjEmpty = true;
		}
		
	}
	
	public void getSobjectFields(String sObjName){  
        listObjectFields =  new List<String>();
        Schema.sObjectType sObjType = globalDescription.get(sObjName);  
        sObjectToBind = sObjType.newSObject();  
        Schema.DescribeSObjectResult r1 = sObjType.getDescribe();  
          
        Map<String , Schema.SObjectField> mapFieldList = r1.fields.getMap();  
        for(String name : mapFieldList.keyset()){
        	Schema.Describefieldresult dfr = mapFieldList.get(name).getDescribe();
			if(dfr.isDeprecatedAndHidden()){
				continue;
			}
			if(dfr.isAccessible() && fieldApiNamesToShowForAllCategories.contains(dfr.getName())){
				listObjectFields.add(dfr.getName());
			}			
        }
    } 
    
    public Pagereference fetchData(){
    	return null;
    }
    
    public Pagereference initialiseTranslation(){
    	
    	translation = new Translation__c(Support_Product__c = selectedProductCategoryId);
    	for(Support_Product__c cat : [select name from Support_Product__c where id = : selectedProductCategoryId]){
    		sourceSupportProduct = cat.name;	
    	}
    	return null;
    }
    
    public void saveTranslation(){
    	upsert translation;
    	fetchTranslationsData();
    }
    
    public void editTranslationAction(){
    	for(Translation__c tr : [Select Support_Product__r.name, language__C, name from Translation__c where id = : selectedTranslationId]){
    		translation = tr;
    		sourceSupportProduct = tr.Support_Product__r.name;
    	}
    }
    
    public void deleteProblemSolution(){
    	delete new Problem_Solution_Junction__c(id = selectedJunctionId);
    	getModifiedData();
    }
    
    public void deleteTranslationAction(){
    	delete new Translation__c(id = selectedTranslationId);
    	fetchTranslationsData();
    }
    
    private void getModifiedData(){
    	if(selectedSObject == 'Problem_Category__c'){
    		fetchSolutionsData();
    	}else if(selectedSObject == 'Solution_Category__c'){
    		fetchProblemCategory();	
		}else{
			fetchTranslationsData();
		}
    }
    
    public void fetchTranslationsData(){
    	listTranslations = new List<Translation__c>();
		for(Translation__c translation : [Select Language__c, name
										 from Translation__c where Support_Product__c =: selectedProductCategoryId]){
		   listTranslations.add(translation);
		}
	}
    
    //fetching Solutions to show on left panel of the page
	public void fetchSolutionsData(){
		isLeafNode = true;
		for(Problem_Category__c pCat : [SELECT (SELECT Id FROM Problem_Categories__r) FROM Problem_Category__c WHERE ID =: selectedProblemCategoryId]){
			if(pCat.Problem_Categories__r.size() <> 0){
				isLeafNode = false;
			}
		}
		solutionCatList = new List<Problem_Solution_Junction__c>();
		solutionCatIds = '';
		if(isLeafNode){
			for(Problem_Solution_Junction__c cat : [Select Solution_Category__c, Solution_Category__r.name from Problem_Solution_Junction__c where Problem_Category__c =: selectedProblemCategoryId]){
			   solutionCatList.add(cat);
			   solutionCatIds += cat.Solution_Category__c + ',';
			}
			if(solutionCatIds.contains(',')){
				solutionCatIds = solutionCatIds.substring(0, solutionCatIds.length()-1);	
			}
		}else{
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Solutions are only allowed at the lowest level of the child in the tree.'));
		}
	}
	
	// fatch lstProblemCategory
    public void fetchProblemCategory(){
    	isLeafNodeForSolutions = true;
    	for(Solution_Category__c pCat : [SELECT (SELECT Id FROM Solution_Categories__r) FROM Solution_Category__c WHERE ID =: selectedSolutionCategoryId]){
			if(pCat.Solution_Categories__r.size() <> 0){
				isLeafNodeForSolutions = false;
			}
		}
    	lstProblemCategory = new List<Problem_Solution_Junction__c>();
		problemCatIds = '';
		if(isLeafNodeForSolutions){
			for(Problem_Solution_Junction__c cat : [Select Problem_Category__c, Problem_Category__r.name from Problem_Solution_Junction__c where Solution_Category__c =: selectedSolutionCategoryId]){
			   lstProblemCategory.add(cat);
			   problemCatIds += cat.Problem_Category__c + ',';
			}
			if(problemCatIds.contains(',')){
				problemCatIds = problemCatIds.substring(0, problemCatIds.length()-1);	
			}
		}else{
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Problems are only allowed at the lowest level of the child in the tree.'));
		}
    }
	
	
	public Pagereference addCategories(){
    	List<sObject> listObjectToInsert = new List<sObject>();
    	Schema.sObjectType sObjType = globalDescription.get(selectedSObject);
    	sObject objToInsert = sObjType.newSObject(); 
    	String brandName = '';
    	if(selectedSObject == 'Problem_Category__c'){
    		selectedObjId = selectedProblemCategoryId.split('-')[0];
    	}else if(selectedSObject == 'Solution_Category__c'){
    		selectedObjId = selectedSolutionCategoryId;	
		}else if(selectedSObject == 'Support_Product__c'){
    		selectedObjId = selectedProductCategoryId;
    		objToInsert.put('Description__c', String.valueOf(sObjectToBind.get('Description__c')));
    		brandName = String.valueOf(sObjectToBind.get('Brand__c'));
    		objToInsert.put('Brand__c', brandName);
    	}
        objToInsert.put('Rank__C', Double.valueOf(sObjectToBind.get('Rank__C')));
    	objToInsert.put('Agent_Visible__C', Boolean.valueOf(sObjectToBind.get('Agent_Visible__C')));
    	objToInsert.put('Name', String.valueOf(sObjectToBind.get('Name')));
        if(selectedDMLType.equalsIgnoreCase('edit')){
        	update sObjectToBind;
        }else if(selectedDMLType.equalsIgnoreCase('child')){
        	objToInsert.put('Parent__c', selectedObjId);
        	listObjectToInsert.add(objToInsert);
        	for(sObject obj : additionalSobjrows){
        		if(String.valueOf(obj.get('Name')) != ''){
        			obj.put('Parent__c', selectedObjId);
        			if(selectedSObject == 'Support_Product__c'){
        				obj.put('Brand__c', brandName);
        			}
        			listObjectToInsert.add(obj);
        		}
        	}
        	insert listObjectToInsert;
        }else if(selectedDMLType.equalsIgnoreCase('sibling')){
        	
        	objToInsert.put('Parent__c', parentCategoryId);
	        listObjectToInsert.add(objToInsert);
	        for(sObject obj : additionalSobjrows){
        		if(String.valueOf(obj.get('Name')) != ''){
        			obj.put('Parent__c', parentCategoryId);
        			listObjectToInsert.add(obj);
        		}
        	}
        	insert listObjectToInsert;
        }else if(selectedDMLType.equalsIgnoreCase('delete')){
        	sObjectToBind = Database.query('Select Id from '+ selectedSObject +' where id =: selectedObjId');
        	delete sObjectToBind;
        	getSobjectFields(selectedSObject);
        	if(selectedSObject == 'Problem_Category__c'){
    			isLeafNode = false;
	    	}else{
	    		isLeafNodeForSolutions = false;	
			}
        }
        /*
        Pagereference pg = new Pagereference('/apex/ProblemSolutionAssociation');
        pg.setRedirect(true);
        */
        showOperationBlock = false;
        return null;
    }
    
    public Pagereference processDMLOperation(){
    	showOperationBlock = true;
    	if(selectedSObject == 'Problem_Category__c'){
    		selectedObjId = selectedProblemCategoryId.split('-')[0];
    		isProblemObjEmpty = false;
    	}else if(selectedSObject == 'Solution_Category__c'){
    		selectedObjId = selectedSolutionCategoryId;
    		isSolutionObjEmpty = false;	
		}else if(selectedSObject == 'Support_Product__c'){
    		selectedObjId = selectedProductCategoryId;
    	}
    	Schema.sObjectType sObjType = globalDescription.get(selectedSObject);
    	sObjectToBind = sObjType.newSObject();
    	if(!String.isEmpty(selectedObjId) && selectedDMLType != 'None'){
    		String query = 'Select Id, Name,parent__C, parent__r.Name, rank__c, Agent_Visible__c from '+ selectedSObject +' where id =\'' + selectedObjId + '\'';
    		if(selectedSObject == 'Support_Product__c'){
    			query = query.replace('Agent_Visible__c', 'Agent_Visible__c, Description__c, Brand__c ');
    		}
    		sObjectToBind = Database.query(query);
    		if(!selectedDMLType.equalsIgnoreCase('edit')){
    			sObjectToBind.put('Agent_Visible__c', true);
    			sObjectToBind.put('rank__c', null);
    			sObjectToBind.put('Description__c', '');
    		}
    		if(sObjectToBind.getSObject('parent__r') != null){
	    		parentCategory = String.valueOf(sObjectToBind.getSObject('parent__r').get('Name'));
	    		parentCategoryId = String.valueOf(sObjectToBind.get('parent__c'));
    		}
    	}else{
    		parentCategory = '';
    		parentCategoryId = '';
    	}
    	numberOfRowsToAdd = 0;
    	additionalSobjrows = new List<SObject>(); 
    	return null;
    }
    
    public Pagereference fetchMatchingProducts(){
    	String marketingParent = String.valueOf(sObjectToBind.get('Name')).split(' | ').size() > 1 ? String.valueOf(sObjectToBind.get('Name')).split(' | ')[0] : String.valueOf(sObjectToBind.get('Name'));
    	for(Product2 product : [Select Description from Product2 where Marketing_Parent__c = :marketingParent and Marketing_Parent__c != null]){
    		sObjectToBind.put('Description__c', product.Description);
    	}
    	return null;
    }
    
    public Pagereference initialiseRows(){
    	Schema.sObjectType sObjType = globalDescription.get(selectedSObject);
    	for(Integer i = 0; i < numberOfRowsToAdd; i++){
    		sObject objToInsert = sObjType.newSObject();
    		objToInsert.put('Agent_visible__C', true);
    		additionalSobjrows.add(objToInsert);
    	}
    	return null;
    }
    
    public void saveNewSolution(){
    	List<Problem_Solution_Junction__c> listToInsert = new List<Problem_Solution_Junction__c>();
    	List<String> commaSeperatedIds = new List<String>();
    	if(selectedSObject == 'Problem_Category__c'){
    		commaSeperatedIds = selectedSolutionIdsToAdd.split(',');
    		for(String solutionId : commaSeperatedIds){
	    		listToInsert.add(new Problem_Solution_Junction__c(problem_category__c = selectedProblemCategoryId.trim(), solution_category__c = solutionId.trim()));
	    	}
    	}else if(selectedSObject == 'Solution_Category__c'){
    		commaSeperatedIds = selectedProblemIdsToAdd.split(',');
    		for(String problemId : commaSeperatedIds){
	    		listToInsert.add(new Problem_Solution_Junction__c(problem_category__c = problemId.trim(), solution_category__c = selectedSolutionCategoryId.trim()));
	    	}
		}
    	insert listToInsert;
    	showSolOperationBlock = false;
    	getModifiedData();
    }
    
    public void showAddSolutionPanel(){
    	showSolOperationBlock = true;
    }
    
    public Pagereference hideLightBoxAction(){
    	showSolOperationBlock = false;
    	return null;
    }
    
    
	//wrapper class
	Class CategoryWrapper{
		public sObject obj {get; set;}
		public boolean isSelected {get; set;}
		
		public CategoryWrapper(sObject obj){
			this.obj = obj;
			this.isSelected = false;
		}
	}
}