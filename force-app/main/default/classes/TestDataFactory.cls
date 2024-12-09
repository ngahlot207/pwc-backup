public with sharing class TestDataFactory {
    /**
     * ********************************************************
     * This method is test data for user
     * ********************************************************
     */ public static User UserData(Boolean doInsert) {
        Profile prof = [SELECT Id FROM Profile WHERE name = 'LOS Base User'];

        User u = new user();
        u.LastName = 'Test Code';
        u.Email = 'test@test.com';
        u.Alias = 'Tcode';
        u.Username = 'test123tring@test.com';
        u.TimeZoneSidKey = 'GMT';
        u.LocaleSidKey = 'en_US';

        u.ProfileID = prof.Id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';

        if (doInsert) {
            TriggerBase.bypass('User');
            insert u;
            TriggerBase.clearBypass('User');
        }
        return u;
    }

    public static User supervisor(Boolean doInsert) {
        Profile prof = [SELECT Id FROM Profile WHERE name = 'LOS Base User'];

        User u = new user();
        u.LastName = 'Test Code';
        u.Email = 'test@test.com';
        u.Alias = 'Tcode';
        u.Username = 'test123tringtring@test.com';
        u.TimeZoneSidKey = 'GMT';
        u.LocaleSidKey = 'en_US';

        u.ProfileID = prof.Id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';

        if (doInsert) {
            TriggerBase.bypass('User');
            insert u;
            TriggerBase.clearBypass('User');
        }
        return u;
    }

    /**
     * ********************************************************
     * This method is test data for sanction condition master record
     * ********************************************************
     */

    public static Sanction_Conditions_Master__c createsanctionmaster(
        Boolean doInsert
    ) {
        Sanction_Conditions_Master__c SanctionMaster = new Sanction_Conditions_Master__c();
        SanctionMaster.OTC__c = 'OTC';
        if (doInsert) {
            TriggerBase.bypass('Sanction_Conditions_Master__c');
            insert SanctionMaster;
            TriggerBase.clearBypass('Sanction_Conditions_Master__c');
        }
        return SanctionMaster;
    }

    /**
     * ********************************************************
     * This method is test data for Lead
     * ********************************************************
     */

    public static Lead LeadData(Boolean doInsert, id ownerId) {
        Lead leadrec = new Lead();
        leadrec.Lastname = 'Test';
        leadrec.ownerId = ownerId;
        if (doInsert) {
            TriggerBase.bypass('Lead');
            insert leadrec;
            TriggerBase.clearBypass('Lead');
        }
        return leadrec;
    }
    //update existing lead
    public static Lead LeadDataupdate(Boolean doUpdate, id leadid, id owner) {
        Lead leadrec = new Lead();
        leadrec.id = leadid;
        //leadrec.Lastname='Test';
        leadrec.ownerId = owner;
        if (doUpdate) {
            TriggerBase.bypass('Lead');
            update leadrec;
            TriggerBase.clearBypass('Lead');
        }
        return leadrec;
    }
    /**
     * ********************************************************
     * This method is test data for Lead Share
     * ********************************************************
     */

    public static LeadShare LeadShareData(Boolean doInsert, id leadId) {
        LeadShare leadApp = new LeadShare();
        leadApp.Leadid = leadId;
        leadApp.RowCause = 'Manual';
        leadApp.LeadAccessLevel = 'Edit';
        User dummyUser = UserData(false);
        dummyUser.UserName =
            Math.random() +
            'testuser@testuser.com' +
            Math.random();
        insert dummyUser;
        leadApp.UserOrGroupId = dummyUser.Id;
        if (doInsert) {
            TriggerBase.bypass('LeadShare');
            insert leadApp;
            TriggerBase.clearBypass('LeadShare');
        }
        return leadApp;
    }

    /**
     * ********************************************************
     * This method is test data for Team Hierarchy
     * ********************************************************
     */
    public static TeamHierarchy__c TestDataTeamHierarchy_nonSup(
        Boolean doInsert,
        id employee,
        id bankbranch
    ) {
        // BankBrchMstr__c prof = [select id from BankBrchMstr__c where id= :BranchId];

        TeamHierarchy__c TH = new TeamHierarchy__c();
        TH.Employee__c = employee;
        TH.EmpBrch__c = bankbranch;
        TH.Emprole__c = 'RM';
        TH.Product_Type__c = 'Home Loan';
        //TH.Supervisor__c=supervisor;
        if (doInsert) {
            TriggerBase.bypass('TeamHierarchy__c');
            insert TH;
            TriggerBase.clearBypass('TeamHierarchy__c');
        }

        return TH;
    }

    public static TeamHierarchy__c TestDataTeamHierarchy_nonSup1(
        Boolean doInsert,
        id employee,
        id bankbranch,
        id team
    ) {
        // BankBrchMstr__c prof = [select id from BankBrchMstr__c where id= :BranchId];

        TeamHierarchy__c TH = new TeamHierarchy__c();
        TH.Employee__c = employee;
        TH.EmpBrch__c = bankbranch;
        TH.Emprole__c = 'SM';
        TH.Product_Type__c = 'Home Loan';
        TH.Supervisor__c = team;
        if (doInsert) {
            TriggerBase.bypass('TeamHierarchy__c');
            insert TH;
            TriggerBase.clearBypass('TeamHierarchy__c');
        }

        return TH;
    }
     public static TeamHierarchy__c TestDataTeamHierarchyBBH(
        Boolean doInsert,
        id employee,
        id bankbranch,
        id locMst
    ) {
        // BankBrchMstr__c prof = [select id from BankBrchMstr__c where id= :BranchId];

        TeamHierarchy__c TH = new TeamHierarchy__c();
        TH.Employee__c = employee;
        TH.EmpBrch__c = bankbranch;
        TH.Emprole__c = 'BBH';
        TH.IsActive__c=true;
        TH.EmpLoc__c=locMst;
        //TH.Supervisor__c = supervisor;
        if (doInsert) {
            TriggerBase.bypass('TeamHierarchy__c');
            insert TH;
            TriggerBase.clearBypass('TeamHierarchy__c');
        }

        return TH;
    }
    public static TeamHierarchy__c TestDataTeamHierarchy(
        Boolean doInsert,
        id employee,
        id bankbranch,
        id supervisor
    ) {
        // BankBrchMstr__c prof = [select id from BankBrchMstr__c where id= :BranchId];

        TeamHierarchy__c TH = new TeamHierarchy__c();
        TH.Employee__c = employee;
        TH.EmpBrch__c = bankbranch;
        TH.Emprole__c = 'ABH';
        TH.Supervisor__c = supervisor;
        if (doInsert) {
            TriggerBase.bypass('TeamHierarchy__c');
            insert TH;
            TriggerBase.clearBypass('TeamHierarchy__c');
        }

        return TH;
    }
    
     public static TeamHierarchy__c TestDataTeamHierarchy_CPA(
        Boolean doInsert,
        id employee,
        id bankbranch,
        id team
    ) {
        // BankBrchMstr__c prof = [select id from BankBrchMstr__c where id= :BranchId];

        TeamHierarchy__c TH = new TeamHierarchy__c();
        TH.Employee__c = employee;
        TH.EmpBrch__c = bankbranch;
        TH.Emprole__c = 'CPA';
        TH.Product_Type__c = 'Home Loan';
        TH.Supervisor__c = team;
        if (doInsert) {
            TriggerBase.bypass('TeamHierarchy__c');
            insert TH;
            TriggerBase.clearBypass('TeamHierarchy__c');
        }

        return TH;
    }
    
     public static TeamHierarchy__c TestDataTeamHierarchy_UW(
        Boolean doInsert,
        id employee,
        id bankbranch,
        id team
    ) {
        // BankBrchMstr__c prof = [select id from BankBrchMstr__c where id= :BranchId];

        TeamHierarchy__c TH = new TeamHierarchy__c();
        TH.Employee__c = employee;
        TH.EmpBrch__c = bankbranch;
        TH.Emprole__c = 'UW';
        TH.Product_Type__c = 'Home Loan';
        TH.Supervisor__c = team;
        if (doInsert) {
            TriggerBase.bypass('TeamHierarchy__c');
            insert TH;
            TriggerBase.clearBypass('TeamHierarchy__c');
        }

        return TH;
    }
    
    /**
     * ********************************************************
     * This method is test data for Bank Branch Master
     * ********************************************************
     */
    public static BankBrchMstr__c TestDataBankBranchMaster(Boolean doInsert) {
        // BankBrchMstr__c prof = [select id from BankBrchMstr__c where id= :BranchId];
        BankBrchMstr__c B = new BankBrchMstr__c();
        B.Name = 'Hyderabad';
        B.BrchCode__c = 'HYC';
        if (doInsert) {
            TriggerBase.bypass('BankBrchMstr__c');
            insert B;
            TriggerBase.clearBypass('BankBrchMstr__c');
        }
        return B;
    }
    
     public static BankBrchMstr__c TestDataBankBranchMaster1(Boolean doInsert) {
        // BankBrchMstr__c prof = [select id from BankBrchMstr__c where id= :BranchId];
        BankBrchMstr__c B1 = new BankBrchMstr__c();
        B1.Name = 'Mumbai';
        B1.BrchCode__c = 'MUM';
        if (doInsert) {
            TriggerBase.bypass('BankBrchMstr__c');
            insert B1;
            TriggerBase.clearBypass('BankBrchMstr__c');
        }
        return B1;
    }

    /**
     * ********************************************************
     * This method is test data for create Loan Application
     * ********************************************************
     */

    public static LoanAppl__c createLoanApplication(Boolean doInsert) {
        LoanAppl__c loanApp = new LoanAppl__c();
        //loanApp.BU__c='Vehicle Loan';
        loanApp.Stage__c = 'QDE';
        loanApp.BrchCode__c = 'HYC';
        loanApp.Product__c = 'Home Loan';
        loanApp.Loan_Tenure_Months__c = 120;
        loanApp.ReqLoanAmt__c=1000000;
        //loanApp.LoginAcceptDate__c = Date.newInstance(2024, 01, 09);
        // loanApp.OwnerName__c = u.Id;
        if (doInsert) {
            TriggerBase.bypass('LoanAppl__c');
            insert loanApp;
            TriggerBase.clearBypass('LoanAppl__c');
        }
        return loanApp;
    }
    
     /**
     * ********************************************************
     * This method is test data for create Disbursement
     * ********************************************************
     */

  public static Disbursement__c createDisbursement(Boolean doInsert, double disburseNo, Id loanAppId) {
        Disbursement__c disbursement = new Disbursement__c();
        disbursement.Disbur_No__c = disburseNo;
      	disbursement.Loan_Appli__c = loanAppId;
        if (doInsert) {
            TriggerBase.bypass('Disbursement__c');
            insert disbursement;
            TriggerBase.clearBypass('Disbursement__c');
        }
        return disbursement;
    }
    
    
    /**
     * ********************************************************
     * This method has test data to create Applicant Employment
     * ********************************************************
     */

    public static ApplicantEmployment__c createApplEmployment(
        Boolean doInsert,
        Id loanAppId
    ) {
        ApplicantEmployment__c applEmp = new ApplicantEmployment__c();
        applEmp.LoanApplicant__c = loanAppId;
        // applEmp.Id='';
        applEmp.Name = 'test';
        //applEmp.IndustryForRBIReporting__c='';
        // applEmp.IndustryType__c='';
        if (doInsert) {
            TriggerBase.bypass('ApplicantEmployment__c');
            insert applEmp;
            TriggerBase.clearBypass('ApplicantEmployment__c');
        }
        return applEmp;
    }
    
    
     public static ApplicantEmployment__c createApplEmplt(
        Boolean doInsert,
        Id applicantId
    ) {
        ApplicantEmployment__c applEmp = new ApplicantEmployment__c();
        applEmp.LoanApplicant__c = applicantId;
        applEmp.DesignationValues__c='PROPRIETOR';
        applEmp.Name = 'test';
       
        if (doInsert) {
            TriggerBase.bypass('ApplicantEmployment__c');
            insert applEmp;
            TriggerBase.clearBypass('ApplicantEmployment__c');
        }
        return applEmp;
    }
    
         public static ApplicantEmployment__c createApplEmplt1(
        Boolean doInsert,
        Id applicantId
    ) {
        ApplicantEmployment__c applEmp = new ApplicantEmployment__c();
        applEmp.LoanApplicant__c = applicantId;
        applEmp.DesignationValues__c='KARTA';
        applEmp.Name = 'test';
       
        if (doInsert) {
            TriggerBase.bypass('ApplicantEmployment__c');
            insert applEmp;
            TriggerBase.clearBypass('ApplicantEmployment__c');
        }
        return applEmp;
    }
    /**
     * ********************************************************
     * This method is test data for create Loan Application
     * ********************************************************
     */

    public static LoanAppl__c createLoanApplicationWithOwnerId(
        Boolean doInsert,
        String ownerId
    ) {
        LoanAppl__c loanApp = new LoanAppl__c();
        //loanApp.BU__c='Vehicle Loan';
        loanApp.Stage__c = 'QDE';
        loanApp.BrchCode__c = 'HYC';
        loanApp.Product__c = 'Home Loan';
        loanApp.OwnerId = ownerId;
        // loanApp.OwnerName__c = u.Id;
        if (doInsert) {
            TriggerBase.bypass('LoanAppl__c');
            insert loanApp;
            TriggerBase.clearBypass('LoanAppl__c');
        }
        return loanApp;
    }
    /**
     * ********************************************************
     * This method is test data for create Applicant
     * ********************************************************
     */

    public static Applicant__c createSingleApplicant(
        Boolean doInsert,
        Id loanAppId
    ) {
        Applicant__c appli = new Applicant__c();

        appli.FName__c = 'test';
        appli.MobNumber__c = '9876567899';
        appli.LName__c = 'method';
        appli.ApplType__c = 'P';
        appli.Investment_in_Plant_and_Machinery__c = 100000000;
        appli.Annual_Turnover__c = 1000000;
        appli.Constitution__c = 'INDIVIDUAL';
        appli.CustProfile__c = 'SELF EMPLOYED NON PROFESSIONAL';
        appli.Type_of_Borrower__c = 'Financial';
        appli.EmailId__c='abcd@gmail.com';
        appli.Average_Monthly_Rental_No_Bank_Credit__c = 10000;
        appli.Average_Monthly_Rental_With_Bank_Credit__c = 10000;
        appli.Average_Other_Income__c = 10000;
        appli.AssessmentProgram__c = 'Regular Income Program';
        appli.Average_Monthly_Cash_Salary__c = 10000;
        appli.Average_Monthly_Pension__c = 2000;
        appli.Average_Net_Salary__c = 50000;
        appli.AverageMonthlyAgricultureIncome__c = 10000;
        appli.Average_Monthly_Gross_Salary__c = 60000;
        appli.Age__c = 25;
        // appli.MSME__c='No';
        // appli.MSME_Type__c='Applicable';
        //appli.DriversLicense__c = 'ENTP876567GH';
        //appli.AadharEncripted__c = '987899878987';
        //appli.File_No__c = '97678987789';
        //appli.VoterID__c = 'EVUG8765G';
        //appli.Pan_No__c = 'ENTFP1779H';
        appli.AdhrLst4Dgts__c = 5464;
        appli.dob__c = Date.newInstance(1987, 2, 23);
        appli.LoanAppln__c = loanAppId;
        appli.TotalIncome__c = 3456;
        appli.Gender__c = 'M';
        appli.CompanyName__c = 'ABC';
        appli.MName__c = 'test';
        appli.Relationship__c = 'Self';
        appli.UCID__c = '13006102';

        //  appli.AddrTyp__c='Permanent Address';
         
        //addition of code
        Applicant__c coApp = new Applicant__c();

        coApp.FName__c = 'CoApplicant';
        coApp.MobNumber__c = '9876567899';
        coApp.LName__c = 'method';
        coApp.ApplType__c = 'C';
        coApp.Investment_in_Plant_and_Machinery__c = 100000000;
        coApp.Annual_Turnover__c = 2000000;
        coApp.Constitution__c = 'INDIVIDUAL';
        coApp.CustProfile__c = 'SELF EMPLOYED NON PROFESSIONAL';
        coApp.Type_of_Borrower__c = 'Financial';
        coApp.EmailId__c='abcd@gmail.com';
        coApp.Average_Monthly_Rental_No_Bank_Credit__c = 10000;
        coApp.Average_Monthly_Rental_With_Bank_Credit__c = 10000;
        coApp.Average_Other_Income__c = 10000;
        coApp.AssessmentProgram__c = 'Regular Income Program';
        coApp.Average_Monthly_Cash_Salary__c = 10000;
        coApp.Average_Monthly_Pension__c = 2000;
        coApp.Average_Net_Salary__c = 50000;
        coApp.AverageMonthlyAgricultureIncome__c = 10000;
        coApp.Average_Monthly_Gross_Salary__c = 60000;
        coApp.Age__c = 25;
        coApp.AdhrLst4Dgts__c = 5464;
        coApp.dob__c = Date.newInstance(1987, 2, 23);
        coApp.LoanAppln__c = loanAppId;
        coApp.TotalIncome__c = 3456;
        coApp.Gender__c = 'M';
        coApp.CompanyName__c = 'ABC';
        coApp.MName__c = 'test';
        coApp.Relationship__c = 'Self';
        coApp.UCID__c = '13006102';

        //
        
        if (doInsert) {
            TriggerBase.bypass('Applicant__c');
            insert appli;
            TriggerBase.clearBypass('Applicant__c');
            
            //Addition of code
            TriggerBase.bypass('Applicant__c');
            insert coApp;
            TriggerBase.clearBypass('Applicant__c');
            //

            ApplKyc__c ap = new ApplKyc__c();
            ap.Applicant__c = appli.Id;
            ap.AadharEncripted__c = '123456789098';
            ap.Address__c = 'Pune';
            ap.VotIdEpicNo__c = '123456789';
            ap.kycDoc__c = 'Voter Id';
            ap.kycId__c = '12345';
            insert ap;
            
            //Addition of code
            ApplKyc__c coappKyc = new ApplKyc__c();
            coappKyc.Applicant__c = coApp.Id;
            coappKyc.AadharEncripted__c = '123456789098';
            coappKyc.Address__c = 'Pune';
            coappKyc.VotIdEpicNo__c = '123456789';
            coappKyc.kycDoc__c = 'Voter Id';
            coappKyc.kycId__c = '12345';
            insert coappKyc;
            //
        }
        return appli;
    }
    
        public static Applicant__c createCoAppli(
        Boolean doInsert,
        id loanAppId
    ) {
       
        Applicant__c appli = new Applicant__c();
        appli.FName__c = 'Co-Applicant';
        appli.MobNumber__c = '9876567899';
        appli.LName__c = 'Test';
        appli.ApplType__c = 'C';
        appli.Constitution__c='INDIVIDUAL';
        appli.LoanAppln__c = loanAppId;

        if (doInsert) {
            TriggerBase.bypass('Applicant__c');
            insert appli;
            TriggerBase.clearBypass('Applicant__c');
        }
        return appli;
    }

     public static Applicant__c createCoAppliProp(
        Boolean doInsert,
        id loanAppId
    ) {
       
        Applicant__c appli = new Applicant__c();
        appli.FName__c = 'Co-Applicant';
        appli.MobNumber__c = '9876567899';
        appli.LName__c = 'PROPERITORSHIP';
        appli.ApplType__c = 'C';
        appli.Constitution__c='PROPERITORSHIP';
        appli.LoanAppln__c = loanAppId;

        if (doInsert) {
            TriggerBase.bypass('Applicant__c');
            insert appli;
            TriggerBase.clearBypass('Applicant__c');
        }
        return appli;
    }
    /**
     * ********************************************************
     * This method is test data for create Integration Message Record
     * ********************************************************
     */
    public static List<IntgMsg__c> createIntegrationMessage(
        Boolean doInsert,
        id appId
    ) {
        List<IntgMsg__c> intMsglist = new List<IntgMsg__c>();

        IntgMsg__c newlit = new IntgMsg__c();
        newlit.Name = 'DRIVER\'S LICENSE AUTHENTICATION';
        newlit.BU__c = 'Vehicle Loan';
        newlit.Svc__c = 'Initiate Transaction';
        newlit.IsActive__c = true;
        newlit.RefId__c = appId;
        newlit.Status__c = 'New';
        newlit.MStatus__c = 'Blank';
        newlit.RefObj__c = 'Applicant__c';
        intMsglist.add(newlit);

        if (doInsert) {
            TriggerBase.bypass('IntgMsg__c');
            insert intMsglist;
            TriggerBase.clearBypass('IntgMsg__c');
        }
        return intMsglist;
    }
    /**
     * ********************************************************
     * This method is test data for create Document Master
     * ********************************************************
     */
    public static DocMstr__c createDocumentMaster(
        Boolean doInsert,
        String docMstrName
    ) {
        DocMstr__c docMast = new DocMstr__c();
        // docMast.Name = docMstrName;
        docMast.BU__c = 'Vehicle Loan';
        docMast.DocType__c = 'KYC';
        docMast.Active__c = true;
        docMast.Required__c = true;
        // insert docMast;
        if (doInsert) {
            TriggerBase.bypass('DocMstr__c');
            insert docMast;
            TriggerBase.clearBypass('DocMstr__c');
        }
        return docMast;
    }
    /**
     * ********************************************************
     * This method is test data for create Document Detail
     * ********************************************************
     */
    public static DocDtl__c createDocumentDetail(
        Boolean doInsert,
        String DocName,
        id appId,
        id docMstrId
    ) {
        DocDtl__c appDocDet = new DocDtl__c();
        appDocDet.DocTyp__c = 'Identity Proof';
        appDocDet.DocCatgry__c = 'KYC Documents';
        appDocDet.DocSubTyp__c = DocName;
        appDocDet.Appl__c = appId;
        appDocDet.DocMstr__c = docMstrId;

        if (doInsert) {
            TriggerBase.bypass('DocDtl__c');
            insert appDocDet;
            TriggerBase.clearBypass('DocDtl__c');
        }
        return appDocDet;
    }

    /**
     * ********************************************************
     * This method is test data for create Integration Message records For Response Processor test Class
     * ********************************************************
     */

    public static List<IntgMsg__c> createIntMsg(
        Boolean doInsert,
        string svcName,
        String appId,
        String wrapperData
    ) {
        List<IntgMsg__c> intMsglist = new List<IntgMsg__c>();
        IntgMsg__c newlit = new IntgMsg__c();
        newlit.Name = svcName;
        newlit.BU__c = 'Vehicle Loan';
        newlit.Svc__c = svcName;
        newlit.IsActive__c = true;
        newlit.RefId__c = appId;
        newlit.Status__c = 'Responded';
        newlit.MStatus__c = 'Blank';
        newlit.Trigger_Platform_Event__c = true;
        newlit.RefObj__c = 'Applicant__c';
        newlit.Resp__c = wrapperData != null ? wrapperData : null;
        intMsglist.add(newlit);

        IntgMsg__c newlit1 = new IntgMsg__c();
        newlit1.Name = svcName;
        newlit1.BU__c = 'Blank';
        newlit1.Svc__c = svcName;
        newlit1.IsActive__c = true;
        newlit1.RefId__c = appId;
        newlit.ParentRefId__c = 'a0GC4000000YgssMAC';
        newlit1.Status__c = 'Responded';
        newlit1.MStatus__c = 'Blank';
        newlit1.RefObj__c = 'Applicant__c';
        newlit1.Resp__c = wrapperData;
        intMsglist.add(newlit1);

        if (doInsert) {
            TriggerBase.bypass('IntgMsg__c');
            insert intMsglist;
            TriggerBase.clearBypass('IntgMsg__c');
        }
        return intMsglist;
    }
    /**
     * ********************************************************
     * This method is test data for create Document Master
     * ********************************************************
     */
    public static LoanTeam__c createLoanTeam(Boolean doInsert, String loanId) {
        LoanTeam__c lnTeam = new LoanTeam__c();
        lnTeam.UserId__c = '';
        lnTeam.LoanApplication__c = loanId;
        lnTeam.Stage__c = 'QDE';
        lnTeam.SubStage__c = 'RM Data Entry';
        lnTeam.ObjAPIName__c = 'LoanAppl__c';
        lnTeam.ObjAccess__c = 'Read';
        //lnTeam.User__c = team.Supervisor__r.Employee__c;
        //lnTeam.UserId__c = team.Supervisor__r.Employee__c;
        //lnTeam.ShareReason__c = sharingMdtMap.get(GlobalConstants.Sharing_Mdt_Sales).SharingReason__c;
        lnTeam.UniqueTeamId__c = 'a03C4000007vvITIAY-005C4000001lsNlIAI';
        // insert docMast;
        if (doInsert) {
            TriggerBase.bypass('LoanTeam__c');
            insert lnTeam;
            TriggerBase.clearBypass('LoanTeam__c');
        }
        return lnTeam;
    }
    /**
     * ********************************************************
     * This method is test data for create Location Master
     * ********************************************************
     */
    public static LocMstr__c LocMaster(Boolean doInsert) {
        LocMstr__c Loc = new LocMstr__c();
        Loc.CityId__c = '957';
        Loc.City__c='Hyderabad';
        if (doInsert) {
            TriggerBase.bypass('LocMstr__c');
            insert Loc;
            TriggerBase.clearBypass('LocMstr__c');
        }
        return Loc;
    }

    /**
     * ********************************************************
     * This method is test data for create Case
     * ********************************************************
     */
    public static Case CaseData(Boolean doInsert) {
        Case Loc = new Case();
        Loc.CityId__c = '957';
        Loc.IsRouRobAllowd__c = true;

        if (doInsert) {
            TriggerBase.bypass('Case');
            insert Loc;
            TriggerBase.clearBypass('Case');
        }
        return Loc;
    }

    /**
     * ********************************************************
     * This method is test data for create Scheme Group
     * ********************************************************
     */
    public static SchmGrp__c createSchemeGroup(Boolean doInsert) {
        SchmGrp__c schGrp = new SchmGrp__c();
        schGrp.Product__c = 'Small Ticket LAP';
        schGrp.SCHDESC__c = 'Test Loan';
        schGrp.SCHID__c = '111';
        if (doInsert) {
            TriggerBase.bypass('SchmGrp__c');
            insert schGrp;
        }
        return schGrp;
    }

    /**
     * ********************************************************
     * This method is test data for create Scheme Mapping
     * ********************************************************
     */
    public static SchMapping__c createSchemeMapping(Boolean doInsert) {
        SchMapping__c schMapp = new SchMapping__c();
        schMapp.MaxAmtFin__c = 5000000;
        schMapp.MinAmtFin__c = 500000;
        schMapp.MaxTenure__c = 240;
        schMapp.MinTenure__c = 24;
        schMapp.SchemeDesc__c = 'BT';
        //schMapp.SchGroup__c = TDF_DummyClass.createSchemeGroup(true).Id;
        if (doInsert) {
            TriggerBase.bypass('SchMapping__c');
            insert schMapp;
        }
        return schMapp;
    }

    /**
     * ********************************************************
     * This method is test data for create Account
     * ********************************************************
     */
    public static Account createAccountDetails(Boolean doInsert) {
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.DSAConnId__c = '11';
        acc.VCReferralCode__c = 'ABC123';
        if (doInsert) {
            TriggerBase.bypass('Account');
            insert acc;
        }
        return acc;
    }

    /**
     * ********************************************************
     * This method is test data for create Relationship
     * ********************************************************
     */
    public static Relationship__c createRelationShipDetails(Boolean doInsert) {
        Relationship__c rel = new Relationship__c();
        rel.Name = 'Test';
        rel.ApplType__c = 'INDIVIDUAL';
        rel.CoApplType__c = 'INDIVIDUAL';
        rel.Key__c = 'TES';
        if (doInsert) {
            TriggerBase.bypass('Relationship__c');
            insert rel;
        }
        return rel;
    }
    /**
     * ***************************************************************
     * This method is test data for Applicant PrinlPlaceforBCheckBox
     * ***************************************************************
     */
    public static Applicant__c PrinlPlaceforBCheckBox(
        Boolean doInsert,
        string applicationId,
        boolean ischeckedvalue
    ) {
        Applicant__c app = new Applicant__c();
        app.LoanAppln__c = applicationId;
        app.Same_as_Principal_place_for_business__c = ischeckedvalue;
        if (doInsert) {
            TriggerBase.bypass('Applicant__c');
            upsert app;
        }
        return app;
    }
    /**
     * ***************************************************************
     * This method is test data for CaseUpdationData
     * ***************************************************************
     */
    public static void caseUpdationData(Boolean doInsert) {
        LocMstr__c Loc = testDataFactory.LocMaster(true);
        contact con = testDataFactory.contactCreationData(true);
        account acc = testDataFactory.createAccountDetails(true);
    }
    /**
     * ***************************************************************
     * This method is test data for ContactCreationData
     * ***************************************************************
     */
    public static contact contactCreationData(Boolean doInsert) {
        contact Con = new contact();
        con.Account = testDataFactory.createAccountDetails(true);
        con.lastName = 'Test';
        if (doInsert) {
            TriggerBase.bypass('contact');
            upsert Con;
        }
        return Con;
    }

    /**
     * ***************************************************************
     * This method is test data for AgencyLocationMap
     * ***************************************************************
     */
    public static AgncLocMap__c AgencyLocationMap(Boolean doInsert) {
        AgncLocMap__c Agn = new AgncLocMap__c();
        Agn.Account__c = testDataFactory.createAccountDetails(true).id;
        if (doInsert) {
            TriggerBase.bypass('AgncLocMap__c');
            upsert Agn;
        }
        return Agn;
    }

    /**
     * ***************************************************************
     * This method is test data for SharingHierarchy__mdt
     * ***************************************************************
     */
    public static List<SharingHierarchy__mdt> SharingHierarchyData() {
        List<SharingHierarchy__mdt> shrngConfigList = [
            SELECT
                Id,
                DeveloperName,
                MasterLabel,
                Label,
                QualifiedApiName,
                SupervisoreRoleSharing__c,
                BrchRoleSharing__c,
                SharingReason__c
            FROM SharingHierarchy__mdt
        ];
        return shrngConfigList;
    }

    /**
     * ***************************************************************
     * This method is test data for Applicant Obligation detail
     * ***************************************************************
     */
    public static List<Applicant_Obligation_detail__c> appliObliDetails(
        Boolean doInsert,
        Integer counter
    ) {
        List<Applicant_Obligation_detail__c> appliObliDetails = new List<Applicant_Obligation_detail__c>();
        for (Integer i = 0; i < counter; i++) {
            appliObliDetails.add(
                new Applicant_Obligation_detail__c(
                    BureauRespDtl__c = TestDataFactory.breResponseDetails(true)
                        .Id
                )
            );
        }
        if (doInsert) {
            TriggerBase.bypass('Applicant_Obligation_detail__c');
            upsert appliObliDetails;
        }
        return appliObliDetails;
    }

    /**
     * ***************************************************************
     * This method is test data for Bureau Response Detail
     * ***************************************************************
     */
    public static BureauRespDtl__c breResponseDetails(Boolean doInsert) {
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        BureauRespDtl__c breRes = new BureauRespDtl__c();
        breRes.Applicant__c = TestDataFactory.createSingleApplicant(
                true,
                loan.Id
            )
            .Id;
        breRes.LoanApplication__c = loan.Id;
        if (doInsert) {
            TriggerBase.bypass('BureauRespDtl__c');
            upsert breRes;
        }
        return breRes;
    }
    /**
     * ***************************************************************
     * This method is test data for BRE Eligibility
     * ***************************************************************
     */ public static BRE_Eligibility__c breEligibility(
        Boolean doInsert,
        Id recordId
    ) {
        BRE_Eligibility__c breElig = new BRE_Eligibility__c();
        if (doInsert) {
            breElig.Type__c = 'Applicant';
            breElig.IncomeProgram__c = 'Cash Flow - Assessed income';
            TriggerBase.bypass('BRE_Eligibility__c');
            upsert breElig;
        }
        return breElig;
    }

    /*
     * *************************************************************
     * This method is test data for Applicant Asset
     * *************************************************************
     */
    public static ApplAsset__c applAssetData(Boolean doInsert, Id applcntId) {
        ApplAsset__c testApplAsset = new ApplAsset__c(
            Appl__c = applcntId,
            Prop_Owners__c = 'Test'
        );

        if (doInsert) {
            TriggerBase.bypass('ApplAsset__c');
            insert testApplAsset;
            TriggerBase.clearBypass('ApplAsset__c');
        }
        return testApplAsset;
    }

     public static ApplAsset__c createApplAsset(Boolean doInsert, Id applcntId, Id loanAppId) {
        ApplAsset__c appAsset = new ApplAsset__c();
            appAsset.Appl__c = applcntId;
            appAsset.Prop_Owners__c = 'Test';
         	appAsset.LoanAppln__c= loanAppId;

        if (doInsert) {
            TriggerBase.bypass('ApplAsset__c');
            insert appAsset;
            TriggerBase.clearBypass('ApplAsset__c');
        }
        return appAsset;
    }
    /*
     * *************************************************************
     * This method is test data for Property Questionnaire
     * *************************************************************
     */
    public static PropQues__c proQuesData(Boolean doInsert) {
        List<String> testPossResponses = new List<String>{
            'test',
            'data',
            'info'
        };
        PropQues__c testPropQues = new PropQues__c(
            IsActive__c = true,
            QuesRefId__c = 'PQ-9999999',
            Question_Tiltle__c = 'Name of Credit Officer',
            RespTyp__c = 'Text',
            PossResp__c = JSON.serialize(testPossResponses)
        );
        if (doInsert) {
            TriggerBase.bypass('PropQues__c');
            insert testPropQues;
            TriggerBase.clearBypass('PropQues__c');
        }
        return testPropQues;
    }

    /*
     * *************************************************************
     * This method is test data for Property Questionnaire Response
     * *************************************************************
     */
    public static PropQuesResp__c propQuesRespData(
        Boolean doInsert,
        Id assetId
    ) {
        PropQuesResp__c testQuesResData = new PropQuesResp__c(
            property__c = assetId
        );
        if (doInsert) {
            TriggerBase.bypass('PropQuesResp__c');
            insert testQuesResData;
            TriggerBase.clearBypass('PropQuesResp__c');
        }
        return testQuesResData;
    }

    /*
     * *************************************************************
     * This method is test data for Property Questionnaire Response Jn
     * *************************************************************
     */
    public static PropQuesRespJn__c propQuesResJnData(
        Boolean doInsert,
        Id propQuesRespId
    ) {
        PropQuesRespJn__c testQuesJn = new PropQuesRespJn__c(
            PropQuesResp__c = propQuesRespId
        );
        if (doInsert) {
            TriggerBase.bypass('PropQuesRespJn__c');
            insert testQuesJn;
            TriggerBase.clearBypass('PropQuesRespJn__c');
        }
        return testQuesJn;
    }
    /*
     * *************************************************************
     * This method is test data for Location Branch Junction
     * *************************************************************
     */
    public static LocBrchJn__c locBranchJnData(
        Boolean doInsert,
        Id bankBrchMasterId,
        Id locMasterId
    ) {
        LocBrchJn__c locBr = new LocBrchJn__c(
            Branch__c = bankBrchMasterId,
            Location__c = locMasterId,
            ProductType__c = 'Home Loan'
        );
        if (doInsert) {
            TriggerBase.bypass('LocBrchJn__c');
            insert locBr;
            TriggerBase.clearBypass('LocBrchJn__c');
        }
        return locBr;
    }
    /*
     * *************************************************************
     * This method is test data for IMD Master
     * *************************************************************
     */
    public static IMDMstr__c imdMasterData(Boolean doInsert) {
        IMDMstr__c imdMstr = new IMDMstr__c(
            PrdType__c = 'Home Loan',
            PF__c = 1,
            Tax__c = 18,
            ChargeType__c = 'PF'
        );
        if (doInsert) {
            TriggerBase.bypass('IMDMstr__c');
            insert imdMstr;
            TriggerBase.clearBypass('IMDMstr__c');
        }
        return imdMstr;
    }
    /*
     * *************************************************************
     * This method is test data for Promotion Mapping
     * *************************************************************
     */
    public static PromoMapping__c proMapData(Boolean doInsert) {
        PromoMapping__c proMap = new PromoMapping__c(
            ProductType__c = 'Home Loan'
        );
        if (doInsert) {
            TriggerBase.bypass('PromoMapping__c');
            insert proMap;
            TriggerBase.clearBypass('PromoMapping__c');
        }
        return proMap;
    }
    /*
     * *************************************************************
     * This method is test data for Charge
     * *************************************************************
     */
    public static LonaApplCharges__c chargeData(
        Boolean doInsert,
        Id loanApplId,
        Id mstrDataId
    ) {
        LonaApplCharges__c charge = new LonaApplCharges__c(
            LoanApplication__c = loanApplId,
            MasterData__c = mstrDataId,
            ChargeCodeID__c='600168',
          
            ActualAmt__c=900000
        );
        if (doInsert) {
            TriggerBase.bypass('LonaApplCharges__c');
            insert charge;
            TriggerBase.clearBypass('LonaApplCharges__c');
        }
        return charge;
    }
    /*
     * *************************************************************
     * This method is test data for Master Data
     * *************************************************************
     */
    public static MasterData__c mstrData(Boolean doInsert) {
        MasterData__c mstr = new MasterData__c(Type__c = 'Charge Master');
        if (doInsert) {
            TriggerBase.bypass('MasterData__c');
            insert mstr;
            TriggerBase.clearBypass('MasterData__c');
        }
        return mstr;
    }

    public static APIVer__c createAPIVerification(
        Boolean doInsert,
        Id loanAppId,
        Id AppId,
        string RTLabel
    ) {
        APIVer__c apiVer = new APIVer__c();
        apiVer.LoanAplcn__c = loanAppId;
        apiVer.Appl__c = AppId;
        apiVer.RecordTypeId = Schema.getGlobalDescribe()
            .get('APIVer__c')
            .getDescribe()
            .getRecordTypeInfosByName()
            .get(RTLabel)
            .getRecordTypeId();
        if (doInsert) {
            TriggerBase.bypass('APIVer__c');
            insert apiVer;
            TriggerBase.clearBypass('APIVer__c');
        }
        return apiVer;
    }

    /*
     * *************************************************************
     * This method is test data for Applicant IMD
     * *************************************************************
     */
    public static ApplIMD__c applIMDData(Boolean doInsert, Id loanId) {
        ApplIMD__c imd = new ApplIMD__c(LoanAppln__c = loanId);
        if (doInsert) {
            TriggerBase.bypass('ApplIMD__c');
            insert imd;
            TriggerBase.clearBypass('ApplIMD__c');
        }
        return imd;
    }

    /*
     * *************************************************************
     * This method is test data for Applicant Address
     * *************************************************************
     */
    public static ApplAddr__c applAddData(
        Boolean doInsert,
        Id loanId,
        Id applId
    ) {
        ApplAddr__c add = new ApplAddr__c(
            LoanAppl__c = loanId,
            Applicant__c = applId
        );
        if (doInsert) {
            TriggerBase.bypass('ApplAddr__c');
            insert add;
            TriggerBase.clearBypass('ApplAddr__c');
        }
        return add;
    }
    /*
     * *************************************************************
     * This method is test data for Applicant Address
     * *************************************************************
     */
    public static ApplAddr__c applAddPermanent(
        Boolean doInsert,
        Id loanId,
        Id applId
    ) {
        ApplAddr__c add = new ApplAddr__c(
            LoanAppl__c = loanId,
            Applicant__c = applId,
            AddrTyp__c = 'Permanent Address'
        );
        if (doInsert) {
            TriggerBase.bypass('ApplAddr__c');
            insert add;
            TriggerBase.clearBypass('ApplAddr__c');
        }
        return add;
    }
    /*
     * *************************************************************
     * This method is test data for Insurance
     * *************************************************************
     */
    public static Insurance__c InsuranceData(
        Boolean doInsert,
        Id loanId,
        Id applId
    ) {
        Insurance__c Ins = new Insurance__c(
            LoanAppln__c = loanId,
            Appl__c = applId
        );
        if (doInsert) {
            TriggerBase.bypass('Insurance__c');
            insert Ins;
            TriggerBase.clearBypass('Insurance__c');
        }
        return Ins;
    }
    /*
     * *************************************************************
     * This method is test data for Bureau
     * *************************************************************
     */
    public static Bureau__c BureauData(Boolean doInsert, Id loanId, Id applId) {
        Bureau__c Ins = new Bureau__c(
            LoanApp__c = loanId,
            Applicant__c = applId,
            IsLatest__c = true,
            BureauAPI__c = 'Commercial'
        );
        if (doInsert) {
            TriggerBase.bypass('Bureau__c');
            insert Ins;
            TriggerBase.clearBypass('Bureau__c');
        }
        return Ins;
    }

    /**
     * ********************************************************
     * This method is test data for create Document Master
     * ********************************************************
     */
    public static DocMstr__c DocumentMasterData(Boolean doInsert) {
        DocMstr__c docData = new DocMstr__c();
        // docMast.Name = docMstrName;
        docData.BU__c = 'Vehicle Loan';
        docData.DocType__c = 'Bureau Report';
        docData.Active__c = true;
        docData.Required__c = true;
        docData.Catgry__c = 'Bureau Report';
        docData.Prod__c = 'Home Loan';
        // insert docMast;
        if (doInsert) {
            TriggerBase.bypass('DocMstr__c');
            insert docData;
            TriggerBase.clearBypass('DocMstr__c');
        }
        return docData;
    }
    /**
     * ********************************************************
     * This method is test data for Applicant Asset
     * ********************************************************
     */
    public static ApplAsset__c ApplAsset(
        Boolean doInsert,
        Id loanId,
        Id Applicant
    ) {
        ApplAsset__c AssetData = new ApplAsset__c();
        // docMast.Name = docMstrName;
        // AssetData.PropAddrs__c = 'DHOLPUR,RAJASTHAN,';
        AssetData.LoanAppln__c = loanId;
        AssetData.Appl__c = Applicant;

        if (doInsert) {
            TriggerBase.bypass('ApplAsset__c');
            insert AssetData;
            TriggerBase.clearBypass('ApplAsset__c');
        }
        return AssetData;
    }
    /**
     * ********************************************************
     * This method is test data for NDC
     * ********************************************************
     */
    public static NDC__c NDCData(Boolean doInsert, Id loanId, Id Applicant) {
        NDC__c NDC = new NDC__c();
        NDC.Applicant__c = Applicant;
        // NDC.PropAddrs__c = 'DHOLPUR,RAJASTHAN,';
        NDC.LoanAppl__c = loanId;
        NDC.IsInvalid__c = false;
        NDC.OpsQuery__c = false;
        NDC.NDC_Section__c = 'Borrower Details';

        if (doInsert) {
            TriggerBase.bypass('NDC__c');
            insert NDC;
            TriggerBase.clearBypass('NDC__c');
        }
        return NDC;
    }
   
    /**
     * ********************************************************
     * This method is test data for AadharOTPResponsewrapper class
     * ********************************************************
     */
      public static String getSampleAadharOTPResponsewrapperJSON() {
        String sampleJson = '{"status":"success","reference_id":"xxxxxxxx","transaction_id":"xxxxxx","message":"xxxxxxxx","response_time_stamp":"YYYY-MM-DDTHH:MM:SS","result":{"validated_data":{"full_name":"xxxx","aadhaar_number":"xxxx","dob":"YYYY-MM-DD","gender":"xxxx","address":{"country":"xxxx","dist":"xxxx","state":"xxxx","po":"xxxx","loc":"xxxx","vtc":"xxxx","subdist":"xxxx","street":"xxxx","house":"xxxx","landmark":""},"face_status":true,"face_score":"xxxx","zip":"xxxxxx","profile_image":"base64 image data","has_image":true,"raw_xml":"xxxx","zip_data":"xxxx","care_of":"xxxx","share_code":"xxxx","mobile_verified":true,"reference_id":"xxxx","aadhaar_pdf":{}}},"error":null,"error_code":null}';
        return sampleJson;
    }
    /**
     * ********************************************************
     * This method is test data for PaytmRequestGenerator class
     * ********************************************************
     */
       public static ApplIMD__c createApplIMD(String LoanId) {
        ApplIMD__c applIMD = new ApplIMD__c(IMDAmt__c = 1000,LoanAppln__c=LoanId);
        insert applIMD;
        return applIMD;
    }

    public static Payment__c createPayment(String LoanId) {
        Payment__c payment = new Payment__c(InstrumentAmt__c = 500,LoanAppl__c=LoanId);
        insert payment;
        return payment;
    }

    
    public static IntgMsg__c createIntgMsg(String refId, String refObj) {
        IntgMsg__c intgMsg = new IntgMsg__c(RefObj__c = refObj, RefId__c = refId);
        intgMsg.Status__c='New';
        insert intgMsg;
        return intgMsg;
    }

    /**
     * ********************************************************
     * This method is test data for PaytmRequestWrapper class
     * ********************************************************
     */
     public class PaytmRequestWrapperTestData {
        public String jsonString;
        public String tokenType;
        public String signature;
        public String mid;
        public String linkType;
        public String linkDescription;
        public String linkName;
        public String linkOrderId;
        public Double amount;
    }

    public static PaytmRequestWrapperTestData createPaytmRequestWrapperTestData() {
        PaytmRequestWrapperTestData testData = new PaytmRequestWrapperTestData();
        
        // Set values for your test data
        testData.tokenType = 'AES';
        testData.signature = '{signature}';
        testData.mid = '{mid}';
        testData.linkType = 'FIXED';
        testData.linkDescription = 'Test Payment';
        testData.linkName = 'Test';
        testData.linkOrderId = '{linkOrderId}';
        testData.amount = 1.01;
        
        // Create the JSON string using the test data
        testData.jsonString = '{"head":{"tokenType":"' + testData.tokenType + '","signature":"' + testData.signature + '"},"body":{"mid":"' + testData.mid + '","linkType":"' + testData.linkType + '","linkDescription":"' + testData.linkDescription + '","linkName":"' + testData.linkName + '","linkOrderId":"' + testData.linkOrderId + '","amount":' + testData.amount + '}}';

        return testData;
    }
    
    /**
     * ********************************************************
     * This method is test data for PaytmResponseWrapper class
     * ********************************************************
     */
    
     public class PaytmResponseWrapperTestData {
        public String jsonString;
        public String version;
        public String timestamp;
        public String channelId;
        public String tokenType;
        public String clientId;
        public String linkId;
        public String linkType;
        public String longUrl;
        public String shortUrl;
        public String expiryDate;
        public Boolean isActive;
        public String merchantHtml;
        public String createdDate;
        public String linkOrderId;
        public List<NotificationDetailsTestData> notificationDetails;
        public ResultInfoTestData resultInfo;
    }

    public class NotificationDetailsTestData {
        public String customerName;
        public String contact;
        public String notifyStatus;
        public String timestamp;
    }

    public class ResultInfoTestData {
        public String resultStatus;
        public String resultCode;
        public String resultMessage;
    }

    public static PaytmResponseWrapperTestData createPaytmResponseWrapperTestData() {
        PaytmResponseWrapperTestData testData = new PaytmResponseWrapperTestData();

        // Set values for your test data
        testData.version = '1.0';
        testData.timestamp = '1566994462639';
        testData.channelId = '123';
        testData.tokenType = 'AES';
        testData.clientId = '456';
        testData.linkId = '5861';
        testData.linkType = 'FIXED';
        testData.longUrl = 'https://securegw-stage.paytm.in/link/PAYMENTLINKNAME/LL_5861';
        testData.shortUrl = 'https://paytm.me/ID-PBo7';
        testData.expiryDate = '27/08/2020 17:44:22';
        testData.isActive = true;
        testData.merchantHtml = '<html></html>';
        testData.createdDate = '28/08/2019 17:44:22';
        testData.linkOrderId = '123456789';
        
        // Set values for NotificationDetails
        testData.notificationDetails = new List<NotificationDetailsTestData>();
        NotificationDetailsTestData notificationTestData = new NotificationDetailsTestData();
        notificationTestData.customerName = 'John Doe';
        notificationTestData.contact = '1234567890';
        notificationTestData.notifyStatus = 'SUCCESS';
        notificationTestData.timestamp = '1566994462639';
        testData.notificationDetails.add(notificationTestData);

        // Set values for ResultInfo
        testData.resultInfo = new ResultInfoTestData();
        testData.resultInfo.resultStatus = 'SUCCESS';
        testData.resultInfo.resultCode = '200';
        testData.resultInfo.resultMessage = 'Payment link is created successfully';

        // Create the JSON string using the test data
        testData.jsonString = '{"head":{"version":"' + testData.version + '","timestamp":"' + testData.timestamp + '","channelId":"' + testData.channelId + '","tokenType":"' + testData.tokenType + '","clientId":"' + testData.clientId + '"},"body":{"linkId":"' + testData.linkId + '","linkType":"' + testData.linkType + '","longUrl":"' + testData.longUrl + '","shortUrl":"' + testData.shortUrl + '","expiryDate":"' + testData.expiryDate + '","isActive":' + testData.isActive + ',"merchantHtml":"' + testData.merchantHtml + '","createdDate":"' + testData.createdDate + '","linkOrderId":"' + testData.linkOrderId + '","notificationDetails":[{"customerName":"' + notificationTestData.customerName + '","contact":"' + notificationTestData.contact + '","notifyStatus":"' + notificationTestData.notifyStatus + '","timestamp":"' + notificationTestData.timestamp + '"}],"resultInfo":{"resultStatus":"' + testData.resultInfo.resultStatus + '","resultCode":"' + testData.resultInfo.resultCode + '","resultMessage":"' + testData.resultInfo.resultMessage + '"}}}';

        return testData;
    }
    
    /**
     * ********************************************************
     * This method is test data for Employer
     * ********************************************************
     */
    public static Employer__c createEmployer(Boolean doInsert){
        Employer__c emp=new Employer__c();
        emp.Name= 'Test Employer';
          if (doInsert) {
            TriggerBase.bypass('Employer__c');
            insert emp;
            TriggerBase.clearBypass('Employer__c');
        }
        return emp;
    } 
    
    
     /**
     * ********************************************************
     * This method is test data for Industry__c
     * ********************************************************
     */
    public static Industry__c createIndustry(Boolean doInsert){
        Industry__c industry=new Industry__c();
        industry.Name= 'Test Industry';
          if (doInsert) {
            TriggerBase.bypass('Industry__c');
            insert industry;
            TriggerBase.clearBypass('Industry__c');
        }
        return industry;
    } 
    
      /**
     * ********************************************************
     * This method is test data for SubIndustry__c
     * ********************************************************
     */
    public static SubIndustry__c createSubIndustry(Boolean doInsert,string industry){
        SubIndustry__c subIndustry=new SubIndustry__c();
        subIndustry.Name= 'Test Sub Industry';
        subIndustry.Industry__c = industry;
          if (doInsert) {
            TriggerBase.bypass('SubIndustry__c');
            insert subIndustry;
            TriggerBase.clearBypass('SubIndustry__c');
        }
        return subIndustry;
    } 
    
        /**
     * ********************************************************
     * This method is test data for RBI_ReportingIndustry__c
     * ********************************************************
     */
    public static RBI_ReportingIndustry__c createRbiIndustry(Boolean doInsert,string industry,string subIndustry){
        RBI_ReportingIndustry__c RBI_Industry=new RBI_ReportingIndustry__c();
        RBI_Industry.Name= 'Test RBI Industry';
        RBI_Industry.Industry__c = industry;
        RBI_Industry.SubIndustry__c = subIndustry;
          if (doInsert) {
            TriggerBase.bypass('RBI_ReportingIndustry__c');
            insert RBI_Industry;
            TriggerBase.clearBypass('RBI_ReportingIndustry__c');
        }
        return RBI_Industry;
    }
    /**
     * ********************************************************
     * This method is test data for Deviation
     * ********************************************************
     */   
    Public static Deviation__c createDeviation(Boolean doInsert, Id loanAppId, Id ApplicantId, String deviationName){
       Deviation__c objDeviation = new Deviation__c();
       objDeviation.Applicant__c = ApplicantId;
       objDeviation.LoanAppln__c = loanAppId;  
       objDeviation.Name = 'Test';
       objDeviation.Deviation__c = deviationName; 
	   if (doInsert) {
            TriggerBase.bypass('Deviation__c'); 
            insert objDeviation;
            TriggerBase.clearBypass('Deviation__c');
        }
        return objDeviation;    
	}
    /**
     * ********************************************************
     * This method is test data for SFDC Bank Master
     * ********************************************************
     */
	public static SFDCBANKMaster__c sfdcBankMasterDetails(Boolean doInsert){
       SFDCBANKMaster__c sfdcBnkMstr = new SFDCBANKMaster__c();
	   if (doInsert) {
            TriggerBase.bypass('SFDCBANKMaster__c');
            insert sfdcBnkMstr;
            TriggerBase.clearBypass('SFDCBANKMaster__c');
        }
        return sfdcBnkMstr;
	} 
	/**
     * ********************************************************
     * This method is test data for Applicant Banking
     * ********************************************************
     */
	public static ApplBanking__c applBankingDetails(Boolean doInsert,id applId,Id loanId,Id sfdcBnkMstrId){
       ApplBanking__c applBank = new ApplBanking__c();
       applBank.Appl__c = applId;
	   applBank.LoanAppl__c = loanId;
       applBank.SFDCBankMaster__c = sfdcBnkMstrId;
	   if (doInsert) {
            TriggerBase.bypass('ApplBanking__c');
            insert applBank;
            TriggerBase.clearBypass('ApplBanking__c');
        }
        return applBank; 
	}    
	/**
     * ********************************************************
     * This method is test data for Repayment Account
     * ********************************************************
     */
	public static Repayment_Account__c rePayAccData(Boolean doInsert,Id loanId){
       Repayment_Account__c repayAcc = new Repayment_Account__c();
	   repayAcc.Loan_Application__c	 = loanId;
	   if (doInsert) {
            TriggerBase.bypass('Repayment_Account__c');
            insert repayAcc;
            TriggerBase.clearBypass('Repayment_Account__c');
        }
        return repayAcc;
	}    	
    
    /**
     * ********************************************************
     * This method is test data for ApplRegltry__c
     * ********************************************************
     */
    public static ApplRegltry__c createApplRegltry(Boolean doInsert,String AppId,String LoanAppId){
        ApplRegltry__c ApplRegltry=new ApplRegltry__c();
        ApplRegltry.IsBorowrOrRelFFDir__c= 'Yes';
        ApplRegltry.Appl__c = AppId;
        ApplRegltry.LoanAppln__c = LoanAppId;
          if (doInsert) {
            TriggerBase.bypass('ApplRegltry__c');
            insert ApplRegltry;
            TriggerBase.clearBypass('ApplRegltry__c');
        }
        return ApplRegltry;
    } 
    
    /**
     * ********************************************************
     * This method is test data for RegltryPrsonl__c
     * ********************************************************
     */
    public static RegltryPrsonl__c createRegPersonal(Boolean doInsert,String regId){
        RegltryPrsonl__c regPersonal=new RegltryPrsonl__c();
        regPersonal.Applicant_Regulatory__c= regId;
        regPersonal.DirName__c = 'Jhon';
        regPersonal.Reltnshp__c = 'Father';
          if (doInsert) {
            TriggerBase.bypass('RegltryPrsonl__c');
            insert regPersonal;
            TriggerBase.clearBypass('RegltryPrsonl__c');
        }
        return regPersonal;
    } 
       /**
     * ********************************************************
     * This method is test data for APICoutTrckr__c
     * ********************************************************
     */
    public static APICoutTrckr__c createAPICountTrckr(Boolean doInsert, id loanAppId,id applicantId){
        APICoutTrckr__c aPICountTrckr=new APICoutTrckr__c();
        aPICountTrckr.LAN__c= loanAppId;
        aPICountTrckr.Appl__c = applicantId;
       
           if (doInsert) {
            TriggerBase.bypass('APICoutTrckr__c');
            insert aPICountTrckr;
            TriggerBase.clearBypass('APICoutTrckr__c');
        }
        return aPICountTrckr; 
        }
        
 /**
     * ********************************************************
     * This method is test data for Applicant Kyc
     * ********************************************************
     */
    public static ApplKyc__c createApplKyc(Boolean doInsert,id applicantId){
        ApplKyc__c appKyc=new ApplKyc__c();
        appKyc.Applicant__c= applicantId;
       	appkyc.ValidationStatus__c = 'Failure';
        appkyc.OCRStatus__c = 'Success';
        appkyc.kycDoc__c = 'Pan';
        appkyc.Pan__c='AHTPS2873B';
       
           if (doInsert) {
            TriggerBase.bypass('ApplKyc__c');
            insert appKyc;
            TriggerBase.clearBypass('ApplKyc__c');
        }
        return appKyc; 
        }
        
    
     public static ApplKyc__c createApplKyc1(Boolean doInsert,id applicantId){
        ApplKyc__c appKyc=new ApplKyc__c();
        appKyc.Applicant__c= applicantId;
        appkyc.ValidationStatus__c = 'Failure';
        appkyc.OCRStatus__c = 'Success';
        appkyc.kycDoc__c = 'Driving license';
        appkyc.DLNo__c='123456';
       
           if (doInsert) {
            TriggerBase.bypass('ApplKyc__c');
            insert appKyc;
            TriggerBase.clearBypass('ApplKyc__c');
        }
        return appKyc; 
        }

    /**
     * ********************************************************
     * This method is test data for RCU Manager Case Update
     * ********************************************************
     */
    public static Case createRCUCase(Boolean doInsert,id loanApp,id accId,id conId,id recId,id caseId){
       Case c = new Case();
        c.Loan_Application__c = loanApp;
        c.RecordTypeId =recId;
        c.Status = 'New';
        c.AccountId=accId;
        c.ContactId=conId;
        c.Case__c=caseId;
       
           if (doInsert) {
            TriggerBase.bypass('Case');
            insert c;
            TriggerBase.clearBypass('Case');
        }
        return c; 
        }
        

     public static CaseDoc__c createCaseDoc(Boolean doInsert,id caseId, id docId, id appAddId){
       CaseDoc__c cd = new CaseDoc__c();
        cd.Case__c=caseId;
        cd.DocDetail__c=docId;
        cd.ApplAddr__c=appAddId;
       
           if (doInsert) {
            TriggerBase.bypass('CaseDoc__c');
            insert cd;
            TriggerBase.clearBypass('CaseDoc__c');
        }
        return cd; 
        }

 public static DocDtl__c createDocDtl(Boolean doInsert,id appliId, id docMstrId, id loanAppId, string docStatus){
       DocDtl__c docDtl = new DocDtl__c();
        docDtl.DocTyp__c = 'Identity Proof';
        docDtl.DocCatgry__c = 'KYC Documents';
        docDtl.Appl__c = appliId;
        docDtl.DocMstr__c = docMstrId;
        docDtl.AgencyAssigned__c =true;
        docDtl.RCUInitiated__c = true;
        docDtl.IsDeleted__c =false;
        docDtl.AgencyDocStatus__c = docStatus;
        docDtl.LAN__c=loanAppId;
       
           if (doInsert) {
            TriggerBase.bypass('DocDtl__c');
            insert docDtl;
            TriggerBase.clearBypass('DocDtl__c');
        }
        return docDtl; 
        }    
    
    public static ApplAddr__c createApplAddr(Boolean doInsert,id appliId, id loanAppId, string docStatus){
       ApplAddr__c applAdd = new ApplAddr__c();
        applAdd.LoanAppl__c = loanAppId;
        applAdd.Applicant__c = appliId;
        applAdd.AgencyAssigned__c = true;
        applAdd.RCUProfChecked__c = true;
        applAdd.RCUInitiated__c = true;
        applAdd.AgencyDocStatus__c= docStatus;
       
           if (doInsert) {
            TriggerBase.bypass('ApplAddr__c');
            insert applAdd;
            TriggerBase.clearBypass('ApplAddr__c');
        }
        return applAdd; 
        }    
}