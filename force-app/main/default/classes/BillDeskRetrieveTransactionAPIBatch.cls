public class BillDeskRetrieveTransactionAPIBatch implements Database.Batchable<sObject>,Schedulable{
    
    public Iterable<sObject> start(Database.BatchableContext BC) {
        
        List<sObject> sObjectList = new List<sObject>();
        
        List<Payment__c> payList = [SELECT Id, OrderId__c, TransStatus__c,LoanAppl__c,LoanAppl__r.Applicant__c FROM Payment__c WHERE OrderId__c != null AND (TransStatus__c = 'Pending' OR TransStatus__c = null)];
        List<ApplIMD__c> imdList = [SELECT Id, OrderId__c, TransStatus__c,LoanAppln__c,LoanAppln__r.Applicant__c FROM ApplIMD__c WHERE OrderId__c != null AND (TransStatus__c = 'Pending' OR TransStatus__c = null)];
        
        sObjectList.addAll(payList);
        sObjectList.addAll(imdList);
        
        return sObjectList;
    }
    
    
    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        
        
        try{
            
            if(!scope.isEmpty()){
                
                List<IntgMsg__c> insertIntgMsg =new List<IntgMsg__c>();
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('BillDesk');
                for (SObject sobj : scope) {
                    
                    BillDeskRetrieveTransactionReqWrapper requestPayload =new BillDeskRetrieveTransactionReqWrapper();
                    requestPayload.mercid = svc.MerchantId__c!=null ? svc.MerchantId__c : '';
                    
                    IntgMsg__c intg=New IntgMsg__c();
                    intg.Name='Retrieve Transaction';
                    intg.BU__c=GlobalConstants.INT_MSG_BU_TYPE;
                    intg.Status__c=GlobalConstants.INT_MSG_STATUS_NEW;
                    intg.MStatus__c=GlobalConstants.INT_MSG_MStatus_BLANK;
                    intg.Svc__c='Retrieve Transaction';
                    intg.ApiVendor__c='BillDesk';
                    
                    if (sobj instanceof Payment__c) {
                        
                        Payment__c pay = (Payment__c)sobj;
                        requestPayload.orderid = pay.OrderId__c;
                        
                        intg.LoanAppln__c=pay.LoanAppl__c;
                        intg.Appl__c=pay.LoanAppl__r.Applicant__c!=null?pay.LoanAppl__r.Applicant__c:'';
                        intg.RefId__c=pay.Id;
                        intg.RefObj__c='Payment__c';
                    }
                    else if(sobj instanceof ApplIMD__c){
                        
                        ApplIMD__c imd = (ApplIMD__c)sobj;
                        requestPayload.orderid = imd.OrderId__c;
                        
                        intg.LoanAppln__c=imd.LoanAppln__c;
                        intg.Appl__c=imd.LoanAppln__r.Applicant__c!=null?imd.LoanAppln__r.Applicant__c:'';
                        intg.RefId__c=imd.Id;
                        intg.RefObj__c='ApplIMD__c';
                    }
                    
                    BillDeskAPIController.RequestWrapper  request = new BillDeskAPIController.RequestWrapper();
                    request.encrypted_Payload = BillDeskAPIController.getEncryptedPayload(JSON.serialize(requestPayload,true));
                    Map<String,String> header = new Map<String,String>();
                    String epochTime = BillDeskAPIController.getepochTime(DateTime.now());
                    header.put('BD-Timestamp',epochTime);
                    header.put('BD-Traceid', GlobalUtility.getUniqueNumber() + epochTime);
                    request.Header = header;
                    
                    intg.Req__c = JSON.serialize(request); 
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
            GlobalUtility.logMessage('Error', 'BillDeskRetrieveTransactionAPIBatch', 
                                     'execute', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            
        }
        
    }
    
    public void finish(Database.BatchableContext BC) {
        System.debug('Payment and IMD batch processing completed.');
    }
    
    public void execute(SchedulableContext sc) {
        BillDeskRetrieveTransactionAPIBatch batch = new BillDeskRetrieveTransactionAPIBatch();
        Database.executeBatch(batch,50);
    }
}