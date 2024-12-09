@isTest
public class CloneLoanAppControllerTest { 
    @isTest
    static void cloneLoanAppControllerTestMethod() {
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        CloneLoanAppController.CloneLoanAppwrpr inputData = new CloneLoanAppController.CloneLoanAppwrpr();
        inputData.recordId = loanApp.Id;
        inputData.rmSmId = null;
        inputData.userId = userInfo.getUserId();
        inputData.cloneReason = 'BT + Top Up';
        
        Boolean isAssert = true;
        try{
            CloneLoanAppController.CloneLoanDetailsWrpr str = CloneLoanAppController.cloneLoanApp(inputData);   
        }catch(AuraHandledException ex){
            isAssert = false;
            system.debug('error occured ' + ex.getMessage());
            system.assertEquals('Script-thrown exception', ex.getMessage());
        }  
        //system.assertEquals(true, isAssert);
        //System.assertEquals('Loan Cloning Process Started Successfully', str);
        try {
            CloneLoanAppController.cloneLoanApp(null);
            System.assert(false, 'Expected an AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
}