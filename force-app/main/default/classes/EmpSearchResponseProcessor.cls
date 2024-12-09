public with sharing class EmpSearchResponseProcessor{}
/*
EmpSearchResponseProcessor implements IintMsgCalloutResponseProcessor{
    public static void process(List<IntgMsg__c> responses){

         Map<IntgMsg__c,EmpSearchResponseWrapper> successResponseMap = new Map<IntgMsg__c,EmpSearchResponseWrapper>();
         Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
         for(IntgMsg__c integrationMessage : responses){
            if(integrationMessage.Svc__c != GlobalConstants.INT_CONFIG_SERVICE_RISK_RATING
               && integrationMessage.BU__c != GlobalConstants.INT_MSG_BU_TYPE){
                   throw new processException('Error! This is not the correct service'); 
               }
            try{
                if(String.isNotBlank(integrationMessage.Resp__c)){
                    
                        EmpSearchResponseWrapper  res =(EmpSearchResponseWrapper) JSON.deserialize(integrationMessage.Resp__c,EmpSearchResponseWrapper.class);
                        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(integrationMessage.Resp__c);
                        String strResp='';

                        if (jsonMap.containsKey('status-code')) {
                            strResp = (String) jsonMap.get('status-code');
                        }
                        System.debug('strResp='+strResp);
                        if(strResp == String.valueOf(GlobalConstants.karza_Status_101)){//101
                            successResponseMap.put(integrationMessage,res);
                        }
                        else if(strResp != String.valueOf(GlobalConstants.karza_Status_101)){
                            System.debug('Failure response');
                            failureResponseMap.put(integrationMessage,GlobalConstants.karza_Status_Code_Authn_Description.ContainsKey(Integer.valueOf(strResp))?GlobalConstants.karza_Status_Code_Authn_Description.get(Integer.valueOf(strResp)):'');
                        }
                }
            }
            catch(Exception ex){
                failureResponseMap.put(integrationMessage,IntegrationUtility.getCustomErrorMessage(ex.getMessage().substringBefore(':')));
               // GlobalUtility.logMessage('Error', 'EmpSearchResponseProcessor class', 
                 //                        'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }

        if(successResponseMap!=null && !successResponseMap.isEmpty()){
                processSuccess(successResponseMap);
        }
        if(failureResponseMap!=null &&  !failureResponseMap.isEmpty()){
                processFailure(failureResponseMap);
        }

    }

    public static Map<Id, Id> getIdForApiVerDetls(Set<Id> IdOfAppls){
        
        Map<Id, Id> applToApiVerIdMap1 = new Map<Id, Id>();
        if (IdOfAppls == null || IdOfAppls.isEmpty()) {
                return applToApiVerIdMap1; // Return an empty map
        }
        
        List<APIVer__c> listFinalAPiver = [SELECT Id, Appl__c, IsLatest__c, RecordType.Name FROM APIVer__c
                WHERE Appl__c IN :IdOfAppls AND RecordType.Name = 'Employment' AND IsLatest__c = true ];

                for (APIVer__c eachApiVer : listFinalAPiver) {
                    applToApiVerIdMap1.put(eachApiVer.Appl__c, eachApiVer.Id);
                }

            return applToApiVerIdMap1;
        }
    
    
    public static void processSuccess(Map<IntgMsg__c,EmpSearchResponseWrapper> successResp){ 
        try{
        Set<Id> applicantsIds =new Set<Id>();
        List<APIVer__c> apiVerListInsert = new List<APIVer__c>();

        if(successResp!=null && !successResp.isEmpty()){
        for(IntgMsg__c intmsg:successResp.keyset()){
            if(successResp.containsKey(intmsg) && string.isNotblank(intmsg.ParentRefId__c)){
                    applicantsIds.add(intmsg.ParentRefId__c);
            }
        }
        }

        //SOQL to check old records
        List<APIVer__c> apiVerLists =[Select id,Appl__c,IsLatest__c,RecordType.Name from APIVer__c Where Appl__c IN:applicantsIds AND RecordType.Name='Employment' AND IsLatest__c=true];
        if(apiVerLists!=null &&  !apiVerLists.isEmpty()){
            IntegrationUtility.updateBooleanFlag(apiVerLists,'IsLatest__c',false);
        } 

        Id empRecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Employment').getRecordTypeId();
        
         
        fflib_SObjectUnitOfWork uow1 = new fflib_SObjectUnitOfWork(new List<SObjectType> {APIVer__c.SObjectType, APIVerDtl__c.SObjectType  }); 
        fflib_SObjectUnitOfWork uow2 = new fflib_SObjectUnitOfWork(new List<SObjectType> {APIVer__c.SObjectType, APIVerDtl__c.SObjectType }); 

            EmpSearchResponseWrapper res =null;
            EmpSearchResponseWrapper.Result resultObject = null;
            EmpSearchResponseWrapper.NameLookup nameLookupObj = null;
            EmpSearchResponseWrapper.Email emailObj= null;
            EmpSearchResponseWrapper.Data dataObj =null;
            EmpSearchResponseWrapper.Whois whoIsObj = null;
            EmpSearchResponseWrapper.Registrant regisObj=null;

        if(successResp!=null){
        for(IntgMsg__c msg:successResp.keyset()){
            if(successResp.containsKey(msg)){

            APIVer__c apiVerObj =new APIVer__c(); //Main Object
            
            res =successResp.get(msg);
            
            if(res!=null){
                resultObject = res.result;
            }
            
            if(resultObject !=null){
                nameLookupObj = res.result.nameLookup;
            }

            if(res!=null && resultObject !=null){
                emailObj= res.result.email;
            }    

            if(res!=null && resultObject !=null && emailObj!=null){
            dataObj =res.result.email.data;
            }  
            
            if(res!=null && resultObject !=null && emailObj!=null){
            whoIsObj = res.result.email.whois;
            }

            if(res!=null && resultObject !=null && emailObj!=null && whoIsObj!=null){
            regisObj=res.result.email.whois.registrant;
            }

            apiVerObj.RecordTypeId  =empRecordTypeId;
            apiVerObj.Appl__c=msg.ParentRefId__c;
            apiVerObj.IsLatest__c=true;
            apiVerObj.IntegrationStatus__c ='Success';

            //nameLookup
            if(nameLookupObj!=null){
            apiVerObj.Organization__c = (res.result.nameLookup.organizationName!=null) ? res.result.nameLookup.organizationName: '' ;
            apiVerObj.isNameExact__c =res.result.nameLookup.isNameExact !=null ? Boolean.valueOf(res.result.nameLookup.isNameExact):false;
            apiVerObj.isEmployed__c =res.result.nameLookup.isEmployed !=null ? Boolean.valueOf(res.result.nameLookup.isEmployed) :false;
            apiVerObj.isRecent__c =res.result.nameLookup.isRecent !=null ? Boolean.valueOf(res.result.nameLookup.isRecent) :false ;
            apiVerObj.isNameUnique__c =res.result.nameLookup.isNameUnique!=null ? Boolean.valueOf(res.result.nameLookup.isNameUnique):false;
            apiVerObj.EmployeeName__c =res.result.nameLookup.employeeName !=null ? res.result.nameLookup.employeeName :'';
            apiVerObj.isNameExact__c =res.result.nameLookup.isNameExact !=null ?  Boolean.valueOf(res.result.nameLookup.isNameExact):false;
            apiVerObj.isEmployed__c=res.result.nameLookup.isEmployed !=null ? Boolean.valueOf(res.result.nameLookup.isEmployed):false;
            apiVerObj.isRecent__c=res.result.nameLookup.isRecent !=null ? Boolean.valueOf(res.result.nameLookup.isRecent):false;
            apiVerObj.EmployeeName__c=res.result.nameLookup.employeeName!=null ? res.result.nameLookup.employeeName:'';
            }
            //data
            if(dataObj!=null){
            apiVerObj.disposable__c= res.result.email.data.disposable !=null ? Boolean.valueOf(res.result.email.data.disposable):false;
            apiVerObj.webmail__c= res.result.email.data.webmail !=null ? Boolean.valueOf(res.result.email.data.webmail) :false ;
            apiVerObj.resultEpfoAPI__c=res.result.email.data.result !=null ? String.valueOf(res.result.email.data.result):'' ;
            apiVerObj.acceptAll__c=res.result.email.data.acceptAll !=null ? res.result.email.data.acceptAll :true;
            apiVerObj.smtpCheck__c=res.result.email.data.smtpCheck !=null ? res.result.email.data.smtpCheck :true;
            apiVerObj.regexp__c=res.result.email.data.regexp !=null ?Boolean.valueOf(res.result.email.data.regexp):false;
            apiVerObj.mxRecords__c=res.result.email.data.mxRecords!=null ?Boolean.valueOf(res.result.email.data.mxRecords):false ;
            apiVerObj.Email__c= res.result.email.data.email !=null ? res.result.email.data.email :'';
            }

            //whois
            if(whoIsObj !=null){
            apiVerObj.DomainCrtnDate__c=  String.valueOf(res.result.email.whois.creationDate) !=null ? getDateValue(String.valueOf(res.result.email.whois.creationDate)): null ;
            apiVerObj.LastDomainUpdDate__c= String.valueOf(res.result.email.whois.updateDate)!=null ? getDateValue(String.valueOf(res.result.email.whois.updateDate)): null ;
            apiVerObj.DomainExpDate__c=  String.valueOf(res.result.email.whois.expirationDate)!=null ? getDateValue(String.valueOf(res.result.email.whois.expirationDate)): null ;
            }

            //registrant
            if(regisObj!=null){
            apiVerObj.NameOfDomainRegistrant__c= res.result.email.whois.registrant.name!=null ? res.result.email.whois.registrant.name :'' ;
            apiVerObj.OrgNameDomainRegistrant__c= res.result.email.whois.registrant.organization!=null ? res.result.email.whois.registrant.organization:'';
            apiVerObj.StreetAddOfDomainRegistrant__c= res.result.email.whois.registrant.street !=null ? res.result.email.whois.registrant.street:'';
            apiVerObj.AddCityOfAddDomainRegistrant__c= res.result.email.whois.registrant.city !=null ? res.result.email.whois.registrant.city:'';
            apiVerObj.PostalCodeOfDomainReg__c= res.result.email.whois.registrant.postal !=null ? res.result.email.whois.registrant.postal:'';
            apiVerObj.CountryOfDomainRegis__c= res.result.email.whois.registrant.country !=null ? res.result.email.whois.registrant.country:'';
            apiVerObj.RegisteredFaxOfTheDomainReg__c= res.result.email.whois.registrant.fax!=null ? res.result.email.whois.registrant.fax:'';
            apiVerObj.RegEmailOfDomainReg__c= res.result.email.whois.registrant.email!=null ? res.result.email.whois.registrant.email:'';
            apiVerObj.StateProvinceOfDomainReg__c= res.result.email.whois.registrant.stateprovince!=null ? res.result.email.whois.registrant.stateprovince:'';
            
            }
            
            //email
            if(emailObj!=null)
            {
            apiVerObj.NameConfidence__c= res.result.email.nameConfidence!=null ? String.valueOf(res.result.email.nameConfidence) :'';
            }
         
            uow1.registerNew(apiVerObj);
            
            List<EmpSearchResponseWrapper.Uan> listUan = resultObject!=null ? resultObject.uan : null ;
            
            if(listUan!=null && !listUan.isEmpty()){
            for(EmpSearchResponseWrapper.Uan eachUan :listUan ){

                APIVerDtl__c apiVerDtlEmpHisObj=new APIVerDtl__c();
                    //apiVerDtlEmpHisObj.APIVerification__c = apiObjIds;
                    apiVerDtlEmpHisObj.Type__c='UAN';
                    apiVerDtlEmpHisObj.Uan__c= eachUan.uan !=null ?eachUan.uan:'' ;
                    uow1.registerRelationship(apiVerDtlEmpHisObj, APIVerDtl__c.APIVerification__c, apiVerObj);  
					uow1.registerNew(apiVerDtlEmpHisObj);
                
                    List<EmpSearchResponseWrapper.Employer> listEmployer = eachUan!=null ? eachUan.employer :null;

                if(listEmployer!=null && !listEmployer.isEmpty()){
                for(EmpSearchResponseWrapper.Employer eachEmployer : listEmployer){
                    
                    APIVerDtl__c apiVerDtlEmpHisObjRel=new APIVerDtl__c();//3rd level
                    apiVerDtlEmpHisObjRel.Type__c='Employers History';
                    apiVerDtlEmpHisObjRel.Employer_name__c=eachEmployer.name !=null ?eachEmployer.name:'';
                    //apiVerDtlEmpHisObjRel.memberId__c=eachEmployer.memberId !=null ?eachEmployer.memberId :'';  
                    apiVerDtlEmpHisObjRel.settled__c='';//eachEmployer.settled ;  
                    apiVerDtlEmpHisObjRel.isNameUnique__c=eachEmployer.isNameUnique!=null ?Boolean.valueOf(eachEmployer.isNameUnique):false; 
                    apiVerDtlEmpHisObjRel.MatchName__c=eachEmployer.matchName !=null ?eachEmployer.matchName:'';  
                    apiVerDtlEmpHisObjRel.LastMonth__c=eachEmployer.lastMonth!=null ?eachEmployer.lastMonth :'';  
                    apiVerDtlEmpHisObjRel.IsRecent__c=eachEmployer.isRecent !=null ?Boolean.valueOf(eachEmployer.isRecent):false;  
                    apiVerDtlEmpHisObjRel.IsNameExact__c=eachEmployer.isNameExact !=null ?Boolean.valueOf(eachEmployer.isNameExact):false ; 
                    apiVerDtlEmpHisObjRel.IsEmployed__c=eachEmployer.isEmployed!=null ?Boolean.valueOf(eachEmployer.isEmployed):false;  
                    apiVerDtlEmpHisObjRel.Name_Confidence__c=eachEmployer.nameConfidence!=null ?eachEmployer.nameConfidence:0;  
                    apiVerDtlEmpHisObjRel.emplrScore__c= eachEmployer.emplrScore !=null ? Decimal.valueOf(String.valueOf(eachEmployer.emplrScore)):0;  
                    apiVerDtlEmpHisObjRel.UanNameMatch__c=eachEmployer.uanNameMatch !=null ?Boolean.valueOf(eachEmployer.uanNameMatch):false;  
                    apiVerDtlEmpHisObjRel.ApiVerDetails__c=apiVerDtlEmpHisObj.Id;
                   

                    uow2.registerRelationship(apiVerDtlEmpHisObjRel, APIVerDtl__c.ApiVerDetails__c, apiVerDtlEmpHisObj);
                    uow2.registerRelationship(apiVerDtlEmpHisObjRel, APIVerDtl__c.APIVerification__c, apiVerObj);
                    uow2.registerNew(apiVerDtlEmpHisObjRel);


                }
                }
                }
            }
            //Inserting 'Employers History' Records End

            //Inserting 'Matches' Records Start
            List<EmpSearchResponseWrapper.Matches> matchesList= nameLookupObj!=null ? res.result.nameLookup.matches :null;
            
            if(matchesList!=null && !matchesList.isEmpty()){
            for(EmpSearchResponseWrapper.Matches eachMatch : matchesList){
                    APIVerDtl__c apiVerDtlMatchObj=new APIVerDtl__c();
                    apiVerDtlMatchObj.Type__c  ='Matches';
                    apiVerDtlMatchObj.Name__c= eachMatch.name!=null ?eachMatch.name:'';
                    apiVerDtlMatchObj.confidence__c=eachMatch.confidence!=null ? eachMatch.confidence:0;
                    apiVerDtlMatchObj.estId__c=eachMatch.estId !=null ?eachMatch.estId:'';
                
                Map<String,Boolean> eachMap=eachMatch.epfHistory;
                Integer monthCount = 1; // To keep track of the month number

                List<String> strMonths = new List<String>();
                if(eachMap!=null && !eachMap.isEmpty()){
                for (String key : eachMap.keySet()) {
                Boolean value = eachMap.get(key);
                    String strResult = key + '_'+ value;
                    strMonths.add(strResult);
                    
                }
                }

                if(strMonths!=null && !strMonths.isEmpty()){

                    for(String eachStr: strMonths){
                    String[] arrStr=eachStr.split('_'); 
                    
                    if (monthCount == 1) {
                        apiVerDtlMatchObj.epfHistory_Month_1__c =  Boolean.valueOf(arrStr[1]);
                        apiVerDtlMatchObj.EpfHistory_Month_1_Name__c = arrStr[0];
                    } else if (monthCount == 2) {
                        apiVerDtlMatchObj.epfHistory_Month_2__c = Boolean.valueOf(arrStr[1]);
                        apiVerDtlMatchObj.EpfHistory_Month_2_Name__c = arrStr[0];
                    } else if (monthCount == 3) {
                        apiVerDtlMatchObj.epfHistory_Month_3__c = Boolean.valueOf(arrStr[1]);
                        apiVerDtlMatchObj.EpfHistory_Month_3_Name__c = arrStr[0];
                    }

                    monthCount++;
                }
                }

                uow1.registerRelationship(apiVerDtlMatchObj, APIVerDtl__c.APIVerification__c, apiVerObj);  
				uow1.registerNew(apiVerDtlMatchObj);

            }
            }
            //Inserting 'Matches' Records End

            //Inserting 'Employers History' Records Start
            List<EmpSearchResponseWrapper.EpfHistory> listEpfHis= nameLookupObj!=null ? res.result.nameLookup.epfHistory :null ;

            if(listEpfHis!=null && !listEpfHis.isEmpty()){
                for(EmpSearchResponseWrapper.EpfHistory eachEpfHis : listEpfHis ){
                    
                    APIVerDtl__c apiVerDtlEpfHisObj=new APIVerDtl__c();
                    apiVerDtlEpfHisObj.Type__c  ='EPF History';
                    apiVerDtlEpfHisObj.TotalAmountFiledbyEmployer__c=eachEpfHis.totalAmount!=null ?Decimal.valueOf(eachEpfHis.totalAmount):0;
                    apiVerDtlEpfHisObj.TotalMembers__c=eachEpfHis.totalMembers !=null ? Decimal.valueOf(eachEpfHis.totalMembers):0;
                    apiVerDtlEpfHisObj.formatted_wage_month__c= eachEpfHis.formatted_wage_month!=null ?Decimal.valueOf(eachEpfHis.formatted_wage_month):0;
                    apiVerDtlEpfHisObj.wageMonth__c=eachEpfHis.wageMonth!=null ?eachEpfHis.wageMonth:'';

                    uow1.registerRelationship(apiVerDtlEpfHisObj, APIVerDtl__c.APIVerification__c, apiVerObj);  
				    uow1.registerNew(apiVerDtlEpfHisObj);


                }
            }    
            //Inserting 'Employers History' Records End

            //Inserting 'Establishments' Records Start
            List<EmpSearchResponseWrapper.EstInfo> listEstinfo= nameLookupObj!=null ? res.result.nameLookup.estInfo :null;
             System.debug('listEstinfo new :'+listEstinfo);
            if(listEstinfo!=null && !listEstinfo.isEmpty() ){
            for(EmpSearchResponseWrapper.EstInfo eachEstInfo : listEstinfo){

            APIVerDtl__c apiVerDtlEstObj=new APIVerDtl__c();

            apiVerDtlEstObj.Type__c ='Establishments';    
            apiVerDtlEstObj.Address__c=eachEstInfo.address!=null ?eachEstInfo.address:'';
            apiVerDtlEstObj.contactNo__c=eachEstInfo.contactNo!=null ?eachEstInfo.contactNo:'';
            apiVerDtlEstObj.EmailId__c=eachEstInfo.emailId!=null ?eachEstInfo.emailId:'';
            apiVerDtlEstObj.estId__c=eachEstInfo.estId!=null ?eachEstInfo.estId:'';
            uow1.registerRelationship(apiVerDtlEstObj, APIVerDtl__c.APIVerification__c, apiVerObj);  
			uow1.registerNew(apiVerDtlEstObj);
            
            }
            }
            }  
            uow1.commitWork();
            uow2.commitWork();

        }//if map contains ends

        }//for loop ends
        }
        catch (Exception ex) {
            //GlobalUtility.logMessage('Error', 'EmpSearchResponseProcessor', 
                 //                    'processSuccess', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }


    public static Date  getDateValue(String passDate)
    {
        if(passDate !=null){
            String[] arrStr =passDate.split('-');
            Date  dtNew = Date.newInstance( Integer.valueOf(arrStr[2]), Integer.valueOf(arrStr[1]), Integer.valueOf(arrStr[0]));
            return dtNew;
        }
        else{
            return null;
        }
    }

    public static void processFailure(Map<IntgMsg__c,String> failureResp){
        try{
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> {APIVer__c.SObjectType});
            Set<Id> applicantIds =new Set<Id>();
            List<APIVer__c> appVerList=new List<APIVer__c>();
            Id recordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Employment').getRecordTypeId();
            if(failureResp!=null && !failureResp.isEmpty()){
            for(IntgMsg__c msg:failureResp.keyset()){
                
                if(string.isNotblank(msg.ParentRefId__c)){
                    applicantIds.add(msg.ParentRefId__c);
                }
            }
             }
            if(!applicantIds.isEmpty()){
                List<APIVer__c> apiVer =[Select id,Appl__c,IsLatest__c,RecordType.Name from APIVer__c Where Appl__c IN:applicantIds AND RecordType.Name='Employment' AND IsLatest__c=true];
                if(!apiVer.isEmpty()){
                    IntegrationUtility.updateBooleanFlag(apiVer,'IsLatest__c',false);
                }
            }
            
            //update error message
            if(failureResp!=null && !failureResp.isEmpty()){
            for(IntgMsg__c intmsg:failureResp.keyset()){
                //Creating API Verification Record
                if(String.isNotblank(intmsg.ParentRefId__c)){
                    APIVer__c apiveri =new APIVer__c();
                    apiveri.Appl__c=intmsg.ParentRefId__c;
                    apiveri.IntegrationStatus__c='Failure';
                    apiveri.IntegrationErrorMessage__c=failureResp.get(intmsg);
                    apiveri.IsLatest__c=true;
                    apiveri.RecordTypeId=recordTypeId!=null?recordTypeId:'';
                    appVerList.add(apiveri);
                }
                APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Failure');
            }
            }
            if(!appVerList.isEmpty()) {
                String sObjectName = 'APIVer__c';
                List<String> fieldNamesList = new List<String>{'Appl__c','IntegrationStatus__c','IntegrationErrorMessage__c','IsLatest__c','RecordTypeId'};
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerNew(appVerList);
            }
            uow.commitWork();
            
        }catch (Exception ex) {
            //GlobalUtility.logMessage('Error', 'EmpSearchResponseProcessor', 
                 //                    'processFailure', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }

}*/