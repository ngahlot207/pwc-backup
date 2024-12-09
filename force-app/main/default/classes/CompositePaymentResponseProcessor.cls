public class CompositePaymentResponseProcessor implements IintMsgCalloutResponseProcessor {
    
    public static void process(List<IntgMsg__c> responses){ 
        System.debug('process() called :: list size:'+responses.size());
        //Processing all responses
        for(IntgMsg__c integrationMessage : responses){
            if(integrationMessage.Svc__c != GlobalConstants.INT_CONFIG_SERVICE_COMPOSITE_API
               && integrationMessage.BU__c != GlobalConstants.INT_MSG_BU_TYPE){
                   System.debug('exception');
                   throw new processException('Error! This is not the correct service'); 
               }
            try{
                System.debug('integrationMessage.Resp__c:'+integrationMessage.Resp__c);
                //parse response
                if(String.isNotBlank(integrationMessage.Resp__c)){
                    CompositePaymentResponseWrapper responseWrapper = (CompositePaymentResponseWrapper) JSON.deserialize(integrationMessage.Resp__c, CompositePaymentResponseWrapper.class); 
                    //Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(integrationMessage.Resp__c);
                    System.debug('String.isNotBlank(integrationMessage.Resp__c)');
                    if(integrationMessage.RefObj__c=='RepayAccVerify__c'){
                        processCompositePaymentResponse(responseWrapper,integrationMessage.RefId__c,integrationMessage);
                    }
                    else if(integrationMessage.RefObj__c=='Split_Disbur__c'){
                        processCompositePaymentResponseForSplitDisb(responseWrapper,integrationMessage.RefId__c,integrationMessage);
                    }
                      

                    
                    if(integrationMessage.Trigger_Platform_Event__c){
                        
                        publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                        platformWra.intId = integrationMessage.Id; 
                        platformWra.recId = integrationMessage.RefId__c;
                        platformWra.ServiceName = integrationMessage.Svc__c ;
                        platformWra.Status = integrationMessage.Status__c ;
                        platformWra.success= (responseWrapper.success.equalsIgnoreCase('true') && responseWrapper.ActCode=='0') ? true : false;
                        platformWra.errorMessage= (responseWrapper.success.equalsIgnoreCase('true') && responseWrapper.ActCode!='0') ? responseWrapper.Response:(responseWrapper.success.equalsIgnoreCase('false') && String.isNotBlank(responseWrapper.description)) ? responseWrapper.description:'';
                        publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                    }    
                }
            }
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'CompositePaymentResponseProcessor class', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
            
            
        }       
    }
    
    
    public static void processCompositePaymentResponse(CompositePaymentResponseWrapper responseWrapper,Id referenceId,IntgMsg__c integrationMessage){
        System.debug('CompositePaymentResponseProcessor processCompositePaymentResponse() method called');
        System.debug('responseWrapper::'+responseWrapper);
        System.debug('referenceId::'+referenceId); 
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { RepayAccVerify__c.SObjectType,IntgMsg__c.SObjectType});
        
        List<RepayAccVerify__c> updateRequest = new List<RepayAccVerify__c>();
        List<IntgMsg__c> createRequestList = new List<IntgMsg__c>(); 
        try{
            Boolean isSuccess;
            if(responseWrapper!=null){
                RepayAccVerify__c updateRec=New RepayAccVerify__c();
                updateRec.id=referenceId;
                updateRec.NameRetuFromPennyDrop__c  =responseWrapper.BeneName;
                updateRec.TransRefNo__c =responseWrapper.TransRefNo;
                if(responseWrapper.success.equalsIgnoreCase('true'))
                {
                    if(responseWrapper.ActCode.equals('0')){
                        
                        updateRec.PennyDropStatus__c='Success';
                        updateRec.ErrorMess__c=responseWrapper.Response;  
                        updateRec.PennyDropDateTime__c = system.now();
                        
                        IntgMsg__c intmsg =new IntgMsg__c();
                        intmsg.Name='Penny drop';
                        intmsg.BU__c='HL / STL';
                        intmsg.RefId__c=referenceId;
                        intmsg.Status__c='New';
                        intmsg.MStatus__c='Blank';
                        intmsg.RefObj__c='RepayAccVerify__c';
                        intmsg.Svc__c='Penny drop';
                        intmsg.IsActive__c=true;
                        createRequestList.add(intmsg);  
                        isSuccess=true;
                    }
                    else{
                        updateRec.PennyDropStatus__c='Failure';
                    	updateRec.ErrorMess__c=responseWrapper.Response;
                        updateRec.PennyDropDateTime__c = system.now();
                        
                        isSuccess = false;
                    }
                    
                }
                else{
                    updateRec.PennyDropStatus__c='Failure';
                    updateRec.ErrorMess__c=responseWrapper.description;
                    updateRec.PennyDropDateTime__c = system.now();
                }  
                
                updateRequest.add(updateRec);
                
            }
            if(updateRequest!=null){
                List<string> fieldNamesList = New List<string>{'NameRetuFromPennyDrop__c','TransRefNo__c','PennyDropStatus__c','ErrorMess__c','PennyDropDateTime__c'};
                    String sObjectName = 'RepayAccVerify__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList); 
                uow.registerDirty(updateRequest);
            }
            if(!createRequestList.isEmpty()){
                List<string> fieldNamesList = New List<string>{'Name','BU__c','RefId__c','Status__c','MStatus__c','RefObj__c','Svc__c','ApiVendor__c',
                    'IsActive__c','ParentRefId__c','ParentRefObj__c'};
                        String sObjectName = 'IntgMsg__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                uow.registerNew(createRequestList);
                
            }
            uow.commitWork();
            if(isSuccess){
                APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
            }
            else{
                APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
            }
        }
        catch(exception ex){
            System.debug(ex);
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }
    }

    public static void processCompositePaymentResponseForSplitDisb(CompositePaymentResponseWrapper responseWrapper,Id referenceId,IntgMsg__c integrationMessage){
        System.debug('CompositePaymentResponseProcessor processCompositePaymentResponse() method called for Split Disb');
        System.debug('responseWrapper::'+responseWrapper);
        System.debug('referenceId::'+referenceId);
        Id idRepayAcc= null; 
        Set<Id> setIdReapAcc =new Set<Id>();
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { IntgMsg__c.SObjectType,RepayAccVerify__c.SObjectType,Split_Disbur__c.SObjectType,Repayment_Account__c.SObjectType});
        
        Map<Id,Split_Disbur__c> splitDisbMap = new Map<Id,Split_Disbur__c>([Select id,name,Cheq_Favor_Acc_No__c,IFSC_Detail__c,Custo_Name__c,DisburseRela__r.Applicant_Mobile_Number__c, DisburseRela__r.Loan_Appli__c from Split_Disbur__c Where Id =:referenceId]);
        List<IntgMsg__c> createRequestList = new List<IntgMsg__c>();
        List<Repayment_Account__c> updateRepayAcc = new List<Repayment_Account__c>();
        List<Repayment_Account__c> insertRepayAcc = new List<Repayment_Account__c>();

        List<Split_Disbur__c> updateSplitDisbExistList = new List<Split_Disbur__c>();
        List<RepayAccVerify__c> updateInsertRepayAccVer = new List<RepayAccVerify__c>();

        Split_Disbur__c splitObj= splitDisbMap.get(referenceId);
        String strAccno=splitObj.Cheq_Favor_Acc_No__c !=null ? splitObj.Cheq_Favor_Acc_No__c :'';
        String splitLoanId = splitObj.DisburseRela__r.Loan_Appli__c !=null ? splitObj.DisburseRela__r.Loan_Appli__c : null;
        String ifscCode=splitObj.IFSC_Detail__c !=null ? splitObj.IFSC_Detail__c:'';
        System.debug('strAccno::'+strAccno);
        System.debug('splitLoanId::'+splitLoanId);
        List<Repayment_Account__c> repayAccListFilter = [Select id,Is_Active__c,Account_Number__c,IFSC_Code__c,Type__c, Loan_Application__c from Repayment_Account__c Where Account_Number__c =:strAccno  and Type__c= 'SPLIT DISBURSEMENT ACCOUNT' AND Loan_Application__c =:splitLoanId AND IFSC_Code__c =:ifscCode order by LastModifiedDate desc limit 1];

        System.debug('repayAccListFilter::'+repayAccListFilter);
        try{
            Boolean isSuccess ;
            if(responseWrapper!=null){
                Split_Disbur__c updateSplitDisObj=New Split_Disbur__c();
                updateSplitDisObj.id=referenceId;
                
                if(responseWrapper.success.equalsIgnoreCase('true'))
                {
                    if(responseWrapper.ActCode.equals('0')){
                        
                        updateSplitDisObj.Penny_Drop_Nm_Sta__c  = 'SUCCESS';  //for timing and txn ref no. make and error msg field also field in sp disb 
                        updateSplitDisObj.Benef_Nm_of_Penny_Drop__c =responseWrapper.BeneName !=null ?responseWrapper.BeneName :'';
                       
                        //new fields  
                        updateSplitDisObj.PennyDrpTxnRefNo__c=responseWrapper.TransRefNo !=null ? responseWrapper.TransRefNo :'';
                        updateSplitDisObj.PennyDrpResTime__c=System.now();
                        updateSplitDisObj.PennyDrpResMsg__c =responseWrapper.Response !=null ? responseWrapper.Response :'';


                        IntgMsg__c intmsg =new IntgMsg__c();
                        intmsg.Name='Penny drop';
                        intmsg.BU__c='HL / STL';
                        intmsg.RefId__c=referenceId;
                        intmsg.Status__c='New';
                        intmsg.MStatus__c='Blank';
                        intmsg.RefObj__c='Split_Disbur__c';
                        intmsg.Svc__c='Penny drop';
                        intmsg.IsActive__c=true;
                        createRequestList.add(intmsg); 

                        isSuccess=true;
                    }
                    else{

                        updateSplitDisObj.Penny_Drop_Nm_Sta__c  = 'FAILURE';  
                        updateSplitDisObj.Benef_Nm_of_Penny_Drop__c =responseWrapper.BeneName!=null? responseWrapper.BeneName :'';
                        
                        //new fields 
                        updateSplitDisObj.PennyDrpTxnRefNo__c=responseWrapper.TransRefNo !=null ? responseWrapper.TransRefNo :'';
                        updateSplitDisObj.PennyDrpResTime__c=System.now();
                        updateSplitDisObj.PennyDrpResMsg__c =responseWrapper.Response!=null ? responseWrapper.Response:'';

                        isSuccess = false;
                    }
                    
                }
                else{
                    updateSplitDisObj.Penny_Drop_Nm_Sta__c  = 'FAILURE';  
                    updateSplitDisObj.Benef_Nm_of_Penny_Drop__c =responseWrapper.BeneName!=null ? responseWrapper.BeneName:''; 
                    isSuccess = false;
                     //new fields 
                     updateSplitDisObj.PennyDrpTxnRefNo__c=responseWrapper.TransRefNo !=null ? responseWrapper.TransRefNo :'';
                     updateSplitDisObj.PennyDrpResTime__c=System.now();
                     updateSplitDisObj.PennyDrpResMsg__c =responseWrapper.description !=null ? responseWrapper.description :'';
                     

                }  
                
                updateSplitDisbExistList.add(updateSplitDisObj);
                
            }
            if(updateSplitDisbExistList!=null){
                List<string> fieldNamesList = New List<string>{'Penny_Drop_Nm_Sta__c','Benef_Nm_of_Penny_Drop__c','PennyDrpTxnRefNo__c','PennyDrpResTime__c','PennyDrpResMsg__c'};
                String sObjectName = 'Split_Disbur__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList); 
                uow.registerDirty(updateSplitDisbExistList);
                //update updateSplitDisbExistList;
                
            }
            //uow.commitWork();

            if(repayAccListFilter!=null && !repayAccListFilter.isEmpty()){    
                
            for(Repayment_Account__c eachRpObj : repayAccListFilter){
                    //eachRpObj.Is_Active__c =true;
                    eachRpObj.IFSC_Code__c = ifscCode;
                    updateRepayAcc.add(eachRpObj);
            }
                
            }else{
                Repayment_Account__c newRepayAcc=new Repayment_Account__c();
                newRepayAcc.Account_Number__c= strAccno;
                //newRepayAcc.Is_Active__c=true;
                newRepayAcc.Type__c='SPLIT DISBURSEMENT ACCOUNT';
                newRepayAcc.Loan_Application__c = splitLoanId;
                newRepayAcc.IFSC_Code__c = ifscCode;
                insertRepayAcc.add(newRepayAcc);
            }
			System.debug('updateRepayAcc::'+updateRepayAcc);
            if(updateRepayAcc !=null && !updateRepayAcc.isEmpty()){
				System.debug('inside updateRepayAcc check');                
                idRepayAcc=updateRepayAcc[0].id;
                System.debug('idRepayAcc:'+idRepayAcc);
                List<string> fieldNamesList = New List<string>{'Type__c','Is_Active__c','Account_Number__c'};
                String sObjectName = 'Repayment_Account__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList); 
                uow.registerDirty(updateRepayAcc); 
                //update updateRepayAcc;
            }
           // uow.commitWork();
			System.debug('insertRepayAcc::'+insertRepayAcc);
            if(insertRepayAcc!=null && !insertRepayAcc.isEmpty()){
                System.debug('insertRepayAcc not null');
                
                /*List<string> fieldNamesList = New List<string>{'Type__c','Is_Active__c','Account_Number__c'};
                String sObjectName = 'Repayment_Account__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                uow.registerNew(insertRepayAcc);
                idRepayAcc=insertRepayAcc[0].id;
                //insert insertRepayAcc; */
                Database.insert(insertRepayAcc);
                 
                
            }
           // uow.commitWork();
            If(!insertRepayAcc.isEmpty()){
               idRepayAcc=insertRepayAcc[0].id; 
            }
			System.debug('idRepayAcc::'+idRepayAcc);

            RepayAccVerify__c repayAccVerObj =new RepayAccVerify__c();
            if(responseWrapper.success.equalsIgnoreCase('true'))
            {
                if(responseWrapper.ActCode.equals('0')){
                    repayAccVerObj.PennyDropStatus__c ='Success'; 
                }
                else{
                    repayAccVerObj.PennyDropStatus__c ='Failure'; 
                }
            }
            else{ 
                repayAccVerObj.PennyDropStatus__c ='Failure'; 
            } 

            repayAccVerObj.PennyDropDateTime__c=System.now();
            repayAccVerObj.BeneficiaryAccNo__c= strAccno;
            repayAccVerObj.RepayAcc__c = idRepayAcc;
            updateInsertRepayAccVer.add(repayAccVerObj);

            if(!updateInsertRepayAccVer.isEmpty()){
                List<string> fieldNamesList = New List<string>{'PennyDropStatus__c','PennyDropDateTime__c','BeneficiaryAccNo__c','RepayAcc__c'};
                        String sObjectName = 'RepayAccVerify__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                uow.registerNew(updateInsertRepayAccVer);
                //insert updateInsertRepayAccVer;
                
            }
            if(!createRequestList.isEmpty()){
                
                List<string> fieldNamesList = New List<string>{'Name','BU__c','RefId__c','Status__c','MStatus__c','RefObj__c','Svc__c','ApiVendor__c',
                    'IsActive__c','ParentRefId__c','ParentRefObj__c'};
                        String sObjectName = 'IntgMsg__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                uow.registerNew(createRequestList);
                //insert createRequestList;
                
            }
            
            uow.commitWork();

            if(isSuccess){
                APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
            }
            else{
                APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
            }
        }
        catch(exception ex){
            System.debug(ex);
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }
    }
    
}