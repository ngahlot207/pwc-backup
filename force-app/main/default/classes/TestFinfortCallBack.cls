public class TestFinfortCallBack implements IintMsgCalloutResponseProcessor{
    
    //Implementing the process method
    public static void process(List<IntgMsg__c> responses){ 
        List<IntgMsg__c> updateIntMsgRecords = new List<IntgMsg__c>();
        for(IntgMsg__c intmsg : responses){
            IntgMsg__c integrationMessage =new IntgMsg__c();
            integrationMessage.Id=intmsg.Id;
            if(intmsg.Svc__c == 'Order Delivery'){
                integrationMessage.Resp__c='{"code":200,"lender_name":"New Bank","lender_referenceNumber":"TestOrder-001","ffOrderId":"FF00001234","borrower_pan":"TESTP1234A","dataTransferStatus":"Success","failureReason":"NA"}';
            }
            else{
                integrationMessage.Resp__c='{"code":200,"lender_name":"New Bank","lender_referenceNumber":"TestOrder-001","ffOrderId":"FF00001234","borrower_pan":"TESTP1234A","fileName":"FF00001234-CAM.xlsx","fileTransferStatus":"Success","failureReason":"NA"}';
            }
            integrationMessage.Status__c = 'Processed';
            updateIntMsgRecords.add(integrationMessage);
        }
        if(!updateIntMsgRecords.isEmpty()){
            update updateIntMsgRecords;
        }        
    }

}