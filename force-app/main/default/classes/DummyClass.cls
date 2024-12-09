public class DummyClass implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){ 
        
       /* fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { IntgMsg__c.SObjectType });
        
        //List<Id> appIds = new List<Id>();
        Set<Id> appIds = new Set<Id>();
        List<Id> loanApplnIds = new List<Id>();
        Set<Id> uniqueRefIds = new Set<Id>();
        Map<Id,List<Applicant__c>> loanAppMap = new Map<Id,List<Applicant__c>>();
        Map<Id, LoanAppl__c> loanAppRecordsMap = new Map<Id, LoanAppl__c>();
        
        //Ucid Of Primary Applicant
        String ucidPriApp ='';
        
        String emiLoan='';
        ID priAppId=null;
        List<ApplGST__c> gstList=new List<ApplGST__c>();
        
        //Set for Different city and Locality
        Set<String> citySet =new Set<String>();
        Set<String> bankSet =new Set<String>();
        Set<String> micrBrnchSet =new Set<String>();
        Set<String> industryVal = new Set<String>();
        Set<Id> repayId =new set<Id>();
        
        //To get GST Details
        ApplGST__c finalGstObj = null;
        //To get Master data from Name
        Map<String,LocMstr__c> mapLocMas =new Map<String,LocMstr__c>();
        Map<String,BankMstr__c> bankMstrMap =new Map<String,BankMstr__c>();
        Map<String,MICRCodeMstr__c> micrMstrMap =new Map<String,MICRCodeMstr__c>();
        Map<String,Industry__c> industryNameMap =new Map<String,Industry__c>();
        
        
        //Creating Maps for storing Loan Application child Records
        Map<Id,List<ApplAsset__c>> appAssetMapByLoanApp = new Map<Id,List<ApplAsset__c>>();
        Map<Id,List<Ref__c>> appRefMapByLoanApp = new Map<Id,List<Ref__c>>();
        Map<Id,List<LonaApplCharges__c>> appLoanChargesMapByLoanApp =new Map<Id,List<LonaApplCharges__c>>();
        Map<Id,List<BureauRespDtl__c>> appBureauMapByLoanApp =new Map<Id,List<BureauRespDtl__c>>();
        Map<Id,List<ApplIMD__c>> appImdByLoanApp=new Map<Id,List<ApplIMD__c>>();
        Map<Id,List<BRE__c>> appBreResByLoanApp =new Map<Id,List<BRE__c>>();
        Map<Id,List<Insurance__c>> appInsuranceByLoanApp =new Map<Id,List<Insurance__c>>();
        
        
        //Creating Maps for storing Applicant child Records        
        Map<Id,List<Applicant_Income__c>> appIncomeMap = new Map<Id,List<Applicant_Income__c>>();
        Map<Id,List<ApplAddr__c>> appAddMap = new Map<Id,List<ApplAddr__c>>();
        Map<Id,List<ApplAsset__c>> appAssetMap = new Map<Id,List<ApplAsset__c>>();
        Map<Id,List<ApplicantEmployment__c>> appEmpMap = new Map<Id,List<ApplicantEmployment__c>>();
        Map<Id,List<ApplGST__c>> appGstMap = new Map<Id,List<ApplGST__c>>(); 
        Map<Id,List<DocDtl__c>> docDetailMap = new Map<Id,List<DocDtl__c>>();
        Map<Id,List<ApplBanking__c>> appBankingMap = new Map<Id,List<ApplBanking__c>>();
        Map<Id,List<DocDtl__c>> applyDocDtlsMap = new Map<Id,List<DocDtl__c>>();
        Map<Id,List<ApplKyc__c>> appKycsMap = new Map<Id,List<ApplKyc__c>>();
        //Map<Id,List<BRE__c>> appBreResMap =new Map<Id,List<BRE__c>>(); Not needed
        
        
        //Maps for getting values based on User Input
        final Map<String,String> mapFtMode =new Map<String,String>{'PREPAID CARD'=>'PC','RTGS'=>'RT','NEFT'=>'NT','INTERNAL TRANSFER'=>'IT','ONLINE TRANSFER'=>'OT','IMPS'=>'IM'};
            final Map <String,String> mapDocStatus =new Map <String,String>{'OTC'=>'D','PDD'=>'P','Waiver'=>'W','Received'=>'C','PENDING'=>'P'};//Completed no info about completed code
                final Map<Integer, String> monthMap = new Map<Integer, String>{1=>'Jan', 2=>'Feb', 3=>'Mar', 4=>'Apr', 5=>'May', 6=>'Jun', 7=>'Jul', 8=>'Aug', 9=>'Sep', 10=>'Oct', 11=>'Nov',12=>'Dec'};
                    final Set<String> typeFilters=new Set<String>{'Channel','Religion','Address Type','Customer Profile','Category','Applicant Type','Ownership Type','Customer','Education Qualification','Nationality','Disburse To','Constitution','Payment Mode','Instrument Type','Customer Profile Selection'};
                        final Map<String,Integer> mapFirstEmiDueMon=new Map<String,Integer> {'January'=>1,'February'=>2,'March'=>3,'April'=>4,'May'=>5,'June'=>6,'July'=>7,'August'=>8,'September'=>9,'October'=>10,'November'=>11,'December'=>12};
                            
                            for(IntgMsg__c intMsg : msgs){ 
                                loanApplnIds.add(intMsg.RefId__c);
                            }
        
        if(!loanApplnIds.isEmpty())
        {
            for(LoanAppl__c app : [SELECT ID,Total_PF_Amount__c,RefEmpCode__c,Applicant__r.Id,ChanelNme__r.DSAConnId__c,ChanelNme__r.VCReferralId__c,BrchName__c,RemPFDeductFromDisbursementAmount__c,FinnoneAppid__c,FirstEMIDueMonth__c,SchemeId__c,ChannelCode__c,RMSMEmployeeID__c,PromCode__c,LoanPurpose__c,BrchCode__c,Product__c,SchmCode__c,Name,CreatedDate,LeadSource__c ,ReqLoanAmt__c,LoanPLRType__c,Repayment_Frequency__c,TotalLoanAmtInclInsurance__c,DisbursedAmount__c,LoanPLRRate__c,AddIntSchedule__c,Rate_Type_Floating_Flag__c,EffectiveROI__c,MoratGraceApplicable__c,DisbursalType__c,DueDay__c,FirstEMIDate__c,Installment_Plan__c,FirstEMIDueYear__c,ImpactOnTenure__c,SpreadID__c,ChargeInterest__c,Loan_Tenure_Months__c,(select Id ,name,Actual_FOIR__c from BRE_Responses__r)  , (Select id,name,SumAmount__c,PremiumAmount__c,InsProvider__r.Name,InsProvider__r.MPno__c from Insurances__r) ,(select ID,Amount__c,Name, ChargeCodeID__c,ChargeCodeDesc__c from Loan_Application_Charges__r) ,(SELECT id,City__c,PaymentMode__c,MICRCode__c,BankBrch__c,BankAccountNo__c,IMDAmt__c from Applicant_IMD__r), (SELECT id,RecordType.name,LoanApplication__c,Applicant__c,ConsiderObligation__c,NatureOfLoan__c,LoanName__c,Source__c,EMI__c,CloseDate__c,LoanAmount__c,FinancierName__c,TenureLeft__c,NoEMIPaid__c,CurrentOs__c from BureauRespDtl__r where RecordType.name= 'Consumer Obligation') ,(SELECT Id,Name,LoanAppln__c,ProfQual__c,LoanAppln__r.Name,LoanAppln__r.BrchName__c,Constitution__c,MobNumber__c,LName__c,DOB__c,FName__c,Age__c,MName__c,Gender__c,PassNo__c,PAN__c,KeyManName__c,FullName__c,MariStatus__c,SpName__c,MthrMdnName__c,YearOfRegistration__c,DLNo__c,VotIdEpicNo__c,EduQual__c,CompanyName__c,Relationship__c,Nationality__c,CustProfile__c,Title__c,UCID__c,DOI__c,ApplType__c,AadhaarNo__c,Religion__c,Father_Name__c,EmailId__c,Category__c  FROM Applicants__r),(SELECT Id,Applicant__r.MobNumber__c,RelationWthApp__c,RelationshipWthApp__c,FName__c,Add__c from References__r) ,(select Id,Resi_Age__c,PropSubType__c,Landmark__c,Property_Carpet_area_Sq_Ft__c,AddrLn1__c,AddrLn2__c,Approx_Age_of_Prop__c,Prop_Owners__c,Land_Area__c,State__c,FlatNo__c,Is_it_an_APF__c,PropType__c,Builder_ID__c,Pin_Code__c,Total_Prop_Cost__c,LoanAppln__r.TotalLoanAmtInclInsurance__c,City__c,Property_Usage__c,name,PropSubTypeDesc__c  FROM Applicant_Assets__r) FROM LoanAppl__c WHERE Id IN:loanApplnIds]){
                loanAppMap.put(app.Id,app.Applicants__r);
                loanAppRecordsMap.put(app.Id,app);   
                appAssetMapByLoanApp.put(app.id,app.Applicant_Assets__r); 
                appRefMapByLoanApp.put(app.id,app.References__r);   
                appLoanChargesMapByLoanApp.put(app.id,app.Loan_Application_Charges__r);                      
                appBureauMapByLoanApp.put(app.id,app.BureauRespDtl__r);
                appImdByLoanApp.put(app.id,app.Applicant_IMD__r);
                appBreResByLoanApp.put(app.id,app.BRE_Responses__r);
                appInsuranceByLoanApp.put(app.id,app.Insurances__r);
                
                if(app.BrchName__c !=null){
                    citySet.add(String.valueOf(app.BrchName__c).toUpperCase()); 
                }    
                
                //if(app.Applicants__r!=null && !app.Applicants__r.isEmpty()){
//for(Applicant__c appObjFromList :app.Applicants__r){
//appIds.add(appObjFromList.Id);
//}
//}
                appIds.addAll(app.Applicants__r != null && !app.Applicants__r.isEmpty() ? new Map<Id, Applicant__c>(app.Applicants__r).keySet() : new Set<Id>());
            }
        }
        
        
        
        
        if(!appIds.isEmpty())
        {
            for(Applicant__c app : [SELECT ID,(Select Id,Agricultural_Income_Year__c,Agricultural_Yearly_Income__c, Salary__c, Net_Salary__c, Month3_Rental_Credited_Amount__c, Month2_Rental_Credited_Amount__c, Month1_Rental_Credited_Amount__c, 
                                               Monthly_Pension_Credited__c, Applicant__c, RecordType.DeveloperName FROM Applicant_Income__r where Applicant__c!=null AND RecordTypeId !=null) , (Select id,name,PassExpDt__c,kycDoc__c from Applicant_KYC__r where kycDoc__c ='Passport'),(Select Id,Applicant__c,MailAddr__c,Country__c,OwnType__c,AddrStability__c,AddrTyp__c,City__c,State__c,AddrLine1__c,AddrLine2__c,Landmark__c,Pincode__c,Locality__c FROM Applicant_Addresses__r),(Select Id,Name,Prop_Owners__c,City__c FROM Applicant_Assets__r),(Select Id,TypeOfOrganisation__c,DesignationValues__c,WorkingWithCurrentEmployer_Years__c,EmployerName__c,TotalWorkExperience_Months__c,SubIndustry__r.Industry__r.IndustryID__c,SubIndustry__r.Name,SubIndustry__r.SubIndustryID__c,CurrentBusinessVintage_Months__c,NatureOfBusinessIndividual__c,IndustryType__r.Name,EmployerName__r.Name,NatureOfBusinessCorporate__c ,GST_Registered__c from Applicant_Employments__r),(select Id,GSTIN__c,RegisteredAddress_GST__c,Main_GSTIN__c from Applicant_GST__r),(SELECT id,AC_No__c,AccountType__c,TotalOutwardReturnCount__c,TotalInwardReturnCount__c,Bank_Branch__c,BankName__c,Bank_City__c from Applicant_Banking1__r),(select id,Name,LAN__c,OSV__c,DocStatus__c,TargetDt__c,ReceivedDt__c,DocMstr__r.DocId__c,DocMstr__r.DocType__c from Applicant_Document_Details__r) FROM Applicant__c WHERE Id IN:appIds])
            {
                appIncomeMap.put(app.Id,app.Applicant_Income__r);  
                //appAddMap.put(app.Id,app.Applicant_Addresses__r);
                appAssetMap.put(app.Id,app.Applicant_Assets__r);
                //appEmpMap.put(app.Id,app.Applicant_Employments__r);
                appGstMap.put(app.Id,app.Applicant_GST__r);
                appBankingMap.put(app.Id,app.Applicant_Banking1__r);
                applyDocDtlsMap.put(app.Id,app.Applicant_Document_Details__r);
                appKycsMap.put(app.Id,app.Applicant_KYC__r);
                //appBreResMap.put(app.Id,app.BRE_Responses__r);
                
                
                // Modifying the below logic Pratap
                // Checking if for an applicant the Employment details are present or not then add it to the map
                
                //if(!app.Applicant_Employments__r.isEmpty()){
//for(ApplicantEmployment__c appEmployment: app.Applicant_Employments__r)
//{
//if(appEmployment.IndustryType__r.name !=null){
//industryVal.add(appEmployment.IndustryType__r.name);
//}
//}
//}
                
                if(!app.Applicant_Employments__r.isEmpty()){
                    appEmpMap.put(app.Id,app.Applicant_Employments__r);
                }
                
                
                if(!app.Applicant_Addresses__r.isEmpty()){
                    appAddMap.put(app.Id,app.Applicant_Addresses__r);                                       
                }
                
                
                if(!app.Applicant_Assets__r.isEmpty()){                    
                    for(ApplAsset__c appAsset: app.Applicant_Assets__r)
                    {
                        if(appAsset.City__c !=null)
                        {
                            
                            citySet.add(String.valueOf(appAsset.City__c).toUpperCase());
                        }    
                    }
                }
                
                if(!app.Applicant_Banking1__r.isEmpty()){                    
                    for(ApplBanking__c appbankObj: app.Applicant_Banking1__r)
                    {
                        if(appbankObj.BankName__c !=null)
                        {
                            bankSet.add(appbankObj.BankName__c);
                        }                          
                        //adding branch name in Set
                        if(appbankObj.Bank_Branch__c !=null){
                            micrBrnchSet.add(appbankObj.Bank_Branch__c); 
                        }
                        if(appbankObj.Bank_City__c !=null){
                            
                            citySet.add(String.valueOf(appbankObj.Bank_City__c).toUpperCase());
                        }
                        
                    }
                }
                
            }
        }
        
        // Logic added to iterate over the emp Map and then extract the needed details
        
        List<ApplicantEmployment__c> allApplicantEmployments = new List<ApplicantEmployment__c>();
        if(!appEmpMap.values().isEmpty()){
            for (List<ApplicantEmployment__c> appEr : appEmpMap.values())
            {
                allApplicantEmployments.addAll(appEr);
            }
        }
        for(ApplicantEmployment__c acl :allApplicantEmployments){
            industryVal.add(acl.IndustryType__r.name);
        }
        
        
        
        List<ApplAddr__c> allApplicantAddress = new List<ApplAddr__c>();
        if(!appAddMap.values().isEmpty()){
            for (List<ApplAddr__c> appAddres : appAddMap.values())
            {
                allApplicantAddress.addAll(appAddres);
            }
        }
        
        for(ApplAddr__c adrl :allApplicantAddress){
            if(adrl.City__c !=null){
                citySet.add(String.valueOf(adrl.City__c).toUpperCase());
            }
            if(adrl.Locality__c !=null)
            {
                citySet.add(String.valueOf(adrl.Locality__c).toUpperCase());
            } 
        }
        
        
        
        
        
        
        
        
        
        if(loanApplnIds != null && loanApplnIds.size() >0)
        {
            for(ID eachLoanAppId: loanApplnIds)
            {     
                if(loanAppMap.get(eachLoanAppId)!=null && !loanAppMap.get(eachLoanAppId).isEmpty()){
                    
                    for(Applicant__c eachApp:loanAppMap.get(eachLoanAppId))
                    {
                        if(eachApp.ApplType__c =='P')
                        {
                            ucidPriApp=eachApp.UCID__c != null ? eachApp.UCID__c :'';
                            
                            priAppId=eachApp.ID;
                            
                            if(!appGstMap.isEmpty())
                            {
                                if(appGstMap.containsKey(eachApp.Id)){
                                    gstList=appGstMap.get(eachApp.Id);  //
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                //else if(loanAppMap.get(eachLoanAppId).size() == 1)
//{

//Applicant__c appLi =loanAppMap.get(eachLoanAppId)[0];

//if(!appGstMap.isEmpty())
//{
//if(appGstMap.containsKey(appLi.Id)){
//gstList=appGstMap.get(appLi.Id);

//}

//}

//}
                
            }
        }
        
        
        System.debug('priAppId::'+priAppId);
        List<Industry__c> liInd= [Select Id,name,IndustryID__c from Industry__c where name IN : industryVal];
        
        if(liInd!=null && !liInd.isEmpty()){
            for(Industry__c industryName : liInd){
                
                industryNameMap.put(industryName.Name ,industryName);
                
            }
        }
        
        System.debug('UcidPriApp::'+ucidPriApp);
        
        
        //Query Optimized
        List<BRE__c> listBre=[select Id,EMI__c from BRE__c where IsLatest__c =true AND EligibilityType__c = 'Application' AND LoanAppl__c IN: loanApplnIds];
        
        
        if(listBre !=null && !listBre.isEmpty())
        {
            emiLoan= String.valueOf(listBre[0].EMI__c);
        }
        
        for(ApplGST__c gstsObj : gstList)
        {
            if(gstsObj.Main_GSTIN__c == true)
            {
                finalGstObj =gstsObj;
            }
            
        }
        System.debug('emiLoan::'+emiLoan);
        System.debug('finalGstObj::'+finalGstObj);
        
        List<Repayment_Account__c> listRepayAccounts = [Select Id,Account_Number__c,MICR_Code__c,Applicant_Banking__r.Appl__r.ApplType__c,Bank_Branch__c,Bank_Name__c,Applicant_Banking__r.Bank_City__c,Applicant_Banking__r.AccountType__c,Deactivate_Date__c,Applicant_Banking__r.Bank_Code__c,IFSC_Code__c,Repayment_Mode__c from Repayment_Account__c where Is_Active__c =true  AND Loan_Application__c  IN : loanApplnIds ];
        
        for(Repayment_Account__c eachRepayAc : listRepayAccounts)
        {
            if(!String.isBlank(eachRepayAc.Applicant_Banking__r.Bank_City__c)){
                System.debug('String.valueOf(eachRepayAc.Applicant_Banking__r.Bank_City__c).toUpperCase():'+String.valueOf(eachRepayAc.Applicant_Banking__r.Bank_City__c).toUpperCase());
                citySet.add(String.valueOf(eachRepayAc.Applicant_Banking__r.Bank_City__c).toUpperCase());
            }
            
            
            repayId.add(eachRepayAc.Id);
            
        }
        
        List<Disbursement__c> listDisbNSplitDis =[select id,Date_of_Disbur__c,Princ_Start_Date__c,Princ_Rec_on__c,(select Id,Effec_Date__c,IFSC_Detail__c,Split_Cheque_Amt__c,Fedbank_Acc_No__c,Custo_Name__c,Cheq_Favor_Acc_No__c,Remarks__c,Cheq_DD_Date__c,Disbur_To__c,Cheq_Favor_Dets__c,Payable_At__c,Fund_Transf_Mode__c,Pay_Mode__c,Date_of_Disbur__c,Cheq_DD_No__c from Split_Disbursements__r) from Disbursement__c where Loan_Appli__c IN: loanApplnIds ];
        
        for(Disbursement__c disB : listDisbNSplitDis ){
            for(Split_Disbur__c spDisb :disB.Split_Disbursements__r){
                if(spDisb.Payable_At__c !=null){
                    
                    citySet.add(String.valueOf(spDisb.Payable_At__c).toUpperCase()); 
                }
                
            }
        }
        
        //Utility Lists
        List<LoanPurpose__c> listLoanPurpose =[Select ID,Value__c from LoanPurpose__c where Name =: loanAppRecordsMap.get(loanApplnIds[0]).LoanPurpose__c];
        List<BankBrchMstr__c> listBrnchCode =[Select Id,OffcCode__c from BankBrchMstr__c where BrchCode__c=: loanAppRecordsMap.get(loanApplnIds[0]).BrchCode__c];
        List<SchMapping__c> listScheme=[select id,SchmId__c,ProductType__c from SchMapping__c where Id =: loanAppRecordsMap.get(loanApplnIds[0]).SchemeId__c];
        
        
        System.debug('citySet::::'+citySet);
        System.debug('bankSet::::'+bankSet);
        System.debug('micrBrnchSet::::'+micrBrnchSet);
        
        //List<PDC__c> liPdc =[Select Id,Name,Repayment_Account__r.Applicant_Banking__r.PDC_by_Name__c from PDC__c where Repayment_Account__r.Id IN: repayId ];
        
        System.debug('priAppId for PDC__C'+priAppId);
        List<PDC__c> liPdc =[Select Id,Name,Repayment_Account__r.Applicant_Banking__r.PDC_by_Name__c from PDC__c where Loan_Application__r.Applicant__c =: priAppId];
        
        System.debug('liPdc::'+liPdc);
        
        //Master Related Data fetch
        List<LocMstr__c> liLocMaster =[select ID,State__c,StateId__c ,City__c, CityId__c from LocMstr__c where City__c IN : citySet]; // where City__c IN : citySet ];//applied city in where condition
        List<BankMstr__c> liBankMast =[Select Id,name,BankId__c, BankCode__c from BankMstr__c where name in : bankSet]; //where name in : bankSet]; //where take all bank Ids 
        List<MICRCodeMstr__c> liMicrMast =[Select Id,name , BanckBrchId__c, Bank__c, BrchName__c, City__c  from MICRCodeMstr__c where BrchName__c IN : micrBrnchSet];
        
        for(BankMstr__c bankObj : liBankMast){
            bankMstrMap.put(bankObj.name ,bankObj);
        }
        
        for(LocMstr__c eachLocMas :liLocMaster){
            mapLocMas.put(eachLocMas.City__c ,eachLocMas);
        }
        
        for(MICRCodeMstr__c micrObj:liMicrMast){
            
            micrMstrMap.put(micrObj.BrchName__c,micrObj);
        }
        //for getting Master related data
        Set<String> masterDataSet=new Set<String>();
        
        Map<String,Map<String,String>> masterDataMap= new Map<String,Map<String,String>> ();
        for(MasterData__c masterObj : [Select id,name,Type__c,FinnoneVal__c,SalesforceCode__c,FinnoneCode__c from MasterData__c Where Type__c IN:typeFilters])
        {
            Map<String,String> tempMap = new Map<String,String>();
            if(masterDataMap.containsKey(masterObj.Type__c))
            {
                tempMap = masterDataMap.get(masterObj.Type__c);
                tempMap.put(masterObj.Name,masterObj.FinnoneCode__c);
                masterDataMap.put(masterObj.Type__C, tempMap);
            }else
            {
                tempMap.put(masterObj.Name,masterObj.FinnoneCode__c);
                masterDataMap.put(masterObj.Type__C, tempMap);
            }
        }
        
        LoanAppl__c loanAppPromo= loanAppRecordsMap.get(loanApplnIds[0]);
        String promDescVal= loanAppPromo !=null ? loanAppPromo.PromCode__c :'';
        String prodTypeVal=loanAppPromo !=null ? loanAppPromo.Product__c :'';
        
        List<PromoMapping__c> listPromotion=[Select Id,name,PromoDesc__c, PromoId__c,ProductType__c from PromoMapping__c where PromoDesc__c =:promDescVal and 
                                             ProductType__c =:prodTypeVal];
        System.debug('listPromotion:: '+listPromotion);
        System.debug('listPromotion size::'+listPromotion.size());
        
        
        
        
        try
        {
            
            
            
            List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>(); 
            if(!msgs.isEmpty()){
                //SplitDisbursalDetails start
                List<LoanBoardingRequestWrapper.SplitDisbursalDetails> listSplitDis=new List<LoanBoardingRequestWrapper.SplitDisbursalDetails>();
                for(Disbursement__c eachDisb : listDisbNSplitDis){
                    for(Split_Disbur__c eachSplitDisObj:eachDisb.Split_Disbursements__r)
                    {
                        LoanBoardingRequestWrapper.SplitDisbursalDetails spDisDetail=new LoanBoardingRequestWrapper.SplitDisbursalDetails();    
                        spDisDetail.disbursalDate=eachDisb.Date_of_Disbur__c!=null ? String.valueOf(eachDisb.Date_of_Disbur__c.day()) + '-' + monthMap.get(eachDisb.Date_of_Disbur__c.month()) + '-' + String.valueOf(eachDisb.Date_of_Disbur__c.year()):'';
                        spDisDetail.paymentMode =masterDataMap.get('Payment Mode') !=null && eachSplitDisObj.Pay_Mode__c !=null ? (masterDataMap.get('Payment Mode').get(eachSplitDisObj.Pay_Mode__c.toupperCase()) !=null ? masterDataMap.get('Payment Mode').get(eachSplitDisObj.Pay_Mode__c.toupperCase()) : '') :'' ;  
                        
                        if((eachSplitDisObj.Fund_Transf_Mode__c) != null){
                            if(String.valueOf(eachSplitDisObj.Fund_Transf_Mode__c).equalsIgnoreCase('PREPAID CARD')){
                                spDisDetail.ftMode ='PC';
                            }
                            else if(String.valueOf(eachSplitDisObj.Fund_Transf_Mode__c).equalsIgnoreCase('RTGS')){
                                spDisDetail.ftMode ='RT';
                            }else if(String.valueOf(eachSplitDisObj.Fund_Transf_Mode__c).equalsIgnoreCase('NEFT')){
                                spDisDetail.ftMode ='NT';
                            }
                            else if(String.valueOf(eachSplitDisObj.Fund_Transf_Mode__c).equalsIgnoreCase('INTERNAL TRANSFER')){
                                spDisDetail.ftMode ='IT';
                            }
                            else if(String.valueOf(eachSplitDisObj.Fund_Transf_Mode__c).equalsIgnoreCase('ONLINE TRANSFER')){
                                spDisDetail.ftMode ='OT';
                            }
                            else if(String.valueOf(eachSplitDisObj.Fund_Transf_Mode__c).equalsIgnoreCase('IMPS')){
                                spDisDetail.ftMode ='IM';
                            }
                            else{
                                spDisDetail.ftMode ='';
                            }
                            
                        }
                        else{
                            spDisDetail.ftMode ='';
                        }
                        
                        spDisDetail.chequeNo ='0';//Hardcoded
                        spDisDetail.payableAt =  mapLocMas.get(eachSplitDisObj.Payable_At__c) != null ? mapLocMas.get(eachSplitDisObj.Payable_At__c).CityId__c !=null ?mapLocMas.get(eachSplitDisObj.Payable_At__c).CityId__c:'':'';//   eachSplitDisObj.Payable_At__c!=null ? eachSplitDisObj.Payable_At__c : '';
                        spDisDetail.inFavourOf =eachSplitDisObj.Cheq_Favor_Dets__c!=null ?eachSplitDisObj.Cheq_Favor_Dets__c:'';
                        spDisDetail.disbTo ='LS';//OK Hardcoded As Suggested
                        spDisDetail.effectIRR ='';  
                        spDisDetail.chequeDate =eachSplitDisObj.Cheq_DD_Date__c !=null ?String.valueOf(eachSplitDisObj.Cheq_DD_Date__c.day()) + '-' + monthMap.get(eachSplitDisObj.Cheq_DD_Date__c.month()) + '-' + String.valueOf(eachSplitDisObj.Cheq_DD_Date__c.year()):'';//String.valueOf(eachSplitDisObj.Cheq_DD_Date__c!=null ?String.valueOf(eachSplitDisObj.Cheq_DD_Date__c):'');
                        spDisDetail.splitRemarks =eachSplitDisObj.Remarks__c!=null ?eachSplitDisObj.Remarks__c:'';
                        spDisDetail.principalStartDate =eachDisb.Princ_Start_Date__c!=null ?String.valueOf(eachDisb.Princ_Start_Date__c.day()) + '-' + monthMap.get(eachDisb.Princ_Start_Date__c.month()) + '-' + String.valueOf(eachDisb.Princ_Start_Date__c.year()):'';//String.valueOf(eachDisb.Princ_Start_Date__c) !=null ?String.valueOf(eachDisb.Princ_Start_Date__c) :'';
                        spDisDetail.splitAccountNo=eachSplitDisObj.Cheq_Favor_Acc_No__c!=null?eachSplitDisObj.Cheq_Favor_Acc_No__c:'';
                        spDisDetail.bpName= 'LS'; //Hardcoded  // eachSplitDisObj.Custo_Name__c !=null?eachSplitDisObj.Custo_Name__c:''; Need to pass mandatory
                        spDisDetail.cashBankAccount ='489'; //Hardcoded //eachSplitDisObj.Fedbank_Acc_No__c !=null ?eachSplitDisObj.Fedbank_Acc_No__c:'';//TBD Hardcode or not- 489 //bank id lena hai bank code
                        spDisDetail.disbursementTo =''; //Blank
                        spDisDetail.splitAccNo =eachSplitDisObj.Cheq_Favor_Acc_No__c!=null?eachSplitDisObj.Cheq_Favor_Acc_No__c:'';
                        spDisDetail.splitAmount =String.valueOf(eachSplitDisObj.Split_Cheque_Amt__c)!=null?String.valueOf(eachSplitDisObj.Split_Cheque_Amt__c):'';
                        
                        
                        if(eachDisb.Princ_Rec_on__c !=null)
                        {            
                            if(String.valueOf(eachDisb.Princ_Rec_on__c).equalsIgnoreCase('Amount Disbursed till Date')){
                                spDisDetail.principalRecoveryOn='D';
                            }
                            else if(String.valueOf(eachDisb.Princ_Rec_on__c).equalsIgnoreCase('AMOUNT FINANCED')){
                                spDisDetail.principalRecoveryOn='S';
                            }else{
                                spDisDetail.principalRecoveryOn='';
                            }
                        }
                        else{
                            spDisDetail.principalRecoveryOn='';
                        }
                        spDisDetail.splitCreditPeriod ='0'; //OK
                        spDisDetail.micrCode =''; 
                        spDisDetail.ifscCode =eachSplitDisObj.IFSC_Detail__c !=null?eachSplitDisObj.IFSC_Detail__c:''; 
                        spDisDetail.effectiveDate =eachSplitDisObj.Effec_Date__c !=null ?  String.valueOf(eachSplitDisObj.Effec_Date__c.day()) + '-' + monthMap.get(eachSplitDisObj.Effec_Date__c.month()) + '-' + String.valueOf(eachSplitDisObj.Effec_Date__c.year()) :'';//String.valueOf(eachSplitDisObj.Effec_Date__c) !=null?String.valueOf(eachSplitDisObj.Effec_Date__c):'';
                        
                        listSplitDis.add(spDisDetail);
                    }    
                }  
                
                
                
                
                for(IntgMsg__c intMsg : msgs){
                    if(loanAppMap.containsKey(intMsg.RefId__c)){
                        
                        
                        
                        //SplitDisbursalDetails end
                        
                        //MortageDetails start blank
                        List<LoanBoardingRequestWrapper.MortageDetails> liMo=new List<LoanBoardingRequestWrapper.MortageDetails>();
                        LoanBoardingRequestWrapper.MortageDetails mrtDetails=new LoanBoardingRequestWrapper.MortageDetails();
                        mrtDetails.lienNumber =''; 
                        mrtDetails.loanOutstanding =''; 
                        mrtDetails.totalCollateralValue ='';
                        mrtDetails.loanNumber ='';
                        liMo.add(mrtDetails); 
                        //MortageDetails end blank
                        
                        
                        //SourcingDetail start
                        
                        LoanAppl__c dataLoanApp= loanAppRecordsMap.get(intMsg.RefId__c);
                        LoanBoardingRequestWrapper.SourcingDetail srcDetail =new LoanBoardingRequestWrapper.SourcingDetail();
                        
                        srcDetail.schemeCurr =''; 
                        srcDetail.loanPurposeDesc =''; 
                        srcDetail.strength =''; //blank
                        srcDetail.scheme = (listScheme.size()>0 && listScheme !=null)  ? listScheme[0].SchmId__c !=null ?listScheme[0].SchmId__c :'' :'';// dataLoanApp.SchmCode__c !=null ?dataLoanApp.SchmCode__c:''; //'556'; //manish suggested
                        srcDetail.finnoneUser ='3407'; 
                        srcDetail.finnoneStage ='FINISH'; 
                        srcDetail.dateOfDisbursal =''; 
                        srcDetail.referralName =''; 
                        srcDetail.referralGroup =''; 
                        srcDetail.sourceCode = ''; //dataLoanApp.LeadSource__c != null ? dataLoanApp.LeadSource__c : ''; //Blank
                        srcDetail.applicationFormNo =	GlobalUtility.getUniqueNumber();// dataLoanApp.Name !=null ?dataLoanApp.Name :''; 
                        srcDetail.referralCode =dataLoanApp.RefEmpCode__c!=null ?dataLoanApp.RefEmpCode__c :'';//'BNGCONSTL054'; 
                        srcDetail.reasonSpecialCondition =''; //blank
                        srcDetail.crmExistingLan =''; 
                        
                        srcDetail.loanPurpose = (listLoanPurpose !=null && listLoanPurpose.size() > 0) ? listLoanPurpose[0].Value__c != null ? listLoanPurpose[0].Value__c :'' :''; // dataLoanApp.LoanPurpose__c!=null ? dataLoanApp.LoanPurpose__c :''; //master hardcoded
                        srcDetail.custProfile =''; //blank
                        srcDetail.tenureInMonths ='180'; //  hardcoded String.valueOf(dataLoanApp.Loan_Tenure_Months__c)!=null ? String.valueOf(dataLoanApp.Loan_Tenure_Months__c) : '' ; //hardcoded not master depend on BRE  loanAppRecordsMap.get(intMsg.RefId__c)!=null ? loanAppRecordsMap.get(intMsg.RefId__c).Loan_Tenure_Months__c 
                        srcDetail.relationshipManager = '';// dataLoanApp.RMSMEmployeeID__c!=null?dataLoanApp.RMSMEmployeeID__c:'';  //can be blank
                        srcDetail.applicationID = '' ; // Hardcoded //String.valueOf(dataLoanApp.FinnoneAppid__c)!=null ?String.valueOf(dataLoanApp.FinnoneAppid__c):''; 
                        srcDetail.existingCustomerName =''; 
                        srcDetail.channelCode = masterDataMap.get('Channel') !=null ? String.valueOf(masterDataMap.get('Channel').get(dataLoanApp.LeadSource__c))!=null  ? String.valueOf(masterDataMap.get('Channel').get(dataLoanApp.LeadSource__c)) : '':''; //Please add hardcoded
                        // srcDetail.branchId =  mapLocMas.get(dataLoanApp.BrchName__c) !=null ? String.valueOf(mapLocMas.get(String.valueOf(dataLoanApp.BrchName__c).toUppercase()).CityId__c)  !=null ? String.valueOf(mapLocMas.get(String.valueOf(dataLoanApp.BrchName__c).toUppercase()).CityId__c) :'':''; //   dataLoanApp.BrchName__c !=null ?dataLoanApp.BrchName__c:''; //harcoded 
                        
                        if(mapLocMas.get(String.valueOf(dataLoanApp.BrchName__c).toUppercase()) !=null){
                            
                            if(!String.isBlank(String.valueOf(mapLocMas.get(String.valueOf(dataLoanApp.BrchName__c).toUppercase()).CityId__c))){
                                
                                srcDetail.branchId = String.valueOf(mapLocMas.get(String.valueOf(dataLoanApp.BrchName__c).toUppercase()).CityId__c);
                                
                            }
                            else{
                                srcDetail.branchId ='';
                            }
                            
                        }
                        else{
                            srcDetail.branchId ='';
                        }
                        
                        System.debug('branchId::'+srcDetail.branchId);
                        System.debug('String.valueOf(mapLocMas.get(String.valueOf(dataLoanApp.BrchName__c).toUppercase()).CityId__c) :'+String.valueOf(mapLocMas.get(String.valueOf(dataLoanApp.BrchName__c).toUppercase()).CityId__c) );
                        System.debug('String.valueOf(dataLoanApp.BrchName__c).toUppercase():'+String.valueOf(dataLoanApp.BrchName__c).toUppercase());
                        System.debug('mapLocMas.get(dataLoanApp.BrchName__c):'+mapLocMas.get(dataLoanApp.BrchName__c));
                        srcDetail.reasonDescription =''; 
                        if(masterDataMap.get('Product') !=null)
                        {
                            if(String.valueOf(masterDataMap.get('Product').get(dataLoanApp.Product__c)) == 'Small Ticket LAP')
                            {
                                srcDetail.product ='STL';
                            }
                            else if(String.valueOf(masterDataMap.get('Product').get(dataLoanApp.Product__c)) == 'Home Loan'){
                                srcDetail.product = 'HL';
                            }
                            else
                            {
                                srcDetail.product = '';
                            }
                        }
                        else
                        {
                            srcDetail.product = '';
                        }
                        
                        srcDetail.custProfileType ='P';//Hardcoded 
                        srcDetail.bankBranch =''; 
                        srcDetail.resaonComments =''; //blank
                        srcDetail.dateEncoded =dataLoanApp.CreatedDate !=null ? String.valueOf(dataLoanApp.CreatedDate.day()) + '-' + monthMap.get(dataLoanApp.CreatedDate.month()) + '-' + String.valueOf(dataLoanApp.CreatedDate.year()) :'';//String.valueOf(dataLoanApp.CreatedDate)!=null ?String.valueOf(dataLoanApp.CreatedDate) :'';  
                        srcDetail.priority =''; 
                        srcDetail.promotionCurr =''; 
                        srcDetail.accountOfficeName =''; 
                        srcDetail.loanAmount =String.valueOf(dataLoanApp.TotalLoanAmtInclInsurance__c)!=null ?String.valueOf(dataLoanApp.TotalLoanAmtInclInsurance__c):''; 
                        srcDetail.branchCode =(listBrnchCode !=null && !listBrnchCode.isEmpty()) ? listBrnchCode[0].OffcCode__c !=null ?listBrnchCode[0].OffcCode__c:'':''; 
                        srcDetail.specialConditionFor =''; 
                        srcDetail.sourcingBranch = '01003';//(listBrnchCode !=null && !listBrnchCode.isEmpty()) ? String.valueOf(listBrnchCode[0].OffcCode__c) :'';// String.valueOf(dataLoanApp.RMSMName__r.Brch__c) !=null ? String.valueOf(dataLoanApp.RMSMName__r.Brch__c) :''; //'01003';//master  
                        srcDetail.dsa = '384';//Hardcoded dataLoanApp.ChannelCode__c !=null  ?dataLoanApp.ChannelCode__c:'';  
                        srcDetail.dateOfReceipt =dataLoanApp.CreatedDate!=null ? String.valueOf(dataLoanApp.CreatedDate.day()) + '-' + monthMap.get(dataLoanApp.CreatedDate.month()) + '-' + String.valueOf(dataLoanApp.CreatedDate.year()) :'';//String.valueOf(dataLoanApp.CreatedDate)!=null ?String.valueOf(dataLoanApp.CreatedDate):''; 
                        srcDetail.accountOfficerCode =''; 
                        srcDetail.dme ='3407';//  '3407'; Hardcoded//Pass this mandatory
                        srcDetail.sourceState =''; 
                        
                        if(listPromotion!=null && !listPromotion.isEmpty()){
                            System.debug('srcDetail.promotion ='+listPromotion[0].PromoId__c);
                        }
                        
                        if(listPromotion!=null && !listPromotion.isEmpty())
                        {
                            srcDetail.promotion = listPromotion[0].PromoId__c;
                        }
                        else
                        {
                            srcDetail.promotion ='';
                        }
                        //if(listPromotion!=null && !listPromotion.isEmpty()){

//}
                        //dataLoanApp.PromCode__c!=null ?dataLoanApp.PromCode__c :''; 
                        //SourcingDetail end
                        
                        //RateRiskDetails start blank    
                        List<LoanBoardingRequestWrapper.RateRiskDetails> listRateRiskDetails =new List<LoanBoardingRequestWrapper.RateRiskDetails>();
                        LoanBoardingRequestWrapper.RateRiskDetails rateRiskDet=new LoanBoardingRequestWrapper.RateRiskDetails();
                        rateRiskDet.commissionRate =''; 
                        rateRiskDet.lessorName =''; 
                        rateRiskDet.bpType =''; 
                        rateRiskDet.consortiumType =''; 
                        rateRiskDet.contributionRate =''; 
                        rateRiskDet.contributionAmt =''; 
                        listRateRiskDetails.add(rateRiskDet);
                        //RateRiskDetails end blank 
                        
                        //ReferenceDetails start
                        
                        List<LoanBoardingRequestWrapper.ReferenceDetails> listRefdetails= new List<LoanBoardingRequestWrapper.ReferenceDetails>();
                        List<Ref__c> listRefObjs =appRefMapByLoanApp.get(loanApplnIds[0]);
                        
                        if(listRefObjs !=null && !listRefObjs.isEmpty())
                        {
                            for(Ref__c eachRefObj:listRefObjs){
                                LoanBoardingRequestWrapper.ReferenceDetails refDetails =new LoanBoardingRequestWrapper.ReferenceDetails();
                                refDetails.refCity ='';  //blank
                                refDetails.refAddressLine5 =''; 
                                refDetails.refaddressLine1 =eachRefObj.Add__c!=null?eachRefObj.Add__c:''; 
                                refDetails.refEmailId =''; 
                                refDetails.refSalutation =eachRefObj.FName__c!=null?eachRefObj.FName__c:''; 
                                refDetails.refPhoneAreaCode =''; 
                                refDetails.refOfficeExtNo =''; 
                                refDetails.refPhone2 =''; 
                                refDetails.refereeName =eachRefObj.FName__c!=null?eachRefObj.FName__c:''; 
                                refDetails.refPhone1 =eachRefObj.Applicant__r.MobNumber__c!=null?eachRefObj.Applicant__r.MobNumber__c:''; 
                                refDetails.refMobile =eachRefObj.Applicant__r.MobNumber__c!=null?eachRefObj.Applicant__r.MobNumber__c:''; 
                                refDetails.refZipCode =''; 
                                refDetails.refAddressLine2 =''; 
                                refDetails.refAddressLine4 =''; 
                                refDetails.refAddressLine3 =''; 
                                refDetails.refereeRelation =eachRefObj.RelationshipWthApp__c!=null?eachRefObj.RelationshipWthApp__c:''; 
                                refDetails.refTitle ='Mr'; //harcoded as it is not captured in sfdc
                                
                                //adding data to list
                                listRefdetails.add(refDetails);
                            }
                            
                        }
                        //ReferenceDetails End
                        //DemoCorpRatingDetails start blank
                        
                        List<LoanBoardingRequestWrapper.DemoCorpRatingDetails> listDemoCopratDetail=new List<LoanBoardingRequestWrapper.DemoCorpRatingDetails>();
                        LoanBoardingRequestWrapper.DemoCorpRatingDetails demoCorRatDet=new LoanBoardingRequestWrapper.DemoCorpRatingDetails();
                        demoCorRatDet.corpRatingRemarks =''; 
                        demoCorRatDet.corpRatingValidTillDate =''; 
                        demoCorRatDet.corpPublishingDate =''; 
                        demoCorRatDet.corpRatingGrade =''; 
                        demoCorRatDet.corpPurposeOfRating =''; 
                        demoCorRatDet.corpRatingAgency ='';
                        listDemoCopratDetail.add(demoCorRatDet);
                        //DemoCorpRatingDetails end blank 
                        
                        
                        
                        //CrossCollateral->blank
                        List<LoanBoardingRequestWrapper.CrossCollateral> listCrsCol =new List<LoanBoardingRequestWrapper.CrossCollateral>();
                        LoanBoardingRequestWrapper.CrossCollateral crsCol=new LoanBoardingRequestWrapper.CrossCollateral();
                        crsCol.agreementType =''; 
                        crsCol.crossCustomerName =''; //blank
                        crsCol.doneOn =''; 
                        crsCol.applicationId =''; 
                        listCrsCol.add(crsCol);
                        //CrossCollateral->blank end
                        
                        //ChargesDetails start
                        List<LoanBoardingRequestWrapper.ChargesDetails> listChrdetails= new List<LoanBoardingRequestWrapper.ChargesDetails>(); 
                        List<LonaApplCharges__c> listOfCharges = appLoanChargesMapByLoanApp.get(loanApplnIds[0]);
                        
                        if(listOfCharges !=null && !listOfCharges.isEmpty()){
                            
                            
                            
                            for(LonaApplCharges__c chrgObj: listOfCharges){
                                LoanBoardingRequestWrapper.ChargesDetails chrDetails=new LoanBoardingRequestWrapper.ChargesDetails();
                                
                                chrDetails.chargeCalculatedOn = 'AMT FINANCED';  // chrgObj.ChargeCodeDesc__c!=null ?chrgObj.ChargeCodeDesc__c: ''; 
                                chrDetails.chargeId =chrgObj.ChargeCodeID__c !=null? chrgObj.ChargeCodeID__c :''; 
                                chrDetails.periodicCharge ='N'; 
                                chrDetails.chargeAmount =String.valueOf(chrgObj.Amount__c) !=null ? String.valueOf(chrgObj.Amount__c) : ''; 
                                chrDetails.chargeToBeFinanced ='N';
                                listChrdetails.add(chrDetails);
                                
                            }
                            
                        }
                        //********** For 68 Code Logic ***************
                        
                        if(loanAppRecordsMap.get(loanApplnIds[0]) !=null)
                        {
                            if(loanAppRecordsMap.get(loanApplnIds[0]).RemPFDeductFromDisbursementAmount__c == 'Yes')
                            {
                                LoanBoardingRequestWrapper.ChargesDetails chrDetails2=new LoanBoardingRequestWrapper.ChargesDetails();
                                chrDetails2.chargeCalculatedOn = 'AMT FINANCED'; // chrgObj.ChargeCodeDesc__c!=null ?chrgObj.ChargeCodeDesc__c: '' ; 
                                chrDetails2.chargeId = '68';//chrgObj.ChargeCodeID__c !=null ? chrgObj.ChargeCodeID__c : ''; 
                                chrDetails2.periodicCharge ='N'; 
                                chrDetails2.chargeAmount = String.valueOf(loanAppRecordsMap.get(loanApplnIds[0]).Total_PF_Amount__c) !=null ?String.valueOf(loanAppRecordsMap.get(loanApplnIds[0]).Total_PF_Amount__c) :''; 
                                chrDetails2.chargeToBeFinanced ='N';
                                listChrdetails.add(chrDetails2);
                                
                            }
                        }
                        
                        //ChargesDetails end
                        
                        //mscInfoDetails start blank
                        LoanBoardingRequestWrapper.MscInfoDetails mscInfoObj =new LoanBoardingRequestWrapper.MscInfoDetails();
                        mscInfoObj.mscdetails28 =''; 
                        mscInfoObj.mscdetails27 =''; 
                        mscInfoObj.mscdetails26 =''; 
                        mscInfoObj.mscdetails25 =''; 
                        mscInfoObj.mscdetails29 =''; 
                        mscInfoObj.mscdetails20 =''; 
                        mscInfoObj.mscdetails24 =''; 
                        mscInfoObj.mscdetails23 =''; 
                        mscInfoObj.mscdetails22 =''; 
                        mscInfoObj.mscdetails21 =''; 
                        mscInfoObj.mscdetails17 =''; 
                        mscInfoObj.mscdetails16 =''; 
                        mscInfoObj.mscdetails15 =''; 
                        mscInfoObj.mscdetails14 =''; 
                        mscInfoObj.mscdetails19 =''; 
                        mscInfoObj.mscdetails18 =''; 
                        mscInfoObj.mscdetails7 =''; 
                        mscInfoObj.mscdetails30 =''; 
                        mscInfoObj.mscdetails8 =''; 
                        mscInfoObj.mscdetails5 =''; 
                        mscInfoObj.mscdetails6 =''; 
                        mscInfoObj.mscdetails13 =''; 
                        mscInfoObj.mscdetails12 =''; 
                        mscInfoObj.mscdetails11 =''; 
                        mscInfoObj.mscdetails9 =''; 
                        mscInfoObj.mscdetails10 =''; 
                        mscInfoObj.mscdetails3 =''; 
                        mscInfoObj.mscdetails4 =''; 
                        mscInfoObj.mscdetails1 =''; 
                        mscInfoObj.mscdetails2 ='';  
                        //mscInfoDetails end blank
                        
                        //tradeInDetail start blank
                        List<LoanBoardingRequestWrapper.TradeInDetail> listtradeInDeatil=new  List<LoanBoardingRequestWrapper.TradeInDetail>();
                        LoanBoardingRequestWrapper.TradeInDetail trDetails=new LoanBoardingRequestWrapper.TradeInDetail();
                        trDetails.tradeInInsured =''; 
                        trDetails.comments =''; 
                        trDetails.subModel =''; 
                        trDetails.valuation1 =''; 
                        trDetails.valuation2 =''; 
                        trDetails.yearPurchased =''; 
                        trDetails.assetType =''; 
                        trDetails.hypothecationLien =''; 
                        trDetails.mileageKmHr =''; 
                        trDetails.finalValuation =''; 
                        trDetails.registrationNo =''; 
                        trDetails.vin =''; 
                        trDetails.model =''; 
                        trDetails.natureOfOwnerShip ='';
                        listtradeInDeatil.add(trDetails); 
                        //tradeInDetail end blank  
                        
                        //StakeHolderDetails start balnk
                        List<LoanBoardingRequestWrapper.StakeHolderDetails> listStakDetls =new List<LoanBoardingRequestWrapper.StakeHolderDetails> ();
                        LoanBoardingRequestWrapper.StakeHolderDetails stkHolderDetails =new LoanBoardingRequestWrapper.StakeHolderDetails();
                        stkHolderDetails.corpStakeholderTitle =''; 
                        stkHolderDetails.corpStakeholderStakePercent =''; 
                        stkHolderDetails.corpStakeholderContactType =''; 
                        stkHolderDetails.corpStakeholderDINNo =''; 
                        stkHolderDetails.corpStakeholderFirstName =''; 
                        stkHolderDetails.corpStakeholderDOI =''; 
                        stkHolderDetails.corpStakeholderIdNo =''; 
                        stkHolderDetails.corpStakeholderPassportNo =''; 
                        stkHolderDetails.corpStakeRelatedNameOfCompany =''; 
                        stkHolderDetails.corpStakeholderIdType =''; 
                        stkHolderDetails.corpStakeHolderPosition =''; 
                        stkHolderDetails.corpStakeholderLastName =''; 
                        stkHolderDetails.corpStakeholderGender =''; 
                        stkHolderDetails.corpStakeholderCompanyName =''; 
                        stkHolderDetails.corpStakeholderConsiderGrading =''; 
                        stkHolderDetails.corpStakeholderNationality =''; 
                        stkHolderDetails.corpStakeholderTIN =''; 
                        stkHolderDetails.corpStakeholderMidName =''; 
                        stkHolderDetails.corpStakeholderTotalExp =''; 
                        stkHolderDetails.corpStakeholderJoinedSince =''; 
                        stkHolderDetails.corpStakeHolderPhone =''; 
                        listStakDetls.add(stkHolderDetails);
                        //StakeHolderDetails end blank
                        
                        //repaymentDetails blank
                        List<LoanBoardingRequestWrapper.RepaymentDetails> listRepayDetails =new List<LoanBoardingRequestWrapper.RepaymentDetails>();
                        List<LoanBoardingRequestWrapper.RepaymentDetails> listRepayDetails1 =new List<LoanBoardingRequestWrapper.RepaymentDetails>();
                        
                        LoanBoardingRequestWrapper.RepaymentDetails rpDet =new LoanBoardingRequestWrapper.RepaymentDetails();
                        listRepayDetails.add(rpDet);
                        //repaymentDetails blank
                        
                        //InstrumentDetails start 
                        LoanBoardingRequestWrapper.InstrumentDetails instDetails=new LoanBoardingRequestWrapper.InstrumentDetails();
                        integer tempI=0;
                        //for(ApplIMD__c eachAppImd : [select id,City__c,PaymentMode__c,MICRCode__c,BankBrch__c,BankAccountNo__c from ApplIMD__c where LoanAppln__c  IN : loanApplnIds]){  Repayment_Mode__c
                        for(Repayment_Account__c eachRepayAcc : listRepayAccounts)
                        {     tempI++;
                         System.debug('tempI::'+tempI);
                         System.debug('eachRepayAcc.Repayment_Mode__c:'+eachRepayAcc.Repayment_Mode__c);
                         String strBankCity =eachRepayAcc.Applicant_Banking__r.Bank_City__c;
                         
                         LocMstr__c locMasterData = mapLocMas.get(strBankCity);
                         
                         instDetails.instrumentType =masterDataMap.get('Instrument Type')!=null ? masterDataMap.get('Instrument Type').get(eachRepayAcc.Repayment_Mode__c)   != null ? masterDataMap.get('Instrument Type').get(eachRepayAcc.Repayment_Mode__c) : '' :''; 
                         
                         if(eachRepayAcc.Repayment_Mode__c != null)
                         {
                             if(eachRepayAcc.Repayment_Mode__c == 'PDC')
                             {
                                 instDetails.downloadToPDCMS ='Y';  
                             }
                             else
                             {
                                 instDetails.downloadToPDCMS ='N'; 
                             }
                         }
                         else
                         {
                             instDetails.downloadToPDCMS ='N'; 
                         }
                         
                         instDetails.customerAccNo = eachRepayAcc.Account_Number__c !=null ? eachRepayAcc.Account_Number__c : '';
                         
                         
                         instDetails.instrumentCity = locMasterData!=null ? locMasterData.CityId__c !=null ? String.valueOf(locMasterData.CityId__c) :'':''; 
                         
                         instDetails.employeeCode =''; //Blank
                         instDetails.micrFlag =''; //Blank
                         instDetails.instrumentBank =eachRepayAcc.Applicant_Banking__r.Bank_Code__c !=null?eachRepayAcc.Applicant_Banking__r.Bank_Code__c:''; 
                         
                         instDetails.micrCode = eachRepayAcc.MICR_Code__c !=null ? eachRepayAcc.MICR_Code__c :''; 
                         instDetails.instrumentBankBranch =eachRepayAcc.Applicant_Banking__r.Bank_Code__c !=null ?eachRepayAcc.Applicant_Banking__r.Bank_Code__c :'';
                         instDetails.destBankAccType ='10'; // Hardcoded As Suggested eachRepayAcc.Applicant_Banking__r.AccountType__c != null ?  eachRepayAcc.Applicant_Banking__r.AccountType__c:''; //TBD master Not created
                         instDetails.ifscCode =''; //blank 
                         
                         if(liPdc !=null && !liPdc.isEmpty())
                         {
                             instDetails.pdcByName =liPdc[0].Repayment_Account__r.Applicant_Banking__r.PDC_by_Name__c !=null ? liPdc[0].Repayment_Account__r.Applicant_Banking__r.PDC_by_Name__c :'';
                             instDetails.destAccHolder =liPdc[0].Repayment_Account__r.Applicant_Banking__r.PDC_by_Name__c!=null ? liPdc[0].Repayment_Account__r.Applicant_Banking__r.PDC_by_Name__c :'';
                         }
                         else
                         {
                             instDetails.pdcByName ='';
                             instDetails.destAccHolder ='';
                         }
                         
                         if(eachRepayAcc.Applicant_Banking__r.Appl__r.ApplType__c !=null)
                         {
                             if(eachRepayAcc.Applicant_Banking__r.Appl__r.ApplType__c =='P')
                             {
                                 instDetails.pdcBy= 'A';
                             }
                             else
                             {
                                 instDetails.pdcBy= 'C';
                             }
                         }
                         else
                         {
                             instDetails.pdcBy= '';
                         }
                        }
                        
                        //instrumentDetails end  
                        
                        //LiabilityDetails start
                        
                        List<LoanBoardingRequestWrapper.LiabilityDetails> listLiabDtls =new List<LoanBoardingRequestWrapper.LiabilityDetails>(); 
                        List<BureauRespDtl__c> listForBureauRes = appBureauMapByLoanApp.get(loanApplnIds[0]);
                        if(listForBureauRes !=null && !listForBureauRes.isEmpty()){
                            
                            
                            for(BureauRespDtl__c eachBurresObj :listForBureauRes)
                            {
                                LoanBoardingRequestWrapper.LiabilityDetails liabDetail =new LoanBoardingRequestWrapper.LiabilityDetails();
                                liabDetail.considerForIncome =eachBurresObj.ConsiderObligation__c!=null ? eachBurresObj.ConsiderObligation__c:''; 
                                liabDetail.totalOutstanding =''; 
                                liabDetail.liabilityTypeOfLoan ='';//eachBurresObj.NatureOfLoan__c!=null ? eachBurresObj.NatureOfLoan__c:'nature'; //harcoded
                                liabDetail.liabiltiyStatusType =''; 
                                liabDetail.considerForBT =''; 
                                liabDetail.loanOwnership =eachBurresObj.LoanName__c!=null?eachBurresObj.LoanName__c:''; 
                                liabDetail.noOfYearsExistFinancier =''; 
                                liabDetail.noOfBounces =''; 
                                liabDetail.liabilitySource =eachBurresObj.Source__c!=null?eachBurresObj.Source__c:''; 
                                liabDetail.liabilityEmiAmount =String.valueOf(eachBurresObj.EMI__c)!=null ?String.valueOf(eachBurresObj.EMI__c):''; 
                                liabDetail.noOfInstallments =''; 
                                liabDetail.obligationToBeDeducted =''; 
                                liabDetail.considerForFOIR =''; 
                                liabDetail.liabilityNoOfEmi =''; 
                                liabDetail.fdAsCollateral =''; 
                                liabDetail.outwardChequeRet =''; 
                                liabDetail.loanClosureDate =eachBurresObj.CloseDate__c!=null ?String.valueOf(eachBurresObj.CloseDate__c.day()) + '-' + monthMap.get(eachBurresObj.CloseDate__c.month()) + '-' + String.valueOf(eachBurresObj.CloseDate__c.year()):'';//String.valueOf(eachBurresObj.CloseDate__c)!=null ?String.valueOf(eachBurresObj.CloseDate__c): ''; 
                                liabDetail.existingFinanciarname =''; 
                                liabDetail.loanAmount =String.valueOf(eachBurresObj.LoanAmount__c)!=null ?String.valueOf(eachBurresObj.LoanAmount__c):''; 
                                liabDetail.financierName =eachBurresObj.FinancierName__c!=null?eachBurresObj.FinancierName__c:''; 
                                liabDetail.installmentsToBePaid =String.valueOf(eachBurresObj.TenureLeft__c)!=null?String.valueOf(eachBurresObj.TenureLeft__c):''; 
                                liabDetail.loanAccountNumber =''; 
                                liabDetail.existingNoOfBounces =''; 
                                liabDetail.bankStatementCollected =''; 
                                liabDetail.emiAlreadyPaid =String.valueOf(eachBurresObj.NoEMIPaid__c)!=null?String.valueOf(eachBurresObj.NoEMIPaid__c):''; 
                                liabDetail.considerForObligation =eachBurresObj.ConsiderObligation__c!=null ? eachBurresObj.ConsiderObligation__c:'';
                                liabDetail.totalNoOfEMIs =''; 
                                liabDetail.princOutstanding =String.valueOf(eachBurresObj.CurrentOs__c)!=null?String.valueOf(eachBurresObj.CurrentOs__c):''; 
                                
                                //adding values
                                listLiabDtls.add(liabDetail);
                                
                            }
                            
                        }
                        //LiabilityDetails end
                        
                        //loanDetails start
                        List<ApplAsset__c> listAppAssestforAmount = appAssetMapByLoanApp.get(loanApplnIds[0]); //  [select Id,Total_Prop_Cost__c from ApplAsset__c where LoanAppln__c IN:loanApplnIds];
                        Integer totalPropAmount= 0;
                        if(listAppAssestforAmount !=null && listAppAssestforAmount.size()>0){
                            for(ApplAsset__c appAsset : listAppAssestforAmount){
                                totalPropAmount= totalPropAmount + Integer.valueOf(appAsset.Total_Prop_Cost__c);
                            }        
                        }
                        System.debug('totalPropAmount::'+totalPropAmount);
                        LoanAppl__c eachLoanAppObj = loanAppRecordsMap.get(intMsg.RefId__c);      
                        LoanBoardingRequestWrapper.LoanDetails lnDetails=new LoanBoardingRequestWrapper.LoanDetails();
                        lnDetails.assetCost =String.valueOf(totalPropAmount); 
                        lnDetails.interestTaxRate =''; //Blank
                        lnDetails.businessIRR =''; //Blank
                        lnDetails.loanPLRType =eachLoanAppObj.LoanPLRType__c!=null ?eachLoanAppObj.LoanPLRType__c: ''; 
                        lnDetails.flatRate =''; //Blank
                        lnDetails.advInstallment =''; //Blank
                        lnDetails.repayFrequency =eachLoanAppObj.Repayment_Frequency__c!=null ?eachLoanAppObj.Repayment_Frequency__c: '';   
                        lnDetails.ioiApplicable =''; //Blank
                        lnDetails.fixedFor ='0'; //ok
                        lnDetails.subventionPercentage =''; //Blank
                        lnDetails.interestStartDate = String.valueOf(System.today().day()) + '-' +  monthMap.get(System.today().month()) + '-' +  String.valueOf(System.today().year());  //need to ckeck this  
                        lnDetails.interestRoundPrecision =''; 
                        lnDetails.eirRate =''; //Blank
                        lnDetails.loanEMI =emiLoan; // String.valueOf(eachLoanAppObj.TotalLoanAmtInclInsurance__c!=null ?String.valueOf(eachLoanAppObj.TotalLoanAmtInclInsurance__c):''); 
                        lnDetails.disbAmount =String.valueOf(eachLoanAppObj.DisbursedAmount__c!=null ?String.valueOf(eachLoanAppObj.DisbursedAmount__c):''); 
                        lnDetails.installmentMode ='R'; //OK
                        lnDetails.loanPLRRate =String.valueOf(eachLoanAppObj.LoanPLRRate__c)!=null ?String.valueOf(eachLoanAppObj.LoanPLRRate__c): '' ; 
                        lnDetails.addInterestSchedule =eachLoanAppObj.AddIntSchedule__c!=null ?eachLoanAppObj.AddIntSchedule__c: '' ; 
                        lnDetails.disburseTo ='LS';//hardcoded OK
                        lnDetails.downPaymentRate =''; //Blank
                        lnDetails.interestRoundOff =''; //Blank
                        lnDetails.rateTypeFloatingFlag =eachLoanAppObj.Rate_Type_Floating_Flag__c!=null ?eachLoanAppObj.Rate_Type_Floating_Flag__c: ''; 
                        lnDetails.addOnRate ='';//Blank
                        lnDetails.effectiveRate =String.valueOf(eachLoanAppObj.EffectiveROI__c!=null ?String.valueOf(eachLoanAppObj.EffectiveROI__c): '');  
                        lnDetails.graceApplicableFlag =eachLoanAppObj.MoratGraceApplicable__c!=null ?eachLoanAppObj.MoratGraceApplicable__c: ''; 
                        lnDetails.interestTax =''; //Blank
                        lnDetails.disbType =  eachLoanAppObj.DisbursalType__c!=null ? String.valueof(eachLoanAppObj.DisbursalType__c).toUppercase(): ''; 
                        lnDetails.floatingFrequency ='0'; //OK
                       // lnDetails.gracePeriod =eachLoanAppObj.MoratGracePeriodMonths__c!=null ?eachLoanAppObj.MoratGracePeriodMonths__c: ''; 
                        lnDetails.dueDay =eachLoanAppObj.DueDay__c!=null ?eachLoanAppObj.DueDay__c: ''; 
                        lnDetails.interestInAdvance =''; //Blank
                        lnDetails.rateEMIFlag ='R'; //hardcoded R=>rate E=>EMI M=>Multi Interest rate (Master name=>Rate EMI flag)
                        lnDetails.fisrtEmiDate = eachLoanAppObj.FirstEMIDate__c !=null ?  String.valueOf(eachLoanAppObj.FirstEMIDate__c.day()) + '-' + monthMap.get(eachLoanAppObj.FirstEMIDate__c.month()) + '-' + String.valueOf(eachLoanAppObj.FirstEMIDate__c.year()) :'';//String.valueOf(eachLoanAppObj.FirstEMIDate__c!=null ?String.valueOf(eachLoanAppObj.FirstEMIDate__c): '');   
                        lnDetails.installmentPlan =String.valueOf(eachLoanAppObj.Installment_Plan__c!=null ?eachLoanAppObj.Installment_Plan__c: ''); 
                        lnDetails.principalBaseUnit ='1'; //OK
                        lnDetails.firstEmiDueYear =String.valueOf(eachLoanAppObj.FirstEMIDueYear__c!=null ?eachLoanAppObj.FirstEMIDueYear__c: ''); 
                        lnDetails.channelDSASubvention ='';//Blank
                        lnDetails.impactOnTenure =eachLoanAppObj.ImpactOnTenure__c!=null ?eachLoanAppObj.ImpactOnTenure__c: '';  
                        lnDetails.reqInterestType ='E'; //OK
                        lnDetails.capitalizeInterest ='N'; //OK
                        lnDetails.interestRoundMethod ='';  //Blank
                        lnDetails.spreadID = '';// String.valueOf(eachLoanAppObj.SpreadID__c)!=null ?String.valueOf(eachLoanAppObj.SpreadID__c): '';  
                        lnDetails.loanRest =''; //Blank
                        lnDetails.tdsRate ='0'; //OK
                        lnDetails.chargeInterest =eachLoanAppObj.ChargeInterest__c!=null ?eachLoanAppObj.ChargeInterest__c: ''; 
                        lnDetails.numberOfInstallments ='180'; // Hardcoded String.valueOf(eachLoanAppObj.Loan_Tenure_Months__c)!=null ?String.valueOf(eachLoanAppObj.Loan_Tenure_Months__c): ''; //BRE YBD
                        lnDetails.noOfDisbursal ='1';//OK 
                        lnDetails.depositAccount =''; //Blank
                        lnDetails.installmentRoundPrecision ='';//Blank 
                        lnDetails.downpayment =''; //Blank
                        lnDetails.fisrtEmiDueMonth =loanAppRecordsMap.get(loanApplnIds[0]) !=null ? String.valueOf(mapFirstEmiDueMon.get(loanAppRecordsMap.get(loanApplnIds[0]).FirstEMIDueMonth__c)) !=Null ? String.valueOf(mapFirstEmiDueMon.get(loanAppRecordsMap.get(loanApplnIds[0]).FirstEMIDueMonth__c)) : '':''; 
                        //loanDetails end
                        
                        
                        //personalDiscussion start 
                        List<LoanBoardingRequestWrapper.PersonalDiscussion> listPerDiscussion =new List<LoanBoardingRequestWrapper.PersonalDiscussion>();
                        
                        List<BRE__c> listOfBreObjs= appBreResByLoanApp.get(loanApplnIds[0]);
                        if(listOfBreObjs!=null && !listOfBreObjs.isEmpty()){
                            
                            for(BRE__c eachBre :listOfBreObjs)
                            {
                                LoanBoardingRequestWrapper.PersonalDiscussion perDis=new LoanBoardingRequestWrapper.PersonalDiscussion();
                                
                                
                                perDis.analysisOfFinancials =''; 
                                perDis.currentObligationDetails =''; 
                                perDis.anyMisleadingInformation =''; 
                                perDis.foir = String.valueOf(eachBre.Actual_FOIR__c) !=null ?String.valueOf(eachBre.Actual_FOIR__c): ''; 
                                perDis.grossMonthlyIncome ='';  //blank
                                perDis.empDetailNatureofBusi =''; 
                                perDis.assetOwned =''; 
                                perDis.mainClients =''; 
                                perDis.resiDetails =''; 
                                perDis.interviewerDecision =''; 
                                perDis.verificationMatch =''; 
                                perDis.interviewerComments =''; 
                                perDis.natureOfFinancialTransaction =''; 
                                perDis.nameOfInterviewer =''; //8
                                perDis.crossSellRemarks =''; 
                                perDis.pfiRemark =''; 
                                perDis.shareHoldingPattern =''; 
                                perDis.propertyDetails =''; 
                                perDis.additionalDocumentCollected =''; 
                                perDis.dateOfMeeting =''; 
                                perDis.futureGrowthPlan =''; 
                                perDis.anyOthBusi =''; 
                                perDis.pfiDoneBy =''; 
                                perDis.placeOfMeeting =''; 
                                perDis.personContacted =''; 
                                perDis.mainSuppliers =''; 
                                perDis.pfiDone =''; 
                                perDis.mainProducts =''; 
                                perDis.aggregateExposure ='';//blank 
                                perDis.customerProfile =''; 
                                perDis.staffStrength =''; 
                                perDis.grossMonthlyPayable =''; //blank
                                perDis.empNo =''; 
                                perDis.bankingHabit =''; 
                                perDis.timeFrame =''; 
                                perDis.decisionDate =''; 
                                perDis.levelOfActivity =''; 
                                perDis.offDetails =''; 
                                perDis.majorVariationsInFinancial =''; 
                                perDis.clientMarketRef =''; 
                                perDis.crossSell =''; 
                                perDis.designation =''; 
                                perDis.emiComfortableWith =''; 
                                perDis.detailOfEndUseOfFunds =''; 
                                listPerDiscussion.add(perDis);
                                
                            }  
                        }
                        else{
                            
                            LoanBoardingRequestWrapper.PersonalDiscussion perDis=new LoanBoardingRequestWrapper.PersonalDiscussion();
                            
                            
                            perDis.analysisOfFinancials =''; 
                            perDis.currentObligationDetails =''; 
                            perDis.anyMisleadingInformation =''; 
                            perDis.foir = '';//String.valueOf(eachBre.Actual_FOIR__c) !=null ?String.valueOf(eachBre.Actual_FOIR__c): ''; 
                            perDis.grossMonthlyIncome ='';  //blank
                            perDis.empDetailNatureofBusi =''; 
                            perDis.assetOwned =''; 
                            perDis.mainClients =''; 
                            perDis.resiDetails =''; 
                            perDis.interviewerDecision =''; 
                            perDis.verificationMatch =''; 
                            perDis.interviewerComments =''; 
                            perDis.natureOfFinancialTransaction =''; 
                            perDis.nameOfInterviewer =''; //8
                            perDis.crossSellRemarks =''; 
                            perDis.pfiRemark =''; 
                            perDis.shareHoldingPattern =''; 
                            perDis.propertyDetails =''; 
                            perDis.additionalDocumentCollected =''; 
                            perDis.dateOfMeeting =''; 
                            perDis.futureGrowthPlan =''; 
                            perDis.anyOthBusi =''; 
                            perDis.pfiDoneBy =''; 
                            perDis.placeOfMeeting =''; 
                            perDis.personContacted =''; 
                            perDis.mainSuppliers =''; 
                            perDis.pfiDone =''; 
                            perDis.mainProducts =''; 
                            perDis.aggregateExposure ='';//blank 
                            perDis.customerProfile =''; 
                            perDis.staffStrength =''; 
                            perDis.grossMonthlyPayable =''; //blank
                            perDis.empNo =''; 
                            perDis.bankingHabit =''; 
                            perDis.timeFrame =''; 
                            perDis.decisionDate =''; 
                            perDis.levelOfActivity =''; 
                            perDis.offDetails =''; 
                            perDis.majorVariationsInFinancial =''; 
                            perDis.clientMarketRef =''; 
                            perDis.crossSell =''; 
                            perDis.designation =''; 
                            perDis.emiComfortableWith =''; 
                            perDis.detailOfEndUseOfFunds =''; 
                            listPerDiscussion.add(perDis);
                            
                        }
                        
                        //personalDiscussion end blank
                        
                        
                        //InitialMoneyDepositDetails start
                        List<LoanBoardingRequestWrapper.InitialMoneyDepositDetails> listIniMoneyDetails =new List<LoanBoardingRequestWrapper.InitialMoneyDepositDetails>();
                        
                        List<ApplIMD__c> listForImdDetails= appImdByLoanApp.get(loanApplnIds[0]);
                        
                        if(listForImdDetails !=null && !listForImdDetails.isEMpty())
                        {
                            for(ApplIMD__c eachAppImd1 : listForImdDetails )
                            {
                                LoanBoardingRequestWrapper.InitialMoneyDepositDetails iniMoneyDepDetail=new LoanBoardingRequestWrapper.InitialMoneyDepositDetails();    
                                
                                iniMoneyDepDetail.imdStatus =''; 
                                iniMoneyDepDetail.imdCity = eachAppImd1.City__c !=null ? String.valueOf(eachAppImd1.City__c) : ''; 
                                iniMoneyDepDetail.imdChequeDate =''; 
                                iniMoneyDepDetail.imdChqNo =''; 
                                iniMoneyDepDetail.imdCurrency =''; //blank
                                iniMoneyDepDetail.imdPaidOn =''; //blank
                                iniMoneyDepDetail.imdDealingBank =''; 
                                iniMoneyDepDetail.imdFTMode =''; //blank
                                iniMoneyDepDetail.imdHostAccNo ='';//blank 
                                iniMoneyDepDetail.imdAccNo =''; //blank
                                iniMoneyDepDetail.imdIncomeTaxIdType ='';//blank 
                                iniMoneyDepDetail.imdHoldAccBankName =''; //blank
                                iniMoneyDepDetail.imdHoldUnhold =''; //blank
                                iniMoneyDepDetail.imdHoldAccountNo =''; //blank
                                iniMoneyDepDetail.imdPaymentMode =''; //blank
                                iniMoneyDepDetail.imdCmsCode =''; //blank
                                iniMoneyDepDetail.imdIncomeTaxIdNo =''; //blank
                                iniMoneyDepDetail.imdTdsByCustomer =''; //blank
                                iniMoneyDepDetail.ifscCode =''; //blank
                                iniMoneyDepDetail.imdInFavourOf =''; 
                                iniMoneyDepDetail.imdDepositSlipNo =''; //blank
                                iniMoneyDepDetail.imdCMSNumeric =''; //blank
                                iniMoneyDepDetail.imdSolId =''; //blank
                                iniMoneyDepDetail.imdUTRNo =''; //blank
                                iniMoneyDepDetail.imdTranDae =''; //blank
                                iniMoneyDepDetail.imdReason =''; //blank
                                iniMoneyDepDetail.imdCustomerId =''; //blank
                                iniMoneyDepDetail.imdChequeId =''; 
                                iniMoneyDepDetail.imdMicrCode =''; //blank
                                iniMoneyDepDetail.imdReceiptNo =''; //blank
                                iniMoneyDepDetail.imdDepositSlipAmt =''; //blank
                                iniMoneyDepDetail.imdHoldAccBankBranch =''; //blank
                                iniMoneyDepDetail.imdAmount = eachAppImd1.IMDAmt__c !=null ? String.valueOf(eachAppImd1.IMDAmt__c) : '' ; // eachAppImd1.IMDAmt__c ? eachAppImd1.IMDAmt__c : '' ; 
                                iniMoneyDepDetail.imdBankBranch =''; //blank
                                iniMoneyDepDetail.imdDepositSlipType =''; //blank
                                iniMoneyDepDetail.imdDrawnOn =''; 
                                iniMoneyDepDetail.imdHoldAccount =''; //blank
                                
                                listIniMoneyDetails.add(iniMoneyDepDetail);
                            }
                            
                        }
                        //InitialMoneyDepositDetails not completed end 
                        
                        
                        //notepadDetails blank
                        List<LoanBoardingRequestWrapper.NotepadDetails> listNoteDetails=new List<LoanBoardingRequestWrapper.NotepadDetails>();
                        LoanBoardingRequestWrapper.NotepadDetails notPadDetail=new LoanBoardingRequestWrapper.NotepadDetails();
                        notPadDetail.noteUser =''; 
                        notPadDetail.noteDate =''; 
                        notPadDetail.noteDetails =''; 
                        notPadDetail.noteCode =''; 
                        notPadDetail.noteReferenceDate =''; 
                        listNoteDetails.add(notPadDetail);
                        //notepadDetails blank
                        
                        //FivCheckList start blank
                        List<LoanBoardingRequestWrapper.FivCheckList> listFivChk =new List<LoanBoardingRequestWrapper.FivCheckList>();
                        LoanBoardingRequestWrapper.FivCheckList fivChkList=new LoanBoardingRequestWrapper.FivCheckList();
                        fivChkList.answer =''; 
                        fivChkList.quesNumber =''; 
                        fivChkList.quesDesc =''; 
                        listFivChk.add(fivChkList);
                        //FivCheckList End blank
                        
                        //FdDetails start Blank
                        List<LoanBoardingRequestWrapper.FdDetails> listFddetails=new List<LoanBoardingRequestWrapper.FdDetails>();
                        LoanBoardingRequestWrapper.FdDetails fdDetail=new LoanBoardingRequestWrapper.FdDetails();
                        fdDetail.finFdBranch =''; 
                        fdDetail.finFdRate =''; 
                        fdDetail.finFdAmount =''; 
                        fdDetail.finFdMaturityDate =''; 
                        fdDetail.finFdNo =''; 
                        fdDetail.finFdBankName =''; 
                        listFddetails.add(fdDetail);
                        //FdDetails start Blank
                        
                        
                        //bussinessVerification start blank
                        LoanBoardingRequestWrapper.BussinessVerification busVer=new LoanBoardingRequestWrapper.BussinessVerification();
                        busVer.productsBrandsCarried =''; 
                        busVer.businessName =''; 
                        busVer.managementAge =''; 
                        busVer.signatoryJobTitle =''; 
                        busVer.registered =''; 
                        busVer.salesFigure =''; 
                        busVer.warehouseLoaction =''; 
                        busVer.negative =''; 
                        busVer.natureOfBusi =''; 
                        busVer.managementPosition =''; 
                        busVer.noOfRegularEmp =''; 
                        busVer.busiType =''; 
                        busVer.signatoryName =''; 
                        busVer.businessAddress =''; 
                        busVer.phoneExt =''; 
                        busVer.managementName =''; 
                        busVer.creditReferencesName =''; 
                        busVer.citizenship =''; 
                        busVer.operatingExpenses =''; 
                        busVer.lengthOfBusinessExis =''; 
                        busVer.percentOwnership =''; 
                        busVer.applicantName =''; 
                        busVer.positive =''; 
                        busVer.rentMortAmt =''; 
                        busVer.branches =''; 
                        busVer.warehouse =''; 
                        busVer.creditReferencesAddress =''; 
                        busVer.creditReferencePhone =''; 
                        busVer.noOfCustomerDay =''; 
                        busVer.registeredName =''; 
                        busVer.othPropOwned =''; 
                        busVer.location =''; 
                        busVer.businessPhone =''; 
                        busVer.businessPremisesOwner =''; 
                        busVer.age =''; 
                        busVer.remarks =''; 
                        //bussinessVerification End blank
                        
                        
                        
                        //gradedRepaymentDetails start blank
                        List<LoanBoardingRequestWrapper.GradedRepaymentDetails> listGradedPay =new List<LoanBoardingRequestWrapper.GradedRepaymentDetails>();
                        LoanBoardingRequestWrapper.GradedRepaymentDetails grdRepayDetails=new LoanBoardingRequestWrapper.GradedRepaymentDetails();
                        grdRepayDetails.slabRecoveryPtg =''; 
                        grdRepayDetails.slabSequence =''; 
                        grdRepayDetails.slabInstlTo =''; 
                        grdRepayDetails.slabEmi =''; 
                        grdRepayDetails.slabInstlFrom =''; 
                        listGradedPay.add(grdRepayDetails);
                        //gradedRepaymentDetails end blank
                        List<Insurance__c> listIns = appInsuranceByLoanApp.get(loanApplnIds[0]); 
                        
                        LoanBoardingRequestWrapper.InsuranceDetails insDetail=new LoanBoardingRequestWrapper.InsuranceDetails();
                        if(listIns!=null && !listIns.isEmpty())
                        {
                            
                            insDetail.boundariesFront ='';//Blank 
                            insDetail.tctCCTNo =''; //Policy No not caturing
                            insDetail.appraisedValue =String.valueOf(listIns[0].SumAmount__c) !=null ? String.valueOf(listIns[0].SumAmount__c)  :''; 
                            insDetail.insEndDate =''; //Expiry date   ==== Not   captured
                            insDetail.insPremYr2 = listIns[0].PremiumAmount__c !=null ? String.valueOf(listIns[0].PremiumAmount__c) :''; 
                            insDetail.remarksOnCoverage =''; //Blank
                            insDetail.insPremYr1 =listIns[0].PremiumAmount__c !=null ? String.valueOf(listIns[0].PremiumAmount__c) :'';  
                            insDetail.buildingDesc =''; //Blank
                            insDetail.amtInsuredContents =''; //Blank
                            insDetail.amtInsImp =''; //Blank
                            insDetail.totalInsPremium =listIns[0].PremiumAmount__c !=null ? String.valueOf(listIns[0].PremiumAmount__c) :''; 
                            insDetail.insurancePolicyType =''; //Blank
                            insDetail.amtInsuredStocks =''; //Blank
                            insDetail.mortgagee =''; //Blank
                            insDetail.others =''; //Blank
                            insDetail.boundariesRear ='';//Blank 
                            insDetail.insuranceRequired =''; //Blank
                            insDetail.insCompName = '';//listIns[0].InsProvider__r.Name !=null?listIns[0].InsProvider__r.Name:'';  //non mandatory
                            insDetail.amtInsured = '';//Coverage Amount  ==== Not   captured
                            insDetail.amtInsuredOff =''; //Blank
                            insDetail.noOfCollaterals =''; //No of Property  ==== Not   captured
                            insDetail.amtInsuredBuilding =''; //Blank
                            insDetail.propDesc =''; 
                            insDetail.insPolNumber = listIns[0].InsProvider__r.MPno__c !=null ?listIns[0].InsProvider__r.MPno__c:''; 
                            insDetail.locationOfRisk ='0';//Hardcoded as given in sample json file 
                            insDetail.mailingAddress =''; 
                            insDetail.insCoverageType =''; 
                            insDetail.boundariesright =''; //Blank
                            insDetail.insStartDate =''; 
                            insDetail.boundariesLeft =''; //Blank
                            insDetail.premiumRemarks =''; //Blank
                            
                        }
                        //InsuranceDetails end
                        
                        
                        //ApplicantCustomDetail start blank
                        LoanBoardingRequestWrapper.ApplicantCustomDetail appCusDetail=new LoanBoardingRequestWrapper.ApplicantCustomDetail();
                        appCusDetail.customFieldCust1 ='NPM';//hardcoded
                        // ApplicantCustomDetail end blank
                        
                        
                        
                        LoanBoardingRequestWrapper.CrossCollateral colDetails=new LoanBoardingRequestWrapper.CrossCollateral();
                        if(loanAppRecordsMap.get(intMsg.RefId__c) !=null)
                        {
                            colDetails.applicationId= String.valueOf(loanAppRecordsMap.get(intMsg.RefId__c).FinnoneAppid__c) !=null ? String.valueOf(loanAppRecordsMap.get(intMsg.RefId__c).FinnoneAppid__c):'';
                        }
                        else{
                            colDetails.applicationId='';
                        }
                        
                        
                        
                        //CollateralDetails blank start //dependent on BRE
                        List<LoanBoardingRequestWrapper.CollateralDetails> listColDetails=new List<LoanBoardingRequestWrapper.CollateralDetails>();
                        //CollateralDetails blank end
                        
                        
                        List<LoanBoardingRequestWrapper.PropertyDetails> listProp=new List<LoanBoardingRequestWrapper.PropertyDetails>();
                        List<ApplAsset__c> listAppAssestforAmount1 = appAssetMapByLoanApp.get(loanApplnIds[0]); 
                        
                        if(listAppAssestforAmount1 !=null && !listAppAssestforAmount1.isEmpty()){
                            for(ApplAsset__c assetObj : listAppAssestforAmount1){
                                
                                
                                LocMstr__c locMstrObj = mapLocMas.get(assetObj.City__c);  
                                
                                LoanBoardingRequestWrapper.PropertyDetails propdetails=new LoanBoardingRequestWrapper.PropertyDetails();
                                propdetails.propPinCode =String.valueOf(assetObj.Pin_Code__c) !=null? String.valueOf(assetObj.Pin_Code__c):   '';  
                                propdetails.areaForPlot =String.valueOf(assetObj.Land_Area__c) !=null? String.valueOf(assetObj.Land_Area__c):   '';   
                                propdetails.technicalVerification =''; 
                                propdetails.appraisedPropertyValue =String.valueOf(assetObj.Total_Prop_Cost__c) !=null? String.valueOf(assetObj.Total_Prop_Cost__c):   ''; 
                                propdetails.developerBuilder =String.valueOf(assetObj.Builder_ID__c) !=null? String.valueOf(assetObj.Builder_ID__c):   ''; 
                                propdetails.sellerAddressTwo =''; //blank
                                propdetails.typeofPurchase =String.valueOf(assetObj.PropType__c) !=null? String.valueOf(assetObj.PropType__c):   '';  
                                propdetails.propertyHeldIn =''; //Blank
                                propdetails.verifyBy =''; //Blank
                                propdetails.rentFlag =''; //Blank
                                propdetails.collateralGradeClassification =''; //Blank
                                propdetails.lienDetails =listRepayDetails1; 
                                propdetails.approved =String.valueOf(assetObj.Is_it_an_APF__c) !=null? String.valueOf(assetObj.Is_it_an_APF__c):   '';   
                                propdetails.blockNo ='';// non mandatory String.valueOf(assetObj.Is_it_an_APF__c) !=null? String.valueOf(assetObj.Is_it_an_APF__c):   '';   
                                propdetails.totalAmountFinanced =String.valueOf(assetObj.LoanAppln__r.TotalLoanAmtInclInsurance__c) !=null? String.valueOf(assetObj.LoanAppln__r.TotalLoanAmtInclInsurance__c):   '';     
                                propdetails.propState =locMstrObj !=null ? String.valueOf(locMstrObj.StateId__c) !=null ? String.valueOf(locMstrObj.StateId__c) :'':'';
                                propdetails.wingName =''; //Blank
                                propdetails.propertyValue =String.valueOf(assetObj.Total_Prop_Cost__c) !=null? String.valueOf(assetObj.Total_Prop_Cost__c):   ''; 
                                propdetails.sellerAddressOne =''; //Blank
                                propdetails.buildingName =''; //Blank
                                propdetails.personalInsurance =''; //Blank
                                propdetails.guaranteeTenure =''; //Blank
                                propdetails.sellerPhoneNo =''; //Blank
                                propdetails.soleOwnerFlag =''; //Blank
                                propdetails.additionalProperties =rpDet; //Blank
                                propdetails.projectName =''; //Blank
                                propdetails.titleClearFlag =''; //Blank
                                propdetails.contractor =''; //Blank
                                propdetails.presentRegisteredOwner =assetObj.Prop_Owners__c !=null ?  assetObj.Prop_Owners__c : ''; 
                                propdetails.guaranteeFlag =''; //Blank
                                propdetails.ageOfProperty = String.valueOf(assetObj.Approx_Age_of_Prop__c)!=null ? String.valueOf(assetObj.Approx_Age_of_Prop__c): '';  
                                propdetails.areaForImprovements =''; //Blank
                                propdetails.builderClassificationType =''; //Blank
                                propdetails.architect =''; //Blank
                                propdetails.sellerName =''; //Blank
                                propdetails.propAddress3 =''; 
                                propdetails.propAddress1 =assetObj.AddrLn1__c !=null ?assetObj.AddrLn1__c: ''; 
                                propdetails.appraiser2Date = ''; 
                                propdetails.propAddress2 =assetObj.AddrLn2__c !=null ?assetObj.AddrLn2__c: ''; 
                                propdetails.propCity =locMstrObj !=null ? String.valueOf(locMstrObj.CityId__c) !=null ? String.valueOf(locMstrObj.CityId__c) :'': '';
                                propdetails.appraiser1Date =''; 
                                propdetails.lotNo =''; //Blank
                                propdetails.areasSqm =String.valueOf(assetObj.Property_Carpet_area_Sq_Ft__c)!=null ? String.valueOf(assetObj.Property_Carpet_area_Sq_Ft__c):''; 
                                propdetails.guaranteeInFavour =''; //Blank
                                propdetails.tobeRegisteredWithName =''; //Blank
                                propdetails.tranchDetails =listRepayDetails1; //Blank
                                propdetails.propertyInsurance =''; //Blank
                                propdetails.mortageDetails =liMo; //Blank
                                propdetails.constructionPurchase =listRepayDetails1; //Blank
                                propdetails.guaranteeAmount =''; //Blank
                                propdetails.areaForImprovement =''; //Blank
                                propdetails.insuranceInsuredFlag =''; //Blank
                                propdetails.propValuationType =''; //Blank
                                propdetails.sellingPriceFairMarketValue =''; //Blank
                                propdetails.guaranteeEndDate =''; //Blank
                                propdetails.propCountry ='1'; 
                                propdetails.propTypeNew =''; //check this 
                                propdetails.propertyAddressLine1 =assetObj.AddrLn1__c !=null ?assetObj.AddrLn1__c: '';  
                                propdetails.propertyAddressLine2 =assetObj.AddrLn2__c !=null ?assetObj.AddrLn2__c: ''; 
                                propdetails.nearestLandmark = assetObj.Landmark__c!=null ? assetObj.Landmark__c: ''; 
                                propdetails.collateralUsage =''; //Blank
                                propdetails.propertyDesc =assetObj.PropSubTypeDesc__c !=null ?assetObj.PropSubTypeDesc__c:''; 
                                propdetails.fundsDetail =listRepayDetails1; //blank
                                propdetails.residualAgeOfProperty =String.valueOf(assetObj.Resi_Age__c)	 !=null ?String.valueOf(assetObj.Resi_Age__c):''; 
                                propdetails.appraisalValue1 =''; 
                                propdetails.propertyCostFinanced =String.valueOf(String.valueOf(loanAppRecordsMap.get(loanApplnIds[0]).TotalLoanAmtInclInsurance__c)) !=null ?String.valueOf(loanAppRecordsMap.get(loanApplnIds[0]).TotalLoanAmtInclInsurance__c) : ''; 
                                propdetails.appraiser2 =''; //TBD
                                propdetails.appraisalValue2 =''; //TBD
                                propdetails.TCTCCTNo =''; //Blank
                                propdetails.propType =''; //TBD
                                propdetails.appraiser1 =''; //TBD
                                propdetails.propertyUsage = 'SELFOC'; // Hardcoded assetObj.Property_Usage__c !=null ? assetObj.Property_Usage__c: ''; 
                                
                                listProp.add(propdetails);
                                
                                //CollateralDetails start
                                LoanBoardingRequestWrapper.CollateralDetails colDetail=new LoanBoardingRequestWrapper.CollateralDetails();
                                colDetail.collLodgement =''; //Blank
                                colDetail.appraisedValue =String.valueOf(assetObj.Total_Prop_Cost__c) !=null? String.valueOf(assetObj.Total_Prop_Cost__c):   '';  
                                colDetail.collateralCategory ='H';// hardcoded House=> H   land=>L hardcode as H
                                colDetail.collType ='HOME'; //hardcode as HOME
                                colDetail.assetLife =''; //Blank
                                colDetail.assetType =String.valueOf(assetObj.PropType__c) !=null? String.valueOf(assetObj.PropType__c):   '';  
                                colDetail.assetAge =String.valueOf(assetObj.Approx_Age_of_Prop__c) !=null ?  String.valueOf(assetObj.Approx_Age_of_Prop__c): ''; 
                                colDetail.collLienTitle =''; //Blank
                                colDetail.collateralUsage =''; //Blank
                                colDetail.regulatoryClearence =''; //Blank
                                colDetail.collDesc =''; //TBD  
                                colDetail.collInsurance =''; //Blank
                                colDetail.collateralValue =String.valueOf(assetObj.Total_Prop_Cost__c) !=null? String.valueOf(assetObj.Total_Prop_Cost__c):   '';  
                                colDetail.depreciationRate =''; //Blank
                                colDetail.collCross =''; //Blank
                                
                                
                                listColDetails.add(colDetail);
                                
                            }
                            
                        }
                        
                        List<Applicant__c> applicantList =loanAppMap.get(intMsg.RefId__c);
                        LoanBoardingRequestWrapper.ConfirmationLog conLog=new LoanBoardingRequestWrapper.ConfirmationLog();
                        
                        
                        
                        
                        
                        LoanBoardingRequestWrapper.GSTInfoDetails gstInDetails =new LoanBoardingRequestWrapper.GSTInfoDetails();  
                        List<LoanBoardingRequestWrapper.ApplicantDetails> listAppDetl =new List<LoanBoardingRequestWrapper.ApplicantDetails>();
                        if(applicantList!=null  && !applicantList.isEmpty()){ 
                            for(Applicant__c app : applicantList){
                                
                                
                                
                                //confirmationLog start blank
                                
                                
                                if(priAppId == app.ID){
                                    conLog.applicantName =app.ApplType__c =='P' ? app.FullName__c : '';
                                    conLog.phoneUsed =''; 
                                    conLog.nameOfAgency =''; 
                                    conLog.citizenship ='17'; //hardcoded 
                                    conLog.remark =''; 
                                    conLog.positive =''; 
                                    conLog.callLogCounter =''; 
                                    conLog.negative =''; 
                                    conLog.callStatus =''; 
                                    conLog.nameOfInformant =''; 
                                    conLog.position =''; 
                                    conLog.relationship =''; 
                                    conLog.age =''; 
                                    conLog.remarks =''; 
                                }
                                
                                
                                
                                //confirmationLog end blank
                                
                                //DocCollectionDetails start
                                
                                List<LoanBoardingRequestWrapper.DocCollectionDetails> listDocdetails =new List<LoanBoardingRequestWrapper.DocCollectionDetails>();
                                //DocCollectionDetails end
                                
                                //GSTInfoDetails start 
                                
                                ApplicantEmployment__c appEm=new ApplicantEmployment__c();
                                
                                if(appEmpMap.get(app.id) !=null  && !appEmpMap.get(app.id).isEmpty())
                                {
                                    appEm=appEmpMap.get(app.id)[0];
                                }
                                
                                LoanBoardingRequestWrapper.WorkDetailsSalaried wrkDetailSal=new LoanBoardingRequestWrapper.WorkDetailsSalaried();
                                if(appEm !=null)
                                {
                                    
                                    //WorkDetailsSalaried impl start
                                    
                                    wrkDetailSal.emplyementType =''; //Blank
                                    wrkDetailSal.shareHolding =''; //Blank
                                    wrkDetailSal.labourIdExpiryDate =''; //Blank
                                    wrkDetailSal.pranNo =''; //Blank
                                    wrkDetailSal.associatedSinceInception =''; //Blank
                                    wrkDetailSal.indutsryWork = '';//hardcoded appEm.IndustryType__r.Name !=null ?appEm.IndustryType__r.Name:''; 
                                    wrkDetailSal.mcaNumber =''; //Blank
                                    wrkDetailSal.uanNumber =''; //Not capturing
                                    wrkDetailSal.businessName =appEm.EmployerName__r.Name !=null ?appEm.EmployerName__r.Name:''; 
                                    wrkDetailSal.websiteAddress =''; 
                                    wrkDetailSal.employerName = appEm.EmployerName__r.Name !=null ? appEm.EmployerName__r.Name :''; 
                                    wrkDetailSal.prevEmployerAddress =''; //Blank
                                    wrkDetailSal.industryEmployment =''; //check this which one should take 
                                    wrkDetailSal.employmentStatus =''; //Blank
                                    wrkDetailSal.employeeNo =''; //Blank
                                    wrkDetailSal.yearPreviousJobMon ='';//Blank 
                                    wrkDetailSal.lengthOfBusiness =String.valueOf(appEm.CurrentBusinessVintage_Months__c)!=null?String.valueOf(appEm.CurrentBusinessVintage_Months__c):''; //check this
                                    wrkDetailSal.yearPreviousJobYr =''; //blank
                                    wrkDetailSal.subIndEmplyment = '';//appEm.SubIndustry__r.SubIndustryID__c !=null ?appEm.SubIndustry__r.SubIndustryID__c :'';//appEm.SubIndustry__r.Name!=null?appEm.SubIndustry__r.Name:''; hardcoded
                                    wrkDetailSal.employerRanking =''; 
                                    wrkDetailSal.totalWorkExp =String.valueOf(appEm.TotalWorkExperience_Months__c) !=null?String.valueOf(appEm.TotalWorkExperience_Months__c):''; 
                                    wrkDetailSal.workPermitNo =''; 
                                    wrkDetailSal.tradeLicenseNo =''; 
                                    wrkDetailSal.prevEmployerPhoneNo =''; 
                                    wrkDetailSal.natureOfBusinessSelf =''; 
                                    wrkDetailSal.natureOfBusinessWork =''; 
                                    wrkDetailSal.department =''; 
                                    wrkDetailSal.prevEmployerName =''; 
                                    wrkDetailSal.subIndustryWork =''; 
                                    wrkDetailSal.pfNumber =''; 
                                    wrkDetailSal.othersWork =''; 
                                    wrkDetailSal.yearPresentJob =String.valueOf(appEm.WorkingWithCurrentEmployer_Years__c)!=null?String.valueOf(appEm.WorkingWithCurrentEmployer_Years__c):''; 
                                    wrkDetailSal.tradeLicenseExpiryDate =''; 
                                    wrkDetailSal.noOfpartners =''; 
                                    wrkDetailSal.nameOfPOAHolder =''; 
                                    wrkDetailSal.typeOfOwnership =''; 
                                    wrkDetailSal.nonEarning =''; 
                                    wrkDetailSal.dateOfInceptionWork =''; 
                                    wrkDetailSal.designation =appEm.DesignationValues__c !=null?appEm.DesignationValues__c:''; 
                                    wrkDetailSal.labourIdNo =''; 
                                    wrkDetailSal.employerRating =''; 
                                    wrkDetailSal.typeOfOrg =appEm.TypeOfOrganisation__c!=null?appEm.TypeOfOrganisation__c:'';
                                    
                                    if(appEm.GST_Registered__c=='Yes')
                                    {
                                        gstInDetails.gstReqd ='Y'; 
                                        gstInDetails.gstCustomerName =ucidPriApp !=null ? ucidPriApp :'';  
                                        gstInDetails.gstCountry ='1'; //OK
                                        gstInDetails.gstAddress = finalGstObj!=null? finalGstObj.RegisteredAddress_GST__c :'';//  appGstMap.get(app.ID)[0].RegisteredAddress_GST__c!=null ? appGstMap.get(app.ID)[0].RegisteredAddress_GST__c:'':''; 
                                        gstInDetails.gstAddressLine3 =''; //TBD
                                        gstInDetails.gstAddressLine2 =finalGstObj !=null ? finalGstObj.RegisteredAddress_GST__c :''; //''; //TBD put A spit Address
                                        gstInDetails.gstNumber = finalGstObj!=null ? String.valueOf(finalGstObj.GSTIN__c) :''; //(appGstMap.get(app.ID)!=null && appGstMap.get(app.ID).size() >0) ?  appGstMap.get(app.ID)[0].GSTIN__c  !=null  ? appGstMap.get(app.ID)[0].GSTIN__c :'' :'';  // gstin field
                                        gstInDetails.gstAddressLine1 =finalGstObj !=null ? finalGstObj.RegisteredAddress_GST__c :''; 
                                        gstInDetails.gstCity =''; //TBD
                                        gstInDetails.gstState =''; //TBD
                                        gstInDetails.gstPinCode =''; //TBD
                                        gstInDetails.gstApplicantType ='C'; //OK
                                        gstInDetails.gstCustomerType =app.ApplType__c !=null ? app.ApplType__c : ''; //applicant type
                                        
                                    }  
                                    else{
                                        gstInDetails.gstReqd ='N'; 
                                        gstInDetails.gstCustomerName ='';
                                        gstInDetails.gstCountry =''; 
                                        gstInDetails.gstAddress =''; 
                                        gstInDetails.gstAddressLine3 =''; 
                                        gstInDetails.gstAddressLine2 =''; 
                                        gstInDetails.gstNumber =''; 
                                        gstInDetails.gstAddressLine1 =''; 
                                        gstInDetails.gstCity =''; 
                                        gstInDetails.gstState =''; 
                                        gstInDetails.gstPinCode =''; 
                                        gstInDetails.gstApplicantType =''; 
                                        gstInDetails.gstCustomerType ='';
                                    }  
                                }
                                else{
                                    wrkDetailSal.emplyementType =''; //Blank
                                    wrkDetailSal.shareHolding =''; //Blank
                                    wrkDetailSal.labourIdExpiryDate =''; //Blank
                                    wrkDetailSal.pranNo =''; //Blank
                                    wrkDetailSal.associatedSinceInception =''; //Blank
                                    wrkDetailSal.indutsryWork =''; 
                                    wrkDetailSal.mcaNumber =''; //Blank
                                    wrkDetailSal.uanNumber =''; //Not capturing
                                    wrkDetailSal.businessName =''; 
                                    wrkDetailSal.websiteAddress =''; 
                                    wrkDetailSal.employerName = ''; 
                                    wrkDetailSal.prevEmployerAddress =''; //Blank
                                    wrkDetailSal.industryEmployment =''; //check this which one should take 
                                    wrkDetailSal.employmentStatus =''; //Blank
                                    wrkDetailSal.employeeNo =''; //Blank
                                    wrkDetailSal.yearPreviousJobMon ='';//Blank 
                                    wrkDetailSal.lengthOfBusiness =''; //blank
                                    wrkDetailSal.subIndEmplyment =''; 
                                    wrkDetailSal.employerRanking =''; 
                                    wrkDetailSal.totalWorkExp =''; 
                                    wrkDetailSal.workPermitNo =''; 
                                    wrkDetailSal.tradeLicenseNo =''; 
                                    wrkDetailSal.prevEmployerPhoneNo =''; 
                                    wrkDetailSal.natureOfBusinessSelf =''; 
                                    wrkDetailSal.natureOfBusinessWork =''; 
                                    wrkDetailSal.department =''; 
                                    wrkDetailSal.prevEmployerName =''; 
                                    wrkDetailSal.subIndustryWork =''; 
                                    wrkDetailSal.pfNumber =''; 
                                    wrkDetailSal.othersWork =''; 
                                    wrkDetailSal.yearPresentJob =''; 
                                    wrkDetailSal.tradeLicenseExpiryDate =''; 
                                    wrkDetailSal.noOfpartners =''; 
                                    wrkDetailSal.nameOfPOAHolder =''; 
                                    wrkDetailSal.typeOfOwnership =''; 
                                    wrkDetailSal.nonEarning =''; 
                                    wrkDetailSal.dateOfInceptionWork =''; 
                                    wrkDetailSal.designation =''; 
                                    wrkDetailSal.labourIdNo =''; 
                                    wrkDetailSal.employerRating =''; 
                                    wrkDetailSal.typeOfOrg ='';
                                }
                                List<LoanBoardingRequestWrapper.BankDetails> listBankDls =new List<LoanBoardingRequestWrapper.BankDetails>();
                                
                                if(appBankingMap.get(app.ID) !=null && !appBankingMap.get(app.ID).isEmpty())
                                {            
                                    for(ApplBanking__c eachAppBankObj : appBankingMap.get(app.ID))
                                        
                                    {
                                        LoanBoardingRequestWrapper.BankDetails bankDetailObj=new LoanBoardingRequestWrapper.BankDetails();
                                        
                                        BankMstr__c eachBankObj= bankMstrMap.get(eachAppBankObj.BankName__c);
                                        System.debug('eachBankObj::'+eachBankObj);
                                        //MICRCodeMstr__c micrObjForBranch = micrMstrMap.get(eachAppBankObj.Bank_Branch__c);
                                        bankDetailObj.finBankMaxBalance =''; 
                                        bankDetailObj.finBankAccountNo =eachAppBankObj.AC_No__c!=null ? eachAppBankObj.AC_No__c : ''; 
                                        bankDetailObj.finBankAccType =eachAppBankObj.AccountType__c!=null ? eachAppBankObj.AccountType__c : ''; 
                                        bankDetailObj.finBankMinBalance =''; 
                                        bankDetailObj.finBankAvgBalance =''; 
                                        bankDetailObj.finBankStmtCollected =''; 
                                        bankDetailObj.finNoOfYearsHeld =''; 
                                        bankDetailObj.finNoOfOutwardChqReturns =  String.valueOf(eachAppBankObj.TotalOutwardReturnCount__c) !=null ?String.valueOf(eachAppBankObj.TotalOutwardReturnCount__c):''; 
                                        bankDetailObj.finBankRemarks =''; 
                                        bankDetailObj.finBankBranch = eachAppBankObj.Bank_Branch__c!=null?eachAppBankObj.Bank_Branch__c:''; //check this
                                        if(eachBankObj !=null){
                                            bankDetailObj.finBankName = eachBankObj.BankId__c !=null  ? eachBankObj.BankId__c : '';  // (micrObjForBranch !=null) ? micrObjForBranch.BanckBrchId__c !=null ? String.valueOf(micrObjForBranch.BanckBrchId__c) :'':''; //  eachAppBankObj.BankName__c!=null?eachAppBankObj.BankName__c:''; 
                                        }else{
                                            bankDetailObj.finBankName = '';
                                        }
                                        
                                        bankDetailObj.finNoOfInwardChqReturns = String.valueOf(eachAppBankObj.TotalInwardReturnCount__c)!=null ? String.valueOf(eachAppBankObj.TotalInwardReturnCount__c): '';
                                        
                                        //adding values
                                        listBankDls.add(bankDetailObj);
                                        
                                    }
                                    
                                }
                                //PropertyDetails start
                                
                                List<LoanBoardingRequestWrapper.AddressDetails> listAddDetails=new List<LoanBoardingRequestWrapper.AddressDetails>();
                                List<ApplAddr__c> listOfAddsAppl =appAddMap.get(app.Id);
                                
                                if(listOfAddsAppl !=null && !listOfAddsAppl.isEmpty())
                                {
                                    
                                    for(ApplAddr__c eachAppAddr: listOfAddsAppl)
                                    {
                                        
                                        LocMstr__c locdata = mapLocMas.get(eachAppAddr.City__c);
                                        //AddressDetails(Applicant) start 
                                        LoanBoardingRequestWrapper.AddressDetails addDetails=new LoanBoardingRequestWrapper.AddressDetails();
                                        //addDetails.country =String.valueOf(eachAppAddr.Country__c)!=null?String.valueOf(eachAppAddr.Country__c): '';  
                                        addDetails.country ='1';//Hardcoded
                                        addDetails.extension =''; 
                                        addDetails.city = (locdata != null) ? String.valueOf(locdata.CityId__c) !=null ? String.valueOf(locdata.CityId__c) :'':''; 
                                        
                                        addDetails.smsFlag =''; 
                                        addDetails.phone2 =''; 
                                        addDetails.emailId =String.valueOf(app.EmailId__c)!=null?String.valueOf(app.EmailId__c):''; 
                                        addDetails.phone1 =''; 
                                        addDetails.poBox =''; 
                                        addDetails.propertyStatus =  eachAppAddr.OwnType__c!=null ?eachAppAddr.OwnType__c:''; 
                                        addDetails.inactive =''; 
                                        addDetails.addressLine1 =eachAppAddr.AddrLine1__c!=null?eachAppAddr.AddrLine1__c:''; 
                                        addDetails.addressLine2 =eachAppAddr.AddrLine2__c!=null?eachAppAddr.AddrLine2__c:''; 
                                        addDetails.addressLine3 =''; //TBD
                                        addDetails.state = (locdata !=null)? String.valueOf(locdata.StateId__c) !=null ?String.valueOf(locdata.StateId__c) :'' :'';
                                        addDetails.fax =''; 
                                        addDetails.landmark =eachAppAddr.Landmark__c!=null?eachAppAddr.Landmark__c:''; 
                                        if(eachAppAddr.MailAddr__c){
                                            addDetails.mailingAddressFlag ='Y';
                                        }else{
                                            addDetails.mailingAddressFlag ='N';
                                        }
                                        addDetails.inactiveAddress =''; 
                                        addDetails.copyaddress =''; 
                                        addDetails.stayDurationCityYear =''; 
                                        addDetails.smsMobileSecondary =''; 
                                        addDetails.addressType = masterDataMap.get('Address Type') !=null ? masterDataMap.get('Address Type').get(eachAppAddr.AddrTyp__c) !=null ?masterDataMap.get('Address Type').get(eachAppAddr.AddrTyp__c):'':''; // 'OFFICE';//hardcoded  eachAppAddr.AddrTyp__c!=null?eachAppAddr.AddrTyp__c:''; 
                                        addDetails.mobile =app.MobNumber__c!=null?app.MobNumber__c:''; 
                                        addDetails.stayDurationCityMon ='' ; 
                                        addDetails.stayDurationCurrAddressYr = String.valueOf(eachAppAddr.AddrStability__c) !=null ?String.valueOf(eachAppAddr.AddrStability__c):''; 
                                        addDetails.areaCode =mapLocMas.get(eachAppAddr.Locality__c) !=null ? String.valueOf(mapLocMas.get(eachAppAddr.Locality__c).CityId__c) !=null ?String.valueOf(mapLocMas.get(eachAppAddr.Locality__c).CityId__c):'':'';  // '20'; //eachAppAddr.Locality__c!=null?eachAppAddr.Locality__c:'20';//hardcoded 
                                        addDetails.district =''; 
                                        addDetails.pinCode =  eachAppAddr.Pincode__c!=null?eachAppAddr.Pincode__c:''; 
                                        addDetails.smsMobilePrimary =''; 
                                        addDetails.stayDurationCurrAddressMon =''; 
                                        listAddDetails.add(addDetails);
                                        
                                        
                                    }
                                    
                                }
                                
                                //AddressDetails(Applicant) end
                                List<LoanBoardingRequestWrapper.IncomeDetails> listIncDetails=new List<LoanBoardingRequestWrapper.IncomeDetails>();
                                List<Applicant_Income__c> listAppIncome = appIncomeMap.get(app.ID);
                                
                                //for Net Income Calculations
                                Decimal totalCashSalNetAmt=0;
                                Decimal totalBankCrSalNetAmt=0;
                                Decimal totalRentWBankNetAmt=0;
                                Decimal totalRentWOBankNetAmt=0;
                                Decimal totalPensionNetAmt=0;
                                Decimal totalAgrAmtCurrentY=0;
                                Decimal totalAgrAmtPreviousY=0;
                                Decimal totalNetAmtCommon=0;
                                
                                
                                
                                Decimal totalCashSalAmt=0;
                                Decimal totalBankCrSal=0;
                                Decimal totalRentWBank=0;
                                Decimal totalRentWOBank=0;
                                Decimal totalPensionAmt=0;
                                
                                //Count for Different types
                                Integer countCashSalAmt=0;
                                Integer countBankCrSal=0;
                                Integer countPension=0;
                                Integer countAgrAmtCurrentY=0;
                                Integer countAgrAmtPreviousY=0;
                                
                                Integer currentYearBlock =System.Today().year();
                                Integer previousYearBlock =currentYearBlock -1;
                                
                                if(listAppIncome!=null && !listAppIncome.isEmpty())
                                {
                                    for(Applicant_Income__c appInc:listAppIncome)
                                    {
                                        
                                        if(appInc.RecordType.DeveloperName == 'CashSal'){
                                            totalCashSalAmt=totalCashSalAmt + (appInc.Salary__c !=null ? Integer.valueOf(appInc.Salary__c) : 0  ) ; 
                                            countCashSalAmt++;
                                            
                                        }
                                        if(appInc.RecordType.DeveloperName == 'BankCrSal'){
                                            totalBankCrSal =totalBankCrSal+  (appInc.Net_Salary__c !=null ? Integer.valueOf(appInc.Net_Salary__c) :0 );
                                            countBankCrSal++;
                                        }
                                        if(appInc.RecordType.DeveloperName =='RentalwBank'){
                                            totalRentWBank =totalRentWBank+ appInc.Month3_Rental_Credited_Amount__c !=null ? Integer.valueOf(appInc.Month3_Rental_Credited_Amount__c) :0;
                                            totalRentWBank =totalRentWBank+ appInc.Month2_Rental_Credited_Amount__c !=null ? Integer.valueOf(appInc.Month2_Rental_Credited_Amount__c) :0 ;
                                            totalRentWBank =totalRentWBank+ appInc.Month1_Rental_Credited_Amount__c != null ? Integer.valueOf(appInc.Month1_Rental_Credited_Amount__c):0 ;
                                            
                                        }
                                        if(appInc.RecordType.DeveloperName =='Rental_woBanking'){
                                            totalRentWOBank=totalRentWOBank + appInc.Month3_Rental_Credited_Amount__c !=null ? Integer.valueOf(appInc.Month3_Rental_Credited_Amount__c) :0;
                                            totalRentWOBank=totalRentWOBank + appInc.Month2_Rental_Credited_Amount__c !=null ?Integer.valueOf(appInc.Month2_Rental_Credited_Amount__c) :0;
                                            totalRentWOBank=totalRentWOBank + appInc.Month1_Rental_Credited_Amount__c!=null ?Integer.valueOf(appInc.Month1_Rental_Credited_Amount__c) :0 ;
                                            
                                        }
                                        if(appInc.RecordType.DeveloperName =='Pension'){
                                            totalPensionAmt =totalPensionAmt+ ((appInc.Monthly_Pension_Credited__c !=null ? Integer.valueOf(appInc.Monthly_Pension_Credited__c) :0));
                                            countPension++;
                                        }
                                        if(appInc.Agricultural_Income_Year__c == currentYearBlock && appInc.RecordType.DeveloperName == 'AgriIncome'){
                                            totalAgrAmtCurrentY= totalAgrAmtCurrentY+ appInc.Agricultural_Yearly_Income__c !=null ?Integer.valueOf(appInc.Agricultural_Yearly_Income__c) :0 ;
                                            countAgrAmtCurrentY++;
                                        }
                                        if(appInc.Agricultural_Income_Year__c == previousYearBlock && appInc.RecordType.DeveloperName == 'AgriIncome'){
                                            totalAgrAmtPreviousY=totalAgrAmtPreviousY+ appInc.Agricultural_Yearly_Income__c !=null ? Integer.valueOf(appInc.Agricultural_Yearly_Income__c):0;
                                            countAgrAmtPreviousY++;
                                        }
                                        
                                        
                                    }
                                }
                                
                                if(countCashSalAmt > 0){
                                    LoanBoardingRequestWrapper.IncomeDetails incDetailsA=new LoanBoardingRequestWrapper.IncomeDetails();
                                    incDetailsA.incomeSource =''; //blank
                                    incDetailsA.howAreYouPaid =''; //blank
                                    incDetailsA.salaryCreditDay = ''; //blank
                                    incDetailsA.incomePercentage='';//blank
                                    //mandatory fields
                                    Decimal resNetAmt=((totalCashSalAmt)/countCashSalAmt);
                                    Decimal resAmt=((resNetAmt)*12);
                                    incDetailsA.incomeHead='03';
                                    incDetailsA.inomeNetAmount= resNetAmt > 0 ? String.valueOf(resNetAmt.setscale(2)): '';
                                    incDetailsA.incomeAmount =resAmt > 0 ? String.valueOf(resAmt.setscale(2)) : ''; 
                                    incDetailsA.incomeFeq='12';
                                    listIncDetails.add(incDetailsA);
                                    
                                    
                                }
                                if(countBankCrSal >0){
                                    LoanBoardingRequestWrapper.IncomeDetails incDetailsB=new LoanBoardingRequestWrapper.IncomeDetails();
                                    incDetailsB.incomeSource =''; //blank
                                    incDetailsB.howAreYouPaid =''; //blank
                                    incDetailsB.salaryCreditDay = ''; //blank
                                    incDetailsB.incomePercentage='';//blank
                                    //mandatory fields
                                    Decimal resNetAmt=((totalBankCrSal)/countBankCrSal);
                                    Decimal resAmt=((resNetAmt)*12);
                                    incDetailsB.incomeHead='202';
                                    incDetailsB.inomeNetAmount= resNetAmt > 0 ? String.valueOf(resNetAmt.setscale(2)) : '';
                                    incDetailsB.incomeAmount =resAmt > 0 ? String.valueOf(resAmt.setscale(2)) : ''; 
                                    incDetailsB.incomeFeq='12';
                                    listIncDetails.add(incDetailsB);
                                    
                                }
                                if(countPension >0){
                                    
                                    LoanBoardingRequestWrapper.IncomeDetails incDetailsC=new LoanBoardingRequestWrapper.IncomeDetails();
                                    incDetailsC.incomeSource =''; //blank
                                    incDetailsC.howAreYouPaid =''; //blank
                                    incDetailsC.salaryCreditDay = ''; //blank
                                    incDetailsC.incomePercentage='';//blank
                                    //mandatory fields
                                    Decimal resNetAmt=((totalPensionAmt)/countPension);
                                    Decimal resAmt=((resNetAmt)*12);
                                    incDetailsC.incomeHead='055';
                                    incDetailsC.inomeNetAmount= resNetAmt > 0 ? String.valueOf(resNetAmt.setscale(2)) : '';
                                    incDetailsC.incomeAmount =resAmt > 0 ? String.valueOf(resAmt.setscale(2)) : ''; 
                                    incDetailsC.incomeFeq='12';
                                    listIncDetails.add(incDetailsC);
                                    
                                }
                                if(countAgrAmtCurrentY >0)
                                {
                                    
                                    LoanBoardingRequestWrapper.IncomeDetails incDetailsD=new LoanBoardingRequestWrapper.IncomeDetails();
                                    incDetailsD.incomeSource =''; //blank
                                    incDetailsD.howAreYouPaid =''; //blank
                                    incDetailsD.salaryCreditDay = ''; //blank
                                    incDetailsD.incomePercentage='';//blank
                                    //mandatory fields
                                    Decimal resNetAmt=((totalAgrAmtCurrentY)/12);
                                    
                                    incDetailsD.incomeHead='212';
                                    incDetailsD.inomeNetAmount= resNetAmt > 0 ? String.valueOf(resNetAmt.setscale(2)) : '';
                                    incDetailsD.incomeAmount =totalAgrAmtCurrentY > 0 ? String.valueOf(totalAgrAmtCurrentY.setscale(2)) : ''; 
                                    incDetailsD.incomeFeq='1';
                                    listIncDetails.add(incDetailsD);
                                    
                                }
                                if(countAgrAmtPreviousY > 0)
                                {
                                    LoanBoardingRequestWrapper.IncomeDetails incDetailsE=new LoanBoardingRequestWrapper.IncomeDetails();
                                    incDetailsE.incomeSource =''; //blank
                                    incDetailsE.howAreYouPaid =''; //blank
                                    incDetailsE.salaryCreditDay = ''; //blank
                                    incDetailsE.incomePercentage='';//blank
                                    //mandatory fields
                                    Decimal resNetAmt=((totalAgrAmtPreviousY)/12);             
                                    
                                    incDetailsE.incomeHead='213';
                                    incDetailsE.inomeNetAmount= resNetAmt  > 0 ? String.valueOf(resNetAmt.setscale(2)) : '';
                                    incDetailsE.incomeAmount =totalAgrAmtPreviousY > 0 ? String.valueOf(totalAgrAmtPreviousY.setscale(2)) : ''; 
                                    incDetailsE.incomeFeq='1';
                                    listIncDetails.add(incDetailsE);
                                    
                                    
                                }
                                if(totalRentWBank >0)
                                {
                                    LoanBoardingRequestWrapper.IncomeDetails incDetailsF=new LoanBoardingRequestWrapper.IncomeDetails();
                                    incDetailsF.incomeSource =''; //blank
                                    incDetailsF.howAreYouPaid =''; //blank
                                    incDetailsF.salaryCreditDay = ''; //blank
                                    incDetailsF.incomePercentage='';//blank
                                    //mandatory fields
                                    Decimal resNetAmt=((totalRentWBank)/3);
                                    Decimal resAmt=((resNetAmt)*12);   
                                    incDetailsF.incomeHead='37';
                                    incDetailsF.inomeNetAmount= resNetAmt > 0 ? String.valueOf(resNetAmt.setscale(2)): '';
                                    incDetailsF.incomeAmount =resAmt > 0? String.valueOf(resAmt.setscale(2)) : ''; 
                                    incDetailsF.incomeFeq='12';
                                    listIncDetails.add(incDetailsF);
                                }
                                if (totalRentWOBank >0)
                                {
                                    LoanBoardingRequestWrapper.IncomeDetails incDetailsG=new LoanBoardingRequestWrapper.IncomeDetails();
                                    incDetailsG.incomeSource =''; //blank
                                    incDetailsG.howAreYouPaid =''; //blank
                                    incDetailsG.salaryCreditDay = ''; //blank
                                    incDetailsG.incomePercentage='';//blank
                                    //mandatory fields
                                    Decimal resNetAmt=((totalRentWOBank)/3);
                                    Decimal resAmt=((resNetAmt)*12);
                                    incDetailsG.incomeHead='37';
                                    incDetailsG.inomeNetAmount= resNetAmt > 0 ? String.valueOf(resNetAmt.setscale(2)) : '';
                                    incDetailsG.incomeAmount =resAmt > 0? String.valueOf(resAmt.setscale(2)) : ''; 
                                    incDetailsG.incomeFeq='12';
                                    listIncDetails.add(incDetailsG);
                                    
                                }
                                Decimal totalAmtPLCurrYear=0;
                                Decimal totalAmtPLPreviousYear=0;
                                
                                Integer ChkValForAppFinY =  0;
                                Integer ChkValForAppFinPY =  0;
                                
                                
                                for(Applicant_Financial_Summary__c appFinSum: [Select id,PAT__c,Applicant_Financial__c, Applicant_Financial__r.RecordTypeId, Applicant_Financial__r.RecordType.DeveloperName, Applicant_Financial__r.Loan_Applicant__c,
                                                                               Financial_Year__c 
                                                                               from Applicant_Financial_Summary__c 
                                                                               where Applicant_Financial__c !=null AND Applicant_Financial__r.RecordTypeId != null AND Applicant_Financial__r.RecordType.DeveloperName = 'Profit_Loss' AND  
                                                                               Applicant_Financial__r.Loan_Applicant__c !=null AND Applicant_Financial__r.Loan_Applicant__c =:app.ID])
                                {
                                    if(String.valueOf(appFinSum.Financial_Year__c) == String.valueOf(currentYearBlock)){
                                        totalAmtPLCurrYear=totalAmtPLCurrYear+appFinSum.PAT__c;
                                        ChkValForAppFinY=Integer.valueOf(appFinSum.Financial_Year__c);
                                    }
                                    if(String.valueOf(appFinSum.Financial_Year__c) == String.valueOf(previousYearBlock)){
                                        totalAmtPLPreviousYear=totalAmtPLPreviousYear+appFinSum.PAT__c;
                                        ChkValForAppFinPY=Integer.valueOf(appFinSum.Financial_Year__c);
                                    }
                                }   
                                
                                
                                
                                if(ChkValForAppFinY == currentYearBlock){
                                    LoanBoardingRequestWrapper.IncomeDetails incDetailsH=new LoanBoardingRequestWrapper.IncomeDetails();
                                    incDetailsH.incomeSource =''; //blank
                                    incDetailsH.howAreYouPaid =''; //blank
                                    incDetailsH.salaryCreditDay = ''; //blank
                                    incDetailsH.incomePercentage='';//blank
                                    //mandatory fields
                                    Decimal resNetAmt=((totalAmtPLCurrYear)/12);
                                    
                                    incDetailsH.incomeHead='216';
                                    incDetailsH.inomeNetAmount= resNetAmt >0 ? String.valueOf(resNetAmt.setscale(2)) : '';
                                    incDetailsH.incomeAmount =totalAmtPLCurrYear >0 ? String.valueOf(totalAmtPLCurrYear.setscale(2)) : ''; 
                                    incDetailsH.incomeFeq='1';
                                    listIncDetails.add(incDetailsH);
                                    
                                }  
                                if(ChkValForAppFinPY == previousYearBlock){
                                    LoanBoardingRequestWrapper.IncomeDetails incDetailsI=new LoanBoardingRequestWrapper.IncomeDetails();
                                    incDetailsI.incomeSource =''; //blank
                                    incDetailsI.howAreYouPaid =''; //blank
                                    incDetailsI.salaryCreditDay = ''; //blank
                                    incDetailsI.incomePercentage='';//blank
                                    //mandatory fields
                                    Decimal resNetAmt=((totalAmtPLPreviousYear)/12);
                                    
                                    incDetailsI.incomeHead='217';
                                    incDetailsI.inomeNetAmount= resNetAmt> 0 ? String.valueOf(resNetAmt.setscale(2)): '';
                                    incDetailsI.incomeAmount =totalAmtPLPreviousYear >0 ? String.valueOf(totalAmtPLPreviousYear.setscale(2)) : ''; 
                                    incDetailsI.incomeFeq='1';
                                    listIncDetails.add(incDetailsI);
                                }
                                
                                //ApplicantDetails start
                                
                                LoanBoardingRequestWrapper.ApplicantDetails appDetail =new LoanBoardingRequestWrapper.ApplicantDetails();
                                ApplicantEmployment__c apEmpData =new ApplicantEmployment__c();
                                List<ApplicantEmployment__c> listAppEmp = appEmpMap.get(app.Id);    
                                LoanAppl__c dataLoanApp1= loanAppRecordsMap.get(intMsg.RefId__c); 
                                List<ApplAsset__c> listAppAsset = appAssetMapByLoanApp.get(loanApplnIds[0]);//  appAssetMap.get(app.Id);
                                String strPropOwner='';
                                System.debug('listAppAsset::'+listAppAsset);
                                if(listAppAsset!=null && !listAppAsset.isEmpty()){
                                    if(listAppAsset!=null && listAppAsset.size()>0){
                                        strPropOwner=listAppAsset[0].Prop_Owners__c;
                                    }
                                    else{
                                        strPropOwner='';
                                    }
                                    
                                }  
                                System.debug('strPropOwner::'+strPropOwner);
                                if(listAppEmp!=null && !listAppEmp.isEmpty()){
                                    
                                    apEmpData=listAppEmp[0];
                                }  
                                
                                
                                appDetail.passportFileNo = '';//app.EduQual__c!=null ?app.EduQual__c:''; TBD 
                                appDetail.cifNo ='';  //TBD non mandatory
                                appDetail.relatedPersonCKyc =''; 
                                appDetail.assetCat =''; 
                                appDetail.companyName =app.CompanyName__c!=null ?app.CompanyName__c:''; 
                                appDetail.corpTradeLicenseExpiryDate =''; 
                                appDetail.turnOver =''; 
                                appDetail.branch =''; 
                                appDetail.finalRiskGrade =''; 
                                appDetail.qualifyingYear =String.valueOf(app.YearOfRegistration__c)!=null ?String.valueOf(app.YearOfRegistration__c):''; 
                                appDetail.relation = 'SFI';//hardcoded app.Relationship__c!=null ?app.Relationship__c :''; TBD
                                appDetail.noOfChildInHigh =''; 
                                appDetail.empIDCGSG =''; //TBD
                                appDetail.taxIdentificationNoJuridiction =''; 
                                appDetail.losNo =''; 
                                appDetail.voterId =app.VotIdEpicNo__c!=null ?app.VotIdEpicNo__c:''; 
                                appDetail.rationCardNo =''; 
                                appDetail.constitution=masterDataMap.get('Constitution')!=null ? masterDataMap.get('Constitution').get(app.Constitution__c) !=null ?masterDataMap.get('Constitution').get(app.Constitution__c) :'':'';//harcoded app.Constitution__c !=null ?app.Constitution__c:'';
                                appDetail.dncFlag =''; 
                                appDetail.endOfService =''; 
                                appDetail.finalRiskStatus =''; 
                                appDetail.deductionDetails =listRepayDetails1; 
                                appDetail.isTopUpLoan =''; 
                                appDetail.corpDesignation =''; 
                                appDetail.natureOfBusinessCorp =apEmpData.NatureOfBusinessCorporate__c!=null?apEmpData.NatureOfBusinessCorporate__c:''; 
                                appDetail.contactPersonDesignation =''; 
                                appDetail.additinalId2 =''; 
                                appDetail.spousePassportCountry =''; 
                                appDetail.relatedCkycNo =''; 
                                appDetail.additionalIdNo3 =''; 
                                appDetail.lastSchoolAttended =''; 
                                appDetail.lastname =app.LName__c!=null ?app.LName__c:''; 
                                appDetail.groupName =''; 
                                appDetail.fwAccountNo =''; 
                                appDetail.visaExpiryDate =''; 
                                appDetail.addressDocName =''; 
                                appDetail.nationality ='1'; //app.Nationality__c!=null?app.Nationality__c :''; //harcoded
                                
                                if(app.Constitution__c == 'INDIVIDUAL' )
                                {
                                    appDetail.indvCorpFlag= 'I';
                                }
                                else{
                                    appDetail.indvCorpFlag='C';
                                }
                                appDetail.corpTradeLicenseNo =''; 
                                
                                appDetail.incomeDetails =listIncDetails; 
                                appDetail.nationalFlag ='Y'; 
                                appDetail.isoCountryCodeBirth =''; 
                                appDetail.gender =app.Gender__c!=null ? app.Gender__c:''; 
                                appDetail.eduQualification =''; 
                                appDetail.relatedIdProofCollected =''; 
                                appDetail.whetherResi ='N'; //OK hardcoded
                                appDetail.rollOverType =''; 
                                appDetail.contactPerson =app.KeyManName__c!=null ?app.KeyManName__c:''; 
                                appDetail.demoCorpRatingDetails =listDemoCopratDetail; 
                                appDetail.selectPassportCountry =''; 
                                appDetail.mscInfoDetails =mscInfoObj; 
                                appDetail.pmayBankRelation =''; 
                                appDetail.nregaJobCard =''; 
                                appDetail.topUpAmount =''; 
                                appDetail.govtIdNo =''; 
                                appDetail.isExistingCustomer =''; 
                                appDetail.hostSystemCustId =''; 
                                appDetail.relatedIdNo =''; 
                                appDetail.applicantType =app.ApplType__c !=null ?app.ApplType__c :''; 
                                appDetail.outstandingAmt =''; 
                                appDetail.customerId =''; //can be blank
                                appDetail.preferredIrr =''; 
                                appDetail.uidToken =app.AadhaarNo__c!=null ?app.AadhaarNo__c:''; 
                                appDetail.educQual =app.EduQual__c !=null ?app.EduQual__c:''; 
                                appDetail.currency_Z =''; // in json: currency
                                appDetail.tenureInMonths ='180';// Hardcoded loanAppRecordsMap.get(intMsg.RefId__c)!=null ? String.valueOf(loanAppRecordsMap.get(intMsg.RefId__c).Loan_Tenure_Months__c) !=null ?String.valueOf(loanAppRecordsMap.get(intMsg.RefId__c).Loan_Tenure_Months__c) :'':'' ;//'180';//harcoded not master 
                                appDetail.guardian =''; 
                                appDetail.relatedIdExpiryDate =''; 
                                appDetail.passportNo =app.PassNo__c!=null ?app.PassNo__c:''; 
                                appDetail.placeOfBirth =''; 
                                appDetail.carOwnership =''; 
                                appDetail.dateOfBirth = app.DOB__c!=null ?String.valueOf(app.DOB__c.day()) + '-' + monthMap.get(app.DOB__c.month()) + '-' + String.valueOf(app.DOB__c.year()) :'';  //String.valueOf(app.DOB__c)!=null ?String.valueOf(app.DOB__c) :''; 
                                appDetail.religion =app.Religion__c !=null ? app.Religion__c :''; 
                                appDetail.idDocName =''; 
                                appDetail.authCapital =''; 
                                appDetail.entityFlag =''; 
                                appDetail.spouseName =app.SpName__c!=null ?app.SpName__c:''; 
                                appDetail.companyWebsite =''; 
                                appDetail.cinRegistrationNo =''; 
                                appDetail.applicantCustomDetail =appCusDetail; 
                                appDetail.relatedTitle =''; 
                                appDetail.residency =''; 
                                appDetail.fatherName =app.Father_Name__c!=null ?app.Father_Name__c:''; 
                                String strIndClass= '';
                                
                                if(appEmpMap.get(app.Id) !=null && !appEmpMap.get(app.Id).isEmpty()){
                                    strIndClass= appEmpMap.get(app.Id)[0].IndustryType__r.name !=null ? appEmpMap.get(app.Id)[0].IndustryType__r.name :'';
                                }
                                System.debug('strIndClass::'+strIndClass);
                                //List<Industry__c> liInd=[Select Id,name,IndustryID__c from Industry__c where name=:strIndClass];
                                Industry__c indObjectForName=industryNameMap.get(strIndClass);
                                
                                System.debug('indObjectForName::'+indObjectForName);
                                
                                appDetail.industryClassification = (indObjectForName!=null) ? String.valueOf(indObjectForName.IndustryID__c) : '';
                                
                                if(!String.isEmpty(strPropOwner))
                                {
                                    if(strPropOwner.length() != 0)
                                    {
                                        appDetail.propertyOwner ='Y'; 
                                    }else
                                    {
                                        appDetail.propertyOwner ='N'; 
                                    }
                                    
                                }
                                else
                                {
                                    appDetail.propertyOwner ='N'; 
                                }
                                appDetail.minor =''; 
                                appDetail.isoCountryCodeJuridiction =''; 
                                appDetail.jobTitle =''; 
                                appDetail.hostSystemAccNo =''; 
                                appDetail.sssGSIS =''; 
                                appDetail.residentOfCountrySince =''; 
                                appDetail.aipTenure =''; 
                                appDetail.docCollectionDetails =listDocdetails; 
                                appDetail.bankDetails =listBankDls; 
                                appDetail.otherIdNo =''; 
                                appDetail.relatedIdDocName =''; 
                                appDetail.noOfCars =''; 
                                appDetail.familyName =''; 
                                appDetail.dateOfClosure =''; 
                                appDetail.corpOrgType =''; 
                                appDetail.assetMake =''; 
                                appDetail.pan =app.PAN__c!=null ?app.PAN__c:''; 
                                appDetail.paidUpCapital =''; 
                                appDetail.leadId =''; 
                                appDetail.group_Z =''; // in json: group
                                appDetail.spousePassNo =''; 
                                appDetail.aliasName =''; 
                                appDetail.noOfDependents =''; 
                                appDetail.lenOfBusiness =''; 
                                appDetail.yearOfBusinessInCountry =''; 
                                appDetail.motherMaidenName =app.MthrMdnName__c!=null ?app.MthrMdnName__c:''; 
                                appDetail.isStaff =''; 
                                appDetail.resType =''; 
                                appDetail.bankType =''; 
                                appDetail.initials =''; 
                                appDetail.noOfChildInCollege =''; 
                                appDetail.accountType =''; 
                                appDetail.motherName =app.MthrMdnName__c!=null ?app.MthrMdnName__c:''; 
                                appDetail.passportIssuedate =''; 
                                appDetail.rentPerMonth =''; 
                                appDetail.spousePassIssueDate =''; 
                                appDetail.degree =''; 
                                appDetail.idExpiryDate =''; 
                                appDetail.employeeDepartment =''; 
                                appDetail.rankEmp =''; 
                                appDetail.firstName =app.FName__c!=null?app.FName__c:''; 
                                
                                
//if(String.valueOf(dataLoanApp1.LeadSource__c).equalsIgnoreCase('DSA'))
//{ 
//appDetail.dsa =dataLoanApp1.ChanelNme__r.DSAConnId__c !=null ? dataLoanApp1.ChanelNme__r.DSAConnId__c :'';
//}
//else if(String.valueOf(dataLoanApp1.LeadSource__c).equalsIgnoreCase('Connector'))
//{
//appDetail.dsa =dataLoanApp1.ChanelNme__r.VCReferralId__c !=null ? dataLoanApp1.ChanelNme__r.VCReferralId__c : ''; 
//}
//else
//{
//appDetail.dsa ='';
//}
                                appDetail.dsa ='384';//hardcoded
                                
                                
                                appDetail.passportIssueCountry =''; 
                                appDetail.salaryAssign =''; 
                                appDetail.relatedFullname =''; 
                                appDetail.salutation =app.FullName__c!=null ?app.FullName__c:''; 
                                appDetail.visaNo =''; 
                                appDetail.region =''; 
                                appDetail.spousePassExpiryDate =''; 
                                appDetail.drivingLicenseIssuedAt =''; 
                                appDetail.bussFinanRatingDetails =listRepayDetails1; 
                                appDetail.maritalStatus =app.MariStatus__c!=null ?app.MariStatus__c:''; 
                                appDetail.stakeHolderDetails =listStakDetls; 
                                if(app.Constitution__c=='INDIVIDUAL'){
                                    // appliDetails.natureOfBusinessWork= apEmpData.NatureOfBusinessIndividual__c;
                                }else{
                                    // appliDetails.natureOfBusinessWork=apEmpData.NatureOfBusinessCorporate__c;
                                } 
                                
                                appDetail.custSegment= masterDataMap.get('Customer Profile')!=null? masterDataMap.get('Customer Profile').get(app.CustProfile__c) !=null ?masterDataMap.get('Customer Profile').get(app.CustProfile__c) :'':''; //masterDataMap.get('Customer Profile').get(app.CustProfile__c) !=null ?masterDataMap.get('Customer Profile').get(app.CustProfile__c) :'';// app.CustProfile__c!=null?app.CustProfile__c:'';
                                appDetail.university =''; 
                                appDetail.liabilityDetails =listLiabDtls; 
                                appDetail.noOfChidNotYet =''; 
                                appDetail.atWhatDayYouArePaid =''; 
                                appDetail.hostAccNo =''; 
                                appDetail.addressDetails =listAddDetails; 
                                appDetail.oldagreementId =''; 
                                System.debug('passportExpiryDate::'+appKycsMap.get(app.Id));
                                appDetail.passportExpiryDate = (appKycsMap.get(app.Id) !=null && !appKycsMap.get(app.Id).isEmpty()) ? (appKycsMap.get(app.Id)[0] != null) ?   appKycsMap.get(app.Id)[0].PassExpDt__c !=null ? (String.valueOf(appKycsMap.get(app.Id)[0].PassExpDt__c.day()) + '-' + monthMap.get(appKycsMap.get(app.Id)[0].PassExpDt__c.month()) + '-' + String.valueOf(appKycsMap.get(app.Id)[0].PassExpDt__c.year()) ):'':'':'';   //TBD
                                appDetail.title = app.Title__c !=null ?  String.valueOf(app.Title__c).toUpperCase() :''; 
                                appDetail.companyNameNatLang =''; 
                                appDetail.workDetailsSalaried =wrkDetailSal; 
                                appDetail.subIndustry =  ''; //( appEmpMap.get(app.Id) !=null && !appEmpMap.get(app.Id).isEmpty() )  ? appEmpMap.get(app.Id)[0].SubIndustry__r.Name !=null ?appEmpMap.get(app.Id)[0].SubIndustry__r.Name:'' :''; 
                                appDetail.tanNo =''; 
                                appDetail.vpaUpiPrimary =''; 
                                appDetail.ruralUrbanCustomer =''; 
                                appDetail.drivingLicenseNo =app.DLNo__c!=null ?app.DLNo__c :''; 
                                appDetail.cibilScore ='NA'; //Hardcode  
                                appDetail.isDeletionRelatedPerson =''; 
                                appDetail.accountNo =''; 
                                appDetail.cardDetails =listRepayDetails1; 
                                appDetail.vpaUpiSecondary =''; 
                                appDetail.relatedGuardianMinor =''; 
                                appDetail.noOfChildInElem =''; 
                                appDetail.aipAmount =''; 
                                appDetail.fwCustomerId =''; 
                                appDetail.professionalQual =app.ProfQual__c!=null ?app.ProfQual__c:''; //OK
                                appDetail.existingCreditCardNo =''; 
                                appDetail.webCibilScore =''; 
                                appDetail.finnoneLanNo =''; 
                                appDetail.idProofCollectedCkyc =''; 
                                appDetail.citizenship ='17'; //
                                appDetail.assetModel =''; 
                                appDetail.fullName =app.FullName__c!=null?app.FullName__c:''; 
                                appDetail.dateOfInception = app.DOI__c!=null ? String.valueOf(app.DOI__c.day()) + '-' + monthMap.get(app.DOI__c.month()) + '-' + String.valueOf(app.DOI__c.year()):'';//String.valueOf(app.DOI__c)!=null ?String.valueOf(app.DOI__c):''; 
                                appDetail.relatedAssignee =''; 
                                appDetail.vpaUpiTertiary =''; 
                                appDetail.visaType =''; 
                                appDetail.staffGrade =''; 
                                appDetail.fdDetails =listFddetails; 
                                appDetail.drivingLicenseExpiryDate =''; 
                                appDetail.uniqueCustomerId =app.UCID__c!=null ?app.UCID__c:''; 
                                appDetail.dmeDST =''; 
                                appDetail.middleName =app.MName__c!=null?app.MName__c:''; 
                                appDetail.bankname =''; 
                                appDetail.category =  app.Category__c !=null ? app.Category__c :'';//  'B'; //masterDataMap.get('Customer Profile').get(app.CustProfile__c) !=null ?masterDataMap.get('Customer Profile').get(app.CustProfile__c) :'';//app.CustProfile__c!=null?app.CustProfile__c:''; 
                                appDetail.staffId =''; 
                                appDetail.age =String.valueOf(app.Age__c)!=null?String.valueOf(app.Age__c):''; 
                                appDetail.additionRelatedPerson =''; 
                                
                                listAppDetl.add(appDetail);
                                
                                //ApplicantEmployment__c apEmpData1=(appEmpMap.get(app.Id)!=null && !appEmpMap.get(app.Id).isEmpty()) ?  appEmpMap.get(app.Id)[0] :new ApplicantEmployment__c();
                                if(app.Constitution__c=='INDIVIDUAL'){
                                    // appliDetails.natureOfBusinessWork= apEmpData.NatureOfBusinessIndividual__c;
                                }else{
                                    // appliDetails.natureOfBusinessWork=apEmpData.NatureOfBusinessCorporate__c;
                                }
                            }    
                            
                        }  
                        LoanBoardingRequestWrapper.MainLoanApp mainLoanObj= new LoanBoardingRequestWrapper.MainLoanApp();
                        mainLoanObj.crossCollateral = listCrsCol; 
                        mainLoanObj.sourceSystem = 'SFDC'; 
                        mainLoanObj.repaymentDetails =listRepayDetails1 ; 
                        mainLoanObj.notepadDetails = listNoteDetails; 
                        mainLoanObj.splitDisbursalDetails = listSplitDis; 
                        mainLoanObj.confirmationLog = conLog; 
                        mainLoanObj.password ='qWI2wzG7ofqhTR1gsHM6Qw==' ; 
                        mainLoanObj.applicantDetails = listAppDetl; 
                        mainLoanObj.instrumentDetails = instDetails; 
                        mainLoanObj.propertyDetails = listProp; 
                        mainLoanObj.insuranceDetails = insDetail; 
                        mainLoanObj.teleVerification = listRepayDetails1; 
                        mainLoanObj.jsonVersion = 'LB-PL-NEv1.0'; //OK
                        mainLoanObj.personalDiscussion =listPerDiscussion ; 
                        mainLoanObj.unqRequestId = 	GlobalUtility.getUniqueNumber();  
                        mainLoanObj.tradeInDetail =listtradeInDeatil ; 
                        mainLoanObj.gradedRepaymentDetails = listGradedPay; 
                        mainLoanObj.loanDetails =lnDetails ; 
                        mainLoanObj.chargesDetails = listChrdetails; 
                        mainLoanObj.collateralDetails =listColDetails ; 
                        mainLoanObj.sourcingDetail =srcDetail ; 
                        mainLoanObj.fivCheckList =listFivChk ; 
                        mainLoanObj.userId = 'finn1lb'; 
                        mainLoanObj.referenceDetails =listRefdetails ; 
                        mainLoanObj.rateRiskDetails =listRateRiskDetails ; 
                        mainLoanObj.gSTInfoDetails =gstInDetails ; 
                        mainLoanObj.bussinessVerification =busVer ; 
                        mainLoanObj.initialMoneyDepositDetails =listIniMoneyDetails ; 
                        
                        // String finalJsonStr=JSON.serialize(mainLoanObj);
                        String finalJsonString =JSON.serialize(mainLoanObj).replace('group_Z', 'group').replace('currency_Z','currency').replace('null', '""');
                        IntgMsg__c intgr=New IntgMsg__c();
                        intgr.id=intMsg.id;
                        if(!String.isBlank(finalJsonString)){
                            intgr.Req__c = finalJsonString;
                        }else{
                            intgr.Req__c = '';
                        }
                        
                        System.debug('*****************JSON Request Start*************************');
                        System.debug('JSON.serialize(mainLoanObj)::'+JSON.serialize(mainLoanObj).replace('group_Z', 'group').replace('currency_Z','currency').replace('null', '""'));
                        System.debug('*****************JSON Request Completed*********************');
                        
                        intgr.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                        updateIntRecords.add(intgr);
                    }
                    //For loop main ends
                }
                if(!updateIntRecords.isEmpty()) {
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Req__c','Status__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntRecords);
                }
            }
            
            uow.commitWork();
        }
        catch(Exception ex){
            System.debug(ex);  
            System.debug('Line::'+ex.getLineNumber());     
            System.debug('error'+ex.getMessage());
            GlobalUtility.logMessage('Error', 'LoanBoardingRequestGenerator' + ex.getLineNumber(), 
                                     'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }*/
        
        
    }   
    
}