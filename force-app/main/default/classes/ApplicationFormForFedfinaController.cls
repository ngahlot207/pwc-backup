public with sharing class ApplicationFormForFedfinaController {
    transient public String recordId{get;set;}
    public List<ApplBanking__c> applBnkList { get; set; }
    public LoanAppl__c loanApplRec { get; set; }
    transient public string formattedDate{get;set;}
    transient public string Product{get;set;}
    transient public string constitution{get;set;}
    public list<RegltryPrsonl__c> regulObj { get; set; }
    public string StaticContent { get; set; }
    public string StaticContentForText { get; set; }
    public string StaticContentForText1 { get; set; }
    public string StaticContentForText2 { get; set; }
    public Boolean isChecked{ get; set;}
    public Boolean checkedNo{ get; set;}
   // transient public Map<integer,String> mapofContent{get;set;}
    transient public ApplicantWrapper applicantWrapper { get; set; }
    transient public list<ApplicantWrapper> twoAppWrapperList { get; set; }
    transient public list<ApplicantWrapper> RemAllAppWrapperList { get; set; }
    transient public Map<string, string> mapFieldWithVal1 { get; set; }
    transient public Map<string, string> mapFieldWithVal2 { get; set; }
    transient public map<string, string> appRegMap { get; set; }
    transient public map<string, string> appRegMap1 { get; set; }
    transient public List<ApplAsset__c> propType{get;set;}
    transient public String PropertyType{get;set;}
    transient public String PropertyAddress{get;set;}
    transient public String natureOfPro{get;set;}
    transient public String pinCode{get;set;}
    transient public String state{get;set;}
    transient public String city{get;set;}
    transient public decimal builtArea{get;set;}
    transient public String propertyUse{get;set;}
    transient public String BTFinancier{get;set;}
    transient public decimal OutStanVal{get;set;}
    transient public string insurType{get;set;}
    transient public Decimal totalCost{get;set;}
    transient public Decimal amenities{get;set;}
    transient public Decimal registCost{get;set;}
    transient public Decimal constCost{get;set;}
    transient public Decimal lancost{get;set;}
    transient public string commuAdress{get;set;}
    transient public Decimal Amount{get;set;}
    transient public string chequeNo{get;set;}
    transient public string paymentMode{get;set;}
    transient public string bankName{get;set;}
    transient public string dateOfCheck{get;set;}
    transient public string rateofInter{get;set;}
    transient public Decimal monthlyExpense{get;set;}
    transient public string totalFamilyMem{get;set;}
    transient public string source1{get;set;}
    transient public string source2{get;set;}
    transient public Decimal downPay{get;set;}
    transient public Decimal OcrBal{get;set;}
    transient public boolean showBottomSpace{get;set;}
    transient public string photoUrlforApp{get;set;}
    transient public string photoTypeforApp{get;set;}
    transient public string yes_checkbox{get;set;}
    transient public string no_checkbox{get;set;}
    transient public string lifeIns_checkbox{get;set;}
    transient public string genIns_checkbox{get;set;}
    transient public list<ChargeWrapper> ChargeWrapperList { get; set; }
    public ApplicationFormForFedfinaController() {
        recordId=ApexPages.currentPage().getParameters().get('recordId');
        if(recordId==null){
            recordId = 'a08C40000082ahBIAQ'; 
        }
      
        ApplicantWrapper = new ApplicantWrapper();
        applBnkList = [select id, AccountType__c, SFDC_Bank_Master_Name__c, AC_No__c, Bank_Branch__c, type__c from ApplBanking__c where LoanAppl__c =:recordId and type__c=:'' and IsDeleted__c != true And  Appl__r.Type_of_Borrower__c =:'Financial'];
        loanApplRec= [select id,TotalOwnContri__c,IsConstruction__c,SchmCode__c,Rate_Type_Floating_Flag__c,ProductSubType__c,EMIIcludingInsurance__c, Name,ReqLoanAmt__c,Loan_Tenure_Months__c,PropertyIdentified__c, Formatted_Login_Acceptance_Date__c, Product__c, BrchCode__c, BrchName__c, RMSMName__r.Name, RMSMEmployeeID__c, ChannelName__c, ChannelCode__c,ChanelNme__r.name, LoanPurpose__c  from LoanAppl__c where id=:recordId LIMIT 1];
        if(loanApplRec.Rate_Type_Floating_Flag__c=='Y'){
            rateofInter='Floating';
        }else if(loanApplRec.Rate_Type_Floating_Flag__c=='N'){
			rateofInter='Fixed';            
        }
        list<ApplIMD__c> loanIMDRecList= [select id,PaymentRefNo__c,TransDt__c,CheqClrDate__c,Amount__c,FinnoneChequeId__c, InstrumentNo__c,DealingBank__r.Name, InstrumentDt__c, PaymentMode__c from ApplIMD__c where LoanAppln__c=:recordId];
        propType = [Select id,Balance_OCR_to_be_arranged_by_customer__c, Agrem_Value__c,Down_payment_PartORegisteredAgreement__c,Stamp_Duty__c, Amenities__c,Appr_Cost_of_Const__c,Cost_of_Plot__c,Regi_Cost__c,Total_Prop_Cost__c, PropAddrs__c,AddrLn2__c,Prop_Bui_up_ar__c,Landmark__c, AddrLn1__c,Pin_Code__c, State__c, City__c, FlatNo__c, NatureofProp__c, PropType__c,Property_Usage__c, PropSubType__c,ValuationToBeTakenAheadForCalculation__c, Total_Valua__c from ApplAsset__c where Appl__r.LoanAppln__r.Id =:recordId and ValuationToBeTakenAheadForCalculation__c!=null order by ValuationToBeTakenAheadForCalculation__c desc];
        if (propType.size()>0){
                system.debug('PropAddrs__c'+propType[0].PropAddrs__c);
                if((loanApplRec.Product__c =='Home Loan' && loanApplRec.ProductSubType__c !='') ||(loanApplRec.Product__c =='Small Ticket LAP' && loanApplRec.ProductSubType__c =='Commercial Property Purchase')){
                    PropertyType = propType[0].PropType__c != null ? propType[0].PropType__c: '';
                string flateNo=propType[0].FlatNo__c != null ? propType[0].FlatNo__c: '';
                string AddLine1=propType[0].AddrLn1__c != null ? propType[0].AddrLn1__c: '';
                string Addline2=propType[0].AddrLn2__c != null ? propType[0].AddrLn2__c: '';
                PropertyAddress = flateNo+', '+ AddLine1 +' '+Addline2;
                pinCode =propType[0].Pin_Code__c != null ? propType[0].Pin_Code__c: '';
                state=propType[0].Landmark__c != null ? propType[0].Landmark__c: '';
                city=propType[0].City__c != null ? propType[0].City__c: '';
                natureOfPro = propType[0].NatureofProp__c != null ? propType[0].NatureofProp__c: '';
                builtArea = propType[0].Prop_Bui_up_ar__c != null ? propType[0].Prop_Bui_up_ar__c: null;
                propertyUse = propType[0].Property_Usage__c != null ? propType[0].Property_Usage__c: '';
                downPay=propType[0].Down_payment_PartORegisteredAgreement__c != null ? propType[0].Down_payment_PartORegisteredAgreement__c: null;
                lancost=propType[0].Agrem_Value__c != null ? propType[0].Agrem_Value__c: null;
                if(loanApplRec.IsConstruction__c==true){
                    constCost = propType[0].Appr_Cost_of_Const__c != null ? propType[0].Appr_Cost_of_Const__c: null;
                }
                
                decimal registCost1 = propType[0].Regi_Cost__c != null ? propType[0].Regi_Cost__c: 0;
                decimal stampcost = propType[0].Stamp_Duty__c != null ? propType[0].Stamp_Duty__c: 0;
                registCost=registCost1+stampcost;
                OcrBal = propType[0].Balance_OCR_to_be_arranged_by_customer__c != null ? propType[0].Balance_OCR_to_be_arranged_by_customer__c: null;
                amenities = propType[0].Amenities__c != null ? propType[0].Amenities__c: null;
                totalCost = propType[0].Total_Prop_Cost__c != null ? propType[0].Total_Prop_Cost__c: null;
                source1 = totalCost ==null ? '': 'Bank-Own Contribution in Bank';
                source2 = totalCost ==null ? '': 'Cash-Own Contribution in Cash';
            }
            
        }
        if (loanIMDRecList.size()>0){
            // if(loanIMDRecList[0].CheqClrDate__c != null){
            //     datetime mydate=loanIMDRecList[0].CheqClrDate__c;
            //     string formateDate=mydate.format('dd-MMM-yyyy');
            //     dateOfCheck = formateDate;
            // }
            if(loanIMDRecList[0].TransDt__c != null && loanIMDRecList[0].PaymentMode__c =='Payment Gateway') {
                Datetime myDateTime=loanIMDRecList[0].TransDt__c;
                String formateDate=myDateTime.format('dd-MM-yyyy');
                dateOfCheck = formateDate;
            }
            else if(loanIMDRecList[0].InstrumentDt__c != null){
                Date mydate=loanIMDRecList[0].InstrumentDt__c;
                Datetime myDateTime = Datetime.newInstance(mydate.year(), mydate.month(), mydate.day(), 0, 0, 0);
                String formateDate=myDateTime.format('dd-MM-yyyy');
                dateOfCheck = formateDate;
            }
             Amount = loanIMDRecList[0].Amount__c != null ? loanIMDRecList[0].Amount__c: null;
            bankName = loanIMDRecList[0].DealingBank__r.name != null ? loanIMDRecList[0].DealingBank__r.name: null;
            paymentMode='';
            if(loanIMDRecList[0].PaymentMode__c =='Cheque'){
                // chequeNo = loanIMDRecList[0].FinnoneChequeId__c != null ? loanIMDRecList[0].FinnoneChequeId__c: null;
                chequeNo = loanIMDRecList[0].InstrumentNo__c != null ? loanIMDRecList[0].InstrumentNo__c: null;
                paymentMode = 'cheque';
            }else if(loanIMDRecList[0].PaymentMode__c =='DD'){
                // chequeNo = loanIMDRecList[0].FinnoneChequeId__c != null ? loanIMDRecList[0].FinnoneChequeId__c: null;
                chequeNo = loanIMDRecList[0].InstrumentNo__c != null ? loanIMDRecList[0].InstrumentNo__c: null;
                paymentMode = 'DD';
            }else{
                chequeNo = loanIMDRecList[0].PaymentRefNo__c != null ? loanIMDRecList[0].PaymentRefNo__c: null;
                paymentMode = 'online payment ref';
            }
            
        }
        
        formattedDate =loanApplRec.Formatted_Login_Acceptance_Date__c == '' || loanApplRec.Formatted_Login_Acceptance_Date__c == null ? '' : loanApplRec.Formatted_Login_Acceptance_Date__c;
        Product=loanApplRec.Product__c == '' || loanApplRec.Product__c == null ? '' : loanApplRec.Product__c;
        List<Applicant__c> applicantRecList =[select id,AssessmentProgram__c,InceptionYears__c,ID_Number__c,ID_proof_type__c, Constitution__c,AadhaarNo__c, PhoneNumber__c,FullName__c,Religion__c,Nationality__c,CustProfile__c,CompanyName__c, Title__c,MName__c,LName__c, FName__c,SpName__c, Father_Name__c, MthrMdnName__c,DOB__c, DOI__c,tolabel(MariStatus__c),tolabel(Gender__c),tolabel(Residential_Status__c),tolabel(Category__c),tolabel(EduQual__c), MobNumber__c, EmailId__c, Average_Monthly_Gross_Salary__c, PAN__c,CKYC_Number__c, Type_of_Borrower__c,ApplType__c from Applicant__c where LoanAppln__c=:recordId AND ApplType__c='P' LIMIT 1];
        List<Applicant__c> coAplicantRecs =[select id,AssessmentProgram__c,InceptionYears__c,ID_Number__c,ID_proof_type__c,Constitution__c, AadhaarNo__c,PhoneNumber__c,FullName__c, Religion__c,Nationality__c,CustProfile__c,CompanyName__c, Title__c,MName__c,LName__c, FName__c,SpName__c, Father_Name__c, MthrMdnName__c,DOB__c, DOI__c,tolabel(MariStatus__c),tolabel(Gender__c),tolabel(Residential_Status__c),tolabel(Category__c),tolabel(EduQual__c), MobNumber__c, EmailId__c, Average_Monthly_Gross_Salary__c, PAN__c,CKYC_Number__c,Type_of_Borrower__c,ApplType__c from Applicant__c where LoanAppln__c=:recordId AND (ApplType__c ='G' OR ApplType__c ='C')];
        
        List<String> addTypeList = new List<String>{'Residence Address', 'Residence Cum office', 'Office Address', 'Permanent Address', 'Principal place for business'};
        set<Id> allAppliIds= new set<Id>();
        system.debug('coAplicantRecs'+coAplicantRecs.size());
        Applicant__c applicantRec=new Applicant__c();
        if (applicantRecList.size()>0) {
            applicantRec=applicantRecList[0];
            allAppliIds.add(applicantRec.Id);
            
            string typeOfApp=applicantRec.Constitution__c;
            string profileType=applicantRec.CustProfile__c;
            applicantWrapper.custProfile = applicantRec.CustProfile__c;
            applicantWrapper.numberOfDep=toGetPDData(recordId, applicantRecList[0]);
            
            if(typeOfApp=='INDIVIDUAL'){
                constitution = 'INDIVIDUAL';
                if(getApplicantPhotos(allAppliIds).size()==2){
					photoUrlforApp=getApplicantPhotos(allAppliIds)[1];
                	photoTypeforApp=getApplicantPhotos(allAppliIds)[0];                    
                }
               
                if(applicantRec.DOB__c !=null){
                datetime mydatetime=applicantRec.DOB__c;
                string formattedDate1=mydatetime.format('dd-MMM-yyyy');
                applicantWrapper.dob = formattedDate1;
            	}
                applicantWrapper.mthrMdnName = applicantRec.MthrMdnName__c;
                applicantWrapper.title = applicantRec.Title__c;
                applicantWrapper.mName = applicantRec.MName__c;
                applicantWrapper.lName = applicantRec.LName__c;
                applicantWrapper.fName = applicantRec.FName__c;
                if(applicantRec.MariStatus__c=='SINGLE'){
                    applicantWrapper.spName = applicantRec.Father_Name__c;
                }else{
                    applicantWrapper.spName = applicantRec.SpName__c;
                }
                applicantWrapper.mariStatus = applicantRec.MariStatus__c;
                applicantWrapper.gender = applicantRec.Gender__c;
                
                applicantWrapper.category = applicantRec.Category__c;
                applicantWrapper.eduQual = applicantRec.EduQual__c;
				 if(applicantRec.AadhaarNo__c !='' && applicantRec.AadhaarNo__c !=null){
                    applicantWrapper.UIDNo = formatAadhaar(applicantRec.AadhaarNo__c);
                 }else{
                    	if(applicantRec.ID_proof_type__c !='' && applicantRec.ID_Number__c !=''){
                             applicantWrapper.UIDNo = applicantRec.ID_proof_type__c+'-'+maskId(applicantRec.ID_Number__c);
                        }
                     
                 }
                applicantWrapper.Religion = applicantRec.Religion__c;
                
            }else{
                //applicantWrapper.companyName = applicantRec.CompanyName__c;
                if(applicantRec.DOI__c !=null){
                datetime mydatetime=applicantRec.DOI__c;
                string formattedDate1=mydatetime.format('dd-MMM-yyyy');
                applicantWrapper.dob = formattedDate1;
            	}
                applicantWrapper.fName = applicantRec.CompanyName__c;
            }
            
            applicantWrapper.residentialStatus = applicantRec.Residential_Status__c;
            applicantWrapper.MobileNumber = applicantRec.MobNumber__c;
            applicantWrapper.phoneNo = applicantRec.PhoneNumber__c;
            applicantWrapper.fullName = applicantRec.FullName__c;
            applicantWrapper.emailId = applicantRec.EmailId__c;
            applicantWrapper.pan = applicantRec.PAN__c;
            applicantWrapper.ckycNumber = applicantRec.CKYC_Number__c;
            applicantWrapper.Nationality = applicantRec.Nationality__c;
            
            List<Applicant_Income__c> appliIncRecList=[select NET_CASH_PROFIT_LOSS__c, IncomeType__c from Applicant_Income__c where Applicant__c=:applicantRec.Id and (IncomeType__c =:'Cash Salary' or IncomeType__c =:'Bank Credit Salarys') ];
           List<ApplicantEmployment__c> appliEmployRecList=[select CurrentBusinessVintage_Years__c, CurrentBusinessVintage_Months__c, EntityName__c, tolabel(NatureOfBusinessIndividual__c), tolabel(NatureOfBusinessCorporate__c), id,UdyamRegistrationNumber__c,tolabel(TypeOfOrganisation__c),TotalWorkExperience_Years__c,TotalWorkExperience_Months__c,DesignationValues__c,DesignationText__c,RetirementAge__c,OfficialEmail__c,WorkingWithCurrentEmployer_Months__c,WorkingWithCurrentEmployer_Years__c, EmployerName__r.Name from ApplicantEmployment__c where LoanApplicant__c=:applicantRec.Id];
            
            List<BRE__c> breRec=[select id, Mnthlyapprincome__c,Applicant__c from BRE__c where Applicant__c =:applicantRec.Id and IsLatest__c=:true ];
            if (appliEmployRecList.size()>0) {
                ApplicantEmployment__c appliEmployRec=appliEmployRecList[0];
                if(typeOfApp=='INDIVIDUAL'){
                    applicantWrapper.designationText = appliEmployRec.DesignationText__c;
                    applicantWrapper.typeOfOrganisation = appliEmployRec.NatureOfBusinessIndividual__c;
                    //applicantWrapper.typeofBuss = appliEmployRec.TypeOfOrganisation__c;
                    Decimal year=appliEmployRec.TotalWorkExperience_Years__c ==null ? 0: appliEmployRec.TotalWorkExperience_Years__c;
                    Decimal Months=appliEmployRec.TotalWorkExperience_Months__c ==null ? 0: appliEmployRec.TotalWorkExperience_Months__c;
                    applicantWrapper.totalWorkExperienceYears = String.valueOf(year) +' Years - '+String.valueOf(Months) +' Months';
                    applicantWrapper.retirementAge = appliEmployRec.RetirementAge__c;
                }else{
                    applicantWrapper.typeOfOrganisation = appliEmployRec.NatureOfBusinessCorporate__c;
                }
                if(profileType == 'SALARIED' && typeOfApp =='INDIVIDUAL'){
                	applicantWrapper.companyName = appliEmployRec.EmployerName__r.name;
                    applicantWrapper.typeofBuss = appliEmployRec.TypeOfOrganisation__c;
                    Decimal year1=appliEmployRec.WorkingWithCurrentEmployer_Years__c ==null ? 0: appliEmployRec.WorkingWithCurrentEmployer_Years__c;
                    Decimal Months1=appliEmployRec.WorkingWithCurrentEmployer_Months__c ==null ? 0: appliEmployRec.WorkingWithCurrentEmployer_Months__c;
                    applicantWrapper.workingWithCurrentEmployerYears = String.valueOf(year1) +'Years - '+String.valueOf(Months1) +' Months';
                	
                }else if((profileType == 'SELF EMPLOYED PROFESSIONAL' || profileType == 'SELF EMPLOYED NON PROFESSIONAL') && typeOfApp =='INDIVIDUAL'){
                    applicantWrapper.companyName = appliEmployRec.EntityName__c;
                    applicantWrapper.typeofBuss = appliEmployRec.TypeOfOrganisation__c;
                    Decimal year1=appliEmployRec.CurrentBusinessVintage_Years__c ==null ? 0: appliEmployRec.CurrentBusinessVintage_Years__c;
                    Decimal Months1=appliEmployRec.CurrentBusinessVintage_Months__c ==null ? 0: appliEmployRec.CurrentBusinessVintage_Months__c;
                    applicantWrapper.workingWithCurrentEmployerYears = String.valueOf(year1) +'Years - '+String.valueOf(Months1) +' Months';
                	
                }else if((profileType == 'SELF EMPLOYED PROFESSIONAL' || profileType == 'SELF EMPLOYED NON PROFESSIONAL') && typeOfApp !='INDIVIDUAL'){
                    applicantWrapper.companyName = applicantRec.CompanyName__c;
                    applicantWrapper.typeofBuss = applicantRec.Constitution__c;
                    applicantWrapper.workingWithCurrentEmployerYears=String.valueOf(applicantRec.InceptionYears__c);
                }else{
                    applicantWrapper.companyName = '';
                        applicantWrapper.typeofBuss='';
                    applicantWrapper.workingWithCurrentEmployerYears='';
                }
                
                /*if(appliEmployRec.DesignationValues__c != ''){
                    applicantWrapper.designationText = appliEmployRec.DesignationValues__c;
                }else{
                    applicantWrapper.designationText = appliEmployRec.DesignationText__c;
                }*/
                if(profileType == 'SALARIED'){
                    if(appliIncRecList.size()>0){
                        if(applicantRec.Average_Monthly_Gross_Salary__c !=null &&  appliIncRecList[0].IncomeType__c=='Bank Credit Salary'){
                        applicantWrapper.avgMonthlyGrossSalary = applicantRec.Average_Monthly_Gross_Salary__c;
                        }else if(applicantRec.Average_Monthly_Cash_Salary__c !=null && appliIncRecList[0].IncomeType__c=='Cash Salary'){
                            applicantWrapper.avgMonthlyGrossSalary = applicantRec.Average_Monthly_Gross_Salary__c;
                        }
                    }
                }else if(profileType == 'SELF EMPLOYED PROFESSIONAL' || profileType == 'SELF EMPLOYED NON PROFESSIONAL'){
                    if(applicantRec.AssessmentProgram__c=='Assessed Income Program'){
                        
                    }else if(applicantRec.AssessmentProgram__c=='Regular Income Program'){
                        if(breRec.size()>0){
                            applicantWrapper.avgMonthlyGrossSalary = breRec[0].Mnthlyapprincome__c;
                        }
                    }
                }
                applicantWrapper.udyamRegistrationNumber = appliEmployRec.UdyamRegistrationNumber__c;
                applicantWrapper.officialEmail = appliEmployRec.OfficialEmail__c;
            }
            list<Insurance__c> insuList=[select id, InsType__c from Insurance__c where LoanAppln__c=: recordId];
            
            if(insuList.size()>0){

                //LAK-9425
                yes_checkbox = URL.getOrgDomainUrl().toExternalForm() +''+ PageReference.forResource('Checked_Checkbox').getUrl();
                no_checkbox = URL.getOrgDomainUrl().toExternalForm() +''+ PageReference.forResource('Blank_Check_box_Image').getUrl();
                // insurType=insuList[0].InsType__c != null ? insuList[0].InsType__c: '';

                Set<String> insuranceTypes = new Set<String>();
                for (Insurance__c ins : insuList) {
                    if (ins.InsType__c != null) {
                        insuranceTypes.add(ins.InsType__c);
                    }
                }
                insurType = String.join(new List<String>(insuranceTypes), ', ');

                if (insuranceTypes.contains('Life Insurance')){
                    lifeIns_checkbox = URL.getOrgDomainUrl().toExternalForm() +''+ PageReference.forResource('Checked_Checkbox').getUrl();
                }
                else{
                    lifeIns_checkbox = URL.getOrgDomainUrl().toExternalForm() +''+ PageReference.forResource('Blank_Check_box_Image').getUrl();
                }

                if (insuranceTypes.contains('General Insurance')){
                    genIns_checkbox = URL.getOrgDomainUrl().toExternalForm() +''+ PageReference.forResource('Checked_Checkbox').getUrl();
                }
                else{
                    genIns_checkbox = URL.getOrgDomainUrl().toExternalForm() +''+ PageReference.forResource('Blank_Check_box_Image').getUrl();
                }
            
            }
            else{
                yes_checkbox = URL.getOrgDomainUrl().toExternalForm() +''+ PageReference.forResource('Blank_Check_box_Image').getUrl();
                no_checkbox = URL.getOrgDomainUrl().toExternalForm() +''+ PageReference.forResource('Checked_Checkbox').getUrl();
                insurType = '';
            }
        }
        
        //List<String> addTypeList = new List<String>{'Residence Address', 'Residence Cum office', 'Office Address', 'Permanent Address'};
        list<ApplAddr__c> residAddress= new list<ApplAddr__c>();
        list<ApplAddr__c> officeAddress= new list<ApplAddr__c>();
        list<ApplAddr__c> CurrentAddress= new list<ApplAddr__c>();
        list<ApplAddr__c> appliAdds=[select id,AddrTyp__c,isPerSameAsResi_ADD__c, Sm_as_Per_Adr__c,AddrLine2__c,AddrLine1__c,City__c,Locality__c,Country__c,FullAdrs__c,HouseNo__c,MailAddr__c,Landmark__c,ToLabel(OwnType__c),State__c,Pincode__c from ApplAddr__c where Applicant__c=:applicantRec.Id AND AddrTyp__c IN: addTypeList];
        if(appliAdds.size()>0){
            for(ApplAddr__c appAdd: appliAdds){
                if(appAdd.MailAddr__c==true){
                    commuAdress=appAdd.HouseNo__c+' '+appAdd.AddrLine1__c + ' ' + appAdd.AddrLine2__c +' '+ appAdd.City__c + ' '+appAdd.Pincode__c;
                }
                if(appAdd.AddrTyp__c =='Residence Address'){
                    //residAddress.add(appAdd);
                    CurrentAddress.add(appAdd);
                }else if(appAdd.AddrTyp__c =='Office Address'){
                    officeAddress.add(appAdd);
                }
                else if(appAdd.AddrTyp__c =='Principal place for business'){
                    officeAddress.add(appAdd);
                }
                else if(appAdd.AddrTyp__c =='Registered place for business'){
                    if(officeAddress.size()==0){
                        officeAddress.add(appAdd);
                    }
                    
                }
                
                
                else if(appAdd.AddrTyp__c=='Residence Cum office'){
                    // if(residAddress.size()==0){
                    //     residAddress.add(appAdd);
                    // }
                    if(CurrentAddress.size()==0){
                        CurrentAddress.add(appAdd);
                    }
                    if(officeAddress.size()==0){
                        officeAddress.add(appAdd);
                    }
                }else if(appAdd.AddrTyp__c =='Permanent Address'){
                    if(appAdd.Sm_as_Per_Adr__c==true){
                        CurrentAddress.add(appAdd);             
                    }
                    if(appAdd.isPerSameAsResi_ADD__c && residAddress.size()==0){
                        residAddress.add(appAdd);
                    }
                }
            }
        }
        
        if(residAddress.size() > 0) {
            ApplAddr__c resAddr = residAddress[0];
            applicantWrapper.ResiAddress = resAddr.HouseNo__c+' '+resAddr.AddrLine1__c + ' ' + resAddr.AddrLine2__c;
            applicantWrapper.ResiLandmark = resAddr.Landmark__c;
            applicantWrapper.ResiCity = resAddr.City__c;
            applicantWrapper.ResiPin = resAddr.Pincode__c;
            applicantWrapper.ResidanceType = resAddr.OwnType__c;
            /*if(resAddr.OwnType__c=='O'){
                applicantWrapper.rentedOwned = 'Owned';
            }else if(resAddr.OwnType__c=='R'){
                applicantWrapper.rentedOwned = 'Rented';
            }*/
        }

        if(officeAddress.size() > 0) {
            ApplAddr__c offAddr = officeAddress[0];
            applicantWrapper.officeAddress = offAddr.HouseNo__c+' '+ offAddr.AddrLine1__c + ' ' + offAddr.AddrLine2__c;
            applicantWrapper.officeLandmark = offAddr.Landmark__c;
            applicantWrapper.officeCity = offAddr.City__c;
            applicantWrapper.officePin = offAddr.Pincode__c;
            applicantWrapper.ResidanceType = offAddr.OwnType__c;
            /*if(offAddr.OwnType__c=='O'){
                applicantWrapper.rentedOwned = 'Owned';
            }else if(offAddr.OwnType__c=='R'){
                applicantWrapper.rentedOwned = 'Rented';
            }*/
            
        }

        if(CurrentAddress.size() > 0) {
            ApplAddr__c curAddr = CurrentAddress[0];
            applicantWrapper.CurreAddress = curAddr.HouseNo__c+' '+curAddr.AddrLine1__c + ' ' + curAddr.AddrLine2__c;
            applicantWrapper.CurreLandmark = curAddr.Landmark__c;
            applicantWrapper.CurreCity = curAddr.City__c;
            applicantWrapper.CurrePin = curAddr.Pincode__c;
            applicantWrapper.ResidanceType = curAddr.OwnType__c;
            /*if(curAddr.OwnType__c=='O'){
                applicantWrapper.rentedOwned = 'Owned';
            }else if(curAddr.OwnType__c=='R'){
                applicantWrapper.rentedOwned = 'Rented';
            }*/
        }
        mapFieldWithVal1=new Map<string, string>();
        mapFieldWithVal2=new Map<string, string>();
        List<string> allKeys=new List<string>{'Add', 'ContactNo', 'FName', 'RelationshipWthApp', 'Title', 'Email', 'Landmark', 'City', 'Pincode'};
        for (String key : allKeys) {
            if (!mapFieldWithVal1.containsKey(key)) {
                mapFieldWithVal1.put(key, '');
            }
            if (!mapFieldWithVal2.containsKey(key)) {
                mapFieldWithVal2.put(key, '');
            }
        }
        List<Ref__c> refreObjList=[select id, Title__c, toLabel(RelationshipWthApp__c), FName__c, ContactNo__c, Applicant__c, Add__c, Landmark__c, City__c, Pincode__c from Ref__c where Loan_Application__c=:recordId and Applicant__c =:applicantRec.Id order by PrsnlDis__r.CmpltDt__c  ASC ];
        if(refreObjList.size()>0){
            for (Integer i = 0; i < refreObjList.size(); i++) {
                Ref__c ref = refreObjList[i];
                string contactVal=String.valueOf(ref.ContactNo__c);
                Map<String, String> currentMap = (i == 0) ? mapFieldWithVal1 : mapFieldWithVal2;
                currentMap.put('Add', ref.Add__c == '' || ref.Add__c == null ? '' : ref.Add__c);
                currentMap.put('Title', ref.Title__c == '' || ref.Title__c == null ? '' : ref.Title__c);
                currentMap.put('FName', ref.FName__c == '' || ref.FName__c == null ? '' : ref.FName__c.toUpperCase());
                currentMap.put('RelationshipWthApp', ref.RelationshipWthApp__c == '' || ref.RelationshipWthApp__c == null ? '' : ref.RelationshipWthApp__c);
                currentMap.put('ContactNo', contactVal == null || contactVal=='' ? '' : contactVal);
                currentMap.put('Landmark', ref.Landmark__c == '' || ref.Landmark__c == null ? '' : ref.Landmark__c);
                currentMap.put('City', ref.City__c == '' || ref.City__c == null ? '' : ref.City__c);
                currentMap.put('Pincode', ref.Pincode__c == '' || ref.Pincode__c == null ? '' : ref.Pincode__c);
            }
        }
        appRegMap=new map<string, string>();
        appRegMap1=new map<string, string>();
        List<string> allKeysForReg=new List<string>{'IAmDirector', 'IAmrelative', 'InteresedAsPather', 'InteresedAsShareHolder', 'SeniorOffice', 'relativeSeniorOffice'};
        for (String key : allKeysForReg) {
            if (!appRegMap.containsKey(key)) {
                appRegMap.put(key, '');
                appRegMap1.put(key, '');
            }
        }
        set<Id> appRegIds=new set<Id>();
        map<Id, ApplRegltry__c> mapOfAppReg=new map<Id, ApplRegltry__c>();
        List<ApplRegltry__c> appliRec=[select id, Appl__c,IsBorowrOrRelFFDir__c, FFDirRelIntrstAsSH__c, FFDirRelIntrstAsPart__c,DirName__c, Reltnshp__c from ApplRegltry__c where LoanAppln__c=:recordId];
        for(ApplRegltry__c appReg: appliRec){
            if(appReg.IsBorowrOrRelFFDir__c =='Yes' || appReg.FFDirRelIntrstAsSH__c=='Yes' || appReg.FFDirRelIntrstAsPart__c=='Yes'){
                appRegIds.add(appReg.Id);
                mapOfAppReg.put(appReg.Id, appReg);
            }
            system.debug('appReg'+appReg);
            if(appReg.IsBorowrOrRelFFDir__c =='Yes'){
                appRegMap.put('IAmDirector', 'Yes');
                appRegMap1.put('IAmDirector', '');
                appRegMap.put('IAmrelative', 'Yes');
                appRegMap1.put('IAmrelative', '');
                appRegMap.put('relativeSeniorOffice', 'Yes');
                appRegMap1.put('relativeSeniorOffice', '');
                appRegMap.put('SeniorOffice', 'Yes');
                appRegMap1.put('SeniorOffice', '');
            }else{
                appRegMap.put('IAmDirector', '');
                appRegMap1.put('IAmDirector', 'No');
                appRegMap.put('IAmrelative', '');
                appRegMap1.put('IAmrelative', 'No');
                appRegMap.put('relativeSeniorOffice', '');
                appRegMap1.put('relativeSeniorOffice', 'No');
                appRegMap.put('SeniorOffice', '');
                appRegMap1.put('SeniorOffice', 'No');
            }
            if(appReg.FFDirRelIntrstAsSH__c=='Yes'){
                appRegMap.put('InteresedAsShareHolder', 'Yes');
                appRegMap1.put('InteresedAsShareHolder', '');
            }else{
                appRegMap.put('InteresedAsShareHolder', '');
                appRegMap1.put('InteresedAsShareHolder', 'No');
            }
            if(appReg.FFDirRelIntrstAsPart__c=='Yes'){
                appRegMap.put('InteresedAsPather', 'Yes');
                appRegMap1.put('InteresedAsPather', '');
            }else{
                 appRegMap.put('InteresedAsPather', '');
                appRegMap1.put('InteresedAsPather', 'No');
            }
        }
        system.debug('appRegMap'+appRegMap);
        regulObj= new list<RegltryPrsonl__c>();
        if(appRegIds.size()>0){
           List<RegltryPrsonl__c> reguPersonRecs=[select id, Desgntn__c, DirName__c, Reltnshp__c, Applicant_Regulatory__c from RegltryPrsonl__c where Applicant_Regulatory__c IN: appRegIds];
            if(reguPersonRecs.size()>0){
                for(RegltryPrsonl__c perReg: reguPersonRecs){
                    RegltryPrsonl__c forVfObj=new RegltryPrsonl__c();
                    forVfObj.Desgntn__c=perReg.Desgntn__c == '' || perReg.Desgntn__c == null ? '' : perReg.Desgntn__c;
                    forVfObj.DirName__c=perReg.DirName__c == '' || perReg.DirName__c == null ? '' : perReg.DirName__c;
                    forVfObj.Reltnshp__c=perReg.Reltnshp__c == '' || perReg.Reltnshp__c == null ? '' : perReg.Reltnshp__c;
                    regulObj.add(forVfObj);
                }
            }
        }
        List<Id> coAppIds=new List<Id>();
        RemAllAppWrapperList=new List<ApplicantWrapper>();
        twoAppWrapperList= new List<ApplicantWrapper>();  
        Map<Id, Applicant__c> mapOfIdWithCoApp=new Map<Id, Applicant__c>();
        Map<Id, ApplicantEmployment__c> mapOfIdWithEmp=new Map<Id, ApplicantEmployment__c>();
        Map<Id, list<ApplAddr__c>> mapOfIdWithAdd=new Map<Id, list<ApplAddr__c>>();
        Map<Id, Applicant_Income__c> mapOfIdWithInc=new Map<Id, Applicant_Income__c>();
        Map<Id, BRE__c> mapOfIdWithBre=new Map<Id, BRE__c>();
        Map<string, List<string>> mapOfAppIdWithPhoto = new Map<string, List<string>>();
        if(coAplicantRecs.size()>0){
            for(Applicant__c coId: coAplicantRecs){
                allAppliIds.add(coId.Id);
                mapOfIdWithCoApp.put(coId.Id, coId);
                coAppIds.add(coId.Id);
            }
            mapOfAppIdWithPhoto= getCoApplicantPhotos(coAppIds);
            
            List<BRE__c> CoBreRec=[select id, Mnthlyapprincome__c,Applicant__c from BRE__c where Applicant__c IN: coAppIds and IsLatest__c=:true ];
            List<Applicant_Income__c> coAppliIncRecList=[select NET_CASH_PROFIT_LOSS__c, IncomeType__c from Applicant_Income__c where Applicant__c IN: coAppIds and (IncomeType__c =:'Cash Salary' or IncomeType__c =:'Bank Credit Salarys') ];
            if(CoBreRec.size()> 0){
                for(BRE__c br : CoBreRec){
                    mapOfIdWithBre.put(br.Applicant__c, br);
                }
             }
            if(coAppliIncRecList.size()> 0){
               for(Applicant_Income__c appInc : coAppliIncRecList){
                    mapOfIdWithInc.put(appInc.Applicant__c, appInc);
                } 
            }
            List<ApplicantEmployment__c> CoappliEmployRec=[select CurrentBusinessVintage_Months__c, CurrentBusinessVintage_Years__c, EntityName__c, tolabel(NatureOfBusinessIndividual__c), tolabel(NatureOfBusinessCorporate__c),id,LoanApplicant__c,UdyamRegistrationNumber__c,tolabel(TypeOfOrganisation__c),TotalWorkExperience_Years__c,TotalWorkExperience_Months__c,DesignationValues__c,DesignationText__c,RetirementAge__c,OfficialEmail__c,WorkingWithCurrentEmployer_Months__c,WorkingWithCurrentEmployer_Years__c, EmployerName__r.Name from ApplicantEmployment__c where LoanApplicant__c IN: coAppIds];
            if(CoappliEmployRec.size()>0){
                for(ApplicantEmployment__c appEmp: CoappliEmployRec){
                    mapOfIdWithEmp.put(appEmp.LoanApplicant__c, appEmp);
                }
            }
            list<ApplAddr__c> CoappliAdds=[select id,Applicant__c,AddrTyp__c,isPerSameAsResi_ADD__c, Sm_as_Per_Adr__c,AddrLine2__c,AddrLine1__c,City__c,Locality__c,Country__c,FullAdrs__c,HouseNo__c,MailAddr__c,Landmark__c,ToLabel(OwnType__c),State__c,Pincode__c from ApplAddr__c where Applicant__c IN: coAppIds AND AddrTyp__c IN: addTypeList];
            if(CoappliAdds.size()>0){
                for(ApplAddr__c appAdd: CoappliAdds){
                    if (!mapOfIdWithAdd.containsKey(appAdd.Applicant__c)) {
                        mapOfIdWithAdd.put(appAdd.Applicant__c, new List<ApplAddr__c>());
                    }
                    mapOfIdWithAdd.get(appAdd.Applicant__c).add(appAdd);
                }
            }
        }
        List<Applicant_Income__c> coappliIncRecList=[select NET_CASH_PROFIT_LOSS__c, IncomeType__c from Applicant_Income__c where Applicant__c IN: coAppIds ];
        
        Integer cNumber=0;
        Integer gNumber=0;

        if(coAppIds.size()>0){
            map<string, string> mapofIdMem=toGetCOAppPDData(recordId, coAppIds);
            
            for (Integer i = 0; i < coAppIds.size(); i++){
                ApplicantWrapper coRecForVf=new ApplicantWrapper();
                Applicant__c appRec=mapOfIdWithCoApp.get(coAppIds[i]);
                coRecForVf.AppdetailNumber=i+2;
                coRecForVf.applicantNumber=i+1;
                if(appRec.ApplType__c == 'C'){
                    cNumber++;
                    coRecForVf.coApplicantNumber = cNumber;
                    coRecForVf.appType='C';
                }
                if(appRec.ApplType__c == 'G'){
                    gNumber++;
                    coRecForVf.guarantorNumber = gNumber;
                    coRecForVf.appType='G';
                }
                coRecForVf.numberOfDep=mapofIdMem.get(coAppIds[i]);
                coRecForVf.custProfile = appRec.CustProfile__c;
                string profileCoType=appRec.CustProfile__c;
                string typeOfCoApp=appRec.Constitution__c;
                string typeOfBorrower=appRec.Type_of_Borrower__c;
                if(typeOfCoApp=='INDIVIDUAL'){
                    if (mapOfAppIdWithPhoto.containsKey(coAppIds[i])) {
                        coRecForVf.photoUrl = mapOfAppIdWithPhoto.get(coAppIds[i])[1];
                        coRecForVf.photoType  = mapOfAppIdWithPhoto.get(coAppIds[i])[0];
                    } else {
                        coRecForVf.photoUrl  = null;
                        coRecForVf.photoType  = null;
                    }
                    coRecForVf.title = appRec.Title__c;
                    coRecForVf.mName = appRec.MName__c;
                    coRecForVf.lName = appRec.LName__c;
                    coRecForVf.fName = appRec.FName__c;
                    if(appRec.MariStatus__c =='SINGLE'){
                        coRecForVf.spName = appRec.Father_Name__c;
                    }else{
                        coRecForVf.spName = appRec.SpName__c;
                    }
                    
                    coRecForVf.mthrMdnName = appRec.MthrMdnName__c;
                    if(appRec.DOB__c !=null){
                    datetime mydatetime=appRec.DOB__c;
                    string formattedDate1=mydatetime.format('dd-MMM-yyyy');
                    coRecForVf.dob = formattedDate1;
                	}
                    coRecForVf.mariStatus = appRec.MariStatus__c;
                	coRecForVf.gender = appRec.Gender__c;
                    coRecForVf.category = appRec.Category__c;
                    coRecForVf.eduQual = appRec.EduQual__c;
                    if(appRec.AadhaarNo__c !='' && appRec.AadhaarNo__c !=null){
                        coRecForVf.UIDNo = formatAadhaar(appRec.AadhaarNo__c);
                    }else{
                       if(appRec.ID_proof_type__c !='' && appRec.ID_Number__c !=''){
                            coRecForVf.UIDNo = appRec.ID_proof_type__c+'-'+maskId(appRec.ID_Number__c);
                        }                     
                    }
                    coRecForVf.Religion = appRec.Religion__c;
                }else{
                    coRecForVf.fName = appRec.CompanyName__c;
                    if(appRec.DOI__c !=null){
                    datetime mydatetime=appRec.DOI__c;
                    string formattedDate1=mydatetime.format('dd-MMM-yyyy');
                    coRecForVf.dob = formattedDate1;
                	}
                    
                }
               coRecForVf.residentialStatus = appRec.Residential_Status__c;
                coRecForVf.MobileNumber = appRec.MobNumber__c;
           		 coRecForVf.phoneNo = appRec.PhoneNumber__c;
                coRecForVf.emailId = appRec.EmailId__c;
                coRecForVf.avgMonthlyGrossSalary = appRec.Average_Monthly_Gross_Salary__c;
                coRecForVf.pan = appRec.PAN__c;
                coRecForVf.ckycNumber = appRec.CKYC_Number__c;
                coRecForVf.Nationality = appRec.Nationality__c;
                
                if(mapOfIdWithEmp.containsKey(coAppIds[i])){
                    ApplicantEmployment__c appEmpRec=mapOfIdWithEmp.get(coAppIds[i]);
                    if(typeOfCoApp=='INDIVIDUAL'){
                        coRecForVf.typeOfOrganisation = typeOfBorrower=='Financial' ? appEmpRec.NatureOfBusinessIndividual__c : '';
                        //coRecForVf.typeofBuss = appEmpRec.TypeOfOrganisation__c;
                        Decimal year=appEmpRec.TotalWorkExperience_Years__c ==null ? 0: appEmpRec.TotalWorkExperience_Years__c;
                        Decimal Months=appEmpRec.TotalWorkExperience_Months__c ==null ? 0: appEmpRec.TotalWorkExperience_Months__c;
                        coRecForVf.totalWorkExperienceYears =typeOfBorrower=='Financial' ? String.valueOf(year) +' Years - '+String.valueOf(Months) +' Months' : null;
                        coRecForVf.designationText = typeOfBorrower=='Financial' ? appEmpRec.DesignationText__c :'';
                       /* if(appEmpRec.DesignationValues__c != ''){
                            coRecForVf.designationText = appEmpRec.DesignationValues__c;
                        }else{
                            coRecForVf.designationText = appEmpRec.DesignationText__c;
                        }*/
                        coRecForVf.retirementAge = typeOfBorrower=='Financial' ? appEmpRec.RetirementAge__c : null;
                    }else{
                        coRecForVf.typeOfOrganisation =typeOfBorrower=='Financial' ? appEmpRec.NatureOfBusinessCorporate__c : null;
                   }
                 if(profileCoType == 'SALARIED' && typeOfCoApp =='INDIVIDUAL'){
                   coRecForVf.companyName =typeOfBorrower=='Financial' ? appEmpRec.EmployerName__r.name : null;
                     coRecForVf.typeofBuss =typeOfBorrower=='Financial' ? appEmpRec.TypeOfOrganisation__c :null;
                     Decimal year1=appEmpRec.WorkingWithCurrentEmployer_Years__c ==null ? 0: appEmpRec.WorkingWithCurrentEmployer_Years__c;
                     Decimal Months1=appEmpRec.WorkingWithCurrentEmployer_Months__c ==null ? 0: appEmpRec.WorkingWithCurrentEmployer_Months__c;
                     coRecForVf.workingWithCurrentEmployerYears =typeOfBorrower=='Financial' ? String.valueOf(year1) +'Years - '+String.valueOf(Months1) +' Months' : null;
                }else if((profileCoType == 'SELF EMPLOYED PROFESSIONAL' || profileCoType == 'SELF EMPLOYED NON PROFESSIONAL') && typeOfCoApp =='INDIVIDUAL'){
                    coRecForVf.companyName = appEmpRec.EntityName__c;
                    coRecForVf.typeofBuss = appEmpRec.TypeOfOrganisation__c;
                    Decimal year1=appEmpRec.CurrentBusinessVintage_Years__c ==null ? 0: appEmpRec.CurrentBusinessVintage_Years__c;
                    Decimal Months1=appEmpRec.CurrentBusinessVintage_Months__c ==null ? 0: appEmpRec.CurrentBusinessVintage_Months__c;
                    coRecForVf.workingWithCurrentEmployerYears = String.valueOf(year1) +'Years - '+String.valueOf(Months1) +' Months';
                }else if((profileCoType == 'SELF EMPLOYED PROFESSIONAL' || profileCoType == 'SELF EMPLOYED NON PROFESSIONAL') && typeOfCoApp !='INDIVIDUAL'){
                    coRecForVf.companyName = typeOfBorrower=='Financial' ? appRec.CompanyName__c : null;
                     coRecForVf.typeofBuss =typeOfBorrower=='Financial' ? appRec.Constitution__c : null;
                    coRecForVf.workingWithCurrentEmployerYears = typeOfBorrower=='Financial' ? String.valueOf(appRec.InceptionYears__c) : null;
                }else{
                    coRecForVf.companyName = '';
                    coRecForVf.typeofBuss = '';
                    coRecForVf.workingWithCurrentEmployerYears='';
                }
                    if(profileCoType == 'SALARIED'){
                        if(mapOfIdWithInc.containsKey(coAppIds[i])){
                            Applicant_Income__c appIncRec=mapOfIdWithInc.get(coAppIds[i]);
                            if(applicantRec.Average_Monthly_Gross_Salary__c !=null &&  appIncRec.IncomeType__c=='Bank Credit Salary'){
                                applicantWrapper.avgMonthlyGrossSalary = typeOfBorrower=='Financial' ? appRec.Average_Monthly_Gross_Salary__c : null;
                            }else if(applicantRec.Average_Monthly_Cash_Salary__c !=null && appIncRec.IncomeType__c=='Cash Salary'){
                                applicantWrapper.avgMonthlyGrossSalary = typeOfBorrower=='Financial' ? appRec.Average_Monthly_Gross_Salary__c :null;
                            }
                        }  
                    }else if(profileCoType == 'SELF EMPLOYED PROFESSIONAL' || profileCoType == 'SELF EMPLOYED NON PROFESSIONAL'){
                        if(appRec.AssessmentProgram__c=='Assessed Income Program'){
                            
                        }else if(appRec.AssessmentProgram__c=='Regular Income Program'){
                            if(mapOfIdWithBre.containsKey(coAppIds[i])){
                            	BRE__c appBreRec=mapOfIdWithBre.get(coAppIds[i]);
                                applicantWrapper.avgMonthlyGrossSalary = typeOfBorrower=='Financial' ? appBreRec.Mnthlyapprincome__c: null;
                            }
                        }
                    }
                    coRecForVf.udyamRegistrationNumber = typeOfBorrower=='Financial' ? appEmpRec.UdyamRegistrationNumber__c :null;
                    
                    coRecForVf.officialEmail = typeOfBorrower=='Financial' ? appEmpRec.OfficialEmail__c :null;
                }
                if(mapOfIdWithAdd.containsKey(coAppIds[i])){
                    list<ApplAddr__c> coappliAddList=mapOfIdWithAdd.get(coAppIds[i]);
                    list<ApplAddr__c> coresidAddress= new list<ApplAddr__c>();
                    list<ApplAddr__c> coOfficeAddress= new list<ApplAddr__c>();
                    list<ApplAddr__c> coCurrentAddress= new list<ApplAddr__c>();
                    for(ApplAddr__c appAdd: coappliAddList){
                        if(appAdd.MailAddr__c==true && typeOfBorrower=='Financial'){
                            coRecForVf.comunicationAddress=appAdd.HouseNo__c+' '+appAdd.AddrLine1__c + ' ' + appAdd.AddrLine2__c +' '+ appAdd.City__c + ' '+appAdd.Pincode__c;
                        }
                        if(appAdd.AddrTyp__c =='Residence Address' && typeOfBorrower=='Financial'){
                            //coresidAddress.add(appAdd);
                            coCurrentAddress.add(appAdd);
                        }else if(appAdd.AddrTyp__c =='Office Address'){
                            if(typeOfBorrower=='Financial'){
                                coOfficeAddress.add(appAdd);
                            }
                            
                        }
                        else if(appAdd.AddrTyp__c =='Principal place for business'){
                            if(typeOfBorrower=='Financial'){
                                coOfficeAddress.add(appAdd);
                            }
                           // coOfficeAddress.add(appAdd);
                        }
                        else if(appAdd.AddrTyp__c =='Registered place for business'){
                            if(coOfficeAddress.size() ==0 && typeOfBorrower=='Financial'){
                                coOfficeAddress.add(appAdd);
                            }
                            
                        }
                        
                        
                        else if(appAdd.AddrTyp__c=='Residence Cum office'){
                            // if(coresidAddress.size()==0){
                            //     coresidAddress.add(appAdd);
                            // }
                            if(coCurrentAddress.size()==0 && typeOfBorrower=='Financial'){
                                coCurrentAddress.add(appAdd);
                            }
                            if(officeAddress.size()==0 && typeOfBorrower=='Financial'){
                                coOfficeAddress.add(appAdd);
                            }
                        }else if(appAdd.AddrTyp__c =='Permanent Address'){
                            if(appAdd.Sm_as_Per_Adr__c==true){
                                coCurrentAddress.add(appAdd);             
                            }
                            if(appAdd.isPerSameAsResi_ADD__c && coresidAddress.size()==0){
                                coresidAddress.add(appAdd);
                            }
                        }
                    }
                    if(coresidAddress.size() > 0) {
                        ApplAddr__c resAddr = coresidAddress[0];
                        coRecForVf.ResiAddress =resAddr.HouseNo__c+' ' +resAddr.AddrLine1__c + ' ' + resAddr.AddrLine2__c;
                        coRecForVf.ResiLandmark = resAddr.Landmark__c;
                        coRecForVf.ResiCity = resAddr.City__c;
                        coRecForVf.ResiPin = resAddr.Pincode__c;
                        coRecForVf.ResidanceType = resAddr.OwnType__c;
                        /*if(resAddr.OwnType__c=='O'){
                            coRecForVf.rentedOwned = 'Owned';
                        }else if(resAddr.OwnType__c=='R'){
                            coRecForVf.rentedOwned = 'Rented';
                        }*/
                    }
                    if(coOfficeAddress.size() > 0 && typeOfBorrower=='Financial') {
                        ApplAddr__c offAddr = coOfficeAddress[0];
                        coRecForVf.officeAddress = offAddr.HouseNo__c+' ' +offAddr.AddrLine1__c + ' ' + offAddr.AddrLine2__c;
                        coRecForVf.officeLandmark = offAddr.Landmark__c;
                        coRecForVf.officeCity = offAddr.City__c;
                        coRecForVf.officePin = offAddr.Pincode__c;
                        coRecForVf.ResidanceType = offAddr.OwnType__c;
                        /*if(offAddr.OwnType__c=='O'){
                            coRecForVf.rentedOwned = 'Owned';
                        }else if(offAddr.OwnType__c=='R'){
                            coRecForVf.rentedOwned = 'Rented';
                        }*/
                    }
                    if(coCurrentAddress.size() > 0) {
                        ApplAddr__c curAddr = coCurrentAddress[0];
                        coRecForVf.CurreAddress = curAddr.HouseNo__c+' '+curAddr.AddrLine1__c + ' ' + curAddr.AddrLine2__c;
                        coRecForVf.CurreLandmark = curAddr.Landmark__c;
                        coRecForVf.CurreCity = curAddr.City__c;
                        coRecForVf.CurrePin = curAddr.Pincode__c;
                        coRecForVf.ResidanceType = curAddr.OwnType__c;
                        /*if(curAddr.OwnType__c=='O'){
                            coRecForVf.rentedOwned = 'Owned';
                        }else if(curAddr.OwnType__c=='R'){
                            coRecForVf.rentedOwned = 'Rented';
                        }*/
                    }
                }
                if (i < 2) {
                    twoAppWrapperList.add(coRecForVf);
                } else {
                    RemAllAppWrapperList.add(coRecForVf);
                }                
            }
        }
        if(RemAllAppWrapperList.size()>0){
            showBottomSpace=true;
        }else{
            showBottomSpace=false;
        }
        
        List<BureauRespDtl__c> obliData=[select id, LoanApplication__c,EMI__c, Applicant__c, Treatment__c from BureauRespDtl__c where LoanApplication__c =: recordId AND Treatment__c=: 'To continue - Obligate'];
        decimal EMIMonExp=0;
        for(BureauRespDtl__c obl: obliData){
            system.debug('obl.EMI__c'+obl.EMI__c);
            EMIMonExp =EMIMonExp + obl.EMI__c;
        }
        monthlyExpense=EMIMonExp;
        getStaticData();
        
        toGetAllData(recordId);
        toGetDescCharges();
    }
    public static String formatAadhaar(String aadhaarNumber) {
        if (aadhaarNumber.length() == 12) {
            String lastFourDigits = String.valueOf(aadhaarNumber.substring(8));
            return 'XXXXXXXX' + lastFourDigits;
        } else {
            system.debug('adhar number is blank');
            return '';
        }
    }
    public static String maskId(String idNumber) {
        if (idNumber == null || idNumber.length() < 4) {
            return 'Invalid ID'; // Handle cases where ID is null or too short
        }
		Integer idLength = idNumber.length();
		String last4Digits = idNumber.substring(idLength - 4);
		String maskedPart = 'X'.repeat(idLength - 4);
		return maskedPart + last4Digits;
    }
    public void  getStaticData(){
        try {
            // Fetch the static resource content
            StaticResource myHtmlResource = [SELECT Body FROM StaticResource WHERE Name = 'ApplicationFormDeclaration'];
            Blob htmlBlob = myHtmlResource.Body;
            StaticContent = htmlBlob.toString();
            StaticResource myHtmlResource1 = [SELECT Body FROM StaticResource WHERE Name = 'FedFinaFormText'];
            Blob htmlBlob1 = myHtmlResource1.Body;
            StaticContentForText = htmlBlob1.toString();
            StaticResource myHtmlResource2 = [SELECT Body FROM StaticResource WHERE Name = 'TextForDocument1'];
            Blob htmlBlob2 = myHtmlResource2.Body;
            StaticContentForText1 = htmlBlob2.toString();
            StaticResource myHtmlResource3 = [SELECT Body FROM StaticResource WHERE Name = 'TextForDocument2'];
            Blob htmlBlob3 = myHtmlResource3.Body;
            StaticContentForText2 = htmlBlob3.toString();
            system.debug('static Content'+ StaticContent );
        } catch (Exception e) {
            System.debug('Error fetching HTML content: ' + e.getMessage());
        }
    } 
    public static string toGetPDData(string loanRecId, Applicant__c appliRec){
        List<string> pdIds=new List<string>();
        string totalFamilyMem1='';
        List<PD__c> pdList=[select id, Appl__c, LoanAppl__c, IsCompleted__c, ExpiryDate__c, CreatedDate from PD__c where LoanAppl__c =: loanRecId and Appl__c =:appliRec.id and PDStatus__c !='withdrawn' and PdTyp__c='Physical PD' order by CreatedDate];
        system.debug('pdList'+pdList);
        for(PD__c pd: pdList){
            pdIds.add(pd.id);
        }
        List<PDResp__c> pdRes=[select Id,Resp__c, Cmnt__c, DocDtl__c, PDQues__c, PrsnlDisc__c, Ques__c, CreatedDate from PDResp__c where Ques__c='Total Number of Family Members @ Residence' and PrsnlDisc__c IN:pdIds  order by CreatedDate];
        for(PDResp__c pd1 : pdRes){
            if(pd1.Resp__c !='' && pd1.Resp__c !=null){
                totalFamilyMem1=pd1.Resp__c;
            }
                
        }
        system.debug('totalFamilyMem1'+totalFamilyMem1);
        return totalFamilyMem1;
        
    }
    public static map<string, string> toGetCOAppPDData(string loanRecId, List<string> coAppliRec){
        List<string> pdIds=new List<string>();
        map<string, string> mapofIdMem=new map<string, string>();
        List<PD__c> pdList=[select id, Appl__c, LoanAppl__c, IsCompleted__c, ExpiryDate__c, CreatedDate from PD__c where LoanAppl__c =: loanRecId and Appl__c IN: coAppliRec and PDStatus__c !='withdrawn' order by CreatedDate];
        for(PD__c pd: pdList){
            pdIds.add(pd.id);
        }
        system.debug('pdIds'+pdIds);
        List<PDResp__c> pdRes=[select Id,PrsnlDisc__r.Appl__c, Cmnt__c, DocDtl__c, PDQues__c, PrsnlDisc__c, Ques__c, Resp__c, CreatedDate from PDResp__c where Ques__c='Total Number of Family Members @ Residence' and PrsnlDisc__c IN:pdIds  order by CreatedDate];
        for (PDResp__c pd1 : pdRes) {
            system.debug('pd1.Resp__c'+pd1.Resp__c);
            if (!String.isBlank(pd1.Resp__c)) {
                String applId = pd1.PrsnlDisc__r.Appl__c;
                if (mapofIdMem.containsKey(applId) && String.isBlank(mapofIdMem.get(applId))) {
                    mapofIdMem.put(applId, pd1.Resp__c);
                } else {
                    mapofIdMem.put(applId, pd1.Resp__c);
                }
            }
        }
        return mapofIdMem;
     }
    public void toGetAllData(string recordId){
        try {
            
            list<btloan__c> btFinancierlist = [select id, BTFinancier__c, SpecifyOtherBTFinancier__c, BTLoanOutstandingValue__c from BTLoan__c where LoanAppl__c =:recordId];
            set<string> btFinancierSet = new set<string>();
            Decimal OutStanVal1=0;
            if (btFinancierlist.size()>0) {
                for (btloan__c bt: btFinancierlist) {
                    if (bt.BTFinancier__c == 'other' && bt.SpecifyOtherBTFinancier__c != null) {
                        btFinancierSet.add(bt.SpecifyOtherBTFinancier__c);
                    }else {
                        btFinancierSet.add(bt.BTFinancier__c);
                    }
                    OutStanVal1=+ bt.BTLoanOutstandingValue__c != null ? bt.BTLoanOutstandingValue__c: 0;
                    OutStanVal=OutStanVal1;
                }
                BTFinancier = string.join(btFinancierSet, ', ');
            }else{
                OutStanVal=OutStanVal1;
                BTFinancier='NA';
            }
        } catch (Exception e) {
            System.debug('Error fetching HTML content: ' + e.getMessage());
        }
    }
    public void toGetDescCharges(){
        List<MasterData__c> masRecForCharges = [
            SELECT
                Id,
                DescriptionOfChargeAsPerFedfinaKFS__c,
                ValuesOfChargeKFS__c,
                Product__c
            FROM MasterData__c
            WHERE
                Product__c = :loanApplRec.Product__c
                AND Type__c = 'KFS Contingent Charges' order by Sequence__c
        ];
        system.debug('masRecForCharges' + masRecForCharges);
        Integer sequence = 2;
        ChargeWrapperList = new List<ChargeWrapper>();
        for (MasterData__c record : masRecForCharges) {
            ChargeWrapper charRec = new ChargeWrapper();
            charRec.Index = sequence;
            charRec.valueOfCharge = record.ValuesOfChargeKFS__c;
            charRec.DecsOfCharge = record.DescriptionOfChargeAsPerFedfinaKFS__c;
            ChargeWrapperList.add(charRec);
            sequence++;
        }
    }
    public List<string> getApplicantPhotos(Set<Id> applicantIds) {
        List<DocDtl__c> docs = [SELECT Id, Appl__c, (SELECT ContentDocumentId  FROM ContentDocumentLinks ORDER BY ContentDocument.CreatedDate DESC LIMIT 1)
                                FROM DocDtl__c
                                WHERE Appl__c IN :applicantIds AND DocTyp__c = 'Photograph' AND IsLatest__c =true];
        system.debug('docs>>>>>>>>>>>'+docs.size());
		String photoUrl='';
        String domainUrl = URL.getOrgDomainUrl().toExternalForm();
        List<string> newlist=new List<string>();
        for (DocDtl__c doc : docs) {
            if (!doc.ContentDocumentLinks.isEmpty()) {
                Id contentDocId = doc.ContentDocumentLinks[0].ContentDocumentId;
                ContentDocument contentDoc = [SELECT Id, FileType FROM ContentDocument WHERE Id = :contentDocId LIMIT 1];
                photoUrl = domainUrl+'/sfc/servlet.shepherd/document/download/' + contentDocId;
                newlist.add(contentDoc.FileType);
                newlist.add(photoUrl);
               // photoUrl = 'https://fedbank--dev.sandbox.lightning.force.com/sfc/servlet.shepherd/version/download/069C4000003dfKwIAI';
			}
        }
        system.debug('photoUrl>>>>>>>>>>>'+newlist);
        return newlist;
    }
    public Map<string, List<string>> getCoApplicantPhotos(List<Id> applicantIds) {
        Map<string, List<string>> mapOfAppIdWithPhoto=new Map<string, List<string>>();
        List<DocDtl__c> docs = [SELECT Id, Appl__c, (SELECT ContentDocumentId  FROM ContentDocumentLinks ORDER BY ContentDocument.CreatedDate DESC LIMIT 1)
                                FROM DocDtl__c
                                WHERE Appl__c IN :applicantIds AND DocTyp__c = 'Photograph' AND IsLatest__c =true];
        system.debug('docs>>>>>>>>>>>'+docs.size());
		//String photoUrl='';
        String domainUrl = URL.getOrgDomainUrl().toExternalForm();
        for (DocDtl__c doc : docs) {
            if (!doc.ContentDocumentLinks.isEmpty()) {
                List<string> newList=new List<string>();
                Id contentDocId = doc.ContentDocumentLinks[0].ContentDocumentId;
                ContentDocument contentDoc = [SELECT Id, FileType FROM ContentDocument WHERE Id = :contentDocId LIMIT 1];
                String photoUrl = domainUrl+'/sfc/servlet.shepherd/document/download/' + contentDocId;
                newList.add(contentDoc.FileType);
                newList.add(photoUrl);
                mapOfAppIdWithPhoto.put(doc.Appl__c, newList);
               // photoUrl = 'https://fedbank--dev.sandbox.lightning.force.com/sfc/servlet.shepherd/version/download/069C4000003dfKwIAI';
			}
        }
        system.debug('Map<string, string>>>>>>>>>>>>'+mapOfAppIdWithPhoto);
        return mapOfAppIdWithPhoto;
    }
    class ChargeWrapper {
        public Integer Index { get; set; }
        public String valueOfCharge { get; set; }
        public String DecsOfCharge { get; set; }
    }
    class ApplicantWrapper {
    // Applicant__c fields
    public String photoUrl { get; set; }
    public String photoType { get; set; }
    public String numberOfDep { get; set; }
    public String custProfile { get; set; }
    public String companyName { get; set; }
    public String phoneNo { get; set; }
    public String MobileNumber { get; set; }
    public String title { get; set; }
    public String mName { get; set; }
    public String lName { get; set; }
    public String fName { get; set; }
    public String fullName { get; set; }   
    public String spName { get; set; }
    public String fatherName { get; set; }
    public String mthrMdnName { get; set; }
    public string dob { get; set; }
    public Date doi { get; set; }
    public String mariStatus { get; set; }
    public String gender { get; set; }
    public String residentialStatus { get; set; }
    public String category { get; set; }
    public String eduQual { get; set; }
    public String UIDNo { get; set; }
    public String emailId { get; set; }
    public Decimal avgMonthlyGrossSalary { get; set; }
    public String pan { get; set; }
    public String ckycNumber { get; set; }
    public String Religion { get; set; }
    public String Nationality { get; set; }
    public String comunicationAddress { get; set; }
     public String typeofBuss { get; set; }

    // ApplicantEmployment__c fields
    public String udyamRegistrationNumber { get; set; }
    public String typeOfOrganisation { get; set; }
    public string totalWorkExperienceYears { get; set; }
    public Decimal totalWorkExperienceMonths { get; set; }
    public String designationValues { get; set; }
    public String designationText { get; set; }
    public Decimal retirementAge { get; set; }
    public String officialEmail { get; set; }
    public Decimal workingWithCurrentEmployerMonths { get; set; }
    public string workingWithCurrentEmployerYears { get; set; }
    public String officeAddress { get; set; }
    public String officeLandmark { get; set; }
    public String officeCity { get; set; }
    public String officePin { get; set; }
    public String rentedOwned { get; set; }
    public String ResidanceType { get; set; }
    public String officeTelStdCode { get; set; }
    public String officeMobile { get; set; }
    public String officeEmail { get; set; }
    public String ResiAddress { get; set; }
    public String ResiLandmark { get; set; }
    public String ResiCity { get; set; }
    public String ResiPin { get; set; }
    public String ResiTelStdCode { get; set; }
    public String ResiMobile { get; set; }
    public String ResiEmail { get; set; }  
    public String CurreAddress { get; set; }
    public String CurreLandmark { get; set; }
    public String CurreCity { get; set; }
    public String CurrePin { get; set; }
    public String CurreTelStdCode { get; set; }
    public String CurreMobile { get; set; }
    public String CurreEmail { get; set; }  
    public Decimal applicantNumber { get; set; }  
    public Decimal AppdetailNumber { get; set; } 
    public Decimal coApplicantNumber { get; set; }   
    public Decimal guarantorNumber { get; set; }  
    public String appType { get; set; }
    }
   
    
}