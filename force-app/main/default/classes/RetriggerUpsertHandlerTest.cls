@isTest
private class RetriggerUpsertHandlerTest {
    
    @testsetup
    Public static void insertData(){
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true); 
        loanApp.Stage__c = 'QDE';
        loanApp.SubStage__c = 'Additional Data Entry';
        TriggerBase.bypass('LoanAppl__c');
        Update loanApp;
        TriggerBase.clearBypass('LoanAppl__c');
        
        Applicant__c applicant = TestDataFactory.createSingleApplicant(true, loanApp.Id);
        BankBrchMstr__c  bankBranchMaster = TestDataFactory.TestDataBankBranchMaster(True);
        
        TeamHierarchy__c teamHir =  TestDataFactory.TestDataTeamHierarchy_nonSup(True,UserInfo.getUserId(),bankBranchMaster.Id);
        List<LoanTAT__c> tatList = new List<LoanTAT__c>();
        
        tatList.add(new LoanTAT__c(
            LoanApplication__c = loanApp.id,
            Stage__c = 'QDE',
            Sub_Stage__c = 'RM Data Entry'
        )); 
        tatList.add(new LoanTAT__c(
            LoanApplication__c = loanApp.id,
            Stage__c = 'QDE',
            Sub_Stage__c = 'Additional Data Entry'         
        )); 
        tatList.add(new LoanTAT__c(
            LoanApplication__c = loanApp.id,
            Stage__c = 'UnderWriting',
            Sub_Stage__c = 'Credit Appraisal'
            
        ));
        TriggerBase.bypass('LoanTAT__c');
        insert tatList;
        TriggerBase.clearBypass('LoanTAT__c');  
    }
    
    @isTest
    Public static void testMethod1(){
        List<LoanAppl__c> lstNewList = [SELECT ID,Name,Stage__c FROM LoanAppl__c LIMIT 1];
        system.debug('lstNewList:'+lstNewList);
        // List<LoanAppl__c> lstOldList = [SELECT ID,Name,Stage__c FROM LoanAppl__c WHERE Stage__c = 'DDE']; 
        // 
        List<Applicant__c> appOldList = [SELECT Id,FName__c,LoanAppln__c,AadhaarNo__c,CompanyName__c,DOB__c,DLNo__c,Gender__c,LName__c,MobNumber__c,PAN__c,PassNo__c,VotIdEpicNo__c,Type_of_Borrower__c
                                         FROM Applicant__c where LoanAppln__c=:lstNewList[0].Id];
        List<Applicant__c> appNewList = new List<Applicant__c>();
        Applicant__c appOld = new Applicant__c();
        appOld.Id = appOldList[0].Id;
        appOld.FName__c = 'added';
        appOld.AadhaarNo__c = '234343455656';
        appOld.LoanAppln__c = lstNewList[0].Id;
        appNewList.add(appOld);
        TriggerBase.bypass('Applicant__c');
        update appNewList;
        TriggerBase.clearBypass('Applicant__c');
        
        RetriggerUpsertHandler.InputData testData = new RetriggerUpsertHandler.InputData();
        testData.newList = appNewList;
        testData.oldList =appOldList;
        testData.modificationType = 'Update'; 
        testData.objectApiName = 'Applicant__c';
        testData.loanFieldAPIName = 'LoanAppln__c';
        testData.applFieldAPIName = 'Id'; 
        RetriggerUpsertHandler.createRetriggerRecords(testData);     
    }
}