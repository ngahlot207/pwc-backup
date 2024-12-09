public class MultiTrancheResponseProcessor implements IintMsgCalloutResponseProcessor{
    public static void process(List<IntgMsg__c> responses) {
      System.debug('MultiTrancheResponseProcessor method start');
      for(IntgMsg__c integrationMessage : responses){
          
          if(integrationMessage.Svc__c != GlobalConstants.INT_MULTI_TRANCHE 
             && integrationMessage.BU__c != GlobalConstants.INT_MSG_BU_TYPE)
          {
              throw new processException('Error! This is not the correct service'); 
          }
          try{
              
              if(String.isNotBlank(integrationMessage.Resp__c)){     
                  fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { IntgMsg__c.SObjectType });
                  List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>(); 
                  Map<String,Map<String,MultiTrancheResponseWrapper>> jsonresponsemap=new  Map<String,Map<String,MultiTrancheResponseWrapper>>();
                  MultiTrancheResponseWrapper responseWrapper = (MultiTrancheResponseWrapper) JSON.deserialize(integrationMessage.Resp__c, MultiTrancheResponseWrapper.class); 
                  
                  if(responseWrapper != null){
                      System.debug('responseWrapper ->'+ responseWrapper);    
                      updateResponseMsg(integrationMessage.RefId__c,responseWrapper,integrationMessage);
                      }    
              }    
          }
          catch(Exception ex){
              GlobalUtility.logMessage('Error', 'MultiTrancheResponseProcessor class', 
                                       'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
          }
      }
    }   
    
  
    public static void updateResponseMsg(id referenceid,MultiTrancheResponseWrapper responseWrapper,IntgMsg__c integrationMessage){
      System.debug('updateResponseMsg inside::');
      List<LoanAppl__c>appKyc =[Select id,name FROM LoanAppl__c WHERE Id=:referenceid];
  
      List<Disbursement__c> listDisbUpdate =new List<Disbursement__c>();
      fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {Disbursement__c.SObjectType});
      
      
      List<MultiTrancheResponseWrapper.Data> listDataRes =  responseWrapper.Data;
      Map<String,String> mapOfDisbRes = new Map<String,String>();
  
      List<MultiTrancheResponseWrapper.Tranches> listOfTranches =new List<MultiTrancheResponseWrapper.Tranches>();
  
      if(listDataRes!=null && !listDataRes.isEmpty()){
          for(MultiTrancheResponseWrapper.Data dataObj : listDataRes)
          {	System.debug('addAll: start'+listOfTranches);
              listOfTranches.addAll(dataObj.Tranches);
              System.debug('addAll:'+listOfTranches);
          }
      }
        else{
            System.debug('listDataRes is null');
        }
      List<ID> idsOfDisbObj =new List<ID>();
      System.debug('listOfTranches::'+listOfTranches);
  
      String resStatus= responseWrapper.status !=null ? String.valueOf(responseWrapper.status) :'0';
      String resmsg=responseWrapper.message !=null ? responseWrapper.message:'';
  
      Boolean result=resmsg.contains('Success');
      if((resStatus == '200' || resStatus == '1')  && result){
  
          System.debug('Success');
          if(integrationMessage.Trigger_Platform_Event__c){
              publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
              platformWra.intId = integrationMessage.Id; 
              platformWra.recId = integrationMessage.RefId__c;
              platformWra.ServiceName = integrationMessage.Svc__c ;
              platformWra.Status = integrationMessage.Status__c ;
              platformWra.success = True;
              platformWra.errorMessage = resmsg;
  
              String sendRes='';
              if(integrationMessage.Resp__c !=null && !String.isEmpty(integrationMessage.Resp__c)){
                  sendRes = String.valueOf(integrationMessage.Resp__c).replace('\\', '');
              }
              platformWra.intMsgRes = sendRes;//integrationMessage.Resp__c;
  
              
              System.debug('Res sent::'+platformWra.intMsgRes);
              publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
          }
          APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
  
  
      }
      else{
          System.debug('platform failure event::');
          if(integrationMessage.Trigger_Platform_Event__c){
              System.debug('platform true for failure::'+integrationMessage.Status__c);
  
              publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
              platformWra.intId = integrationMessage.Id; 
              platformWra.recId = integrationMessage.RefId__c;
              platformWra.ServiceName = integrationMessage.Svc__c ;
              platformWra.Status = integrationMessage.Status__c ;
              platformWra.success = False;
              platformWra.errorMessage = resmsg;
              String sendRes='';
              if(integrationMessage.Resp__c !=null && !String.isEmpty(integrationMessage.Resp__c)){
                  sendRes = String.valueOf(integrationMessage.Resp__c).replace('\\', '');
              }
              platformWra.intMsgRes = sendRes;//integrationMessage.Resp__c;
              System.debug('Res :'+platformWra.intMsgRes);
              publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
          }
  
  
          APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
      
  
      }
  
      for(MultiTrancheResponseWrapper.Tranches eachTrancheObj : listOfTranches ){
  
          if(eachTrancheObj.Message !=null && !String.isEmpty(eachTrancheObj.Message)){
  
              List<String> strMsgIdArr = eachTrancheObj.Message.split('_');
              Boolean res= (strMsgIdArr!=null && !strMsgIdArr.isEmpty()) ;
              Integer sizeArr= res ? strMsgIdArr.size() : 0 ;
  
              String statusRes= eachTrancheObj.DisbursalStatus!=null ? eachTrancheObj.DisbursalStatus :'';
              if(sizeArr > 1)
              {
                  idsOfDisbObj.add(strMsgIdArr[1]);
                  mapOfDisbRes.put(strMsgIdArr[1],statusRes);
              }
          
          }
  
  
          System.debug('List Of Disb Ids ::'+idsOfDisbObj);
          System.debug('mapOfDisbRes::'+mapOfDisbRes);
  
  
  
          List<Disbursement__c> listDisb = [Select id,name,Disbur_Status__c  from Disbursement__c where Id in : mapOfDisbRes.keySet()];
  
  
          for(Disbursement__c disbEach :listDisb){
              disbEach.Disbur_Status__c=mapOfDisbRes.get(disbEach.Id) !=null ? mapOfDisbRes.get(disbEach.Id) :'';  //'DISBURSED';
              listDisbUpdate.add(disbEach);
          }
  
  }
         /*
          if(listDisbUpdate!=null && !listDisbUpdate.isEmpty()){
              List<string> fieldNamesList = New List<string>{'Disbur_Status__c'};
              String sObjectName = 'Disbursement__c';
              Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
              fflib_SecurityUtils.checkUpdate(objType,fieldNamesList); 
              uow.registerDirty(listDisbUpdate);
          }
          uow.commitWork();
          */
          //APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
  }
    
  }