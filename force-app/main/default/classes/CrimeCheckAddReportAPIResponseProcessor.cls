public class CrimeCheckAddReportAPIResponseProcessor implements IintMsgCalloutResponseProcessor {
    
    public static void process(List<IntgMsg__c> responses) {
        
        if(!responses.isEmpty()){
            
            Map<IntgMsg__c,String> successResponseMap = new Map<IntgMsg__c,String>();
            Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
            
            
            for(IntgMsg__c intmsg:responses){
                
                if(string.isNotblank(intmsg.Resp__c)){
                    
                    try{
                        
                        CrimeCheckAddReportAPIResponseWrapper res =(CrimeCheckAddReportAPIResponseWrapper) JSON.deserialize(intmsg.Resp__c,CrimeCheckAddReportAPIResponseWrapper.class); 
                        
                        if(res!=null && string.isNotblank(res.status)){
                            
                            if(res.status.toLowerCase()=='ok' && String.isNotblank(res.requestId)){
                                successResponseMap.put(intmsg,res.requestId);
                            }
                            
                        }
                        
                    }catch(Exception ex){
                        GlobalUtility.logMessage('Error', 'CrimeCheckAddReportAPIResponseProcessor class', 
                                                 'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                        failureResponseMap.put(intmsg,intmsg.Resp__c);
                    }
                }
            }
            
            
            if(!successResponseMap.isEmpty()){
                processSuccess(successResponseMap);
            }
            if(!failureResponseMap.isEmpty()){
                processFailure(failureResponseMap);
            }
            
        }
    }
    //*********************************************************************************************************************************************
    public static void processSuccess(Map<IntgMsg__c,String> successResp){
        
        try{
            
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> {APIVer__c.SObjectType});
            
            Set<Id> applicantIds =new Set<Id>();
            List<APIVer__c> APIVerList =new List<APIVer__c>();
            Map<Id,Id> applicantMap =new Map<Id,Id>();
            
            Map<String,APIConfiguration__c> APICrdMap = APIConfiguration__c.getAll();
            
            Id recordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('CrimeCheck').getRecordTypeId();
            
            for(IntgMsg__c intmsg:successResp.keyset()){
                
                if(string.isNotblank(intmsg.RefId__c)){
                    applicantIds.add(intmsg.RefId__c);
                }
            }
            
            //Updating Old Records
            if(!applicantIds.isEmpty()){
                
                List<APIVer__c> apiver =[Select id,Appl__c,RecordType.DeveloperName,IsLatest__c from APIVer__c Where Appl__c IN:applicantIds 
                                         AND RecordType.DeveloperName='CrimeCheck' AND IsLatest__c=true];
                
                if(!apiver.isEmpty()){
                    IntegrationUtility.updateBooleanFlag(apiver, 'IsLatest__c', false);
                }
                
                for(Applicant__c app:[Select id,LoanAppln__c from Applicant__c Where id IN:applicantIds]){
                                      applicantMap.put(app.id,app.LoanAppln__c);
                }
            }
            
            //Creating New API Verification
            for(IntgMsg__c intmsg:successResp.keyset()){
                
                if(String.isNotblank(intmsg.RefId__c)){
                    
                    APIVer__c apiver =new APIVer__c();
                    apiver.Appl__c=intmsg.RefId__c;
                    apiver.LoanAplcn__c=applicantMap.containsKey(apiver.Appl__c)?applicantMap.get(apiver.Appl__c):'';
                    apiver.IsLatest__c=true;
                    apiver.CrimeCheckId__c=successResp.get(intmsg);
                    apiver.RecordTypeId=recordTypeId;
                    apiver.ReportMode__c=(String.isNotblank(intmsg.TriggerType__c) && intmsg.TriggerType__c=='System')?APICrdMap.get('Crime Check').Mode__c:'';
                    apiver.CrimeCheckAddReportStatus__c='Success';
                    APIVerList.add(apiver);
                }
                APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Success');
            }
            
            //Creating the APIVer__c
            if(!APIVerList.isEmpty()) {
                String sObjectName = 'APIVer__c';
                List<String> fieldNamesList = new List<String>{'Appl__c','ReportMode__c','LoanAplcn__c','IsLatest__c','CrimeCheckId__c','RecordTypeId','CrimeCheckAddReportStatus__c'};
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerNew(APIVerList);
                
            }
            uow.commitWork();
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrimeCheckAddReportAPIResponseProcessor', 
                                     'processSuccess', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            
        }
        
    }
    
    //*********************************************************************************************************************************************
    public static void processFailure( Map<IntgMsg__c,String> failureResp){
        
        try{
            
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> {APIVer__c.SObjectType});
            
            Set<Id> applicantIds =new Set<Id>();
            List<APIVer__c> APIVerList =new List<APIVer__c>();
            Map<Id,Id> applicantMap =new Map<Id,Id>();
            
            Id recordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('CrimeCheck').getRecordTypeId();
            
            
            for(IntgMsg__c intmsg:failureResp.keyset()){
                
                if(string.isNotblank(intmsg.RefId__c)){
                    applicantIds.add(intmsg.RefId__c);
                }
            }
            
            //Updating Old Records
            if(!applicantIds.isEmpty()){
                
                List<APIVer__c> apiver =[Select id,Appl__c,RecordType.DeveloperName,IsLatest__c from APIVer__c Where Appl__c IN:applicantIds 
                                         AND RecordType.DeveloperName='CrimeCheck' AND IsLatest__c=true];
                
                if(!apiver.isEmpty()){
                    IntegrationUtility.updateBooleanFlag(apiver, 'IsLatest__c', false);
                }
                
                for(Applicant__c app:[Select id,LoanAppln__c from Applicant__c Where id IN:applicantIds]){
                                      applicantMap.put(app.id,app.LoanAppln__c);
                }
            }
            
            //Creating New API Verification
            for(IntgMsg__c intmsg:failureResp.keyset()){
                
                if(String.isNotblank(intmsg.RefId__c)){
                    
                    APIVer__c apiver =new APIVer__c();
                    apiver.Appl__c=intmsg.RefId__c;
                    apiver.LoanAplcn__c=applicantMap.containsKey(apiver.Appl__c)?applicantMap.get(apiver.Appl__c):'';
                    apiver.IsLatest__c=true;
                    apiver.CrimeCheckAddReportError__c=failureResp.get(intmsg);
                    apiver.RecordTypeId=recordTypeId;
                    apiver.CrimeCheckAddReportStatus__c='Failure';
                    APIVerList.add(apiver);
                }
                APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Failure');
            }
            
            //Creating the APIVer__c
            if(!APIVerList.isEmpty()) {
                String sObjectName = 'APIVer__c';
                List<String> fieldNamesList = new List<String>{'Appl__c','LoanAplcn__c','IsLatest__c','CrimeCheckAddReportError__c','RecordTypeId','CrimeCheckAddReportStatus__c'};
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerNew(APIVerList);
                
            }
            uow.commitWork();
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrimeCheckAddReportAPIResponseProcessor', 
                                     'processFailure', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            
        }
    }    
}