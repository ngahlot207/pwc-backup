public class ComCompreDtlsResponseProcessor implements IintMsgCalloutResponseProcessor{

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
                    Map<IntgMsg__c,ComCompreDtlsResponseWrapper> successResponseMap = new Map<IntgMsg__c,ComCompreDtlsResponseWrapper>();
                    Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
                    
                    if(cvdata!=null){

                        String jsonContent=cvdata.VersionData.toString();

                        //String jsonContent = EncodingUtil.urlDecode(jsonReceived, 'UTF-8'); 
                        //jsonContent =jsonContent.replace('\'', '');  
                        // String jsonString = EncodingUtil.urlDecode(integrationMessage.Req__c, 'UTF-8');

                        ComCompreDtlsResponseWrapper res = (ComCompreDtlsResponseWrapper) JSON.deserialize(jsonContent, ComCompreDtlsResponseWrapper.class);
                        successResponseMap.put(intMsg,res);
                        
                        try{
                             ComCompreDtlsQueueable queueableInstance = new ComCompreDtlsQueueable(successResponseMap,jsonContent);
                             System.enqueueJob(queueableInstance);
                            
                        }
                        catch(Exception ex){
                             GlobalUtility.logMessage('Error', 'ComCompreDtlsResponseProcessor class', 
                                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                        }
                    }
                    
                }
                
            }
        }
        
    }

    


