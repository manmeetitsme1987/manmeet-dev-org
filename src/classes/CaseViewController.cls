/*
Class : CaseViewController 
Description :  This class is used for showing knowledge Side bar
Developed by : Manmeet Manethiya
Created Date : Aug 27, 2013
*/
public without sharing class CaseViewController {
    public Case caseObj {get;set;}
    public List<ArticleWrapper> listArticleCategories {get; set;} 
    
    Set<String> setSelectedArticles;
    public CaseViewController(ApexPages.StandardController controller){
        caseObj = (Case)controller.getRecord();
        fetchCaseArticles();
        fetchKnowledgeArticles();
    }
    
    public void fetchKnowledgeArticles(){
        listArticleCategories = new List<ArticleWrapper>();
        boolean isConditionAdded = false, isOROperatorNeeded = false;
        String query = 'select Knowledge_Article_URL__c, Article_Title__c, Article_Id__c, Problem_Category__c, Support_Product__c, Solution_Category__c '+
                        ' from Article_category__C where ';
        if(caseObj.problem_category__c != null){
            String problemCatId = caseObj.problem_category__c;
            query += 'Problem_Category__c = : problemCatId ';
            isConditionAdded = true;
            isOROperatorNeeded = true;
        }
        if(caseObj.asset.Support_Product__c != null){
            if(isOROperatorNeeded){
                query += ' or ';
                isOROperatorNeeded = false;
            }
            String productCatId = caseObj.asset.Support_Product__c;
            query += 'Support_Product__c = : productCatId ';
            isConditionAdded = true;
            
        }
        if(isConditionAdded){
            query += 'Limit 500';
            for(Article_category__C category : Database.query(query)){
                if(setSelectedArticles.contains(category.Article_Id__c)){
                    listArticleCategories.add(new ArticleWrapper(category, true));  
                }else{
                    listArticleCategories.add(new ArticleWrapper(category, false));
                }
                                            
            }
        }
        
    }
    
    public void fetchCaseArticles(){
        setSelectedArticles = new Set<String>();
        for(Case cs : [Select problem_category__c, solution_category__C, asset.Support_Product__c,
                    (Select Id, CaseId, KnowledgeArticleId, CreatedById, CreatedDate, SystemModstamp, IsDeleted, ArticleLanguage From CaseArticles) 
                    from Case where id = : caseObj.id]){
            caseObj = cs;
            for(CaseArticle cArticle : cs.CaseArticles){
                setSelectedArticles.add(cArticle.KnowledgeArticleId);   
            }
        }
    }
    
    public Pagereference attachCase(){ 
        List<CaseArticle> articleList = new List<CaseArticle>();
        for(ArticleWrapper wrapper : listArticleCategories){
            if(wrapper.isSelected){
                articleList.add(new CaseArticle(KnowledgeArticleId = wrapper.article.Article_Id__c, caseId = caseObj.Id));  
            }
        }
        if(articleList.size() > 0){
            insert articleList;
        }
        DateTime testDate = System.Now() + 7;
        fetchCaseArticles();
        fetchKnowledgeArticles();
        return null;
    }
    
    class ArticleWrapper{
        public Article_category__C article {get;set;}
        public boolean isSelected {get;set;}
        public boolean isAlreadyPresent {get;set;}
        public ArticleWrapper(Article_category__C article, boolean isAlreadyPresent){
            this.article = article;
            this.isSelected = false;
            this.isAlreadyPresent = isAlreadyPresent;
        }
    }
}