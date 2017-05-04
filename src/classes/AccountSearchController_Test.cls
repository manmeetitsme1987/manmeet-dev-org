@isTest
private class AccountSearchController_Test {
	
    static testMethod void myTest() {
        AccountSearchController ctrl = new AccountSearchController();
        
        List<Account> result = AccountSearchController.searchAccounts('',10);
        System.assert(result != null);
        
        Integer countAcc = AccountSearchController.getTotalAccounts('');
        System.assert(result != null);
     }
}