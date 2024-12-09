@isTest
public class UpdateRCUStatusAfterRCUManagerTest {
    @isTest
    public static void testUpdateStatus(){
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Account testAccount1 = new Account(Name = 'Test Account');
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        testAccount1.RecordTypeId = recordTypeId;
        insert testAccount1;
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' LIMIT 1].Id,
            IsActive__c = true
        );
        insert testContact;
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        LoanAppl__c loanApp1 = TestDataFactory.createLoanApplication(true);
        Applicant__c appli = TestDataFactory.createSingleApplicant(true,loanApp.Id);
        Id recordTypeId1 = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RCU').getRecordTypeId();
        DocMstr__c docMstr = TestDataFactory.createDocumentMaster(true, 'Master document');
        
        DocDtl__c docDtl = TestDataFactory.createDocDtl(true,appli.Id,docMstr.Id,loanApp.Id, 'Pending');
        DocDtl__c docDtl1 = TestDataFactory.createDocDtl(true,appli.Id,docMstr.Id,loanApp.Id, 'Refer');
        DocDtl__c docDtl2 = TestDataFactory.createDocDtl(true,appli.Id,docMstr.Id,loanApp.Id, 'Negative');
        DocDtl__c docDtl3 = TestDataFactory.createDocDtl(true,appli.Id,docMstr.Id,loanApp.Id, 'Positive');
        
        ApplAddr__c applAdd = TestDataFactory.createApplAddr(true,appli.Id,loanApp.Id, 'Fraud');
        ApplAddr__c applAdd1 = TestDataFactory.createApplAddr(true,appli.Id,loanApp.Id, 'Pending');
        ApplAddr__c applAdd2 = TestDataFactory.createApplAddr(true,appli.Id,loanApp.Id, 'Negative');
        ApplAddr__c applAdd3 = TestDataFactory.createApplAddr(true,appli.Id,loanApp.Id, 'Refer');
        ApplAddr__c applAdd4 = TestDataFactory.createApplAddr(true,appli.Id,loanApp1.Id, 'Pending');
        
        Case parentCase = new Case();
        parentCase.Loan_Application__c = loanApp.Id;
        parentCase.RecordTypeId =recordTypeId1;
        parentCase.Status = 'New';
        insert parentCase;
        
        Case parentCase1 = new Case();
        parentCase1.Loan_Application__c = loanApp1.Id;
        parentCase1.RecordTypeId =recordTypeId1;
        parentCase1.Status = 'New';
        insert parentCase1;
        
        Case c = TestDataFactory.createRCUCase(true,loanApp.Id,testAccount.Id,testContact.Id,recordTypeId1,parentCase.Id);
        Case c1 = TestDataFactory.createRCUCase(true,loanApp.Id,testAccount.Id,testContact.Id,recordTypeId1,parentCase.Id);
        Case c2 = TestDataFactory.createRCUCase(true,loanApp.Id,testAccount.Id,testContact.Id,recordTypeId1,parentCase.Id);
        Case c3 = TestDataFactory.createRCUCase(true,loanApp1.Id,testAccount.Id,testContact.Id,recordTypeId1,parentCase1.Id);
        
        CaseDoc__c cd = TestDataFactory.createCaseDoc(true,c.Id,docDtl.Id,null);
        CaseDoc__c cd1 = TestDataFactory.createCaseDoc(true,c.Id,null,applAdd.Id);
        CaseDoc__c cd2 = TestDataFactory.createCaseDoc(true,c1.Id,docDtl1.Id,null);
        CaseDoc__c cd3 = TestDataFactory.createCaseDoc(true,c1.Id,docDtl2.Id,null);
        CaseDoc__c cd4 = TestDataFactory.createCaseDoc(true,c.Id,docDtl3.Id,null);
        CaseDoc__c cd5 = TestDataFactory.createCaseDoc(true,c.Id,null,applAdd1.Id);
        CaseDoc__c cd6 = TestDataFactory.createCaseDoc(true,c2.Id,null,applAdd2.Id);
        CaseDoc__c cd7 = TestDataFactory.createCaseDoc(true,c2.Id,null,applAdd3.Id);
        CaseDoc__c cd8 = TestDataFactory.createCaseDoc(true,c3.Id,null,applAdd4.Id);
        try{
            UpdateRCUStatusAfterRCUManager.updateStatus(loanApp.Id);
        }catch(exception e){
            
        }        
    }
}