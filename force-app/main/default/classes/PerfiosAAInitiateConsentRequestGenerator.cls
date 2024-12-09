public class PerfiosAAInitiateConsentRequestGenerator implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){
        try{
            if(!msgs.isempty()){
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Perfios_AA_Initiate_Consent');
                APIConfiguration__c config = APIConfiguration__c.getInstance('Perfios AA');
                
                Set<Id> refIds = new Set<Id>();
                List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>();
                List<Applicant__c> updateApplicantRecords = new List<Applicant__c>();
                
                for (IntgMsg__c intMsg : msgs) {
                    refIds.add(intMsg.RefId__c);
                }
                
                Map<Id,Applicant__c> applicantMap = new Map<Id,Applicant__c>([SELECT Id,LoanAppln__c,LoanAppln__r.ReqLoanAmt__c,LoanAppln__r.ReqTenInMonths__c,LoanAppln__r.ProductSubType__c,CustProfile__c,MobNumber__c,BankingMobNumber__c,isAlternateAggMob__c,IntegrationStatus__c,IntegrationErrorMessage__c FROM Applicant__c WHERE Id IN:refIds]);
                
                for(IntgMsg__c intmsg:msgs){
                    if(applicantMap.containsKey(intmsg.RefId__c)){
                        PerfiosAAInitiateConsentRequestWrapper request = new PerfiosAAInitiateConsentRequestWrapper();
                        request.userId = getUserId(svc.Username__c,(applicantMap.get(intmsg.RefId__c).isAlternateAggMob__c =='Y' && applicantMap.get(intmsg.RefId__c).BankingMobNumber__c!=null? applicantMap.get(intmsg.RefId__c).BankingMobNumber__c : applicantMap.get(intmsg.RefId__c).MobNumber__c));
                        request.profileId = svc.AggregatorID__c;
                        
                        request.fiTypes = svc.OperationFlag__c!=null? svc.OperationFlag__c.split(',') : new List<String>{};
                            
                        //request.fipIds = new List<String>();    
                        //request.accType = new List<String>{'CURRENT','SAVINGS',};
                            
                        request.txnId = intmsg.Integration_Message_Number__c + DateTime.now().getTime();
                        request.returnUrl = config!=null ? config.URL__c : '';
                        
                        PerfiosAAInitiateConsentRequestWrapper.Callback callback =  new PerfiosAAInitiateConsentRequestWrapper.Callback();
                        callback.includeTxnStatus = true;
                        request.callback = callback;
                        
                        List<PerfiosAAInitiateConsentRequestWrapper.PassThroughParams> params = new List<PerfiosAAInitiateConsentRequestWrapper.PassThroughParams>();
                        
                        PerfiosAAInitiateConsentRequestWrapper.PassThroughParams param = new PerfiosAAInitiateConsentRequestWrapper.PassThroughParams();
                        
                        PerfiosAAInitiateConsentRequestWrapper.Data data = new PerfiosAAInitiateConsentRequestWrapper.Data();
                        
                        //data.facility = 'NONE';
                        data.loanType = applicantMap.get(intmsg.RefId__c).LoanAppln__r.ProductSubType__c!=null ? applicantMap.get(intmsg.RefId__c).LoanAppln__r.ProductSubType__c : '';
                        data.loanAmount = applicantMap.get(intmsg.RefId__c).LoanAppln__r.ReqLoanAmt__c!=null ? String.valueOf(applicantMap.get(intmsg.RefId__c).LoanAppln__r.ReqLoanAmt__c.setScale(0, RoundingMode.HALF_UP)) : '';
                        //data.todAllowed = '';
                        //data.yearMonthTo = '';
                        //data.employerName = '';
                        data.loanDuration = applicantMap.get(intmsg.RefId__c).LoanAppln__r.ReqTenInMonths__c!=null ? String.valueOf(applicantMap.get(intmsg.RefId__c).LoanAppln__r.ReqTenInMonths__c.setScale(0)) : '';
                        //data.yearMonthFrom = '';
                        //data.processingType = svc.ProcessCode__c;
                        data.acceptancePolicy = 'atLeastOneTransactionInRange';
                        data.employmentType = (applicantMap.get(intmsg.RefId__c).CustProfile__c!=null && applicantMap.get(intmsg.RefId__c).CustProfile__c=='SALARIED') ? 'Salaried': 'SelfEmployed';
                        //data.uploadingScannedStatements = 'false';
                        
                        param.data = data;
                        param.target = svc.StaticKey__c!=null ? svc.StaticKey__c : '';// 'INSIGHTS'
                        params.add(param);
                        
                        request.passThroughParams = params;
                        
                        //request.startDate = '';
                        //request.endDate = '';
                        
                        //PerfiosAAInitiateConsentRequestWrapper.OptionalParams optionalParams = new PerfiosAAInitiateConsentRequestWrapper.OptionalParams();
                        //optionalParams.consentNotification = 'https://uat-api.fedfina.com/sandbox/dev/perfios/consent/notification';
                        //optionalParams.dataNotification = 'https://uat-api.fedfina.com/sandbox/dev/perfios/fetch/notification';
                        //optionalParams.reportNotification = 'https://uat-api.fedfina.com/sandbox/dev/perfios/report/notification';
                        
                        PerfiosAAInitiateConsentRequestWrapper.OptionalParams optionalParams = svc.CallbackURL__c!= null? (PerfiosAAInitiateConsentRequestWrapper.OptionalParams) JSON.deserialize(svc.CallbackURL__c, PerfiosAAInitiateConsentRequestWrapper.OptionalParams.class) : new PerfiosAAInitiateConsentRequestWrapper.OptionalParams(); 					
                        
                        request.optionalParams = optionalParams;
                        
                        //request.customerUniqueId = '';
                        
                        IntgMsg__c integrationMessage =new IntgMsg__c();
                        integrationMessage.Id=intmsg.Id;
                        integrationMessage.Req__c=JSON.serialize(request,true);
                        integrationMessage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                        updateIntRecords.add(integrationMessage);
                        
                        Applicant__c appl = new Applicant__c();
                        appl.Id = applicantMap.get(intmsg.RefId__c).Id;
                        appl.Perfios_AA_Status__c = 'Pending';
                        appl.IntegrationStatus__c = PerfiosAPIController.replaceAndUpdateString('Perfios AA', '', applicantMap.get(intmsg.RefId__c).IntegrationErrorMessage__c, ';');
                        appl.IntegrationErrorMessage__c = PerfiosAPIController.replaceAndUpdateString('Perfios AA', '', applicantMap.get(intmsg.RefId__c).IntegrationErrorMessage__c, ';');
                        updateApplicantRecords.add(appl);
                    }
                }
                
                if(!updateIntRecords.isEmpty()){
                    update updateIntRecords;
                }
                if(!updateApplicantRecords.isEmpty()){
                    update updateApplicantRecords;
                }
            }
        }
        catch(Exception ex){
            System.debug('error'+ex.getMessage());
            GlobalUtility.logMessage('Error', 'PerfiosAAInitiateConsentRequestGenerator' + ex.getLineNumber(), 
                                     'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
    public Static String getUserId(String usernameFormat, String MobileNumber){
        String UserId;
        if(usernameFormat!=null && mobileNumber!=null){
            userId = usernameFormat.replace('<<__MobileNumber__>>',mobileNumber);
        }
        return EncodingUtil.base64Encode(Blob.valueOf(userId)); 
    }
}