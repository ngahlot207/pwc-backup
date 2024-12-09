public class PerfiosGenerateLinkRequestGenerator implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){  
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType,ApplBanking__c.SObjectType,ContentVersion.SObjectType});
        
        try{
            if(!msgs.isempty()){
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Perfios_Generate_Link');
                List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>();
                List<ApplBanking__c> updateApplBankingList = new List<ApplBanking__c>();
                Set<Id> refIds = new Set<Id>();
                Set<Id> applIds = new Set<Id>();
                Map<Id, ApplBanking__c> applBankingMap = new Map<Id, ApplBanking__c>();
                Map<Id,ApplicantEmployment__c> applEmpMap = new Map<Id,ApplicantEmployment__c>();
                
                for (IntgMsg__c intMsg : msgs) {
                    refIds.add(intMsg.RefId__c);
                }
                
                for(ApplBanking__c app : [select Id,LoanAppl__c,LoanAppl__r.ReqLoanAmt__c,LoanAppl__r.ReqTenInMonths__c,LoanAppl__r.ProductSubType__c,Appl__c,Appl__r.CustProfile__c,Appl__r.TabName__c,FileType__c,AccountType__c,PeriodOfBankingStart__c,PeriodOfBankingEnd__c,IsThereChangeInLimitDuringThePeri__c, Limit__c,SisterCompanyName__c,SFDCBankMaster__c,SFDCBankMaster__r.InstitutionId__c,(Select Id,MonthlyLimit__c,Year__c,Month__c From Applicant_Banking_Detail__r ORDER BY Year__c,Month__c ) from ApplBanking__c where Id IN:refIds]){
                    applBankingMap.put(app.Id,app);
                    applIds.add(app.Appl__c);
                }
                
                if(!applIds.isEmpty()){
                    for(ApplicantEmployment__c appEmp : [Select id,LoanApplicant__c, LoanApplicant__r.Constitution__c, EmployerName__c, EmployerName__r.Name,Others__c from ApplicantEmployment__c]){
                        applEmpMap.put(appEmp.LoanApplicant__c,	appEmp);
                    }
                }
                
                for(IntgMsg__c intmsg:msgs){
                    if(applBankingMap.containskey(intmsg.RefId__c)){
                        ApplBanking__c applBanking = applBankingMap.get(intmsg.RefId__c);
                        
                        PerfiosGenerateLinkRequestWrapper request = new PerfiosGenerateLinkRequestWrapper();
                        List<PerfiosGenerateLinkRequestWrapper.EmployerNames> employerNames = new List<PerfiosGenerateLinkRequestWrapper.EmployerNames>();
                        List<PerfiosGenerateLinkRequestWrapper.VariableAmounts> variableAmounts = new List<PerfiosGenerateLinkRequestWrapper.VariableAmounts>();
                        //List<PerfiosInitiateRequestWrapper.VariableAmounts> sanctionLimitVariableAmounts = new List<PerfiosInitiateRequestWrapper.VariableAmounts>();
                        //List<PerfiosInitiateRequestWrapper.VariableAmounts> drawingPowerVariableAmounts = new List<PerfiosInitiateRequestWrapper.VariableAmounts>();
						List<PerfiosGenerateLinkRequestWrapper.CompanyNames> companyNames = new List<PerfiosGenerateLinkRequestWrapper.CompanyNames>();
						List<PerfiosGenerateLinkRequestWrapper.SisterCompanyNames> sisterCompanyNames = new List<PerfiosGenerateLinkRequestWrapper.SisterCompanyNames>();
                        
                        PerfiosGenerateLinkRequestWrapper.Payload payload = new PerfiosGenerateLinkRequestWrapper.Payload();
                        
                        payload.loanAmount = applBanking.LoanAppl__r.ReqLoanAmt__c!=null? String.valueOf(applBanking.LoanAppl__r.ReqLoanAmt__c.setScale(0, RoundingMode.HALF_UP)):'';	
                        payload.loanDuration = applBanking.LoanAppl__r.ReqTenInMonths__c!=null? String.valueOf(applBanking.LoanAppl__r.ReqTenInMonths__c.setScale(0)):'';	
                        payload.loanType = applBanking.LoanAppl__r.ProductSubType__c!=null? applBanking.LoanAppl__r.ProductSubType__c:'';
                        payload.processingType = svc.ProcessCode__c;
                        payload.transactionCompleteCallbackUrl = svc.CallbackURL__c;
                        payload.txnId = intmsg.Integration_Message_Number__c;
                        payload.employmentType = (applBanking.Appl__r.CustProfile__c!=null && applBanking.Appl__r.CustProfile__c=='SALARIED')? 'Salaried': 'SelfEmployed';
                        payload.facility = applBanking.AccountType__c!=null ? applBanking.AccountType__c =='CC' ? 'CC': applBanking.AccountType__c=='OVERDRAFT' ? 'OD':'NONE' : 'NONE';
                        
                        payload.sanctionLimitFixed = applBanking.IsThereChangeInLimitDuringThePeri__c=='No' ? 'true' : 'false';
                        //payload.drawingPowerFixed = applBanking.IsThereChangeInLimitDuringThePeri__c=='No' ? 'true' : 'false';
                        payload.sanctionLimitFixedAmount = (applBanking.IsThereChangeInLimitDuringThePeri__c=='No' && applBanking.Limit__c!=null) ? String.valueOf(applBanking.Limit__c) : '0';
                        //payload.drawingPowerFixedAmount = (applBanking.IsThereChangeInLimitDuringThePeri__c=='No' && applBanking.Limit__c!=null) ? String.valueOf(applBanking.Limit__c) : '0';
                        
                        
                        payload.productType = 'loan';//applBanking.LoanAppl__r.ProductSubType__c!=null? applBanking.LoanAppl__r.ProductSubType__c:'';
                        payload.sourceSystem = svc.SourceSystem__c;
                        payload.acceptancePolicy = 'atLeastOneTransactionInRange';
                        
                        payload.institutionId = applBanking.SFDCBankMaster__r.InstitutionId__c!=null ?applBanking.SFDCBankMaster__r.InstitutionId__c : null;
                        
                        payload.maxVintageDays = null;
                        //payload.yearMonthFrom = '';//(applBanking.PeriodOfBankingStart__c!=null && applBanking.PeriodOfBankingEnd__c!=null) ? String.valueOf(DateTime.newInstance(applBanking.PeriodOfBankingStart__c.year(), applBanking.PeriodOfBankingStart__c.month(), applBanking.PeriodOfBankingStart__c.day()).format('yyyy-MM'))  : ''; //String.valueOf(system.now().format('yyyy-MM'));
                        //payload.yearMonthTo= '';//(applBanking.PeriodOfBankingStart__c!=null && applBanking.PeriodOfBankingEnd__c!=null) ? String.valueOf(DateTime.newInstance(applBanking.PeriodOfBankingEnd__c.year(), applBanking.PeriodOfBankingEnd__c.month(), applBanking.PeriodOfBankingEnd__c.day()).format('yyyy-MM'))  : ''; //String.valueOf(system.now().format('yyyy-MM'));
                        
                        payload.yearMonthFrom = String.valueOf(DateTime.newInstance(System.now().addYears(-1).year(), System.now().addYears(-1).month(), System.now().addYears(-1).day()).format('yyyy-MM'));
                        payload.yearMonthTo=  String.valueOf(DateTime.newInstance(System.now().year(), System.now().month(), System.now().day()).format('yyyy-MM')); 
                        
                        /*PerfiosGenerateLinkRequestWrapper.DataSources dataSources = new PerfiosGenerateLinkRequestWrapper.DataSources();
                        List<String> dataSource = new List<String>{'STATEMENT'};
                        dataSources.dataSource = dataSource;
                        
                        payload.dataSources = dataSources;*/
                        
                        
                        
                        
                        if(applBanking.Appl__r.CustProfile__c!=null && applBanking.Appl__r.CustProfile__c=='SALARIED' && applEmpMap.containsKey(applBanking.Appl__c)){
                            
                            if(String.isNotBlank(applEmpMap.get(applBanking.Appl__c).EmployerName__r.Name)){
                                //PerfiosGenerateLinkRequestWrapper.EmployerNames employerName = new PerfiosGenerateLinkRequestWrapper.EmployerNames();
                                //PerfiosGenerateLinkRequestWrapper.NamePattern namePattern = new PerfiosGenerateLinkRequestWrapper.NamePattern();
                                if(applEmpMap.get(applBanking.Appl__c).EmployerName__r.Name!='OTHER'){
                                    //namePattern.pattern = applEmpMap.get(applBanking.Appl__c).EmployerName__r.Name;
                                    //employerName.namePattern = namePattern;
                                    //employerNames.add(employerName);
                                    payload.employerName = applEmpMap.get(applBanking.Appl__c).EmployerName__r.Name;
                                }
                                else if(String.isNotBlank(applEmpMap.get(applBanking.Appl__c).Others__c)){
                                    //namePattern.pattern = applEmpMap.get(applBanking.Appl__c).Others__c;
                                    //employerName.namePattern = namePattern;
                                    //employerNames.add(employerName);
                                    payload.employerName = applEmpMap.get(applBanking.Appl__c).Others__c;
                                }
                            }
                        }
                        //payload.employerNames = employerNames;
                        
                        if(applBanking.IsThereChangeInLimitDuringThePeri__c=='Yes'){
                            List<ApplBankDetail__c> applBankDetailList = applBanking.Applicant_Banking_Detail__r;
                            if(!applBankDetailList.isEmpty() && applBanking.PeriodOfBankingStart__c!=null){
                                for(ApplBankDetail__c appBank: applBankDetailList){
                                    if(appBank.Year__c!=null && appBank.Month__c!=null){
                                        Date dt = Date.newInstance(Integer.valueOf(appBank.Year__c), monthMap.get(appBank.Month__c),  1);
                                        if(dt>=applBanking.PeriodOfBankingStart__c.toStartOfMonth() && dt<=applBanking.PeriodOfBankingEnd__c.toStartOfMonth()){
                                            PerfiosGenerateLinkRequestWrapper.VariableAmounts variableAmount = new PerfiosGenerateLinkRequestWrapper.VariableAmounts();
                                            PerfiosGenerateLinkRequestWrapper.VariableAmount amount = new PerfiosGenerateLinkRequestWrapper.VariableAmount();
                                            amount.amount = appBank.MonthlyLimit__c!=null ? String.valueOf(appBank.MonthlyLimit__c) : '0';
                                            variableAmount.variableAmount = amount;
                                            variableAmounts.add(variableAmount);
                                        }
                                    }
                                }
                            }
                        }
                        
                        for(Integer i = 0 ; i<12; i++){
                            PerfiosGenerateLinkRequestWrapper.VariableAmounts variableAmount = new PerfiosGenerateLinkRequestWrapper.VariableAmounts();
                            PerfiosGenerateLinkRequestWrapper.VariableAmount amount = new PerfiosGenerateLinkRequestWrapper.VariableAmount();
                            amount.amount = applBanking.Limit__c!=null ? String.valueOf(applBanking.Limit__c) : '0';
                            variableAmount.variableAmount = amount;
                            variableAmounts.add(variableAmount);
                        }
                        
                        payload.sanctionLimitVariableAmounts = new List<PerfiosGenerateLinkRequestWrapper.VariableAmounts>();
                        payload.drawingPowerVariableAmounts = variableAmounts;
                        
                        if(String.isNotBlank(applBanking.Appl__r.TabName__c)){
                            PerfiosGenerateLinkRequestWrapper.CompanyNames companyName = new PerfiosGenerateLinkRequestWrapper.CompanyNames();
                            PerfiosGenerateLinkRequestWrapper.NamePattern namePattern = new PerfiosGenerateLinkRequestWrapper.NamePattern();
                            namePattern.pattern = applBanking.Appl__r.TabName__c;
                            companyName.namePattern = namePattern;
							companyNames.add(companyName);                             
                        }
                        payload.companyNames = companyNames;
                        
                        if(String.isNotBlank(applBanking.SisterCompanyName__c)){
                            PerfiosGenerateLinkRequestWrapper.SisterCompanyNames sisterCompanyName = new PerfiosGenerateLinkRequestWrapper.SisterCompanyNames();
                            PerfiosGenerateLinkRequestWrapper.NamePattern namePattern = new PerfiosGenerateLinkRequestWrapper.NamePattern();
                            namePattern.pattern = applBanking.SisterCompanyName__c;
                            sisterCompanyName.namePattern = namePattern;
							sisterCompanyNames.add(sisterCompanyName);                            
                        }
                        payload.sisterCompanyNames = sisterCompanyNames;
                        
                        request.payload = payload;
                        
                        
                        String method ='POST';
                        String requestDate= String.valueOf(system.now().format('yyyyMMdd\'T\'HHmmss\'Z\''));
                        String url = svc.URL__c;
                        
                        String requestpayload = JSON.serialize(request);
                        string signature = PerfiosAPIController.generateSignature(method,URL,'',requestpayload, requestDate);
                        
                        
                        PerfiosAPIController.RequestWrapper perfioRequest = new PerfiosAPIController.RequestWrapper();
                        perfioRequest.Payload=request;
                        PerfiosAPIController.Header header = new PerfiosAPIController.Header();
                        header.perfioRequestDate = requestDate;
                        header.perfiosAlgorithm = svc.AlgorithmName__c;
                        header.sha256Content = PerfiosAPIController.getSHA256Content(requestpayload);
                        header.perfioSignature = signature;
                        header.perfiosSignedHeaders = svc.SignedHeaders__c;
                        perfioRequest.Header = header;
                        
                        IntgMsg__c integrationMessage =new IntgMsg__c();
                        integrationMessage.Id=intmsg.Id;
                        integrationMessage.Req__c=JSON.serialize(perfioRequest);
                        integrationMessage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                        updateIntRecords.add(integrationMessage);
                        
                        
                        ApplBanking__c applBank = new ApplBanking__c();
                        applBank.Id = applBankingMap.get(intmsg.RefId__c).Id;
                        applBank.Initiate_Perfios_Status__c ='Pending';
                        updateApplBankingList.add(applBank);
                    }
                    
                }
                if(!updateIntRecords.isEmpty()) {
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Req__c','Status__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntRecords);
                }
                if(!updateApplBankingList.isEmpty()){
                    String sObjectName = 'ApplBanking__c';
                    List<String> fieldNamesList = new List<String>{'Initiate_Perfios_Status__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateApplBankingList);
                }
                uow.commitWork();
            }
            
            
        }
        //Catch bloack to catch Exceptions occured during generation of payload and displaying the passing the same in GlobalUtility class
        catch(Exception ex){
            System.debug('error'+ex.getMessage());
            GlobalUtility.logMessage('Error', 'PerfiosInitiateRequestGenerator' + ex.getLineNumber(), 
                                     'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
    public static final Map<String,Integer> monthMap = new Map<String,Integer>{'JAN'=>01,'FEB'=>02,'MAR'=>03,'APR'=>04,'MAY'=>05,'JUN'=>06,'JUL'=>07,'AUG'=>08,'SEP'=>09,'OCT'=>10,'NOV'=>11,'DEC'=>12};             
    public class PerfiosGenerateLinkRequestException extends Exception {
        
    }
}