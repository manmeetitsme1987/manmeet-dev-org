public class AccountSearchController {
    
	@AuraEnabled
    public static List<Account> searchAccounts(String accName, Integer resLimit) {
        List<Account> accList = new List<Account>();
        String queryStr = 'SELECT ID, Name, BillingState, Phone FROM Account';
        if(accName != null) {
            queryStr += ' WHERE Name LIKE \'%' + accName + '%\'';
        }
        queryStr += ' Limit ' + resLimit;
        accList = (List<Account>)Database.query(queryStr);
        return accList;                
    }
    
    @AuraEnabled
    public static Integer getTotalAccounts(String accName) {
        List<Account> accList = new List<Account>();
        String tempVar = '%' + accName + '%';
        Integer totalAccs = 0;
        if(accName != null) {
           totalAccs = [Select Count() From Account Where Name Like : tempVar];
        }
        else{
           totalAccs = [Select Count() From Account]; 
        }
        return totalAccs;
    }
}