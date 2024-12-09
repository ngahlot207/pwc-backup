public class DedupeResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    //Implementing the process method
    public static void process(List<IntgMsg__c> responses){ 
        for(IntgMsg__c integrationMessage : responses){
            try{
                DedupeResponseWrapper responseWrapper = (DedupeResponseWrapper) JSON.deserialize(integrationMessage.Resp__c, DedupeResponseWrapper.class);
                if((responseWrapper.success !=null) && boolean.valueOf(responseWrapper.success)){
                    createDedupeSuccess(responseWrapper,integrationMessage.RefId__c,integrationMessage);
                }
                else {
                    createDedupeError(responseWrapper,integrationMessage.RefId__c,integrationMessage); 
                }
                
                if(integrationMessage.Trigger_Platform_Event__c){
                    publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                    platformWra.intId = integrationMessage.Id; 
                    platformWra.recId = integrationMessage.ParentRefId__c;
                    platformWra.ServiceName = integrationMessage.Svc__c ;
                    platformWra.Status = integrationMessage.Status__c ;
                    platformWra.success = boolean.valueOf(responseWrapper.success);
                    platformWra.errorMessage = responseWrapper.message;
                    /*if(boolean.valueOf(responseWrapper.success)){
                    platformWra.success=true;
                    }
                    else{
                    platformWra.errorMessage=responseWrapper.message;
                    }*/
                    publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                }
            }
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'DedupeResponseProcessor class', 
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
                
                
                if(integrationMessage.Trigger_Platform_Event__c){
                    publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                    platformWra.intId = integrationMessage.Id; 
                    platformWra.recId = integrationMessage.ParentRefId__c;
                    platformWra.ServiceName = integrationMessage.Svc__c ;
                    platformWra.Status = integrationMessage.Status__c ;
                    // platformWra.success = boolean.valueOf(responseWrapper.success);
                    platformWra.errorMessage = string.isNotBlank(errorMessage)?errorMessage:'';
                    publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                }
                APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
                
                
            
            } 
        }
    }
    
    public static void createDedupeSuccess(DedupeResponseWrapper responseWrapper, Id referenceId, IntgMsg__c integrationMessage){
        try{
            Map<Id,Applicant__c> applMap = new Map<Id,Applicant__c>([Select Id,LoanAppln__c,LoanAppln__r.Stage__c,IntegrationStatus__c,IntegrationErrorMessage__c,UCID__c,Constitution__c,LoanAppln__r.Product__c from Applicant__c where Id=:referenceId]);
            List<Applicant__c> updateApplList = new List<Applicant__c>();            
            if(applMap.containsKey(referenceId)){
                if(responseWrapper!=null){
                    Id dedupeRecordTypeId = Schema.SObjectType.DedupeResponse__c.getRecordTypeInfosByDeveloperName().get('Dedupe').getRecordTypeId();
                    List<IntgMsg__c> createRequestList = new List<IntgMsg__c>();
                    Map<String,DedupeResponse__c> existingDedupeMap = new Map<String,DedupeResponse__c>();
                    Map<Boolean,DedupeResponse__c> existingNoMatchDedupeMap = new Map<Boolean,DedupeResponse__c>();
                    Map<String,List<DedupeResponseWrapper.AdditionalInformation>> dedupeMatchCrMap = new Map<String,List<DedupeResponseWrapper.AdditionalInformation>>();
                    Set<String> appIds = new Set<String>();
                    //List<DedupeResponse__c> existingdedupeList = [Select Id,IsLatest__c FROM DedupeResponse__c WHERE IsLatest__c=True AND Applicant__c=:referenceId AND LoanAppln__c=:applMap.get(referenceId).LoanAppln__c AND RecordTypeId=:dedupeRecordTypeId];
                    for(DedupeResponse__c resp : [Select Id,UCID__c,AppId__c,Source__c,FileName__c,NoMatchFound__c FROM DedupeResponse__c WHERE Applicant__c=:referenceId AND LoanAppln__c=:applMap.get(referenceId).LoanAppln__c AND RecordTypeId=:dedupeRecordTypeId]){
                        if(resp.UCID__c!=null || resp.AppId__c!=null){
                            existingDedupeMap.put((resp.UCID__c!=null?resp.UCID__c:'') +'-'+ (resp.AppId__c!=null?resp.AppId__c:''),resp);
                        }
                        if(resp.NoMatchFound__c){
                            existingNoMatchDedupeMap.put(resp.NoMatchFound__c,resp);
                        }
                        
                    }
                    
                    Applicant__c appl= new Applicant__c();
                    appl.Id=referenceId;
                    if(String.isNotBlank(responseWrapper.ucid)){
                        appl.UCID__c = responseWrapper.ucid;
                    }
                    
                    appl.IntegrationStatus__c= replaceAndUpdateString('Dedupe API', 'Dedupe API: Success', applMap.get(referenceId).IntegrationStatus__c,';');
                    appl.IntegrationErrorMessage__c=replaceAndUpdateString('Dedupe API', '', applMap.get(referenceId).IntegrationErrorMessage__c,';');
                    updateApplList.add(appl);
                    
                    if(String.isNotBlank(responseWrapper.ucid)){
                    	IntgMsg__c intmsg =new IntgMsg__c();
                        intmsg.Name='ENPA';
                        intmsg.BU__c='HL / STL';
                        intmsg.RefId__c=referenceId;
                        intmsg.Status__c='New';
                        intmsg.MStatus__c='Blank';
                        intmsg.RefObj__c='Applicant__c';
                        intmsg.Svc__c='ENPADeatils';
                        intmsg.IsActive__c=true;
                        intmsg.TriggFrmScrn__c=integrationMessage.TriggFrmScrn__c !=null ? integrationMessage.TriggFrmScrn__c :'';

                        createRequestList.add(intmsg);
                	}
					//check if req or not
                    if(String.isBlank(responseWrapper.ucid) && applMap.get(referenceId).LoanAppln__r.Stage__c == 'DDE'){
                        IntgMsg__c intmsg =new IntgMsg__c();
                        intmsg.Name='UCIC API Token';
                        intmsg.BU__c='HL / STL';
                        intmsg.RefId__c=referenceId;
                        intmsg.Status__c='New';
                        intmsg.MStatus__c='Blank';
                        intmsg.RefObj__c='Applicant__c';
                        intmsg.Svc__c='Dedupe API Token';
                        intmsg.ParentRefId__c=applMap.get(referenceId).LoanAppln__c;
                        intmsg.ParentRefObj__c='LoanAppl__c';
                        intmsg.TriggFrmScrn__c=integrationMessage.TriggFrmScrn__c !=null ? integrationMessage.TriggFrmScrn__c :'';
                        
                        intmsg.IsActive__c=true;
                        createRequestList.add(intmsg);
                    }
                    
                    List<DedupeResponse__c> dedupeList = new List<DedupeResponse__c>();
                    //match found
                    if(responseWrapper.customers.size()>0){
                        for(DedupeResponseWrapper.Customers customerData : responseWrapper.customers){
                            
                            DedupeResponse__c dedupeRes = new DedupeResponse__c();
                            dedupeRes.Applicant__c=referenceId;
                            dedupeRes.LoanAppln__c=applMap.get(referenceId).LoanAppln__c;
                            dedupeRes.RecordTypeId=dedupeRecordTypeId;
                            dedupeRes.UCID__c = String.isNotBlank(responseWrapper.ucid)? responseWrapper.ucid : '';
                            dedupeRes.InternalDedupeResponse__c ='Match Found';
                            dedupeRes.IsLatest__c=true;
                            dedupeRes.LatestReportTime__c = System.now();
                            if(String.isNotBlank(customerData.risk_category)){
                                dedupeRes.RiskCategory__c = customerData.risk_category;
                            }
                            if(String.isNotBlank(customerData.source)){
                                dedupeRes.Source__c = customerData.source;
                            }
                            if(String.isNotBlank(customerData.customerFirstName)){
                                dedupeRes.CustomerFirstName__c = customerData.customerFirstName;
                            }
                            if(String.isNotBlank(customerData.husbandorfatherfirstname)){
                                dedupeRes.HusbandorFatherFirstName__c = customerData.husbandorfatherfirstname;
                            }
                            if(String.isNotBlank(customerData.appid)){
                                dedupeRes.AppId__c = customerData.appid;
                            }
                            if(existingDedupeMap.containsKey((String.isNotBlank(responseWrapper.ucid)? responseWrapper.ucid : '') +'-'+ (String.isNotBlank(customerData.appid)? customerData.appid : ''))){
                                dedupeRes.Id = existingDedupeMap.get((String.isNotBlank(responseWrapper.ucid)? responseWrapper.ucid : '') +'-'+ (String.isNotBlank(customerData.appid)? customerData.appid : '')).Id;
                            }
                            
                            if(customerData.matchingCr!=null){
                                String Matchcriteria='';
                                if(String.isNotBlank(customerData.matchingCr.DRIVINGLICENCE) && customerData.matchingCr.DRIVINGLICENCE=='100%'){
                                    Matchcriteria+= 'Match in DRIVING LICENCE,';
                                }
                                if(String.isNotBlank(customerData.matchingCr.VOTERID) && customerData.matchingCr.VOTERID=='100%'){
                                    Matchcriteria+= 'Match in VOTERID,';
                                }
                                if(String.isNotBlank(customerData.matchingCr.AADHAR) && customerData.matchingCr.AADHAR=='100%'){
                                    Matchcriteria+= 'Match in AADHAR,';
                                }
                                if(String.isNotBlank(customerData.matchingCr.PAN) && customerData.matchingCr.PAN=='100%'){
                                    Matchcriteria+= 'Match in PAN,';
                                }
                                if(String.isNotBlank(customerData.matchingCr.PASSPORT) && customerData.matchingCr.PASSPORT=='100%'){
                                    Matchcriteria+= 'Match in PASSPORT,';
                                }
                                if(customerData.matchingCr.OTHER_CRITERIA!=null){
                                    if(customerData.matchingCr.OTHER_CRITERIA.firstName!=null && String.isNotBlank(customerData.matchingCr.OTHER_CRITERIA.firstName) && customerData.matchingCr.OTHER_CRITERIA.firstName=='100%'){
                                        Matchcriteria+= 'Match in FIRST NAME,';
                                    }
                                    if(customerData.matchingCr.OTHER_CRITERIA.lastName!=null && String.isNotBlank(customerData.matchingCr.OTHER_CRITERIA.lastName) && customerData.matchingCr.OTHER_CRITERIA.lastName=='100%'){
                                        Matchcriteria+= 'Match in LAST NAME,';
                                    }
                                    if(customerData.matchingCr.OTHER_CRITERIA.gender!=null && String.isNotBlank(customerData.matchingCr.OTHER_CRITERIA.gender) && customerData.matchingCr.OTHER_CRITERIA.gender=='100%'){
                                        Matchcriteria+= 'Match in GENDER,';
                                    }
                                    if(customerData.matchingCr.OTHER_CRITERIA.dateOfBirth!=null && String.isNotBlank(customerData.matchingCr.OTHER_CRITERIA.dateOfBirth) && customerData.matchingCr.OTHER_CRITERIA.dateOfBirth=='100%'){
                                        Matchcriteria+= 'Match in DATE OF BIRTH,';
                                    }
                                    if(customerData.matchingCr.OTHER_CRITERIA.primaryMobileNo!=null && String.isNotBlank(customerData.matchingCr.OTHER_CRITERIA.primaryMobileNo) && customerData.matchingCr.OTHER_CRITERIA.primaryMobileNo=='100%'){
                                        Matchcriteria+= 'Match in PRIMARY MOBILE NO,';
                                    }
                                    if(customerData.matchingCr.OTHER_CRITERIA.email!=null && String.isNotBlank(customerData.matchingCr.OTHER_CRITERIA.email) && customerData.matchingCr.OTHER_CRITERIA.email=='100%'){
                                        Matchcriteria+= 'Match in EMAIL,';
                                    }
                                }
                                
                                dedupeRes.MatchCriteria__c = Matchcriteria.removeEnd(',');
                                if(String.isNOtBlank(customerData.customerid)){
                                    dedupeRes.CustomerId__c = customerData.customerid;
                                }
                                
                                if(!customerData.matchingCr.additionalInformation.isEmpty()){
                                    if(String.isNotBlank(customerData.appid)){
                                        //dedupeRes.AppId__c = customerData.appid;
                                        dedupeRes.IsAddMatchingCr__c=true;
                                        dedupeMatchCrMap.put((String.isNotBlank(responseWrapper.ucid)? responseWrapper.ucid : '') +'-'+ customerData.appid,customerData.matchingCr.additionalInformation);
                                        appIds.add(customerData.appid);
                                    }
                                }
                                
                            }
                            
                            dedupeList.add(dedupeRes);
                        }
                    }
                    //match found
                    if(responseWrapper.negativeList.size()>0){
                        for(DedupeResponseWrapper.negativeList negativeData : responseWrapper.negativeList){
                            DedupeResponse__c dedupeRes = new DedupeResponse__c();
                            dedupeRes.Applicant__c=referenceId;
                            dedupeRes.LoanAppln__c=applMap.get(referenceId).LoanAppln__c;
                            dedupeRes.RecordTypeId=dedupeRecordTypeId;
                            dedupeRes.IsLatest__c=true;
                            dedupeRes.Source__c = 'NegativeList';
                            dedupeRes.MatchSource__c ='NegativeList';
                            dedupeRes.InternalDedupeResponse__c ='Match Found';
                            if(String.isNotBlank(negativeData.file_name)){
                                dedupeRes.FileName__c= negativeData.file_name;
                            }
                            if(String.isNotBlank(negativeData.negative_reasons)){
                                dedupeRes.NegativeReasons__c = negativeData.negative_reasons;
                            }
                            if(String.isNotBlank(negativeData.customername)){
                                dedupeRes.CustomerFirstName__c = negativeData.customername;
                            }
                            dedupeRes.LatestReportTime__c = System.now();
                            dedupeList.add(dedupeRes);
                        }
                        
                    }
                    
                    if(responseWrapper.customers.isEmpty() && responseWrapper.negativeList.isEmpty()){
                        
                        if(applMap.containsKey(referenceId) && applMap.get(referenceId).Constitution__c == 'INDIVIDUAL' && (applMap.get(referenceId).LoanAppln__r.Product__c == 'Business Loan' ||  applMap.get(referenceId).LoanAppln__r.Product__c == 'Personal Loan') && integrationMessage.TriggFrmScrn__c == 'Applicant Details'){
                            IntgMsg__c intmsg =new IntgMsg__c();
                            intmsg.Name='Consumer ACK Request';
                            intmsg.BU__c='HL / STL';
                            intmsg.RefId__c=referenceId;
                            intmsg.Status__c='New';
                            intmsg.MStatus__c='Blank';
                            intmsg.RefObj__c='Applicant__c';
                            intmsg.Svc__c='Consumer ACK Request';
                            intmsg.ParentRefId__c=applMap.get(referenceId).LoanAppln__c;
                            intmsg.ParentRefObj__c='LoanAppl__c';
                            intmsg.TriggFrmScrn__c=integrationMessage.TriggFrmScrn__c;
                            intmsg.IsActive__c=true;
                            createRequestList.add(intmsg);
                        }
                        
                        DedupeResponse__c dedupeRes = new DedupeResponse__c();
                        dedupeRes.Applicant__c=referenceId;
                        dedupeRes.LoanAppln__c=applMap.get(referenceId).LoanAppln__c;
                        dedupeRes.RecordTypeId=dedupeRecordTypeId;
                        dedupeRes.InternalDedupeResponse__c ='No Match Found';
                        dedupeRes.NoMatchFound__c = true;
                        if(existingNoMatchDedupeMap.containskey(true)){
                            dedupeRes.Id=existingNoMatchDedupeMap.get(true).Id;
                        }
                        dedupeRes.IsLatest__c=true;
                        dedupeRes.LatestReportTime__c = System.now();
                        dedupeList.add(dedupeRes);
                    }
                        
                    if(!dedupeList.isEmpty()){
                        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { DedupeResponse__c.SObjectType });
                        //List<string> fieldNamesList = New List<string>{'Applicant__c','LoanAppln__c','RecordTypeId','IsLatest__c','RiskCategory__c','MatchCriteria__c','AppId__c','CustomerId__c','Source__c','CustomerFirstName__c','HusbandorFatherFirstName__c','UCID__c','IsAddMatchingCr__c','NoMatchFound__c','InternalDedupeResponse__c','NegativeReasons__c','FileName__c'};
                        //    String sObjectName = 'DedupeResponse__c';
                        //Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                        //fflib_SecurityUtils.checkInsert(objType,fieldNamesList);
                        uow.registerUpsert(dedupeList);
                        uow.commitWork();
                        //insert dedupeList;
                        if(!dedupeMatchCrMap.isEmpty()){
                            createDedupeMatchCr(referenceId,dedupeMatchCrMap,appIds);
                        }
                    }
                    if(!updateApplList.isEmpty()){
                        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Applicant__c.SObjectType });
                        List<string> fieldNamesList = New List<string>{'UCID__c','IntegrationStatus__c','IntegrationErrorMessage__c'};
                            String sObjectName = 'Applicant__c';
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                        fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                        uow.registerDirty(updateApplList);
                        uow.commitWork();
                    }
                    /*if(!existingdedupeList.isEmpty()){
                        updateExistingDedupeResponse(existingdedupeList);
                    }*/
                    
                    
                    if(!createRequestList.isEmpty()){
                        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType});
                        List<string> fieldNamesList = New List<string>{'Name','BU__c','RefId__c','Status__c','MStatus__c','RefObj__c','Svc__c','ApiVendor__c',
                            'IsActive__c','ParentRefId__c','ParentRefObj__c'};
                        String sObjectName = 'IntgMsg__c';
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                        fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                        uow.registerNew(createRequestList);
                        uow.commitWork();
                    }

                    APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
                }
            } 
        }
        catch(exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }  
        
    }
    
    public static void createDedupeError(DedupeResponseWrapper responseWrapper, Id referenceId,IntgMsg__c integrationMessage){
        Map<Id,Applicant__c> applMap = new Map<Id,Applicant__c>([Select Id,LoanAppln__c,IntegrationStatus__c,IntegrationErrorMessage__c from Applicant__c where Id=:referenceId]);
        List<Applicant__c> updateApplList = new List<Applicant__c>();
        //Id dedupeRecordTypeId = Schema.SObjectType.DedupeResponse__c.getRecordTypeInfosByDeveloperName().get('Dedupe').getRecordTypeId();
        //List<DedupeResponse__c> existingdedupeList = [Select Id,IsLatest__c FROM DedupeResponse__c WHERE IsLatest__c=True AND Applicant__c=:referenceId AND LoanAppln__c=:applMap.get(referenceId).LoanAppln__c AND RecordTypeId=:dedupeRecordTypeId];
        //List<String> existingStatus= applMap.get(referenceId).IntegrationStatus__c.split(';');
        
        if(applMap.containsKey(referenceId)){
            if(responseWrapper!=null){
                String errorMessage = String.isNotBlank(responseWrapper.message) ? responseWrapper.message:String.isNotBlank(responseWrapper.msg) ? responseWrapper.msg:'';
                Applicant__c appl= new Applicant__c();
                appl.Id=referenceId;
                appl.IntegrationStatus__c= replaceAndUpdateString('Dedupe API', 'Dedupe API: Failure', applMap.get(referenceId).IntegrationStatus__c,';');
                appl.IntegrationErrorMessage__c=replaceAndUpdateString('Dedupe API', 'Dedupe API: '+ errorMessage, applMap.get(referenceId).IntegrationErrorMessage__c,';');
                updateApplList.add(appl);
            }
            
            if(!updateApplList.isEmpty()){
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Applicant__c.SObjectType });
                List<string> fieldNamesList = New List<string>{'IntegrationStatus__c','IntegrationErrorMessage__c'};
                    String sObjectName = 'Applicant__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(updateApplList);
                uow.commitWork();
            }
            /*if(!existingdedupeList.isEmpty()){
                updateExistingDedupeResponse(existingdedupeList);
            }*/
            APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
        }        
    }
    
    public static void createDedupeMatchCr(Id referenceId, Map<String,List<DedupeResponseWrapper.AdditionalInformation>> dedupeMatchCrMap, Set<String> appIds){
        
        if(!dedupeMatchCrMap.isEmpty()){
            List<DedupeResponse__c> dedupeMatchCrList = new List<DedupeResponse__c>();
            Id dedupeMatchCrRecordTypeId = Schema.SObjectType.DedupeResponse__c.getRecordTypeInfosByDeveloperName().get('DedupeMatchCr').getRecordTypeId();
            Map<String,DedupeResponse__c> appDedupeResMap = new Map<String,DedupeResponse__c>();
            Map<String,DedupeResponse__c> appLANMap = new Map<String,DedupeResponse__c>();
            for(DedupeResponse__c dedupeRes : [Select Id,AppId__c,PastAppId__c,Lan__c,LoanAppln__c,Applicant__c,RecordType.Name,Dedupe__c, Dedupe__r.AppId__c,UCID__c,Dedupe__r.UCID__c from DedupeResponse__c where Applicant__c=:referenceId AND (AppId__c IN:appIds OR Dedupe__r.AppId__c IN:appIds)]){//AND (UCID__c IN:ucids OR Dedupe__r.UCID__c IN:ucids)
                if(dedupeRes.RecordType.Name=='Dedupe' && (dedupeRes.UCID__c!=null ||dedupeRes.AppId__c!=null)){
                    appDedupeResMap.put((dedupeRes.UCID__c!=null?dedupeRes.UCID__c:'') +'-'+ (dedupeRes.AppId__c!=null?dedupeRes.AppId__c:''),dedupeRes);
                }
                if(dedupeRes.RecordType.Name=='DedupeMatchCr' && (dedupeRes.Dedupe__r.UCID__c!=null || dedupeRes.Dedupe__r.AppId__c!=null) && dedupeRes.PastAppId__c!=null){
                    appLANMap.put((dedupeRes.Dedupe__r.UCID__c!=null?dedupeRes.Dedupe__r.UCID__c:'') +'-'+ (dedupeRes.Dedupe__r.AppId__c!=null?dedupeRes.Dedupe__r.AppId__c:'') +'-'+ dedupeRes.PastAppId__c,dedupeRes);
                }
            }
            for(String appId : dedupeMatchCrMap.keySet()){
                for(DedupeResponseWrapper.AdditionalInformation additionalInformation : dedupeMatchCrMap.get(appId)){
                    DedupeResponse__c dedupeMatchCr = new DedupeResponse__c();
                    dedupeMatchCr.Applicant__c=appDedupeResMap.get(appId).Applicant__c;
                    dedupeMatchCr.LoanAppln__c=appDedupeResMap.get(appId).LoanAppln__c;
                    dedupeMatchCr.Dedupe__c=appDedupeResMap.get(appId).Id;
                    dedupeMatchCr.RecordTypeId=dedupeMatchCrRecordTypeId;
                    //dedupeMatchCr.AppId__c=appId;
                    dedupeMatchCr.InternalDedupeResponse__c ='Match Found';
                    if(String.isNotBlank(additionalInformation.dpdString)){
                        dedupeMatchCr.SystemDPD__c = additionalInformation.dpdString;
                    }
                    if(String.isNotBlank(additionalInformation.loanType)){
                        dedupeMatchCr.LoanType__c = additionalInformation.loanType;
                    }
                    if(String.isNotBlank(additionalInformation.loanDisbDate)){
                        List<String>dateValue =additionalInformation.loanDisbDate.split('[- : .]');
                        if(dateValue.size()>=7){
                            dedupeMatchCr.LoanDisbDate__c= Date.newInstance(Integer.valueOf(dateValue[0]), Integer.valueOf(dateValue[1]), Integer.valueOf(dateValue[2]));
                        }
                    }
                    if(String.isNotBlank(additionalInformation.currentOutstanding)){
                        dedupeMatchCr.CurrentOutstanding__c = Decimal.valueOf(additionalInformation.currentOutstanding);
                    }
                    if(String.isNotBlank(additionalInformation.existingFedfinaTenure)){
                        dedupeMatchCr.Tenure__c = Decimal.valueOf(additionalInformation.existingFedfinaTenure);
                    }
                    if(String.isNotBlank(additionalInformation.source)){
                        dedupeMatchCr.MatchSource__c = additionalInformation.source;
                    }
                    if(String.isNotBlank(additionalInformation.customerName)){
                        dedupeMatchCr.DedupeMatchName__c = additionalInformation.customerName;
                    }
                    if(String.isNotBlank(additionalInformation.loanAmount)){
                        dedupeMatchCr.LoanAmount__c = Decimal.valueOf(additionalInformation.loanAmount);
                    }
                    if(String.isNotBlank(additionalInformation.loanStatus)){
                        dedupeMatchCr.LoanStatus__c = additionalInformation.loanStatus;
                    }
                    if(String.isNotBlank(additionalInformation.lan)){
                        dedupeMatchCr.Lan__c = additionalInformation.lan;
                    }
                    if(String.isNotBlank(additionalInformation.dpd)){
                        dedupeMatchCr.DPD__c = additionalInformation.dpd;
                    }
                    if(String.isNotBlank(additionalInformation.rejectReason)){
                        dedupeMatchCr.RejectionReason__c = additionalInformation.rejectReason;
                    }
                    if(String.isNotBlank(additionalInformation.applicationId)){
                        dedupeMatchCr.PastAppId__c = additionalInformation.applicationId;
                        if(appLANMap.containsKey(appId +'-'+ additionalInformation.applicationId)){
                            dedupeMatchCr.Id = appLANMap.get(appId +'-'+ additionalInformation.applicationId).Id;
                        }
                    }
                    if(String.isNotBlank(additionalInformation.securitizationFlag)){
                        dedupeMatchCr.SecuritisationStatus__c = additionalInformation.securitizationFlag;
                    }
                    if(String.isNotBlank(additionalInformation.applicationDate)){
                        List<String>dateValue =additionalInformation.applicationDate.split('[- : .]');
                        if(dateValue.size()>=7){
                            dedupeMatchCr.PastAppDate__c= Date.newInstance(Integer.valueOf(dateValue[0]), Integer.valueOf(dateValue[1]), Integer.valueOf(dateValue[2]));
                        }
                    }
                    dedupeMatchCr.LatestReportTime__c = System.now();
                    dedupeMatchCrList.add(dedupeMatchCr);
                }
            }
            
            if(!dedupeMatchCrList.isEmpty()){
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { DedupeResponse__c.SObjectType });
                //List<string> fieldNamesList = New List<string>{'Applicant__c','LoanAppln__c','Dedupe__c','RecordTypeId','SystemDPD__c','LoanType__c','LoanDisbDate__c','CurrentOutstanding__c','Tenure__c','MatchSource__c','DedupeMatchName__c','LoanAmount__c','LoanStatus__c','Lan__c','PastAppId__c','SecuritisationStatus__c','PastAppDate__c','InternalDedupeResponse__c'};
                //   String sObjectName = 'DedupeResponse__c';
                //Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                //flib_SecurityUtils.checkInsert(objType,fieldNamesList);
                uow.registerUpsert(dedupeMatchCrList);
                uow.commitWork();
                
                //insert dedupeMatchCrList;
            }
            
        }
    }
    
    /*public static void updateExistingDedupeResponse(List<DedupeResponse__c> responses){
        if(!responses.isEmpty()){
            for(DedupeResponse__c res : responses){
                res.IsLatest__c=false;
            }
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { DedupeResponse__c.SObjectType });
            List<string> fieldNamesList = New List<string>{'IsLatest__c'};
                String sObjectName = 'DedupeResponse__c';
            Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
            fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
            uow.registerDirty(responses);
            uow.commitWork();
        }
    }*/
    
    public static string replaceAndUpdateString(String toRemove, String toAdd,String actualString,String splitIdentifier){
        String updatedString;
        List<String> updatedStringList = new List<String>();
        if(String.isNotBlank(actualString)){
            List<String> existingStringList = actualString.split(splitIdentifier);
            system.debug(existingStringList);
            if(!existingStringList.isEmpty()){
                for(string value : existingStringList){
                    if(!value.contains(toRemove)){
                        updatedStringList.add(value);
                    }
                }
            }
        }	
        if(String.isNotBlank(toAdd)){
            updatedStringList.add(toAdd);
        }
        
        updatedString= String.join(updatedStringList,splitIdentifier).removeStart(splitIdentifier).removeEnd(splitIdentifier);
        
        return updatedString; 
    }
}