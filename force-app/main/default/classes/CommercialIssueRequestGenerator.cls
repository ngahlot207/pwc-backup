public class CommercialIssueRequestGenerator implements ICalloutRequestGenerator {
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType) { 
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType>{IntgMsg__c.SObjectType});
        
        try{
            Set<Id> refIdSet = new Set<Id>(); 
            
            // Check if msgs is empty before processing
            if (!msgs.isEmpty()) {
                for (IntgMsg__c intmsg : msgs) {
                    refIdSet.add(intmsg.RefId__c);
                    
                }
            }
            
            
            if (!refIdSet.isEmpty()) {
                List<Applicant__c> applist = [SELECT Id, Name, LoanAppln__c FROM Applicant__c WHERE Id IN :refIdSet];  
                
                
                if (!applist.isEmpty()) {
                    Id loanApplnId = applist[0].LoanAppln__c;
                    List<LoanAppl__c> loanlist = [SELECT Id, Name FROM LoanAppl__c WHERE Id = :loanApplnId];
                    
                    
                    if (!loanlist.isEmpty()) {
                        List<Bureau__c> Bureaulist = [SELECT Id, Applicant__c, AckId__c, IsLatest__c, LoanApp__c,BureauAPI__c FROM Bureau__c WHERE Applicant__c IN :refIdSet AND LoanApp__c = :loanlist[0].Id AND IsLatest__c = true AND BureauAPI__c='Commercial'];
                        
                        
                        if (!Bureaulist.isEmpty()) {
                            
                            // Key Values from metaData
                            IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Commercial_Issue_Request');
                            
                            // Used In HEADER section REQUEST-TIME
                            DateTime currentDateTime = DateTime.now();
                            String currentDateTimeString = currentDateTime.format('ddMMyyyy HH:mm:ss');
                            
                            // ACKNOWLEDGEMENT-ID section
                            Map<String, Object> requestBody = new Map<String, Object>();
                            requestBody.put('ACKNOWLEDGEMENT-ID', Bureaulist[0].AckId__c != null ? String.valueOf(Bureaulist[0].AckId__c) : '');
                            
                            // HEADER section
                            Map<String, Object> header = new Map<String, Object>();
                            header.put('APPLICATION-ID',loanlist[0].Name != null ? loanlist[0].Name : '' );//
                            header.put('CUST-ID',applist[0].Name != null ? applist[0].Name : '');//
                            header.put('REQUEST-RECEIVED-TIME', currentDateTimeString);
                            header.put('REQUEST-TYPE', String.isNotBlank(svc.InquiryCode__c)?svc.InquiryCode__c:'');//ISSUE
                            header.put('SOURCE-SYSTEM', String.isNotBlank(svc.SourceSystem__c)?svc.SourceSystem__c:'');//  DIRECT
                            
                            requestBody.put('HEADER', header);
                            
                            List<String> responseFormat = new List<String>();
                            responseFormat.add('04');
                            responseFormat.add('02');
                            
                            requestBody.put('RESPONSE-FORMAT', responseFormat);
                            
                            // Process integration message records
                            List<IntgMsg__c> updateIntMsgRecords = new List<IntgMsg__c>();
                            
                            for (IntgMsg__c intmsg : msgs) {
                                
                                IntgMsg__c integrationMessage =new IntgMsg__c();
                                integrationMessage.id=intmsg.id;
                                integrationMessage.Req__c = JSON.serialize(requestBody);
                                integrationMessage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                                updateIntMsgRecords.add(integrationMessage);
                            }
                            
                            
                            if (!updateIntMsgRecords.isEmpty()) {
                                String sObjectName = 'IntgMsg__c';
                                List<String> fieldNamesList = new List<String>{'Req__c', 'Status__c'};
                                    Schema.SObjectType objType = Schema.getGlobalDescribe().get(sObjectName);
                                fflib_SecurityUtils.checkUpdate(objType, fieldNamesList);
                                uow.registerDirty(updateIntMsgRecords);
                            }
                        }
                    }
                }
            }
            
            uow.commitWork();
        }catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'CommercialIssueRequestGenerator class', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
}