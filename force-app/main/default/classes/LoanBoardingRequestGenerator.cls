public class LoanBoardingRequestGenerator implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){ 
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { IntgMsg__c.SObjectType });
        
        List<Id> appIds = new List<Id>();
        List<Id> loanApplnIds = new List<Id>();
        Map<Id,List<Applicant__c>> loanAppMap = new Map<Id,List<Applicant__c>>();
        Map<Id, LoanAppl__c> loanAppRecordsMap = new Map<Id, LoanAppl__c>();
        
        //Ucid Of Primary Applicant
        String ucidPriApp ='';
        Id idForOwPer=null;
        String emiLoan='';
        ID priAppId=null;
        Map<Id,List<ApplGST__c>> mapOfGstdetails =new Map<Id,List<ApplGST__c>>();
        //Map<Id,List<ApplAddr__c>> mapOfAddDetailsGst =new Map<Id,List<ApplAddr__c>>();
        
        //Set for Different city and Locality
        Set<String> citySet =new Set<String>();
        Set<String> bankSet =new Set<String>();
        Set<String> micrBrnchSet =new Set<String>();
        Set<String> industryVal = new Set<String>();
        Set<Id> repayId =new set<Id>();
        
        
        //To get Master data from Name
        Map<String,LocMstr__c> mapLocMas =new Map<String,LocMstr__c>();
        Map<String,LocBrchJn__c> mapLocBrnchMas =new Map<String,LocBrchJn__c>();
        Map<String,BankMstr__c> bankMstrMap =new Map<String,BankMstr__c>();
        Map<String,MICRCodeMstr__c> micrMstrMap =new Map<String,MICRCodeMstr__c>();
        Map<String,Industry__c> industryNameMap =new Map<String,Industry__c>();
        
        //Map<Id, Map<String, ApplAddr__c>> applAddressMapGst = new Map<Id, Map<String, ApplAddr__c>>();
        
        
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
        Map<Id,List<DocDtl__c>> appDocDetailsByLoanApp= new Map<Id,List<DocDtl__c>>();
        Map<Id,List<BureauRespDtl__c>> appBureauMapByApplicant =new Map<Id,List<BureauRespDtl__c>>();
        
        Map<Id,List<Bureau__c>> cibilScoreByAppMap= new Map<Id,List<Bureau__c>>();
        
        
        List<IntgSvcMgmt__mdt> liMdtReqd = [select id, DeveloperName,Username__c,Password__c,SourceSystem__c  from IntgSvcMgmt__mdt where DeveloperName ='Loan_Boarding'];
        
        Map<Id,List<ApplBankDetail__c>> bankingDetailMap = new Map<Id,List<ApplBankDetail__c>>();
        
        Map<String,Map<String,String>> masterDataMap= new Map<String,Map<String,String>> ();
        // Initialize a list to store related banking detail records for each banking record
        List<ApplBankDetail__c> detailList = new List<ApplBankDetail__c>();
                     
        
        
        //Map<Id, Case> tsrCasesMap = new Map<Id, Case>();
        Map<Id, Case> technicalCasesMap = new Map<Id, Case>();
        //Map<String, Case> legalCasesMap = new Map<String, Case>();
        Integer tsrCount = 0;
        Integer technicalCount = 0;
        Integer legalCount = 0;
        
        Id tsrCaseId=null;
        Id technicalCaseId1=null;
        Id technicalCaseId2=null;
        Id legalCaseId=null;
        
        //String for Unique Number
        String intMsgNum ='';
        String loanAppName ='';
        String finalUnqNum='';
        Boolean isCoAppFirst=true;
        Boolean isPriAppHasGst=false;
        Boolean isAppAddressPresent=false;
        Boolean isPriPresent =false;
        ApplGST__c  appGstObject;
        ApplAddr__c appAddressobject;
        
        //CoApplicant ID
        List<ID> coAppIdList= new List<ID>();
        List<ID> nonIndivAppIdList= new List<ID>();
        List<ID> indivAppIdList= new List<ID>();
        //List<Id> IdsForAppBank = new List<Id>();
        
        Map<String,String> relationShipMap = new Map<String,String>();
        for(Relationship__c relationShip: [Select id,ApplType__c, CoApplType__c, Name,Key__c from Relationship__c]){
            relationShipMap.put(relationShip.Name,relationShip.Key__c);
        }
        
        Integer individualApplicantCount = 0;
        Decimal individualSharingHolderPercent = 0;
        Set<Id> IdAssets= new Set<Id>();

        Integer sizeOfAssets =0;
        //Maps for getting values based on User Input
        final Map<String,String> mapFtMode =new Map<String,String>{'PREPAID CARD'=>'PC','RTGS'=>'RT','NEFT'=>'NT','INTERNAL TRANSFER'=>'IT','ONLINE TRANSFER'=>'OT','IMPS'=>'IM'};
            final Map <String,String> mapDocStatus =new Map <String,String>{'OTC'=>'D','PDD'=>'P','Waiver'=>'W','Received'=>'C','PENDING'=>'P'};//Completed no info about completed code
                final Map<Integer, String> monthMap = new Map<Integer, String>{1=>'Jan', 2=>'Feb', 3=>'Mar', 4=>'Apr', 5=>'May', 6=>'Jun', 7=>'Jul', 8=>'Aug', 9=>'Sep', 10=>'Oct', 11=>'Nov',12=>'Dec'};
                    final Set<String> typeFilters=new Set<String>{'Designation','Nature Of Loan','Income Type','Income Head','Prop Type','Repayment Account Type','Doc Status','Account Type', 'Product','Fund Transfer Mode','CashBank Account','Channel','Religion','Address Type','Customer Profile','Category','Applicant Type','Ownership Type','Customer','Education Qualification','Nationality','Disburse To','Constitution','Payment Mode','Instrument Type','Customer Profile Selection','Property Usage','Property Type','Marital Status'};
                        final Map<String,Integer> mapFirstEmiDueMon=new Map<String,Integer> {'January'=>1,'February'=>2,'March'=>3,'April'=>4,'May'=>5,'June'=>6,'July'=>7,'August'=>8,'September'=>9,'October'=>10,'November'=>11,'December'=>12};
                            
                            for(IntgMsg__c intMsg : msgs){ 
                                loanApplnIds.add(intMsg.RefId__c);
                                intMsgNum = intMsg.Integration_Message_Number__c  !=null ? intMsg.Integration_Message_Number__c :'';
                                
                            }
        
        if(!loanApplnIds.isEmpty())
        {//removed (select id,Name,LAN__c,OSV__c,DocStatus__c,TargetDt__c,ReceivedDt__c,DocSubTyp__c,DocMstr__r.DocId__c,DocDes__c from Applicant_Document_Details__r where DocStatus__c in ('OTC','PDD'))
            for(LoanAppl__c app : [SELECT ID,PromotionId__c,Final_Loan_Disbursal_Amount__c,ColChrgsAmt__c,AddationalComm__c,PrsnldetailsofPromotrs__c,IncomerelateComm__c,BDApplicantCoapp__c,PreEmiType__c,Pre_EMI_Amount__c,Name,ChanelNme__c,LoanPurposeId__c,RateEMIFlag__c,First_EMI_Due_Year_1__c,First_EMI_Due_Month_1__c,
                                   RMSMName__c,Total_PF_Amount__c,RefEmpCode__c,Applicant__r.Id,ChanelNme__r.DSAConnId__c,ChanelNme__r.VCReferralCode__c, ChanelNme__r.VCReferralId__c,BrchName__c,
                                   RemPFDeductFromDisbursementAmount__c,FinnoneAppid__c,FirstEMIDueMonth__c,SchemeId__c,ChannelCode__c,RMSMEmployeeID__c,PromCode__c,LoanPurpose__c,BrchCode__c,
                                   Product__c,SchmCode__c,CreatedDate,LeadSource__c ,ReqLoanAmt__c,LoanPLRType__c,Repayment_Frequency__c,TotalLoanAmtInclInsurance__c,DisbursedAmount__c,
                                   LoanPLRRate__c,AddIntSchedule__c,Rate_Type_Floating_Flag__c,EffectiveROI__c,MoratGraceApplicable__c,DisbursalType__c,DueDay__c,
                                   FirstEMIDate__c,Installment_Plan__c,FirstEMIDueYear__c,ImpactOnTenure__c,SpreadID__c,ChargeInterest__c,Loan_Tenure_Months__c,
                                   (select Id ,name,Actual_FOIR__c from BRE_Responses__r  where IsLatest__c =true)  , 
                                   (Select id,name,SumAmount__c,PremiumAmount__c,InsProvider__r.Name,InsProvider__r.MPno__c from Insurances__r), 
                                   //(select id,Name,LAN__c,OSV__c,DocStatus__c,TargetDt__c,ReceivedDt__c,DocSubTyp__c,DocMstr__r.DocId__c,DocDes__c,DocMstr__r.Catgry__c  from Applicant_Document_Details__r  where DocMstr__r.Catgry__c in ('Additional Post Sanction Documents','Mandatory Post Sanction Documents', 'Property Documents','Sanction Condition Documents')),
                                   (select ID,Amount__c,Name, ChargeCodeID__c,ChargeCodeDesc__c,EffeChrgeAmt__c from Loan_Application_Charges__r) ,
                                   (SELECT id,City__c,PaymentMode__c,MICRCode__c,BankBrch__c,BankAccountNo__c,IMDAmt__c,InstrumentAmt__c,PaymentRefNo__c from Applicant_IMD__r), 
                                   (SELECT id,RecordType.name,LoanApplication__c,Applicant__c,ConsiderObligation__c,NatureOfLoan__c,LoanName__c,Source__c,EMI__c,CloseDate__c,LoanAmount__c,FinancierName__c,TenureLeft__c,NoEMIPaid__c,CurrentOs__c,LoanApplication__r.Add_Another_Loan__c,Tenure__c,TotalBouncesInRTR__c,Treatment__c from BureauRespDtl__r where RecordType.name= 'Consumer Obligation' and Treatment__c IN ('To continue - Obligate','BT loan')) ,
                                   (SELECT Id,Name,LoanAppln__c,ProfQual__c,LoanAppln__r.Name,LoanAppln__r.BrchName__c,Constitution__c,MobNumber__c,LName__c,DOB__c,FName__c,Age__c,MName__c,Gender__c,PassNo__c,PAN__c,KeyManName__c,FullName__c,toLabel(MariStatus__c),SpName__c,MthrMdnName__c,YearOfRegistration__c,DLNo__c,VotIdEpicNo__c,EduQual__c,CompanyName__c,Relationship__c,Nationality__c,CustProfile__c,Title__c,UCID__c,DOI__c,ApplType__c,AadhaarNo__c,Religion__c,Father_Name__c,EmailId__c,Category__c,Type_of_Borrower__c,DrivingLicExpDate__c,Residential_Status__c,LatestyearforwhichITRisavailable__c  FROM Applicants__r WHERE ApplType__c in ('P','G','C')),
                                   (SELECT Id,Applicant__c,Applicant__r.MobNumber__c,RelationWthApp__c,RelationshipWthApp__c,FName__c,Add__c,Title__c from References__r WHERE Applicant__r.ApplType__c in ('P','G','C') AND PrsnlDis__r.IsCompleted__c=true AND PrsnlDis__r.CmpltDt__c != NULL  ORDER BY PrsnlDis__r.CmpltDt__c DESC ) ,
                                   (select Id,Name,Resi_Age__c,PropSubType__c,Landmark__c,Property_Carpet_area_Sq_Ft__c,AddrLn1__c,AddrLn2__c,Approx_Age_of_Prop__c,Prop_Owners__c,Land_Area__c,State__c,FlatNo__c,Is_it_an_APF__c,PropType__c,Builder_ID__c,Pin_Code__c,Total_Prop_Cost__c,LoanAppln__r.TotalLoanAmtInclInsurance__c,City__c,Property_Usage__c ,PropSubTypeDesc__c,Valuation_as_per_policy_norms__c,Comments_on_Collateral__c,ValuationToBeTakenAheadForCalculation__c,PropIdentified__c FROM Applicant_Assets__r) 
                                   FROM LoanAppl__c WHERE Id IN:loanApplnIds]){
                                       loanAppMap.put(app.Id,app.Applicants__r);
                                       loanAppRecordsMap.put(app.Id,app);   
                                       appAssetMapByLoanApp.put(app.id,app.Applicant_Assets__r); 
                                       appRefMapByLoanApp.put(app.id,app.References__r);   
                                       appLoanChargesMapByLoanApp.put(app.id,app.Loan_Application_Charges__r);                      
                                       appBureauMapByLoanApp.put(app.id,app.BureauRespDtl__r);
                                       appImdByLoanApp.put(app.id,app.Applicant_IMD__r);
                                       appBreResByLoanApp.put(app.id,app.BRE_Responses__r);
                                       appInsuranceByLoanApp.put(app.id,app.Insurances__r);
                                       //appDocDetailsByLoanApp.put(app.id,app.Applicant_Document_Details__r);
                                       

                                       if(app.Applicant_Assets__r!=null && !app.Applicant_Assets__r.isEMpty()){
                                        for(ApplAsset__c eachAsset : app.Applicant_Assets__r ){
                                            IdAssets.add(eachAsset.Id);
                                        }

                                        //

                                        sizeOfAssets = app.Applicant_Assets__r.size();
                                       }
                                       
                                       if(app.BrchName__c !=null){
                                           citySet.add(String.valueOf(app.BrchName__c).toUpperCase()); 
                                       }
                                       
                                    /*
                                    if(app.Applicants__r!=null && !app.Applicants__r.isEmpty()){
                                    for(Applicant__c appObjFromList :app.Applicants__r){
                                    appIds.add(appObjFromList.Id);
                                    }
                                    }*/
                                       
                                       //Improved Logic
                                       appIds.addAll(app.Applicants__r != null && !app.Applicants__r.isEmpty() ? new Map<Id, Applicant__c>(app.Applicants__r).keySet() : new Set<Id>());
                                       loanAppName=app.Name !=null ? app.Name :'';
                                   }
        }
        

        
        
        List<Case> allCases = [SELECT Id, CaseNumber, ReportResult__c, RecordType.Name, Total_Valuation_Land_Valuation_B__c, 
        Account.AgencyCode__c, Date_of_Report__c, CreatedDate 
        FROM Case 
        WHERE (RecordType.Name = 'TSR' OR RecordType.Name = 'Technical' OR RecordType.Name = 'Legal') 
        AND Status = 'Closed' and Date_of_Report__c!=null
        AND ApplAssetId__c IN :IdAssets ORDER BY Date_of_Report__c DESC]; // not expired 
        
        
        Case latestTSRCase;
        Case latestLegalCase;
        List<CaseWrapper> technicalCaseWrappers = new List<CaseWrapper>();
        
        for (Case caseRecord : allCases) {
            if (caseRecord.RecordType.Name == 'TSR') {
                if (latestTSRCase == null || caseRecord.Date_of_Report__c > latestTSRCase.Date_of_Report__c) {
                    latestTSRCase = caseRecord;
                }
            } else if (caseRecord.RecordType.Name == 'Legal') {
                if (latestLegalCase == null || caseRecord.Date_of_Report__c > latestLegalCase.Date_of_Report__c) {
                    latestLegalCase = caseRecord;
                }
            } else if (caseRecord.RecordType.Name == 'Technical') {
                technicalCaseWrappers.add(new CaseWrapper(caseRecord));
            }
        }
        
        // Sort the list of technical case wrappers by Date_of_Report__c in descending order
        technicalCaseWrappers.sort();
        
        // Extract the top two latest technical cases
        List<Case> latestTechnicalCases = new List<Case>();
        for (Integer i = 0; i < Math.min(2, technicalCaseWrappers.size()); i++) {
            latestTechnicalCases.add(technicalCaseWrappers[i].caseRecord);
        }

        for (Case techCase : latestTechnicalCases) {
            if(techCase!=null){
                System.debug('latest technical: ' + techCase.CaseNumber);
            }
            
        }
        
        List<PD__c> listOfPerDiscn =[Select Id,PDRmrks__c,Appl__r.FullName__c,CmpltDt__c, AsgnTo__r.Name, Appl__r.TabName__c,AsgnTo__r.EmployeeNumber, SchDate__c, PDStatus__c, (SELECT Ques__c, Resp__c FROM PD_Responses__r WHERE Ques__c IN ('Overall PD Remarks','Name of Person with whom PD was conducted','PD Done At','PD Conducted Date','Total Employee Strength','Overall PD Comfort','Name of Employee Conducting PD','Employee No of Employee conucting PD','PD Closure Date','Total Number of Employees working in Organization')) FROM PD__c Where  PDStatus__c != 'Withdrawn' and IsCompleted__c =true  and LoanAppl__c IN : loanApplnIds order by createddate desc];
        List<DocDtl__c> listDocumentsByLoanId = [Select id,Name,LAN__c,OSV__c,DocStatus__c,TargetDt__c,ReceivedDt__c,DocSubTyp__c,DocMstr__r.DocId__c,DocDes__c,DocMstr__r.Catgry__c,Rmrk__c  from DocDtl__c  where DocMstr__r.Catgry__c in ('Additional Post Sanction Documents','Mandatory Post Sanction Documents', 'Property Documents','Sanction Condition Documents') and LAN__c =: loanApplnIds[0]];
        
        
        //List<Bureau__c> listCibil =[SELECT Id, name,Score__c  from Bureau__c where IsLatest__c =true and Applicant__c IN :appIds];
        finalUnqNum=loanAppName +'#'+intMsgNum;
        
        /* 
                            not needed as captured id in previous loop
                            for(Applicant__c applcnt : [SELECT ID FROM Applicant__c where LoanAppln__c  in : loanApplnIds]){
                            appIds.add(applcnt.Id);
        }*/
        
        
        List<Decimal> lisOfNums = new List<Decimal>();
        Decimal overallMaxValueAppBankDtls = 0;
        Decimal overallMinValueAppBankDtls = 0;
        
        //(select id,Name,LAN__c,OSV__c,DocStatus__c,TargetDt__c,ReceivedDt__c,DocMstr__r.DocId__c,DocMstr__r.DocType__c,DocDes__c from Applicant_Document_Details__r)  Removed 
        if(appIds!=null && !appIds.isEmpty())
        {
            for(Applicant__c app : [SELECT ID,Name,Residential_Status__c,LatestyearforwhichITRisavailable__c,ApplType__c,DrivingLicExpDate__c,Type_of_Borrower__c,Constitution__c,CompanyName__c,
                                    (Select Id,Agricultural_Income_Year__c,Agricultural_Yearly_Income__c, Salary__c, Net_Salary__c, Month3_Rental_Credited_Amount__c, Month2_Rental_Credited_Amount__c, Month1_Rental_Credited_Amount__c, 
                                     Monthly_Pension_Credited__c, Applicant__c, RecordType.DeveloperName,Month__c,Monthly_Other_Income__c,NET_CASH_PROFIT_LOSS__c FROM Applicant_Income__r where Applicant__c!=null AND RecordTypeId !=null) , 
                                    (Select id,name,PassExpDt__c,kycDoc__c,PassNo__c from Applicant_KYC__r where kycDoc__c ='Passport' and PassNo__c !=null and PassExpDt__c!=null),
                                    (Select Id,Applicant__c,MailAddr__c,StabAtAddressMnth__c,StabAtAddressYr__c,Country__c,OwnType__c,AddrStability__c,AddrTyp__c,City__c,State__c,AddrLine1__c,AddrLine2__c,Landmark__c,Pincode__c,Locality__c,HouseNo__c,Applicant__r.ApplType__c  FROM Applicant_Addresses__r order by AddrTyp__c asc),
                                    (Select Id,Name,Prop_Owners__c,City__c,Landmark__c,FlatNo__c,ValuationToBeTakenAheadForCalculation__c,PropType__c,PropIdentified__c FROM Applicant_Assets__r),
                                    (SELECT id,RecordType.name,LoanApplication__c,Applicant__c,ConsiderObligation__c,NatureOfLoan__c,LoanName__c,Source__c,EMI__c,CloseDate__c,LoanAmount__c,FinancierName__c,TenureLeft__c,NoEMIPaid__c,CurrentOs__c,LoanApplication__r.Add_Another_Loan__c,Tenure__c,TotalBouncesInRTR__c,Treatment__c from BureauRespDtl__r  where RecordType.name= 'Consumer Obligation' and Treatment__c IN ('To continue - Obligate','BT loan'))
                                    ,(Select Id,TypeOfOrganisation__c,DesignationValues__c,WorkingWithCurrentEmployer_Years__c,EmployerName__c,TotalWorkExperience_Months__c,TotalWorkExperience_Years__c,SubIndustry__r.Industry__r.IndustryID__c,SubIndustry__r.Name,SubIndustry__r.SubIndustryID__c,CurrentBusinessVintage_Months__c,NatureOfBusinessIndividual__c,IndustryType__r.Name,EmployerName__r.Name,NatureOfBusinessCorporate__c ,GST_Registered__c,EmployerName__r.EmployerId__c,Others__c,EntityName__c,IndustryType__r.IndustryID__c from Applicant_Employments__r),
                                    //(select Id,GSTIN__c,RegisteredAddress_GST__c,Main_GSTIN__c,Applicant__r.Id,Applicant__r.ApplType__c,Applicant__r.FullName__c from Applicant_GST__r where Main_GSTIN__c = true),
                                    (SELECT Id, name,Score__c  from Bureau_Responses__r where IsLatest__c =true limit 1), 
                                    (SELECT id,AC_No__c,AccountType__c,TotalOutwardReturnCount__c,TotalInwardReturnCount__c,Bank_Branch__c,BankName__c,Bank_City__c,MICR_Code__c,SFDCBankMaster__c,SFDCBankMaster__r.BankCode__c,AverageBankBalance__c,SFDCBankMaster__r.BankName__c 
                                     from Applicant_Banking1__r where Appl__r.Type_of_Borrower__c ='Financial' and Type__c = null)
                                    FROM Applicant__c WHERE Id IN:appIds])
            {
                appIncomeMap.put(app.Id,app.Applicant_Income__r);  
                appAddMap.put(app.Id,app.Applicant_Addresses__r);
                appAssetMap.put(app.Id,app.Applicant_Assets__r);
                appEmpMap.put(app.Id,app.Applicant_Employments__r);
                //appGstMap.put(app.Id,app.Applicant_GST__r);
                appBankingMap.put(app.Id,app.Applicant_Banking1__r);
                //applyDocDtlsMap.put(app.Id,app.Applicant_Document_Details__r);
                appKycsMap.put(app.Id,app.Applicant_KYC__r);
                appBureauMapByApplicant.put(app.Id,app.BureauRespDtl__r);
                cibilScoreByAppMap.put(app.Id,app.Bureau_Responses__r);
                
                if(app.Constitution__c !=null && app.ApplType__c!=null)
                {
                    
                    if(!String.valueOf(app.Constitution__c).equalsIgnoreCase('INDIVIDUAL'))
                    {
                        System.debug('Non Individual AppIdList condition true');
                        nonIndivAppIdList.add(app.Id);
                    }
                    if(String.valueOf(app.Constitution__c).equalsIgnoreCase('INDIVIDUAL') && (String.valueOf(app.ApplType__c).equalsIgnoreCase('P') || String.valueOf(app.ApplType__c).equalsIgnoreCase('C')))
                    {
                        System.debug('Individual AppIdList condition true');
                        indivAppIdList.add(app.Id);
                    }
                    
                    
                }
                
                if(app.Applicant_Employments__r!=null && !app.Applicant_Employments__r.isEmpty()){
                    for(ApplicantEmployment__c appEmployment: app.Applicant_Employments__r)
                    {
                        if(appEmployment.IndustryType__r.name !=null){
                            industryVal.add(appEmployment.IndustryType__r.name);
                        }
                    }
                }
                
                
                if(app.Applicant_Addresses__r!=null && !app.Applicant_Addresses__r.isEmpty())
                {
                    
                    for(ApplAddr__c appAdd: app.Applicant_Addresses__r)
                    {
                        if(appAdd.City__c !=null)
                        {
                            citySet.add(String.valueOf(appAdd.City__c).toUpperCase());
                        }
                        if(appAdd.Locality__c !=null)
                        {
                            citySet.add(String.valueOf(appAdd.Locality__c).toUpperCase());
                        } 
                        
                    }    
                    
                }
                
                if(app.Applicant_Assets__r!=null && !app.Applicant_Assets__r.isEmpty()){                    
                    for(ApplAsset__c appAsset: app.Applicant_Assets__r)
                    {
                        if(appAsset.City__c !=null)
                        {
                            citySet.add(String.valueOf(appAsset.City__c).toUpperCase());
                        }    
                    }
                }
                
                if(app.Applicant_Banking1__r !=null && !app.Applicant_Banking1__r.isEmpty()){                    
                    for(ApplBanking__c appbankObj: app.Applicant_Banking1__r)
                    {
                        
                        if(appbankObj.BankName__c !=null)
                        {
                            bankSet.add(appbankObj.BankName__c);
                        }  
                        
                        //adding branch name in Set
                        /*if(appbankObj.Bank_Branch__c !=null){
                        micrBrnchSet.add(appbankObj.Bank_Branch__c); 
                        }*/
                        
                        if(appbankObj.MICR_Code__c !=null){
                            micrBrnchSet.add(appbankObj.MICR_Code__c); 
                        }
                        
                        if(appbankObj.Bank_City__c !=null){
                            
                            citySet.add(String.valueOf(appbankObj.Bank_City__c).toUpperCase());
                        }
                    }
                }
            }
            if(individualApplicantCount>0){
                Decimal tempSharingHolderPercent = 100/individualApplicantCount;
                individualSharingHolderPercent = tempSharingHolderPercent.setScale(0, RoundingMode.HALF_UP);
            }
        }
        
        
        if(indivAppIdList !=null && !indivAppIdList.isEmpty()){
            idForOwPer=indivAppIdList[0];
        }
        
        
        
        List<ApplBankDetail__c> listForAppBankDtls =[Select id,name,ApplBanking__r.Appl__c,Month__c,ApplBanking__c,BalanceAt_1st__c,BalanceAt_5th__c,BalanceAt_10th__c,BalanceAt_15th__c,BalanceAt_20th__c,BalanceAt_25th__c from ApplBankDetail__c  where ApplBanking__r.LoanAppl__c IN  : loanApplnIds ];
        //List<ApplBankDetail__c> listForAppBankDtls =[Select id,name,ApplBanking__r.Appl__c,Month__c,ApplBanking__c,BalanceAt_1st__c,BalanceAt_5th__c,BalanceAt_10th__c,BalanceAt_15th__c,BalanceAt_20th__c,BalanceAt_25th__c from ApplBankDetail__c  where ApplBanking__c IN  : IdsForAppBank ];
        
        
        for (ApplBankDetail__c detail : listForAppBankDtls) 
        {
            if(detail.Month__c !=null){
                // Collect balances into a list
                Decimal[] balances = new Decimal[]{
                    detail.BalanceAt_1st__c,
                        detail.BalanceAt_5th__c,
                        detail.BalanceAt_10th__c,
                        detail.BalanceAt_15th__c,
                        detail.BalanceAt_20th__c,
                        detail.BalanceAt_25th__c
                        };
                        // Compute max and min balances for the current detail and update the overall max and min
                        Map<String, Decimal> maxMinValues = LoanBoardingUtility.computeOverallMaxMin(balances);
                
                lisOfNums.add(maxMinValues.get('MaxValue'));
                lisOfNums.add(maxMinValues.get('MinValue'));
                
                
            }
            
        }
        
        
        if(lisOfNums !=null && !lisOfNums.isEmpty()){
            Map<String, Decimal> maxMinValues1 = LoanBoardingUtility.computeOverallMaxMin(lisOfNums);
            overallMaxValueAppBankDtls = (maxMinValues1!=null) ? maxMinValues1.get('MaxValue'):0;
            overallMinValueAppBankDtls = (maxMinValues1!=null) ? maxMinValues1.get('MinValue'):0;
        }
        
        
        List<Applicant_Financial_Summary__c> listAppliFinSum=[Select id,PAT__c,Applicant_Financial__c, Applicant_Financial__r.RecordTypeId, Applicant_Financial__r.RecordType.DeveloperName, Applicant_Financial__r.Loan_Applicant__c,
                                                              Financial_Year__c 
                                                              from Applicant_Financial_Summary__c 
                                                              where Applicant_Financial__c !=null AND Applicant_Financial__r.RecordTypeId != null AND Applicant_Financial__r.RecordType.DeveloperName = 'Profit_Loss' AND  
                                                              Applicant_Financial__r.Loan_Applicant__c !=null AND Applicant_Financial__r.Loan_Applicant__c IN : appIds]; 
        
        
        //For GST details calculation
        ApplGST__c finalGSTObj;
        ApplAddr__c finalAddress;
        ApplicantEmployment__c finalAppEmpObj;   
        
        for(ApplGST__c appGstEach: [SELECT Id,Locality__c,Landmark__c,HouseNo__c,AddrLine1__c, AddrLine2__c, City__c, Pincode__c, State__c, LastSelectedAddrType__c,Applicant_Address__c ,Applicant__r.UCID__c,Applicant__r.Type_of_Borrower__c,Applicant__r.CustProfile__c,GSTIN__c,RegisteredAddress_GST__c,
                                    Main_GSTIN__c,Applicant__c,Applicant__r.ApplType__c,Applicant__r.FullName__c from ApplGST__c where Main_GSTIN__c = true and Applicant__c IN : appIds and Applicant__r.ApplType__c IN ('P','C') and Applicant__r.Type_of_Borrower__c ='Financial' and Applicant__r.CustProfile__c In ('SELF EMPLOYED NON PROFESSIONAL','SELF EMPLOYED PROFESSIONAL' ) ORDER BY  Applicant__r.ApplType__c DESC] ){
                                        
                                        if(appGstEach !=null && appGstEach.City__c !=null ){
                                            citySet.add(String.valueOf(appGstEach.City__c).toUpperCase());
                                            System.debug('City by GST::'+ appGstEach.City__c);
                                        }
                                        
                                        if((appEmpMap.containsKey(appGstEach.Applicant__c)) && (appEmpMap.get(appGstEach.Applicant__c) !=null && !appEmpMap.get(appGstEach.Applicant__c).isEmpty()) && (appEmpMap.get(appGstEach.Applicant__c)[0].GST_Registered__c == 'YES')){
                                            
                                            finalAppEmpObj= appEmpMap.get(appGstEach.Applicant__c)[0];   
                                            
                                            if(appGstEach.Applicant__r.ApplType__c == 'P' ){
                                                finalGSTObj = appGstEach;
                                                break;
                                            }
                                            if(finalGSTObj == NULL){
                                                finalGSTObj= appGstEach;
                                            }
                                        }
                                        
                                    }
        
        if(finalGSTObj!=null){
            for(ApplAddr__c appAddressEach: [Select Id,Applicant__c,StabAtAddressMnth__c,StabAtAddressYr__c,MailAddr__c,Country__c,OwnType__c,AddrStability__c,AddrTyp__c,City__c,State__c,AddrLine1__c,AddrLine2__c,Landmark__c,Pincode__c,Locality__c,HouseNo__c,Applicant__r.ApplType__c  FROM ApplAddr__c where Applicant__c =: finalGSTObj.Applicant__c] ){
                
                if(appAddressEach.AddrTyp__c == 'Principal place for business'){
                    finalAddress = appAddressEach;
                    break;
                }else if(appAddressEach.AddrTyp__c == 'Residence Cum office' && finalAddress == NULL){
                    finalAddress = appAddressEach;
                }
            }
        }else{
            System.debug('No gst record found');
        }
        
        
        if(loanApplnIds != null && !loanApplnIds.isEmpty())
        {
            for(ID eachLoanAppId: loanApplnIds)
            {     
                if(loanAppMap.get(eachLoanAppId)!=null && !loanAppMap.get(eachLoanAppId).isEmpty()){
                    
                    for(Applicant__c eachApp:loanAppMap.get(eachLoanAppId))
                    {
                        if(eachApp.ApplType__c =='P'){
                            priAppId=eachApp.ID;
                            ucidPriApp=eachApp.UCID__c != null ? eachApp.UCID__c :'';
                        }
                    }
                    
                }
                
            }
        }
        
        List<Industry__c> liInd= [Select Id,name,IndustryID__c from Industry__c where name IN : industryVal];
        
        if(liInd!=null && !liInd.isEmpty()){
            for(Industry__c industryName : liInd){
                industryNameMap.put(industryName.Name ,industryName);
            }
        }
        
        //Query Optimized
        List<BRE__c> listBre=[select Id,EMI__c from BRE__c where IsLatest__c =true AND EligibilityType__c = 'Application' AND LoanAppl__c IN: loanApplnIds];
        
        if(listBre !=null && !listBre.isEmpty())
        {
            emiLoan= String.valueOf(listBre[0].EMI__c);
        }
        
        LoanAppl__c loanObject= loanAppRecordsMap.get(loanApplnIds[0]);
        String loanRmsmName= loanObject.RMSMName__c !=null ? loanObject.RMSMName__c :null;
        String loanChannelName;
        if(loanObject.ChanelNme__c !=null)
        {
            loanChannelName=loanObject.ChanelNme__c;
        }
        //String loanChannelName=  ? loanObject.ChanelNme__c :'';
        
        List<DSABrchJn__c> listDsaBrnchJun;
        List<DSABrchJn__c> listDsaBrnchJunOther;
        
        if(loanRmsmName !=null && loanChannelName!=null){
            listDsaBrnchJun = [select id,name,InspectorId__c,RMUsr__c from DSABrchJn__c  where RMUsr__c =: loanRmsmName and Account__c =: loanChannelName];    
        }
        
        if(loanRmsmName !=null){
            listDsaBrnchJunOther = [select id,name,InspectorId__c,RMUsr__c from DSABrchJn__c  where RMUsr__c =: loanRmsmName and Account__r.DSAConnId__c='21'];    
        }
        
        List<Repayment_Account__c> listRepayAccounts = [Select Id,Applicant_Banking__r.PDC_by_Name__c,Account_Number__c,MICR_Code__c,Applicant_Banking__r.Appl__r.ApplType__c,Bank_Branch__c,Bank_Name__c,Applicant_Banking__r.Bank_City__c,Applicant_Banking__r.AccountType__c,Deactivate_Date__c,Applicant_Banking__r.Bank_Code__c,IFSC_Code__c,Repayment_Mode__c from Repayment_Account__c where Is_Active__c =true  AND Loan_Application__c  IN : loanApplnIds ];
        if(listRepayAccounts!=null && !listRepayAccounts.isEmpty()){
            for(Repayment_Account__c eachRepayAc : listRepayAccounts)
            {
                if(!String.isBlank(eachRepayAc.Applicant_Banking__r.Bank_City__c)){
                    //System.debug('String.valueOf(eachRepayAc.Applicant_Banking__r.Bank_City__c).toUpperCase():'+String.valueOf(eachRepayAc.Applicant_Banking__r.Bank_City__c).toUpperCase());
                    citySet.add(String.valueOf(eachRepayAc.Applicant_Banking__r.Bank_City__c).toUpperCase());
                }
                repayId.add(eachRepayAc.Id);
                
            }
        }
        
        
        Integer countDisbur =0;
        String disbIdVal ='';
        
        List<Disbursement__c> listDisbNSplitDis =[select id,Total_Disb_Amt__c,Date_of_Disbur__c,No_of_Disbur__c,Princ_Start_Date__c,Princ_Rec_on__c,(select Id,Effec_Date__c,IFSC_Detail__c,Split_Cheque_Amt__c,Fedbank_Acc_No__c,Custo_Name__c,Cheq_Favor_Acc_No__c,Remarks__c,Cheq_DD_Date__c,Disbur_To__c,Cheq_Favor_Dets__c,Payable_At__c,Fund_Transf_Mode__c,Pay_Mode__c,Date_of_Disbur__c,Cheq_DD_No__c,Fedbank_Acc_Nm__c from Split_Disbursements__r) from Disbursement__c where Loan_Appli__c IN: loanApplnIds and Disbur_No__c =1 order by LastModifiedDate desc LIMIT 1];
        
        
        Decimal totalAmtToSendDisb=0;
        Decimal totalDisbsAmt =0;
        
        
        List<Split_Disbur__c> listOfSplitDisb = new List<Split_Disbur__c>();
        
        if(listDisbNSplitDis !=null && !listDisbNSplitDis.isEmpty()){
            
            totalDisbsAmt = listDisbNSplitDis[0].Total_Disb_Amt__c !=null ? listDisbNSplitDis[0].Total_Disb_Amt__c :0;
            for(Disbursement__c disB : listDisbNSplitDis ){
                disbIdVal=disB.Id;
                countDisbur++;
                for(Split_Disbur__c spDisb :disB.Split_Disbursements__r){
                    listOfSplitDisb.add(spDisb);
                    if(spDisb.Payable_At__c !=null){
                        citySet.add(String.valueOf(spDisb.Payable_At__c).toUpperCase()); 
                    }
                }
            }
            
        }
        
        
        //Utility Lists
        //List<LoanPurpose__c> listLoanPurpose =[Select ID,Value__c from LoanPurpose__c where Name =: loanAppRecordsMap.get(loanApplnIds[0]).LoanPurpose__c and ProdType__c = : loanAppRecordsMap.get(loanApplnIds[0]).Product__c];
        //List<LoanPurpose__c> listLoanPurpose =[Select ID,Value__c from LoanPurpose__c where Name =: loanAppRecordsMap.get(loanApplnIds[0]).LoanPurpose__c and ProdType__c INCLUDES(:loanAppRecordsMap.get(loanApplnIds[0]).Product__c)];
        List<LoanPurpose__c> listLoanPurpose =[Select ID,Value__c from LoanPurpose__c where ID =: loanAppRecordsMap.get(loanApplnIds[0]).LoanPurposeID__c];
        List<BankBrchMstr__c> listBrnchCode =[Select Id,OffcCode__c,SourcingBranchCode__c  from BankBrchMstr__c where BrchCode__c=: loanAppRecordsMap.get(loanApplnIds[0]).BrchCode__c];
        List<SchMapping__c> listScheme=[select id,SchmId__c,ProductType__c,ISBT__C from SchMapping__c where Id =: loanAppRecordsMap.get(loanApplnIds[0]).SchemeId__c];
        
        
        
        List<PDC__c> liPdc =[Select Id,Name,Repayment_Account__r.Applicant_Banking__r.PDC_by_Name__c from PDC__c where Loan_Application__r.Applicant__c =: priAppId];
        
        
        //Master Related Data fetch
        List<LocMstr__c> liLocMaster =[select ID,State__c,StateId__c ,City__c, CityId__c,StateGSTId__c from LocMstr__c where City__c IN : citySet]; 
        // List<BankMstr__c> liBankMast =[Select Id,name,BankId__c, BankCode__c from BankMstr__c where name in : bankSet]; //where name in : bankSet]; //where take all bank Ids 
        List<MICRCodeMstr__c> liMicrMast =[Select Id,name ,Bank__r.BankId__c, BanckBrchId__c, Bank__c, BrchName__c, City__c,City__r.CityId__c  from MICRCodeMstr__c where MICRCode__c IN : micrBrnchSet];
        //List<LocBrchJn__c> liLocBrnchMaster =[Select id,Location__r.City__c,Location__r.CityId__c from LocBrchJn__c where Branch__r.name IN : citySet ];
        
        
        // for(BankMstr__c bankObj : liBankMast){
        //     bankMstrMap.put(bankObj.name ,bankObj);
        // }
        
        for(LocMstr__c eachLocMas :liLocMaster){
            mapLocMas.put( String.valueOf(eachLocMas.City__c).toUppercase() ,eachLocMas);
        }
        
        // for(LocBrchJn__c eachLocBrnchMas :liLocBrnchMaster){
        //     mapLocBrnchMas.put(eachLocBrnchMas.Location__r.City__c ,eachLocBrnchMas);
        // }
        
        for(MICRCodeMstr__c eachMicrObj: liMicrMast){
            micrMstrMap.put(eachMicrObj.BrchName__c	,eachMicrObj);
        }
        
        
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
        Id loanIdForPromotion =loanAppPromo.PromotionId__c !=null ? loanAppPromo.PromotionId__c :null;


        //String promDescVal= loanAppPromo !=null ? loanAppPromo.PromCode__c :'';
        //String prodTypeVal=loanAppPromo !=null ? loanAppPromo.Product__c :'';
        
        //List<PromoMapping__c> listPromotion=[Select Id,name,PromoDesc__c, PromoId__c,ProductType__c from PromoMapping__c where PromoDesc__c =:promDescVal and 
        //                                     ProductType__c =:prodTypeVal];

        List<PromoMapping__c> listPromotion =[Select id,PromoId__c from PromoMapping__c where id =: loanIdForPromotion];                                     
        
        try
        {
            
            List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>(); 
            
            if(!msgs.isEmpty()){
                
                for(IntgMsg__c intMsg : msgs){
                    
                    if(loanAppMap.containsKey(intMsg.RefId__c)){
                        
                        //SplitDisbursalDetails start
                        List<LoanBoardingRequestWrapper.SplitDisbursalDetails> listSplitDis=LoanBoardingUtility.processDisbursements(listDisbNSplitDis,masterDataMap,mapLocMas,monthMap);
                         
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
                        srcDetail.scheme = (listScheme !=null && !listScheme.isEmpty())  ? listScheme[0].SchmId__c !=null ?listScheme[0].SchmId__c :'' :'';// dataLoanApp.SchmCode__c !=null ?dataLoanApp.SchmCode__c:''; //'556'; //manish suggested
                        srcDetail.finnoneUser = System.Label.LoanB_finnoneUser;  
                        srcDetail.finnoneStage = System.Label.LoanB_FinnoneStage ;  
                        srcDetail.dateOfDisbursal =''; 
                        srcDetail.referralName =''; 
                        srcDetail.referralGroup =''; 
                        srcDetail.sourceCode = ''; 
                        srcDetail.applicationFormNo = dataLoanApp.FinnoneAppid__c !=null ? 'SFDC_'+dataLoanApp.FinnoneAppid__c :'';// 	GlobalUtility.getUniqueNumber();
                        //srcDetail.referralCode = dataLoanApp.ChanelNme__r.VCReferralId__c !=null ? dataLoanApp.ChanelNme__r.VCReferralId__c : '';  
                        
                        
                        srcDetail.referralCode = dataLoanApp.ChanelNme__r.VCReferralCode__c !=null ? dataLoanApp.ChanelNme__r.VCReferralCode__c : ''; 
                        
                        
                        srcDetail.reasonSpecialCondition =''; //blank
                        srcDetail.crmExistingLan =''; 
                        
                        srcDetail.loanPurpose = (listLoanPurpose !=null && !listLoanPurpose.isEmpty() ) ? listLoanPurpose[0].Value__c != null ? listLoanPurpose[0].Value__c :'' :''; // dataLoanApp.LoanPurpose__c!=null ? dataLoanApp.LoanPurpose__c :''; //master hardcoded
                        srcDetail.custProfile =''; //blank
                        srcDetail.tenureInMonths = String.valueOf(dataLoanApp.Loan_Tenure_Months__c)!=null ? String.valueOf(dataLoanApp.Loan_Tenure_Months__c) : '' ;     //'180'; 
                        srcDetail.relationshipManager = '';// dataLoanApp.RMSMEmployeeID__c!=null?dataLoanApp.RMSMEmployeeID__c:'';  //can be blank
                        srcDetail.applicationID = String.valueOf(dataLoanApp.FinnoneAppid__c)!=null ?String.valueOf(dataLoanApp.FinnoneAppid__c):''; 
                        srcDetail.existingCustomerName =''; 
                        srcDetail.channelCode = masterDataMap.get('Channel') !=null ? String.valueOf(masterDataMap.get('Channel').get(dataLoanApp.LeadSource__c))!=null  ? String.valueOf(masterDataMap.get('Channel').get(dataLoanApp.LeadSource__c)) : '':''; //Please add hardcoded
                        srcDetail.branchId =(listBrnchCode !=null && !listBrnchCode.isEmpty()) ? listBrnchCode[0].OffcCode__c !=null ?listBrnchCode[0].OffcCode__c:'':''; 
                        
                        
                        srcDetail.reasonDescription =''; 
                        if(masterDataMap.get('Product') !=null)
                        {
                            
                            srcDetail.product =String.valueOf(masterDataMap.get('Product').get(dataLoanApp.Product__c));
                            
                        }
                        else
                        {
                            srcDetail.product = '';
                        }
                        
                        srcDetail.custProfileType ='P';//Hardcoded OK
                        srcDetail.bankBranch =''; 
                        srcDetail.resaonComments =''; //blank
                        srcDetail.dateEncoded =dataLoanApp.CreatedDate !=null ? String.valueOf(dataLoanApp.CreatedDate.day()) + '-' + monthMap.get(dataLoanApp.CreatedDate.month()) + '-' + String.valueOf(dataLoanApp.CreatedDate.year()) :'';//String.valueOf(dataLoanApp.CreatedDate)!=null ?String.valueOf(dataLoanApp.CreatedDate) :'';  
                        srcDetail.priority =''; 
                        srcDetail.promotionCurr =''; 
                        srcDetail.accountOfficeName =''; 
                        srcDetail.loanAmount =String.valueOf(dataLoanApp.TotalLoanAmtInclInsurance__c)!=null ?String.valueOf(dataLoanApp.TotalLoanAmtInclInsurance__c):''; 
                        srcDetail.branchCode = '';   
                        srcDetail.specialConditionFor =''; 
                        srcDetail.sourcingBranch = (listBrnchCode !=null && !listBrnchCode.isEmpty()) ? String.valueOf(listBrnchCode[0].SourcingBranchCode__c ) : '' ; 
                        
                        if(dataLoanApp.LeadSource__c !=null){
                            if(String.valueOf(dataLoanApp.LeadSource__c).equalsIgnoreCase('DSA'))
                            { 
                                srcDetail.dsa =dataLoanApp.ChanelNme__r.DSAConnId__c !=null ? dataLoanApp.ChanelNme__r.DSAConnId__c :'';
                            }
                            else if(String.valueOf(dataLoanApp.LeadSource__c).equalsIgnoreCase('Connector'))
                            {
                                srcDetail.dsa = '';//dataLoanApp.ChanelNme__r.VCReferralId__c !=null ? dataLoanApp.ChanelNme__r.VCReferralId__c : ''; //Sending Blank As per LAK-7405
                            }
                            else
                            {
                                srcDetail.dsa ='21';
                            } 
                        }
                        else{
                            srcDetail.dsa ='';
                        }
                        
                        
                        srcDetail.dateOfReceipt =dataLoanApp.CreatedDate!=null ? String.valueOf(dataLoanApp.CreatedDate.day()) + '-' + monthMap.get(dataLoanApp.CreatedDate.month()) + '-' + String.valueOf(dataLoanApp.CreatedDate.year()) :'';//String.valueOf(dataLoanApp.CreatedDate)!=null ?String.valueOf(dataLoanApp.CreatedDate):''; 
                        srcDetail.accountOfficerCode =''; 
                        
                        if(dataLoanApp.LeadSource__c !=null){
                            if(dataLoanApp.LeadSource__c =='DSA' || dataLoanApp.LeadSource__c =='Connector'){
                                
                                /*if(listDsaBrnchJun!=null && !listDsaBrnchJun.isEmpty()){
                                srcDetail.dme = listDsaBrnchJun[0].InspectorId__c !=null ? listDsaBrnchJun[0].InspectorId__c:'';
                                System.debug('listDsaBrnchJun : and if condition:: srcDetail.dme:'+srcDetail.dme);
                                }*/
                                if(listDsaBrnchJunOther!=null && !listDsaBrnchJunOther.isEmpty())
                                {
                                    srcDetail.dme = listDsaBrnchJunOther[0].InspectorId__c !=null ? listDsaBrnchJunOther[0].InspectorId__c:'';
                                    
                                } 
                                else{
                                    srcDetail.dme ='';
                                }
                            }
                            else{
                                if(listDsaBrnchJunOther!=null && !listDsaBrnchJunOther.isEmpty())
                                {
                                    srcDetail.dme = listDsaBrnchJunOther[0].InspectorId__c !=null ? listDsaBrnchJunOther[0].InspectorId__c:'';
                                    
                                }    
                                else
                                {
                                    srcDetail.dme ='';
                                }
                            }
                            
                        }else{
                            srcDetail.dme ='';
                        }    
                        
                        
                        srcDetail.sourceState =''; 
                        
                        if(listPromotion!=null && !listPromotion.isEmpty()){
                            System.debug('srcDetail.promotion ='+listPromotion[0].PromoId__c);
                        }
                        
                        if(listPromotion!=null && !listPromotion.isEmpty())
                        {
                            srcDetail.promotion = listPromotion[0].PromoId__c !=null ? listPromotion[0].PromoId__c :'';
                        }
                        else
                        {
                            srcDetail.promotion ='';
                        }
                        //SourcingDetail end
                        
                        //RateRiskDetails start blank    
                        List<LoanBoardingRequestWrapper.RateRiskDetails> listRateRiskDetails =LoanBoardingUtility.createBlankRateRiskDetails();
                        
                        //ReferenceDetails start
                        List<LoanBoardingRequestWrapper.ReferenceDetails> listRefdetails= new List<LoanBoardingRequestWrapper.ReferenceDetails>();
                        List<Ref__c> listRefObjs =LoanBoardingUtility.getAllReference(appRefMapByLoanApp.get(loanApplnIds[0]));
                        
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
                                refDetails.refTitle = eachRefObj.Title__c !=null ?  String.valueOf(eachRefObj.Title__c).removeEnd('.')  :''; //      'Mr'; //harcoded as it is not captured in sfdc
                                
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
                                chrDetails.chargeAmount =String.valueOf(chrgObj.EffeChrgeAmt__c) !=null ? String.valueOf(chrgObj.EffeChrgeAmt__c) : ''; 
                                chrDetails.chargeToBeFinanced ='N';
                                listChrdetails.add(chrDetails);
                            }
                        }
                        //********** For 68 Code Logic ***************//
                        
                        if(loanAppRecordsMap.get(loanApplnIds[0]) !=null)
                        {
                            // if(loanAppRecordsMap.get(loanApplnIds[0]).RemPFDeductFromDisbursementAmount__c == 'Yes')
                            //{
                            LoanBoardingRequestWrapper.ChargesDetails chrDetails2=new LoanBoardingRequestWrapper.ChargesDetails();
                            chrDetails2.chargeCalculatedOn = 'AMT FINANCED'; 
                            chrDetails2.chargeId = '68';
                            chrDetails2.periodicCharge ='N'; 
                            
                            if(loanAppRecordsMap.get(loanApplnIds[0]).PreEmiType__c !=null && !String.isEmpty(loanAppRecordsMap.get(loanApplnIds[0]).PreEmiType__c) && loanAppRecordsMap.get(loanApplnIds[0]).PreEmiType__c == 'C'){
                                //if(loanAppRecordsMap.get(loanApplnIds[0]).PreEmiType__c == 'C'){
                                String strAmtPf = String.valueOf(loanAppRecordsMap.get(loanApplnIds[0]).Total_PF_Amount__c) !=null ?String.valueOf(loanAppRecordsMap.get(loanApplnIds[0]).Total_PF_Amount__c) :'0'; 
                                Decimal preEmiAmt =loanAppRecordsMap.get(loanApplnIds[0]).Pre_EMI_Amount__c !=null ? loanAppRecordsMap.get(loanApplnIds[0]).Pre_EMI_Amount__c :0;
                                Decimal pfAmtTotal =  (Decimal.valueOf(strAmtPf) + preEmiAmt) - (loanAppRecordsMap.get(loanApplnIds[0]).ColChrgsAmt__c !=null ? loanAppRecordsMap.get(loanApplnIds[0]).ColChrgsAmt__c: 0 );
                                
                                
                                chrDetails2.chargeAmount = String.valueOf(pfAmtTotal);
                                // }
                            }else{
                                
                                Decimal finalResult= (loanAppRecordsMap.get(loanApplnIds[0]).Total_PF_Amount__c !=null ? Decimal.valueOf(String.valueOf(loanAppRecordsMap.get(loanApplnIds[0]).Total_PF_Amount__c))  : 0 )  - (loanAppRecordsMap.get(loanApplnIds[0]).ColChrgsAmt__c !=null ? loanAppRecordsMap.get(loanApplnIds[0]).ColChrgsAmt__c: 0 ) ;
                                chrDetails2.chargeAmount = String.valueOf(finalResult);
                                Decimal pfAmtTotalNPreEmi = loanAppRecordsMap.get(loanApplnIds[0]).Total_PF_Amount__c;
                                //totalAmtToSendDisb= finalResult +totalDisbsAmt  ;
                            }
                            chrDetails2.chargeToBeFinanced ='N';
                            listChrdetails.add(chrDetails2);
                            //}
                        }
                        
                        //ChargesDetails end
                        
                        //mscInfoDetails start blank
                        LoanBoardingRequestWrapper.MscInfoDetails mscInfoObj =  LoanBoardingUtility.initializeMscInfoDetails();
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
                        List<LoanBoardingRequestWrapper.StakeHolderDetails> listStakDetls = LoanBoardingUtility.createStakeHolderDetails();
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
                        {    
                            tempI++;
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
                            //LAK-7908 
                            instDetails.instrumentCity = '';//locMasterData!=null ? locMasterData.CityId__c !=null ? String.valueOf(locMasterData.CityId__c) :'':''; 
                            instDetails.employeeCode =''; //Blank
                            instDetails.micrFlag =''; //Blank
                            instDetails.instrumentBank =eachRepayAcc.Applicant_Banking__r.Bank_Code__c !=null?eachRepayAcc.Applicant_Banking__r.Bank_Code__c:''; 
                            instDetails.micrCode = eachRepayAcc.MICR_Code__c !=null ? eachRepayAcc.MICR_Code__c :''; 
                            instDetails.instrumentBankBranch =eachRepayAcc.Applicant_Banking__r.Bank_Code__c !=null ?eachRepayAcc.Applicant_Banking__r.Bank_Code__c :'';
                            instDetails.destBankAccType = (masterDataMap.get('Repayment Account Type') !=null && eachRepayAcc.Applicant_Banking__r.AccountType__c !=null ) ? (masterDataMap.get('Repayment Account Type').get(eachRepayAcc.Applicant_Banking__r.AccountType__c) !=null ? masterDataMap.get('Repayment Account Type').get(eachRepayAcc.Applicant_Banking__r.AccountType__c) : '') :'' ; //'10';
                            
                            instDetails.ifscCode =''; //blank 
                            
                            instDetails.pdcByName = eachRepayAcc.Applicant_Banking__r.PDC_by_Name__c !=null ? eachRepayAcc.Applicant_Banking__r.PDC_by_Name__c :'';
                            instDetails.destAccHolder =eachRepayAcc.Applicant_Banking__r.PDC_by_Name__c!=null ? eachRepayAcc.Applicant_Banking__r.PDC_by_Name__c :'';
                            
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
                        //loanDetails start
                        List<ApplAsset__c> listAppAssestforAmount = appAssetMapByLoanApp.get(loanApplnIds[0]); //  [select Id,Total_Prop_Cost__c from ApplAsset__c where LoanAppln__c IN:loanApplnIds];
                        Integer totalPropAmount= 0;
                        
                        Integer totalPropValueAmount= 0;
                        
                        if(listAppAssestforAmount !=null && !listAppAssestforAmount.isEmpty()){
                            for(ApplAsset__c appAsset : listAppAssestforAmount){
                                if(appAsset.Total_Prop_Cost__c !=null && Integer.valueOf(appAsset.Total_Prop_Cost__c) > 0){
                                    totalPropAmount= totalPropAmount + Integer.valueOf(appAsset.Total_Prop_Cost__c); 
                                }
                                if(appAsset.Valuation_as_per_policy_norms__c !=null){
                                    totalPropValueAmount = totalPropValueAmount + Integer.valueOf(appAsset.Valuation_as_per_policy_norms__c);
                                }
                            }        
                        }
                        
                        LoanAppl__c eachLoanAppObj = loanAppRecordsMap.get(intMsg.RefId__c);      
                        LoanBoardingRequestWrapper.LoanDetails lnDetails=new LoanBoardingRequestWrapper.LoanDetails();
                        
                        if(String.valueOf(dataLoanApp.Product__c) == 'Small Ticket LAP' || String.valueOf(dataLoanApp.Product__c) == 'Loan Against Property') 
                        {
                            lnDetails.assetCost =String.valueOf(totalPropValueAmount);
                        }
                        else{
                            lnDetails.assetCost =String.valueOf(totalPropAmount);  
                        }  
                        
                        lnDetails.interestTaxRate =''; //Blank
                        
                        if(eachLoanAppObj.PreEmiType__c !=null && !String.isEmpty(eachLoanAppObj.PreEmiType__c))
                        {
                            lnDetails.pemiType =eachLoanAppObj.PreEmiType__c; 
                        }
                        else{
                            lnDetails.pemiType =''; 
                        }
                        
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
                        lnDetails.disbAmount =  eachLoanAppObj.TotalLoanAmtInclInsurance__c !=null ? String.valueOf(eachLoanAppObj.TotalLoanAmtInclInsurance__c) : '';//eachLoanAppObj.Final_Loan_Disbursal_Amount__c !=null ? String.valueOf(eachLoanAppObj.Final_Loan_Disbursal_Amount__c) :''; //String.valueOf(totalAmtToSendDisb);//String.valueOf(eachLoanAppObj.DisbursedAmount__c!=null ?String.valueOf(eachLoanAppObj.DisbursedAmount__c+eachLoanAppObj.Total_PF_Amount__c):'');
                        lnDetails.installmentMode ='R'; //OK
                        lnDetails.loanPLRRate =String.valueOf(eachLoanAppObj.LoanPLRRate__c)!=null ?String.valueOf(eachLoanAppObj.LoanPLRRate__c): '' ; 
                        lnDetails.addInterestSchedule =eachLoanAppObj.AddIntSchedule__c!=null ?eachLoanAppObj.AddIntSchedule__c: '' ; 
                        lnDetails.disburseTo = 'LS'; //hardcoded OK
                        lnDetails.downPaymentRate =''; //Blank
                        lnDetails.interestRoundOff =''; //Blank
                        lnDetails.rateTypeFloatingFlag =eachLoanAppObj.Rate_Type_Floating_Flag__c!=null ?eachLoanAppObj.Rate_Type_Floating_Flag__c: ''; 
                        lnDetails.addOnRate ='';//Blank
                        lnDetails.effectiveRate =String.valueOf(eachLoanAppObj.EffectiveROI__c!=null ?String.valueOf(eachLoanAppObj.EffectiveROI__c): '');  
                        lnDetails.graceApplicableFlag =eachLoanAppObj.MoratGraceApplicable__c!=null ?eachLoanAppObj.MoratGraceApplicable__c: ''; 
                        lnDetails.interestTax =''; //Blank
                        lnDetails.disbType =  eachLoanAppObj.DisbursalType__c!=null ? String.valueof(eachLoanAppObj.DisbursalType__c).toUppercase(): ''; 
                        lnDetails.floatingFrequency ='0'; //OK
                        
                        if(eachLoanAppObj.MoratGraceApplicable__c == 'Y'){
                            lnDetails.gracePeriod =eachLoanAppObj.MoratGracePeriodMonths__c!=null ? String.valueof(eachLoanAppObj.MoratGracePeriodMonths__c) : ''; 
                        }else{
                            lnDetails.gracePeriod = '';
                        }   
                        
                        if(eachLoanAppObj.DueDay__c!=null && !String.isBlank(eachLoanAppObj.DueDay__c)) 
                        {
                            if(String.valueOf(eachLoanAppObj.DueDay__c).length() == 1 )
                            {
                                lnDetails.dueDay = '0'+eachLoanAppObj.DueDay__c;
                            }else
                            {
                                lnDetails.dueDay = eachLoanAppObj.DueDay__c;
                            }
                        }
                        
                        lnDetails.interestInAdvance =''; //Blank
                        lnDetails.rateEMIFlag = eachLoanAppObj.RateEMIFlag__c !=null ? eachLoanAppObj.RateEMIFlag__c :'';//  'R'; //hardcoded R=>rate E=>EMI M=>Multi Interest rate (Master name=>Rate EMI flag)
                        lnDetails.fisrtEmiDate = eachLoanAppObj.FirstEMIDate__c !=null ?  String.valueOf(eachLoanAppObj.FirstEMIDate__c.day()) + '-' + monthMap.get(eachLoanAppObj.FirstEMIDate__c.month()) + '-' + String.valueOf(eachLoanAppObj.FirstEMIDate__c.year()) :'';//String.valueOf(eachLoanAppObj.FirstEMIDate__c!=null ?String.valueOf(eachLoanAppObj.FirstEMIDate__c): '');   
                        lnDetails.installmentPlan =String.valueOf(eachLoanAppObj.Installment_Plan__c!=null ?eachLoanAppObj.Installment_Plan__c: ''); 
                        lnDetails.principalBaseUnit ='1'; //OK
                        lnDetails.firstEmiDueYear =String.valueOf(eachLoanAppObj.First_EMI_Due_Year_1__c !=null ?eachLoanAppObj.First_EMI_Due_Year_1__c : ''); 
                        lnDetails.channelDSASubvention ='';//Blank
                        lnDetails.impactOnTenure =eachLoanAppObj.ImpactOnTenure__c!=null ?eachLoanAppObj.ImpactOnTenure__c: '';  
                        lnDetails.reqInterestType ='E'; //OK
                        lnDetails.capitalizeInterest ='N'; //OK
                        lnDetails.interestRoundMethod ='';  //Blank
                        lnDetails.spreadID = '';// String.valueOf(eachLoanAppObj.SpreadID__c)!=null ?String.valueOf(eachLoanAppObj.SpreadID__c): '';  
                        lnDetails.loanRest =''; //Blank
                        lnDetails.tdsRate ='0'; //OK
                        lnDetails.chargeInterest =eachLoanAppObj.ChargeInterest__c!=null ?eachLoanAppObj.ChargeInterest__c: ''; 
                        lnDetails.numberOfInstallments =String.valueOf(eachLoanAppObj.Loan_Tenure_Months__c)!=null ?String.valueOf(eachLoanAppObj.Loan_Tenure_Months__c): ''; //     '180'; // Hardcoded  //BRE dependent
                        lnDetails.noOfDisbursal = String.valueOf(countDisbur) ;    //'1';//OK 
                        lnDetails.depositAccount =''; //Blank
                        lnDetails.installmentRoundPrecision ='';//Blank 
                        lnDetails.downpayment =''; //Blank
                        lnDetails.fisrtEmiDueMonth =loanAppRecordsMap.get(loanApplnIds[0]) !=null ? String.valueOf(mapFirstEmiDueMon.get(loanAppRecordsMap.get(loanApplnIds[0]).First_EMI_Due_Month_1__c)) !=Null ? String.valueOf(mapFirstEmiDueMon.get(loanAppRecordsMap.get(loanApplnIds[0]).First_EMI_Due_Month_1__c)) : '':''; 
                        //loanDetails end
                        
                        //personalDiscussion start 
                        List<LoanBoardingRequestWrapper.PersonalDiscussion> listPerDiscussion =new List<LoanBoardingRequestWrapper.PersonalDiscussion>();
                        List<BRE__c> listOfBreObjs= appBreResByLoanApp.get(loanApplnIds[0]);
                        
                        String commonFoir= '';
                        
                        if(listOfBreObjs!=null && !listOfBreObjs.isEmpty()){
                            commonFoir= listOfBreObjs[0].Actual_FOIR__c !=null ? String.valueOf(listOfBreObjs[0].Actual_FOIR__c) :'';
                        }
                        
                        if(listOfPerDiscn!=null && !listOfPerDiscn.isEmpty()){
                            for(PD__c eachPdObj :listOfPerDiscn){
                                LoanBoardingRequestWrapper.PersonalDiscussion perDis=new LoanBoardingRequestWrapper.PersonalDiscussion();
                                perDis.personContacted = eachPdObj.AsgnTo__r.Name !=null ?eachPdObj.AsgnTo__r.Name : '';
                                perDis.dateOfMeeting =eachPdObj.SchDate__c !=null ? String.valueOf(eachPdObj.SchDate__c.day()) + '-' + monthMap.get(eachPdObj.SchDate__c.month()) + '-' + String.valueOf(eachPdObj.SchDate__c.year()) :''; 
                                perDis.interviewerDecision =eachPdObj.PDStatus__c !=null ? eachPdObj.PDStatus__c :'';
                                perDis.nameOfInterviewer =eachPdObj.AsgnTo__r.Name !=null ?eachPdObj.AsgnTo__r.Name  : ''; 
                                perDis.empNo =  eachPdObj.AsgnTo__r.EmployeeNumber !=null ?eachPdObj.AsgnTo__r.EmployeeNumber  : ''; 
                                perDis.decisionDate =eachPdObj.CmpltDt__c !=null ? String.valueOf(eachPdObj.CmpltDt__c.day()) + '-' + monthMap.get(eachPdObj.CmpltDt__c.month()) + '-' + String.valueOf(eachPdObj.CmpltDt__c.year()) :'';  
                                //Blank Fields
                                perDis.analysisOfFinancials =''; //blank
                                perDis.currentObligationDetails =''; //blank
                                perDis.anyMisleadingInformation =''; //blank
                                perDis.foir = commonFoir;
                                perDis.grossMonthlyIncome ='';  //blank
                                perDis.empDetailNatureofBusi =''; //blank
                                perDis.assetOwned =''; //blank
                                perDis.mainClients =''; //blank
                                perDis.resiDetails =''; //blank
                                perDis.verificationMatch =''; //blank
                                perDis.interviewerComments =''; //blank
                                perDis.natureOfFinancialTransaction =''; //blank
                                perDis.crossSellRemarks =''; //blank
                                perDis.shareHoldingPattern =''; //Blank
                                perDis.propertyDetails =''; //blank
                                perDis.additionalDocumentCollected =''; //blank
                                perDis.futureGrowthPlan =''; //blank
                                perDis.anyOthBusi =''; //blank
                                perDis.pfiDoneBy =''; //Blank
                                perDis.placeOfMeeting =''; //Not Captured In SF
                                perDis.mainSuppliers =''; //blank
                                perDis.pfiDone =''; 
                                perDis.mainProducts =''; //blank
                                perDis.aggregateExposure ='';//blank 
                                perDis.customerProfile =''; //blank
                                perDis.grossMonthlyPayable =''; //blank
                                perDis.bankingHabit =''; //blank
                                perDis.timeFrame =''; //blank
                                perDis.levelOfActivity =''; //blank
                                perDis.offDetails =''; //blank
                                perDis.majorVariationsInFinancial =''; //blank
                                perDis.clientMarketRef =''; //blank
                                perDis.crossSell =''; //blank
                                perDis.designation =''; //blank
                                perDis.emiComfortableWith =''; //blank
                                perDis.detailOfEndUseOfFunds =''; //blank
                                
                                //PD res Object Fields
                                if(eachPdObj.PD_Responses__r !=null && !eachPdObj.PD_Responses__r.isEmpty()){
                                    for(PDResp__c eachPdresObj : eachPdObj.PD_Responses__r)
                                    {
                                        if(eachPdresObj.Ques__c == 'Total Number of Employees working in Organization') {
                                            perDis.pfiRemark = eachPdresObj.Resp__c!=null ? eachPdresObj.Resp__c: ''; 
                                        }
                                        else if(eachPdresObj.Ques__c == 'Total Employee Strength') {
                                            perDis.staffStrength =eachPdresObj.Resp__c!=null ? eachPdresObj.Resp__c: ''; 
                                        }
                                    }
                                }
                                
                                listPerDiscussion.add(perDis);
                            }
                        }else
                        {
                            
                            LoanBoardingRequestWrapper.PersonalDiscussion perDis=new LoanBoardingRequestWrapper.PersonalDiscussion();
                            perDis.analysisOfFinancials =''; 
                            perDis.currentObligationDetails =''; 
                            perDis.anyMisleadingInformation =''; 
                            perDis.foir = '';
                            perDis.grossMonthlyIncome ='';  
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
                        
                        List<ApplIMD__c> listForImdDetails = appImdByLoanApp.get(loanApplnIds[0]);
                        List<LoanBoardingRequestWrapper.InitialMoneyDepositDetails> listIniMoneyDetails = LoanBoardingUtility.createInitialMoneyDepositDetails(listForImdDetails);
                        //InitialMoneyDepositDetails not completed end 
                        //notepadDetails blank
                        List<LoanBoardingRequestWrapper.NotepadDetails> listNoteDetails=new List<LoanBoardingRequestWrapper.NotepadDetails>();
                        Integer pdCount=1;
                        if(listOfPerDiscn!=null && !listOfPerDiscn.isEmpty()){
                            for(PD__c eachPerDisObj : listOfPerDiscn){
                                System.debug('Per discussion data present');
                                
                                if(eachPerDisObj.Appl__r.FullName__c != null && eachPerDisObj.PDRmrks__c != null) {
                                    Integer pdRmrksLength = eachPerDisObj.PDRmrks__c.length();
                                    for (Integer i = 0; i < pdRmrksLength; i += 3800) {
                                        Integer endIndex = Math.min(i + 3800, pdRmrksLength); // Ensure endIndex doesn't exceed the length of the string
                                        String substring = eachPerDisObj.PDRmrks__c.substring(i, endIndex);
                                        LoanBoardingRequestWrapper.NotepadDetails notPadDetail = new LoanBoardingRequestWrapper.NotepadDetails();
                                        notPadDetail.noteUser = '';
                                        notPadDetail.noteDate = eachPerDisObj.CmpltDt__c != null ? String.valueOf(eachPerDisObj.CmpltDt__c.day()) + '-' + monthMap.get(eachPerDisObj.CmpltDt__c.month()) + '-' + String.valueOf(eachPerDisObj.CmpltDt__c.year()) : '';
                                        if (eachPerDisObj.Appl__r.FullName__c != null && eachPerDisObj.PDRmrks__c != null) {
                                            notPadDetail.noteDetails = eachPerDisObj.Appl__r.FullName__c + ': ' + 'PD Remarks: ' + pdCount + ' ' + substring;
                                        } else {
                                            notPadDetail.noteDetails = '';
                                        }
                                        
                                        notPadDetail.noteCode = 'COMMENT';
                                        notPadDetail.noteReferenceDate = eachPerDisObj.CmpltDt__c != null ? String.valueOf(eachPerDisObj.CmpltDt__c.day()) + '-' + monthMap.get(eachPerDisObj.CmpltDt__c.month()) + '-' + String.valueOf(eachPerDisObj.CmpltDt__c.year()) : '';
                                        listNoteDetails.add(notPadDetail);
                                    }
                                    pdCount++;
                                }
                            }
                        }
                        
                        List<ApplAsset__c> listAssetByLoan =appAssetMapByLoanApp.get(loanApplnIds[0]);
                        //Integer assetCount=1;
                        
                        if (listAssetByLoan != null && !listAssetByLoan.isEmpty()) {
                            for (ApplAsset__c eachAssetObj : listAssetByLoan) {
                                if (eachAssetObj.Comments_on_Collateral__c != null) {
                                    String comments = eachAssetObj.Comments_on_Collateral__c;
                                    Integer commentLength = comments.length();
                                    
                                    for (Integer i = 0; i < commentLength; i += 3800) {
                                        Integer endIndex = Math.min(i + 3800, commentLength); // Ensure endIndex is within bounds
                                        String subComments = comments.substring(i, endIndex);
                                        
                                        LoanBoardingRequestWrapper.NotepadDetails notPadDetail1 = new LoanBoardingRequestWrapper.NotepadDetails();
                                        notPadDetail1.noteUser = '';
                                        notPadDetail1.noteDate = String.valueOf(System.today().day()) + '-' + monthMap.get(System.today().month()) + '-' + String.valueOf(System.today().year());
                                        notPadDetail1.noteDetails = 'COLLATERAL COMMENTS: '+eachAssetObj.Name  + ': ' + subComments;
                                        notPadDetail1.noteCode = 'COMMENT';
                                        notPadDetail1.noteReferenceDate = String.valueOf(System.today().day()) + '-' + monthMap.get(System.today().month()) + '-' + String.valueOf(System.today().year());
                                        listNoteDetails.add(notPadDetail1);
                                    }
                                }
                                //assetCount++;
                            }
                        }
                        
                        LoanAppl__c eachLoanOb=loanAppRecordsMap.get(loanApplnIds[0]);
                        
                        if (eachLoanOb.AddationalComm__c != null) {
                            String additionalComments = eachLoanOb.AddationalComm__c;
                            Integer additionalCommentsLength = additionalComments.length();
                            Integer addComCount = 1;
                            
                            for (Integer i = 0; i < additionalCommentsLength; i += 3800) {
                                Integer endIndex = Math.min(i + 3800, additionalCommentsLength); // Ensure endIndex is within bounds
                                String subComments = additionalComments.substring(i, endIndex);
                                
                                LoanBoardingRequestWrapper.NotepadDetails notPadDetail2 = new LoanBoardingRequestWrapper.NotepadDetails();
                                notPadDetail2.noteUser = ''; 
                                notPadDetail2.noteDate = String.valueOf(System.today().day()) + '-' + monthMap.get(System.today().month()) + '-' + String.valueOf(System.today().year());  
                                notPadDetail2.noteDetails = 'Additional Remarks: ' + addComCount + ': ' + subComments; 
                                notPadDetail2.noteCode = 'COMMENT'; 
                                notPadDetail2.noteReferenceDate = String.valueOf(System.today().day()) + '-' + monthMap.get(System.today().month()) + '-' + String.valueOf(System.today().year());   
                                listNoteDetails.add(notPadDetail2);
                                addComCount++;    
                            }
                        }
                        
                        if (eachLoanOb.PrsnldetailsofPromotrs__c != null) {
                            String personalDetails = eachLoanOb.PrsnldetailsofPromotrs__c;
                            Integer personalDetailsLength = personalDetails.length();
                            Integer addPerDetailsCount = 1;
                            
                            for (Integer i = 0; i < personalDetailsLength; i += 3800) {
                                Integer endIndex = Math.min(i + 3800, personalDetailsLength); // Ensure endIndex is within bounds
                                String subDetails = personalDetails.substring(i, endIndex);
                                
                                LoanBoardingRequestWrapper.NotepadDetails notPadDetail3 = new LoanBoardingRequestWrapper.NotepadDetails();
                                notPadDetail3.noteUser = ''; 
                                notPadDetail3.noteDate = String.valueOf(System.today().day()) + '-' + monthMap.get(System.today().month()) + '-' + String.valueOf(System.today().year());  
                                notPadDetail3.noteDetails = 'Personal/Family Details of Promoters: ' + addPerDetailsCount + ': ' + subDetails; 
                                notPadDetail3.noteCode = 'COMMENT'; 
                                notPadDetail3.noteReferenceDate = String.valueOf(System.today().day()) + '-' + monthMap.get(System.today().month()) + '-' + String.valueOf(System.today().year());   
                                listNoteDetails.add(notPadDetail3);
                                addPerDetailsCount++;
                            }
                        }
                        
                        if (eachLoanOb.IncomerelateComm__c != null) {
                            String incomeRelatedComments = eachLoanOb.IncomerelateComm__c;
                            Integer incomeRelatedCommentsLength = incomeRelatedComments.length();
                            Integer incRelCount = 1;
                            
                            for (Integer i = 0; i < incomeRelatedCommentsLength; i += 3800) {
                                Integer endIndex = Math.min(i + 3800, incomeRelatedCommentsLength); // Ensure endIndex is within bounds
                                String subComments = incomeRelatedComments.substring(i, endIndex);
                                
                                LoanBoardingRequestWrapper.NotepadDetails notPadDetail4 = new LoanBoardingRequestWrapper.NotepadDetails();
                                notPadDetail4.noteUser = ''; 
                                notPadDetail4.noteDate = String.valueOf(System.today().day()) + '-' + monthMap.get(System.today().month()) + '-' + String.valueOf(System.today().year());  
                                notPadDetail4.noteDetails = 'Income Related Comments: ' + incRelCount + ': ' + subComments; 
                                notPadDetail4.noteCode = 'COMMENT'; 
                                notPadDetail4.noteReferenceDate = String.valueOf(System.today().day()) + '-' + monthMap.get(System.today().month()) + '-' + String.valueOf(System.today().year());   
                                listNoteDetails.add(notPadDetail4);
                                incRelCount++;
                            }
                        }
                        
                        if (eachLoanOb.BDApplicantCoapp__c != null) {
                            String businessDetails = eachLoanOb.BDApplicantCoapp__c;
                            Integer businessDetailsLength = businessDetails.length();
                            Integer bsDelsCount = 1;
                            
                            for (Integer i = 0; i < businessDetailsLength; i += 3800) {
                                Integer endIndex = Math.min(i + 3800, businessDetailsLength); // Ensure endIndex is within bounds
                                String subDetails = businessDetails.substring(i, endIndex);
                                
                                LoanBoardingRequestWrapper.NotepadDetails notPadDetail5 = new LoanBoardingRequestWrapper.NotepadDetails();
                                notPadDetail5.noteUser = ''; 
                                notPadDetail5.noteDate = String.valueOf(System.today().day()) + '-' + monthMap.get(System.today().month()) + '-' + String.valueOf(System.today().year()); 
                                notPadDetail5.noteDetails = 'Brief of Business Details of Applicant and Coapplicant: ' + bsDelsCount + ': ' + subDetails; 
                                notPadDetail5.noteCode = 'COMMENT'; 
                                notPadDetail5.noteReferenceDate = String.valueOf(System.today().day()) + '-' + monthMap.get(System.today().month()) + '-' + String.valueOf(System.today().year());   
                                listNoteDetails.add(notPadDetail5);
                                bsDelsCount++;    
                            }
                        }
                        
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
                        LoanBoardingRequestWrapper.BussinessVerification busVer= LoanBoardingUtility.populateBusinessVerification();
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
                            insDetail.noOfCollaterals = String.valueOf(sizeOfAssets); //No of Property  ==== Not   captured
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
                                propdetails.appraisedPropertyValue =String.valueOf(assetObj.ValuationToBeTakenAheadForCalculation__c) !=null? String.valueOf(assetObj.ValuationToBeTakenAheadForCalculation__c):   ''; 
                                propdetails.developerBuilder =String.valueOf(assetObj.Builder_ID__c) !=null? String.valueOf(assetObj.Builder_ID__c):   ''; 
                                propdetails.sellerAddressTwo =''; //blank
                                propdetails.typeofPurchase = masterDataMap.get('Property Type') !=null ? masterDataMap.get('Property Type').get(assetObj.PropType__c) !=null ? masterDataMap.get('Property Type').get(assetObj.PropType__c):'':'';       // String.valueOf(assetObj.PropType__c) !=null? String.valueOf(assetObj.PropType__c):   '';  
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
                                //LAK-7857 Start
                                
                                Boolean res = false;
                                
                                
                                if (listScheme != null && !listScheme.isEmpty()) {
                                    res = listScheme[0].ISBT__c;
                                }
                                
                                if(String.valueOf(dataLoanApp.Product__c) == 'Small Ticket LAP' || String.valueOf(dataLoanApp.Product__c) == 'Loan Against Property')
                                {
                                    propdetails.propertyValue = String.valueOf(assetObj.ValuationToBeTakenAheadForCalculation__c) !=null? String.valueOf(assetObj.ValuationToBeTakenAheadForCalculation__c): '';  
                                }
                                else if(String.valueOf(dataLoanApp.Product__c) == 'Home Loan' )
                                {
                                    /*if(res == true){
                                        propdetails.propertyValue =''; 
                                    }else{
                                        propdetails.propertyValue = String.valueOf(assetObj.Total_Prop_Cost__c) !=null? String.valueOf(assetObj.Total_Prop_Cost__c):   '';  
                                    }
                                    */

                                    //New Change
                                   if(assetObj.Total_Prop_Cost__c != NULL && assetObj.Total_Prop_Cost__c >0){
                                        propdetails.propertyValue = String.valueOf(assetObj.Total_Prop_Cost__c) !=null? String.valueOf(assetObj.Total_Prop_Cost__c):   '';  
                                        
                                    }else{
                                         propdetails.propertyValue = String.valueOf(assetObj.ValuationToBeTakenAheadForCalculation__c) !=null? String.valueOf(assetObj.ValuationToBeTakenAheadForCalculation__c): '';  
                                    }

                                }
                                
                                else
                                {
                                    propdetails.propertyValue = '';  
                                }
                                
                                //LAK-7857 End    
                                
                                propdetails.sellerAddressOne =''; //Blank
                                propdetails.buildingName =''; //Blank
                                propdetails.personalInsurance =''; //Blank
                                propdetails.guaranteeTenure =''; //Blank
                                propdetails.sellerPhoneNo =''; //Blank
                                propdetails.soleOwnerFlag =''; //Blank
                                propdetails.additionalProperties =rpDet; //Blank
                                propdetails.projectName =''; //Blank
                                Case tempTsrCase = latestTSRCase;
                                
                                if((tempTsrCase !=null) && (tempTsrCase.ReportResult__c == 'Positive' || tempTsrCase.ReportResult__c == 'Query')){
                                    propdetails.titleClearFlag ='Y'; 
                                }
                                else{
                                    propdetails.titleClearFlag ='N'; 
                                }
                                
                                propdetails.contractor =''; //Blank
                                propdetails.presentRegisteredOwner =assetObj.Prop_Owners__c !=null ?  String.valueOf(assetObj.Prop_Owners__c).left(30) : ''; 
                                propdetails.guaranteeFlag =''; //Blank
                                propdetails.ageOfProperty = String.valueOf(assetObj.Approx_Age_of_Prop__c)!=null ? String.valueOf(assetObj.Approx_Age_of_Prop__c): '';  
                                propdetails.areaForImprovements =''; //Blank
                                propdetails.builderClassificationType =''; //Blank
                                propdetails.architect =''; //Blank
                                propdetails.sellerName =''; //Blank

                                //LAK-7889
                                String propAddress1Str = (assetObj.FlatNo__c !=null ? String.valueOf(assetObj.FlatNo__c)+' ' :'') + (assetObj.AddrLn1__c !=null ?assetObj.AddrLn1__c: '');
                                if(propAddress1Str !=null && String.isNotBlank(propAddress1Str)){
                                    propAddress1Str=propAddress1Str.replaceAll('\\r\\n|\\r|\\n', ' ');
                                    propAddress1Str =propAddress1Str.replace('\\n', ' ');
                                    propAddress1Str =propAddress1Str.replace('\\s\\n\\s', ' ');
                                    propAddress1Str = propAddress1Str.replaceAll('[^a-zA-Z0-9\\s]', '').trim().left(50); // Remove special characters
                                    propAddress1Str = propAddress1Str.replaceAll('\\s+', ' ').trim();
                                }
                                propdetails.propAddress1 = propAddress1Str;

                                String propAddress2Str = assetObj.AddrLn2__c !=null ?assetObj.AddrLn2__c: '';
                                if(propAddress2Str !=null && String.isNotBlank(propAddress2Str)){
                                    propAddress2Str=propAddress2Str.replaceAll('\\r\\n|\\r|\\n', ' ');
                                    propAddress2Str =propAddress2Str.replace('\\n', ' ');
                                    propAddress2Str =propAddress2Str.replace('\\s\\n\\s', ' ');
                                    propAddress2Str = propAddress2Str.replaceAll('[^a-zA-Z0-9\\s]', '').trim().left(50); // Remove special characters
                                    propAddress2Str = propAddress2Str.replaceAll('\\s+', ' ').trim();
                                }
                                propdetails.propAddress2 =propAddress2Str;


                                //
                                
                                //propdetails.propAddress1 = (assetObj.FlatNo__c !=null ? String.valueOf(assetObj.FlatNo__c)+' ' :'') + (assetObj.AddrLn1__c !=null ?assetObj.AddrLn1__c: ''); 
                                //propdetails.propAddress2 =assetObj.AddrLn2__c !=null ?assetObj.AddrLn2__c: '';
                                propdetails.propAddress3 = assetObj.Landmark__c !=null ? assetObj.Landmark__c :'';
                                
                                propdetails.propCity =locMstrObj !=null ? String.valueOf(locMstrObj.CityId__c) !=null ? String.valueOf(locMstrObj.CityId__c) :'': '';
                                
                                
                                Case caseObjLgl = latestLegalCase;
                                
                                if(caseObjLgl !=null){ 
                                    propdetails.lawyerName=  caseObjLgl.Account.AgencyCode__c !=null ? caseObjLgl.Account.AgencyCode__c :'';
                                }
                                else{
                                    propdetails.lawyerName=  '';
                                }
                                
                                propdetails.lotNo =''; //Blank
                                propdetails.areasSqm = assetObj.Property_Carpet_area_Sq_Ft__c!=null ? String.valueOf((assetObj.Property_Carpet_area_Sq_Ft__c * 0.09290303997).setScale(2, RoundingMode.HALF_UP)):''; 
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
                                propdetails.propTypeNew = '';// No need to map  assetObj.PropIdentified__c !=null ? assetObj.PropIdentified__c :''; 
                                propdetails.propertyAddressLine1 =assetObj.AddrLn1__c !=null ? String.valueOf(assetObj.AddrLn1__c).left(24) : '';  
                                propdetails.propertyAddressLine2 = assetObj.AddrLn2__c !=null ? String.valueOf(assetObj.AddrLn2__c).left(24) : ''; //Added only first 20 char as not validation in FE 
                                propdetails.nearestLandmark = '';//assetObj.Landmark__c!=null ? assetObj.Landmark__c: ''; 
                                propdetails.collateralUsage =''; //Blank
                                propdetails.propertyDesc =assetObj.PropSubTypeDesc__c !=null ?assetObj.PropSubTypeDesc__c:''; 
                                propdetails.fundsDetail =listRepayDetails1; //blank
                                propdetails.residualAgeOfProperty =String.valueOf(assetObj.Resi_Age__c)	 !=null ?String.valueOf(assetObj.Resi_Age__c):''; 
                                propdetails.propertyCostFinanced =String.valueOf(String.valueOf(loanAppRecordsMap.get(loanApplnIds[0]).TotalLoanAmtInclInsurance__c)) !=null ?String.valueOf(loanAppRecordsMap.get(loanApplnIds[0]).TotalLoanAmtInclInsurance__c) : ''; 
                                propdetails.TCTCCTNo =''; //Blank
                                propdetails.propType = masterDataMap.get('Prop Type')!=null ? masterDataMap.get('Prop Type').get(assetObj.PropType__c)   != null ?  String.valueOf(masterDataMap.get('Prop Type').get(assetObj.PropType__c))  : '' :'';
                                
                                
                                Case caseTechObj1 ;
                                Case caseTechObj2 ;

                               
                                if(latestTechnicalCases !=null && !latestTechnicalCases.isEmpty()){
                                    if(latestTechnicalCases[0] !=null){
                                        caseTechObj1=latestTechnicalCases[0];
                                    }
                                    if(latestTechnicalCases.size() == 2 && latestTechnicalCases[1] !=null){
                                        caseTechObj2=latestTechnicalCases[1];
                                    }
                                }

                                //if(caseTechObj1 !=null && (caseTechObj1.Total_Valuation_Land_Valuation_B__c >= 2500000)){
                                if(caseTechObj1 !=null){    
                                    propdetails.appraisalValue1 = caseTechObj1.Total_Valuation_Land_Valuation_B__c !=null ? String.valueOf(caseTechObj1.Total_Valuation_Land_Valuation_B__c) :'';
                                    propdetails.appraiser1 = caseTechObj1.Account.AgencyCode__c !=null ? caseTechObj1.Account.AgencyCode__c :'' ;
                                    propdetails.appraiser1Date = caseTechObj1.Date_of_Report__c !=null ? String.valueOf(caseTechObj1.Date_of_Report__c.day()) + '-' + monthMap.get(caseTechObj1.Date_of_Report__c.month()) + '-' + String.valueOf(caseTechObj1.Date_of_Report__c.year()) :'';
                                }
                                else{
                                    propdetails.appraisalValue1 = '';
                                    propdetails.appraiser1 = '';
                                    propdetails.appraiser1Date ='';
                                }
                                
                                
                                //if(caseTechObj2 !=null && (caseTechObj2.Total_Valuation_Land_Valuation_B__c <= 2500000)){
                                if(caseTechObj2 !=null){    
                                    propdetails.appraisalValue2 =caseTechObj2.Total_Valuation_Land_Valuation_B__c !=null ? String.valueOf(caseTechObj2.Total_Valuation_Land_Valuation_B__c) :'';
                                    propdetails.appraiser2 = caseTechObj2.Account.AgencyCode__c !=null ? caseTechObj2.Account.AgencyCode__c :'';
                                    propdetails.appraiser2Date =caseTechObj2.Date_of_Report__c !=null ? String.valueOf(caseTechObj2.Date_of_Report__c.day()) + '-' + monthMap.get(caseTechObj2.Date_of_Report__c.month()) + '-' + String.valueOf(caseTechObj2.Date_of_Report__c.year()) :'';
                                }
                                else{
                                    propdetails.appraisalValue2 = '';
                                    propdetails.appraiser2 = '';
                                    propdetails.appraiser2Date ='';
                                }
                                
                                propdetails.propertyUsage =  masterDataMap.get('Property Usage') !=null ? masterDataMap.get('Property Usage').get(assetObj.Property_Usage__c) !=null ? masterDataMap.get('Property Usage').get(assetObj.Property_Usage__c):'':''; //       'SELFOC'; // Hardcoded assetObj.Property_Usage__c !=null ? assetObj.Property_Usage__c: ''; 
                                listProp.add(propdetails);
                                
                            }
                            
                        }
                        
                        List<Applicant__c> applicantList =loanAppMap.get(intMsg.RefId__c);
                        LoanBoardingRequestWrapper.ConfirmationLog conLog=new LoanBoardingRequestWrapper.ConfirmationLog();
                        
                        LoanBoardingRequestWrapper.GSTInfoDetails gstInDetails =new LoanBoardingRequestWrapper.GSTInfoDetails();  
                        List<LoanBoardingRequestWrapper.ApplicantDetails> listAppDetl =new List<LoanBoardingRequestWrapper.ApplicantDetails>();
                        if(applicantList!=null  && !applicantList.isEmpty()){ 
                            for(Applicant__c app : applicantList)
                            {
                                List<LoanBoardingRequestWrapper.LiabilityDetails> listLiabDtls = LoanBoardingUtility.populateLiabilityDetails(app,appBureauMapByApplicant,monthMap,masterDataMap); 
                                
                                if(priAppId == app.ID){
                                    conLog.applicantName =app.ApplType__c =='P' ? app.FullName__c : '';
                                    conLog.phoneUsed =''; 
                                    conLog.nameOfAgency =''; 
                                    conLog.citizenship ='17'; //hardcoded OK
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
                                
                                
                                //DocCollectionDetails start
                                List<LoanBoardingRequestWrapper.DocCollectionDetails> listDocdetails =new List<LoanBoardingRequestWrapper.DocCollectionDetails>();
                                
                                //List<DocDtl__c> liForDocdetails = listDocumentsByLoanId;//appDocDetailsByLoanApp.get(loanApplnIds[0]);
                                
                                if(listDocumentsByLoanId !=null && !listDocumentsByLoanId.isEmpty()){
                                    for(DocDtl__c eachDocdetail :listDocumentsByLoanId){
                                        LoanBoardingRequestWrapper.DocCollectionDetails docColDetails =new LoanBoardingRequestWrapper.DocCollectionDetails();
                                        
                                        if((eachDocdetail.DocStatus__c =='OTC' || eachDocdetail.DocStatus__c =='PDD')  && eachDocdetail.DocMstr__r.Catgry__c == 'Mandatory Post Sanction Documents'){
                                            
                                            docColDetails.docName =eachDocdetail.DocSubTyp__c !=null ?eachDocdetail.DocSubTyp__c:'' ; 
                                            docColDetails.docRICReqd ='N'; 
                                            docColDetails.originalDoc = ''; //eachDocdetail.OSV__c !=null ?  String.valueOf(eachDocdetail.OSV__c) :'' ; 
                                            docColDetails.docStatus =masterDataMap.get('Doc Status') !=null && eachDocdetail.DocStatus__c !=null ? (masterDataMap.get('Doc Status').get(eachDocdetail.DocStatus__c) !=null ? masterDataMap.get('Doc Status').get(eachDocdetail.DocStatus__c) : '') :'' ;//eachDocdetail.DocStatus__c !=null ?  mapDocStatus.get(eachDocdetail.DocStatus__c)  :''; 
                                            docColDetails.docValidityDate =''; 
                                            docColDetails.docDesc ='';
                                            docColDetails.document =eachDocdetail.DocMstr__r.DocId__c !=null ?eachDocdetail.DocMstr__r.DocId__c:'' ; 
                                            docColDetails.docReason =''; 
                                            
                                            if(eachDocdetail.Rmrk__c !=null && String.isNotBlank(eachDocdetail.Rmrk__c)){
                                                // Remove special characters and newline characters
                                                
                                                String removeNLStr =eachDocdetail.Rmrk__c.replaceAll('\\r\\n|\\r|\\n', ' ');
                                                removeNLStr =removeNLStr.replace('\\n', ' ');
                                                removeNLStr =removeNLStr.replace('\\s\\n\\s', ' ');
                                                removeNLStr = removeNLStr.replaceAll('[^a-zA-Z0-9\\s]', '').trim().left(200); // Remove special characters
                                                removeNLStr = removeNLStr.replaceAll('\\s+', ' ').trim();
                                                docColDetails.docRemarks = removeNLStr;


                                            }
                                            else{
                                                docColDetails.docRemarks='';
                                            }
                                            
                                            if(eachDocdetail.DocStatus__c !=null && (eachDocdetail.DocStatus__c=='OTC' || eachDocdetail.DocStatus__c=='PDD')){
                                                docColDetails.docReceivedDate ='';
                                                docColDetails.docTargetDate = eachDocdetail.TargetDt__c!=null ? String.valueOf(eachDocdetail.TargetDt__c.day()) + '-' + monthMap.get(eachDocdetail.TargetDt__c.month()) + '-' + String.valueOf(eachDocdetail.TargetDt__c.year()):'';
                                            } 
                                            else{
                                                docColDetails.docTargetDate ='';
                                                docColDetails.docReceivedDate = eachDocdetail.ReceivedDt__c!=null ? String.valueOf(eachDocdetail.ReceivedDt__c.day()) + '-' + monthMap.get(eachDocdetail.ReceivedDt__c.month()) + '-' + String.valueOf(eachDocdetail.ReceivedDt__c.year()):'';
                                            }
                                            
                                            //adding data to list  
                                            listDocdetails.add(docColDetails);
                                            
                                        }
                                        else if(eachDocdetail.DocMstr__r.Catgry__c == 'Additional Post Sanction Documents' || eachDocdetail.DocMstr__r.Catgry__c == 'Property Documents' || eachDocdetail.DocMstr__r.Catgry__c == 'Sanction Condition Documents'){
                                            
                                            docColDetails.docName =eachDocdetail.DocSubTyp__c !=null ?eachDocdetail.DocSubTyp__c:'' ; 
                                            docColDetails.docRICReqd ='N'; 
                                            docColDetails.originalDoc = ''; //eachDocdetail.OSV__c !=null ?  String.valueOf(eachDocdetail.OSV__c) :'' ; 
                                            docColDetails.docStatus =masterDataMap.get('Doc Status') !=null && eachDocdetail.DocStatus__c !=null ? (masterDataMap.get('Doc Status').get(eachDocdetail.DocStatus__c) !=null ? masterDataMap.get('Doc Status').get(eachDocdetail.DocStatus__c) : '') :'' ;//eachDocdetail.DocStatus__c !=null ?  mapDocStatus.get(eachDocdetail.DocStatus__c)  :''; 
                                            docColDetails.docValidityDate =''; 
                                            docColDetails.docDesc ='';
                                            
                                            docColDetails.document =eachDocdetail.DocMstr__r.DocId__c !=null ?eachDocdetail.DocMstr__r.DocId__c:'' ; 
                                            docColDetails.docReason =''; 
                                            
                                            if(eachDocdetail.Rmrk__c !=null && String.isNotBlank(eachDocdetail.Rmrk__c)){
                                                
                                                

                                                String removeNLStr =eachDocdetail.Rmrk__c.replaceAll('\\r\\n|\\r|\\n', ' ');
                                                removeNLStr =removeNLStr.replace('\\n', ' ');
                                                removeNLStr =removeNLStr.replace('\\s\\n\\s', ' ');
                                                removeNLStr = removeNLStr.replaceAll('[^a-zA-Z0-9\\s]', '').trim().left(200); // Remove special characters
                                                removeNLStr = removeNLStr.replaceAll('\\s+', ' ').trim();
                                                docColDetails.docRemarks = removeNLStr;


                                                
                                            }else{
                                                docColDetails.docRemarks='';
                                            }
                                            
                                            
                                            if(eachDocdetail.DocStatus__c !=null && (eachDocdetail.DocStatus__c=='OTC' || eachDocdetail.DocStatus__c=='PDD')){
                                                docColDetails.docReceivedDate ='';
                                                docColDetails.docTargetDate = eachDocdetail.TargetDt__c!=null ? String.valueOf(eachDocdetail.TargetDt__c.day()) + '-' + monthMap.get(eachDocdetail.TargetDt__c.month()) + '-' + String.valueOf(eachDocdetail.TargetDt__c.year()):'';
                                            } 
                                            else{
                                                docColDetails.docTargetDate ='';
                                                docColDetails.docReceivedDate = eachDocdetail.ReceivedDt__c!=null ? String.valueOf(eachDocdetail.ReceivedDt__c.day()) + '-' + monthMap.get(eachDocdetail.ReceivedDt__c.month()) + '-' + String.valueOf(eachDocdetail.ReceivedDt__c.year()):'';
                                            }
                                            
                                            //adding data to list  
                                            listDocdetails.add(docColDetails);
                                        }
                                        
                                    }
                                    
                                }
                                //DocCollectionDetails end
                                
                                //GSTInfoDetails start 
                                ApplicantEmployment__c appEm;//=new ApplicantEmployment__c();
                                if(appEmpMap.get(app.id) !=null  && !appEmpMap.get(app.id).isEmpty())
                                {
                                    appEm=appEmpMap.get(app.id)[0];
                                }
                                
                                LoanBoardingRequestWrapper.WorkDetailsSalaried wrkDetailSal= LoanBoardingUtility.createWorkDetailsSalaried(appEm,industryNameMap,masterDataMap);
                                
                                List<LoanBoardingRequestWrapper.BankDetails> listBankDls =new List<LoanBoardingRequestWrapper.BankDetails>();
                                
                                if(appBankingMap.get(app.ID) !=null && !appBankingMap.get(app.ID).isEmpty())
                                {            
                                    for(ApplBanking__c eachAppBankObj : appBankingMap.get(app.ID))
                                    {
                                        LoanBoardingRequestWrapper.BankDetails bankDetailObj=new LoanBoardingRequestWrapper.BankDetails();
                                        
                                        //BankMstr__c eachBankObj= bankMstrMap.get(eachAppBankObj.BankName__c);
                                        MICRCodeMstr__c eachMicrDetailObj=micrMstrMap.get(eachAppBankObj.Bank_Branch__c);
                                        //MICRCodeMstr__c micrObjForBranch = micrMstrMap.get(eachAppBankObj.Bank_Branch__c);
                                        bankDetailObj.finBankMaxBalance = String.valueOf(overallMaxValueAppBankDtls); 
                                        bankDetailObj.finBankAccountNo =eachAppBankObj.AC_No__c!=null ? eachAppBankObj.AC_No__c : ''; 
                                        bankDetailObj.finBankAccType = (masterDataMap.get('Account Type') !=null && eachAppBankObj.AccountType__c !=null ) ? (masterDataMap.get('Account Type').get(eachAppBankObj.AccountType__c) !=null ? masterDataMap.get('Account Type').get(eachAppBankObj.AccountType__c) : '') :'' ;   
                                        
                                        bankDetailObj.finBankMinBalance = String.valueOf(overallMinValueAppBankDtls);
                                        bankDetailObj.finBankAvgBalance =eachAppBankObj.AverageBankBalance__c!=null ? String.valueOf(eachAppBankObj.AverageBankBalance__c) : ''; 
                                        bankDetailObj.finBankStmtCollected =''; 
                                        bankDetailObj.finNoOfYearsHeld =''; 
                                        bankDetailObj.finNoOfOutwardChqReturns =  String.valueOf(eachAppBankObj.TotalOutwardReturnCount__c) !=null ?String.valueOf(eachAppBankObj.TotalOutwardReturnCount__c).left(3):''; 
                                        bankDetailObj.finBankRemarks =''; 
                                        
                                        // bankDetailObj.finBankBranch = micr=>BrchName__c eachAppBankObj.Bank_Branch__c!=null?eachAppBankObj.Bank_Branch__c:''; //check this
                                        bankDetailObj.finBankName = System.Label.LoanB_finBankName; //eachAppBankObj.SFDCBankMaster__r.BankCode__c != null?eachAppBankObj.SFDCBankMaster__r.BankCode__c:'';
                                        bankDetailObj.finBankBranch =eachAppBankObj.SFDCBankMaster__r.BankName__c != null?eachAppBankObj.SFDCBankMaster__r.BankName__c:''; 
                                        /*if(eachMicrDetailObj !=null){
                                        bankDetailObj.finBankName =   eachMicrDetailObj.Bank__r.BankId__c !=null ? eachMicrDetailObj.Bank__r.BankId__c:'';//     micr =>Bank__r.BankId__c	 eachBankObj.BankId__c !=null  ? eachBankObj.BankId__c : '';  // (micrObjForBranch !=null) ? micrObjForBranch.BanckBrchId__c !=null ? String.valueOf(micrObjForBranch.BanckBrchId__c) :'':''; //  eachAppBankObj.BankName__c!=null?eachAppBankObj.BankName__c:''; 
                                        bankDetailObj.finBankBranch = eachMicrDetailObj.BrchName__c !=null ?eachMicrDetailObj.BrchName__c :''; 

                                        }else{
                                        bankDetailObj.finBankName = '';
                                        bankDetailObj.finBankBranch ='';
                                        }*/
                                        bankDetailObj.finNoOfInwardChqReturns = String.valueOf(eachAppBankObj.TotalInwardReturnCount__c)!=null ? String.valueOf(eachAppBankObj.TotalInwardReturnCount__c).left(3) : ''; //Added only first 3 character as not handled in FE
                                        
                                        listBankDls.add(bankDetailObj);
                                        
                                    }
                                    
                                }
                                
                                //PropertyDetails start
                                List<LoanBoardingRequestWrapper.AddressDetails> listAddDetails= LoanBoardingUtility.populatePropertyDetails(app,appAddMap,mapLocMas,masterDataMap);
                                //AddressDetails(Applicant) end
                                List<LoanBoardingRequestWrapper.IncomeDetails> listIncDetails=new List<LoanBoardingRequestWrapper.IncomeDetails>();
                                List<Applicant_Income__c> listAppIncome = appIncomeMap.get(app.ID);
                                
                                //for Net Income Calculations
                                Decimal totalCashSalNetAmt=0;
                                Decimal totalBankCrSalNetAmt=0;
                                Decimal CashFlowSalNetAmt=0;
                                Decimal totalRentWBankNetAmt=0;
                                Decimal totalRentWOBankNetAmt=0;
                                Decimal totalPensionNetAmt=0;
                                Decimal totalAgrAmtCurrentY=0;
                                Decimal totalAgrAmtPreviousY=0;
                                Decimal totalNetAmtCommon=0;
                                Decimal totalCashSalAmt=0;
                                Decimal totalBankCrSal=0;
                                Decimal totalCashFlowSal=0;
                                Decimal totalRentWBank=0;
                                Decimal totalRentWOBank=0;
                                Decimal totalPensionAmt=0;
                                Decimal totalOtherAmt=0;
                                Decimal totalRentalIncomeAmt=0;
                                
                                //Count for Different types
                                Integer countCashSalAmt=0;
                                Integer countBankCrSal=0;
                                Integer countCashFlowSal=0;
                                Integer countPension=0;
                                Integer countAgrAmtCurrentY=0;
                                Integer countAgrAmtPreviousY=0;
                                Integer countOtherAmt =0;
                                
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
                                        if(appInc.RecordType.DeveloperName == 'Cashflow_Map' && app!=null  && app.LatestyearforwhichITRisavailable__c != NULL && app.LatestyearforwhichITRisavailable__c.equalsIgnoreCase('ITR Not Available')){
                                            totalCashFlowSal =totalCashFlowSal+  (appInc.NET_CASH_PROFIT_LOSS__c !=null ? Integer.valueOf(appInc.NET_CASH_PROFIT_LOSS__c) :0 );
                                            countCashFlowSal++;
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
                                        if(appInc.RecordType.DeveloperName =='Other_Income'){
                                            totalOtherAmt =totalOtherAmt + (appInc.Monthly_Other_Income__c !=null ? Integer.valueOf(appInc.Monthly_Other_Income__c) :0 );
                                            countOtherAmt++;
                                        }
                                    }
                                }
                                
                                totalRentalIncomeAmt= totalRentWBank+totalRentWOBank;
                                
                                if(countCashSalAmt > 0){
                                    LoanBoardingRequestWrapper.IncomeDetails incDetailsA=new LoanBoardingRequestWrapper.IncomeDetails();
                                    incDetailsA.incomeSource =''; //blank
                                    incDetailsA.howAreYouPaid =''; //blank
                                    incDetailsA.salaryCreditDay = ''; //blank
                                    incDetailsA.incomePercentage='';//blank
                                    //mandatory fields
                                    Decimal resNetAmt=((totalCashSalAmt)/countCashSalAmt);
                                    Decimal resAmt=((resNetAmt)*12);
                                    incDetailsA.incomeHead= masterDataMap.get('Income Head') !=null ? String.valueOf(masterDataMap.get('Income Head').get('Cash Salary')) : '' ; //'03'; 
                                    incDetailsA.inomeNetAmount= resAmt >= 0 ? String.valueOf(resAmt.setScale(2, RoundingMode.HALF_UP)) : '0';
                                    incDetailsA.incomeAmount =resNetAmt >= 0 ? String.valueOf(resNetAmt.setScale(2, RoundingMode.HALF_UP)): '0';
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
                                    incDetailsB.incomeHead= masterDataMap.get('Income Head') !=null ? String.valueOf(masterDataMap.get('Income Head').get('Salary With Bank Credit')) : '' ; //   '202';
                                    incDetailsB.inomeNetAmount=  resAmt >= 0 ? String.valueOf(resAmt.setScale(2, RoundingMode.HALF_UP)) : '0';
                                    incDetailsB.incomeAmount = resNetAmt >= 0 ? String.valueOf(resNetAmt.setScale(2, RoundingMode.HALF_UP)) : '0';
                                    incDetailsB.incomeFeq='12';
                                    listIncDetails.add(incDetailsB);
                                }
                                
                                if(countCashFlowSal >0){
                                    LoanBoardingRequestWrapper.IncomeDetails incDetailsCashFlowSal=new LoanBoardingRequestWrapper.IncomeDetails();
                                    incDetailsCashFlowSal.incomeSource =''; //blank
                                    incDetailsCashFlowSal.howAreYouPaid =''; //blank
                                    incDetailsCashFlowSal.salaryCreditDay = ''; //blank
                                    incDetailsCashFlowSal.incomePercentage='';//blank
                                    //mandatory fields
                                    Decimal resNetAmt=((totalCashFlowSal)/countCashFlowSal);
                                    Decimal resAmt=((resNetAmt)/12);
                                    incDetailsCashFlowSal.incomeHead= masterDataMap.get('Income Head') !=null ? String.valueOf(masterDataMap.get('Income Head').get('Cash Flow Computation')) : '' ; 
                                    incDetailsCashFlowSal.inomeNetAmount=  resAmt >= 0 ? String.valueOf(resAmt.setScale(2, RoundingMode.HALF_UP)) : '0';
                                    incDetailsCashFlowSal.incomeAmount = resNetAmt >= 0 ? String.valueOf(resNetAmt.setScale(2, RoundingMode.HALF_UP)) : '0';
                                    incDetailsCashFlowSal.incomeFeq='1';
                                    listIncDetails.add(incDetailsCashFlowSal);
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
                                    incDetailsC.incomeHead=masterDataMap.get('Income Head') !=null ? String.valueOf(masterDataMap.get('Income Head').get('Pension Income')) : '' ;  //'055';
                                    incDetailsC.inomeNetAmount= resAmt >= 0 ? String.valueOf(resAmt.setScale(2, RoundingMode.HALF_UP)) : '0'; 
                                    incDetailsC.incomeAmount = resNetAmt >= 0 ? String.valueOf(resNetAmt.setScale(2, RoundingMode.HALF_UP)) : '0';
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
                                    
                                    incDetailsD.incomeHead=masterDataMap.get('Income Head') !=null ? String.valueOf(masterDataMap.get('Income Head').get('Agricultural Income Current Year')) : '' ;   //'212';
                                    incDetailsD.inomeNetAmount= totalAgrAmtCurrentY >= 0 ? String.valueOf(totalAgrAmtCurrentY.setScale(2, RoundingMode.HALF_UP)) : '0';
                                    incDetailsD.incomeAmount =  resNetAmt >= 0 ? String.valueOf(resNetAmt.setScale(2, RoundingMode.HALF_UP)) : '0';
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
                                    
                                    incDetailsE.incomeHead= masterDataMap.get('Income Head') !=null ? String.valueOf(masterDataMap.get('Income Head').get('Agricultural Income Previous Year')) : '' ;//'213';
                                    incDetailsE.inomeNetAmount=  totalAgrAmtPreviousY >= 0 ? String.valueOf(totalAgrAmtPreviousY.setScale(2, RoundingMode.HALF_UP)) : '0'; 
                                    incDetailsE.incomeAmount =resNetAmt  >= 0 ? String.valueOf(resNetAmt.setScale(2, RoundingMode.HALF_UP)) : '0';
                                    incDetailsE.incomeFeq='1';
                                    listIncDetails.add(incDetailsE);
                                }
                                if(countOtherAmt>0){
                                    
                                    LoanBoardingRequestWrapper.IncomeDetails incDetailsF=new LoanBoardingRequestWrapper.IncomeDetails();
                                    incDetailsF.incomeSource =''; //blank
                                    incDetailsF.howAreYouPaid =''; //blank
                                    incDetailsF.salaryCreditDay = ''; //blank
                                    incDetailsF.incomePercentage='';//blank
                                    //mandatory fields
                                    Decimal resNetAmt=((totalOtherAmt)/12);             
                                    
                                    incDetailsF.incomeHead= masterDataMap.get('Income Head') !=null ? String.valueOf(masterDataMap.get('Income Head').get('Other Income')) : '' ;//'213';
                                    incDetailsF.inomeNetAmount= totalOtherAmt >= 0 ? String.valueOf(totalOtherAmt.setScale(2, RoundingMode.HALF_UP)) : '0';  
                                    incDetailsF.incomeAmount =  resNetAmt  >= 0 ? String.valueOf(resNetAmt.setScale(2, RoundingMode.HALF_UP)) : '0'; 
                                    incDetailsF.incomeFeq='1';
                                    listIncDetails.add(incDetailsF);
                                }
                                
                                
                                if(totalRentalIncomeAmt > 0){
                                    LoanBoardingRequestWrapper.IncomeDetails incDetailsRentalTotal =new LoanBoardingRequestWrapper.IncomeDetails();
                                    incDetailsRentalTotal.incomeSource =''; //blank
                                    incDetailsRentalTotal.howAreYouPaid =''; //blank
                                    incDetailsRentalTotal.salaryCreditDay = ''; //blank
                                    incDetailsRentalTotal.incomePercentage='';//blank
                                    //mandatory fields
                                    Decimal resNetAmt=((totalRentalIncomeAmt)/3);
                                    Decimal resAmt=((resNetAmt)*12);
                                    incDetailsRentalTotal.incomeHead= masterDataMap.get('Income Head') !=null ? String.valueOf(masterDataMap.get('Income Head').get('Rental Credits In Banking')) : '' ; //'37';
                                    incDetailsRentalTotal.inomeNetAmount=   resAmt >= 0? String.valueOf(resAmt.setScale(2, RoundingMode.HALF_UP)) : '0'; 
                                    incDetailsRentalTotal.incomeAmount =resNetAmt >= 0 ? String.valueOf(resNetAmt.setScale(2, RoundingMode.HALF_UP)) : '0';
                                    incDetailsRentalTotal.incomeFeq='12';
                                    listIncDetails.add(incDetailsRentalTotal);
                                    
                                }
                                
                                Decimal totalAmtPLCurrYear=0;
                                Decimal totalAmtPLPreviousYear=0;
                                Integer ChkValForAppFinY =  0;
                                Integer ChkValForAppFinPY =  0;
                                
                                
                                if(listAppliFinSum !=null && !listAppliFinSum.isEmpty()){
                                    for(Applicant_Financial_Summary__c appFinSum: listAppliFinSum )
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
                                }
                                
                                if(ChkValForAppFinY == currentYearBlock){
                                    System.debug('ChkValForAppFinY == currentYearBlock::');
                                    LoanBoardingRequestWrapper.IncomeDetails incDetailsH=new LoanBoardingRequestWrapper.IncomeDetails();
                                    incDetailsH.incomeSource =''; //blank
                                    incDetailsH.howAreYouPaid =''; //blank
                                    incDetailsH.salaryCreditDay = ''; //blank
                                    incDetailsH.incomePercentage='';//blank
                                    //mandatory fields
                                    Decimal resNetAmt=((totalAmtPLCurrYear)/12);
                                    incDetailsH.incomeHead= masterDataMap.get('Income Head') !=null ? String.valueOf(masterDataMap.get('Income Head').get('Profit and Loss current Year')) : '' ;//   '216';
                                    incDetailsH.inomeNetAmount= totalAmtPLCurrYear != 0 ? String.valueOf(totalAmtPLCurrYear.setScale(2, RoundingMode.HALF_UP)) : '0';
                                    incDetailsH.incomeAmount =  resNetAmt != 0 ? String.valueOf(resNetAmt.setScale(2, RoundingMode.HALF_UP)) : '0';
                                    incDetailsH.incomeFeq='1';
                                    listIncDetails.add(incDetailsH);
                                    
                                }  
                                if(ChkValForAppFinPY == previousYearBlock){
                                    System.debug('ChkValForAppFinPY == previousYearBlock :'+previousYearBlock);
                                    LoanBoardingRequestWrapper.IncomeDetails incDetailsI=new LoanBoardingRequestWrapper.IncomeDetails();
                                    incDetailsI.incomeSource =''; //blank
                                    incDetailsI.howAreYouPaid =''; //blank
                                    incDetailsI.salaryCreditDay = ''; //blank
                                    incDetailsI.incomePercentage='';//blank
                                    //mandatory fields
                                    Decimal resNetAmt=((totalAmtPLPreviousYear)/12);
                                    incDetailsI.incomeHead= masterDataMap.get('Income Head') !=null ? String.valueOf(masterDataMap.get('Income Head').get('Profit and Loss previous Year')) : '' ; //'217';
                                    incDetailsI.inomeNetAmount= totalAmtPLPreviousYear !=0 ? String.valueOf(totalAmtPLPreviousYear.setScale(2, RoundingMode.HALF_UP)) : '0';
                                    incDetailsI.incomeAmount =  resNetAmt != 0 ? String.valueOf(resNetAmt.setScale(2, RoundingMode.HALF_UP)): '0';
                                    incDetailsI.incomeFeq='1';
                                    listIncDetails.add(incDetailsI);
                                }
                                
                                //ApplicantDetails start
                                LoanBoardingRequestWrapper.ApplicantDetails appDetail =new LoanBoardingRequestWrapper.ApplicantDetails();
                                ApplicantEmployment__c apEmpData =new ApplicantEmployment__c();
                                List<ApplicantEmployment__c> listAppEmp = appEmpMap.get(app.Id);    
                                LoanAppl__c dataLoanApp1= loanAppRecordsMap.get(intMsg.RefId__c); 
                                List<ApplAsset__c> listAppAsset = appAssetMapByLoanApp.get(loanApplnIds[0]);
                                String strPropOwner='';
                                if(listAppAsset!=null && !listAppAsset.isEmpty()){
                                    strPropOwner= listAppAsset[0].Prop_Owners__c !=null ? listAppAsset[0].Prop_Owners__c:'' ;
                                }  
                                if(listAppEmp!=null && !listAppEmp.isEmpty()){
                                    apEmpData=listAppEmp[0];
                                }  
                                
                                if(nonIndivAppIdList ==null && nonIndivAppIdList.isEmpty())
                                {
                                    appDetail.beneficiaryParent='Y';
                                    appDetail.beneficiaryOwnerPercent='0';
                                }
                                else if(app.Constitution__c!=null && !String.valueOf(app.Constitution__c).equalsIgnoreCase('INDIVIDUAL')){
                                    appDetail.beneficiaryParent='Y';
                                    appDetail.beneficiaryOwnerPercent='0';
                                }
                                else if(idForOwPer == app.Id){
                                    appDetail.beneficiaryParent='N';
                                    appDetail.beneficiaryOwnerPercent=String.valueOf(100);
                                }
                                else{
                                    appDetail.beneficiaryParent='N'; //yaha par pahele Y tha
                                    appDetail.beneficiaryOwnerPercent='0';
                                }
                                
                                appDetail.beneficiaryCriteria='0';//Hardcoded
                                appDetail.companyListed='N';//Hardcoded
                                appDetail.passportFileNo = ''; 
                                appDetail.cifNo ='';  
                                appDetail.relatedPersonCKyc =''; 
                                appDetail.assetCat =''; 
                                appDetail.companyName =app.CompanyName__c!=null ?app.CompanyName__c:''; 
                                appDetail.corpTradeLicenseExpiryDate =''; 
                                appDetail.turnOver =''; 
                                appDetail.branch =''; 
                                appDetail.finalRiskGrade =''; 
                                appDetail.qualifyingYear =String.valueOf(app.YearOfRegistration__c)!=null ?String.valueOf(app.YearOfRegistration__c):''; 
                                appDetail.relation =  relationShipMap.containsKey(app.Relationship__c)?relationShipMap.get(app.Relationship__c):'';//'SFI';//hardcoded Not maintaining in Salesforce
                                appDetail.noOfChildInHigh =''; 
                                appDetail.empIDCGSG =''; 
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
                                
                                if(app.Constitution__c!=null && app.Constitution__c != 'INDIVIDUAL' )
                                {
                                    appDetail.lastname = '';//app.CompanyName__c!=null ?app.CompanyName__c:'';
                                }
                                else{
                                    appDetail.lastname =app.LName__c!=null ?app.LName__c:'';
                                }
                                
                                appDetail.groupName =''; 
                                appDetail.fwAccountNo =''; 
                                appDetail.visaExpiryDate =''; 
                                appDetail.addressDocName =''; 
                                appDetail.nationality ='1'; //harcoded
                                
                                if(app.Constitution__c!=null && app.Constitution__c == 'INDIVIDUAL' )
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
                                
                                if(app.Residential_Status__c !=null){
                                    if(app.Residential_Status__c == 'C' || app.Residential_Status__c == 'PR' || app.Residential_Status__c == 'R'){
                                        appDetail.whetherResi =    'Y'; 
                                    }
                                    else{
                                        appDetail.whetherResi =    'N'; 
                                    }
                                }
                                else{
                                    appDetail.whetherResi =    'N';
                                }
                                
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
                                appDetail.customerId =''; 
                                appDetail.preferredIrr =''; 
                                appDetail.uidToken =app.AadhaarNo__c!=null ?app.AadhaarNo__c:''; 
                                appDetail.educQual =app.EduQual__c !=null ?app.EduQual__c:''; 
                                appDetail.currency_Z =''; // in json: currency
                                appDetail.tenureInMonths =loanAppRecordsMap.get(intMsg.RefId__c)!=null ? String.valueOf(loanAppRecordsMap.get(intMsg.RefId__c).Loan_Tenure_Months__c) !=null ?String.valueOf(loanAppRecordsMap.get(intMsg.RefId__c).Loan_Tenure_Months__c) :'':'' ;    //'180';// Hardcoded //'180';//harcoded not master 
                                appDetail.guardian =''; 
                                appDetail.relatedIdExpiryDate =''; 
                                appDetail.passportNo =(appKycsMap.get(app.Id) !=null && !appKycsMap.get(app.Id).isEmpty()) ? appKycsMap.get(app.Id)[0].PassNo__c !=null ?appKycsMap.get(app.Id)[0].PassNo__c :'' :'';  
                                appDetail.passportExpiryDate = (appKycsMap.get(app.Id) !=null && !appKycsMap.get(app.Id).isEmpty()) ? (appKycsMap.get(app.Id)[0] != null) ?   appKycsMap.get(app.Id)[0].PassExpDt__c !=null ? (String.valueOf(appKycsMap.get(app.Id)[0].PassExpDt__c.day()) + '-' + monthMap.get(appKycsMap.get(app.Id)[0].PassExpDt__c.month()) + '-' + String.valueOf(appKycsMap.get(app.Id)[0].PassExpDt__c.year()) ):'':'':'';    
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
                                
                                
                                Industry__c indObjectForName=industryNameMap.get(strIndClass);
                                
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
                                appDetail.group_Z =''; 
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
                                
                                if(dataLoanApp1.LeadSource__c !=null){
                                    if(String.valueOf(dataLoanApp1.LeadSource__c).equalsIgnoreCase('DSA'))
                                    { 
                                        appDetail.dsa =dataLoanApp1.ChanelNme__r.DSAConnId__c !=null ? dataLoanApp1.ChanelNme__r.DSAConnId__c :'';
                                    }
                                    else if(String.valueOf(dataLoanApp1.LeadSource__c).equalsIgnoreCase('Connector'))
                                    {
                                        appDetail.dsa = '';//   dataLoanApp1.ChanelNme__r.VCReferralId__c !=null ? dataLoanApp1.ChanelNme__r.VCReferralId__c : ''; //Sending Blank As per LAK-7405
                                    }
                                }
                                else
                                {
                                    appDetail.dsa ='21';
                                }    
                                
                                appDetail.passportIssueCountry =''; 
                                appDetail.salaryAssign =''; 
                                appDetail.relatedFullname =''; 
                                appDetail.salutation =app.FullName__c != null ? app.FullName__c:''; 
                                appDetail.visaNo =''; 
                                appDetail.region =''; 
                                appDetail.spousePassExpiryDate =''; 
                                appDetail.drivingLicenseIssuedAt =''; 
                                appDetail.bussFinanRatingDetails =listRepayDetails1; 
                                //LAK-8498 Changes Start
                                appDetail.maritalStatus =app.MariStatus__c!=null && masterDataMap.containskey('Marital Status') &&  masterDataMap.get('Marital Status').containsKey(app.MariStatus__c)? masterDataMap.get('Marital Status').get(app.MariStatus__c):''; 
                                //LAK-8498 Changes End
                                appDetail.stakeHolderDetails =listStakDetls; 
                                
                                /* if(app.Constitution__c=='INDIVIDUAL'){
                                // appliDetails.natureOfBusinessWork= apEmpData.NatureOfBusinessIndividual__c;
                                }else{
                                // appliDetails.natureOfBusinessWork=apEmpData.NatureOfBusinessCorporate__c;
                                } 
                                */
                                
                                appDetail.custSegment= masterDataMap.get('Customer Profile')!=null? masterDataMap.get('Customer Profile').get(app.CustProfile__c) !=null ?masterDataMap.get('Customer Profile').get(app.CustProfile__c) :'':''; //masterDataMap.get('Customer Profile').get(app.CustProfile__c) !=null ?masterDataMap.get('Customer Profile').get(app.CustProfile__c) :'';// app.CustProfile__c!=null?app.CustProfile__c:'';
                                appDetail.university =''; 
                                appDetail.liabilityDetails =listLiabDtls; 
                                appDetail.noOfChidNotYet =''; 
                                appDetail.atWhatDayYouArePaid =''; 
                                appDetail.hostAccNo =''; 
                                appDetail.addressDetails =listAddDetails; 
                                appDetail.oldagreementId =''; 
                                
                                if(app.Gender__c!=null && app.Gender__c == 'T'){
                                    appDetail.title = 'MR.';
                                }
                                else{
                                    appDetail.title = app.Title__c !=null ?  String.valueOf(app.Title__c).toUpperCase() :'';
                                }
                                
                                appDetail.companyNameNatLang =''; 
                                appDetail.workDetailsSalaried =wrkDetailSal; 
                                appDetail.subIndustry =  ''; //( appEmpMap.get(app.Id) !=null && !appEmpMap.get(app.Id).isEmpty() )  ? appEmpMap.get(app.Id)[0].SubIndustry__r.Name !=null ?appEmpMap.get(app.Id)[0].SubIndustry__r.Name:'' :''; 
                                appDetail.tanNo =''; 
                                appDetail.vpaUpiPrimary =''; 
                                appDetail.ruralUrbanCustomer =''; 
                                appDetail.drivingLicenseNo =app.DLNo__c!=null ?app.DLNo__c :''; 
                                
                                if(app.Constitution__c == 'INDIVIDUAL' && cibilScoreByAppMap!=null && cibilScoreByAppMap.get(app.Id).size()>0){
                                    appDetail.cibilScore =cibilScoreByAppMap.get(app.Id) !=null ? String.valueOf(cibilScoreByAppMap.get(app.Id)[0].Score__c)   : 'NA'; 
                                    
                                }else{
                                    appDetail.cibilScore ='NA'; //Hardcode  OK
                                }
                                
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
                                appDetail.citizenship ='17'; //OK
                                appDetail.assetModel =''; 
                                appDetail.fullName =app.FullName__c!=null?app.FullName__c:''; 
                                appDetail.dateOfInception = app.DOI__c!=null ? String.valueOf(app.DOI__c.day()) + '-' + monthMap.get(app.DOI__c.month()) + '-' + String.valueOf(app.DOI__c.year()):'';
                                appDetail.relatedAssignee =''; 
                                appDetail.vpaUpiTertiary =''; 
                                appDetail.visaType =''; 
                                appDetail.staffGrade =''; 
                                appDetail.fdDetails =listFddetails; 
                                appDetail.drivingLicenseExpiryDate = app.DrivingLicExpDate__c !=null ? String.valueOf(app.DrivingLicExpDate__c.day()) + '-' + monthMap.get(app.DrivingLicExpDate__c.month()) + '-' + String.valueOf(app.DrivingLicExpDate__c.year())     :''; 
                                appDetail.uniqueCustomerId =app.UCID__c!=null ?app.UCID__c:''; 
                                appDetail.dmeDST =''; 
                                appDetail.middleName =app.MName__c!=null?app.MName__c:''; 
                                appDetail.bankname =''; 
                                appDetail.category =  app.Category__c !=null ? app.Category__c :'';
                                appDetail.staffId =''; 
                                appDetail.age =String.valueOf(app.Age__c)!=null?String.valueOf(app.Age__c):''; 
                                appDetail.additionRelatedPerson =''; 
                                
                                /*
                                if(app.Constitution__c=='INDIVIDUAL'){
                                // appliDetails.natureOfBusinessWork= apEmpData.NatureOfBusinessIndividual__c;
                                }else{
                                // appliDetails.natureOfBusinessWork=apEmpData.NatureOfBusinessCorporate__c;
                                }
                                */
                                listAppDetl.add(appDetail);
                                
                            }  
                            LocMstr__c locdataGst = (finalAddress != null && finalAddress.City__c != null) ? mapLocMas.get(finalAddress.City__c) : null;
                            LocMstr__c locdataGstForgstOnly = (finalGSTObj != null && finalGSTObj.City__c != null) ? mapLocMas.get(finalGSTObj.City__c) : null;
                            String addressTypeGst=(finalAddress != null && masterDataMap.get('Address Type') != null && masterDataMap.get('Address Type').get(finalAddress.AddrTyp__c) != null) ? masterDataMap.get('Address Type').get(finalAddress.AddrTyp__c) : '';
                            gstInDetails=LoanBoardingUtility.populateGSTDetails(finalAppEmpObj,finalAddress,finalGSTObj,locdataGst,locdataGstForgstOnly,addressTypeGst);
                            
                            LoanBoardingRequestWrapper.MainLoanApp mainLoanObj= new LoanBoardingRequestWrapper.MainLoanApp();
                            mainLoanObj.crossCollateral = listCrsCol; 
                            mainLoanObj.sourceSystem = liMdtReqd !=null ? liMdtReqd[0].SourceSystem__c :'';
                            mainLoanObj.repaymentDetails =listRepayDetails1 ; 
                            mainLoanObj.notepadDetails = listNoteDetails; 
                            mainLoanObj.splitDisbursalDetails = listSplitDis; 
                            mainLoanObj.confirmationLog = conLog; 
                            mainLoanObj.password = liMdtReqd!=null ? liMdtReqd[0].Password__c : '';
                            mainLoanObj.applicantDetails = listAppDetl; 
                            mainLoanObj.instrumentDetails = instDetails; 
                            mainLoanObj.propertyDetails = listProp; 
                            mainLoanObj.insuranceDetails = insDetail; 
                            mainLoanObj.teleVerification = listRepayDetails1; 
                            mainLoanObj.jsonVersion = System.Label.LoanB_JsonVersion;   //'LB-PL-NEv1.0'; //OK
                            mainLoanObj.personalDiscussion =listPerDiscussion ; 
                            mainLoanObj.unqRequestId = 	finalUnqNum;//GlobalUtility.getUniqueNumber();  
                            mainLoanObj.tradeInDetail =listtradeInDeatil ; 
                            mainLoanObj.gradedRepaymentDetails = listGradedPay; 
                            mainLoanObj.loanDetails =lnDetails ; 
                            mainLoanObj.chargesDetails = listChrdetails; 
                            mainLoanObj.collateralDetails =listColDetails ; 
                            mainLoanObj.sourcingDetail =srcDetail ; 
                            mainLoanObj.fivCheckList =listFivChk ; 
                            mainLoanObj.userId = liMdtReqd!=null ? liMdtReqd[0].Username__c :''; 
                            mainLoanObj.referenceDetails =listRefdetails ; 
                            mainLoanObj.rateRiskDetails =listRateRiskDetails ; 
                            mainLoanObj.gSTInfoDetails =gstInDetails ; 
                            mainLoanObj.bussinessVerification =busVer ; 
                            mainLoanObj.initialMoneyDepositDetails =listIniMoneyDetails ; 
                            
                            String finalJsonString =JSON.serialize(mainLoanObj).replace('group_Z', 'group').replace('currency_Z','currency').replace('null', '""');
                            
                            IntgMsg__c intgr=New IntgMsg__c();
                            intgr.id=intMsg.id;
                            intgr.Upsert_Record_Ids__c=disbIdVal!=null ? disbIdVal :'';
                            if(!String.isBlank(finalJsonString)){
                                intgr.Req__c = finalJsonString;
                            }else{
                                intgr.Req__c = '';
                            }
                            
                            intgr.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                            updateIntRecords.add(intgr);
                            
                        }
                        
                    }
                    if(updateIntRecords!=null && !updateIntRecords.isEmpty()) {
                        String sObjectName = 'IntgMsg__c';
                        List<String> fieldNamesList = new List<String>{'Req__c','Status__c','Upsert_Record_Ids__c'};
                            Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                        fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                        uow.registerDirty(updateIntRecords);
                    }
                }
                uow.commitWork();
            }
        }
        catch(Exception ex){
            System.debug(ex);  
            System.debug('Line::'+ex.getLineNumber());     
            System.debug('error'+ex.getMessage());
            GlobalUtility.logMessage('Error', 'LoanBoardingRequestGenerator.' + ex.getLineNumber(), 
                                     'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
    }
      
    
    private class CaseWrapper implements Comparable {
    public Case caseRecord;
    
    public CaseWrapper(Case caseRecord) {
        this.caseRecord = caseRecord;
    }

public Integer compareTo(Object other) {
        CaseWrapper otherWrapper = (CaseWrapper) other;
        // Compare dates in descending order
        if (this.caseRecord.Date_of_Report__c > otherWrapper.caseRecord.Date_of_Report__c) {
            return -1;
        } else if (this.caseRecord.Date_of_Report__c < otherWrapper.caseRecord.Date_of_Report__c) {
            return 1;
        } else {
            return 0;
        }
    }
}
    
}