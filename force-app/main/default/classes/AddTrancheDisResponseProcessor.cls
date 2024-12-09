public class AddTrancheDisResponseProcessor implements IintMsgCalloutResponseProcessor{
    //start
    public static void process(List<IntgMsg__c> responses) {
        System.debug('AddTrancheDisResponseProcessor method start');
        for(IntgMsg__c integrationMessage : responses){
            
            if(integrationMessage.Svc__c != GlobalConstants.INT_ADD_TR_DIS_SVC 
               && integrationMessage.BU__c != GlobalConstants.INT_MSG_BU_TYPE)
            {
                throw new processException('Error! This is not the correct service'); 
            }
            try{
                
                if(String.isNotBlank(integrationMessage.Resp__c)){     
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { IntgMsg__c.SObjectType });
                    List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>(); 
                    Map<String,Map<String,AddTrancheDisResponseWrapper>> jsonresponsemap=new  Map<String,Map<String,AddTrancheDisResponseWrapper>>();
                    AddTrancheDisResponseWrapper responseWrapper = (AddTrancheDisResponseWrapper) JSON.deserialize(integrationMessage.Resp__c, AddTrancheDisResponseWrapper.class); 
                    
                    if(responseWrapper != null){
                        system.debug('responseWrapper ->'+ responseWrapper);    
                        updateResponseMsg(integrationMessage.ParentRefId__c,integrationMessage.RefId__c,responseWrapper,integrationMessage);
                       }    
                }    
            }
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'AddTrancheDisResponseProcessor class', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
    }
    
    
    public static void updateResponseMsg(id parentReferenceid,id referenceid,AddTrancheDisResponseWrapper responseWrapper,IntgMsg__c integrationMessage){
        System.debug('updateResponseMsg inside::');
        List<Disbursement__c> disbRecForUpdtList =[select id,Disbur_No__c,Total_Disb_Amt__c,Disbur_Desrp__c,Disbur_Status__c FROM Disbursement__c WHERE Id=:referenceid];
        Integer sizeOfDisbList=0;
        Id lastDisbId=null;
        List<Disbursement__c> listOfDisbByLoanApp=[select id,Disbur_No__c,Total_Disb_Amt__c,Disbur_Desrp__c,Disbur_Status__c FROM Disbursement__c WHERE Loan_Appli__c=: parentReferenceid];
        if(listOfDisbByLoanApp !=null && !listOfDisbByLoanApp.isEmpty()){
            sizeOfDisbList=listOfDisbByLoanApp.size();
            for(Disbursement__c eachDisb :listOfDisbByLoanApp ){
            if(eachDisb.Disbur_No__c !=null && eachDisb.Disbur_No__c ==  sizeOfDisbList){
                lastDisbId =eachDisb.Id;
            }
            }

        }
        System.debug('lastDisbId ::'+lastDisbId);
        
        System.debug('sizeOfDisbList::'+sizeOfDisbList);
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {Disbursement__c.SObjectType});
        List<string> fieldNamesList = New List<string>{'Disbur_Status__c','Princ_Start_Date__c','Date_of_Disbur__c'};    
        String sObjectName = 'Disbursement__c';
        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
        fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);

        Disbursement__c updateRec=New Disbursement__c();

        updateRec.id=referenceid;
        System.debug('responseWrapper :'+responseWrapper);
        String strErrDesc='';
        if(responseWrapper !=null &&  responseWrapper.disbursalDetail !=null && responseWrapper.disbursalDetail.errorDescription !=null) 
        {
            strErrDesc=responseWrapper.disbursalDetail.errorDescription;
        }
        if(responseWrapper !=null && responseWrapper.errorDescription !=null){
            strErrDesc=responseWrapper.errorDescription;
        }
        System.debug('strErrDesc::'+strErrDesc);
       
        if(responseWrapper.disbursalDetail !=null && responseWrapper.disbursalDetail.errorcode == '00000' && (strErrDesc.contains('Successfull') || strErrDesc.contains('Successful.'))){
            System.debug('inside if success');

            if(lastDisbId == updateRec.id){
                updateRec.Disbur_Status__c='DISBURSED';
                updateRec.Date_of_Disbur__c=Date.today();
                updateRec.Finnone_Tranche_Disbursed_Amount__c =  (disbRecForUpdtList != null && !disbRecForUpdtList.isEmpty() && disbRecForUpdtList[0].Total_Disb_Amt__c !=null )? disbRecForUpdtList[0].Total_Disb_Amt__c :0 ;
            }
            else{
                updateRec.Disbur_Status__c='INITIATED';
                updateRec.Date_of_Disbur__c=Date.today();
            }


            if(integrationMessage.Trigger_Platform_Event__c){
                System.debug('inside condition check platform success..');
                publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                platformWra.intId = integrationMessage.Id; 
                platformWra.recId = integrationMessage.RefId__c;
                platformWra.ServiceName = integrationMessage.Svc__c ;
                platformWra.intMsgRes = integrationMessage.Resp__c;
                platformWra.Status = integrationMessage.Status__c ;
                platformWra.success = true;
                publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
            }
            APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');

        }else{
            updateRec.Disbur_Status__c='INTEGRATION FAILURE';

            System.debug('inside if failure');

            if(integrationMessage.Trigger_Platform_Event__c){
                System.debug('inside condition check platform failure..');
                publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                platformWra.intId = integrationMessage.Id; 
                platformWra.recId = integrationMessage.RefId__c;
                platformWra.ServiceName = integrationMessage.Svc__c ;
                platformWra.Status = integrationMessage.Status__c ;
                platformWra.success = false;
                platformWra.errorMessage = strErrDesc;
                platformWra.intMsgRes = integrationMessage.Resp__c;
                publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
            }


            APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
        }
        
		System.debug('inside Done..');
        uow.registerDirty(updateRec);
        uow.commitWork();
        
        
    }
    
    
}