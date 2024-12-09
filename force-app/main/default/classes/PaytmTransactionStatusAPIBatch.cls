public class PaytmTransactionStatusAPIBatch implements Database.Batchable<sObject>,Schedulable{
   
    public Iterable<sObject> start(Database.BatchableContext BC) {
        
        List<sObject> sObjectList = new List<sObject>();
        
        List<Payment__c> payList = [SELECT Id, PaytmOrderId__c, TransStatus__c,LoanAppl__c,LoanAppl__r.Applicant__c FROM Payment__c WHERE PaytmOrderId__c != null AND (TransStatus__c = 'Pending' OR TransStatus__c = null)];
        List<ApplIMD__c> imdList = [SELECT Id, PaytmOrderId__c, TransStatus__c,LoanAppln__c,LoanAppln__r.Applicant__c FROM ApplIMD__c WHERE PaytmOrderId__c != null AND (TransStatus__c = 'Pending' OR TransStatus__c = null)];
        
        sObjectList.addAll(payList);
        sObjectList.addAll(imdList);
        
        return sObjectList;
    }
    
    
    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        
       
        try{
            
            if(!scope.isEmpty()){
                
                List<IntgMsg__c> insertIntgMsg =new List<IntgMsg__c>();
                
                for (SObject sobj : scope) {
                    
                    IntgMsg__c intg=New IntgMsg__c();
                    intg.Name='Transaction Status API';
                    intg.BU__c=GlobalConstants.INT_MSG_BU_TYPE;
                    intg.Status__c=GlobalConstants.INT_MSG_STATUS_NEW;
                    intg.MStatus__c=GlobalConstants.INT_MSG_MStatus_BLANK;
                    intg.Svc__c='Transaction Status API';
                    intg.ApiVendor__c='Paytm';
                    
                    if (sobj instanceof Payment__c) {
                        
                        Payment__c pay = (Payment__c)sobj;
                        
                        intg.LoanAppln__c=pay.LoanAppl__c;
                        intg.Appl__c=pay.LoanAppl__r.Applicant__c!=null?pay.LoanAppl__r.Applicant__c:'';
                        intg.RefId__c=pay.Id;
                        intg.RefObj__c='Payment__c';
                        intg.Req__c=requestGenerator(pay.PaytmOrderId__c);
                        
                    }
                    
                    else if(sobj instanceof ApplIMD__c){
                        
                        ApplIMD__c imd = (ApplIMD__c)sobj;
                        
                        intg.LoanAppln__c=imd.LoanAppln__c;
                        intg.Appl__c=imd.LoanAppln__r.Applicant__c!=null?imd.LoanAppln__r.Applicant__c:'';
                        intg.RefId__c=imd.Id;
                        intg.RefObj__c='ApplIMD__c';
                        intg.Req__c=requestGenerator(imd.PaytmOrderId__c);
                        
                    }
                    
                    insertIntgMsg.add(intg);
                }
                
                if(!insertIntgMsg.isEmpty()){
                    
                    insert insertIntgMsg;
                    
                    List<IntgMsg__c> newIntmsg =[SELECT id,Name,BU__c,Status__c,MStatus__c,RefObj__c,Req__c,Svc__c,ApiVendor__c from IntgMsg__c where id IN:insertIntgMsg];
                    
                    if (!newIntmsg.isEmpty()) {
                        System.enqueueJob(new PaytmTransactionStatusAPIQueueable(newIntmsg));
                    }
                }
            }
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'PaytmTransactionStatusAPIBatch', 
                                     'execute', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            
        }
        
    }
    
    public void finish(Database.BatchableContext BC) {
        System.debug('Payment and IMD batch processing completed.');
    }
    
    public void execute(SchedulableContext sc) {
        PaytmTransactionStatusAPIBatch batch = new PaytmTransactionStatusAPIBatch();
        Database.executeBatch(batch,50);
    }
    
    public static string requestGenerator(string paytmOrderId){
        
        
        IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Paytm');
        
        
        PaytmTransactionStatusRequestWrapper.Body requestbody = new PaytmTransactionStatusRequestWrapper.Body();
        
        requestbody.mid = svc.MerchantId__c;
        requestbody.orderId=paytmOrderId;
        
        PaytmChecksum paytmChecksum = new PaytmChecksum();
        
        PaytmTransactionStatusRequestWrapper.Head requestHead =new PaytmTransactionStatusRequestWrapper.Head();
        requestHead.signature=paytmChecksum.generateSignature(JSON.serialize(requestBody), svc.PrivateKey__c);
        
        
        PaytmTransactionStatusRequestWrapper request =new PaytmTransactionStatusRequestWrapper();
        request.body=requestbody;
        request.head=requestHead;
        
        return JSON.serialize(request);
        
    }
}