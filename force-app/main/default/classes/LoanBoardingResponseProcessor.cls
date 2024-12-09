public class LoanBoardingResponseProcessor implements IintMsgCalloutResponseProcessor{
 
    //Implementing the process method
    public static void process(List<IntgMsg__c> responses){ 
        System.debug('LoanBoardingResponseProcessor called ');
        //Processing all responses
        for(IntgMsg__c integrationMessage : responses){
            if(integrationMessage.Svc__c != GlobalConstants.INT_CONFIG_SERVICE_LOAN_BOARDING_API_SERVICE
               && integrationMessage.BU__c != GlobalConstants.INT_MSG_BU_TYPE){
                   throw new processException('Error! This is not the correct service'); 
               }
            try{
                //parse response
                LoanBoardingResponseWrapper responseWrapper = (LoanBoardingResponseWrapper) JSON.deserialize(integrationMessage.Resp__c, LoanBoardingResponseWrapper.class); 
                Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(integrationMessage.Resp__c);
                //check if responseWrapper is empty or not
                if(responseWrapper != null){
                    //Note : Waiting for fields Information which need to be updated 
                    system.debug('responseWrapper '+ responseWrapper);
                   
                   
                    System.debug('integrationMessage Ref ID::'+integrationMessage.RefId__c);
                    List<Applicant__c> listOfAppl =[Select Id,name from Applicant__c where LoanAppln__c =: integrationMessage.RefId__c];
                    
                        updateLoanApplicationStatus(integrationMessage,integrationMessage.RefId__c,responseWrapper,listOfAppl);
                        system.debug('LoanBoardingResponseProcessor Response Received');
                    
                   
                    
                } 
            }
            //Exception Handling
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'LoanBoardingResponseProcessor', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                 system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
            }  
            
        }       
    }
    
    
    public static void updateLoanApplicationStatus(IntgMsg__c integrationMessage, id referenceid,LoanBoardingResponseWrapper responseWrapper,List<Applicant__c> appList){
        List<LoanAppl__c> loanAppList =[Select Id,Name,ErrorMessage__c from LoanAppl__c WHERE Id=:referenceid];

        String strDisbId= integrationMessage.Upsert_Record_Ids__c;
        System.debug('strDisbId:'+strDisbId);
        //List<Disbursement__c> loanAppList = [Select id,name,Disbur_Status__c from Disbursement__c WHERE Id=:strDisbId];


        System.debug('**** LoanBoardingResponseProcessor  ****');
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {LoanAppl__c.SObjectType });
        List<string> fieldNamesList = New List<string>{'ErrorMessage__c','Loan_Boarding_API_Status__c','FinnSubDtTime__c','Status__c'};
        //List<IntgMsg__c> createRequestList = new List<IntgMsg__c>();    
        List<Disbursement__c> updateDisbStatusList =new List<Disbursement__c>();
        String sObjectName = 'LoanAppl__c';
        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
        fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
        Boolean isSuccess;
        LoanAppl__c updateRec=New LoanAppl__c();
        updateRec.id=referenceid;

        if(loanAppList !=null && !loanAppList.isEmpty()){
            System.debug('responseWrapper.errorcode::'+responseWrapper.errorcode);
           

            String expectedStr ='APPLICATION CREATED SUCCESSFULLY';
            String strRes= responseWrapper.errorDescription;
            System.debug('Res Result ::'+ strRes.contains(expectedStr));
            System.debug('responseWrapper.errorDescription::'+responseWrapper.errorDescription);
            Boolean resForFinnone=strRes.contains(expectedStr);


            if(resForFinnone){
                updateRec.Loan_Boarding_API_Status__c='Success'; 
                updateRec.FinnSubDtTime__c =System.now();
                updateRec.Status__c='Finnone Pending';
                isSuccess=true;
            }else
            {
                updateRec.Loan_Boarding_API_Status__c='Failure';
                isSuccess=false;
            }
            
			updateRec.ErrorMessage__c = responseWrapper.errorDescription != null ? responseWrapper.errorDescription : '';
                //loanAppList[0].ErrorMessage__c + ' , LoanBoardingApi Response:'+(responseWrapper.errorDescription != null ? responseWrapper.errorDescription : '');
          }
        
        uow.registerDirty(updateRec);
        //system.debug('updateRec ::' +updateRec);
        //system.debug('isSuccess-------------->' +isSuccess);
        uow.commitWork();
        
        system.debug('isSuccess ::' +isSuccess);
        if(isSuccess){
            APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
            
            if(String.isNotBlank(strDisbId)) {
                Disbursement__c updDisb = new Disbursement__c();
                updDisb.id=strDisbId;
                updDisb.Disbur_Status__c='INITIATED';  
                updateDisbStatusList.add(updDisb);
            }
            
            /*if(appList !=null && !appList.isEmpty()){
                for(Applicant__c app : appList){
                    
               			//Creating Intg Msg for CKYC API  
                    	IntgMsg__c intMsgCkyc =new IntgMsg__c();
                        intMsgCkyc.Name='CKYC API';
                        intMsgCkyc.BU__c='HL / STL';
                        intMsgCkyc.RefId__c=app.Id;
                        intMsgCkyc.Status__c='New';
                        intMsgCkyc.MStatus__c='Blank';
                        intMsgCkyc.RefObj__c='Applicant__c';
                        intMsgCkyc.Svc__c='CKYC API';
                        intMsgCkyc.IsActive__c=true;
                    
                        createRequestList.add(intMsgCkyc);
                
                    
                		//Creating Intg Msg for CKYC ATTACHMENT  
                    	IntgMsg__c intMsgCkycAtt =new IntgMsg__c();
                        intMsgCkycAtt.Name='CKYC ATTACHMENT';
                        intMsgCkycAtt.BU__c='HL / STL';
                        intMsgCkycAtt.RefId__c=app.Id;
                        intMsgCkycAtt.Status__c='New';
                        intMsgCkycAtt.MStatus__c='Blank';
                        intMsgCkycAtt.RefObj__c='Applicant__c';
                        intMsgCkycAtt.Svc__c='CKYC ATTACHMENT';
                        intMsgCkycAtt.IsActive__c=true;
                    
                        createRequestList.add(intMsgCkycAtt);
                   
                }
            }*/
        }
            else{
                APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
            }
        
        /*System.debug('createRequestList::'+createRequestList);
        if(createRequestList!=null && !createRequestList.isEmpty()){
                        fflib_SObjectUnitOfWork uowInt = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType});
                        List<string> fieldNamesListInt = New List<string>{'Name','BU__c','RefId__c','Status__c','MStatus__c','RefObj__c','Svc__c','ApiVendor__c',
                            'IsActive__c','ParentRefId__c','ParentRefObj__c'};
                        String sObjectNameInt = 'IntgMsg__c';
                        Schema.SObjectType objTypeInt  = Schema.getGlobalDescribe().get(sObjectNameInt);
                        fflib_SecurityUtils.checkInsert(objTypeInt,fieldNamesListInt); 
                        uowInt.registerNew(createRequestList);
                        uowInt.commitWork();
          }*/

        System.debug('Update Status::'+updateDisbStatusList);
        if(updateDisbStatusList!=null && !updateDisbStatusList.isEmpty()){                        
                        /*
                        List<string> fieldNamesListDisb = New List<string>{'Disbur_Status__c'};
                        String sObjectNameDisb = 'Disbursement__c';
                        Schema.SObjectType objTypeInt  = Schema.getGlobalDescribe().get(sObjectNameDisb);
                        fflib_SecurityUtils.checkInsert(objTypeInt,fieldNamesListDisb); 
                        uowDisb.registerNew(updateDisbStatusList);
                        uowDisb.commitWork();
                        */
                        
                        fflib_SObjectUnitOfWork uowDisb = new fflib_SObjectUnitOfWork( new List<SObjectType> { Disbursement__c.SObjectType});
                        String sObjectNameDisb = 'Disbursement__c';
                        List<String> fieldNamesListDisb = new List<String>{'Disbur_Status__c' };
                        Schema.SObjectType objTypeDisb  = Schema.getGlobalDescribe().get(sObjectNameDisb);
                        fflib_SecurityUtils.checkUpdate(objTypeDisb,fieldNamesListDisb);
                        uowDisb.registerDirty(updateDisbStatusList);
                        uowDisb.commitWork();

          }

     }
     
}