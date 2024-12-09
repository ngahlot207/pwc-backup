public class ScreeningWachoutResponseProcessor implements IintMsgCalloutResponseProcessor {
    
    public static void process(List<IntgMsg__c> responses) {
        System.debug('ScreeningWachoutResponseProcessor start');
        try {
            if (responses != null && !responses.isEmpty()) {
                String jsonResponse = responses[0].Resp__c.unescapeJava().replace(':"{',':{').replace('}"}','}}');
                
                String jsonResponseToProcess = jsonResponse.replaceAll('(\\r|\\n|\\t)', '');
                String jsonString = '{"WotJsonResult":""}';
                
                if (!String.isBlank(jsonResponseToProcess) && jsonResponseToProcess!=jsonString) {
                    
                    ScreeningWachoutResponseWrapper res = (ScreeningWachoutResponseWrapper) JSON.deserialize(jsonResponseToProcess, ScreeningWachoutResponseWrapper.class);
                    
                    if (res != null && res.WotJsonResult.Table != null && !res.WotJsonResult.Table.isEmpty()) {
                        ScreeningSuccess(res,responses[0].RefId__c);
                        
                        if(responses[0].Trigger_Platform_Event__c){
                            publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                            platformWra.intId = responses[0].Id; 
                            platformWra.recId = responses[0].RefId__c;
                            platformWra.ServiceName = responses[0].Svc__c ;
                            platformWra.Status = responses[0].Status__c ;
                            platformWra.success=true;
                            publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                        } 
                    }
                    
                    APICalloutTracker.update_ApiTrackerWithIntMsg(responses[0].Id,responses[0].Svc__c, responses[0].RefId__c, 'Success');
                    
                }
                
                if(responses[0].Resp__c==jsonString){
                    ScreeningEmpty(responses[0].RefId__c);
                    APICalloutTracker.update_ApiTrackerWithIntMsg(responses[0].Id,responses[0].Svc__c, responses[0].RefId__c, 'Success');
                }
            }
        } catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'ScreeningWachoutResponseProcessor class', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
 //*******************************************************************************************************************************************
    public Static Void ScreeningSuccess(ScreeningWachoutResponseWrapper res,Id refid){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { APIVer__c.SObjectType });
        
        List<APIVer__c> existingWoutInvsList = [Select Id,IsLatest__c,Appl__c,RecordType.Name FROM APIVer__c WHERE IsLatest__c=True AND Appl__c=:refid AND RecordType.Name='Watchout'];
        
        if(!existingWoutInvsList.isEmpty()){
            IsLatestFalse(existingWoutInvsList);
        }
        
        try{
            if(res!=null && refid!=null ){
                List<Applicant__c> applist=[Select Id,FullName__c,ApplType__c,Constitution__c,CompanyName__c,LoanAppln__c from Applicant__c Where Id=:refid];
                
                Id APIVerRecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Watchout').getRecordTypeId();
               
                List<APIVer__c> APIVerList = new List<APIVer__c>();
                
                for(ScreeningWachoutResponseWrapper.table tab:res.WotJsonResult.Table){
                    
                    APIVer__c apiVer =new APIVer__c();
                    
                    apiVer.Appl__c=refid!=null?refid:'';
                    apiVer.LoanAplcn__c=applist[0].LoanAppln__c!=null?applist[0].LoanAppln__c:'';
                    apiVer.IsLatest__c=true;
                    apiver.IntegrationStatus__c='Success';
                    apiver.WatchoutInvestor__c=true;
                    apiver.ApplNme__c=applist[0].Constitution__c=='INDIVIDUAL'?applist[0].FullName__c:applist[0].CompanyName__c;
                    apiver.ApplTyp__c=applist[0].ApplType__c!=null?applist[0].ApplType__c:'';
                    apiver.RecordTypeId=APIVerRecordTypeId;
                    
                    
                    if(!string.isblank(tab.Record_ID)){
                        apiVer.RecId__c=tab.Record_ID;
                    }
                    
                    if(!string.isblank(tab.Regulator_Competent_Authority_Name)){
                        apiVer.RegCompAuthName__c=tab.Regulator_Competent_Authority_Name;
                    }
                    if(!string.isblank(tab.Order_Date)){
                        String dateString = tab.Order_Date;//31-jul-1998
                        
                        List<String> dateParts = dateString.split('-');
                        Integer day = Integer.valueOf(dateParts[0]);
                        String monthStr = dateParts[1];
                        Integer year = Integer.valueOf(dateParts[2]);
                        
                        
                        Map<String, Integer> monthMap = new Map<String, Integer>{
                            'Jan' => 1, 'Feb' => 2, 'Mar' => 3, 'Apr' => 4, 'May' => 5, 'Jun' => 6,
                                'Jul' => 7, 'Aug' => 8, 'Sep' => 9, 'Oct' => 10, 'Nov' => 11, 'Dec' => 12
                                };
                                    Integer month = monthMap.get(monthStr);
                        Date parsedDate = Date.newInstance(year, month, day);
                        apiVer.OdrDt__c=parsedDate;
                    }
                    
                    if(!string.isblank(tab.Defaulter_Code)){
                        apiVer.DefCode__c = tab.Defaulter_Code;
                    }
                    
                    if(!string.isblank(tab.Defaulter_Name)){
                        apiVer.DefName__c = tab.Defaulter_Name;
                    }
                    
                    if(!string.isblank(tab.Defaulter_Type_Company_Person)){
                        apiVer.DefTypCmpyPrsn__c = tab.Defaulter_Type_Company_Person;
                    }
                    
                    if(!string.isblank(tab.Defaulter_New_Name1)){
                        apiVer.DefNewNme1__c = tab.Defaulter_New_Name1;
                    }
                    
                    if(!string.isblank(tab.Defaulter_Old_Name1)){
                        apiVer.DefOldNme1__c = tab.Defaulter_Old_Name1;
                    }
                    
                    if(!string.isblank(tab.Defaulter_Merged_With)){
                        apiVer.DefMrgWth__c = tab.Defaulter_Merged_With;
                    }
                    
                    if(!string.isblank(tab.PAN_CIN_DIN)){
                        apiVer.PanCinDin__c = tab.PAN_CIN_DIN;
                    }
                    
                    if(!string.isblank(tab.Defaulter_Other_Details)){
                        apiVer.DefOthrDtls__c = tab.Defaulter_Other_Details;
                    }
                    
                    if(!string.isblank(tab.Not_Defaulter_Infact_Associated_Entity)){
                        apiVer.OthrEntAssosWthDefEnt__c = tab.Not_Defaulter_Infact_Associated_Entity;
                    }
                    
                    if(!string.isblank(tab.Alongwith)){
                        apiVer.Alongwth__c = tab.Alongwith;
                    }
                    
                    if(!string.isblank(tab.Associated_Entity_Person)){
                        apiVer.AssocEntPrsn__c = tab.Associated_Entity_Person;
                    }
                    
                    if(!string.isblank(tab.Regulatory_Charges)){
                        apiVer.RegChngs__c = tab.Regulatory_Charges;
                    }
                    
                    if(!string.isblank(tab.Regulatory_Actions)){
                        apiVer.RegActns__c = tab.Regulatory_Actions;
                    }
                    
                    if(!string.isblank(tab.Regulatory_Action_Source1)){
                        apiVer.RegActnSrc1__c = tab.Regulatory_Action_Source1;
                    }
                    
                    if(!string.isblank(tab.Regulatory_Action_Source2)){
                        apiVer.RegActnsSrc2__c = tab.Regulatory_Action_Source2;
                    }
                    
                    if(!string.isblank(tab.Regulatory_Action_Source3)){
                        apiVer.RegActnsSrc3__c = tab.Regulatory_Action_Source3;
                    }
                    APIVerList.add(apiVer);
                }
              
               
                if(APIVerList!=null){
                    List<string> fieldNamesList = New List<string>{'Appl__c','LoanAplcn__c','RecId__c','RegCompAuthName__c','OdrDt__c','DefCode__c','IntegrationStatus__c',
                                                                   'DefName__c','DefTypCmpyPrsn__c','DefNewNme1__c','DefOldNme1__c','DefMrgWth__c','PanCinDin__c',
                                                                    'DefOthrDtls__c','OthrEntAssosWthDefEnt__c','Alongwth__c','AssocEntPrsn__c','RegChngs__c','RegActns__c',
                                                                       'RegActnSrc1__c','RegActnsSrc2__c','RegActnsSrc3__c','WatchoutInvestor__c','IsLatest__c'};
                     String sObjectName = 'APIVer__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(APIVerList);
                }
                uow.commitWork();
                
            }
            
        }
        catch(Exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }
    }   
    
    
    
    //*************************************************************************************************************************88
    public static Void ScreeningEmpty(Id refid){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { APIVer__c.SObjectType });
        
        List<APIVer__c> existingWoutInvsList = [Select Id,IsLatest__c,Appl__c,RecordType.Name FROM APIVer__c WHERE IsLatest__c=True AND Appl__c=:refid AND RecordType.Name='Watchout'];
        
        if(!existingWoutInvsList.isEmpty()){
            IsLatestFalse(existingWoutInvsList);
        }
        
        try{
            if(refid!=null){
                List<Applicant__c> applist=[Select Id,FullName__c,Constitution__c,CompanyName__c,ApplType__c,LoanAppln__c from Applicant__c Where Id=:refid];
                
                Id APIVerRecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Watchout').getRecordTypeId();
                List<APIVer__c> APIVerList = new List<APIVer__c>();
              
                APIVer__c apiVer =new APIVer__c();
                
                apiVer.Appl__c=refid!=null?refid:'';
                apiVer.LoanAplcn__c=applist[0].LoanAppln__c!=null?applist[0].LoanAppln__c:'';
                apiVer.IsLatest__c=true;
                apiver.IntegrationStatus__c='Success';
                apiver.RecordTypeId=APIVerRecordTypeId;
                apiver.ApplNme__c=applist[0].Constitution__c=='INDIVIDUAL'?applist[0].FullName__c:applist[0].CompanyName__c;
                apiver.ApplTyp__c=applist[0].ApplType__c!=null?applist[0].ApplType__c:'';
                APIVerList.add(apiver);
                
                 if(APIVerList!=null){
                    List<string> fieldNamesList = New List<string>{'Appl__c','LoanAplcn__c','IsLatest__c','RecordTypeId','ApplNme__c','ApplTyp__c','IntegrationStatus__c'};
                     String sObjectName = 'APIVer__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(APIVerList);
                }
                uow.commitWork();
                
            }
            
        }catch(Exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }
        
        
    }
//*********************************************************************************************************************************
    public static void IsLatestFalse(List<APIVer__c> responses){
        if(!responses.isEmpty()){
            for(APIVer__c res : responses){
                res.IsLatest__c=false;
            }
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { APIVer__c.SObjectType });
            List<string> fieldNamesList = New List<string>{'IsLatest__c'};
                String sObjectName = 'APIVer__c';
            Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
            fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
            uow.registerDirty(responses);
            uow.commitWork();
        }
    }        
    
}