public class GenerateShortUrlAPIRequestGenerator implements ICalloutRequestGenerator{
    
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){
        
        if(!msgs.isempty()){
            
            Set<Id> imdIds =new Set<Id>();
            Set<Id> paymentIds =new Set<Id>();
            Set<Id> applicnatIds = new Set<Id>();
            Set<Id> applBankIds = new Set<Id>();
            Map<Id,ApplIMD__c> applicantImdMap;
            Map<Id,Payment__c> paymentMap;
            Map<Id,Applicant__c> applicantMap;
            Map<Id,ApplBanking__c> applBankMap;
            List<IntgMsg__c> updateIntMsgRecords = new List<IntgMsg__c>();
            
            IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Generate_Short_URL');
            
            try{
                
                //Getting sObjectIds
                for(IntgMsg__c msg :msgs){
                    
                    if(String.isnotBlank(msg.RefId__c)){
                        
                        if(String.isnotBlank(msg.RefObj__c) && msg.RefObj__c=='ApplIMD__c'){
                            imdIds.add(msg.RefId__c);
                        }
                        
                        if(String.isnotBlank(msg.RefObj__c) && msg.RefObj__c=='Payment__c'){
                            paymentIds.add(msg.RefId__c);
                        }
                        if(String.isnotBlank(msg.RefObj__c) && msg.RefObj__c=='Applicant__c'){
                            applicnatIds.add(msg.RefId__c);
                        }
                        if(String.isnotBlank(msg.RefObj__c) && msg.RefObj__c=='ApplBanking__c'){
                            applBankIds.add(msg.RefId__c);
                        }
                        
                    }
                }
                
                if(!imdIds.isEmpty()){
                    applicantImdMap =new Map<Id,ApplIMD__c>([Select id,PaymentGateway__c,PaytmLinkURL__c,BDLinkURL__c from ApplIMD__c Where Id IN:imdIds]);
                }
                
                if(!paymentIds.isEmpty()){
                    paymentMap=new Map<Id,Payment__c>([Select id,Payment_Gaterway__c,PaytmLinkURL__c,BDLinkURL__c from Payment__c Where Id IN:paymentIds]);
                }
                
                if(!applicnatIds.isEmpty()){
                    applicantMap=new Map<Id,Applicant__c>([Select id,TransactionLink__c from Applicant__c Where Id IN:applicnatIds]);
                }
                
                if(!applBankIds.isEmpty()){
                    applBankMap=new Map<Id,ApplBanking__c>([Select id,TransactionLink__c from ApplBanking__c Where Id IN:applBankIds]);
                }
                
                for(IntgMsg__c intmsg :msgs){
                    
                    GenerateShortUrlAPIRequestWrapper req =new GenerateShortUrlAPIRequestWrapper();
                    req.senderId=string.isNotblank(svc.SenderId__c)?svc.SenderId__c:'';
                    req.sourceSystem=string.isNotblank(svc.SourceSystem__c)?svc.SourceSystem__c:'';
                    req.templateId=string.isNotblank(svc.StaticKey__c)?svc.StaticKey__c:'';
                    
                    if(String.isNotblank(intmsg.RefId__c) && String.isNotblank(intmsg.RefObj__c)){
                        
                        if(intmsg.RefObj__c=='ApplIMD__c' && applicantImdMap.containsKey(intmsg.RefId__c)){
                            req.actualUrl= applicantImdMap.get(intmsg.RefId__c).PaymentGateway__c=='Paytm' && String.isNotblank(applicantImdMap.get(intmsg.RefId__c).PaytmLinkURL__c) ? applicantImdMap.get(intmsg.RefId__c).PaytmLinkURL__c : applicantImdMap.get(intmsg.RefId__c).PaymentGateway__c=='Billdesk' && String.isNotblank(applicantImdMap.get(intmsg.RefId__c).BDLinkURL__c) ? applicantImdMap.get(intmsg.RefId__c).BDLinkURL__c : '';
                        }
                        else if(intmsg.RefObj__c=='Payment__c' && paymentMap.containsKey(intmsg.RefId__c)){
                            req.actualUrl= paymentMap.get(intmsg.RefId__c).Payment_Gaterway__c =='Paytm' && String.isNotblank(paymentMap.get(intmsg.RefId__c).PaytmLinkURL__c) ? paymentMap.get(intmsg.RefId__c).PaytmLinkURL__c : paymentMap.get(intmsg.RefId__c).Payment_Gaterway__c =='Bill Desk' && String.isNotblank(paymentMap.get(intmsg.RefId__c).BDLinkURL__c) ? paymentMap.get(intmsg.RefId__c).BDLinkURL__c : '';
                        }
                        else if(intmsg.RefObj__c=='Applicant__c' && applicantMap.containsKey(intmsg.RefId__c)){
                            req.actualUrl= String.isNotblank(applicantMap.get(intmsg.RefId__c).TransactionLink__c) ? applicantMap.get(intmsg.RefId__c).TransactionLink__c : '';
                        }
                        else if(intmsg.RefObj__c=='ApplBanking__c' && applBankMap.containsKey(intmsg.RefId__c)){
                            req.actualUrl= String.isNotblank(applBankMap.get(intmsg.RefId__c).TransactionLink__c) ? applBankMap.get(intmsg.RefId__c).TransactionLink__c : '';
                        }
                    }
                    
                    if(req.actualUrl!=null && String.isNotBlank(req.actualUrl)){
                        IntgMsg__c integrationMessage =new IntgMsg__c();
                        integrationMessage.Id=intmsg.Id;
                        integrationMessage.Req__c=JSON.serialize(req);
                        integrationMessage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                        updateIntMsgRecords.add(integrationMessage);
                    }
                }
                
                if(!updateIntMsgRecords.isEmpty()){
                    update updateIntMsgRecords;
                }
                
                
            }catch(Exception ex){
                GlobalUtility.logMessage('Error', 'GenerateShortUrlAPIRequestGenerator class', 
                                         'generate', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
    }
    
}