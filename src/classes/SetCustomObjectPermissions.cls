public without sharing class SetCustomObjectPermissions {
	public List<Profile> profileList {get; set;}
	
	//fetching custom objects from org
	public String selecteObject {get;set;}
	public List<SelectOption> getObjectNames(){
		List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();    
		List<SelectOption> options = new List<SelectOption>();
		for(Schema.SObjectType f : gd){
			if(f.getDescribe().getName().contains('__c')){
				options.add(new SelectOption(f.getDescribe().getLabel(),f.getDescribe().getLabel()));
			}
		}
		return options;
	}
	
	
	public SetCustomObjectPermissions(){
		profileList = new List<Profile>();
		for(Profile pf : [Select id, name from Profile]){
			profileList.add(pf);
		}
	}

}