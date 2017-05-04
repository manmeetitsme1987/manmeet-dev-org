/***********************************************************************
Class Name      : ArticleAssociation_v3Controller
Created By      : Appirio (Manmeet Manethiya)
Created Date    : 31st August,2013
************************************************************************/
public with sharing class ArticleAssociation_v3Controller {
    public String articleTypeAssociated {get;set;}
    public String searchTextAssociated {get;set;}
    public List<SelectOption> articleTypes {get;set;}
    
    public map<String,String> articleTypesLabels{get;set;}
    public boolean forProductTreeView{get;set;}
    public boolean forTreeView{get;set;}
    public String selectedTreeView {get;set;}
    public String selectedProductIds {get;set;}
    public String selectedProblemIds {get;set;}
    //public String selectedProduct2Ids {get;set;}
    public String selectedKnowledgeArticleId {get;set;}
    public String selectedKnowledgeArticleTitle {get;set;}
    public String selectedField {get;set;}
    public String selectedLanguage {get;set;}
    public boolean isLangauge {get;set;}
    public String selectedArticleIndex {get;set;}
    public String selectedArticleVersionId {get;set;}
    public List<product2Wrapper> product2ListForDisplay{get;set;}
    public Boolean isShowMsg {get;set;}
    public String selectedStatus {get; set;}
    
    //public map<id,KnowledgeArticleVersion> mapOfIdAndKnowledgeVersion;
    private map<String,List<Article_Category__c>> mapOfArticalCategory;
    Set<String> alreadySelectedProductIds;
    Set<String> alreadySelectedProblemIds;
    Set<String> alreadySelectedProduct2Ids;
    set <String> supportProductNames;
    private Integer listTotalSize;
    private boolean isForSearch;
    
    
    
    public List<SelectOption> getLanguages(){
      List<SelectOption> options = new List<SelectOption>();
      Schema.DescribeFieldResult fieldResult = KnowledgeArticleVersion.Language.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getValue(), f.getLabel()));    
       }       
       return options;
    }
    
    
    public List<SelectOption> getArticleStatus(){
      List<SelectOption> options = new List<SelectOption>();
      options.add(new SelectOption('Draft', 'Draft'));
      options.add(new SelectOption('Online', 'Online'));
      options.add(new SelectOption('Archived', 'Archived'));
      return options;
    }
   
    public ArticleAssociation_v3Controller() {
        pageSize = Integer.valueOf(Label.Default_Page_Size); 
        selectedReocrdSizeInPage = pageSize+'';
        selectedField = 'Title';
        forTreeView = false;
        isForSearch = false;
        totalPageNumber = 0;
        gotoPage=1;
        this.articleTypes = new List<SelectOption>();
        this.articleTypesLabels = new Map<String,String>();
        //get articles types
        system.debug('before getArticle Types');
        this.articleTypesLabels = getArticleTypes();
        product2ListForDisplay = new List<product2Wrapper> ();
        //sorting article types alphanumeric
        List<String> aTypes = new List<String>();
        for(String str : this.articleTypesLabels.keySet()){
            aTypes.add(str);
        }
        aTypes.sort();
        this.articleTypes.add(new SelectOption('All','All'));

        for(String artType : aTypes) {
            String ArtTypeName = (this.articleTypesLabels.get(artType)).replaceAll(' ','_') + '__kav';
            this.articleTypes.add(new SelectOption(ArtTypeName,this.articleTypesLabels.get(artType)));
        }
        articleTypeAssociated = 'Document__kav';
        listOfWrapperArticle = new list<wrapperArticle>();
        selectedStatus = 'Draft';
        getListOfAssociatedArticle(1);
    }
    
    /*
     *  Returns articles Types/API Names
     */
    public static Map<String,String> getArticleTypes() {
        Map<String,Schema.SOBjectType> objs = Schema.getGlobalDescribe();
        Map<String,String> result = new Map<String,String>();
        for(String objName : objs.keySet()){
            Schema.Describesobjectresult dsor = objs.get(objName).getDescribe();
            System.assert(dsor !=null,objName+ 'is not a valid Sobject type');          
            if(objName.endsWith('__kav'))result.put(objName,dsor.getLabel());
        }
        return result;
    }
    
    
    
    /*
    *   Returns list of Article that is associated with any product and problem category
  */
    public PageReference getListOfAssociatedArticle(Integer newPageIndex){
          try{
              listOfWrapperArticle = new list<wrapperArticle>();
              mapOfArticalCategory = new  map<String,List<Article_Category__c>>();
              Set<String> setofArticleId = new Set<String>();
              List<String> tempListToSortArticles = new List<String>();
              Map<String, KnowledgeArticleVersion> mapOverallArticleVersions = new Map<String, KnowledgeArticleVersion>();
              String articleQuery = 'Select Id, ArticleNumber From KnowledgeArticle';
              for(KnowledgeArticle article : Database.query(articleQuery)){
                    setofArticleId.add(article.id);
              }
              
              String query = 'Select id, Title, PublishStatus,VersionNumber,CreatedById, KnowledgeArticleId, ArticleType, ArticleNumber,Language'+
                            ' From KnowledgeArticleVersion where KnowledgeArticleId in : setofArticleId and PublishStatus = : selectedStatus and IsLatestVersion = true ';
              if(isForSearch){
                if(!String.isEmpty(searchTextAssociated)){
                    if(selectedField != 'Language'){
                        query += ' and '+selectedField+' like \'%'+searchTextAssociated+'%\'';
                    }
                }
                if(selectedField == 'Language'){
                    query += ' and '+selectedField+' = \''+selectedLanguage+'\'';
                }
              }else{
                if(articleTypeAssociated != 'All'){
                    query += ' and ArticleType =: articleTypeAssociated';
                }
              }
              Integer index = 0;
              for(KnowledgeArticleVersion sobj : Database.query(query)){
                tempListToSortArticles.add(sobj.Title + index);
                mapOverallArticleVersions.put(sobj.Title + index, sobj);
                index++;
              }
               
              tempListToSortArticles.sort();
              List<String> pageListArticles = new List<String>();
              Set<String> pageArticleIds = new Set<String>();
                //taking transient variables for maintaining counter withing a page and controller
                Transient Integer counter = 0;
                Transient Integer min = 0;
                Transient Integer max = 0;
                //if newPageIndex > number of pages then settting minimum value as pagenumber * pagesize
                //if newPageIndex > number of pages then settting maximum value as newPageIndex * pagesize
                if (newPageIndex > pageNumber){
                    max = newPageIndex * pageSize;
                    min = max - pageSize;
                }
                else{
                    max = newPageIndex * pageSize;
                    min = max - pageSize;
                }
                
                for(String article : tempListToSortArticles){
                    counter++;
                    if (counter > min && counter <= max){
                        pageListArticles.add(article);
                        pageArticleIds.add(mapOverallArticleVersions.get(article).KnowledgeArticleId);
                    }
                }
                if(pageListArticles.size()!=0){
                    pageNumber = newPageIndex;  
                }
                else
                {
                    pageNumber=0; 
                }
              
              Integer countRecord = 1;  
              for(Article_Category__c ac : [Select Article_Id__c, Support_Product__c, Problem_Category__c, Problem_Category__r.Name , 
                                            Support_Product__r.Name,Product2__r.Part_Number__c
                                            FROM Article_Category__c Where Article_Id__c != null and Article_Id__c in : pageArticleIds]) {
                  if(!mapOfArticalCategory.containsKey(ac.Article_Id__c)) {
                    mapOfArticalCategory.put(ac.Article_Id__c, new List<Article_Category__c>());
                  }
                  mapOfArticalCategory.get(ac.Article_Id__c).add(ac);
                  countRecord++;
              }
              for(String articleTitle : pageListArticles){
                wrapperArticle obj = new wrapperArticle(mapOverallArticleVersions.get(articleTitle));
                obj.problemCategories = '';
                obj.productCategories = '';
                obj.problemCategoriesIDs = '';
                obj.productCategoriesIDs = '';
                obj.alreadySelectedProductIds = new Set<String>();
                obj.alreadySelectedProblemIds = new Set<String>();
                obj.alreadySelectedProduct2Ids = new Set<String>();
                obj.supportProductNames = new Set<String>();
                //Added by Abhishek--start
                obj.products = '';
                //Added by Abhishek--end
                if(mapOfArticalCategory.containskey(obj.knowledgeArticleVersion.KnowledgeArticleId)){
                    for(Article_Category__c categry : mapOfArticalCategory.get(obj.knowledgeArticleVersion.KnowledgeArticleId)){
                        if(categry.Support_Product__c != null && categry.Support_Product__r.Name != '' 
                                                               && categry.Support_Product__r.Name != null) {
                            
                            obj.productCategories += categry.Support_Product__r.Name + ', ';
                            obj.productCategoriesIDs += categry.Support_Product__c + ',';
                            obj.alreadySelectedProductIds.add(categry.Support_Product__c);
                            obj.supportProductNames.add(categry.Support_Product__r.Name);
                        }
                      if(categry.Problem_Category__c != null && categry.Problem_Category__r.Name != '' 
                                                               && categry.Problem_Category__r.Name != null) {
                            
                            obj.problemCategories += categry.Problem_Category__r.Name + ', ' ;
                            obj.problemCategoriesIDs +=  categry.Problem_Category__c + ',' ;
                            obj.alreadySelectedProblemIds.add(categry.Problem_Category__c);
                        }
                     if(categry.Product2__c != null && categry.Product2__r.Part_Number__c != '' && 
                        categry.Product2__r.Part_Number__c != null) {
                          obj.products += categry.Product2__r.Part_Number__c + ', ';    
                          obj.alreadySelectedProduct2Ids.add(categry.Product2__c);
                        }
                     }
                     
                     if(obj.problemCategories != ''){
                        obj.problemCategories = obj.problemCategories.subString(0 , obj.problemCategories.length() - 2);
                        obj.problemCategoriesIDs = obj.problemCategoriesIDs.subString(0 , obj.problemCategoriesIDs.length() - 1);
                     }else{
                        obj.problemCategories = 'None';
                     }
                     if(obj.productCategories != ''){
                        obj.productCategories = obj.productCategories.subString(0 , obj.productCategories.length() - 2);
                        obj.productCategoriesIDs = obj.productCategoriesIDs.subString(0 , obj.productCategoriesIDs.length() - 1);
                     }else{
                        obj.productCategories = 'None';
                     }
                     
                     if(obj.products != ''){
                        obj.products = obj.products.subString(0 , obj.products.length() - 2);
                     }else{
                        obj.products = 'None';
                     }           
                }else{
                    obj.problemCategories = 'None';
                    obj.productCategories = 'None';
                    obj.products = 'None';
                }
                listOfWrapperArticle.add(obj);
              }
              mapOfArticalCategory = null;
              listTotalSize = tempListToSortArticles.size();
          }catch(Exception ex){
            system.assert(false, ex);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getMessage()));
        }
     return null;
    }
    
    private void deleteAllCateories() {
        String query = 'Select ID FROM Article_Category__c Where Article_Id__c =:selectedKnowledgeArticleId';
        Set<String> sIds = new Set<String>();
        if(selectedTreeView == 'Product'){
            query += ' and Support_Product__c in : alreadySelectedProductIds';
        }else if(selectedTreeView == 'Problem'){
            query += ' and Problem_category__c in : alreadySelectedProblemIds';
        }else {
            query += ' and Product2__c in : alreadySelectedProduct2Ids';
        }
        Database.delete(Database.query(query));
        
    }
    
 /*
    *   This method create associate category records for selected article.
    */
    
    public PageReference createArticle() {
        Savepoint sp;
        try{
            deleteAllCateories();
            if(!String.isEmpty(selectedKnowledgeArticleId)){
            	selectedKnowledgeArticleTitle = selectedKnowledgeArticleTitle.replaceAll('~', '\'');
                List<Article_Category__c> listArticleCategoriesToInsert = new List<Article_Category__c>();
                if(selectedTreeView == 'Product'){
                    if(!String.isEmpty(selectedProductIds)){
                        List<String> splittedIds = selectedProductIds.split(',');
                        for(String pId : splittedIds){
                            listArticleCategoriesToInsert.add( new Article_Category__c(Article_Id__c = selectedKnowledgeArticleId, 
                                                        Article_Title__c = selectedKnowledgeArticleTitle.length() > 100 ? selectedKnowledgeArticleTitle.subString(0, 98) : selectedKnowledgeArticleTitle, 
                                                        Support_Product__c = pId.trim(),
                                                        Article_Version_id__c = selectedArticleVersionId));
                        }
                    }
                    
                }else if(selectedTreeView == 'Problem'){
                    if(!String.isEmpty(selectedProblemIds)){
                        List<String> splittedIds = selectedProblemIds.split(',');
                        for(String pId : splittedIds){
                            listArticleCategoriesToInsert.add( new Article_Category__c(Article_Id__c = selectedKnowledgeArticleId, 
                                                        Article_Title__c = selectedKnowledgeArticleTitle.length() > 100 ? selectedKnowledgeArticleTitle.subString(0, 98) : selectedKnowledgeArticleTitle, 
                                                        Problem_Category__c = pId.trim(),
                                                        Article_Version_id__c = selectedArticleVersionId));
                        }
                    }
                }
                if(listArticleCategoriesToInsert.size() > 0){
                    insert listArticleCategoriesToInsert;
                }
            }
            getListOfAssociatedArticle(pageNumber);
            forTreeView = false;
            return null;
        }
        catch(Exception ex){
              if(sp != null) {
             Database.rollback(sp);
              }
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
        }
    }
    
    private void fetchExistingCategories(){
        if(!String.isEmpty(selectedArticleIndex)){
            wrapperArticle obj = listOfWrapperArticle.get(Integer.valueOf(selectedArticleIndex));
            if(selectedTreeView == 'Product'){
                alreadySelectedProductIds = new Set<String>();
                selectedProductIds = obj.productCategoriesIDs;
                alreadySelectedProductIds = obj.alreadySelectedProductIds;
            }else if(selectedTreeView == 'Problem'){
                alreadySelectedProblemIds = new Set<String>();
                selectedProblemIds = obj.problemCategoriesIDs;
                alreadySelectedProblemIds = obj.alreadySelectedProblemIds;
            }else{
                alreadySelectedProduct2Ids = new Set<String>();
                alreadySelectedProduct2Ids = obj.alreadySelectedProduct2Ids;
                prepareProduct2WrapperForDisplay(obj.supportProductNames,alreadySelectedProduct2Ids);
            }
        }
     }
    
   public void prepareProduct2WrapperForDisplay(Set <String> supportProductNames,  Set <String> alreadySelectedProduct2Ids){
    isShowMsg = false;
        product2ListForDisplay = new List<product2Wrapper>();
        Integer recordCount = 0 ;
        for(Product2 prod2 : [Select Id,Name,Part_Number__c from Product2 where Marketing_Parent__c IN : supportProductNames order by CreatedDate desc]){
            if(recordCount < 999){
                if(alreadySelectedProduct2Ids.contains(prod2.Id)){
                    product2ListForDisplay.add( new product2Wrapper(prod2,true) );
                }else{
                    product2ListForDisplay.add( new product2Wrapper(prod2,false) );
                }
                recordCount++;
            }else{
                 isShowMsg = true;          
                break;
            }
        }
    }
    
    public PageReference createArticleCategoryForProduct2(){
        Set<String> selectedProduct2Ids = new Set<String>();
        for(product2Wrapper prod2Obj: product2ListForDisplay) {
            if(prod2Obj.selected == true) {
                selectedProduct2Ids.add(prod2Obj.prod2.Id);
            }
        }
        Savepoint sp;
        try{
            deleteAllCateories();
            if(!String.isEmpty(selectedKnowledgeArticleId)){
                List<Article_Category__c> listArticleCategoriesToInsert = new List<Article_Category__c>();
                if(!selectedProduct2Ids.isEmpty()){
                	selectedKnowledgeArticleTitle = selectedKnowledgeArticleTitle.replaceAll('~', '\'');
                    for(String pId : selectedProduct2Ids){
                            listArticleCategoriesToInsert.add( new Article_Category__c(Article_Id__c = selectedKnowledgeArticleId, 
                                                        Article_Title__c = selectedKnowledgeArticleTitle.length() > 100 ? selectedKnowledgeArticleTitle.subString(0, 98) : selectedKnowledgeArticleTitle, 
                                                        Product2__c = pId.trim(),
                                                        Article_Version_id__c = selectedArticleVersionId));
                        }
                    
                }
                if(listArticleCategoriesToInsert.size() > 0){
                    insert listArticleCategoriesToInsert;
                }
            }
            getListOfAssociatedArticle(pageNumber);
            return null;
        }
        catch(Exception ex){
              if(sp != null) { 
                Database.rollback(sp);
              }
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
        }
    
    }
     
     public Pagereference openTreeViewAction(){
        if(selectedTreeView == 'Product'){
            forProductTreeView = true;
            forTreeView = true;
        }else{
            forProductTreeView = false;
            forTreeView = true;
        }
        fetchExistingCategories();
        return null;
     }
     
     
     
     public Pagereference openProduct2List(){
        forProductTreeView = false;
        forTreeView = false;
        fetchExistingCategories();
        return null;
     }
    
 /*
    *   This method fetch the associated article list
    */
    public Pagereference fetListOfArticlesAssociated(){
        isForSearch = false;
        fetchData();
        return null;
    }
    
    public void fetchData(){
        pageSize = Integer.valueOf(selectedReocrdSizeInPage);
        totalPageNumber = 0;
        gotoPage=1;
        getListOfAssociatedArticle(1);
    }
    
    public Pagereference fetListOfArticlesAssociatedForSearch(){
        isForSearch = true;
        fetchData();
        return null;
    }
    
    public Pagereference checkForLanguageAction(){
        if(selectedField == 'Language'){
            isLangauge = true;
        }else{
            isLangauge = false;
        }
        return null;
    }
    
 /*
    *   This class is used for wrap the problem and product category for Article.
    */
    class wrapperArticle {
        public KnowledgeArticleVersion knowledgeArticleVersion{get;set;}
        public String problemCategories{get;set;}
        public String productCategories{get;set;}
        public String problemCategoriesIDs{get;set;}
        public String productCategoriesIDs{get;set;}
        public Set<String> alreadySelectedProductIds{get;set;}
        public Set<String> alreadySelectedProblemIds{get;set;}
        public Set<String> alreadySelectedProduct2Ids{get;set;}
        public Set<String> supportProductNames {get;set;}
        public String knowledgeArticleTitle {get;set;}
        //Added by Abhishek--start
        public String products{get;set;}
        //Added by Abhishek--end
        public boolean isSelected{get;set;}
        public wrapperArticle(KnowledgeArticleVersion knowledgeArticleVersion){
        	if(knowledgeArticleVersion.Title != null){
        		this.knowledgeArticleTitle = knowledgeArticleVersion.Title.replaceAll('\'', '~');
        	}
        	this.knowledgeArticleVersion = knowledgeArticleVersion;
            isSelected = false;
        }
    }
    
    class product2Wrapper{
        public Product2 prod2 {get; set;}
        public Boolean selected {get; set;}
        
        public product2Wrapper(Product2 prodct2 , Boolean selectedVal) {
            prod2 = prodct2;
            selected = selectedVal;
        }
    }
    
    /***************************************************HELPER FUNCTIONS*******************************************************************/
    
    public Integer gotoPage{get;set;}
    public String selectedReocrdSizeInPage{get;set;} {selectedReocrdSizeInPage = '10';}
    private Integer pageNumber;
    private Integer pageSize;
    private Integer totalPageNumber;
    public List<wrapperArticle> listOfWrapperArticle {get; set;}
    //private List<wrapperArticle> pageListOfWrapperArticle ;
    
    //getter and setter for properties
        public Integer getPageNumber(){
            return pageNumber;
        }
        public List<wrapperArticle> getListOfWrapperArticle(){
            return listOfWrapperArticle;
        }
        public Integer getPageSize(){
            return pageSize;
        }
        public Boolean getPreviousButtonEnabled(){
            return !(pageNumber > 1);
        }
        public Boolean getNextButtonDisabled(){
            if (listOfWrapperArticle == null){
                 return true;
            }else{
                return ((pageNumber * pageSize) >= listTotalSize);
            }
        }
        public Boolean getLastButtonEnabled(){
            return (totalPageNumber==0||pageNumber == totalPageNumber);
        }
        public Boolean getFirstButtonEnabled(){
            return (pageNumber == 1 ||pageNumber == 0);
        }
        public Integer getTotalPageNumber(){
            if (totalPageNumber == 0 && listTotalSize > 0){
                totalPageNumber = listTotalSize / pageSize;
                Integer mod = listTotalSize - (totalPageNumber * pageSize);
                if (mod > 0)
                    totalPageNumber++;
            }
            return totalPageNumber;
        }
    
    // function called for next button
    public PageReference nextBtnClick() {
        getListOfAssociatedArticle(pageNumber + 1);
        return null;
    }
    
    // function called for previous button
    public PageReference previousBtnClick() {
        getListOfAssociatedArticle(pageNumber - 1);
        return null;
    }
    
    public PageReference jumpBtnClick() {
        if(gotoPage<=totalPageNumber&& gotoPage>0){
                getListOfAssociatedArticle(gotoPage);
        }else{
            gotoPage=pageNumber;
        }
      return null;
    }
    
    public PageReference lastPageBtnClick() {
            getListOfAssociatedArticle(totalPageNumber);        
        return null;
    }
    
    public PageReference firstPageBtnClick() { 
        getListOfAssociatedArticle(1);      
        return null;
    }
    //function called when number of record per page request changes
    public Pagereference renderNewRecords(){
        pageSize = Integer.valueOf(selectedReocrdSizeInPage);
        totalPageNumber = 0;
        getListOfAssociatedArticle(1);
        return null;
    }
    
    //builds a picklist for number of records in a page
    /*
    public List<selectOption> getNumberOfRecordsInPage() {
        List<selectOption> options = new List<selectOption>(); //new list for holding date picklist options
        options.add(new selectOption('10', '10'));
        options.add(new selectOption('25', '25'));
        options.add(new selectOption('50', '50'));
        //options.add(new selectOption('75', '75'));
        //options.add(new selectOption('100', '100'));
        return options; //return the picklist options
    }
    */
}