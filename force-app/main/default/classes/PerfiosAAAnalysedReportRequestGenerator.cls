public class PerfiosAAAnalysedReportRequestGenerator implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){
        try{
            if(!msgs.isempty()){
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Perfios_AA_Analysed_Report');
                Set<Id> refIds = new Set<Id>();
                List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>();
                for (IntgMsg__c intMsg : msgs) {
                    refIds.add(intMsg.RefId__c);
                }
                
                Map<Id,Applicant__c> applicantMap = new Map<Id,Applicant__c>([SELECT Id,TransactionId__c FROM Applicant__c WHERE Id IN:refIds]);
                
                for(IntgMsg__c intmsg:msgs){
                    if(applicantMap.containsKey(intmsg.RefId__c)){
                        PerfiosAAAnalysedReportRequestWrapper request = new PerfiosAAAnalysedReportRequestWrapper();
                        
                        request.txnId = applicantMap.get(intmsg.RefId__c).TransactionId__c;
                        request.type = svc.StaticKey__c;
                        request.format = intmsg.Name.substringAfter(':')=='XLSX'? 'xlsx' : 'json';
                        
                        IntgMsg__c integrationMessage =new IntgMsg__c();
                        integrationMessage.Id=intmsg.Id;
                        integrationMessage.Req__c=JSON.serialize(request);
                        integrationMessage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                        updateIntRecords.add(integrationMessage);
                        
                    }
                }
                if(!updateIntRecords.isEmpty()){
                    update updateIntRecords;
                }
            }
        }
        catch(Exception ex){
            System.debug('error'+ex.getMessage());
            GlobalUtility.logMessage('Error', 'PerfiosAAAnalysedReportRequestGenerator' + ex.getLineNumber(), 
                                     'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
    }
}