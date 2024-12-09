public class EPFOLookUpResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    public static void process(List<IntgMsg__c> responses) {
        
        if(!responses.isEmpty()){
            
            Map<IntgMsg__c,EPFOLookUpResponseWrapper> successResponseMap = new Map<IntgMsg__c,EPFOLookUpResponseWrapper>();
            Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
            
            
            for(IntgMsg__c intmsg:responses){
                
                if(string.isNotblank(intmsg.Resp__c)){
                    
                    try{
                        
                        EPFOLookUpResponseWrapper  res =(EPFOLookUpResponseWrapper) JSON.deserialize(intmsg.Resp__c.replace('status-code','statuscode'),EPFOLookUpResponseWrapper.class);
                        
                        
                        //Success
                        if(Integer.valueof(res.statuscode) ==GlobalConstants.karza_Status_101){//101
                            successResponseMap.put(intmsg,res);
                        }
                        
                        //Failure
                        else if(Integer.valueof(res.statuscode) !=GlobalConstants.karza_Status_101){
                            failureResponseMap.put(intmsg,GlobalConstants.karza_Status_Code_Authn_Description.ContainsKey(Integer.valueof(res.statuscode))?GlobalConstants.karza_Status_Code_Authn_Description.get(Integer.valueof(res.statuscode)):'');
                        }
                        
                    }catch(Exception ex){
                        GlobalUtility.logMessage('Error', 'EPFOLookUpResponseProcessor class', 
                                                 'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                        failureResponseMap.put(intmsg,IntegrationUtility.getCustomErrorMessage(ex.getMessage().substringBefore(':')));
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
    
    //***************************************************************************************************************************************
    public static void processSuccess(Map<IntgMsg__c,EPFOLookUpResponseWrapper> successResp){
        
        try{
            
            Set<Id> applicantIds =new Set<Id>();
            Map<Id,Applicant__c> applicantMap;
            List<APIVer__c> apiVerList =new List<APIVer__c>();
            List<IntgMsg__c> intgMsgList =new List<IntgMsg__c>();
            
            Id recordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Employment').getRecordTypeId();
            
            for(IntgMsg__c intmsg:successResp.keyset()){
                
                if(String.isNotblank(intmsg.RefId__c)){
                    applicantIds.add(intmsg.RefId__c);
                }
            }
            
            if(!applicantIds.isEmpty()){
                
                applicantMap=new Map<Id,Applicant__c>([Select Id,LoanAppln__c from Applicant__c Where Id IN:applicantIds]);
                
                
                //Making Islatest False
                List<APIVer__c>  apiver =[Select Id,IsLatest__c,RecordType.DeveloperName from APIVer__c Where RecordType.DeveloperName='Employment'
                                          AND Appl__c IN:applicantIds AND IsLatest__c=True];
                
                if(!apiver.isEmpty()){
                    IntegrationUtility.updateBooleanFlag(apiver,'IsLatest__c',false);
                }
            }
            
            
            
            //Processing the Response
            for(IntgMsg__c intmsg:successResp.keyset()){
                
                if(String.isNotblank(intmsg.RefId__c) && applicantMap.containsKey(intmsg.RefId__c)){
                    
                    EPFOLookUpResponseWrapper resp =successResp.get(intmsg);
                    
                    if(resp!=null && resp.result!=null && resp.result.uan!=null){
                        
                        
                        for(String uanNumber:resp.result.uan){
                            
                            APIVer__c apiver =new APIVer__c();
                            apiver.Appl__c=applicantMap.get(intmsg.RefId__c).Id;
                            apiver.LoanAplcn__c=String.isNotblank(applicantMap.get(intmsg.RefId__c).LoanAppln__c)?applicantMap.get(intmsg.RefId__c).LoanAppln__c:'';
                            apiver.IsLatest__c=true;
                            apiver.RecordTypeId=recordTypeId;
                            apiver.Uan__c=uanNumber;
                            apiver.EPFOLookUpStatus__c='Success';
                            apiVerList.add(apiver);
                            
                            IntgMsg__c msg =new IntgMsg__c();
                            msg.Name='EPF UAN Validation';
                            msg.BU__c='HL / STL';
                            msg.Status__c='New';
                            msg.MStatus__c='Blank';
                            msg.Svc__c='EPF UAN Validation';
                            msg.IsActive__c=true;
                            msg.RefId__c=intmsg.RefId__c;
                            msg.RefObj__c=intmsg.RefObj__c;
                            msg.ParentRefId__c=uanNumber;
                            intgMsgList.add(msg);
                        }
                    }
                }
                
                APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Success');
            }
            
            
            if(!apiVerList.isEmpty()){
                Insert apiVerList;
            }
            
            if(!intgMsgList.isEmpty()){
                Insert intgMsgList;
            }
            
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'EPFOLookUpResponseProcessor', 
                                     'processSuccess', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            
        }
    }
    
    //***************************************************************************************************************************************
    public static void processFailure(Map<IntgMsg__c,String> failureResp){
        
        try{
            
            Set<Id> applicantIds =new Set<Id>();
            Map<Id,Applicant__c> applicantMap;
            List<APIVer__c> apiVerList =new List<APIVer__c>();
            
            
            Id recordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Employment').getRecordTypeId();
            
            for(IntgMsg__c intmsg:failureResp.keyset()){
                
                if(String.isNotblank(intmsg.RefId__c)){
                    applicantIds.add(intmsg.RefId__c);
                }
            }
            
            
            if(!applicantIds.isEmpty()){
                
                applicantMap=new Map<Id,Applicant__c>([Select Id,LoanAppln__c from Applicant__c Where Id IN:applicantIds]);
                
                
                //Making Islatest False
                List<APIVer__c>  apiver =[Select Id,IsLatest__c,RecordType.DeveloperName from APIVer__c Where RecordType.DeveloperName='Employment'
                                          AND Appl__c IN:applicantIds AND IsLatest__c=True];
                
                if(!apiver.isEmpty()){
                    IntegrationUtility.updateBooleanFlag(apiver,'IsLatest__c',false);
                }
            }
            
            //Processing the Response
            for(IntgMsg__c intmsg:failureResp.keyset()){
                
                APIVer__c apiver =new APIVer__c();
                apiver.Appl__c=applicantMap.get(intmsg.RefId__c).Id;
                apiver.LoanAplcn__c=String.isNotblank(applicantMap.get(intmsg.RefId__c).LoanAppln__c)?applicantMap.get(intmsg.RefId__c).LoanAppln__c:'';
                apiver.IsLatest__c=true;
                apiver.RecordTypeId=recordTypeId;
                apiver.EPFOLookUpStatus__c='Failure';
                apiver.IntegrationErrorMessage__c=failureResp.get(intmsg);
                apiVerList.add(apiver);
                
                APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Failure');
                
            }
            
            if(!apiVerList.isEmpty()){
                Insert apiVerList;
            }
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'EPFOLookUpResponseProcessor', 
                                     'processFailure', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            
        }
    }
}