@isTest
public class ProbeCallbackResponseProTest {

    
    @isTest
    static void perfiosCallbackResponseProcessorTestMethod() {
        
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id);  
        

		APIVer__c apiVer =TestDataFactory.createAPIVerification(true,loanApp.ID,appli.Id,'Probe42');  
        apiVer.IsLatest__c=true;
        apiVer.UpdReqId__c='66b271af6c08d5313902b023';
        apiVer.UpdateApiType__c = 'Update Company Comprehensive details';
        update apiVer;
        
        
        List<IntgMsg__c> intMsglist = new List<IntgMsg__c>();
        IntgMsg__c newlit = new IntgMsg__c();
        newlit.Name = 'Probe42 Callback';
        newlit.BU__c = 'HL / STL';
        //newlit.Svc__c = svcName;
        newlit.IsActive__c = true;
        newlit.RefId__c = appli.Id;
        newlit.Status__c = 'Processed';
        newlit.MStatus__c = 'Blank';
        newlit.Trigger_Platform_Event__c = true;
        newlit.RefObj__c = 'Applicant__c';
        newlit.ParentRefId__c = loanApp.Id;
        newlit.Req__c = '{"cin":"L74120MH1985PLC035308","request_id":"66b271af6c08d5313902b023","status":"FULFILLED"}';
        //newlit.Resp__c = wrapperData != null ? wrapperData : null;
        intMsglist.add(newlit);
        
        IntgMsg__c newlit1 = new IntgMsg__c();
        newlit1.Name = 'Probe42 Callback';
        newlit1.BU__c = 'HL / STL';
        //newlit1.Svc__c = svcName;
        newlit1.IsActive__c = true;
        newlit1.RefId__c = appli.Id;
        newlit.ParentRefId__c = loanApp.id;
        newlit1.Status__c = 'Processed';
        newlit1.MStatus__c = 'Blank';
        newlit1.RefObj__c = 'Applicant__c';
        newlit1.Req__c = '{"cin":"L74120MH1985PLC035308","request_id":"66b271af6c08d5313902b023","status":"FULFILLED"}';
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
            ProbeCallbackResponseProcessor.process(intMsglist);
            ProbeCallbackResponseProcessor.process(null);
            TriggerBase.clearBypass('IntgMsg__c');
            
        }catch(NullPointerException ex){
            assertsBoolNew = false;
            //system.assertEquals('Attempt to de-reference a null object', ex.getMessage());
        } 
        system.assertEquals(true, assertsBoolNew);
        
    }
    
}