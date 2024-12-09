public class PerfiosRetrieveReportRequestGenerator implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType});
        
        try{
            if(!msgs.isempty()){
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Perfios_Retrieve_Report');
                List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>();
                
                Set<Id> refIds = new Set<Id>();
                
                for (IntgMsg__c intMsg : msgs) {
                    refIds.add(intMsg.ParentRefId__c);
                }
                
                Map<Id, ApplBanking__c> applBankingMap = new Map<Id, ApplBanking__c>([select Id,TransactionId__c from ApplBanking__c where Id IN:refIds]);
                
                for(IntgMsg__c intmsg:msgs){
                    if(applBankingMap.containskey(intmsg.ParentRefId__c)){
                        ApplBanking__c applBanking = applBankingMap.get(intmsg.ParentRefId__c);
                        
                        if(String.isNotBlank(applBanking.TransactionId__c)){
                            String reportType= intmsg.Name.substringAfter(':')=='XLSX'? 'xlsx' : 'json';
                            String method ='GET';
                            String requestDate= String.valueOf(system.now().format('yyyyMMdd\'T\'HHmmss\'Z\''));
                            String url = svc.URL__c.replace('<<__TransactionId__>>',applBanking.TransactionId__c);//'/KuberaVault/api/v3/organisations/fedfina/transactions/'+applBanking.TransactionId__c+'/reports';
                            String urlquerystring = 'types=' + reportType;
                            String payload = '';
                            string signature = PerfiosAPIController.generateSignature(method,URL,urlquerystring,payload, requestDate);
                            
                            
                            PerfiosAPIController.RequestWrapper perfioRequest = new PerfiosAPIController.RequestWrapper();
                            perfioRequest.Payload=payload;
                            PerfiosAPIController.Header header = new PerfiosAPIController.Header();
                            header.perfioRequestDate = requestDate;
                            header.perfiosAlgorithm = svc.AlgorithmName__c;//'PERFIOS1-RSA-SHA256';
                            header.sha256Content = PerfiosAPIController.getSHA256Content(payload);
                            header.perfioSignature = signature;
                            header.perfiosSignedHeaders = svc.SignedHeaders__c;//'host;x-perfios-content-sha256;x-perfios-date';
                            header.transactionID = applBanking.TransactionId__c;
                            header.reportTypes = reportType;
                            perfioRequest.Header = header;
                            
                            IntgMsg__c integrationMessage =new IntgMsg__c();
                            integrationMessage.Id=intmsg.Id;
                            integrationMessage.Req__c=JSON.serialize(perfioRequest);
                            integrationMessage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                            updateIntRecords.add(integrationMessage);
                            
                        }
                    }
                }
                if(!updateIntRecords.isEmpty()) {
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Req__c','Status__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntRecords);
                }
                uow.commitWork();
            }
            
            
        }
        //Catch bloack to catch Exceptions occured during generation of payload and displaying the passing the same in GlobalUtility class
        catch(Exception ex){
            System.debug('error'+ex.getMessage());
            GlobalUtility.logMessage('Error', 'PerfiosRetrieveReportRequestGenerator' + ex.getLineNumber(), 
                                     'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
    public class PerfiosRetrieveReportException extends Exception {
        
    }
}