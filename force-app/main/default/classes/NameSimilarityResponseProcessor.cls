public class NameSimilarityResponseProcessor implements IintMsgCalloutResponseProcessor{

    public static void process(List<IntgMsg__c> responses){ 
         if(!responses.isEmpty()){
            for(IntgMsg__c intmsg:responses){
                    try{ 
                    if(String.isnotBlank(intmsg.Resp__c)){
                        NameSimilarityResponseWrapper  res =(NameSimilarityResponseWrapper) JSON.deserialize(intmsg.Resp__c,NameSimilarityResponseWrapper.class);
                        //Success
                        
                        if(res.statusCode ==GlobalConstants.karza_Status_101){
                            processSuccess(res,intmsg.RefId__c,intmsg.ParentRefId__c,intmsg.RefObj__c);
                            APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Success');
                        }
                        else if(res.statusCode !=GlobalConstants.karza_Status_101){
                            string errormes=GlobalConstants.karza_Status_Code_Authn_Description.ContainsKey(res.statusCode)?GlobalConstants.karza_Status_Code_Authn_Description.get(res.statusCode):'';
                            processFailure(errormes,intmsg.RefId__c,intmsg.ParentRefId__c,intmsg.RefObj__c);
                            APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Failure');
                        }
                    }
                }
                catch(Exception ex){
                    GlobalUtility.logMessage('Error', 'NameSimilarityResponseProcessor class', 
                                             'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                } 

            }
            
        }
    }   
    
    public static void processSuccess(NameSimilarityResponseWrapper  res,string childObjId,string appId ,String childObjType ){
        try{
            if(res!=null || String.isNotBlank(childObjId) || String.isNotBlank(appId)){
                
                List<SObject> recordsToUpdate = new List<SObject>();
                
                if(String.isNotBlank(childObjId)){
                    
                    if(childObjType =='ApplKyc__c'){
                    ApplKyc__c appKyc = [SELECT Id,Name__c from ApplKyc__c Where Id =:childObjId];
                    if(appKyc!=null){
                        appKyc = (ApplKyc__c)updateSobject(res, appKyc, 'ApplKyc__c');
                        
                        if(appKyc!=null){
                            recordsToUpdate.add(appKyc); 
                        }
                    }
                    }
                    else if(childObjType =='ApplBanking__c'){
                    ApplBanking__c appBankObj = [SELECT Id from ApplBanking__c Where Id =:childObjId];
                    if(appBankObj!=null){
                        appBankObj = (ApplBanking__c)updateSobject(res, appBankObj, 'ApplBanking__c');
                        
                        if(appBankObj!=null){
                            recordsToUpdate.add(appBankObj); 
                        }
                    }
                    }
                    else if(childObjType =='APIVer__c'){  
                    APIVer__c apiVerObj = [SELECT Id,Name__c from APIVer__c Where Id =:childObjId];
                    if(apiVerObj!=null){
                        apiVerObj = (APIVer__c)updateSobject(res, apiVerObj, 'APIVer__c');
                        
                        if(apiVerObj!=null){
                            recordsToUpdate.add(apiVerObj); 
                        }
                    }
                    }
                }
                
                if(recordsToUpdate!=null && !recordsToUpdate.isEmpty()){
                    System.debug('Updating records');
                    update recordsToUpdate;
                }

            }
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'NameSimilarityResponseProcessor', 
                                     'processSuccess', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            
        }
    }

    public static void processFailure(String errormessage,Id childId,Id applicantId  ,String childObjType){
        try{
            System.debug('inside processFailure');
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> {ApplKyc__c.SObjectType,ApplBanking__c.SObjectType,APIVer__c.SObjectType,ApplGST__c.SObjectType,Applicant_Financial__c.SObjectType });   
            
            List<ApplKyc__c> appKycList=new List<ApplKyc__c>();
            List<ApplBanking__c> applBankList=new List<ApplBanking__c>();
            List<APIVer__c> applVerList=new List<APIVer__c>();
            List<ApplGST__c> applGstList=new List<ApplGST__c>();
            List<Applicant_Financial__c> applFinList=new List<Applicant_Financial__c>();
            
            
            //Updating Applicant Kyc Record
            if(childId!=null && String.isNotBlank(errormessage) && childObjType =='ApplKyc__c'){
                
                ApplKyc__c kyc =new ApplKyc__c();
                kyc.Id=childId;
                kyc.Name_Match_API_Error_Msg__c=errormessage;
                kyc.NameMatchAPIStatus__c='Failure';

                System.debug('Kyc obj ::'+appKycList);
                appKycList.add(kyc);
            }

            if(childId!=null && String.isNotBlank(errormessage) && childObjType =='ApplBanking__c'){
                
                ApplBanking__c appBankOb =new ApplBanking__c();
                appBankOb.Id=childId;
                appBankOb.Name_Match_API_Error_Msg__c=errormessage;
                appBankOb.NameMatchAPIStatus__c='Failure';
                applBankList.add(appBankOb);
            }

            if(childId!=null && String.isNotBlank(errormessage) && childObjType =='APIVer__c'){
                
                APIVer__c appVerOb =new APIVer__c();
                appVerOb.Id=childId;
                appVerOb.Name_Match_API_Error_Msg__c=errormessage;
                appVerOb.NameMatchAPIStatus__c='Failure';
                applVerList.add(appVerOb);
            }
            
            //
            if(childId!=null && String.isNotBlank(errormessage) && childObjType =='ApplGST__c'){
                
                ApplGST__c appGstOb =new ApplGST__c();
                appGstOb.Id=childId;
                appGstOb.Name_Match_API_Error_Msg__c=errormessage;
                appGstOb.NameMatchAPIStatus__c='Failure';
                applGstList.add(appGstOb);
            }

            if(childId!=null && String.isNotBlank(errormessage) && childObjType =='Applicant_Financial__c'){
                /*
                Applicant_Financial__c appFinOb =new Applicant_Financial__c();
                appFinOb.Id=childId;
                appFinOb.Name_Match_API_Error_Msg__c=errormessage;
                appFinOb.NameMatchAPIStatus__c='Failure';
                applFinList.add(appFinOb);
                */
            }
            //
            
            
            if(!appKycList.isEmpty()) {
                String sObjectName = 'ApplKyc__c';
                List<String> fieldNamesList = new List<String>{'Name_Match_API_Error_Msg__c','NameMatchAPIStatus__c'};
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(appKycList);
            }

            if(!applBankList.isEmpty()) {
                String sObjectName = 'ApplBanking__c';
                List<String> fieldNamesList = new List<String>{'Name_Match_API_Error_Msg__c','NameMatchAPIStatus__c'};
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(applBankList);
            }

            if(!applVerList.isEmpty()) {
                String sObjectName = 'APIVer__c';
                List<String> fieldNamesList = new List<String>{'Name_Match_API_Error_Msg__c','NameMatchAPIStatus__c'};
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(applVerList);
            }

            //
            if(!applGstList.isEmpty()) {
                String sObjectName = 'ApplGST__c';
                List<String> fieldNamesList = new List<String>{'Name_Match_API_Error_Msg__c','NameMatchAPIStatus__c'};
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(applGstList);
            }

            if(!applFinList.isEmpty()) {
                /*
                String sObjectName = 'Applicant_Financial__c';
                List<String> fieldNamesList = new List<String>{'Name_Match_API_Error_Msg__c','NameMatchAPIStatus__c'};
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(applFinList);
                */
            }
            //
            uow.commitWork();
        }catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'NameSimilarityResponseProcessor', 
                                     'processFailure', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }

    public static SObject updateSobject(NameSimilarityResponseWrapper res, SObject recordToUpdate, String objectAPIName) {
        
        try {
            if (res != null && recordToUpdate != null && String.isNotBlank(objectAPIName)) {
                if(objectAPIName=='ApplKyc__c'){
                    
                    Double strNum = Double.valueOf(res.result.score);
                    strNum = strNum * 100;
                    Decimal decimalNum = Decimal.valueOf(strNum);
                    Decimal finalResult = decimalNum.setScale(2, RoundingMode.HALF_UP); 
                    System.debug(finalResult);//76.79   

                    recordToUpdate.put('Name_Match_API_Error_Msg__c','');
                    recordToUpdate.put('Name_Match_Score__c',finalResult);
                    recordToUpdate.put('NameMatchAPIStatus__c','Success');
                }
                if(objectAPIName=='ApplBanking__c'){
                     Double strNum = Double.valueOf(res.result.score);
                    strNum = strNum * 100;
                    Decimal decimalNum = Decimal.valueOf(strNum);
                    Decimal finalResult = decimalNum.setScale(2, RoundingMode.HALF_UP);
                    System.debug(finalResult);//76.79   

                    recordToUpdate.put('Name_Match_API_Error_Msg__c','');
                    recordToUpdate.put('Name_Match_Score__c',finalResult);
                    recordToUpdate.put('NameMatchAPIStatus__c','Success');
                }
                if(objectAPIName=='APIVer__c'){
                    Double strNum = Double.valueOf(res.result.score);
                    strNum = strNum * 100;
                    Decimal decimalNum = Decimal.valueOf(strNum);
                    Decimal finalResult = decimalNum.setScale(2, RoundingMode.HALF_UP);
                    System.debug(finalResult);//76.79   

                    recordToUpdate.put('Name_Match_API_Error_Msg__c','');
                    recordToUpdate.put('Name_Match_Score__c',finalResult);
                    recordToUpdate.put('NameMatchAPIStatus__c','Success');
                }

                if(objectAPIName=='ApplGST__c'){
                    Double strNum = Double.valueOf(res.result.score);
                    strNum = strNum * 100;
                    Decimal decimalNum = Decimal.valueOf(strNum);
                    Decimal finalResult = decimalNum.setScale(2, RoundingMode.HALF_UP);
                    System.debug(finalResult);//76.79   

                    recordToUpdate.put('Name_Match_API_Error_Msg__c','');
                    recordToUpdate.put('Name_Match_Score__c',finalResult);
                    recordToUpdate.put('NameMatchAPIStatus__c','Success');
                }

                if(objectAPIName=='Applicant_Financial__c'){
                    //Not Required for now 
                }
                System.debug('Returning rec as :'+recordToUpdate);
                return recordToUpdate;
            }

            }
            catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'NameSimilarityResponseProcessor', 
                                     'updateSobject', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        return null; 

    }

}