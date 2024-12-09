public class LLPBaseDtlsResponseProcessor implements IintMsgCalloutResponseProcessor{
 
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
                    Map<IntgMsg__c,LLPBaseDtlsResponseWrapper> successResponseMap = new Map<IntgMsg__c,LLPBaseDtlsResponseWrapper>();
                    Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
                    
                    if(cvdata!=null){
                        String jsonContent = cvdata.VersionData.toString();
                        LLPBaseDtlsResponseWrapper res = (LLPBaseDtlsResponseWrapper) JSON.deserialize(jsonContent, LLPBaseDtlsResponseWrapper.class);
                        successResponseMap.put(intMsg,res);
                        
                        try{
                             LLPBaseDtlsQueueable queueableInstance = new LLPBaseDtlsQueueable(successResponseMap,jsonContent);
                             System.enqueueJob(queueableInstance);
                            
                        }
                        catch(Exception ex){
                             GlobalUtility.logMessage('Error', 'LLPBaseDtlsResponse Processor class', 
                                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                        }
                    }
                    
                }
                
            }
        }
        
    }



    //*******************************************************************************************************************************************
   
   
public static void processSuccess(Map<IntgMsg__c, LLPBaseDtlsResponseWrapper> successResp) {
        try {
            fflib_SObjectUnitOfWork uow1 = new fflib_SObjectUnitOfWork(new List<SObjectType> {APIVer__c.SObjectType, APIVerDtl__c.SObjectType  }); 
            
            //fflib_SObjectUnitOfWork uow1 = new fflib_SObjectUnitOfWork(new List<SObjectType>{IntgMsg__c.SObjectType, APIVer__c.SObjectType, APIVerDtl__c.SObjectType });
            fflib_SObjectUnitOfWork uow2 = new fflib_SObjectUnitOfWork(new List<SObjectType>{Applicant__c.SObjectType ,LoanApplRelationship__c.SObjectType});
            Set<Id> applicantIds = new Set<Id>();
            Set<Id> loanAppIds = new Set<Id>();
            Map<Id,Id> addressMap = new Map<Id,Id>();
            Set<String> directorPans = new Set<String>();
            List<ApplAddr__c> appAddList = new List<ApplAddr__c>();
            List<Applicant__c> appList = new  List<Applicant__c>();

            for (IntgMsg__c intmsg : successResp.keySet()) {
                if (String.isNotBlank(intmsg.RefId__c)) {
                    applicantIds.add(intmsg.RefId__c);
                }
                if (String.isNotBlank(intmsg.ParentRefId__c)) {
                    loanAppIds.add(intmsg.ParentRefId__c);
                }

                LLPBaseDtlsResponseWrapper resObj = successResp.get(intmsg);
                if(resObj!=null && resObj.data!=null && resObj.data.directors !=null)
                {
                    for(LLPBaseDtlsResponseWrapper.cls_directors eachDirs : resObj.data.directors){
                        if(eachDirs.pan !=null){
                            directorPans.add(eachDirs.pan);
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


            }

            System.debug('directorPans ::'+directorPans);


            List<Applicant__c> existingAppWIthPans = [SELECT Id,name,PAN__c,LoanAppln__c, FName__c, Gender__c, ApplType__c,DOB__c,Age__c,Nationality__c from Applicant__c where PAN__c IN: directorPans AND ApplType__c ='D' AND LoanAppln__c IN : loanAppIds];
            Set<Id> idApplsExist  =new Set<Id>();
            Map<String, Applicant__c> existAppMapByPAN = new Map<String, Applicant__c>();
            System.debug('existingAppWIthPans ==>'+existingAppWIthPans);
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



            if(!applicantIds.isEmpty()){
            List<APIVer__c> existingApiVers = getExistingApiVerRecords(applicantIds);
            if (!existingApiVers.isEmpty()) {
                IntegrationUtility.updateBooleanFlag(existingApiVers, 'IsLatest__c', false);
            }
            }

            for (IntgMsg__c msg : successResp.keySet()) {

                    LLPBaseDtlsResponseWrapper resObj =successResp.get(msg);

                    if(resObj!=null){
                        APIVer__c apiVerObj = new APIVer__c();
                            apiVerObj.RecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Probe42').getRecordTypeId();
                            apiVerObj.Appl__c = msg.RefId__c;
                            apiVerObj.IsLatest__c = true;
                            apiVerObj.IntegrationStatus__c = 'Success';
                            apiVerObj.Type__c='Probe Basic LLP';
                            apiVerObj.LoanAplcn__c = msg.ParentRefId__c;
                            //LAK-9573
                            apiVerObj.RetriggerRationale__c = msg.RetriRatinal__c;

                            apiVerObj.ActionedDate__c = System.today();
                            apiVerObj.UserName__c = msg.UserName__c;
                            apiVerObj.UserNameRole__c = msg.UserNameRole__c;

                        if(resObj.metadata!=null){
                                LLPBaseDtlsResponseWrapper.cls_metadata metaObj = resObj.metadata;
                                apiVerObj.ApiVersion__c= metaObj.api_version;
                                apiVerObj.Lstupdt__c= setDateFormat(metaObj.last_updated);

                        }

                        if(resObj.data !=null){

                            if(resObj.data.llp !=null){
                                apiVerObj.Llpin__c= resObj.data.llp.llpin;
                                apiVerObj.LlpLegalName__c= resObj.data.llp.legal_name;
                                apiVerObj.EfilingStatus__c=resObj.data.llp.efiling_status;
                                apiVerObj.DteOfIncorp__c =setDateFormat(resObj.data.llp.incorporation_date);
                                apiVerObj.SumOfCharges__c =resObj.data.llp.sum_of_charges;
                                apiVerObj.TotObligOfContri__c= resObj.data.llp.total_obligation_of_contribution;
                                apiVerObj.Name__c =   resObj.data.llp.legal_name;

                                Applicant__c appData = new Applicant__c(Id = msg.RefId__c);
                                    appData.LLPIN__c = (resObj.data.llp.llpin != null) ? resObj.data.llp.llpin : '';
                                    appList.add(appData);

                                if(resObj.data.llp.registered_address !=null){

                                    apiVerObj.Address__c=resObj.data.llp.registered_address.full_address;
                                    apiVerObj.AddrLine1__c=resObj.data.llp.registered_address.address_line1;
                                    apiVerObj.AddrLine2__c=resObj.data.llp.registered_address.address_line2;
                                    apiVerObj.City__c=resObj.data.llp.registered_address.city;
                                    apiVerObj.Pincode__c=resObj.data.llp.registered_address.pincode;
                                    apiVerObj.State__c=resObj.data.llp.registered_address.state;


                                    ApplAddr__c adrs = new ApplAddr__c( Applicant__c = msg.RefId__c );
                                    if(addressMap.containsKey(msg.RefId__c)){
                                        adrs.Id = addressMap.get(msg.RefId__c);
                                    }
                                    //adrs.Applicant__c = msg.RefId__c;
                                    //adrs.Address__c=(regiAddObj.full_address != null) ? regiAddObj.full_address : regiAddObj.full_address;
                                    adrs.AddrLine1__c = (resObj.data.llp.registered_address.address_line1 != null) ? resObj.data.llp.registered_address.address_line1 : '';
                                    adrs.AddrLine2__c = (resObj.data.llp.registered_address.address_line2 != null) ? resObj.data.llp.registered_address.address_line2 : '';
                                    adrs.City__c = (resObj.data.llp.registered_address.city != null) ? resObj.data.llp.registered_address.city : '';
                                    adrs.Pincode__c = (resObj.data.llp.registered_address.pincode != null) ? resObj.data.llp.registered_address.pincode : '';
                                    adrs.State__c = (resObj.data.llp.registered_address.state != null) ? resObj.data.llp.registered_address.state : '';
                                    adrs.AddrTyp__c = 'Registered place for business';
                                    appAddList.add(adrs);
                                    

                                }

                                if(resObj.data.llp.lei !=null){

                                    apiVerObj.LeiNumber__c= resObj.data.llp.lei.number_Z;
                                    apiVerObj.LeiStatus__c= resObj.data.llp.lei.status;
                                }

                               apiVerObj.Classification__c= resObj.data.llp.classification;
                               apiVerObj.LastFinReportDate__c= setDateFormat(resObj.data.llp.last_financial_reporting_date);
                               apiVerObj.LastAnnRetFiledDate__c= setDateFormat(resObj.data.llp.last_annual_returns_filed_date);
                               apiVerObj.Email__c= resObj.data.llp.email;



                            }

                            uow1.registerNew(apiVerObj);

                            if(resObj.data.open_charges!=null){
                                for(LLPBaseDtlsResponseWrapper.cls_open_charges eachOpenCh : resObj.data.open_charges){

                                    APIVerDtl__c apiVerDtOpChrs = new APIVerDtl__c();
                        
                                    apiVerDtOpChrs.Type__c = 'Authorized Signatories';
                                    apiVerDtOpChrs.OpenChargesId__c= String.valueOf(eachOpenCh.id);
                                    apiVerDtOpChrs.OpenChargesDate__c=setDateFormat(eachOpenCh.date_Z);
                                    apiVerDtOpChrs.HolderName__c=eachOpenCh.holder_name;
                                    apiVerDtOpChrs.OpenChargesAmount__c=eachOpenCh.amount;
                                    apiVerDtOpChrs.OpenChargesType__c=eachOpenCh.type;

                                    uow1.registerRelationship(apiVerDtOpChrs, APIVerDtl__c.APIVerification__c, apiVerObj);  
							        uow1.registerNew(apiVerDtOpChrs);
                                }
                            }


                            if(resObj.data.directors !=null){
                                for(LLPBaseDtlsResponseWrapper.cls_directors eachDir : resObj.data.directors){
                                    System.debug('designation present :: designation is::'+eachDir.designation);

                                    //directors Start

                                    if(eachDir.designation!=null && eachDir.designation.toLowerCase().contains('partner'))
                                    {
                                        System.debug('designation present ::');
                                        //if(existAppMapByPAN.containsKey(eachDir.pan)){
                                        if(eachDir.pan!=null && msg.ParentRefId__c!=null && existAppMapByPAN.containsKey(eachDir.pan +'-'+ msg.ParentRefId__c))
                                        {
                                            System.debug('if condition pan');
                                        //update operation
                                        Applicant__c applObj = new Applicant__c();
                                        applObj.Id= existAppMapByPAN.get(eachDir.pan +'-'+ msg.ParentRefId__c).Id ;
                                        applObj.PAN__c= eachDir.pan;
                                        applObj.FName__c= eachDir.name;
                                        applObj.ApplType__c='PR';
                                        applobj.DataSource__c = 'API'; 
                                        
                                        if(eachDir.gender!=null && eachDir.gender.equalsIgnoreCase('Male')){
                                            applObj.Gender__c= 'M';
                                        }else if(eachDir.gender!=null && eachDir.gender.equalsIgnoreCase('Female')){
                                            applObj.Gender__c= 'F';
                                        }
                                        
                                        applObj.DOB__c= eachDir.date_of_birth !=null ? setDateFormat(eachDir.date_of_birth):null ;
                                        applObj.Age__c=eachDir.age;

                                        if(eachDir.nationality!=null && eachDir.nationality.equalsIgnoreCase('India')){
                                            applObj.Nationality__c='INDIA';
                                        }
                                        applObj.LoanAppln__c = msg.ParentRefId__c;
                                        
                                        uow2.registerDirty(applObj);

                                        if(msg.RefId__c!=null && eachDir.pan!=null && existAppRelMap.containsKey(applObj.Id +'-'+ msg.RefId__c))
                                        {
                                        //Update relationship
                                        LoanApplRelationship__c appRelObj = new LoanApplRelationship__c();
                                        
                                        appRelObj.Id=existAppRelMap.get(applObj.Id +'-'+ msg.RefId__c).Id;
                                        
                                        if(eachDir.address !=null){
                                        appRelObj.AddrLine1__c=eachDir.address.address_line1 ;
                                        appRelObj.AddrLine2__c= eachDir.address.address_line2;
                                        appRelObj.City__c= eachDir.address.city;
                                        appRelObj.Country__c= eachDir.address.country;
                                        appRelObj.Pincode__c= eachDir.address.pincode;
                                        appRelObj.State__c= eachDir.address.state;
                                        }
                                        
                                        appRelObj.DateOfAppointment__c= setDateFormat(eachDir.date_of_appointment);
                                        appRelObj.DateOfAppCurrentDesig__c= setDateFormat(eachDir.date_of_appointment_for_current_designation);
                                        appRelObj.DateOfCessation__c= setDateFormat(eachDir.date_of_cessation);
                                        appRelObj.Designation__c= eachDir.designation;
                                        appRelObj.Din__c= eachDir.din;
                                        appRelObj.DinStatus__c= eachDir.din_status;
                                        appRelObj.Loan_Applicant__c=msg.RefId__c;
                                        appRelObj.Relationship_Type__c='Partner';

                                        uow2.registerRelationship(appRelObj, LoanApplRelationship__c.Related_Person__c, applObj);   
						                uow2.registerDirty(appRelObj);
                                        }else{
                                            system.debug('else');
                                            //create relationship
                                            LoanApplRelationship__c appRelObj = new LoanApplRelationship__c();
                                        
                                            if(eachDir.address !=null){
                                            appRelObj.AddrLine1__c=eachDir.address.address_line1 ;
                                            appRelObj.AddrLine2__c= eachDir.address.address_line2;
                                            appRelObj.City__c= eachDir.address.city;
                                            appRelObj.Country__c= eachDir.address.country;
                                            appRelObj.Pincode__c= eachDir.address.pincode;
                                            appRelObj.State__c= eachDir.address.state;
                                            }
                                            
                                            appRelObj.DateOfAppointment__c= setDateFormat(eachDir.date_of_appointment);
                                            appRelObj.DateOfAppCurrentDesig__c= setDateFormat(eachDir.date_of_appointment_for_current_designation);
                                            appRelObj.DateOfCessation__c= setDateFormat(eachDir.date_of_cessation);
                                            appRelObj.Designation__c= eachDir.designation;
                                            appRelObj.Din__c= eachDir.din;
                                            appRelObj.DinStatus__c= eachDir.din_status;
                                            appRelObj.Loan_Applicant__c=msg.RefId__c;
                                            appRelObj.Relationship_Type__c='Director';

                                            uow2.registerRelationship(appRelObj, LoanApplRelationship__c.Related_Person__c, applObj);   
                                            uow2.registerNew(appRelObj);

                                        }
                                        }
                                        else{
                                        //insert operation

                                        System.debug('inserting Applicants for :'+eachDir.pan);
                                        Applicant__c applObj = new Applicant__c();
                                        applObj.PAN__c= eachDir.pan;
                                        applObj.FName__c= eachDir.name;
                                        applObj.ApplType__c='PR';
                                        applobj.DataSource__c = 'API'; 
                                        
                                        if(eachDir.gender!=null && eachDir.gender.equalsIgnoreCase('Male')){
                                            applObj.Gender__c= 'M';
                                        }else if(eachDir.gender!=null && eachDir.gender.equalsIgnoreCase('Female')){
                                            applObj.Gender__c= 'F';
                                        }
                                        
                                        applObj.DOB__c= eachDir.date_of_birth !=null ? setDateFormat(eachDir.date_of_birth):null ;
                                        applObj.Age__c=eachDir.age;

                                        if(eachDir.nationality!=null && eachDir.nationality.equalsIgnoreCase('India')){
                                            applObj.Nationality__c='INDIA';
                                        }
                                        applObj.LoanAppln__c = msg.ParentRefId__c;
                                        
                                        uow2.registerNew(applObj);

                                        LoanApplRelationship__c appRelObj = new LoanApplRelationship__c();
                                        
                                        if(eachDir.address !=null){
                                        appRelObj.AddrLine1__c=eachDir.address.address_line1 ;
                                        appRelObj.AddrLine2__c= eachDir.address.address_line2;
                                        appRelObj.City__c= eachDir.address.city;
                                        appRelObj.Country__c= eachDir.address.country;
                                        appRelObj.Pincode__c= eachDir.address.pincode;
                                        appRelObj.State__c= eachDir.address.state;
                                        }
                                        
                                        appRelObj.DateOfAppointment__c= setDateFormat(eachDir.date_of_appointment);
                                        appRelObj.DateOfAppCurrentDesig__c= setDateFormat(eachDir.date_of_appointment_for_current_designation);
                                        appRelObj.DateOfCessation__c= setDateFormat(eachDir.date_of_cessation);
                                        appRelObj.Designation__c= eachDir.designation;
                                        appRelObj.Din__c= eachDir.din;
                                        appRelObj.DinStatus__c= eachDir.din_status;
                                        appRelObj.Loan_Applicant__c=msg.RefId__c;
                                        appRelObj.Relationship_Type__c='Partner';

                                        uow2.registerRelationship(appRelObj, LoanApplRelationship__c.Related_Person__c, applObj);   
						                uow2.registerNew(appRelObj);

                                        }
                                        //Insert or update Done

                                    }

                                    //directors End


                                    APIVerDtl__c apiVerDtlDirObj = new APIVerDtl__c();
                                        apiVerDtlDirObj.Type__c = 'Directors';
                                        
                                        apiVerDtlDirObj.Din__c= eachDir.din;
                                        apiVerDtlDirObj.Pan__c= eachDir.pan;
                                        apiVerDtlDirObj.DirectNwName__c= eachDir.name;
                                        apiVerDtlDirObj.Designation__c= eachDir.designation;
                                        apiVerDtlDirObj.DinStatus__c= eachDir.din_status;
                                        apiVerDtlDirObj.Gender__c= eachDir.gender;
                                        apiVerDtlDirObj.DOB__c= setDateFormat(eachDir.date_of_birth);
                                        apiVerDtlDirObj.Age__c= eachDir.age;
                                        apiVerDtlDirObj.DateOfAppointment__c= setDateFormat(eachDir.date_of_appointment);
                                        apiVerDtlDirObj.DateAppCurrentDesig__c= setDateFormat(eachDir.date_of_appointment_for_current_designation);
                                        apiVerDtlDirObj.DateOfCessation__c= setDateFormat(eachDir.date_of_cessation);
                                        apiVerDtlDirObj.Nationality__c= eachDir.nationality;

                                        if(eachDir.address!=null){
                                            apiVerDtlDirObj.AddrLine1__c = eachDir.address.address_line1;
                                            apiVerDtlDirObj.AddrLine2__c =  eachDir.address.address_line2;
                                            apiVerDtlDirObj.City__c = eachDir.address.city;
                                            apiVerDtlDirObj.Pincode__c = eachDir.address.pincode;
                                            apiVerDtlDirObj.State__c = eachDir.address.state;
                                            apiVerDtlDirObj.Country__c = eachDir.address.country;
                                            
                                        }

                                    uow1.registerRelationship(apiVerDtlDirObj, APIVerDtl__c.APIVerification__c, apiVerObj);  
							        uow1.registerNew(apiVerDtlDirObj);    
                                }
                            }
                        }
                    }
                    APICalloutTracker.update_ApiTrackerWithIntMsg(msg.Id,msg.Svc__c, msg.RefId__c, 'Success');
                }

                uow1.commitWork();
                uow2.commitWork();
                
                if(!appAddList.isEmpty()){
                    upsert appAddList;
                }
                if(!appList.isEmpty()){
                    update appList;
                }
                  
         }catch(Exception ex) {
            GlobalUtility.logMessage('Error', 'LLPBaseDtlsResponseProcessor',
                'processSuccess', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    
    }

    private static List<APIVer__c> getExistingApiVerRecords(Set<Id> applicantIds) {
        return [SELECT Id, Appl__c, IsLatest__c, RecordType.Name,Type__c FROM APIVer__c WHERE Appl__c IN :applicantIds AND RecordType.DeveloperName = 'Probe42' AND IsLatest__c = true and Type__c ='Probe Basic LLP'];
    }



    //*******************************************************************************************************************************************   
    public static void processFailure(String messageRes,Map<IntgMsg__c,LLPBaseDtlsResponseWrapper> failureResp){
        
        try{
            
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> {ApplKyc__c.SObjectType,APIVer__c.SObjectType});
            Set<Id> applicantIds =new Set<Id>();
            List<APIVer__c> appVerList=new List<APIVer__c>();
            Id recordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Probe42').getRecordTypeId();
            //looping to get KycIds
            for(IntgMsg__c msg:failureResp.keyset()){
                
                if(string.isNotblank(msg.RefId__c)){
                    applicantIds.add(msg.RefId__c);
                }
            }
            
            //SOQL to check old records
            List<APIVer__c> apiVer =[Select id,Appl__c,IsLatest__c,RecordType.Name,Type__c from APIVer__c Where Appl__c IN:applicantIds AND RecordType.DeveloperName='Probe42' AND IsLatest__c=true and Type__c ='Probe Basic LLP'];
            
            if(!apiVer.isEmpty()){
                IntegrationUtility.updateBooleanFlag(apiVer,'IsLatest__c',false);
            }
            
            //Looping to update the records
            for(IntgMsg__c msg:failureResp.keyset()){
                
                if(failureResp.containsKey(msg) && String.isNotblank(msg.RefId__c)){
                    
                            APIVer__c apiveri =new APIVer__c();
                            apiveri.Appl__c=msg.RefId__c;
                            //LAK-9573
                            apiveri.RetriggerRationale__c = msg.RetriRatinal__c;
                            apiveri.ActionedDate__c = System.today();
                            apiveri.UserName__c = msg.UserName__c;
                            apiveri.UserNameRole__c = msg.UserNameRole__c;
                            apiveri.Type__c='Probe Basic LLP';
                            apiveri.IntegrationStatus__c='Failure';
                            apiveri.LoanAplcn__c = msg.ParentRefId__c;
                            apiveri.IntegrationErrorMessage__c=messageRes;
                            apiveri.IsLatest__c=true;
                            apiveri.RecordTypeId=recordTypeId!=null?recordTypeId:'';
                            appVerList.add(apiveri);
                            APICalloutTracker.update_ApiTrackerWithIntMsg(msg.Id,msg.Svc__c, msg.RefId__c, 'Failure');
                        
                    }
            }

            
            
            //Creating API Verification Record
            if(!appVerList.isEmpty()) {
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

    public static Date setDateFormat(String datePass) 
    {
            if (datePass != null) {
                return Date.valueOf(datePass);
            }else{
                return null;
            } 
    }

}