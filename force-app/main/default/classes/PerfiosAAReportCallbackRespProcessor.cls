public class PerfiosAAReportCallbackRespProcessor {

    
    public Static void process(List<IntgMsg__c> responses){
        try{
            Map<String,ReportResponseWrapper> responseMap = new Map<String,ReportResponseWrapper>();
            Map<String,String> intgMsgRefIdsMap = new Map<String,String>();
            
            for(IntgMsg__c integrationMessage : responses){
                if(integrationMessage.Req__c!=null){
                    try{
                        ReportResponseWrapper response = (ReportResponseWrapper) JSON.deserialize(integrationMessage.Req__c,ReportResponseWrapper.class);
                        if(response!=null && response.txnId!=null && String.isNotBlank(response.txnId)){
                            responseMap.put(response.txnId, response);
                            intgMsgRefIdsMap.put(integrationMessage.Id,response.txnId);
                        }
                        
                    }
                    catch(exception ex){
                        system.debug('Error line number: ' + ex.getLineNumber() + 'Error Message: '+ ex.getMessage());
                    }
                }
            }
            
            if(!responseMap.isEmpty()){
                processResponse(intgMsgRefIdsMap,responseMap);
            }
        }
        catch(exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }  
    }
    
    public static void processResponse(Map<String,String> intgMsgRefIdsMap,Map<String,ReportResponseWrapper> responseMap){
        try{
            if(responseMap!=null){
                List<Applicant__c> applicantList = new List<Applicant__c>();
                Map<String,Applicant__c> applicantMap = new Map<String,Applicant__c> ();
                List<IntgMsg__c> createRequestList = new List<IntgMsg__c>();
                for(Applicant__c appl : [SELECT Id,LoanAppln__c,TransactionId__c,IntegrationStatus__c,IntegrationErrorMessage__c FROM Applicant__c WHERE TransactionId__c IN:responseMap.keySet()]){
                    applicantMap.put(appl.TransactionId__c,appl);
                	
                    if(responseMap.containsKey(appl.TransactionId__c)){
                        ReportResponseWrapper response = responseMap.get(appl.TransactionId__c);
                        if(response!=null && response.status!=null){
                            Applicant__c app = new Applicant__c();
                            app.Id = appl.Id;
                            if( response.status.equalsIgnoreCase('COMPLETED')){
                                app.IntegrationStatus__c = PerfiosAPIController.replaceAndUpdateString('Perfios AA Report Notification', 'Perfios AA Report Notification: Success', appl.IntegrationStatus__c, ';');
                                app.IntegrationErrorMessage__c = PerfiosAPIController.replaceAndUpdateString('Perfios AA Report Notification', '', appl.IntegrationErrorMessage__c, ';');
                                
                                IntgMsg__c intmsg =new IntgMsg__c();
                                intmsg.Name='Analysed Report:JSON';
                                intmsg.BU__c='HL / STL';
                                intmsg.Status__c='New';
                                intmsg.MStatus__c='Blank';
                                intmsg.Svc__c='Analysed Report';
                                intmsg.IsActive__c=true;
                                intmsg.RefId__c= appl.Id;
                                intmsg.RefObj__c= 'Applicant__c';
                                intMsg.ParentRefId__c = appl.LoanAppln__c;
                                intMsg.ParentRefObj__c = 'LoanAppl__c';
                                createRequestList.add(intmsg);
                                
                                IntgMsg__c intmsg1 =new IntgMsg__c();
                                intmsg1.Name='Analysed Report:XLSX';
                                intmsg1.BU__c='HL / STL';
                                intmsg1.Status__c='New';
                                intmsg1.MStatus__c='Blank';
                                intmsg1.Svc__c='Analysed Report';
                                intmsg1.IsActive__c=true;
                                intmsg1.RefId__c= appl.Id;
                                intmsg1.RefObj__c= 'Applicant__c';
                                intMsg1.ParentRefId__c = appl.LoanAppln__c;
                                intMsg1.ParentRefObj__c = 'LoanAppl__c';
                                createRequestList.add(intmsg1);
                            }
                            else{
                                app.IntegrationStatus__c = PerfiosAPIController.replaceAndUpdateString('Perfios AA Report Notification', 'Perfios AA Report Notification: Failure', appl.IntegrationStatus__c, ';');
                                app.IntegrationErrorMessage__c = PerfiosAPIController.replaceAndUpdateString('Perfios AA Report Notification','Perfios AA Report Notification: ' + response.status , appl.IntegrationErrorMessage__c, ';');
                                app.Perfios_AA_Status__c = 'Failure';
                            }
                            applicantList.add(app);
                        }
                    }
                
                }
                if(!applicantList.isEmpty()){
                    update applicantList;
                }
                if(!createRequestList.isEmpty()){
                    insert createRequestList;
                }
                if(!intgMsgRefIdsMap.isEmpty()){
                    List<IntgMsg__c> updateIntgMsgRecords = new List<IntgMsg__c>();
                    for(String intgMsgId : intgMsgRefIdsMap.keySet()){
                        IntgMsg__c intg = new IntgMsg__c();
                        intg.id =  intgMsgId;
                        intg.Status__c = 'Processed';
                        if(applicantMap.containskey(intgMsgRefIdsMap.get(intgMsgId))){
                            intg.Appl__c = applicantMap.get(intgMsgRefIdsMap.get(intgMsgId)).Id;
                            if(applicantMap.get(intgMsgRefIdsMap.get(intgMsgId)).LoanAppln__c!=null){
                                intg.LoanAppln__c = applicantMap.get(intgMsgRefIdsMap.get(intgMsgId)).LoanAppln__c;
                            }
                        }
                        updateIntgMsgRecords.add(intg);
                    }
                    if(!updateIntgMsgRecords.isEmpty()){
                        update updateIntgMsgRecords;
                    }
                }
            }
        }
        catch(exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }  
    }
    
    
    
    
    public class ReportResponseWrapper{
        public ReportStatus reportStatus;
        public String txnId;	//62faea57813240299b75260d5e16fca8
        public String status;	//COMPLETED
    }
    public class ReportStatus {
        public Insights INSIGHTS;
    }
    public class Insights {
        public List<String> reportFiles;
        public String status;	//SUCCESS
    }
}