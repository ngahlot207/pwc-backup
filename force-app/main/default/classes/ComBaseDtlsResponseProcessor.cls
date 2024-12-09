public class ComBaseDtlsResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    private static boolean isException =false;
    
    public static void process(List<IntgMsg__c> responses) {
        Set<Id> ids = new Set<Id>();
        Map<Id,Id> ContentDocumentMap =new Map<Id,Id>();
        Map<Id,ContentVersion> ContentVersionMap =new Map<Id,ContentVersion>();
        
        if(!responses.isempty()){
            //Getting IntgMsg__c Id
            for (IntgMsg__c integrationMessage : responses) {
                ids.add(integrationMessage.Id);
            }
        }
        
        if(!ids.isempty()){
            //Getting ContentDocumentId
            for(ContentDocumentLink cdl:[SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN:ids AND 
                                         ContentDocument.Title = 'response.json']){//response.json,hrms testdata (1), hrms testdata (2), manager change, email,HRMScreateNew,HRMSInactiveUser,NewHRMSTestDataInActive
                ContentDocumentMap.put(cdl.LinkedEntityId,cdl.ContentDocumentId);
            }
            //Getting VersionData
            for(ContentVersion cv:[SELECT Id, VersionData,FileType,ContentDocumentId FROM ContentVersion
                                   WHERE ContentDocumentId IN:ContentDocumentMap.values()]){
                ContentVersionMap.put(cv.ContentDocumentId,cv);
            }
        }
        
        if(!ContentVersionMap.isempty()){
            
            for(IntgMsg__c intMsg : responses){
                
                if(ContentDocumentMap.containskey(intMsg.id) && ContentVersionMap.containskey(ContentDocumentMap.get(intMsg.id))){
                    
                    ContentVersion cvdata=ContentVersionMap.get(ContentDocumentMap.get(intMsg.id));
                    Map<IntgMsg__c,ComBaseDtlsResponseWrapper> successResponseMap = new Map<IntgMsg__c,ComBaseDtlsResponseWrapper>();
                    Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
                    
                    if(cvdata!=null){
                        String jsonContent = cvdata.VersionData.toString();
                        ComBaseDtlsResponseWrapper res = (ComBaseDtlsResponseWrapper) JSON.deserialize(jsonContent, ComBaseDtlsResponseWrapper.class);
                        successResponseMap.put(intMsg,res);
                        
                        try{
                            ComBaseDtlsQueueable queueableInstance = new ComBaseDtlsQueueable(successResponseMap,jsonContent);
                            System.enqueueJob(queueableInstance);
                            
                        }
                        catch(Exception ex){
                            GlobalUtility.logMessage('Error', 'ComBaseDtlsResponseProcessor class',
                            'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                        }
                    }
                    
                }
                
            }
        }
        
    }
    
    public static void processSuccess(Map<IntgMsg__c, ComBaseDtlsResponseWrapper> successResp) {
        try {
            
            ComBaseDtlsResponseWrapper resObj = null;
            ComBaseDtlsResponseWrapper.Data dataObj =null;
            ComBaseDtlsResponseWrapper.Metadata metaObj = null;
            List<ComBaseDtlsResponseWrapper.Authorized_signatories> listAuthObj = null;
            ComBaseDtlsResponseWrapper.Company compObj = null;
            List<ComBaseDtlsResponseWrapper.Open_charges> listOpenChObj = null;
            ComBaseDtlsResponseWrapper.Lei leiObj = null;
            ComBaseDtlsResponseWrapper.Registered_address regiAddObj = null;
            
            
            
            fflib_SObjectUnitOfWork uow1 = new fflib_SObjectUnitOfWork(new List<SObjectType> {APIVer__c.SObjectType, APIVerDtl__c.SObjectType ,Applicant__c.SObjectType,LoanApplRelationship__c.SObjectType });
            
            Set<Id> applicantIds = new Set<Id>();
            Set<Id> loanAppIds = new Set<Id>();
            Set<String> directorPans = new Set<String>();
            Map<Id,Id> addressMap = new Map<Id,Id>();
            List<ApplAddr__c> appAddList = new List<ApplAddr__c>();
            List<Applicant__c> appList = new  List<Applicant__c>();
            //Set<Id> appliIds =new Set<Id>();
            
            
            
            
            for (IntgMsg__c msg : successResp.keySet()) {
                
                if (String.isNotBlank(msg.RefId__c)) {
                    applicantIds.add(msg.RefId__c);
                    //appliIds.add(msg.RefId__c);
                }
                if (String.isNotBlank(msg.ParentRefId__c)) {
                    loanAppIds.add(msg.ParentRefId__c);
                }
                
                
                resObj = successResp.get(msg);
                if(resObj!=null && resObj.data!=null && resObj.data.authorized_signatories !=null)
                {
                    for(ComBaseDtlsResponseWrapper.Authorized_signatories eachAuthSig : resObj.data.authorized_signatories){
                        if(eachAuthSig.pan !=null){
                            directorPans.add(eachAuthSig.pan);
                        }
                    }
                }
            }
            
            if(!applicantIds.isEmpty()){
                for(ApplAddr__c appAdd : [select id,Applicant__c,AddrTyp__c from ApplAddr__c where Applicant__c IN : applicantIds and AddrTyp__c = 'Registered place for business']){
                    if(!addressMap.containskey(appAdd.Applicant__c)){
                        addressMap.put(appAdd.Applicant__c,appAdd.Id);
                        
                    }
                }
            }
            
            if(!applicantIds.isEmpty()){
                List<APIVer__c> existingApiVers = getExistingApiVerRecords(applicantIds);
                if (!existingApiVers.isEmpty()) {
                    IntegrationUtility.updateBooleanFlag(existingApiVers, 'IsLatest__c', false);
                }
            }
            
            
            List<Applicant__c> existingAppWIthPans = [SELECT Id,name,PAN__c,LoanAppln__c, FName__c, Gender__c, ApplType__c,DOB__c,Age__c,Nationality__c from Applicant__c where PAN__c IN: directorPans AND ApplType__c ='D' AND LoanAppln__c IN : loanAppIds];
            Set<Id> idApplsExist  =new Set<Id>();
            Map<String, Applicant__c> existAppMapByPAN = new Map<String, Applicant__c>();
            
            for (Applicant__c app : existingAppWithPans) {
                if (app.PAN__c != null) {
                    existAppMapByPAN.put(app.PAN__c +'-'+app.LoanAppln__c, app);
                }
                idApplsExist.add(app.Id);
            }
            
            
            List<LoanApplRelationship__c> listLoanAppRels=[SELECT Id,Related_Person__c,Loan_Applicant__c  from LoanApplRelationship__c where Related_Person__c  In : idApplsExist and Loan_Applicant__c In : applicantIds];
            
            Map<String, LoanApplRelationship__c> existAppRelMap = new Map<String, LoanApplRelationship__c>();
            
            for (LoanApplRelationship__c app : listLoanAppRels) {
                if (app.Related_Person__c != null) {
                    //existAppRelMap.put(app.Related_Person__c, app);
                    existAppRelMap.put(app.Related_Person__c + '-' + app.Loan_Applicant__c, app);
                }
            }
            
            
            System.debug('existAppRelMap ==>'+existAppRelMap);
            System.debug('existAppMapByPAN ==>'+existAppMapByPAN);
            
            
            
            List<APIVer__c> apiVerListInsert = new List<APIVer__c>();
            
            for (IntgMsg__c msg : successResp.keySet()) {
                
                resObj = successResp.get(msg);
                dataObj = resObj != null ? resObj.data : null;
                metaObj = resObj != null ? resObj.metadata : null;
                listAuthObj = dataObj != null ? dataObj.authorized_signatories : null;
                compObj = dataObj != null ? dataObj.company : null;
                listOpenChObj = dataObj != null ? dataObj.open_charges : null;
                leiObj = compObj != null ? compObj.lei : null;
                regiAddObj = compObj != null ? compObj.registered_address : null;
                
                List<ComBaseDtlsResponseWrapper.Address> listAddObj = new List<ComBaseDtlsResponseWrapper.Address>();
                if (listAuthObj != null && !listAuthObj.isEmpty()) {
                    for (ComBaseDtlsResponseWrapper.Authorized_signatories eachAuthObj : listAuthObj) {
                        if (eachAuthObj.address != null) {
                            listAddObj.add(eachAuthObj.address);
                        }
                    }
                }
                
                APIVer__c apiVerObj = new APIVer__c();
                apiVerObj.RecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Probe42').getRecordTypeId();
                apiVerObj.Appl__c = msg.RefId__c;
                apiVerObj.IsLatest__c = true;
                apiVerObj.IntegrationStatus__c = 'Success';
                apiVerObj.Type__c='Probe Basic Company';
                apiVerObj.LoanAplcn__c = msg.ParentRefId__c;
                if (compObj != null) {
                    
                    system.debug('compObj not null :'+compObj);
                    apiVerObj.AuthorizedCapital__c = (compObj.authorized_capital != null) ? compObj.authorized_capital : apiVerObj.AuthorizedCapital__c;
                    apiVerObj.PanCinDin__c = (compObj.cin != null) ? compObj.cin : apiVerObj.PanCinDin__c;
                    apiVerObj.EfilingStatus__c = (compObj.efiling_status != null) ? compObj.efiling_status : apiVerObj.EfilingStatus__c;
                    apiVerObj.DteOfIncorp__c = (compObj.incorporation_date != null) ? Date.valueOf(compObj.incorporation_date) : apiVerObj.DteOfIncorp__c;
                    apiVerObj.LegalName__c = (compObj.legal_name != null) ? compObj.legal_name : apiVerObj.LegalName__c;
                    apiVerObj.PaidupCapital__c = (compObj.paid_up_capital != null) ? Double.valueOf(compObj.paid_up_capital) : apiVerObj.PaidupCapital__c;
                    System.debug('SumOfCharges__c ==>'+compObj.sum_of_charges);
                    apiVerObj.SumOfCharges__c = (compObj.sum_of_charges != null) ? Double.valueOf(String.valueOf(compObj.sum_of_charges)) : apiVerObj.SumOfCharges__c;
                    apiVerObj.ActiveCompliance__c = (compObj.active_compliance != null) ? compObj.active_compliance : apiVerObj.ActiveCompliance__c;
                    apiVerObj.Classification__c = (compObj.classification != null) ? compObj.classification : apiVerObj.Classification__c;
                    apiVerObj.DataStatus__c = (compObj.status != null) ? compObj.status : apiVerObj.DataStatus__c;
                    apiVerObj.LastAgmDate__c = (compObj.last_agm_date != null) ? Date.valueOf(compObj.last_agm_date) : apiVerObj.LastAgmDate__c;
                    apiVerObj.LastFilingDate__c = (compObj.last_filing_date != null) ? compObj.last_filing_date : apiVerObj.LastFilingDate__c;
                    apiVerObj.Email__c = (compObj.email != null) ? compObj.email : apiVerObj.Email__c;
                    apiVerObj.Name__c =  (compObj.legal_name != null) ? compObj.legal_name : apiVerObj.LegalName__c;
                    
                    if (regiAddObj != null) {
                        system.debug('regiAddObj not null :'+regiAddObj);
                        apiVerObj.Address__c=(regiAddObj.full_address != null) ? regiAddObj.full_address : regiAddObj.full_address;
                        apiVerObj.AddrLine1__c = (regiAddObj.address_line1 != null) ? regiAddObj.address_line1 : apiVerObj.AddrLine1__c;
                        apiVerObj.AddrLine2__c = (regiAddObj.address_line2 != null) ? regiAddObj.address_line2 : apiVerObj.AddrLine2__c;
                        apiVerObj.City__c = (regiAddObj.city != null) ? regiAddObj.city : apiVerObj.City__c;
                        apiVerObj.Pincode__c = (regiAddObj.pincode != null) ? regiAddObj.pincode : apiVerObj.Pincode__c;
                        apiVerObj.State__c = (regiAddObj.state != null) ? regiAddObj.state : apiVerObj.State__c;
                        

                        Applicant__c appData = new Applicant__c(Id = msg.RefId__c);
                        if(compObj != null){
                            appData.CIN__c = (compObj.cin != null) ? compObj.cin : '';
                            appList.add(appData);

                        }
                        
                        ///
                        ApplAddr__c adrs = new ApplAddr__c( Applicant__c = msg.RefId__c );
                        if(addressMap.containsKey(msg.RefId__c)){
                            adrs.Id = addressMap.get(msg.RefId__c);
                        }
                        //adrs.Applicant__c = msg.RefId__c;
                        //adrs.Address__c=(regiAddObj.full_address != null) ? regiAddObj.full_address : regiAddObj.full_address;
                        adrs.AddrLine1__c = (regiAddObj.address_line1 != null) ? regiAddObj.address_line1 : '';
                        adrs.AddrLine2__c = (regiAddObj.address_line2 != null) ? regiAddObj.address_line2 : '';
                        adrs.City__c = (regiAddObj.city != null) ? regiAddObj.city : '';
                        adrs.Pincode__c = (regiAddObj.pincode != null) ? regiAddObj.pincode : '';
                        adrs.State__c = (regiAddObj.state != null) ? regiAddObj.state : '';
                        adrs.AddrTyp__c = 'Registered place for business';
                        appAddList.add(adrs);
                    }
                    
                    
                    if (leiObj != null) {
                        system.debug('leiObj not null :'+leiObj);
                        apiVerObj.LeiNumber__c = (leiObj.number_Z != null) ? leiObj.number_Z : apiVerObj.LeiNumber__c;
                        apiVerObj.LeiStatus__c = (leiObj.status != null) ? leiObj.status : apiVerObj.LeiStatus__c;
                        
                    }
                }
                
                if (metaObj != null) {
                    system.debug('metaObj not null :'+metaObj);
                    apiVerObj.ApiVersion__c = metaObj.api_version !=null ? metaObj.api_version:'';
                    apiVerObj.Lstupdt__c = metaObj.last_updated !=null ?  Date.valueOf(metaObj.last_updated) : null;
                }
                //LAK-9573
                apiVerObj.RetriggerRationale__c = msg.RetriRatinal__c;
                apiVerObj.ActionedDate__c = System.today();
                apiVerObj.UserName__c = msg.UserName__c;
                apiVerObj.UserNameRole__c = msg.UserNameRole__c;
                
                //apiVerListInsert.add(apiVerObj);
                uow1.registerNew(apiVerObj);
                
                
                if (listOpenChObj != null && !listOpenChObj.isEmpty()) {
                    for (ComBaseDtlsResponseWrapper.Open_charges eachOc : listOpenChObj) {
                        System.debug('listOpenChObj start '+eachOc);
                        APIVerDtl__c apiVerDtlOpenChrObj = new APIVerDtl__c();
                        apiVerDtlOpenChrObj.Type__c = 'Open Charges';
                        apiVerDtlOpenChrObj.OpenChargesId__c = eachOc.id != null ? String.valueOf(eachOc.id) : '';
                        apiVerDtlOpenChrObj.OpenChargesDate__c = eachOc.date_Z != null ?  Date.valueOf(eachOc.date_Z) : null;
                        apiVerDtlOpenChrObj.HolderName__c = eachOc.holder_name != null ? eachOc.holder_name : '';
                        apiVerDtlOpenChrObj.OpenChargesAmount__c = eachOc.amount != null ? eachOc.amount : 0;
                        apiVerDtlOpenChrObj.OpenChargesType__c = eachOc.type != null ? eachOc.type : '';
                        
                        uow1.registerRelationship(apiVerDtlOpenChrObj, APIVerDtl__c.APIVerification__c, apiVerObj);
                        uow1.registerNew(apiVerDtlOpenChrObj);
                    }
                }
                
                if (listAuthObj != null && !listAuthObj.isEmpty()) {
                    System.debug('listAuthObj start ');
                    for (ComBaseDtlsResponseWrapper.Authorized_signatories eachAuth : listAuthObj) {
                        
                        
                        if(eachAuth.designation!=null && eachAuth.designation.toLowerCase().contains('director'))
                        {
                            //if(existAppMapByPAN.containsKey(eachAuth.pan)){
                                if(eachAuth.pan!=null && msg.ParentRefId__c!=null && existAppMapByPAN.containsKey(eachAuth.pan +'-'+ msg.ParentRefId__c))
                                {
                                    
                                    //update operation
                                    Applicant__c applObj = new Applicant__c();
                                    applObj.Id= existAppMapByPAN.get(eachAuth.pan +'-'+ msg.ParentRefId__c).Id ;
                                    applObj.PAN__c= eachAuth.pan;
                                    applObj.FName__c= eachAuth.name;
                                    applObj.ApplType__c='D';
                                    applobj.DataSource__c = 'API';
                                    
                                    if(eachAuth.gender!=null && eachAuth.gender.equalsIgnoreCase('Male')){
                                        applObj.Gender__c= 'M';
                                    }else if(eachAuth.gender!=null && eachAuth.gender.equalsIgnoreCase('Female')){
                                        applObj.Gender__c= 'F';
                                    }
                                    
                                    applObj.DOB__c= eachAuth.date_of_birth !=null ? setDateFormat(eachAuth.date_of_birth):null ;
                                    applObj.Age__c=eachAuth.age;
                                    
                                    if(eachAuth.nationality!=null && eachAuth.nationality.equalsIgnoreCase('India')){
                                        applObj.Nationality__c='INDIA';
                                    }
                                    applObj.LoanAppln__c = msg.ParentRefId__c;
                                    
                                    uow1.registerDirty(applObj);
                                    
                                    if(msg.RefId__c!=null && eachAuth.pan!=null && existAppRelMap.containsKey(applObj.Id +'-'+ msg.RefId__c))
                                    {
                                        //Update relationship
                                        LoanApplRelationship__c appRelObj = new LoanApplRelationship__c();
                                        
                                        appRelObj.Id=existAppRelMap.get(applObj.Id +'-'+ msg.RefId__c).Id;
                                        
                                        if(eachAuth.address !=null){
                                            appRelObj.AddrLine1__c=eachAuth.address.address_line1 ;
                                            appRelObj.AddrLine2__c= eachAuth.address.address_line2;
                                            appRelObj.City__c= eachAuth.address.city;
                                            appRelObj.Country__c= eachAuth.address.country;
                                            appRelObj.Pincode__c= eachAuth.address.pincode;
                                            appRelObj.State__c= eachAuth.address.state;
                                        }
                                        
                                        appRelObj.DateOfAppointment__c= setDateFormat(eachAuth.date_of_appointment);
                                        appRelObj.DateOfAppCurrentDesig__c= setDateFormat(eachAuth.date_of_appointment_for_current_designation);
                                        appRelObj.DateOfCessation__c= setDateFormat(eachAuth.date_of_cessation);
                                        appRelObj.Designation__c= eachAuth.designation;
                                        appRelObj.Din__c= eachAuth.din;
                                        appRelObj.DinStatus__c= eachAuth.din_status;
                                        appRelObj.Loan_Applicant__c=msg.RefId__c;
                                        appRelObj.Relationship_Type__c='Director';
                                        
                                        uow1.registerRelationship(appRelObj, LoanApplRelationship__c.Related_Person__c, applObj);
                                        uow1.registerDirty(appRelObj);
                                    }else{
                                        //create relationship
                                        LoanApplRelationship__c appRelObj = new LoanApplRelationship__c();
                                        
                                        if(eachAuth.address !=null){
                                            appRelObj.AddrLine1__c=eachAuth.address.address_line1 ;
                                            appRelObj.AddrLine2__c= eachAuth.address.address_line2;
                                            appRelObj.City__c= eachAuth.address.city;
                                            appRelObj.Country__c= eachAuth.address.country;
                                            appRelObj.Pincode__c= eachAuth.address.pincode;
                                            appRelObj.State__c= eachAuth.address.state;
                                        }
                                        
                                        appRelObj.DateOfAppointment__c= setDateFormat(eachAuth.date_of_appointment);
                                        appRelObj.DateOfAppCurrentDesig__c= setDateFormat(eachAuth.date_of_appointment_for_current_designation);
                                        appRelObj.DateOfCessation__c= setDateFormat(eachAuth.date_of_cessation);
                                        appRelObj.Designation__c= eachAuth.designation;
                                        appRelObj.Din__c= eachAuth.din;
                                        appRelObj.DinStatus__c= eachAuth.din_status;
                                        appRelObj.Loan_Applicant__c=msg.RefId__c;
                                        appRelObj.Relationship_Type__c='Director';
                                        
                                        uow1.registerRelationship(appRelObj, LoanApplRelationship__c.Related_Person__c, applObj);
                                        uow1.registerNew(appRelObj);
                                        
                                    }
                                }
                                else{
                                    //insert operation
                                    Applicant__c applObj = new Applicant__c();
                                    applObj.PAN__c= eachAuth.pan;
                                    applObj.FName__c= eachAuth.name;
                                    applObj.ApplType__c='D';
                                    applobj.DataSource__c = 'API';
                                    
                                    if(eachAuth.gender!=null && eachAuth.gender.equalsIgnoreCase('Male')){
                                        applObj.Gender__c= 'M';
                                    }else if(eachAuth.gender!=null && eachAuth.gender.equalsIgnoreCase('Female')){
                                        applObj.Gender__c= 'F';
                                    }
                                    
                                    applObj.DOB__c= eachAuth.date_of_birth !=null ? setDateFormat(eachAuth.date_of_birth):null ;
                                    applObj.Age__c=eachAuth.age;
                                    
                                    if(eachAuth.nationality!=null && eachAuth.nationality.equalsIgnoreCase('India')){
                                        applObj.Nationality__c='INDIA';
                                    }
                                    applObj.LoanAppln__c = msg.ParentRefId__c;
                                    
                                    uow1.registerNew(applObj);
                                    
                                    LoanApplRelationship__c appRelObj = new LoanApplRelationship__c();
                                    
                                    if(eachAuth.address !=null){
                                        appRelObj.AddrLine1__c=eachAuth.address.address_line1 ;
                                        appRelObj.AddrLine2__c= eachAuth.address.address_line2;
                                        appRelObj.City__c= eachAuth.address.city;
                                        appRelObj.Country__c= eachAuth.address.country;
                                        appRelObj.Pincode__c= eachAuth.address.pincode;
                                        appRelObj.State__c= eachAuth.address.state;
                                    }
                                    
                                    appRelObj.DateOfAppointment__c= setDateFormat(eachAuth.date_of_appointment);
                                    appRelObj.DateOfAppCurrentDesig__c= setDateFormat(eachAuth.date_of_appointment_for_current_designation);
                                    appRelObj.DateOfCessation__c= setDateFormat(eachAuth.date_of_cessation);
                                    appRelObj.Designation__c= eachAuth.designation;
                                    appRelObj.Din__c= eachAuth.din;
                                    appRelObj.DinStatus__c= eachAuth.din_status;
                                    appRelObj.Loan_Applicant__c=msg.RefId__c;
                                    appRelObj.Relationship_Type__c='Director';
                                    
                                    uow1.registerRelationship(appRelObj, LoanApplRelationship__c.Related_Person__c, applObj);
                                    uow1.registerNew(appRelObj);
                                    
                                }
                                //Insert or update Done
                                
                            }
                            //Main If condition END
                            
                            
                            APIVerDtl__c apiVerDtlAuthObj = new APIVerDtl__c();
                            
                            apiVerDtlAuthObj.Type__c = 'Authorized Signatories';
                            apiVerDtlAuthObj.Pan__c = (eachAuth.pan != null) ? eachAuth.pan : apiVerDtlAuthObj.Pan__c;
                            apiVerDtlAuthObj.Din__c = (eachAuth.din != null) ? eachAuth.din : apiVerDtlAuthObj.Din__c;
                            apiVerDtlAuthObj.AuthSignName__c = (eachAuth.name != null) ? eachAuth.name : apiVerDtlAuthObj.AuthSignName__c;
                            apiVerDtlAuthObj.Designation__c = (eachAuth.designation != null) ? eachAuth.designation : apiVerDtlAuthObj.Designation__c;
                            apiVerDtlAuthObj.DinStatus__c = (eachAuth.din_status != null) ? eachAuth.din_status : apiVerDtlAuthObj.DinStatus__c;
                            apiVerDtlAuthObj.Gender__c = (eachAuth.gender != null) ? eachAuth.gender : apiVerDtlAuthObj.Gender__c;
                            apiVerDtlAuthObj.DOB__c = (eachAuth.date_of_birth != null) ? Date.valueOf(eachAuth.date_of_birth) : apiVerDtlAuthObj.DOB__c;
                            apiVerDtlAuthObj.Age__c = (eachAuth.age != null) ? eachAuth.age : apiVerDtlAuthObj.Age__c;
                            apiVerDtlAuthObj.DateOfAppointment__c = (eachAuth.date_of_appointment != null) ? Date.valueOf(eachAuth.date_of_appointment) : apiVerDtlAuthObj.DateOfAppointment__c;
                            apiVerDtlAuthObj.DateAppCurrentDesig__c = (eachAuth.date_of_appointment_for_current_designation != null) ? Date.valueOf(eachAuth.date_of_appointment_for_current_designation) : apiVerDtlAuthObj.DateAppCurrentDesig__c;
                            apiVerDtlAuthObj.DateOfCessation__c = (eachAuth.date_of_cessation != null) ? Date.valueOf(eachAuth.date_of_cessation) : apiVerDtlAuthObj.DateOfCessation__c;
                            apiVerDtlAuthObj.Nationality__c = (eachAuth.nationality != null) ? eachAuth.nationality : apiVerDtlAuthObj.Nationality__c;
                            
                            
                            if(eachAuth !=null){
                                System.debug('eachAuth :'+eachAuth);
                                ComBaseDtlsResponseWrapper.Address address = eachAuth.address;
                                if (address != null) {
                                    apiVerDtlAuthObj.AddrLine1__c = address.address_line1 !=null ? address.address_line1:'';
                                    apiVerDtlAuthObj.AddrLine2__c = address.address_line2 !=null ? address.address_line2 :'';
                                    apiVerDtlAuthObj.City__c = address.city !=null ? address.city:'';
                                    apiVerDtlAuthObj.Pincode__c = address.pincode !=null ? address.pincode:'';
                                    apiVerDtlAuthObj.State__c = address.state !=null ? address.state:'';
                                    apiVerDtlAuthObj.Country__c = address.country !=null ? address.country:'';
                                }
                            }
                            
                            uow1.registerRelationship(apiVerDtlAuthObj, APIVerDtl__c.APIVerification__c, apiVerObj);
                            uow1.registerNew(apiVerDtlAuthObj);
                            
                            
                        }
                    }

                    APICalloutTracker.update_ApiTrackerWithIntMsg(msg.Id,msg.Svc__c, msg.RefId__c, 'Success');
                }
                //for loop end
                if(!appAddList.isEmpty()){
                    upsert appAddList;
                }
                if(!appList.isEmpty()){
                    update appList;
                }
                uow1.commitWork();
                
                
            }
            catch(Exception ex) {
                GlobalUtility.logMessage('Error', 'ComBaseDtlsResponseProcessor',
                'processSuccess', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
            
        }
        
        public static Date setDateFormat(String datePass)
        {
            if (datePass != null) {
                return Date.valueOf(datePass);
            }
            else{
                return null;
            }
        }
        
        private static List<APIVer__c> getExistingApiVerRecords(Set<Id> applicantIds) {
            system.debug('making list true');
            return [SELECT Id, Appl__c, IsLatest__c, RecordType.Name,Type__c FROM APIVer__c WHERE Appl__c IN :applicantIds AND RecordType.DeveloperName = 'Probe42' AND IsLatest__c = true and Type__c ='Probe Basic Company'];
        }
        
        public static Map<Id, Id> getIdForApiVerDetls(Set<Id> IdOfAppls){
            Map<Id, Id> applToApiVerIdMap1 = new Map<Id, Id>();
            if (IdOfAppls == null || IdOfAppls.isEmpty()) {
                return applToApiVerIdMap1; // Return an empty map
            }
            List<APIVer__c> listFinalAPiver = [
                SELECT Id, Appl__c, IsLatest__c, RecordType.Name
                FROM APIVer__c
                WHERE Appl__c IN :IdOfAppls
                AND RecordType.Name = 'Probe42'
                AND IsLatest__c = true
        ];
            
            for (APIVer__c eachApiVer : listFinalAPiver) {
                applToApiVerIdMap1.put(eachApiVer.Appl__c, eachApiVer.Id);
            }
            return applToApiVerIdMap1;
        }
        
        //*******************************************************************************************************************************************
        public static void processFailure(String failureresStr,Map<IntgMsg__c, ComBaseDtlsResponseWrapper> failureResp){
            
            try{
                
                
                
                Set<Id> applicantIds =new Set<Id>();
                
                Id recordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Probe42').getRecordTypeId();
                
                
                List<APIVer__c> appVerList=new List<APIVer__c>();
                
                //looping to get KycIds
                for(IntgMsg__c msg:failureResp.keyset()){
                    
                    if(string.isNotblank(msg.RefId__c)){
                        applicantIds.add(msg.RefId__c);
                    }
                }
                
                
                //SOQL to check old records
                List<APIVer__c> apiVer =[Select id,Appl__c,IsLatest__c,RecordType.Name,Type__c from APIVer__c Where Appl__c IN:applicantIds AND RecordType.DeveloperName='Probe42' AND IsLatest__c=true and Type__c ='Probe Basic Company'];
                
                if(!apiVer.isEmpty()){
                    IntegrationUtility.updateBooleanFlag(apiVer,'IsLatest__c',false);
                }
                
                //Looping to update the records
                for(IntgMsg__c msg:failureResp.keyset()){
                    
                    if(failureResp.containsKey(msg) && String.isNotblank(msg.RefId__c)){
                        
                        APIVer__c apiveri =new APIVer__c();
                        apiveri.Appl__c=msg.RefId__c;
                        apiveri.Type__c='Probe Basic Company';
                        //LAK-9573
                        apiveri.RetriggerRationale__c = msg.RetriRatinal__c;
                        apiveri.ActionedDate__c =System.today();
                        apiveri.UserName__c = msg.UserName__c;
                        apiveri.UserNameRole__c = msg.UserNameRole__c;
                        apiveri.IntegrationStatus__c='Failure';
                        apiveri.LoanAplcn__c = msg.ParentRefId__c;
                        apiveri.IntegrationErrorMessage__c= failureresStr !=null ? failureresStr:'';
                        apiveri.IsLatest__c=true;
                        apiveri.RecordTypeId=recordTypeId!=null?recordTypeId:'';
                        appVerList.add(apiveri);
                        APICalloutTracker.update_ApiTrackerWithIntMsg(msg.Id,msg.Svc__c, msg.RefId__c, 'Failure');
                        
                    }
                    
                    
                }
                
                if(!appVerList.isEmpty()) {
                    System.debug('inside list not empty creation');
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> {APIVer__c.SObjectType});
                    String sObjectName = 'APIVer__c';
                    List<String> fieldNamesList = new List<String>{'Appl__c','LoanAplcn__c','Type__c','IntegrationStatus__c','IntegrationErrorMessage__c','IsLatest__c','RecordTypeId'};
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerNew(appVerList);
                    uow.commitWork();
                }
            }catch (Exception ex) {
                GlobalUtility.logMessage('Error', 'ComBaseDtlsResponseProcessor',
                'processFailure', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
            
            
        }
    }