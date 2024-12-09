public class UdyamVerificationAPIRequestGenerator implements ICalloutRequestGenerator{
    
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType});
        
        if(!msgs.isempty()){
            
            try{
                List<IntgMsg__c> updateIntMsgRecords = new List<IntgMsg__c>();
                Set<Id> applicantIds =new Set<Id>();
                
                
                //Getting All Applicant Ids
                for(IntgMsg__c msg :msgs){
                   
                    if(String.isnotBlank(msg.ParentRefId__c)){
                        applicantIds.add(msg.ParentRefId__c);
                    }
                }
                
                if(!applicantIds.isempty()){
                    //Using applicantIds Getting the ApplicantEmployment__c
                    Map<Id,ApplicantEmployment__c> applicantEmpMap =new Map<Id,ApplicantEmployment__c>();
                
                    for(ApplicantEmployment__c aem:[SELECT Id, UdyamRegistrationNumber__c, LoanApplicant__c,LastModifiedDate FROM ApplicantEmployment__c 
                                                    WHERE LoanApplicant__c IN :applicantIds ORDER BY LastModifiedDate ASC]){
                           
                       applicantEmpMap.put(aem.LoanApplicant__c,aem);                                  
                    }
                    
                    //Looping IntgMsg__c
                    for(IntgMsg__c intmsg :msgs){
                        
                        if(applicantEmpMap.containsKey(intmsg.ParentRefId__c)){
                            
                            ApplicantEmployment__c applEmp=applicantEmpMap.get(intmsg.ParentRefId__c);
                            
                            UdyamVerificationAPIRequestWrapper.ClientData caseid =new UdyamVerificationAPIRequestWrapper.ClientData();
                            caseid.caseId=intmsg.Integration_Message_Number__c;
                            
                            UdyamVerificationAPIRequestWrapper req =new UdyamVerificationAPIRequestWrapper();
                            req.consent=GlobalConstants.yesValue;//Y/N
                            req.getEnterpriseDetails=system.label.Udyam_Enterprise_Details.toupperCase();//GlobalConstants.yesValue;//Y/N
                            req.isPDFRequired=system.label.Udyam_PDF.toupperCase();//GlobalConstants.noValue;//Y/N
                            req.udyamRegistrationNo=String.isNotBlank(applEmp.UdyamRegistrationNumber__c)?applEmp.UdyamRegistrationNumber__c:'';
                            req.clientData=caseid;
                           
                            
                            IntgMsg__c integrationMessage =new IntgMsg__c();
                            integrationMessage.Id=intmsg.Id;
                            integrationMessage.Req__c=JSON.serialize(req);
                            integrationMessage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                            updateIntMsgRecords.add(integrationMessage);
                        }
                        
                    }
                    
                }
                
                //Updating the IntgMsg
                if(!updateIntMsgRecords.isEmpty()) {
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Req__c','Status__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntMsgRecords);
                }
                 uow.commitWork();
                
            }catch(Exception ex){
                GlobalUtility.logMessage('Error', 'UdyamVerificationAPIRequestGenerator class', 
                                         'generate', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
    }
    
}