public static void processSuccess(Map<IntgMsg__c, ComCompreDtlsResponseWrapper> successResp) {
        try {

           
           fflib_SObjectUnitOfWork uow1 = new fflib_SObjectUnitOfWork(new List<SObjectType> {APIVer__c.SObjectType, APIVerDtl__c.SObjectType ,Applicant__c.SObjectType,LoanApplRelationship__c.SObjectType  }); 
           fflib_SObjectUnitOfWork uow2 = new fflib_SObjectUnitOfWork(new List<SObjectType> {APIVer__c.SObjectType, APIVerDtl__c.SObjectType }); 
           fflib_SObjectUnitOfWork uow3 = new fflib_SObjectUnitOfWork(new List<SObjectType> {Applicant_Financial__c.SObjectType  ,Applicant_Financial_Summary__c.SObjectType }); 
           //fflib_SObjectUnitOfWork uow3 = new fflib_SObjectUnitOfWork(new List<SObjectType> {LoanApplRelationship__c.SObjectType,Applicant__c.SObjectType }); 
            Set<Id> applicantIds = new Set<Id>();
            Set<Id> loanAppIds = new Set<Id>();
            Set<String> directorPans = new Set<String>();

            List<IntgMsg__c> createRequestList = new List<IntgMsg__c>();  

            //List<Applicant__c> listApplicants = new List<Applicant__c>();
            for (IntgMsg__c intmsg : successResp.keySet()) {
                if (String.isNotBlank(intmsg.RefId__c)) {
                    applicantIds.add(intmsg.RefId__c);
                }
                if (String.isNotBlank(intmsg.ParentRefId__c)) {
                    loanAppIds.add(intmsg.ParentRefId__c);
                }
            }

            if(!applicantIds.isEmpty()){
            List<APIVer__c> existingApiVers = getExistingApiVerRecords(applicantIds);
            if (!existingApiVers.isEmpty()) {
                IntegrationUtility.updateBooleanFlag(existingApiVers, 'IsLatest__c', false);
            }
            }
            Set<Id> appliIds =new Set<Id>();
            for (IntgMsg__c msg : successResp.keySet()) {
            
            loanAppIds.add(msg.ParentRefId__c);
            appliIds.add(msg.RefId__c);

            ComCompreDtlsResponseWrapper resObj = successResp.get(msg);
            if(resObj!=null && resObj.data!=null && resObj.data.director_network !=null)
            {
                for(ComCompreDtlsResponseWrapper.Director_network eachDirNw : resObj.data.director_network){
                    if(eachDirNw.pan!=null){
                        directorPans.add(eachDirNw.pan);
                    }
                }
                }  
            }

            List<Applicant__c> existingAppWIthPans = [SELECT Id,name,PAN__c, FName__c,LoanAppln__c, Gender__c, ApplType__c,DOB__c,Age__c,Nationality__c from Applicant__c where PAN__c IN: directorPans AND ApplType__c ='D' AND LoanAppln__c IN : loanAppIds];//type='director' and loanAppId In :loanAppIds
            Set<Id> idApplsExist  =new Set<Id>();
            Map<String, Applicant__c> existAppMapByPAN = new Map<String, Applicant__c>();
            
            for (Applicant__c app : existingAppWithPans) {
                if (app.PAN__c != null) {
                    existAppMapByPAN.put(app.PAN__c +'-'+app.LoanAppln__c, app);
                }
                idApplsExist.add(app.Id);
            }

            List<LoanApplRelationship__c> listLoanAppRels=[SELECT Id,Related_Person__c,Loan_Applicant__c  from LoanApplRelationship__c where Related_Person__c  In : idApplsExist and Loan_Applicant__c In : appliIds]; // and Loan_Applicant__c =msg.RefId

            Map<String, LoanApplRelationship__c> existAppRelMap = new Map<String, LoanApplRelationship__c>();
            
            for (LoanApplRelationship__c app : listLoanAppRels) {
                if (app.Related_Person__c != null) {
                    existAppRelMap.put(app.Related_Person__c + '-' + app.Loan_Applicant__c, app);
                }
            }

            System.debug('existAppRelMap ==>'+existAppRelMap);
            System.debug('existAppMapByPAN ==>'+existAppMapByPAN);


            //API ver data insert start
            for (IntgMsg__c msg : successResp.keySet()) {

                ComCompreDtlsResponseWrapper resObj = successResp.get(msg);
                
                APIVer__c apiVerObj = new APIVer__c();
                apiVerObj.RecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Probe42').getRecordTypeId();
                apiVerObj.Appl__c = msg.RefId__c;
                apiVerObj.LoanAplcn__c = msg.ParentRefId__c;
                apiVerObj.IsLatest__c = true;
                apiVerObj.IntegrationStatus__c = 'Success';
                apiVerObj.Type__c='Probe Comprehensive Company';

                //API Verifiaction Objs
                if(resObj !=null){

                    if(resObj.metadata !=null ){

                        apiVerObj.ApiVersion__c =resObj.metadata.api_version;
                        apiVerObj.Lstupdt__c = setDateFormat(resObj.metadata.last_updated);

                    }    

                    if(resObj.data !=null){

                        if(resObj.data.company !=null){
                            
                            apiVerObj.PanCinDin__c=	resObj.data.company.cin;
                            apiVerObj.LegalName__c=	resObj.data.company.legal_name;
                            apiVerObj.EfilingStatus__c=	resObj.data.company.efiling_status;
                            apiVerObj.DteOfIncorp__c=	setDateFormat(resObj.data.company.incorporation_date);
                            apiVerObj.PaidupCapital__c=	resObj.data.company.paid_up_capital;
                            apiVerObj.SumOfCharges__c=	resObj.data.company.sum_of_charges; 
                            apiVerObj.AuthorizedCapital__c=	resObj.data.company.authorized_capital;
                            apiVerObj.ActiveCompliance__c=	resObj.data.company.active_compliance;
                            apiVerObj.Name__c=resObj.data.company.legal_name;

                            if(resObj.data.company.registered_address !=null ){
                                apiVerObj.Address__c=	resObj.data.company.registered_address.full_address;
                                apiVerObj.AddrLine1__c=	resObj.data.company.registered_address.address_line1;
                                apiVerObj.AddrLine2__c=	resObj.data.company.registered_address.address_line2;
                                apiVerObj.City__c=	resObj.data.company.registered_address.city;
                                apiVerObj.Pincode__c=	resObj.data.company.registered_address.pincode;
                                apiVerObj.State__c=	resObj.data.company.registered_address.state;

                            }

                            if(resObj.data.company.business_address !=null ){
                                apiVerObj.BusAddrLine_1__c=	resObj.data.company.business_address.address_line1;
                                apiVerObj.BusAddrLine2__c=	resObj.data.company.business_address.address_line2;
                                apiVerObj.BusAddrCIty__c=	resObj.data.company.business_address.city;
                                apiVerObj.BusAddrPin__c=	resObj.data.company.business_address.pincode;
                                apiVerObj.BusAddrState__c=	resObj.data.company.business_address.state;
                            }

                                apiVerObj.Pan__c=	resObj.data.company.pan;
                                apiVerObj.Website__c=	resObj.data.company.website;
                                apiVerObj.Classification__c=	resObj.data.company.classification;
                                apiVerObj.DataStatus__c=	resObj.data.company.status;
                                apiVerObj.LastAgmDate__c=	setDateFormat(resObj.data.company.last_agm_date);
                                apiVerObj.LastFilingDate__c=	resObj.data.company.last_filing_date;
                                apiVerObj.Email__c=	resObj.data.company.email;

                            if(resObj.data.company.lei !=null ){
                                apiVerObj.LeiNumber__c=	resObj.data.company.lei.number_Z;
                                apiVerObj.LeiStatus__c=	resObj.data.company.lei.status;
                                apiVerObj.DateOfRegistration__c=	setDateFormat(resObj.data.company.lei.registration_date);
                                apiVerObj.LeiLastUpdDate__c=	setDateFormat(resObj.data.company.lei.last_updated_date);
                                apiVerObj.NextRenewDate__c=	setDateFormat(resObj.data.company.lei.next_renewal_date);
                            }

                        }

                        //Company details done
                        
                        if(resObj.data.description !=null){

                            apiVerObj.DataDesc__c=resObj.data.description.desc_thousand_char;
                        }   
                        

                        if(resObj.data.holding_entities!=null){
                            apiVerObj.HoldEntFinYear__c =resObj.data.holding_entities.financial_year;
                        }

                        if(resObj.data.subsidiary_entities!=null){
                            apiVerObj.SubEntFinYear__c= resObj.data.subsidiary_entities.financial_year;
                        }

                        if(resObj.data.struckoff248_details!=null){

                            apiVerObj.StrRestStatus__c= resObj.data.struckoff248_details.restored_status;
                            apiVerObj.Struckoff_Status__c= resObj.data.struckoff248_details.struck_off_status;
                        }

                        // if(resObj.data.msme_supplier_payment_delays !=null && resObj.data.msme_supplier_payment_delays.delays_for_peri !=null){

                        //     apiVerObj.LatDelForPeriod__c= resObj.data.msme_supplier_payment_delays.delays_for_period.latest_period;
                        //     apiVerObj.TotAmtDueForPeriod__c = resObj.data.msme_supplier_payment_delays.delays_for_period.total_amount_due_for_period;
                        // }

                        }

                        //API Ver Details mapping Done
                        uow1.registerNew(apiVerObj);
                }
                
                //API Verifiaction Details Objs mapping start
                if(resObj !=null){
                if(resObj.data !=null){

                if(resObj.data.name_history !=null){
                            for(ComCompreDtlsResponseWrapper.Name_history eachHis: resObj.data.name_history )
                            {
                                APIVerDtl__c apiVerDtlNmHisObj = new APIVerDtl__c();
                                apiVerDtlNmHisObj.Type__c = 'Name History';
                                apiVerDtlNmHisObj.NameHisDate__c= setDateFormat(eachHis.date_Z);
                                apiVerDtlNmHisObj.NameHisName__c= eachHis.name;
                                uow1.registerRelationship(apiVerDtlNmHisObj, APIVerDtl__c.APIVerification__c, apiVerObj);  
							    uow1.registerNew(apiVerDtlNmHisObj);
                            }
                }

                if(resObj.data.authorized_signatories !=null){
                    if(resObj.data.authorized_signatories!=null && !resObj.data.authorized_signatories.isEmpty()){
                                
                                for(ComCompreDtlsResponseWrapper.Authorized_signatories eachAuth : resObj.data.authorized_signatories ){
                                    APIVerDtl__c apiVerDtlAuthSignObj = new APIVerDtl__c();
                                    apiVerDtlAuthSignObj.Pan__c= eachAuth.pan;     
                                    apiVerDtlAuthSignObj.Type__c ='Authorized Signatories';                                    
                                    apiVerDtlAuthSignObj.Din__c= eachAuth.din;                                         
                                    apiVerDtlAuthSignObj.AuthSignName__c= eachAuth.name;                                        
                                    apiVerDtlAuthSignObj.Designation__c= eachAuth.designation;                                
                                    apiVerDtlAuthSignObj.DinStatus__c =eachAuth.din_status;                                  
                                    apiVerDtlAuthSignObj.Gender__c= eachAuth.gender;                                      
                                    apiVerDtlAuthSignObj.DOB__c= setDateFormat(eachAuth.date_of_birth);                               
                                    apiVerDtlAuthSignObj.Age__c= eachAuth.age;                                         
                                    apiVerDtlAuthSignObj.DateOfAppointment__c= setDateFormat(eachAuth.date_of_appointment);                         
                                    apiVerDtlAuthSignObj.DateAppCurrentDesig__c =setDateFormat(eachAuth.date_of_appointment_for_current_designation); 
                                    apiVerDtlAuthSignObj.DateOfCessation__c =setDateFormat(eachAuth.date_of_cessation);                            
                                    apiVerDtlAuthSignObj.Nationality__c =eachAuth.nationality;  
                                    
                                    if(eachAuth.address!=null){
                                        apiVerDtlAuthSignObj.AddrLine1__c =eachAuth.address.address_line1;
                                        apiVerDtlAuthSignObj.AddrLine2__c=eachAuth.address.address_line2;
                                        apiVerDtlAuthSignObj.City__c=eachAuth.address.city;
                                        apiVerDtlAuthSignObj.Pincode__c=eachAuth.address.pincode;
                                        apiVerDtlAuthSignObj.State__c=eachAuth.address.state;
                                        apiVerDtlAuthSignObj.Country__c=eachAuth.address.country;
                                        
                                    }
                                    uow1.registerRelationship(apiVerDtlAuthSignObj, APIVerDtl__c.APIVerification__c, apiVerObj);  
							        uow1.registerNew(apiVerDtlAuthSignObj);
                                    //for self lookup association_history

                                    if(eachAuth.association_history!=null){

                                        for(ComCompreDtlsResponseWrapper.Association_history eachAsHis : eachAuth.association_history){
                                            //self lookup
                                            APIVerDtl__c apiVerDtlAssoHisObj = new APIVerDtl__c();

                                            apiVerDtlAssoHisObj.Event__c=setDateFormat(eachAsHis.event);
                                            apiVerDtlAssoHisObj.EventDate__c=setDateFormat(eachAsHis.event_date);
                                            apiVerDtlAssoHisObj.DesignAfterEvent__c=eachAsHis.designation_after_event;
                                            apiVerDtlAssoHisObj.FilingDt__c=setDateFormat(eachAsHis.filing_date);
                                            apiVerDtlAssoHisObj.Type__c='Association History';

                                            uow2.registerRelationship(apiVerDtlAssoHisObj, APIVerDtl__c.ApiVerDetails__c, apiVerDtlAuthSignObj);
                                            uow2.registerRelationship(apiVerDtlAssoHisObj, APIVerDtl__c.APIVerification__c, apiVerObj);
                                            uow2.registerNew(apiVerDtlAssoHisObj);
                                }
                            }
                        }
                    }
                }
                //Auth Sign END

                if(resObj.data.director_network !=null)
                {

                    for(ComCompreDtlsResponseWrapper.Director_network eachDirNw : resObj.data.director_network){
                        APIVerDtl__c apiVerDtlDirNw = new APIVerDtl__c();
                        apiVerDtlDirNw.DirectNwName__c =eachDirNw.name;
                        apiVerDtlDirNw.Pan__c=eachDirNw.pan;
                        apiVerDtlDirNw.Din__c =eachDirNw.din;
                        apiVerDtlDirNw.Type__c='Director Network';

                        // if(eachDirNw.pan!=null){
                        //     directorPans.add(eachDirNw.pan);
                        // }
                        
                        uow1.registerRelationship(apiVerDtlDirNw, APIVerDtl__c.APIVerification__c, apiVerObj);  
						uow1.registerNew(apiVerDtlDirNw);

                        if(eachDirNw.network!=null)
                        {
                            if(eachDirNw.network.companies !=null){

                                for(ComCompreDtlsResponseWrapper.Companies eachComNw : eachDirNw.network.companies){

                                    APIVerDtl__c apiVerDtlNwComps = new APIVerDtl__c();

                                    apiVerDtlNwComps.Type__c='Network Companies';
                                    apiVerDtlNwComps.CompCin__c=eachComNw.cin;
                                    apiVerDtlNwComps.CompLegalName__c= eachComNw.legal_name;
                                    apiVerDtlNwComps.CompStatus__c=eachComNw.company_status;
                                    apiVerDtlNwComps.CompIncorpDate__c= setDateFormat(eachComNw.incorporation_date);
                                    apiVerDtlNwComps.CompPaidCapital__c=eachComNw.paid_up_capital;
                                    apiVerDtlNwComps.SumOfChrgs__c=eachComNw.sum_of_charges;
                                    apiVerDtlNwComps.CompCity__c=eachComNw.city;
                                    apiVerDtlNwComps.CompActCompliance__c=eachComNw.active_compliance;
                                    apiVerDtlNwComps.CompDesignation__c=eachComNw.designation;
                                    apiVerDtlNwComps.CompDateAppoint__c= setDateFormat(eachComNw.date_of_appointment);
                                    apiVerDtlNwComps.CompDateAppointCurrentDesig__c= setDateFormat(eachComNw.date_of_appointment_for_current_designation);
                                    apiVerDtlNwComps.CompDateCessation__c= setDateFormat(eachComNw.date_of_cessation);

                                    uow2.registerRelationship(apiVerDtlNwComps, APIVerDtl__c.ApiVerDetails__c, apiVerDtlDirNw);
                                    uow2.registerRelationship(apiVerDtlNwComps, APIVerDtl__c.APIVerification__c, apiVerObj);
                                    uow2.registerNew(apiVerDtlNwComps);

                                    
                                }
                            }

                            if(eachDirNw.network.llps !=null){

                                for(ComCompreDtlsResponseWrapper.Llps eachllpNw : eachDirNw.network.llps){

                                    APIVerDtl__c apiVerDtlNwLlps = new APIVerDtl__c();
                                        apiVerDtlNwLlps.Type__c='Network Llps';
                                        apiVerDtlNwLlps.Llpin__c=	eachllpNw.llpin;
                                        apiVerDtlNwLlps.LlpLegalName__c=	eachllpNw.legal_name;
                                        apiVerDtlNwLlps.LlpStatus__c=	eachllpNw.status;
                                        apiVerDtlNwLlps.LlpIncorpDate__c=	setDateFormat(eachllpNw.incorporation_date);
                                        apiVerDtlNwLlps.LlpTotalObligContri__c=	eachllpNw.total_obligation_of_contribution;
                                        apiVerDtlNwLlps.SumOfChrgs__c=	eachllpNw.sum_of_charges;
                                        apiVerDtlNwLlps.LlpCity__c=	eachllpNw.city;
                                        apiVerDtlNwLlps.LlpDesignation__c=	eachllpNw.designation;
                                        apiVerDtlNwLlps.LlpDateAptmt__c=	setDateFormat(eachllpNw.date_of_appointment);
                                        apiVerDtlNwLlps.LlpDateAppCurrdesi__c=	setDateFormat(eachllpNw.date_of_appointment_for_current_designation);
                                        apiVerDtlNwLlps.LlpDateCessation__c=	setDateFormat(eachllpNw.date_of_cessation);

                                        uow2.registerRelationship(apiVerDtlNwLlps, APIVerDtl__c.ApiVerDetails__c, apiVerDtlDirNw);
                                        uow2.registerRelationship(apiVerDtlNwLlps, APIVerDtl__c.APIVerification__c, apiVerObj);
                                        uow2.registerNew(apiVerDtlNwLlps);

                                }
                            }
                        }
                    }
                }
                //Director Network END

               // System.debug('Directors Pan list :'+directorPans);



                //My logic for Applicant Insertion Start

                //get list of applicants with directors pan list =?if found 
                //map <pan,applicant> mapsExiting
                
                if(resObj.data.authorized_signatories !=null){
                    if(resObj.data.authorized_signatories!=null && !resObj.data.authorized_signatories.isEmpty()){
                                
                                for(ComCompreDtlsResponseWrapper.Authorized_signatories eachAuth : resObj.data.authorized_signatories ){
                                    //
                                    if(msg.ParentRefId__c !=null && eachAuth.pan!=null && !existAppMapByPAN.containsKey(eachAuth.pan +'-'+ msg.ParentRefId__c)){

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
                                    else if(eachAuth.pan!=null && msg.ParentRefId__c!=null && existAppMapByPAN.containsKey(eachAuth.pan +'-'+ msg.ParentRefId__c)){

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

                                        LoanApplRelationship__c appRelObj = new LoanApplRelationship__c();
                                        //System.debug('id rel obj:'+existAppRelMap.get(existAppMapByPAN.get(eachAuth.pan +'-' +msg.ParentRefId__c).Id +'-'+ msg.RefId__c));
                                        appRelObj.Id=existAppRelMap.get(applObj.Id +'-'+ msg.RefId__c).Id;
                                        //existAppRelMap.get(existAppMapByPAN.get(eachAuth.pan +'-' +msg.ParentRefId__c).Id).Id;
                                        //existAppRelMap.get(existAppMapByPAN.get(eachAuth.pan +'-' +msg.ParentRefId__c).Id
                                        
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



                                    //
                                    
                                    /*  store this
                                    apiVerDtlAuthSignObj.Type__c ='Authorized Signatories';                                    
                                    apiVerDtlAuthSignObj.AuthSignDin__c= eachAuth.din;                                         
                                    apiVerDtlAuthSignObj.AuthSignName__c= eachAuth.name;                                        
                                    apiVerDtlAuthSignObj.Designation__c= eachAuth.designation;                                
                                    apiVerDtlAuthSignObj.DinStatus__c =eachAuth.din_status;                                  
                                    apiVerDtlAuthSignObj.Gender__c= eachAuth.gender;                                      
                                    apiVerDtlAuthSignObj.DOB__c= setDateFormat(eachAuth.date_of_birth);                               
                                    apiVerDtlAuthSignObj.Age__c= eachAuth.age;                                         
                                    apiVerDtlAuthSignObj.DateOfAppointment__c= setDateFormat(eachAuth.date_of_appointment);                         
                                    apiVerDtlAuthSignObj.DateAppCurrentDesig__c =setDateFormat(eachAuth.date_of_appointment_for_current_designation); 
                                    apiVerDtlAuthSignObj.DateOfCessation__c =setDateFormat(eachAuth.date_of_cessation);                            
                                    apiVerDtlAuthSignObj.Nationality__c =eachAuth.nationality;  
                                    
                                    if(eachAuth.address!=null){
                                        apiVerDtlAuthSignObj.AddrLine1__c =eachAuth.address.address_line1;
                                        apiVerDtlAuthSignObj.AddrLine2__c=eachAuth.address.address_line2;
                                        apiVerDtlAuthSignObj.City__c=eachAuth.address.city;
                                        apiVerDtlAuthSignObj.Pincode__c=eachAuth.address.pincode;
                                        apiVerDtlAuthSignObj.State__c=eachAuth.address.state;
                                        apiVerDtlAuthSignObj.Country__c=eachAuth.address.country;
                                        
                                    }
                                    uow1.registerRelationship(apiVerDtlAuthSignObj, APIVerDtl__c.APIVerification__c, apiVerObj);  
							        uow1.registerNew(apiVerDtlAuthSignObj); */
                                    //for self lookup association_history
                                    /*
                                    if(eachAuth.association_history!=null){

                                        for(ComCompreDtlsResponseWrapper.Association_history eachAsHis : eachAuth.association_history){
                                            //self lookup
                                            APIVerDtl__c apiVerDtlAssoHisObj = new APIVerDtl__c();

                                            apiVerDtlAssoHisObj.Event__c=setDateFormat(eachAsHis.event);
                                            apiVerDtlAssoHisObj.EventDate__c=setDateFormat(eachAsHis.event_date);
                                            apiVerDtlAssoHisObj.DesignAfterEvent__c=eachAsHis.designation_after_event;
                                            apiVerDtlAssoHisObj.FilingDt__c=setDateFormat(eachAsHis.filing_date);
                                            apiVerDtlAssoHisObj.Type__c='Association History';

                                            uow2.registerRelationship(apiVerDtlAssoHisObj, APIVerDtl__c.ApiVerDetails__c, apiVerDtlAuthSignObj);
                                            uow2.registerRelationship(apiVerDtlAssoHisObj, APIVerDtl__c.APIVerification__c, apiVerObj);
                                            uow2.registerNew(apiVerDtlAssoHisObj);
                                }
                            } */
                        }
                    }
                }
                





                //My logic for Applicant Insertion End

                if(resObj.data.contact_details!=null){
                    
                    if(resObj.data.contact_details.email!=null){
                            for(ComCompreDtlsResponseWrapper.Email eachEms : resObj.data.contact_details.email){
                                APIVerDtl__c apiVerDtEm = new APIVerDtl__c();
                                apiVerDtEm.EmailId__c=eachEms.emailId;
                                apiVerDtEm.EmailStatus__c =eachEms.status;
                                apiVerDtEm.Type__c='Email';
                                uow1.registerRelationship(apiVerDtEm, APIVerDtl__c.APIVerification__c, apiVerObj);  
						        uow1.registerNew(apiVerDtEm);
                            } 
                        }
                          
                        if(resObj.data.contact_details.phone!=null){
                            for(ComCompreDtlsResponseWrapper.Phone eachPhs: resObj.data.contact_details.phone){
                                APIVerDtl__c apiVerDtPh = new APIVerDtl__c();
                                apiVerDtPh.PhoneNumber__c=eachPhs.phoneNumber;
                                apiVerDtPh.PhoneStatus__c=eachPhs.status;
                                apiVerDtPh.Type__c='Phone';
                                uow1.registerRelationship(apiVerDtPh, APIVerDtl__c.APIVerification__c, apiVerObj);  
						        uow1.registerNew(apiVerDtPh);
                            }
                        }     
                }

                //GSt Start details

                if(resObj.data.gst_details !=null){

                    for(ComCompreDtlsResponseWrapper.Gst_details eachGst : resObj.data.gst_details){
                        APIVerDtl__c apiVerDtGst = new APIVerDtl__c();
                        apiVerDtGst.Type__c='Gst Details';
                        apiVerDtGst.Gstin__c=eachGst.gstin;
                        apiVerDtGst.GstStatus__c=eachGst.status;
                        apiVerDtGst.GstCompName__c=eachGst.company_name;
                        apiVerDtGst.TradeName__c=eachGst.trade_name;
                        apiVerDtGst.GstState__c=eachGst.state;
                        apiVerDtGst.StateJurisdiction__c=eachGst.state_jurisdiction;
                        apiVerDtGst.CentJurisdiction__c=eachGst.centre_jurisdiction;
                        apiVerDtGst.DateOfRegis__c= setDateFormat(eachGst.date_of_registration);
                        apiVerDtGst.TaxpayerType__c=eachGst.taxpayer_type;
                        apiVerDtGst.NatureBusActi__c=eachGst.nature_of_business_activities;

                        uow1.registerRelationship(apiVerDtGst, APIVerDtl__c.APIVerification__c, apiVerObj);  
						uow1.registerNew(apiVerDtGst);


                        if(eachGst.filings !=null)
                        {
                            for(ComCompreDtlsResponseWrapper.Filings eachGstFil :eachGst.filings ){
                                APIVerDtl__c apiVerDtGstFils = new APIVerDtl__c();
                                apiVerDtGstFils.Type__c='Gst Details Filings';
                                apiVerDtGstFils.ReturnType__c=eachGstFil.return_type;
                                apiVerDtGstFils.GstDateFiling__c=setDateFormat(eachGstFil.date_of_filing);
                                apiVerDtGstFils.GstFinYear__c=eachGstFil.financial_year;
                                apiVerDtGstFils.TaxPeriod__c=eachGstFil.tax_period;
                                apiVerDtGstFils.FilingsStatus__c=eachGstFil.status;

                                uow2.registerRelationship(apiVerDtGstFils, APIVerDtl__c.ApiVerDetails__c, apiVerDtGst);
                                uow2.registerRelationship(apiVerDtGstFils, APIVerDtl__c.APIVerification__c, apiVerObj);
                                uow2.registerNew(apiVerDtGstFils);

                            }
                        }


                    }

                }

                //GSt end details


                if(resObj.data.defaulter_list !=null){

                    for(ComCompreDtlsResponseWrapper.Defaulter_list eachDef : resObj.data.defaulter_list){
                        APIVerDtl__c apiVerDtDef = new APIVerDtl__c();
                        apiVerDtDef.Type__c='Defaulter List';
                        apiVerDtDef.DefListDate__c=setDateFormat(eachDef.date_Z);
                        apiVerDtDef.DefListAgency__c=eachDef.agency;
                        apiVerDtDef.DefListBank__c=eachDef.bank;
                        apiVerDtDef.DefListAmt__c=eachDef.amount;

                        uow1.registerRelationship(apiVerDtDef, APIVerDtl__c.APIVerification__c, apiVerObj);  
						uow1.registerNew(apiVerDtDef);

                    }

                }

                if(resObj.data.cdr_history !=null){
                    for(ComCompreDtlsResponseWrapper.Cdr_history eachCdrHis : resObj.data.cdr_history){
                        APIVerDtl__c apiVerDtCdrHis = new APIVerDtl__c();
                        apiVerDtCdrHis.Type__c='Cdr History';
                        apiVerDtCdrHis.DefListBank__c=eachCdrHis.date_Z;
                        apiVerDtCdrHis.DefListAmt__c=eachCdrHis.description;

                        uow1.registerRelationship(apiVerDtCdrHis, APIVerDtl__c.APIVerification__c, apiVerObj);  
						uow1.registerNew(apiVerDtCdrHis);

                    }
                }

                if(resObj.data.bifr_history!=null){

                    for(ComCompreDtlsResponseWrapper.Bifr_history eachBirf : resObj.data.bifr_history){
                        
                        APIVerDtl__c apiVerDtBirf = new APIVerDtl__c();
                        apiVerDtBirf.BifrDate__c= setDateFormat(eachBirf.date_Z);
                        apiVerDtBirf.BifrCaseNum__c=eachBirf.case_number;
                        apiVerDtBirf.BifrStatus__c=eachBirf.status;
                        apiVerDtBirf.Type__c='Bifr History';

                        uow1.registerRelationship(apiVerDtBirf, APIVerDtl__c.APIVerification__c, apiVerObj);  
						uow1.registerNew(apiVerDtBirf);



                    }

                }


                if(resObj.data.credit_ratings!=null){

                    for(ComCompreDtlsResponseWrapper.credit_ratings eachCrRat : resObj.data.credit_ratings){
                     
                    APIVerDtl__c apiVerDtCrRat = new APIVerDtl__c();
                    apiVerDtCrRat.Type__c='Credit Ratings';
                    apiVerDtCrRat.RatingDate__c= setDateFormat(eachCrRat.rating_date);
                    apiVerDtCrRat.RatingAgency__c=eachCrRat.rating_agency;
                    apiVerDtCrRat.Rating__c=eachCrRat.rating;
                    apiVerDtCrRat.TypeOfLoan__c=eachCrRat.type_of_loan;
                    apiVerDtCrRat.Currency__c=eachCrRat.currency_Z;
                    apiVerDtCrRat.RatingAmount__c= String.valueOf(eachCrRat.amount);

                     uow1.registerRelationship(apiVerDtCrRat, APIVerDtl__c.APIVerification__c, apiVerObj);  
                     uow1.registerNew(apiVerDtCrRat);



                     if(eachCrRat.rating_details !=null){

                        for(ComCompreDtlsResponseWrapper.Rating_details eachRatDtl : eachCrRat.rating_details){
                            APIVerDtl__c apiVerDtRatDtls = new APIVerDtl__c();
                            apiVerDtRatDtls.Type__c='Rating Details';

                            apiVerDtRatDtls.RatingAction__c=eachRatDtl.action;
                            apiVerDtRatDtls.Outlook__c=eachRatDtl.outlook;
                            apiVerDtRatDtls.RatingDetsName__c= eachRatDtl.rating;
                            apiVerDtRatDtls.RatingRemarks__c=eachRatDtl.remarks;

                            uow2.registerRelationship(apiVerDtratDtls, APIVerDtl__c.ApiVerDetails__c, apiVerDtCrRat);
                            uow2.registerRelationship(apiVerDtratDtls, APIVerDtl__c.APIVerification__c, apiVerObj);
                            uow2.registerNew(apiVerDtratDtls);
                        }
                     }
                    }

                }

                //charge_sequence Start

                if(resObj.data.charge_sequence!=null){

                    for(ComCompreDtlsResponseWrapper.Charge_sequence eachChrSeq :resObj.data.charge_sequence){

                        APIVerDtl__c apiVerDtCheSeq = new APIVerDtl__c();
                        apiVerDtCheSeq.Type__c='Charge Sequence';

                        apiVerDtCheSeq.ChargeSeqId__c= String.valueOf(eachChrSeq.charge_id);
                        apiVerDtCheSeq.ChargeSeqStatus__c=eachChrSeq.status;
                        apiVerDtCheSeq.ChargeSeqDate__c=setDateFormat(eachChrSeq.date_Z);
                        apiVerDtCheSeq.ChargeSeqAmt__c=eachChrSeq.amount;
                        apiVerDtCheSeq.ChargeSeqHoldName__c=eachChrSeq.holder_name;
                        apiVerDtCheSeq.ChargeSeqNoHolder__c=eachChrSeq.number_of_holder;
                        apiVerDtCheSeq.ChargeSeqPropType__c=eachChrSeq.property_type;
                        apiVerDtCheSeq.ChargeSeqFilDate__c=setDateFormat(eachChrSeq.filing_date);
                        apiVerDtCheSeq.PropParticulars__c=eachChrSeq.property_particulars;

                        uow2.registerRelationship(apiVerDtCheSeq, APIVerDtl__c.APIVerification__c, apiVerObj);
                        uow2.registerNew(apiVerDtCheSeq);



                    }
                } 
                //charge_sequence End


                //open_charges
                if(resObj.data.open_charges!=null){
                    for(ComCompreDtlsResponseWrapper.Open_charges eachOc : resObj.data.open_charges){
                                
                                APIVerDtl__c apiVerDtOpChrs = new APIVerDtl__c();
                                apiVerDtOpChrs.OpenChargesId__c= String.valueOf(eachOc.id);
                                apiVerDtOpChrs.OpenChargesDate__c=setDateFormat(eachOc.date_Z);
                                apiVerDtOpChrs.HolderName__c=eachOc.holder_name;
                                apiVerDtOpChrs.OpenChargesAmount__c=eachOc.amount;
                                apiVerDtOpChrs.OpenChargesType__c=eachOc.type;
                                apiVerDtOpChrs.Type__c='Open Charges';
                                uow1.registerRelationship(apiVerDtOpChrs, APIVerDtl__c.APIVerification__c, apiVerObj);  
						        uow1.registerNew(apiVerDtOpChrs);
                    } 
                }
                //open_charges End

                //Financial Start

                if(resObj.data.financials !=null){

                    for(ComCompreDtlsResponseWrapper.Financials eachFin : resObj.data.financials){
                         
                        //BS
                         if(eachFin.bs !=null){

                            Applicant_Financial__c applFinObjBs=new Applicant_Financial__c();
                            applFinObjBs.RecordTypeId = Schema.SObjectType.Applicant_Financial__c.getRecordTypeInfosByDeveloperName().get('Balance_Sheet').getRecordTypeId();
                            applFinObjBs.Type__c ='Probe42';
                            
                            applFinObjBs.Loan_Applicant__c = msg.RefId__c;
                            uow3.registerNew(applFinObjBs);

                            Applicant_Financial_Summary__c appFinSumBsObj= new Applicant_Financial_Summary__c();

                            if(eachFin.bs.assets!=null){

                                appFinSumBsObj.Nature__c=eachFin.nature;
                                appFinSumBsObj.FilingType__c=eachFin.filing_type;
                                appFinSumBsObj.FilingStandard__c=eachFin.filing_standard;
                                appFinSumBsObj.FinancialYearProbe__c= eachFin.year !=null ? eachFin.year :'';

                                appFinSumBsObj.TangibleAssets__c= eachFin.bs.assets.tangible_assets;                                      
                                appFinSumBsObj.ProducingProp__c= eachFin.bs.assets.producing_properties;  
                                appFinSumBsObj.PreproducingProp__c= eachFin.bs.assets.preproducing_properties;                               
                                appFinSumBsObj.IntangibleAssets__c= eachFin.bs.assets.intangible_assets;                                    
                                                          
                                appFinSumBsObj.TanAssetCapWIP__c= eachFin.bs.assets.tangible_assets_capital_work_in_progress;             
                                appFinSumBsObj.IntangAssetUnderDev__c= eachFin.bs.assets.intangible_assets_under_development;  
                                
                                appFinSumBsObj.NoncurrtInvestments__c= eachFin.bs.assets.noncurrent_investments;                               
                                appFinSumBsObj.DefTaxAssetNet__c= eachFin.bs.assets.deferred_tax_assets_net;    
                                appFinSumBsObj.LongTLoansAdvances__c= eachFin.bs.assets.long_term_loans_and_advances;
                                appFinSumBsObj.OtherNoncurrAsset__c= eachFin.bs.assets.other_noncurrent_assets;
                                appFinSumBsObj.ForCurrMoneTrDiffAsset__c= eachFin.bs.assets.foreign_curr_monetary_item_trans_diff_asset_account;  
                                                              
                                appFinSumBsObj.CurrtInvestments__c= eachFin.bs.assets.current_investments;                                  
                                appFinSumBsObj.Inventories__c= eachFin.bs.assets.inventories;                                          
                                appFinSumBsObj.TradeReceivables__c= eachFin.bs.assets.trade_receivables;                                    
                                appFinSumBsObj.Cash_Bank_Balances__c= eachFin.bs.assets.cash_and_bank_balances;                               
                                appFinSumBsObj.ShortTLoansNAdvances__c= eachFin.bs.assets.short_term_loans_and_advances;                        
                                appFinSumBsObj.Other_current_assets__c= eachFin.bs.assets.other_current_assets;                                 
                                
                                appFinSumBsObj.GivenAssetsTotal__c= eachFin.bs.assets.given_assets_total;     
                            }

                             if(eachFin.bs.liabilities!=null){

                                appFinSumBsObj.ShareCapital__c = eachFin.bs.liabilities.share_capital !=null ? eachFin.bs.liabilities.share_capital :0;
                                appFinSumBsObj.ReserveNSurplus__c =eachFin.bs.liabilities.reserves_and_surplus !=null ? eachFin.bs.liabilities.reserves_and_surplus :0;
                                appFinSumBsObj.MoneyRecAgShWarrant__c =eachFin.bs.liabilities.money_received_against_share_warrants !=null ? eachFin.bs.liabilities.money_received_against_share_warrants:0;
                                appFinSumBsObj.ShAppMoneyPenAllot__c =eachFin.bs.liabilities.share_application_money_pending_allotment !=null ? eachFin.bs.liabilities.share_application_money_pending_allotment :0;
                                appFinSumBsObj.DefGovtGrants__c =eachFin.bs.liabilities.deferred_government_grants !=null ? eachFin.bs.liabilities.deferred_government_grants :0;
                                appFinSumBsObj.MinorityInterest__c =eachFin.bs.liabilities.minority_interest !=null ? eachFin.bs.liabilities.minority_interest:0;

                                appFinSumBsObj.LongTermBorrow__c =eachFin.bs.liabilities.long_term_borrowings;                                    
                                appFinSumBsObj.DefTaxLiabNet__c=eachFin.bs.liabilities.deferred_tax_liabilities_net;                            
                                appFinSumBsObj.ForeignCurrLiabAcc__c=eachFin.bs.liabilities.foreign_curr_monetary_item_trans_diff_liability_account; 
                                appFinSumBsObj.OtherLongTermLiab__c=eachFin.bs.liabilities.other_long_term_liabilities;                             
                                appFinSumBsObj.LongTermProv__c= eachFin.bs.liabilities.long_term_provisions; 

                                appFinSumBsObj.ShortTermBorrow__c=eachFin.bs.liabilities.short_term_borrowings;                                   
                                appFinSumBsObj.TradePayables__c=eachFin.bs.liabilities.trade_payables;                                   
                                appFinSumBsObj.Other_current_liabilities__c=eachFin.bs.liabilities.other_current_liabilities;                               
                                appFinSumBsObj.ShortTermProv__c=eachFin.bs.liabilities.short_term_provisions;                                   
                                
                                appFinSumBsObj.GivenLiabTotal__c=eachFin.bs.liabilities.given_liabilities_total;                                 

                            }
                             
                            if(eachFin.bs.subTotals!=null){
                                appFinSumBsObj.TotalEquity__c=eachFin.bs.subTotals.total_equity;              
                                appFinSumBsObj.TotlCurrtLiabilities__c=eachFin.bs.subTotals.total_current_liabilities; 
                            }

                            if(eachFin.bs.subTotals!=null){
                                appFinSumBsObj.NetFixedAssets__c= eachFin.bs.subTotals.net_fixed_assets;                
                            }

                            uow3.registerRelationship(appFinSumBsObj, Applicant_Financial_Summary__c.Applicant_Financial__c, applFinObjBs);  
						    uow3.registerNew(appFinSumBsObj);
                         }


                         //PNL
                         if(eachFin.pnl!=null){
                            
                            Applicant_Financial__c applFinObjPnl=new Applicant_Financial__c();

                            applFinObjPnl.RecordTypeId = Schema.SObjectType.Applicant_Financial__c.getRecordTypeInfosByDeveloperName().get('Profit_Loss').getRecordTypeId();
                            applFinObjPnl.Type__c ='Probe42';
                            
                            applFinObjPnl.Loan_Applicant__c = msg.RefId__c;
                            uow3.registerNew(applFinObjPnl);
                            
                            Applicant_Financial_Summary__c appFinSumPnlObj= new Applicant_Financial_Summary__c();
                            
                            if(eachFin.pnl.lineItems!=null){
                               
                                appFinSumPnlObj.Nature__c=eachFin.nature;
                                appFinSumPnlObj.FilingType__c=eachFin.filing_type;
                                appFinSumPnlObj.FilingStandard__c =eachFin.filing_standard;
                                appFinSumPnlObj.FinancialYearProbe__c = eachFin.year !=null ? eachFin.year :'';
                                appFinSumPnlObj.NetRevenue__c =eachFin.pnl.lineItems.net_revenue;                                                     
                                appFinSumPnlObj.TotCostMatConsumed__c =eachFin.pnl.lineItems.total_cost_of_materials_consumed;                                
                                appFinSumPnlObj.TotPurchStockInTrade__c =eachFin.pnl.lineItems.total_purchases_of_stock_in_trade;                               
                                appFinSumPnlObj.TotlChInventFinished__c =eachFin.pnl.lineItems.total_changes_in_inventories_or_finished_goods;                  
                                appFinSumPnlObj.TotlEmpBenefitExp__c =eachFin.pnl.lineItems.total_employee_benefit_expense;                                  
                                appFinSumPnlObj.TotlOtherExp__c =eachFin.pnl.lineItems.total_other_expenses;  
                               
                                appFinSumPnlObj.OperatingProfit__c =eachFin.pnl.lineItems.operating_profit;                                                
                                appFinSumPnlObj.OtherIncome__c =eachFin.pnl.lineItems.other_income;                                                    
                                appFinSumPnlObj.Depreciation__c =eachFin.pnl.lineItems.depreciation;                                                    
                                appFinSumPnlObj.ProfitBeforeIntAndTax__c =eachFin.pnl.lineItems.profit_before_interest_and_tax;                                  
                                appFinSumPnlObj.ProfitLossInterest__c =eachFin.pnl.lineItems.interest;                                                        
                                appFinSumPnlObj.ProfitBefrTaxExItems__c =eachFin.pnl.lineItems.profit_before_tax_and_exceptional_items_before_tax;              
                                appFinSumPnlObj.ExcepItemsBeforeTax__c =eachFin.pnl.lineItems.exceptional_items_before_tax;                                    
                                appFinSumPnlObj.ProfitBeforeTax__c =eachFin.pnl.lineItems.profit_before_tax;                                               
                                appFinSumPnlObj.IncomeTax__c =eachFin.pnl.lineItems.income_tax;                                                      
                                appFinSumPnlObj.ProfitPeriodFrContOperat__c =eachFin.pnl.lineItems.profit_for_period_from_continuing_operations;                    
                                appFinSumPnlObj.ProfitFromDiscontOpTax__c =eachFin.pnl.lineItems.profit_from_discontinuing_operation_after_tax;                   
                                appFinSumPnlObj.MinIntProfitFromAssoc__c =eachFin.pnl.lineItems.minority_interest_and_profit_from_associates_and_joint_ventures; 
                                
                                appFinSumPnlObj.ProfitAfterTax__c =eachFin.pnl.lineItems.profit_after_tax;

                             } 
                             
                             if(eachFin.pnl.subTotals!=null){
                                appFinSumPnlObj.TotlOperatingCost__c =eachFin.pnl.subTotals.total_operating_cost;
                             } 
                             
                             if(eachFin.pnl.revenue_breakup!=null){

                                appFinSumPnlObj.RevFrmSaleProducts__c =eachFin.pnl.revenue_breakup.revenue_from_sale_of_products;
                                appFinSumPnlObj.RevFrmSaleServices__c =eachFin.pnl.revenue_breakup.revenue_from_sale_of_services;
                                appFinSumPnlObj.OtherOpRevenues__c =eachFin.pnl.revenue_breakup.other_operating_revenues;
                                appFinSumPnlObj.RevFrmOthFinSer__c =eachFin.pnl.revenue_breakup.revenue_from_other_financial_services;
                                appFinSumPnlObj.RevFrmInterest__c =eachFin.pnl.revenue_breakup.revenue_from_interest;
                                appFinSumPnlObj.RevFrmOperations__c =eachFin.pnl.revenue_breakup.revenue_from_operations;
                                appFinSumPnlObj.ExciseDuty__c =eachFin.pnl.revenue_breakup.excise_duty;                           
                                appFinSumPnlObj.ServiceTaxCollected__c =eachFin.pnl.revenue_breakup.service_tax_collected; 
                                appFinSumPnlObj.OthDutiesTaxColl__c =eachFin.pnl.revenue_breakup.other_duties_taxes_collected;
                               
                                appFinSumPnlObj.SaleGoodsManDom__c =eachFin.pnl.revenue_breakup.sale_of_goods_manufactured_domestic;
                                appFinSumPnlObj.SaleGoodsTrDomestic__c =eachFin.pnl.revenue_breakup.sale_of_goods_traded_domestic;  
                                appFinSumPnlObj.SaleSupplyServDomestic__c =eachFin.pnl.revenue_breakup.sale_or_supply_of_services_domestic; 
                                appFinSumPnlObj.SaleGoodsManExport__c =eachFin.pnl.revenue_breakup.sale_of_goods_manufactured_export;
                                appFinSumPnlObj.SaleGoodsTrExport__c =eachFin.pnl.revenue_breakup.sale_of_goods_traded_export;
                                appFinSumPnlObj.SaleSupplyServExp__c =eachFin.pnl.revenue_breakup.sale_or_supply_of_services_export;
                                
                             } 

                             uow3.registerRelationship(appFinSumPnlObj, Applicant_Financial_Summary__c.Applicant_Financial__c, applFinObjPnl);  
                             uow3.registerNew(appFinSumPnlObj);

                        }

                      }//For Loop End 
                 }
                //Financial Data End


                
                //open_charges_latest_event Start
                if(resObj.data.open_charges_latest_event !=null){

                           for(ComCompreDtlsResponseWrapper.Open_charges_latest_event eachOcLt : resObj.data.open_charges_latest_event){
                                
                            APIVerDtl__c apiVerDtOpChrslatst = new APIVerDtl__c();
                            apiVerDtOpChrslatst.Type__c='Open Charges Latest';
                            apiVerDtOpChrslatst.OpenchLatEventId__c=	String.valueOf(eachOcLt.id);                         
                            apiVerDtOpChrslatst.OpenchLatEvtDate__c=	setDateFormat(eachOcLt.date_Z);                       
                            apiVerDtOpChrslatst.OpchLatEvtHolderName__c=	eachOcLt.holder_name;                
                            apiVerDtOpChrslatst.OpChLatEvtAmount__c=	eachOcLt.amount;                    
                            apiVerDtOpChrslatst.OpChLatEvtType__c=	eachOcLt.type;                      
                            apiVerDtOpChrslatst.OpChLatEvtFildate__c=	setDateFormat(eachOcLt.filing_date);             
                            apiVerDtOpChrslatst.OpChLatEvtPropType__c=	eachOcLt.property_type;            
                            apiVerDtOpChrslatst.NumOfChargeholder__c=	eachOcLt.number_of_chargeholder;     
                            apiVerDtOpChrslatst.InstrumDesc__c=	eachOcLt.instrument_description;     
                            apiVerDtOpChrslatst.RateOfInterest__c=	eachOcLt.rate_of_interest;           
                            apiVerDtOpChrslatst.TermsOfPayment__c=	eachOcLt.terms_of_payment;           
                            apiVerDtOpChrslatst.PropParticulars__c=	eachOcLt.property_particulars;       
                            apiVerDtOpChrslatst.ExtAndOper__c=	eachOcLt.extent_and_operation;       
                            apiVerDtOpChrslatst.OtherTerms__c=	eachOcLt.other_terms;                
                            apiVerDtOpChrslatst.ModiParticulars__c=	eachOcLt.modification_particulars;   
                            apiVerDtOpChrslatst.JointHolding__c=	eachOcLt.joint_holding;              
                            apiVerDtOpChrslatst.ConsortHolding__c=	eachOcLt.consortium_holding;

                            uow1.registerRelationship(apiVerDtOpChrslatst, APIVerDtl__c.APIVerification__c, apiVerObj);  
                            uow1.registerNew(apiVerDtOpChrslatst);         

                           } 

                    }//open_charges_latest_event End



                    /*if(resObj.data.legal_history!=null){

                        for(ComCompreDtlsResponseWrapper.Legal_history eachLegal : resObj.data.legal_history){
                            APIVerDtl__c apiVerDtLegal = new APIVerDtl__c();
                            apiVerDtLegal.Type__c='Legal History';
                            apiVerDtLegal.Petitioner__c=eachLegal.petitioner;
                            apiVerDtLegal.Respondent__c=eachLegal.respondent;
                            apiVerDtLegal.CourtName__c=eachLegal.court;
                            apiVerDtLegal.DateLastHearing__c=eachLegal.date;
                            apiVerDtLegal.CaseStatus__c=eachLegal.case_status;
                            apiVerDtLegal.CaseNum__c=eachLegal.case_number;
                            apiVerDtLegal.CaseCategory__c=eachLegal.case_category;
                            apiVerDtLegal.CaseType__c=eachLegal.case_type;

                            uow1.registerRelationship(apiVerDtLegal, APIVerDtl__c.APIVerification__c, apiVerObj);  
                            uow1.registerNew(apiVerDtLegal); 
                            
                        }

                    }*/
                    //director_shareholdings  START
                    if(resObj.data.director_shareholdings!=null){

                        for(ComCompreDtlsResponseWrapper.Director_shareholdings eachDirShHold : resObj.data.director_shareholdings){
                         
                            APIVerDtl__c apiVerDtDirShHold = new APIVerDtl__c();
                            apiVerDtDirShHold.Type__c='Director Shareholdings';


                            apiVerDtDirShHold.DirShareYear__c=eachDirShHold.year;
                            apiVerDtDirShHold.DirShareFinYear__c= setDateFormat(eachDirShHold.financial_year);
                            apiVerDtDirShHold.DinPan__c=eachDirShHold.din_pan;
                            apiVerDtDirShHold.DirShareFullName__c=eachDirShHold.full_name;
                            apiVerDtDirShHold.DirShareDesig__c=eachDirShHold.designation;
                            apiVerDtDirShHold.DirShareDateCessation__c= setDateFormat(eachDirShHold.date_of_cessation);
                            apiVerDtDirShHold.DirShareNoOfShares__c=eachDirShHold.no_of_shares;
                            apiVerDtDirShHold.DirSharePerHolding__c=eachDirShHold.percentage_holding;

                            uow1.registerRelationship(apiVerDtDirShHold, APIVerDtl__c.APIVerification__c, apiVerObj);  
                            uow1.registerNew(apiVerDtDirShHold);


                        }

                    }
                    //director_shareholdings END

                    //shareholdings_summary START
                    if(resObj.data.shareholdings_summary!=null){

                        for(ComCompreDtlsResponseWrapper.Shareholdings_summary eachShSum : resObj.data.shareholdings_summary){
                            
                            APIVerDtl__c apiVerDtShHoldSum = new APIVerDtl__c();
                            apiVerDtShHoldSum.Type__c='Shareholdings Summary';

                            apiVerDtShHoldSum.ShareSumYear__c=eachShSum.year;
                            apiVerDtShHoldSum.ShareSumFinYear__c= setDateFormat(eachShSum.financial_year);
                            apiVerDtShHoldSum.TotalEqShares__c=eachShSum.total_equity_shares;
                            apiVerDtShHoldSum.TotalPrefShares__c=eachShSum.total_preference_shares;
                            apiVerDtShHoldSum.Promoter__c=eachShSum.promoter;
                            apiVerDtShHoldSum.Public__c=eachShSum.public_Z;
                            apiVerDtShHoldSum.ShareholdSumTotal__c=eachShSum.total;

                            if(eachShSum.metadata!=null){
                                apiVerDtShHoldSum.DocId__c=eachShSum.metadata.doc_id;
                            }

                            uow1.registerRelationship(apiVerDtShHoldSum, APIVerDtl__c.APIVerification__c, apiVerObj);  
                            uow1.registerNew(apiVerDtShHoldSum);


                        }

                    }

                    //shareholdings_summary END

                }
                APICalloutTracker.update_ApiTrackerWithIntMsg(msg.Id,msg.Svc__c, msg.RefId__c, 'Success');
            }  //APi Ver Details ENd and self lookup
            
            //Calling Report APIs
            IntgMsg__c intmsg = new IntgMsg__c();
            intmsg.Name='Company Report';
            intmsg.BU__c='HL / STL';
            intmsg.Status__c='New';
            intmsg.MStatus__c='Blank';
            intmsg.RefObj__c='Applicant__c';
            intmsg.Svc__c='Company Report';
            intmsg.ParentRefId__c=msg.ParentRefId__c;
            intmsg.ParentRefObj__c=msg.ParentRefObj__c;
            intmsg.RefId__c = msg.RefId__c; //appKyc[0].Applicant__c;
            intmsg.IsActive__c=true;
            //intmsg.Resp__c ='An Unique Identifier';
            //intmsg.Trigger_Platform_Event__c = true;
            createRequestList.add(intmsg); 


            //Calling Document API
            IntgMsg__c intmsg1 = new IntgMsg__c();
            intmsg1.Name='Company Incorporation Document';
            intmsg1.BU__c='HL / STL';
            intmsg1.Status__c='New';
            intmsg1.MStatus__c='Blank';
            intmsg1.Svc__c='Company Incorporation Document';
            intmsg1.RefObj__c='Applicant__c';
            intmsg1.ParentRefId__c=msg.ParentRefId__c;
            intmsg1.ParentRefObj__c=msg.ParentRefObj__c;
            intmsg1.RefId__c = msg.RefId__c; //appKyc[0].Applicant__c;
            intmsg1.IsActive__c=true;
            //intmsg1.Resp__c ='An Unique Identifier';
            //intmsg.Trigger_Platform_Event__c = true;
            
            createRequestList.add(intmsg1); 

            //Called APIs


        }  //End Of for loop



        if(!createRequestList.isEmpty()){
            fflib_SObjectUnitOfWork uowInt = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType});
            List<string> fieldNamesList = New List<string>{'Name','BU__c','RefId__c','Status__c','MStatus__c','RefObj__c','Svc__c','ApiVendor__c',
                'IsActive__c','ParentRefId__c','ParentRefObj__c'};
                    String sObjectName = 'IntgMsg__c';
            Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
            fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
            uowInt.registerNew(createRequestList);
            uowInt.commitWork();
        }


                
            uow1.commitWork();
            uow2.commitWork();
            uow3.commitWork();

            

        }catch(Exception ex) {
                GlobalUtility.logMessage('Error', 'Company Comprehensive DtlsResponseProcessor',
                    'processSuccess', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
    
    }


    private static List<APIVer__c> getExistingApiVerRecords(Set<Id> applicantIds) {
        system.debug('making list true');
        return [SELECT Id, Appl__c, IsLatest__c, RecordType.Name,Type__c FROM APIVer__c WHERE Appl__c IN :applicantIds AND RecordType.DeveloperName = 'Probe42' AND IsLatest__c = true and Type__c ='Probe Comprehensive Company'];
    }
    

    public static Date setDateFormat(String datePass) 
    {
            if (datePass != null) {
                return Date.valueOf(datePass);
            }else{
                return null;
            } 
    }

    public static void processFailure(String messageRes,Map<IntgMsg__c,ComCompreDtlsResponseWrapper> failureResp){
        
        try{
            
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> {ApplKyc__c.SObjectType,APIVer__c.SObjectType});
            
            Set<Id> applicantIds =new Set<Id>();
            List<APIVer__c> appVerList=new List<APIVer__c>();
            
            Id recordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Probe42').getRecordTypeId();
            
            for(IntgMsg__c msg:failureResp.keyset()){
                
                if(string.isNotblank(msg.RefId__c)){
                    applicantIds.add(msg.RefId__c);
                }
            }
            
            //SOQL to check old records
            List<APIVer__c> apiVer =[Select id,Appl__c,IsLatest__c,RecordType.Name,Type__c from APIVer__c Where Appl__c IN:applicantIds AND RecordType.DeveloperName='Probe42' AND IsLatest__c=true and Type__c ='Probe Comprehensive Company'];
            
            if(!apiVer.isEmpty()){
                IntegrationUtility.updateBooleanFlag(apiVer,'IsLatest__c',false);
            }
            
            //Looping to update the records
            for(IntgMsg__c msg:failureResp.keyset()){
                
                if(failureResp.containsKey(msg) && String.isNotblank(msg.RefId__c)){
                    
                            APIVer__c apiveri =new APIVer__c();
                            apiveri.Appl__c=msg.RefId__c;
                            apiveri.LoanAplcn__c = msg.ParentRefId__c;
                            apiveri.IntegrationStatus__c='Failure';
                            apiveri.Type__c='Probe Comprehensive Company';
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
            GlobalUtility.logMessage('Error', 'ComCompreDtlsResponse Processor', 
                                     'processFailure', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    

    }


}