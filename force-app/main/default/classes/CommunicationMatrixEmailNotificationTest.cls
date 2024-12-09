@isTest
public class CommunicationMatrixEmailNotificationTest {

@testsetup
    Public static void insertData(){
        string userId = UserInfo.getUserId();
        EmailTemplate testTemplate = new EmailTemplate();
        testTemplate.DeveloperName = 'test_template';
        testTemplate.Name = 'Test Template';
        testTemplate.Subject = 'Test Subject';
        testTemplate.Body = 'Test Body';
        testTemplate.IsActive = true;
        testTemplate.FolderId = userId;
        testTemplate.TemplateType = 'text';
        insert testTemplate;
    }
    
    @isTest
    Public static void testSendEmailCommunication_UserRecipient(){
        EmailTemplate emTem = [SELECT ID,Name,Subject,Body,IsActive,DeveloperName FROM EmailTemplate WHERE Name = 'Test Template' Limit 1];
        User u = TestDataFactory.UserData(true);
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        
        CommunicationMatrixEmailNotification.inputVariables testInput = new CommunicationMatrixEmailNotification.inputVariables();
        testInput.emailTemplateId = emTem.Id;
        testInput.loanApplicationID = loan.Id;
        testInput.emailAddress = new List<String>{ u.Email };
        testInput.userId = new List<String>{ u.Id };
        testInput.ccemailAddress = new List<String> {u.Email};
        testInput.typeOfRecipient = 'user';
        Test.startTest();
        CommunicationMatrixEmailNotification.sendEmailCommunication(new List<CommunicationMatrixEmailNotification.inputVariables>{ testInput });
        Test.stopTest();
      
    }
    
    @isTest 
     Public static void testSendEmailCommunication_UserRecipient1(){
        EmailTemplate emTem = [SELECT ID,Name,Subject,Body,IsActive,DeveloperName FROM EmailTemplate WHERE Name = 'Test Template' Limit 1];
        User u = TestDataFactory.UserData(true);
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        CommunicationMatrixEmailNotification.inputVariables testInput = new CommunicationMatrixEmailNotification.inputVariables();
        testInput.emailTemplateId = emTem.Id;
        testInput.loanApplicationID = loan.Id;
        testInput.emailAddress = new List<String>{ u.Email };
        testInput.userId = new List<String>{ u.Id };
        testInput.typeOfRecipient = 'Applicant';
        testInput.ccemailAddress = new List<String> {u.Email};
        Test.startTest();
         try{
        CommunicationMatrixEmailNotification.sendEmailCommunication(new List<CommunicationMatrixEmailNotification.inputVariables>{ testInput });
         }catch(Exception e){
             
         }
        Test.stopTest(); 
     }
}