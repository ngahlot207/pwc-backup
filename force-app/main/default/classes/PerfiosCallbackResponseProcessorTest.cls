@istest
public class PerfiosCallbackResponseProcessorTest {
    
    @isTest
    static void perfiosCallbackResponseProcessorTestMethod() {
        
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id);  
        
        List<ApplBanking__c>appBanking = new List<ApplBanking__c>();
        appBanking.add(new ApplBanking__c(
            TransactionId__c = 'K8JF1703661182351',
            LoanAppl__c = loanApp.Id
        ));
        appBanking.add(new ApplBanking__c(
            TransactionId__c = '3PW71704439314625',
            LoanAppl__c = loanApp.Id
        ));
        
        TriggerBase.bypass('ApplBanking__c');
        insert appBanking;
        TriggerBase.clearBypass('ApplBanking__c'); 
        system.debug('appBanking '+ appBanking);
        
        List<IntgMsg__c> intMsglist = new List<IntgMsg__c>();
        IntgMsg__c newlit = new IntgMsg__c();
        newlit.Name = 'Perfios Callback';
        newlit.BU__c = 'Vehicle Loan';
        //newlit.Svc__c = svcName;
        newlit.IsActive__c = true;
        newlit.RefId__c = appli.Id;
        newlit.Status__c = 'Processed';
        newlit.MStatus__c = 'Blank';
        newlit.Trigger_Platform_Event__c = true;
        newlit.RefObj__c = 'Applicant__c';
        newlit.ParentRefId__c = loanApp.Id;
        newlit.Req__c = 'errorMessage=&errorCode=E_NO_ERROR&clientTransactionId=936959379&perfiosTransactionId=K8JF1703661182351&status=COMPLETED';
        //newlit.Resp__c = wrapperData != null ? wrapperData : null;
        intMsglist.add(newlit);
        
        IntgMsg__c newlit1 = new IntgMsg__c();
        newlit1.Name = 'Perfios Callback';
        newlit1.BU__c = 'Blank';
        //newlit1.Svc__c = svcName;
        newlit1.IsActive__c = true;
        newlit1.RefId__c = appli.Id;
        newlit.ParentRefId__c = loanApp.id;
        newlit1.Status__c = 'Processed';
        newlit1.MStatus__c = 'Blank';
        newlit1.RefObj__c = 'Applicant__c';
        newlit1.Req__c = 'errorMessage=Error+due+to+transaction+still+in+INITIATED+status&errorCode=E_OTHER&clientTransactionId=633109666&perfiosTransactionId=3PW71704439314625&status=ERROR';
        //newlit1.Resp__c = wrapperData;
        intMsglist.add(newlit1);
        
        TriggerBase.bypass('IntgMsg__c');
        insert intMsglist;
        TriggerBase.clearBypass('IntgMsg__c');
        
        // TriggerBase.bypass('IntgMsg__c');
        // PerfiosCallbackResponseProcessor.process(intMsglist);
        //TriggerBase.clearBypass('IntgMsg__c');
        Boolean assertsBoolNew = true;
        try{
            TriggerBase.bypass('IntgMsg__c');
            PerfiosCallbackResponseProcessor.process(intMsglist);
            PerfiosCallbackResponseProcessor.process(null);
            TriggerBase.clearBypass('IntgMsg__c');
            
        }catch(NullPointerException ex){
            assertsBoolNew = false;
            system.assertEquals('Attempt to de-reference a null object', ex.getMessage());
        } 
        system.assertEquals(true, assertsBoolNew);
        
    }
}