public class EmpSearchRequestGenerator implements ICalloutRequestGenerator{
    public void generate(List<IntgMsg__c> msgs,String service, String processType) {
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType>{ IntgMsg__c.SObjectType } );
        //Creating a Set of ids
        Set<Id> appEmpIds = new Set<Id>();
        Set<Id> applicantIds = new Set<Id>();
        
        for (IntgMsg__c intMsg : msgs) {
            

            if(String.isnotBlank(intMsg.RefId__c)){
                        appEmpIds.add(intMsg.RefId__c);
              }

            if(String.isnotBlank(intMsg.ParentRefId__c)){
                        applicantIds.add(intMsg.ParentRefId__c);
              }


        }
       
        if(!applicantIds.isempty()){

            Map<Id,ApplicantEmployment__c> applicantEmpMap =new Map<Id,ApplicantEmployment__c>();

            for(ApplicantEmployment__c aem:[Select id,Name ,EmployerName__r.Name,LoanApplicant__r.FullName__c,LoanApplicant__r.MobNumber__c,OfficialEmail__c from ApplicantEmployment__c where ID IN : appEmpIds ORDER BY LastModifiedDate ASC]){
                           
                       applicantEmpMap.put(aem.LoanApplicant__c,aem);                                  
            }



           
        
        try {
            List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>();
            
            if (!msgs.isEmpty()) {
                for (IntgMsg__c intMsg : msgs) {
                    
                    ApplicantEmployment__c eachObjOfEmp=applicantEmpMap.get(intmsg.ParentRefId__c);

                    EmpSearchRequestWrapper empSchObj =new EmpSearchRequestWrapper();

                     
                        empSchObj.employer=eachObjOfEmp.EmployerName__r.Name !=null ? eachObjOfEmp.EmployerName__r.Name : '';
                        empSchObj.name=eachObjOfEmp.LoanApplicant__r.FullName__c  !=null ? eachObjOfEmp.LoanApplicant__r.FullName__c : '';
                        empSchObj.mobile= eachObjOfEmp.LoanApplicant__r.MobNumber__c !=null ? eachObjOfEmp.LoanApplicant__r.MobNumber__c: '';
                        empSchObj.emailId=eachObjOfEmp.OfficialEmail__c !=null ? eachObjOfEmp.OfficialEmail__c : '';
                        empSchObj.consent='Y';//check this for passing
                    
                    EmpSearchRequestWrapper.ClientData cltData = new EmpSearchRequestWrapper.ClientData();
                    cltData.caseId = intMsg.Integration_Message_Number__c;  
                    empSchObj.clientData = cltData;
                    
                    IntgMsg__c intg=New IntgMsg__c();
                    intg.id=intMsg.id;
                    intg.Req__c = JSON.serialize(empSchObj,true); 
                    intg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                    updateIntRecords.add(intg);


                }
                
                if (!updateIntRecords.isEmpty()) {
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Req__c','Status__c' };
                        Schema.SObjectType objType = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType, fieldNamesList);
                    uow.registerDirty(updateIntRecords);
                }
            }
            
            uow.commitWork();
        }
        //Catch bloack to catch Exceptions occured during generation of payload and displaying the passing the same in GlobalUtility class
        catch (Exception ex) {
            System.debug('error' + ex.getMessage());
            GlobalUtility.logMessage('Error','EmpSearchRequestGenerator' + ex.getLineNumber(),'Generate',
                                     null,null,ex.getMessage() + ' Line: ' + ex.getLineNumber(),null,ex,null);
        }

    }
    }

}