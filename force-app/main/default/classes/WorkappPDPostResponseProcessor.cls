public class WorkappPDPostResponseProcessor implements IintMsgCalloutResponseProcessor{
    
        public static void process(List<IntgMsg__c> responses){
            if(!responses.isEmpty()){
                for(IntgMsg__c intmsg:responses){
                    try{ 
                        if(String.isnotBlank(intmsg.Resp__c)){

                            if (intmsg.Svc__c != GlobalConstants.INT_CONFIG_SERVICE_WORKAPPS_POST_API_SERVICE
                            && intmsg.BU__c != GlobalConstants.INT_MSG_BU_TYPE) {
                            throw new processException('Error! This is not the correct service');
                            }
                            
                            WorkappPDPostResponseWrapper  res =(WorkappPDPostResponseWrapper) JSON.deserialize(intmsg.Resp__c,WorkappPDPostResponseWrapper.class);
                            //Success
                            if(res.scpUrl !=null && res.redirectUrl!=null && res.groupId !=null){ 
                                processSuccess(res,intmsg.RefId__c,intmsg.ParentRefId__c);
                                APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Success');
                            }
                            //Failure
                            else{
                                //{"code":1226,"message":"user data : key and value passed must be non-empty"}
                                processFailure(res.message,intmsg.RefId__c,intmsg.ParentRefId__c);
                                APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Failure');
                            }
                        }
                    } 
                    catch(Exception ex){
                        GlobalUtility.logMessage('Error', 'WorkappPDPostResponse Processor class', 
                                                 'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                        
                        String errorMessage ='';
                        String error = ex.getMessage().substringBefore(':');
                        if(error!=null && String.isNotBlank(error)){
                            if(error.containsIgnoreCase('Unexpected character')){
                                errorMessage = 'API Internal Server Error';
                            } 
                            else if(error.containsIgnoreCase('Illegal unquoted character')){
                                errorMessage = 'An error occurred due to a special character in the response';
                            }
                            else {
                                errorMessage = 'An unexpected error has occurred';
                            }
                        }
                        else{
                            errorMessage = 'An unexpected error has occurred';
                        }
                        
                        processFailure(errorMessage,intmsg.RefId__c,intmsg.ParentRefId__c);
                        APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Failure');
                    }
                }
            }
        }
        
        
        public static void processSuccess(WorkappPDPostResponseWrapper  res,string refId,string parRefId){
            
            try{
                if(res!=null && String.isNotBlank(refId)){
                    List<SObject> recordsToUpdate = new List<SObject>();
                    PD__c pdObj = [SELECT Id,WorkAppScpUrl__c,WorkAppRedirectionUrl__c,WorkAppVideoPdId__c from PD__c Where Id =:refId];//query out side lop
                        if(pdObj!=null){
                           pdObj = (PD__c)updateSobject(res, pdObj, 'PD__c');
                            if(pdObj!=null){
                                recordsToUpdate.add(pdObj); 
                            }
                        }
                    
                if(recordsToUpdate!=null && !recordsToUpdate.isEmpty()){
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {PD__c.SObjectType}); 
                    String sObjectName = 'PD__c';
                    List<String> fieldNamesList = new List<String>{'WorkAppVideoPdPostError__c','WorkAppVideoPdGetStatus__c','WorkAppRedirectionUrl__c','WorkAppScpUrl__c','WorkAppVideoPdId__c','WorkAppVideoPdPostStatus__c'};   
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(recordsToUpdate);
                    uow.commitWork();
                }
                }
            }
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'WorkappPDPostResponseProcessor', 
                                         'processSuccess', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                
            }
            
        } 
    
         public static void processFailure(String errormessage,Id refId,Id parentRefId){
            try{
                
                List<PD__c> pdObjList=new List<PD__c>();
                
                if(refId!=null && String.isNotBlank(errormessage)){
                    
                    PD__c pdEach =new PD__c();
                    pdEach.Id=refId;
                    pdEach.WorkAppVideoPdPostError__c=errormessage;
                    pdEach.WorkAppVideoPdPostStatus__c='Failure';
                    pdObjList.add(pdEach);
                }
                if(!pdObjList.isEmpty()) {
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {PD__c.SObjectType}); 
                    String sObjectName = 'PD__c';
                    List<String> fieldNamesList = new List<String>{'WorkAppVideoPdPostError__c','WorkAppVideoPdPostStatus__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(pdObjList);
                    uow.commitWork();
                }
                
            }catch (Exception ex) {
                GlobalUtility.logMessage('Error', 'WorkappPDPostResponse Processor', 
                                         'processFailure', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
        
        
        public static SObject updateSobject(WorkappPDPostResponseWrapper res, SObject recordToUpdate, String objectAPIName) {
            try {
                if (res != null && recordToUpdate != null && String.isNotBlank(objectAPIName)) {
                    if(objectAPIName=='PD__c'){
                        recordToUpdate.put('WorkAppRedirectionUrl__c', res.redirectUrl!=null ? res.redirectUrl :'' );  
                        recordToUpdate.put('WorkAppScpUrl__c', res.scpUrl !=null ? res.scpUrl : '');
                        recordToUpdate.put('WorkAppVideoPdId__c', res.groupId !=null ? String.valueOf(res.groupId) : '');
                        recordToUpdate.put('WorkAppVideoPdPostStatus__c','Success');
                    }
                    return recordToUpdate;
                }
            } catch (Exception ex) {
                GlobalUtility.logMessage('Error', 'WorkappPDPostResponse Processor', 
                                         'updateSobject', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
            return null; 
        }
    
    }