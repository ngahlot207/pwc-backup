public class LlpCompreDtlsResponseProcessor implements IintMsgCalloutResponseProcessor{
 
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
                                         ContentDocument.Title = 'response.json']){
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
                    Map<IntgMsg__c,LlpCompreDtlsResponseWrapper> successResponseMap = new Map<IntgMsg__c,LlpCompreDtlsResponseWrapper>();
                    
                    if(cvdata!=null){
                        String jsonContent = cvdata.VersionData.toString();
                        LlpCompreDtlsResponseWrapper res = (LlpCompreDtlsResponseWrapper) JSON.deserialize(jsonContent, LlpCompreDtlsResponseWrapper.class);
                        successResponseMap.put(intMsg,res);
                        
                        try{
                             LlpCompreDtlsQueueable queueableInstance = new LlpCompreDtlsQueueable(successResponseMap,jsonContent);
                             System.enqueueJob(queueableInstance);
                            
                        }
                        catch(Exception ex){
                             GlobalUtility.logMessage('Error', 'LlpCompreDtlsResponseProcessor class', 
                                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                        }
                    }
                    
                }
                
            }
        }
        
    }


 

    public static void processSuccess(Map<IntgMsg__c, LlpCompreDtlsResponseWrapper> successResp) {
        try {
          system.debug('process called llp comprehensive details');
          //fflib_SObjectUnitOfWork uow1 = new fflib_SObjectUnitOfWork(new List<SObjectType>{IntgMsg__c.SObjectType, APIVer__c.SObjectType, APIVerDtl__c.SObjectType ,Applicant_Financial__c.SObjectType , Applicant_Financial_Summary__c.SObjectType });
          fflib_SObjectUnitOfWork uow1 = new fflib_SObjectUnitOfWork(new List<SObjectType> {APIVer__c.SObjectType, APIVerDtl__c.SObjectType ,Applicant__c.SObjectType,LoanApplRelationship__c.SObjectType  }); 
           
          fflib_SObjectUnitOfWork uow2 = new fflib_SObjectUnitOfWork(new List<SObjectType>{IntgMsg__c.SObjectType, APIVer__c.SObjectType, APIVerDtl__c.SObjectType});
          fflib_SObjectUnitOfWork uow3 = new fflib_SObjectUnitOfWork(new List<SObjectType> {Applicant_Financial__c.SObjectType  ,Applicant_Financial_Summary__c.SObjectType });   
            Set<Id> applicantIds = new Set<Id>();
            Set<Id> loanAppIds = new Set<Id>();
            Set<String> directorPans = new Set<String>();
            List<IntgMsg__c> createRequestList = new List<IntgMsg__c>();  

            for (IntgMsg__c intmsg : successResp.keySet()) {
                if (String.isNotBlank(intmsg.RefId__c)) {
                    applicantIds.add(intmsg.RefId__c);
                }
                if (String.isNotBlank(intmsg.ParentRefId__c)) {
                    loanAppIds.add(intmsg.ParentRefId__c);
                }

            LlpCompreDtlsResponseWrapper resObj = successResp.get(intmsg);
            if(resObj!=null && resObj.data!=null && resObj.data.director_network !=null)
                {
                    for(LlpCompreDtlsResponseWrapper.Director_network eachDirNw : resObj.data.director_network){
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

            List<LoanApplRelationship__c> listLoanAppRels=[SELECT Id,Related_Person__c,Loan_Applicant__c  from LoanApplRelationship__c where Related_Person__c  In : idApplsExist and Loan_Applicant__c In : applicantIds]; // and Loan_Applicant__c =msg.RefId

            Map<String, LoanApplRelationship__c> existAppRelMap = new Map<String, LoanApplRelationship__c>();
            
            for (LoanApplRelationship__c app : listLoanAppRels) {
                if (app.Related_Person__c != null) {
                    existAppRelMap.put(app.Related_Person__c + '-' + app.Loan_Applicant__c, app);
                }
            }

            System.debug('existAppRelMap ==>'+existAppRelMap);
            System.debug('existAppMapByPAN ==>'+existAppMapByPAN);


            //

            if(!applicantIds.isEmpty()){
            List<APIVer__c> existingApiVers = getExistingApiVerRecords(applicantIds);
            if (!existingApiVers.isEmpty()) {
                IntegrationUtility.updateBooleanFlag(existingApiVers, 'IsLatest__c', false);
            }
            }

            

            
            //API ver data insert start
            for (IntgMsg__c msg : successResp.keySet()) {

                LlpCompreDtlsResponseWrapper resObj = successResp.get(msg);
                
                APIVer__c apiVerObj = new APIVer__c();
                apiVerObj.RecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Probe42').getRecordTypeId();
                apiVerObj.Appl__c = msg.RefId__c;
                apiVerObj.LoanAplcn__c =msg.ParentRefId__c;
                apiVerObj.IsLatest__c = true;
                apiVerObj.IntegrationStatus__c = 'Success';
                apiVerObj.Type__c='Probe Comprehensive LLP';


                if(resObj !=null){

                    if(resObj.metadata !=null ){

                        apiVerObj.ApiVersion__c =resObj.metadata.api_version;
                        apiVerObj.Lstupdt__c = setDateFormat(resObj.metadata.last_updated);

                    }    

                    if(resObj.data !=null){

                        if(resObj.data.llp !=null){


                            apiVerObj.TotObligOfContri__c=resObj.data.llp.total_obligation_of_contribution;
                            apiVerObj.Llpin__c= resObj.data.llp.llpin;
                            apiVerObj.EfilingStatus__c=resObj.data.llp.efiling_status;
                            apiVerObj.DteOfIncorp__c= setDateFormat(resObj.data.llp.incorporation_date);
                            apiVerObj.LastAnnRetFiledDate__c= setDateFormat(resObj.data.llp.last_annual_returns_filed_date);
                            apiVerObj.LastFinReportDate__c= setDateFormat(resObj.data.llp.last_financial_reporting_date);
                            apiVerObj.LlpLegalName__c=resObj.data.llp.legal_name;
                            apiVerObj.TotContriReceived__c=resObj.data.llp.total_contribution_received;
                            apiVerObj.SumOfCharges__c=resObj.data.llp.sum_of_charges;
                            apiVerObj.Name__c=resObj.data.llp.legal_name;
                           
                            
                            if(resObj.data.llp.registered_address !=null){
                                apiVerObj.Address__c=	resObj.data.llp.registered_address.full_address;
                                apiVerObj.AddrLine1__c=resObj.data.llp.registered_address.address_line1;
                                apiVerObj.AddrLine2__c=resObj.data.llp.registered_address.address_line2;
                                apiVerObj.City__c=resObj.data.llp.registered_address.city;
                                apiVerObj.Pincode__c=resObj.data.llp.registered_address.pincode;
                                apiVerObj.State__c=resObj.data.llp.registered_address.state;
                            }

                            if(resObj.data.llp.business_address!=null){
                                apiVerObj.BusAddrLine_1__c=resObj.data.llp.business_address.address_line1;
                                apiVerObj.BusAddrLine2__c=resObj.data.llp.business_address.address_line2;
                                apiVerObj.BusAddrCIty__c=resObj.data.llp.business_address.city;
                                apiVerObj.BusAddrPin__c=resObj.data.llp.business_address.pincode;
                                apiVerObj.BusAddrState__c=resObj.data.llp.business_address.state;
                            }

                            apiVerObj.Website__c=resObj.data.llp.website;
                            apiVerObj.Pan__c=resObj.data.llp.pan;
                            apiVerObj.Classification__c=resObj.data.llp.classification;
                            apiVerObj.Email__c=resObj.data.llp.email;

                            if(resObj.data.llp.lei !=null){
                                apiVerObj.LeiNumber__c=resObj.data.llp.lei.number_Z;
                                apiVerObj.LeiStatus__c=resObj.data.llp.lei.status;
                                apiVerObj.DateOfRegistration__c=setDateFormat(resObj.data.llp.lei.registration_date);
                                apiVerObj.LeiLastUpdDate__c=setDateFormat(resObj.data.llp.lei.last_updated_date);
                                apiVerObj.NextRenewDate__c=setDateFormat(resObj.data.llp.lei.next_renewal_date);
                            }

                        }

                        if(resObj.data.description != null){
                                apiVerObj.DataDesc__c= resObj.data.description.desc_thousand_char;
                        }

                        uow1.registerNew(apiVerObj);
                        //APi Ver Obj Register
                             
                        if(resObj.data.name_history != null){
                            for(LlpCompreDtlsResponseWrapper.Name_history eachNmHis : resObj.data.name_history ){
                                APIVerDtl__c apiVerDtlNmHisObj = new APIVerDtl__c();
                                apiVerDtlNmHisObj.Type__c = 'Name History';
                                apiVerDtlNmHisObj.NameHisName__c= eachNmHis.name;
                                apiVerDtlNmHisObj.NameHisDate__c= setDateFormat(eachNmHis.date_Z);
                                uow1.registerRelationship(apiVerDtlNmHisObj, APIVerDtl__c.APIVerification__c, apiVerObj);  
                                uow1.registerNew(apiVerDtlNmHisObj);  
                            }
                        }

                        if(resObj.data.directors != null){
                            for(LlpCompreDtlsResponseWrapper.Directors eachDir : resObj.data.directors ){
                                        //For Applicant Info Start

                                        if(msg.ParentRefId__c !=null && eachDir.pan!=null && !existAppMapByPAN.containsKey(eachDir.pan +'-'+ msg.ParentRefId__c)){

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
                                            
                                            uow1.registerNew(applObj);
    
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
    
                                            uow1.registerRelationship(appRelObj, LoanApplRelationship__c.Related_Person__c, applObj);   
                                            uow1.registerNew(appRelObj);
    
    
                                        }
                                        else if(eachDir.pan!=null && msg.ParentRefId__c!=null && existAppMapByPAN.containsKey(eachDir.pan +'-'+ msg.ParentRefId__c)){
    
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
                                            
                                            uow1.registerDirty(applObj);
    
                                            if(msg.RefId__c!=null && eachDir.pan!=null && existAppRelMap.containsKey(applObj.Id +'-'+ msg.RefId__c))
                                            {
    
                                            LoanApplRelationship__c appRelObj = new LoanApplRelationship__c();
                                            //System.debug('id rel obj:'+existAppRelMap.get(existAppMapByPAN.get(eachDir.pan +'-' +msg.ParentRefId__c).Id +'-'+ msg.RefId__c));
                                            appRelObj.Id=existAppRelMap.get(applObj.Id +'-'+ msg.RefId__c).Id;
                                            //existAppRelMap.get(existAppMapByPAN.get(eachDir.pan +'-' +msg.ParentRefId__c).Id).Id;
                                            //existAppRelMap.get(existAppMapByPAN.get(eachDir.pan +'-' +msg.ParentRefId__c).Id
                                            
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
    
                                            uow1.registerRelationship(appRelObj, LoanApplRelationship__c.Related_Person__c, applObj);   
                                            uow1.registerDirty(appRelObj);
                                            }else{
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
                                                appRelObj.Relationship_Type__c='Partner';
    
                                                uow1.registerRelationship(appRelObj, LoanApplRelationship__c.Related_Person__c, applObj);   
                                                uow1.registerNew(appRelObj);
    
                                            }
    
                                        }



                                        ///For Applicant Info End
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

                                }}
                        }

                        //Directors data End


                        if(resObj.data.director_network !=null){

                        for(LlpCompreDtlsResponseWrapper.Director_network eachDirNw : resObj.data.director_network){

                           
                        APIVerDtl__c apiVerDtlDirNw = new APIVerDtl__c();
                        apiVerDtlDirNw.DirectNwName__c =eachDirNw.name;
                        apiVerDtlDirNw.Pan__c=eachDirNw.pan;
                        apiVerDtlDirNw.Din__c =eachDirNw.din;
                        apiVerDtlDirNw.Type__c='Director Network';
                        uow1.registerRelationship(apiVerDtlDirNw, APIVerDtl__c.APIVerification__c, apiVerObj);  
						uow1.registerNew(apiVerDtlDirNw);

                        if(eachDirNw.network!=null)
                        {
                            if(eachDirNw.network.companies !=null){

                                for(LlpCompreDtlsResponseWrapper.Companies eachComNw : eachDirNw.network.companies){

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

                                for(LlpCompreDtlsResponseWrapper.Llps eachllpNw : eachDirNw.network.llps){

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

                //director_network

                if(resObj.data.contact_details!=null){
                    
                    if(resObj.data.contact_details.email!=null){
                            for(LlpCompreDtlsResponseWrapper.Email eachEms : resObj.data.contact_details.email){
                                APIVerDtl__c apiVerDtEm = new APIVerDtl__c();
                                apiVerDtEm.EmailId__c=eachEms.emailId;
                                apiVerDtEm.EmailStatus__c =eachEms.status;
                                apiVerDtEm.Type__c='Email';
                                uow1.registerRelationship(apiVerDtEm, APIVerDtl__c.APIVerification__c, apiVerObj);  
						        uow1.registerNew(apiVerDtEm);
                            } 
                        }
                          
                        if(resObj.data.contact_details.phone!=null){
                            for(LlpCompreDtlsResponseWrapper.Phone eachPhs: resObj.data.contact_details.phone){
                                APIVerDtl__c apiVerDtPh = new APIVerDtl__c();
                                apiVerDtPh.PhoneNumber__c=eachPhs.phoneNumber;
                                apiVerDtPh.PhoneStatus__c=eachPhs.status;
                                apiVerDtPh.Type__c='Phone';
                                uow1.registerRelationship(apiVerDtPh, APIVerDtl__c.APIVerification__c, apiVerObj);  
						        uow1.registerNew(apiVerDtPh);
                            }
                        }     
                        
                    

                }


                

                //Financial Details Start

                if(resObj.data.financials !=null){

                    for(LlpCompreDtlsResponseWrapper.Financials eachFinObj : resObj.data.financials){

                        if(eachFinObj.statement_of_assets_and_liabilities!=null){

                            Applicant_Financial__c applFinObjAsstNLiab =new Applicant_Financial__c();
                            applFinObjAsstNLiab.RecordTypeId = Schema.SObjectType.Applicant_Financial__c.getRecordTypeInfosByDeveloperName().get('Balance_Sheet').getRecordTypeId();
                            applFinObjAsstNLiab.Type__c ='Probe42';
                            
                            applFinObjAsstNLiab.Loan_Applicant__c = msg.RefId__c;
                            uow3.registerNew(applFinObjAsstNLiab);


                            Applicant_Financial_Summary__c appFinSumAsstNLiabObj= new Applicant_Financial_Summary__c();

                            if(eachFinObj.statement_of_assets_and_liabilities.assets !=null){

                                appFinSumAsstNLiabObj.FinancialYearProbe__c= eachFinObj.year !=null ? eachFinObj.year :'';
                                

                                LlpCompreDtlsResponseWrapper.Assets eachAssetObj =eachFinObj.statement_of_assets_and_liabilities.assets;
                                //MAp App Fin Summary FIelds  like appFinSumAsstNLiabObj.
                                appFinSumAsstNLiabObj.GrossFixedAssets__c=eachAssetObj.gross_fixed_assets;
                                appFinSumAsstNLiabObj.DepreAmortization__c=eachAssetObj.depreciation_and_amortization;
                                appFinSumAsstNLiabObj.Investments__c=eachAssetObj.investments;
                                appFinSumAsstNLiabObj.Other_loans_advances__c=eachAssetObj.loans_and_advances;//Doubt
                                appFinSumAsstNLiabObj.Inventories__c =eachAssetObj.inventories;
                                appFinSumAsstNLiabObj.TradeReceivables__c=eachAssetObj.trade_receivables;
                                appFinSumAsstNLiabObj.CashNCashEquiv__c=eachAssetObj.cash_and_cash_equivalents;
                                appFinSumAsstNLiabObj.Other_current_assets__c=eachAssetObj.other_assets; //Doubt
                                appFinSumAsstNLiabObj.NetFixedAssets__c=eachAssetObj.net_fixed_assets;

                            }

                            if(eachFinObj.statement_of_assets_and_liabilities.liabilities !=null){
                                LlpCompreDtlsResponseWrapper.Liabilities eachLiabObj =eachFinObj.statement_of_assets_and_liabilities.liabilities;

                                //MAp App Fin Summary FIelds  like appFinSumAsstNLiabObj.

                                appFinSumAsstNLiabObj.ContributionRec__c=eachLiabObj.contribution_received;
                                appFinSumAsstNLiabObj.ReserveNSurplus__c=eachLiabObj.reserves_and_surplus;
                                appFinSumAsstNLiabObj.SecuredLoan__c=eachLiabObj.secured_loan;
                                appFinSumAsstNLiabObj.UnsecuredLoan__c=eachLiabObj.unsecured_loan;
                                appFinSumAsstNLiabObj.ShortTermBorrow__c=eachLiabObj.short_term_borrowing;
                                appFinSumAsstNLiabObj.TradePayables__c=eachLiabObj.trade_payables;
                                appFinSumAsstNLiabObj.OtherLiabilities__c=eachLiabObj.other_liabilities;
                                appFinSumAsstNLiabObj.ProviTaxation__c=eachLiabObj.provisions_for_taxation;
                                appFinSumAsstNLiabObj.ProviContingencies__c=eachLiabObj.provisions_for_contingencies;
                                appFinSumAsstNLiabObj.ProviInsurance__c=eachLiabObj.provisions_for_insurance;
                                appFinSumAsstNLiabObj.OtherProvisions__c=eachLiabObj.other_provisions;


                            }

                            //Make relationship b/n obj 
                            uow3.registerRelationship(appFinSumAsstNLiabObj, Applicant_Financial_Summary__c.Applicant_Financial__c, applFinObjAsstNLiab);  
						    uow3.registerNew(appFinSumAsstNLiabObj);

                        }

                        if(eachFinObj.statement_of_income_and_expenditure!=null){

                            Applicant_Financial__c applFinObjIncNExpObj =new Applicant_Financial__c();
                            applFinObjIncNExpObj.RecordTypeId = Schema.SObjectType.Applicant_Financial__c.getRecordTypeInfosByDeveloperName().get('Balance_Sheet').getRecordTypeId();
                            applFinObjIncNExpObj.Type__c ='Probe42';
                            
                            applFinObjIncNExpObj.Loan_Applicant__c = msg.RefId__c;
                            uow3.registerNew(applFinObjIncNExpObj);


                            Applicant_Financial_Summary__c appFinSumIncNExpLiItObj= new Applicant_Financial_Summary__c();


                            if(eachFinObj.statement_of_income_and_expenditure.lineItems !=null){

                                //map appFinSumIncNExpLiItObj. = here

                                LlpCompreDtlsResponseWrapper.LineItems eachLineItem = eachFinObj.statement_of_income_and_expenditure.lineItems;
                                appFinSumIncNExpLiItObj.NetRevenue__c=eachLineItem.net_revenue;
                                appFinSumIncNExpLiItObj.TotlOperatingCost__c = eachLineItem.operating_cost; //Doubt
                                appFinSumIncNExpLiItObj.TotCostMatConsumed__c = eachLineItem.total_cost_of_materials_consumed;
                                appFinSumIncNExpLiItObj.TotPurchStockInTrade__c = eachLineItem.total_purchases_of_stock_in_trade;
                                appFinSumIncNExpLiItObj.TotlChInventFinished__c = eachLineItem.total_changes_in_inventories_or_finished_goods;
                                appFinSumIncNExpLiItObj.TotlEmpBenefitExp__c = eachLineItem.total_employee_benefit_expense;
                                appFinSumIncNExpLiItObj.TotlOtherExp__c = eachLineItem.total_other_expenses;
                                appFinSumIncNExpLiItObj.OperatingProfit__c = eachLineItem.operating_profit;
                                appFinSumIncNExpLiItObj.OtherIncome__c = eachLineItem.other_income;
                                appFinSumIncNExpLiItObj.Depreciation__c = eachLineItem.depreciation;
                                appFinSumIncNExpLiItObj.ProfitBeforeIntAndTax__c = eachLineItem.profit_before_interest_and_tax;
                                appFinSumIncNExpLiItObj.ProfitLossInterest__c = eachLineItem.interest;
                                appFinSumIncNExpLiItObj.ProfitBefrTaxExItems__c = eachLineItem.profit_before_tax_and_exceptional_items_before_tax;
                                appFinSumIncNExpLiItObj.ExcepItemsBeforeTax__c = eachLineItem.exceptional_items_before_tax;
                                appFinSumIncNExpLiItObj.ProfitBeforeTax__c = eachLineItem.profit_before_tax;
                                appFinSumIncNExpLiItObj.IncomeTax__c = eachLineItem.income_tax;
                                appFinSumIncNExpLiItObj.ProfitPeriodFrContOperat__c = eachLineItem.profit_for_period_from_continuing_operations;
                                appFinSumIncNExpLiItObj.ProfitFromDiscontOpTax__c = eachLineItem.profit_from_discontinuing_operation_after_tax;
                                appFinSumIncNExpLiItObj.MinIntProfitFromAssoc__c = eachLineItem.minority_interest_and_profit_from_associates_and_joint_ventures;
                                appFinSumIncNExpLiItObj.ProfitAfterTax__c = eachLineItem.profit_after_tax;

                            }

                            if(eachFinObj.statement_of_income_and_expenditure.revenue_breakup !=null){
                                
                                LlpCompreDtlsResponseWrapper.Revenue_breakup eachRevBrkObj= eachFinObj.statement_of_income_and_expenditure.revenue_breakup ;
                                appFinSumIncNExpLiItObj.SaleGoodsManDom__c=eachRevBrkObj.sale_of_goods_manufactured_domestic;
                                appFinSumIncNExpLiItObj.SaleGoodsTrDomestic__c=eachRevBrkObj.sale_of_goods_traded_domestic;
                                appFinSumIncNExpLiItObj.SaleSupplyServDomestic__c=eachRevBrkObj.sale_or_supply_of_services_domestic;
                                appFinSumIncNExpLiItObj.SaleSupplyServExp__c=eachRevBrkObj.sale_or_supply_of_services_export;
                                appFinSumIncNExpLiItObj.SaleGoodsManExport__c=eachRevBrkObj.sale_of_goods_manufactured_export;
                                appFinSumIncNExpLiItObj.SaleGoodsTrExport__c=eachRevBrkObj.sale_of_goods_traded_export;
                                

                            }

                            //make creationship b/n obj 
                            uow3.registerRelationship(appFinSumIncNExpLiItObj, Applicant_Financial_Summary__c.Applicant_Financial__c, applFinObjIncNExpObj);  
						    uow3.registerNew(appFinSumIncNExpLiItObj);

                        }

                        
                    }
                    //For Loop Ends
                    
                }

                //Financial Details End    
                    if(resObj.data.open_charges!=null){
                            for(LlpCompreDtlsResponseWrapper.Open_charges eachOc : resObj.data.open_charges){
                                        
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
                    //Open_charges End

                        
                    if(resObj.data.open_charges_latest_event !=null){

                           for(LlpCompreDtlsResponseWrapper.Open_charges_latest_event eachOcLt : resObj.data.open_charges_latest_event){
                                
                            APIVerDtl__c apiVerDtOpChrslatst = new APIVerDtl__c();
                            apiVerDtOpChrslatst.Type__c='Open Charges Latest';
                            apiVerDtOpChrslatst.OpenchLatEventId__c=	String.valueOf(eachOcLt.id);                         
                            apiVerDtOpChrslatst.OpenchLatEvtDate__c=	setDateFormat(eachOcLt.date_Z);                       
                            apiVerDtOpChrslatst.OpchLatEvtHolderName__c=	eachOcLt.holder_name;                
                            apiVerDtOpChrslatst.OpChLatEvtAmount__c=	eachOcLt.amount;                    
                            apiVerDtOpChrslatst.OpChLatEvtType__c=	eachOcLt.type ;                      
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

                        }

                        //open_charges_latest_event 

                        if(resObj.data.charge_sequence!=null){

                            for(LlpCompreDtlsResponseWrapper.Charge_sequence eachChrSeq :resObj.data.charge_sequence){
                                APIVerDtl__c apiVerDtOpChrsSeq = new APIVerDtl__c();
                                apiVerDtOpChrsSeq.ChargeSeqId__c= String.valueOf(eachChrSeq.charge_id);
                                apiVerDtOpChrsSeq.Type__c='Charge Sequence';
                                apiVerDtOpChrsSeq.ChargeStatus__c=eachChrSeq.status;
                                apiVerDtOpChrsSeq.ChargeSeqDate__c=setDateFormat(eachChrSeq.date_Z);
                                apiVerDtOpChrsSeq.ChargeSeqFilDate__c=setDateFormat(eachChrSeq.filing_date);
                                apiVerDtOpChrsSeq.ChargeSeqAmt__c=eachChrSeq.amount;
                                apiVerDtOpChrsSeq.ChargeSeqHoldName__c=eachChrSeq.holder_name;
                                apiVerDtOpChrsSeq.ChargeSeqNoHolder__c=eachChrSeq.number_of_holder;
                                apiVerDtOpChrsSeq.ChargeSeqPropType__c=eachChrSeq.property_type;
                                apiVerDtOpChrsSeq.PropParticulars__c=eachChrSeq.property_particulars;

                                uow1.registerRelationship(apiVerDtOpChrsSeq, APIVerDtl__c.APIVerification__c, apiVerObj);  
                                uow1.registerNew(apiVerDtOpChrsSeq);  

                            }
                        }//Charge_sequence
                        
                    }
                    APICalloutTracker.update_ApiTrackerWithIntMsg(msg.Id,msg.Svc__c, msg.RefId__c, 'Success');

                    //Calling Report APIs
                    IntgMsg__c intmsg = new IntgMsg__c();
                    intmsg.Name='LLP Report';
                    intmsg.BU__c='HL / STL';
                    intmsg.Status__c='New';
                    intmsg.MStatus__c='Blank';
                    intmsg.RefObj__c='Applicant__c';
                    intmsg.Svc__c='LLP Report';
                    intmsg.ParentRefId__c=msg.ParentRefId__c;
                    intmsg.ParentRefObj__c=msg.ParentRefObj__c;
                    intmsg.RefId__c = msg.RefId__c; //appKyc[0].Applicant__c;
                    intmsg.IsActive__c=true;
                    //intmsg.Resp__c ='An Unique Identifier';
                    //intmsg.Trigger_Platform_Event__c = true;
                    createRequestList.add(intmsg); 


                    //Calling Document API
                    IntgMsg__c intmsg1 = new IntgMsg__c();
                    intmsg1.Name='LLP Incorporation Document';
                    intmsg1.BU__c='HL / STL';
                    intmsg1.Status__c='New';
                    intmsg1.MStatus__c='Blank';
                    intmsg1.Svc__c='LLP Incorporation Document';
                    intmsg1.RefObj__c='Applicant__c';
                    intmsg1.ParentRefId__c=msg.ParentRefId__c;
                    intmsg1.ParentRefObj__c=msg.ParentRefObj__c;
                    intmsg1.RefId__c = msg.RefId__c; //appKyc[0].Applicant__c;
                    intmsg1.IsActive__c=true;
                    //intmsg1.Resp__c ='An Unique Identifier';
                    //intmsg.Trigger_Platform_Event__c = true;
                    
                    createRequestList.add(intmsg1); 
                }

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


                //Commiting work
                uow1.commitWork();
                uow2.commitWork();    
                uow3.commitWork();
                
        }//API ver data insert End
        catch(Exception ex) {
            GlobalUtility.logMessage('Error', 'LlpCompreDtlsResponseProcessor',
                'processSuccess', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    
    }

    private static List<APIVer__c> getExistingApiVerRecords(Set<Id> applicantIds) {
        system.debug('making list true');
        return [SELECT Id, Appl__c, IsLatest__c, RecordType.Name,Type__c FROM APIVer__c WHERE Appl__c IN :applicantIds AND RecordType.DeveloperName = 'Probe42' AND IsLatest__c = true and Type__c ='Probe Comprehensive LLP']; //Type__c
    }

    public static Date setDateFormat(String datePass) 
    {
            if (datePass != null) {
                return Date.valueOf(datePass);
            }else{
                return null;
            } 
    }

    public static void processFailure(String messageRes,Map<IntgMsg__c,LlpCompreDtlsResponseWrapper> failureResp){
        
        try{
            
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> {APIVer__c.SObjectType});
            
            Set<Id> applicantIds =new Set<Id>();
            List<APIVer__c> appVerList=new List<APIVer__c>();
            
            Id recordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Probe42').getRecordTypeId();
            
            for(IntgMsg__c msg:failureResp.keyset()){
                
                if(string.isNotblank(msg.RefId__c)){
                    applicantIds.add(msg.RefId__c);
                }
            }
            
            //SOQL to check old records
            List<APIVer__c> apiVer =[Select id,Appl__c,IsLatest__c,RecordType.Name from APIVer__c Where Appl__c IN:applicantIds AND RecordType.DeveloperName='Probe42' AND IsLatest__c=true and Type__c ='Probe Comprehensive LLP'];
            
            if(!apiVer.isEmpty()){
                IntegrationUtility.updateBooleanFlag(apiVer,'IsLatest__c',false);
            }
            
            //Looping to update the records
            for(IntgMsg__c msg:failureResp.keyset()){
                
                if(failureResp.containsKey(msg) && String.isNotblank(msg.RefId__c)){
                    
                            APIVer__c apiveri =new APIVer__c();
                            apiveri.Appl__c=msg.RefId__c;
                            apiveri.LoanAplcn__c =msg.ParentRefId__c;
                            apiveri.IntegrationStatus__c='Failure';
                            apiveri.Type__c='Probe Comprehensive LLP';
                            apiveri.IntegrationErrorMessage__c=messageRes!=null ? messageRes :'';
                            apiveri.IsLatest__c=true;
                            apiveri.RecordTypeId=recordTypeId!=null?recordTypeId:'';
                            appVerList.add(apiveri);
                            APICalloutTracker.update_ApiTrackerWithIntMsg(msg.Id,msg.Svc__c, msg.RefId__c, 'Failure');
                    }
            }

            if(!appVerList.isEmpty()) {
                String sObjectName = 'APIVer__c';
                List<String> fieldNamesList = new List<String>{'Appl__c','LoanAplcn__c','Type__c','IntegrationStatus__c','IntegrationErrorMessage__c','IsLatest__c','RecordTypeId'};
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerNew(appVerList);
                uow.commitWork();
                
            }
        }catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'LlpCompreDtlsResponseProcessor', 
                                     'processFailure', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    

    }


}