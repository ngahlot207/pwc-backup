public class EmailAuthenticationAdvRequestGenerator implements ICalloutRequestGenerator{
    
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){
        
        if(!msgs.isEmpty()){
            
            try{
                Set<Id> applicantIds =new Set<Id>();
                List<IntgMsg__c> updateIntMsgRecords = new List<IntgMsg__c>();
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Email_Authentication_Advanced');
                
                //getting Applicant Ids
                for(IntgMsg__c intmsg:msgs){
                    
                    if(String.isNotblank(intmsg.RefId__c)){
                        applicantIds.add(intmsg.RefId__c);
                    }
                }
                
                if(!applicantIds.isEmpty()){
                    
                    Set<Id> employerIds =new Set<Id>();
                    
                    //Applicant Map
                    Map<Id,Applicant__c> applicantMap =new Map<Id,Applicant__c>([Select Id,Constitution__c,EmailId__c,CompanyName__c,
                                                                                 FullName__c from Applicant__c Where Id IN:applicantIds]);
                    
                    //ApplicantEmployment__c Map
                    Map<Id,ApplicantEmployment__c> applicantEmpMap =new Map<Id,ApplicantEmployment__c>();
                    
                    for(ApplicantEmployment__c appemp:[Select Id,LoanApplicant__c,LoanApplicant__r.Constitution__c,EmployerName__c from ApplicantEmployment__c
                                                       Where LoanApplicant__c IN:applicantIds AND 
                                                       LoanApplicant__r.Constitution__c= 'INDIVIDUAL' order By CreatedDate Desc]){
                                                           
                                                           if (!applicantEmpMap.containsKey(appemp.LoanApplicant__c)) {
                                                               applicantEmpMap.put(appemp.LoanApplicant__c,appemp);
                                                           }
                                                           
                                                           if(!applicantEmpMap.containsKey(appemp.LoanApplicant__c) && appemp.EmployerName__c!=null){
                                                               employerIds.add(appemp.EmployerName__c);
                                                           }
                                                           
                                                       }
                    
                    //Employer__c Map
                    Map<Id,Employer__c> empMap=new Map<Id,Employer__c>([Select Id,Name from Employer__c Where Id IN:employerIds]);
                    
                    
                    for(IntgMsg__c intmsg:msgs){
                        
                        EmailAuthenticationAdvRequestWrapper.ClientData clientdata =new EmailAuthenticationAdvRequestWrapper.ClientData();
                        clientdata.caseId=intmsg.Integration_Message_Number__c;
                        
                        
                        EmailAuthenticationAdvRequestWrapper request =new EmailAuthenticationAdvRequestWrapper();
                        
                        request.email=(string.isNotBlank(intmsg.RefId__c) && applicantMap.containsKey(intmsg.RefId__c) && string.isNotBlank(applicantMap.get(intmsg.RefId__c).EmailId__c))?applicantMap.get(intmsg.RefId__c).EmailId__c:'';
                        request.individualName=(string.isNotBlank(intmsg.RefId__c) && applicantMap.containsKey(intmsg.RefId__c) && string.isNotBlank(applicantMap.get(intmsg.RefId__c).FullName__c))?applicantMap.get(intmsg.RefId__c).FullName__c:'';
                        
                        if(string.isNotBlank(intmsg.RefId__c) && applicantMap.containsKey(intmsg.RefId__c) && applicantEmpMap.containsKey(intmsg.RefId__c) &&
                           string.isNotBlank(applicantMap.get(intmsg.RefId__c).Constitution__c) && applicantMap.get(intmsg.RefId__c).Constitution__c=='INDIVIDUAL' &&
                           applicantEmpMap.get(intmsg.RefId__c).EmployerName__c!=null){
                               
                               if(empMap.containsKey(applicantEmpMap.get(intmsg.RefId__c).EmployerName__c) && 
                                  empMap.get(applicantEmpMap.get(intmsg.RefId__c).EmployerName__c).Name!='OTHER'){
                                      
                                      request.organizationName=empMap.get(applicantEmpMap.get(intmsg.RefId__c).EmployerName__c).Name;
                                  }
                               
                               else if(empMap.containsKey(applicantEmpMap.get(intmsg.RefId__c).EmployerName__c) && 
                                       empMap.get(applicantEmpMap.get(intmsg.RefId__c).EmployerName__c).Name=='OTHER'){
                                           
                                           request.organizationName=String.isNotBlank(applicantEmpMap.get(intmsg.RefId__c).Others__c)?applicantEmpMap.get(intmsg.RefId__c).Others__c:'';
                                       }else{
                                           request.organizationName='';
                                       }
                               
                           }
                        
                        else if(string.isNotBlank(intmsg.RefId__c) && applicantMap.containsKey(intmsg.RefId__c) && 
                                string.isNotBlank(applicantMap.get(intmsg.RefId__c).Constitution__c) &&
                                applicantMap.get(intmsg.RefId__c).Constitution__c!='INDIVIDUAL'){
                                    request.organizationName=string.isNotBlank(applicantMap.get(intmsg.RefId__c).CompanyName__c)?applicantMap.get(intmsg.RefId__c).CompanyName__c:'';
                                }
                        
                        request.version=(svc!=null && String.isNotblank(svc.ApiVersion__c))?Integer.valueOf(svc.ApiVersion__c):0;
                        request.consent=(svc!=null && String.isNotblank(svc.StaticKey__c))?svc.StaticKey__c:'';
                        request.clientData=clientdata;
                        
                        
                        IntgMsg__c integrationMessage =new IntgMsg__c();
                        integrationMessage.Id=intmsg.Id;
                        integrationMessage.Req__c=JSON.serialize(request);
                        integrationMessage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                        updateIntMsgRecords.add(integrationMessage);
                        
                    }
                    
                    if(!updateIntMsgRecords.isEmpty()){
                        Update updateIntMsgRecords;
                    }
                }
                
            }catch(Exception ex){
                GlobalUtility.logMessage('Error', 'EmailAuthenticationAdvRequestGenerator class', 
                                         'generate', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
    }
    
}