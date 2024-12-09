@isTest
public class CaseValidateVendorPortalTest {
    
    @isTest
    public static void setupTestData() {
        
        UserRole r = [Select id,Name from UserRole WHERE Name = 'CEO'];
        User thisUser = [SELECT ID,UserRoleId  from USER Where ID =: UserInfo.getUserId()];
        thisUser.UserRoleId =  r.id;
        Update thisUser;
        User u1;
        System.runAs(thisUser){
            Profile pfile = [SELECT Name, Id FROM Profile WHERE Name = 'Agency Profile'];
            Account portalAccount = new Account(name = 'portalAccount');
            insert portalAccount;
            
            Contact portalContact = new Contact(LastName = 'portalContact', AccountId = portalAccount.Id);
            insert portalContact;
            
            u1 = new User( email='test@test.com',
                          profileid = pfile.Id, 
                          UserName='portalUser@portalTestUser.com', 
                          Alias = 'a',
                          TimeZoneSidKey='Australia/Sydney',
                          EmailEncodingKey='ISO-8859-1',
                          LocaleSidKey='en_US', 
                          LanguageLocaleKey='en_US',
                          ContactId = portalContact.Id,
                          FirstName = 'Test FirstName',
                          LastName = 'LastName'
                         );
            
            insert u1;
        }
        
        
        System.runAs(u1){
            List<case> newcaseList = new List<case>();
            List<case> oldcaseList = new List<case>(); 
            List<case> newcaseList1 = new List<case>();
            List<case> oldcaseList1 = new List<case>();
            
            List<case> newcaseList2 = new List<case>();
            List<case> oldcaseList2 = new List<case>();  
            LoanAppl__c loanApp = TestDataFactory.createLoanApplication(True); 
            Applicant__c applicant = TestDataFactory.createSingleApplicant(True,loanApp.Id);
            ApplAsset__c appAsset = TestDataFactory.applAssetData(True,applicant.Id);
            Id TechanicalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
            
            Case objCase = new case();
            objCase.ValidityDays__c = -3;
            objCase.Loan_Application__c = loanApp.Id;
            objCase.ApplAssetId__c=appAsset.Id;
            objCase.RecordTypeId =TechanicalRecordTypeId;
            objCase.Date_of_Report__c = date.today();
            objCase.Status = 'new';
            objCase.ReportResult__c = 'Positive';
            objCase.PhotoCount__c = null;
            objCase.ReportCount__c = NULL;    
            TriggerBase.bypass('Case');
            Insert objCase;
            TriggerBase.clearBypass('Case');
            
            Case objCase1 = new Case();
            objCase1.ValidityDays__c = -3;
            objCase1.Id = objCase.Id;
            objCase1.Loan_Application__c = loanApp.Id;
            objCase1.ApplAssetId__c=appAsset.Id;
            objCase1.RecordTypeId =TechanicalRecordTypeId;
            objCase1.Date_of_Report__c = date.today();
            objCase1.Status = 'Query';
            objCase1.ReportResult__c = 'Positive';
            objCase1.PhotoCount__c = 1;
            objCase1.ReportCount__c = 7;   
            try{
                Update objCase1;
            }catch(Exception e){
            }
            
            Case objCase2 = new case();
            objCase2.ValidityDays__c = -3;
            objCase2.Loan_Application__c = loanApp.Id;
            objCase2.ApplAssetId__c=appAsset.Id;
            objCase2.RecordTypeId =TechanicalRecordTypeId;
            objCase2.Date_of_Report__c = date.today();
            objCase2.Status = 'new';
            objCase2.ReportResult__c = 'Positive';
            objCase2.PhotoCount__c = 7;
            objCase2.ReportCount__c = null;    
            TriggerBase.bypass('Case');
            Insert objCase2;
            TriggerBase.clearBypass('Case');
            
            Case objCase3 = new Case();
            objCase3.ValidityDays__c = -3;
            objCase3.Id = objCase2.Id;
            objCase3.Loan_Application__c = loanApp.Id;
            objCase3.ApplAssetId__c=appAsset.Id;
            objCase3.RecordTypeId =TechanicalRecordTypeId;
            objCase3.Date_of_Report__c = date.today();
            objCase3.Status = 'Query';
            objCase3.ReportResult__c = 'Positive';
            objCase3.PhotoCount__c = 1;
            objCase3.ReportCount__c = 7;   
            try{
                Update objCase3;
            }catch(Exception e){
            }           
            
            Case objCase4 = new case();
            objCase4.ValidityDays__c = -3;
            objCase4.Loan_Application__c = loanApp.Id;
            objCase4.ApplAssetId__c=appAsset.Id;
            objCase4.RecordTypeId =TechanicalRecordTypeId;
            objCase4.Date_of_Report__c = date.today();
            objCase4.Status = 'new';
            objCase4.ReportResult__c = 'Positive';
            objCase4.PhotoCount__c = null;
            objCase4.ReportCount__c = 1;    
            TriggerBase.bypass('Case');
            Insert objCase4;
            TriggerBase.clearBypass('Case');
            
            
            Case objCase5 = new Case();
            objCase5.ValidityDays__c = -3;
            objCase5.Id = objCase4.Id;
            objCase5.Loan_Application__c = loanApp.Id;
            objCase5.ApplAssetId__c=appAsset.Id;
            objCase5.RecordTypeId =TechanicalRecordTypeId;
            objCase5.Date_of_Report__c = date.today();
            objCase5.Status = 'Query';
            objCase5.ReportResult__c = 'Positive';
            objCase5.PhotoCount__c = 5;
            objCase5.ReportCount__c = null;   
            try{
                Update objCase5;
            }catch(Exception e){
            }   
            newcaseList.add(objCase);
            oldcaseList.add(objCase1);
            newcaseList1.add(objCase2);
            oldcaseList1.add(objCase3);
            newcaseList2.add(objCase4);
            oldcaseList2.add(objCase5);   
            
            Test.StartTest();
            CaseValidateVendorPortalUploadedFiles.beforeUpdate(newcaseList , oldcaseList);
            CaseValidateVendorPortalUploadedFiles.beforeUpdate(newcaseList1 , oldcaseList1);
            CaseValidateVendorPortalUploadedFiles.beforeUpdate(newcaseList2 , oldcaseList2);
            Test.StopTest();
        }
    }
    
}