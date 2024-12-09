public class CompositePaymentRequestGenerator implements ICalloutRequestGenerator {
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){ 
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType });
        
        //Creating a Set of Ids
        Set<Id> repayAccVerIds = new Set<Id>();
        Set<Id> splitDisbIds = new Set<Id>();
        
        //Iterating over new Intgeration Message record Ids to add them into the above List
        for(IntgMsg__c intMsg : msgs){ 
            if(intMsg.RefObj__c=='Split_Disbur__c'){
                splitDisbIds.add(intMsg.RefId__c);
                System.debug('splitDisbIds::'+splitDisbIds);
            }
            else if(intMsg.RefObj__c=='RepayAccVerify__c'){
                repayAccVerIds.add(intMsg.RefId__c);
                System.debug('repayAccVerIds::'+repayAccVerIds);
            }
            else{
                //nothing
            }
        }
        
        
        Map<Id,Split_Disbur__c> splitDisbMap;
        Map<Id,RepayAccVerify__c> repayAccVerMap;
        
        if(splitDisbIds!=null && !splitDisbIds.isEmpty()){
            splitDisbMap = new Map<Id,Split_Disbur__c>([Select id,name,Cheq_Favor_Acc_No__c,IFSC_Detail__c,Custo_Name__c,DisburseRela__r.Applicant_Mobile_Number__c from Split_Disbur__c Where Id IN:splitDisbIds]);
        }
        if(repayAccVerIds!=null && !repayAccVerIds.isEmpty()){
            repayAccVerMap = new Map<Id,RepayAccVerify__c>([Select id,RepayAcc__r.Account_Number__c,RepayAcc__r.Applicant_Banking__r.Appl__r.MobNumber__c,RepayAcc__r.AccHolderName__c,RepayAcc__r.IFSC_Code__c from RepayAccVerify__c Where Id IN:repayAccVerIds]);
        } 
        
        try{
            List<IntgMsg__c>updateIntMsgList=New List<IntgMsg__c>();
            IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('ICICI_PennyDrop'); 
            
            if(!msgs.isEmpty()){
                for(IntgMsg__c integrationMsg : msgs){ 
                    if(integrationMsg.RefId__c!=null){
                        if(integrationMsg.RefObj__c=='RepayAccVerify__c'){
                            
                            if(repayAccVerMap.containskey(integrationMsg.RefId__c)){
                                
                                RepayAccVerify__c refacc=repayAccVerMap.get(integrationMsg.RefId__c);
                                
                                CompositePaymentRequestWrapper request = new CompositePaymentRequestWrapper();
                                Datetime currentDateTime = System.now();
                                String formattedDateTime = currentDateTime.formatGMT('yyyyMMddHHmmss');
                                
                                request.localTxnDtTime=formattedDateTime;
                                request.beneAccNo=refacc.RepayAcc__r.Account_Number__c;
                                request.beneIFSC=refacc.RepayAcc__r.IFSC_Code__c;
                                request.amount=GlobalConstants.amount;
                                request.tranRefNo=GlobalUtility.getUniqueNumber();
                                request.paymentRef=GlobalUtility.getUniqueNumber();
                                request.senderName=refacc.RepayAcc__r.AccHolderName__c;      
                                request.mobile=refacc.RepayAcc__r.Applicant_Banking__r.Appl__r.MobNumber__c;
                                request.retailerCode=GlobalConstants.retailerCode;
                                request.passCode=svc.Password__c;//'cd5cd91514e343568613260edcbdba40';
                                request.bcID=svc.MerchantId__c;//'IBCFED01286';
                                request.crpId=svc.CorporateId__c;//'FEDBANKF30032017';
                                request.crpUsr=svc.Username__c;//'SOUGATAR';
                                request.aggrId=svc.AggregatorID__c;//'CUST0946';
                                
                                IntgMsg__c integrationMessage =new IntgMsg__c();
                                integrationMessage.Id=integrationMsg.Id;
                                
                                integrationMessage.Req__c=JSON.serialize(request);
                                integrationMessage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                                updateIntMsgList.add(integrationMessage);
                                
                            }
                            
                        }
                        else if(integrationMsg.RefObj__c=='Split_Disbur__c'){
                            
                            if(splitDisbMap.containskey(integrationMsg.RefId__c)){
                                
                                Split_Disbur__c splitDisObj =splitDisbMap.get(integrationMsg.RefId__c);
                                
                                CompositePaymentRequestWrapper request = new CompositePaymentRequestWrapper();
                                Datetime currentDateTime = System.now();
                                String formattedDateTime = currentDateTime.formatGMT('yyyyMMddHHmmss');
                                
                                request.localTxnDtTime=formattedDateTime;
                                request.beneAccNo=splitDisObj.Cheq_Favor_Acc_No__c;
                                request.beneIFSC=splitDisObj.IFSC_Detail__c;
                                request.amount=GlobalConstants.amount;
                                request.tranRefNo=GlobalUtility.getUniqueNumber();
                                request.paymentRef=GlobalUtility.getUniqueNumber();
                                request.senderName=splitDisObj.Custo_Name__c;      
                                request.mobile=splitDisObj.DisburseRela__r.Applicant_Mobile_Number__c;
                                request.retailerCode=GlobalConstants.retailerCode;
                                request.passCode=svc.Password__c;//'cd5cd91514e343568613260edcbdba40';
                                request.bcID=svc.MerchantId__c;//'IBCFED01286';
                                request.crpId=svc.CorporateId__c;//'FEDBANKF30032017';
                                request.crpUsr=svc.Username__c;//'SOUGATAR';
                                request.aggrId=svc.AggregatorID__c;//'CUST0946';
                                
                                IntgMsg__c integrationMessage =new IntgMsg__c();
                                integrationMessage.Id=integrationMsg.Id;
                                
                                integrationMessage.Req__c=JSON.serialize(request);
                                integrationMessage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                                updateIntMsgList.add(integrationMessage);
                                
                            } 
                            
                        }
                        
                    }
                    
                }
                if (!updateIntMsgList.isEmpty()) {
                        String sObjectName = 'IntgMsg__c';
                        List<String> fieldNamesList = new List<String>{'Req__c', 'Status__c'};
                            Schema.SObjectType objType = Schema.getGlobalDescribe().get(sObjectName);
                        fflib_SecurityUtils.checkUpdate(objType, fieldNamesList);
                        uow.registerDirty(updateIntMsgList);
                    }
                uow.commitWork();
            }
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CompositePaymentRequestGenerator class', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
}