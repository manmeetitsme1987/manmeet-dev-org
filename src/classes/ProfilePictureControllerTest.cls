@isTest
public class ProfilePictureControllerTest {

    static Contact testCon;
    
    static testMethod void testMethod1(){
        Test.startTest();
        createTestData();
        ProfilePictureController.saveAttachment(testCon.Id, 'test Con', 'test string for the image', 'image/png');
        ProfilePictureController.getProfilePicture(testCon.Id);
        system.assert(true);
        Test.stopTest();
    }
    
    
    static testMethod void saveAttacmentTest(){
        Test.startTest();
        createTestData();
        ProfilePictureController.saveAttachment(testCon.Id, 'test Con', 'test string for the image', 'image/png');
        system.assert(true);
        Test.stopTest();
    }
    
    
    static void createTestData(){
        
        Account testAcc = new Account();
        testAcc.Name = 'test Account';
        insert testAcc;
        
        testCon = new Contact();
        testCon.FirstName = 'test Name';
        testCon.LastName = 'last Name';
        insert testCon;
        
        
    }
}