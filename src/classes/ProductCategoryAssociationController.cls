/*
Class : ProductCategoryAssociationController 
Description :  This class is used for Associating Products with Product category 
Developed by : Manmeet Manethiya
Created Date : Aug 28, 2013
*/
public without sharing class ProductCategoryAssociationController {
	public String selectedObjId {get; set;}
	public List<List<CategoryWrapper>> listCategoriesOrProducts {get; set;}
	public String searchString {get;set;}	
	public String selectedView{get;set;}
	//Constructor
	public ProductCategoryAssociationController(){
		selectedView = '0';
		listCategoriesOrProducts = new List<List<CategoryWrapper>>();
		fetchProductsData();
	}
	
	//get view picklist options
	public List<SelectOption> getViewOptions(){
		List<SelectOption> lstOption = new List<SelectOption>();
		lstOption.add(new SelectOption('0','Products with no assigment'));
		lstOption.add(new SelectOption('1','Products having an assignment'));
		lstOption.add(new SelectOption('2','Associated Products'));		
		
		return lstOption;
	}
	
	//fetching prdoducts to show on left panel of the page
	public void fetchProductsData(){
		
		listCategoriesOrProducts.clear();
		if(selectedView != '2') {
			List<CategoryWrapper> tempProducts = new List<CategoryWrapper>();
			String query = 'Select name, Part_Number__c, Description, Support_Product__c from Product2 where isActive = true';
			query += selectedView == '0' ? ' and Support_Product__c = null' : ' and Support_Product__c != null';
			if(!String.isEmpty(searchString)){
				query += ' and Part_Number__c like \'%' + searchString + '%\'';
			}
			query += ' limit 500';
			for(Product2 product : Database.query(query)){
				tempProducts.add(new CategoryWrapper(product));
				if(tempProducts.size() > 999){
					listCategoriesOrProducts.add(tempProducts);
					tempProducts = new List<CategoryWrapper>();
				}
			}
			listCategoriesOrProducts.add(tempProducts);
		}
	}
	
	//fetching Associated Product relsted to selected Support_Product__c
	public void fetchAssociatedProduct(){
		listCategoriesOrProducts.clear();
		List<CategoryWrapper> tempProducts = new List<CategoryWrapper>();
		String query = 'Select name, Part_Number__c, Description, Support_Product__c from Product2 where isActive = true';
		query += ' and Support_Product__c = :selectedObjId';
		query += ' limit 500';
		for(Product2 product : Database.query(query)){
			tempProducts.add(new CategoryWrapper(product));
			if(tempProducts.size() > 999){
				listCategoriesOrProducts.add(tempProducts);
				tempProducts = new List<CategoryWrapper>();
			}
		}
		listCategoriesOrProducts.add(tempProducts);
	}
	//filtering products according to search criteria
	public Pagereference filterProducts(){
		fetchProductsData();
		return null;
	}
	
	//updating products
	public Pagereference save(){
		if(String.isEmpty(selectedObjId)){
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Product Category must be selected.');
        	ApexPages.addMessage(myMsg);
        	return null;
		}else{
			List<Product2> categoriesToUpdate = new List<Product2>();
			for(List<CategoryWrapper> upperWrapper : listCategoriesOrProducts){
				for(CategoryWrapper wrapper : upperWrapper){
					if(wrapper.isSelected){
						categoriesToUpdate.add(new Product2(id = wrapper.obj.id, Support_Product__c = selectedObjId));
					}
				}
			}
			update categoriesToUpdate;
			fetchProductsData();
			return null;
		}
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