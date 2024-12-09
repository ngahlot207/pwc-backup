public without sharing class UWForwardValidations {
    public static LoanAppl__c loanRec;  
    public static list<Applicant__c> appRecList;    
  @AuraEnabled
  public static List<String> validateData(String loanId) {
    List<String> errors = new List<String>();
    try {
      LoanAppl__c loan = [
        SELECT
          Id,
          Stage__c,
          Product__c,
          SubStage__c,
          DisbursedAmount__c,
          PendingDisbursalAmount__c,
          EffectiveNextIntStartDt__c,
          TotalLoanAmountIncCharges__c,
          Final_Loan_Disbursal_Amount__c,
          DisbursalType__c,
          DocGenReRequired__c,
                Disbursal_Document_Required__c,
          App_Form_End_Use_Letter_Doc_Required__c,
          Is_E_Stamp_Done__c,
                Is_E_Sign_Physical_Done__c,
          SchemeId__c,
          OwnContriCash__c,
          SchmCode__c,
          BonceBTloanSesingless12mths__c,
          BonceBTloanSesingtreql12mths__c,
          BonceBTloanSesingtreql18mths__c,
          LANRCUStatus__c
        FROM LoanAppl__c
        WHERE Id = :loanId
      ];
            loanRec=loan;
      ///START - LAK-6166
      if (
        loan.Stage__c != 'QDE' &&
        loan.SchmCode__c != null &&
        loan.SchmCode__c.contains('BT') &&
        (loan.BonceBTloanSesingless12mths__c == null ||
        loan.BonceBTloanSesingtreql12mths__c == null ||
        loan.BonceBTloanSesingtreql18mths__c == null)
      ) {
        errors.add(
          'Mandatory fields on Obligation details are not entered. Please complete all required fields.'
        );
      }
        //lak-9574
        // List<String> consumerProduct = new List<String>{
                     List<String> consumerProduct = new List<String>{'Auto Loan',
                        'Housing Loan',
                        'Property Loan',
                        'Loan Against Shares/Securities',
                        'Personal Loan',
                        'Consumer Loan',
                        'Education Loan',
                        'Loan to Professional',
                        'Leasing',
                        'Overdraft',
                        'Two-wheeler Loan',
                        'Loan Against Bank Deposits',
                        'Commercial Vehicle Loan',
                        'GECL Loan Secured',
                        'GECL Loan Unsecured',
                        'Used Car Loan',
                        'Construction Equipment Loan',
                        'Tractor Loan',
                        'Loan on Credit Card',
                        'Mudra Loans - Shishu / Kishor / Tarun',
                        'Microfinance - Business Loan',
                        'Microfinance - Personal Loan',
                        'Microfinance - Housing Loan',
                        'Microfinance - Other',
                        'P2P Personal Loan',
                        'P2P Auto Loan',
                        'P2P Education Loan',
                        'Business Loan - Secured',
                        'Business Loan - General',
                        'Business Loan - Priority Sector - Small Business',
                        'Business Loan - Priority Sector - Agriculture',
                        'Business Loan - Priority Sector - Others',
                        'Business Loan - Unsecured',
                        'Other'
                        };
                            List<String> commercialProduct = new List<String>{
                                'Cash credit',
                                    'Overdraft',
                                    'Demand loan',
                                    'Medium term loan (period above 1 year and up to 3 years)',
                                    'Long term loan (period above 3 years)',
                                    'Lease finance',
                                    'Hire purchase',
                                    'Commercial vehicle loan',
                                    'Equipment financing (construction office medical)',
                                    'Unsecured business loan',
                                    'Short term loan (less than 1 year)',
                                    'Auto Loan',
                                    'Property Loan',
                                    'Gold Loan',
                                    'HealthCare Finance',
                                    'Infrastructure Finance',
                                    'GECL Loan',
                                    'Others'
                                    };
                                        Date minCloseDate = Date.today().addYears(-1);
List<BureauRespDtl__c> bureauRespDtls = [
                    SELECT
                    Id,
                    NatureOfLoan__c,
                    EMI__c,
                    FinancierName__c,
                    CurrentOs__c,
                    Repayment_Bank__c,
                    RepayAc__c,
                    Treatment__c,
                    Applicant__c,
                    Bureau__c,
                    EMISource__c,
                    Source__c,
                    PrsnlDis__c,
                    Overdues__c,
                    Tenure__c,
                    DisbursalDate__c,
                    LoanAmount__c,
                    CrdFacType__c,
                    IsLatest__c,
                    CloseDate__c,
                    Remarks__c,
                    LoanName__c,
                    LoanCapacity__c,
                    RecordType.Name,
                    LoanApplication__r.BonceBTloanSesingless12mths__c, LoanApplication__r.BonceBTloanSesingtreql12mths__c, LoanApplication__r.BonceBTloanSesingtreql18mths__c
                    FROM BureauRespDtl__c
                    WHERE
                    LoanApplication__c = :loanId
                    AND Applicant__r.Type_of_Borrower__c = 'Financial'
                    AND (RecordType.Name = 'Consumer Obligation'
                         OR RecordType.Name = 'Commercial Obligation')
                    AND Treatment__c != 'Already closed'
                    AND CloseDate__c = NULL
                ];
                if (!bureauRespDtls.isEmpty()) {
                    for (BureauRespDtl__c brd : bureauRespDtls) {
                        Integer closeCal = null;
                        if (brd.CloseDate__c != null) {
                            Date currentDate = Date.today();
                            Date closeDate = brd.CloseDate__c;
                            Integer c1 = currentDate.year() - closeDate.year();
                            Integer c2 = currentDate.month() - closeDate.month();
                            closeCal = (c1 * 12) + c2;
                        }
                        if (
                            (String.isBlank(brd.FinancierName__c) ||
                             String.isBlank(brd.Treatment__c) ||
                             String.isBlank(brd.Repayment_Bank__c) ||
                             brd.CurrentOs__c == null ||
                             brd.EMI__c == null ||
                             brd.Overdues__c == null ||
                             brd.Tenure__c == null ||
                             String.isBlank(brd.RepayAc__c) ||
                             String.isBlank(brd.EMISource__c)) &&
                            brd.Source__c != 'Manual' &&
                            (consumerProduct.contains(brd.NatureOfLoan__c) ||
                             (brd.CrdFacType__c != null &&
                              brd.CrdFacType__c == 'Current' &&
                              CommercialProduct.contains(brd.NatureOfLoan__c))) 
                            // removed above condition for LAK-8489
                            //   &&
                            //     (brd.CloseDate__c == null || (closeCal != null && closeCal <= 12))
                        ) {
                            // system.debug('error coming here first ' + brd.Id);
                            errors.add('Required Data Missing on Obligation Details.');
                            
                        } //lak-9574
                        /* else if (
(brd.LoanApplication__r.BonceBTloanSesingless12mths__c==null) ||
(brd.LoanApplication__r.BonceBTloanSesingtreql12mths__c==null) ||
(brd.LoanApplication__r.BonceBTloanSesingtreql18mths__c==null)
) {
// system.debug('error coming here second ' + brd.Id);
errors.add('Required Data Missing on Obligation Details.');
}*/
                        
                        else if (
                            (String.isBlank(brd.FinancierName__c) ||
                             String.isBlank(brd.Treatment__c) ||
                             String.isBlank(brd.Repayment_Bank__c) ||
                             brd.CurrentOs__c == null ||
                             brd.EMI__c == null ||
                             brd.Tenure__c == null ||
                             String.isBlank(brd.RepayAc__c) ||
                             String.isBlank(brd.LoanName__c) ||
                             String.isBlank(brd.NatureOfLoan__c) ||
                             String.isBlank(brd.LoanCapacity__c) ||
                             brd.DisbursalDate__c == null ||
                             brd.LoanAmount__c == null) && brd.Source__c == 'Manual'
                        ) {
                            // system.debug('error coming here second ' + brd.Id);
                            errors.add('Required Data Missing on Obligation Details.');
                        }
                    }
                }
            // LAK-112, RCU Validation
        if (
        loan.Stage__c != 'QDE' &&
        loan.LANRCUStatus__c != null &&
        (loan.LANRCUStatus__c == 'Fraud' ||
        loan.LANRCUStatus__c == 'Negative')
      ) {
        errors.add(
          'Loan RCU Status is '+loan.LANRCUStatus__c+'.'
        );
      }
      List<LoanAppeal__c> loanAppealNego = new List<LoanAppeal__c>();
      loanAppealNego = [SELECT Id, Status__c, LoanAppl__c FROM LoanAppeal__c  where  LoanAppl__c =:loanId  AND (Status__c = 'New'  OR Status__c = 'In Progress'  )  AND RecordType.DeveloperName ='LoanTermNegotiation'];
       
      if(!loanAppealNego.isEmpty() && loan.Stage__c == 'Post Sanction' &&  loan.subStage__c == 'Data Entry'   ){
        errors.add(
          'Loan Term Negotiation in Progress '
        );
      }
      
      list<Applicant__c> appl = new List<Applicant__c>(
        [
          SELECT
            Id,
            Businessproofavailable__c,
            CustProfile__c,
            Constitution__c,
            FullName__c,
            Type_of_Borrower__c,
                    MobNumber__c,
                    ApplType__c,
                    (SELECT ID FROM Applicant_Employments__r)
          FROM Applicant__c
          WHERE LoanAppln__c = :loanId AND ApplType__c IN ('P', 'C', 'G')
        ]
      );
            appRecList=appl;
            String primaryAppMobNum;
      for (Applicant__c app : appl) {
        if (
          String.isBlank(app.Businessproofavailable__c) &&
          loan.Stage__c != 'QDE' &&
          app.CustProfile__c != 'SALARIED' &&
          app.Type_of_Borrower__c == 'Financial'
        ) {
          errors.add(
            app.FullName__c +
            ': Mandatory fields on Employment Details are not entered. Please complete all required fields.'
          );
        }

        Integer empCount = 0;
        for (ApplicantEmployment__c appEmp : app.Applicant_Employments__r) {   
          empCount++;
        }
        if(empCount > 1){
          errors.add(app.FullName__c + ' : Multiple Employments Details Present, Please Contact Admin');
        }
      }
      ///END - LAK-6166
      String loanProductCode;
      List<Case> rcuCases = [
        SELECT Id, Loan_Application__c, ReportResult__c
        FROM Case
        WHERE RecordType.Name = 'RCU' AND Loan_Application__c = :loanId
      ];
      if (loan != null) {
        if (loan.Product__c == 'Home Loan') {
          loanProductCode = '5935';
        } else if (loan.Product__c == 'Small Ticket LAP') {
          loanProductCode = '5934';
        }
      }
      List<Deviation__c> postSanAutoDevRecrds = [
        SELECT id
        FROM Deviation__c
        WHERE
          DeviationCategory__c = 'Post Sanction Auto Deviation'
          AND LoanAppln__c = :loanId
          AND Deviation__c = :loanProductCode
      ];
      List<Bureau__c> bureauRespnses = [
        SELECT
          Id,
          Applicant__c,
          Applicant__r.Id,
          BureauAPI__c,
          IsLatest__c,
          ErrorMess__c
        FROM Bureau__c
        WHERE BureauAPI__c = 'Consumer' AND LoanApp__c = :loanId
      ];

      List<APICoutTrckr__c> coutTrackers = [
        SELECT Id, LtstRespCode__c, IsInvalid__c
        FROM APICoutTrckr__c
        WHERE APIName__c = 'Crif Auth Login' AND LAN__c = :loanId
      ];

      List<Disbursement__c> disburseList = [
        SELECT
          Id,
          ApplicationID__c,
          Appl_Name__c,
          Product__c,
          Split_Disbursement_s_Amount__c,
          Scheme__c,
          Loan_Tenu__c,
          Total_Disb_Amt__c,
          Disbur_To__c,
          No_of_Disbur__c,
          Princ_Rec_on__c,
          Princ_Start_Date__c,
          Disbur_No__c,
          Disbur_Desrp__c,
          Date_of_Disbur__c,
          DisbrDiscription__c,
          Disbur_Status__c,
          Loan_Appli__c,
          Pend_Disbur_Amt__c,
          Loan_Appli__r.DisbursalType__c,
          (
            SELECT
              Id,
              Disbur_To__c,
              Split_Cheque_Amt__c,
              Date_of_Disbur__c,
              Custo_Name__c,
              Pay_Mode__c,
              Penny_Drop_Nm_Sta__c,
              Pay_City_Id__c,
              Fund_Transf_Mode__c,
              IFSC_Detail__c,
              Cheq_DD_Date__c,
              Cheq_DD_No__c,
              Effec_Date__c,
              Fedbank_Acc_Nm__c,
              Payable_At__c,
              Fedbank_Acc_No__c,
              Cheq_Favor_Dets__c,
              Remarks__c,
              Cheq_Favor_Acc_No__c,
              Benef_Nm_of_Penny_Drop__c,
              DisburseRela__c,
              Payment_to__c,
              RefId__c,
              RemitterAccNo__c,
              BeneficiaryAccNo__c,
              UTR__c,
              ResponseReason__c,
              CashBankAccountId__c,
              OpsVer__c,
              DisburseAmt__c
            FROM Split_Disbursements__r
          )
        FROM Disbursement__c
        WHERE Loan_Appli__c = :loanId
      ];

      Map<Id, Applicant__c> appMap = new Map<Id, Applicant__c>(
        [
          SELECT
            Id,
            CustProfile__c,
            Constitution__c,
            Type_of_Borrower__c,
            TabName__c,
            FullName__c,
            UCID__c,
            OTP_Verified__c,
            Is_Physical_Consent_Validated__c,
            ApplType__c,
            PAN__c,
            (
              SELECT
                id,
                DocCatgry__c,
                DocTyp__c,
                DocSubTyp__c,
                TargetDt__c,
                DocStatus__c,
                Applicant_KYC__r.kycDoc__c,
                Applicant_KYC__r.AadharNo__c,
                Applicant_KYC__r.DLNo__c,
                Applicant_KYC__r.PassNo__c,
                Applicant_KYC__r.VotIdEpicNo__c,
                Applicant_KYC__r.OtherDocName__c,
                Applicant_KYC__r.Pan__c
              FROM Applicant_Document_Details__r
              WHERE
                DocTyp__c = 'Residence Address proof - OVD'
                OR DocTyp__c = 'Residence Address proof - Deemed OVD'
                OR DocTyp__c = 'Disbursal Documents'
                OR DocCatgry__c = 'Insurance documents'
                OR DocCatgry__c = 'PAN Documents'
            )
          FROM Applicant__c
          WHERE LoanAppln__c = :loanId AND ApplType__c IN ('P', 'C', 'G')
        ]
      );
      /* LAK-6286- Paresh Drop1-A*/

      list<Applicant_Income__c> appIncomeList = [
        SELECT id, Applicant__c, RecordType.DeveloperName
        FROM Applicant_Income__c
        WHERE
          RecordType.DeveloperName = 'BankCrSal'
          AND Applicant__c != NULL
          AND Applicant__r.LoanAppln__c = :loanId
          AND Applicant__r.CustProfile__c = 'SALARIED'
      ];

      Map<Id, list<Applicant_Income__c>> appIncMap = new Map<Id, list<Applicant_Income__c>>();
      if (!appIncomeList.isEmpty()) {
        for (Applicant_Income__c appInc : appIncomeList) {
          if (appIncMap.containskey(appInc.Applicant__c)) {
            appIncMap.get(appInc.Applicant__c).add(appInc);
          } else {
            appIncMap.put(
              appInc.Applicant__c,
              new List<Applicant_Income__c>{ appInc }
            );
          }
        }
      }
      list<ApplBanking__c> appBankingList = new List<ApplBanking__c>(
        [
          SELECT Id, Appl__c, LoanAppl__c, SalaryAccount__c
          FROM ApplBanking__c
          WHERE Appl__c IN :appIncMap.keySet()
        ]
      );
      Map<Id, list<ApplBanking__c>> appBankingMap = new Map<Id, list<ApplBanking__c>>();
      if (!appBankingList.isEmpty()) {
        for (ApplBanking__c appBank : appBankingList) {
          if (appBankingMap.containskey(appBank.Appl__c)) {
            appBankingMap.get(appBank.Appl__c).add(appBank);
          } else {
            appBankingMap.put(
              appBank.Appl__c,
              new List<ApplBanking__c>{ appBank }
            );
          }
        }
      }

      if (appMap.size() < 2) {
        errors.add('No Coapplicant Found');
      }
      SchMapping__c schemeMaping = new SchMapping__c();
      if (loan != null && loan.SchemeId__c != null) {
        schemeMaping = [
          SELECT Id, ApplicableOwnContribution__c, IsFixed__c
          FROM SchMapping__c
          WHERE Id = :loan.SchemeId__c
          LIMIT 1
        ];
      }
            system.debug('## loan.OwnContriCash__c'+loan.OwnContriCash__c);
      if (
        loan.Stage__c == 'Post Sanction' &&
        schemeMaping.ApplicableOwnContribution__c
      ) {
        if (loan.OwnContriCash__c == null) {
          errors.add(
            'Mandatory fields on Loan details are not entered. Please complete all required fields.'
          );
        }
      }

      if (
        (loan.Stage__c == 'DDE' || loan.Stage__c == 'Post Sanction') &&
        (loan.subStage__c == 'CPA Data Entry' ||
        loan.subStage__c == 'Query' ||
        loan.subStage__c == 'Data Entry' ||
                 loan.subStage__c == 'Ops Query' ||
        loan.subStage__c == 'CPA Vendor Data Entry')
      ) {
        if (
          coutTrackers.size() == 0 ||
          (coutTrackers.size() > 0 && coutTrackers[0].IsInvalid__c)
        ) {
          errors.add('Kindly run BRE before Forwarding the LAN');
        }
        Map<id, string> pddDocErrorMap = new Map<id, string>();
       
        list<DocDtl__c> pddDocPresent = new  list<DocDtl__c>();
        for (Applicant__c app : appMap.values()) {
          if (String.isBlank(app.UCID__c)) {
            errors.add(
              'UCID is not generated for ' +
                app.FullName__c +
                '. Please generate the UCID before forwarding to Underwriter.'
            );
          }

          if (!app.Applicant_Document_Details__r.isEmpty()) {
            boolean hasResAddOVD = false;
            boolean hasPDDdoc = false;
            boolean hasTargetDateOut = false;
            boolean aadharConcenterror = false;
            for (DocDtl__c dd : app.Applicant_Document_Details__r) {
              if (dd.DocTyp__c == 'Residence Address proof - OVD') {
                Boolean showError = false;
                string docName = dd.Applicant_KYC__r.kycDoc__c;
                if (
                  docName == 'Driving License' &&
                  dd.Applicant_KYC__r.DLNo__c == null
                ) {
                  showError = true;
                } else if (
                  docName == 'Aadhaar' &&
                  dd.Applicant_KYC__r.AadharNo__c == null
                ) {
                  showError = true;
                } else if (
                  docName == 'Voter Id' &&
                  dd.Applicant_KYC__r.VotIdEpicNo__c == null
                ) {
                  showError = true;
                } else if (
                  docName == 'Passport' &&
                  dd.Applicant_KYC__r.PassNo__c == null
                ) {
                  showError = true;
                }
                // Pan Missing Validation
                else if(dd.DocCatgry__c == 'PAN Documents' && dd.Applicant_KYC__r.Pan__c != null && app.PAN__c == null){
                  errors.add(
                      app.FullName__c +
                      ' : ' +
                      'Something went wrong while updating PAN, Kindly Upload/Validate PAN Again!'
                  );
              }
                if (showError) {
                  errors.add(
                    app.FullName__c +
                      ' : ' +
                      System.Label.Documents_Id_Number_Is_Missing_For_OVD
                  );
                }
              }
              // LAK-6491
              if (
                loan.Stage__c == 'Post Sanction' &&
                (loan.subStage__c == 'Data Entry' ||
                loan.subStage__c == 'Ops Query') &&
                dd.DocTyp__c == 'Disbursal Documents' 
                && app.ApplType__c =='P' // &&
                && dd.DocSubTyp__c.contains('RESIDENCE ADDRESS PROOF - OVD')
                
              ) {
                pddDocPresent.add(dd);
              }
              if (
                loan.Stage__c == 'Post Sanction' &&
                (loan.subStage__c == 'Data Entry' ||
                loan.subStage__c == 'Ops Query') &&
                dd.DocTyp__c == 'Residence Address proof - Deemed OVD' &&
                dd.DocSubTyp__c == 'Aadhaar Acknowledgment for address change'
              ) {
                aadharConcenterror = true;
                
                for (DocDtl__c ddd : app.Applicant_Document_Details__r) {
                  if (ddd.DocTyp__c == 'Residence Address proof - OVD') {
                    //hasResAddOVD = true;
                  }else{
                    pddDocErrorMap.put(app.Id,'Pdd Required');
                  }
              
                }
              }         
            }
          
          }
          if (appIncMap != null && appBankingMap.get(app.Id) != null) {
            if (appBankingMap != null) {
              if (appBankingMap.containsKey(app.Id)) {
                boolean salaryAccNotPresent = true;
                for (ApplBanking__c appBank : appBankingMap.get(app.Id)) {
                  if (appBank.SalaryAccount__c == true) {
                    salaryAccNotPresent = false;
                    break;
                  }
                }
                if (salaryAccNotPresent) {
                  errors.add(
                    app.FullName__c +
                      ' : ' +
                      System.Label.BankingDetails_SalaryAcc_ErrorMessage
                  );
                }
              } else {
              }
            }
          }
        }
        // LAK-6491
          if(pddDocErrorMap.size()> 0 ){
          integer noOfPddReq = pddDocErrorMap.size() - pddDocPresent.size(); 
          if(noOfPddReq >0 ){
            errors.add( noOfPddReq + ' RESIDENCE ADDRESS PROOF - OVD / PDD Documents Required for Applicant/Co-Applicants '  );
          }
         
          if(pddDocPresent.size() >0){
            for(DocDtl__c dd : pddDocPresent){
                   if (dd.TargetDt__c == null && dd.DocStatus__c == 'PDD') {
                    
                      errors.add(
                  dd.DocSubTyp__c +
                   ' : ' +
                    'Disbursal Documents not updated properly on NDC ( Target Date (30 Days)/ Document Status ( PDD ))'
                );
                    } else if (
                      dd.TargetDt__c != null &&
                      dd.DocStatus__c == 'PDD' &&
                      Date.today().daysBetween(dd.TargetDt__c) > 30 //LAK-8260
                    ) {
                     
                      errors.add(
                        dd.DocSubTyp__c +
                    ' : ' +
                    'Disbursal Documents not updated properly on NDC ( Target Date (30 Days) / Document Status ( PDD ))'
                );
                    }
            }
          }
           // LAK-6491
          }
        // Bureau Changes Started
        Set<String> appIds = new Set<String>();
        Map<String, Integer> appWithBureau = new Map<String, Integer>();
                system.debug('##bureauRespnses'+bureauRespnses);
        if (bureauRespnses != null && bureauRespnses.size() > 0) {
          for (Bureau__c burea : bureauRespnses) {
            if (
              String.isBlank(burea.ErrorMess__c) || burea.ErrorMess__c == null
            ) {
                            system.debug('## here');
              // appIds.add(burea.Applicant__r.Id);
              if (appWithBureau.containsKey(burea.Applicant__c)) {
                Integer count = appWithBureau.get(burea.Applicant__c);
                count++;
                appWithBureau.put(burea.Applicant__c, count);
              } else {
                appWithBureau.put(burea.Applicant__c, 1);
              }
            }
          }
        }
        for (Applicant__c app : appMap.values()) {
                    system.debug('## app'+app);
          if (app.Constitution__c == 'INDIVIDUAL') {
            Integer res = appWithBureau.get(app.Id);
                        system.debug('## res'+res);
            if (res <= 0 || res == null) {
              errors.add('Please Run the Bureau for ' + app.FullName__c);
            }
          }
        }
        // Bureau Changes Ended
      }

      //LAK-8619 added data entry check 
      if (loan.Stage__c == 'Post Sanction' && (loan.subStage__c == 'Ops Query' || loan.subStage__c == 'Data Entry')) {
        Set<String> sectionNames = new Set<String>();
        Set<String> screenNames = new Set<String>();

        Boolean opsQuery = false;
        for (NDC__c ndc : [
          SELECT Id, OpsQuery__c, ScreenNames__c, NDC_Section__c
          FROM NDC__c
          WHERE LoanAppl__c = :loanId AND IsInvalid__c = FALSE
        ]) {
          if (ndc.OpsQuery__c) {
            // opsQuery = true;
            if (ndc.ScreenNames__c != null) {
              screenNames.add(ndc.ScreenNames__c);
            } else if (ndc.NDC_Section__c != null) {
              sectionNames.add(ndc.NDC_Section__c);
            }
          }
        }
        if (screenNames != null && screenNames.size() > 0) {
          string allstring = string.join(screenNames, ',');
          errors.add(
            'Please respond on Query Before Sending the Application back to Ops : (' +
              allstring +
              ')'
          );
        }
        if (sectionNames != null && sectionNames.size() > 0) {
          string allstring = string.join(sectionNames, ',');
          errors.add(
            'Please respond on Query Before Sending the Application back to Ops : (' +
              allstring +
              ')'
          );
        }
      }

      if (
        (loan.Stage__c == 'DDE' &&
        (loan.subStage__c == 'CPA Data Entry' ||
                  loan.subStage__c == 'Query' || loan.subStage__c == 'CPA Vendor Data Entry')) ||
        (loan.Stage__c == 'Post Sanction' &&
        (loan.subStage__c == 'Data Entry' ||
        loan.subStage__c == 'Ops Query') ||
        (loan.Stage__c == 'Disbursed' &&
        loan.subStage__c == 'Additional Processing'))
      ) {
        List<ValidateRequiredFieldsAndDoc.Responce> valRespData = ValidateRequiredFieldsAndDoc.getValidationReport(
          loanId
        );

        for (ValidateRequiredFieldsAndDoc.Responce res : valRespData) {
          System.debug('res is' + res);
          if (res.validated == false) {
            String resp = res.applicantName + ' : ' + res.errorMessage;
            if (res.missingDoc == true) {
              resp =
                res.applicantName +
                ' : ' +
                res.errorMessage +
                ' : [ ' +
                res.missingValue +
                ' ]';
              // Map<String, List<String>> missingDocMap = missingSubDocValue;
            }
            errors.add(resp);
          }
        }
      }

      //FOR LAK-6233
      if (
        (loan.Stage__c == 'Post Sanction' &&
        (loan.SubStage__c == 'Data Entry' ||
        loan.SubStage__c == 'Ops Query')) ||
        (loan.Stage__c == 'Disbursed' &&
        loan.subStage__c == 'Additional Processing')
      ) {
        if (disburseList != null && disburseList.size() > 0) {
          disburseList.sort(new DisbursementComparator());
          Disbursement__c highestDisbursement = disburseList[
            disburseList.size() - 1
          ];
          Integer listIterator = 0;
          for (Disbursement__c disurse : disburseList) {
            listIterator = listIterator + 1; // Index 0 iterate 1, Index 1 interate 2, Index 2 Iterator 3
            if (
              disurse.Total_Disb_Amt__c != null &&
              String.isNotBlank(disurse.Disbur_To__c) &&
              ((String.isNotBlank(disurse.Princ_Rec_on__c) &&
              disurse.Princ_Start_Date__c != null &&
              loan.DisbursalType__c == 'MULTIPLE') ||
              loan.DisbursalType__c == 'SINGLE') &&
              disurse.Date_of_Disbur__c != null &&
              String.isNotBlank(disurse.DisbrDiscription__c)
            ) {
              if (
                disurse.Date_of_Disbur__c < Date.today() &&
                (disurse.Disbur_Status__c != 'DISBURSED' &&
                disurse.Disbur_Status__c != 'PARTIALLY DISBURSED' &&
                disurse.Disbur_Status__c != 'INITIATED')
              ) {
                errors.add('Date of Disbursement(s) cannot be past date.');
                break;
              }

              if (String.isEmpty(disurse.Loan_Appli__r.DisbursalType__c)) {
                errors.add('Disbursal Type missing for the Loan Application.');
                break;
              } else if (disurse.Loan_Appli__r.DisbursalType__c == 'MULTIPLE') {
                if (listIterator < disburseList.size()) {
                  if (
                    disurse.Date_of_Disbur__c != null &&
                    disburseList[listIterator].Date_of_Disbur__c != null
                  ) {
                    if (
                      disurse.Date_of_Disbur__c >=
                      disburseList[listIterator].Date_of_Disbur__c
                    ) {
                      errors.add(
                        'Date of Disbursement(s) are not in progressive order.'
                      );
                      break;
                    }
                  } else {
                    errors.add(
                      'Date of Disbursement(s) missing for the record(s).'
                    );
                    break;
                  }
                }

                if (
                  disurse.Princ_Start_Date__c != null &&
                  highestDisbursement.Princ_Start_Date__c != null
                ) {
                  if (
                    disurse.Princ_Start_Date__c !=
                    highestDisbursement.Princ_Start_Date__c ||
                    disurse.Princ_Start_Date__c <
                    highestDisbursement.Date_of_Disbur__c
                  ) {
                    errors.add(
                      'Principle Start Date(s) not correct for the record(s).'
                    );
                    break;
                  }
                } else {
                  errors.add(
                    'Principle Start Date(s) missing for the record(s)'
                  );
                  break;
                }
              }

              if (disurse.DisbrDiscription__c == 'TRANCHE-1') {
                if (
                  disurse.Split_Disbursements__r != null &&
                  disurse.Split_Disbursements__r.size() > 0
                ) {
                  for (
                    Split_Disbur__c splitDis : disurse.Split_Disbursements__r
                  ) {
                    if (
                      String.isEmpty(splitDis.Pay_Mode__c) ||
                      String.isEmpty(splitDis.Disbur_To__c) ||
                      splitDis.Split_Cheque_Amt__c == null ||
                      String.isEmpty(splitDis.Fedbank_Acc_Nm__c) ||
                      String.isEmpty(splitDis.Payable_At__c)
                    ) {
                      errors.add(
                        'Tranche and Multi Tranche details has to be mandatorily filled. Atleast one Split Disbursal row has to be there.'
                      );
                      break;
                    } else {
                      if (
                        (splitDis.Pay_Mode__c == 'Cheque' ||
                        splitDis.Pay_Mode__c == 'Draft' ||
                        splitDis.Pay_Mode__c == 'Funds Transfer') &&
                        (splitDis.Cheq_DD_Date__c == null ||
                        splitDis.Cheq_DD_No__c == null)
                      ) {
                        errors.add(
                          'Tranche and Multi Tranche details has to be mandatorily filled. Atleast one Split Disbursal row has to be there.'
                        );
                        break;
                      }
                    }
                  }
                } else {
                  errors.add(
                    'Tranche and Multi Tranche details has to be mandatorily filled. Atleast one Split Disbursal row has to be there.'
                  );
                  break;
                }
              }
            } else {
              errors.add(
                'Tranche and Multi Tranche details has to be mandatorily filled. Atleast one Split Disbursal row has to be there.'
              );
              break;
            }
          }
        }

        //LAK-6401
        if (
          rcuCases != null &&
          rcuCases.size() > 0 &&
          rcuCases[0].ReportResult__c == 'Pending'
        ) {
          if (postSanAutoDevRecrds.size() == 0) {
            errors.add(
              'RCU status is Pending. Kindly add applicable deviation'
            );
          }
        }
        //LAK-6401
      }
        //LAK-551
        if (
        loan.Stage__c == 'Post Sanction' &&
        (loan.SubStage__c == 'Data Entry' ||
        loan.SubStage__c == 'Ops Query')
        ) {
            boolean tsrStatus = false;
            list<Case> lstCases = [SELECT id,FinalStatusTSRReportFromHLM__c,WaiveCPV__c from Case where Loan_Application__c =:loanId AND RecordType.DeveloperName ='TSR' AND ApplAssetId__c != NULL AND WaiveCPV__c !='Yes' ORDER By CreatedDate DESC LIMIT 1]; 
             if(!lstCases.isEmpty()){
                 for(Case c : lstCases){
                if(c.FinalStatusTSRReportFromHLM__c != 'Positive'){
                    tsrStatus =true;
                }
            }
            }
            if (tsrStatus) {
            errors.add(
              'TSR Report Result must be positive.'
            );
          }

                          //LAK-9154
                          list<APIVer__c> lgitationList = [
                            SELECT
                            Id,
                            RiskType__c,
                            LoanAplcn__c,
                            Appl__c,
                            Appl__r.FullName__c
                            FROM APIVer__c
                            WHERE LoanAplcn__c = :loanId AND RecordType.DeveloperName = 'CrimeCheck' AND IsLatest__c  = True
                        ];
                        
                                system.debug('ligit.loanId'+ loanId);
                                system.debug('ligit.lgitationList :'+ lgitationList);
        
                        if (lgitationList == null || lgitationList.size() == 0) {
                                        errors.add('Please Initiate Litigation check API before forwarding the Loan Application');
                                    }
        
                        //Changes Ended for LAK-9154
        }

          //LAK-552
          //  ORDER By CreatedDate DESC LIMIT 1 added for LAK-8800
        if (
        loan.Stage__c == 'Post Sanction' &&
        (loan.SubStage__c == 'Data Entry' ||
        loan.SubStage__c == 'Ops Query')
        ) {
            boolean tsrStatus = false;
            list<Case> lstCases = [SELECT id,FinalStatusTSRReportFromHLM__c,WaiveCPV__c from Case where Loan_Application__c =:loanId AND RecordType.DeveloperName ='Vetting' AND WaiveCPV__c !='Yes' ORDER By CreatedDate DESC LIMIT 1]; 
             if(!lstCases.isEmpty()){
                 for(Case c : lstCases){
                if(c.FinalStatusTSRReportFromHLM__c != 'Positive'){
                    tsrStatus =true;
                }
            }
            }
            if (tsrStatus) {
                    // errors.add('Vetting Report Result must be positive.'  );
                }
            }
            
            //changes for 9389
            if (
                loan.Stage__c == 'Post Sanction' &&
                (loan.SubStage__c == 'Data Entry')
            ){
                List<LoanAppl__c> ln = new List<LoanAppl__c>(
                    [
                        SELECT
                        Id,
                        SchemeId__c, SchmCode__c
                        FROM LoanAppl__c
                        WHERE
                        Id = :loanId]);
                SchMapping__c schemeMaping1 = new SchMapping__c();
                if (!ln.isEmpty() && ln[0].SchemeId__c != null) {
                    schemeMaping1 = [
                        SELECT
                        Id,SchmId__c,
                        SchemeDesc__c,
                        Verification_Initiation__c
                        FROM SchMapping__c
                        WHERE Id = :ln[0].SchemeId__c
                        LIMIT 1
                    ];
                }
                list<DocDtl__c>  DocDtl = new list<DocDtl__c> ();
                if (!ln.isEmpty() ) {
                    DocDtl = [
                        select id ,LAN__c, DocStatus__c,DocTyp__c,DocSubTyp__c, DocCatgry__c from DocDtl__c where LAN__c =:loanId and DocStatus__c in ('OTC','PDD') and DocTyp__c='Disbursal Documents' and DocSubTyp__c='Vetting report by Lawyer'
                        
                    ];
                }               
                list<Case> lstCases = [SELECT id,FinalStatusTSRReportFromHLM__c,WaiveCPV__c,Status from Case where Loan_Application__c =:loanId AND RecordType.DeveloperName ='Vetting'  and ApplAssetId__c!=null ORDER By CreatedDate DESC ]; 
                
                
                if (schemeMaping1 != null && (schemeMaping1.Verification_Initiation__c != null && 
                                              schemeMaping1.Verification_Initiation__c.contains('Vetting Post Disbursement'))){
                                                  if (!DocDtl.isEmpty()){
                                                      boolean isOtcRecordPresent = true;
                                                      boolean isPddRecordPresent = true;
                                                      for (DocDtl__c record : DocDtl) {
                                                          if (record.DocStatus__c == 'OTC') {
                                                              isOtcRecordPresent = false;
                                                          } else if (record.DocStatus__c == 'PDD') {
                                                              isPddRecordPresent=false;
                                                          }                            
                                                      }
                                                      /*if(isOtcRecordPresent){
errors.add('There Should be OTC Document added in NDC.');
}
if(isPddRecordPresent){
errors.add('There Should be PDD Document added in NDC.');
}*/
                                                      if(isOtcRecordPresent && isPddRecordPresent){
                                                          errors.add('Kindly add Vetting report as OTC/PDD since vetting is not closed.');
                                                      }
                                                  }
                                                   else{
                                                           errors.add('Kindly add Vetting report as OTC/PDD since vetting is not closed.');
                                                      }
                                              }
                else{
                    if(!lstCases.isEmpty()){
                        for(Case c : lstCases){
                            if(c.WaiveCPV__c  != 'Yes'){
                                if(c.Status  != 'Closed'){
                                   // errors.add('Kindly add Vetting report as OTC/PDD since vetting is not closed.');
                                    if (!DocDtl.isEmpty()){
                                                      boolean isOtcRecordPresent = true;
                                                      boolean isPddRecordPresent = true;
                                                      for (DocDtl__c record : DocDtl) {
                                                          if (record.DocStatus__c == 'OTC') {
                                                              isOtcRecordPresent = false;
                                                          } else if (record.DocStatus__c == 'PDD') {
                                                              isPddRecordPresent=false;
                                                          }                            
                                                      }
                                                     
                                                      if(isOtcRecordPresent && isPddRecordPresent){
                                                          errors.add('Kindly add Vetting report as OTC/PDD since vetting is not closed.');
                                                      }
                                                  }
                                                   else{
                                                           errors.add('Kindly add Vetting report as OTC/PDD since vetting is not closed.');
                                                      }
                                }
                                
                            }
                            if(c.Status  != 'Closed'){
                               // errors.add('Kindly add Vetting report as OTC/PDD since vetting is not closed.');
                                if (!DocDtl.isEmpty()){
                                                      boolean isOtcRecordPresent = true;
                                                      boolean isPddRecordPresent = true;
                                                      for (DocDtl__c record : DocDtl) {
                                                          if (record.DocStatus__c == 'OTC') {
                                                              isOtcRecordPresent = false;
                                                          } else if (record.DocStatus__c == 'PDD') {
                                                              isPddRecordPresent=false;
                                                          }                            
                                                      }
                                                      
                                                      if(isOtcRecordPresent && isPddRecordPresent){
                                                          errors.add('Kindly add Vetting report as OTC/PDD since vetting is not closed.');
                                                      }
                                                  }
                                                   else{
                                                           errors.add('Kindly add Vetting report as OTC/PDD since vetting is not closed.');
                                                      }
                            }
                        }
                    }else{
                        errors.add('Vetting Should be Initiated.');
                    }
                }
            }
 //LAK-9422
 if (
    loan.Stage__c == 'Post Sanction' &&
    (loan.SubStage__c == 'Data Entry')
){
    list<DocDtl__c>  docDtlList = new list<DocDtl__c> ();
    docDtlList = [select id ,LAN__c,DocSubTyp__c, DocStatus__c, DocCatgry__c from DocDtl__c where LAN__c =:loanId and DocStatus__c in ('OTC')
                  AND DocSubTyp__c in ('RCU Report for Pre sanction documents','RCU Report for Post sanction documents') ];
    list<Case> lstRcuCases = [SELECT id,RecordType.DeveloperName,Status from Case where Loan_Application__c =:loanId AND RecordType.DeveloperName ='RCU' ORDER By CreatedDate DESC ];
              boolean rcuNotClosed=true;
    if(!lstRcuCases.isEmpty()){
        for(Case c : lstRcuCases){
                    if(c.Status  == 'Closed'){
                       rcuNotClosed=false;
            }                   
                    
        }
    }else{
        errors.add('RCU Should be Initiated.');
    }
    if(rcuNotClosed && docDtlList.isEmpty()){
        errors.add('For RCU Cases: Please add OTC document on NDC.');
    } 
            }
            //LAK-113
        if (
        loan.Stage__c == 'Post Sanction' &&
        (loan.SubStage__c == 'Data Entry' ||
        loan.SubStage__c == 'Ops Query')
        ) {
            boolean legalStatus = false;
            list<Case> lstCases = [SELECT id,FinalStatusTSRReportFromHLM__c,WaiveCPV__c from Case where Loan_Application__c =:loanId AND RecordType.DeveloperName ='Legal' AND WaiveCPV__c !='Yes' ORDER By CreatedDate DESC LIMIT 1]; 
             if(!lstCases.isEmpty()){
                 for(Case c : lstCases){
                if(c.FinalStatusTSRReportFromHLM__c != 'Positive'){
                    legalStatus =true;
                }
            }
            }
            if (legalStatus) {
            errors.add(
              'Legal Report Result must be positive.'
            );
          }
        }
        
  			// Hunter LAK-10088
                if (loan.Stage__c == 'Post Sanction' && (loan.SubStage__c == 'Data Entry')) {
                List<HunterVer__c> hunterList = [
                    SELECT Id, HunMatchSta__c, HunterStatWhereMatchFound__c,FraudStatusDescription__c,WorkStatusDescription__c
                    FROM HunterVer__c
                    WHERE LoanAplcn__c = :loanId AND IsLatest__c = TRUE
                ];
                if (hunterList != null && hunterList.size() > 0) {
                    for (HunterVer__c hunter : hunterList) {
                        if (
                            string.isNotBlank(hunter.HunMatchSta__c) &&
                            hunter.HunMatchSta__c.toLowerCase() == 'match' &&
                            string.isBlank(hunter.FraudStatusDescription__c) &&
                            string.isBlank(hunter.WorkStatusDescription__c)
                        ) {
                            errors.add('Hunter status and RCU manager feedback fields should be filled');
                        }
                    }
                }      
            }
      //FOR LAK-6233
      if (
        loan.Stage__c == 'Post Sanction' &&
        (loan.SubStage__c == 'Data Entry' ||
        loan.SubStage__c == 'Ops Query')
      ) {
        Boolean isFT = false;
        List<DocDtl__c> otcDocs = [
          SELECT Id, DocStatus__c
          FROM DocDtl__c
          WHERE LAN__c = :loanId AND DocStatus__c = 'OTC'
        ];
        if (otcDocs != null && otcDocs.size() > 0) {
          List<Split_Disbur__c> allSplits = [
            SELECT Id, Pay_Mode__c
            FROM Split_Disbur__c
            WHERE DisburseRela__r.Loan_Appli__c = :loanId
          ];
          for (Split_Disbur__c spd : allSplits) {
            if (spd.Pay_Mode__c == 'Funds Transfer') {
              isFT = true;
            }
          }
          if (isFT) {
            errors.add(
              'Fund Transfer is not applicable for OTC , So Please Change Payment Mode.'
            );
          }
        }

        List<DocumentCheckController.DocDetailWrapper> ndcDocs = DocumentCheckController.ndcDocumentCheck(
          loanId
        );
        if (ndcDocs != null && ndcDocs.size() > 0) {
          for (DocumentCheckController.DocDetailWrapper item : ndcDocs) {
            errors.add(
              item.docCategry +
                ' : Please Upload Document For ' +
                item.docDetName +
                ' on Ndc Screen.'
            );
          }
        }

        List<ApplIMD__c> allIMDs = [
          SELECT Id, BRECheqClrStatus__c, PaymentMode__c, FinnoneChequeId__c
          FROM ApplIMD__c
          WHERE
            LoanAppln__c = :loanId
            AND PaymentMode__c IN ('DD', 'Cheque', 'Payment Gateway')
        ];
        for (ApplIMD__c item : allIMDs) {
          if (item.PaymentMode__c != null) {
            if (
              item.PaymentMode__c == 'Payment Gateway' &&
              String.isEmpty(item.FinnoneChequeId__c)
            ) {
              errors.add('LMS Update is not done For Payment Gateway');
              break;
            }
            if (
              (item.PaymentMode__c == 'DD' ||
              item.PaymentMode__c == 'Cheque') &&
              String.isEmpty(item.BRECheqClrStatus__c)
            ) {
              errors.add('IMD Payment Status For Cheque OR DD is Blank.');
              break;
            }
          }
        }

        List<DocDtl__c> sanLetter = [
          SELECT Id, DocStatus__c, isLatest__C
          FROM DocDtl__c
          WHERE LAN__c = :loanId AND DocCatgry__c = 'Sanction Letter' and isLatest__C=true
        ];
               
        if (sanLetter.size() == 0 || loan.DocGenReRequired__c) {
          errors.add('Please Generate Sanction Letter And KFS Document.');
        }
        List<DocDtl__c> LoanAgreeLetter = [
                    SELECT Id, DocStatus__c, DocTyp__c, isLatest__C
                    FROM DocDtl__c
                    WHERE LAN__c = :loanId AND DocSubTyp__c = 'Loan Agreement' and DocCatgry__c='System Generated Documents' and isLatest__C=true
                ]; 
                if (LoanAgreeLetter.size() == 0 || loan.Disbursal_Document_Required__c) {
                    errors.add('Please Generate Disbursal Documents.');
                }
                List<DocDtl__c> LoanAppliLetter = [
                    SELECT Id, DocStatus__c, DocTyp__c, isLatest__C
                    FROM DocDtl__c
                    WHERE LAN__c = :loanId AND DocSubTyp__c = 'Application Form' and DocCatgry__c='System Generated Documents' and isLatest__C=true
                ]; 
                if (LoanAppliLetter.size() == 0 || loan.App_Form_End_Use_Letter_Doc_Required__c) {
                    errors.add('Please Generate Application Form.');
                }
                if (loan.Is_E_Stamp_Done__c ==false) {
                    errors.add('Please Complete E-Stamp/Physical Stamp.');
                }
                if (loan.Is_E_Sign_Physical_Done__c ==false) {
                    errors.add('Please Complete E-Sign/Physical Sign.');
                }

                
        if (loan.Final_Loan_Disbursal_Amount__c != loan.DisbursedAmount__c) {
          errors.add(
            'Sum of Disbursement Amount mismatched with Loan Disbursal Amount.'
          );
        }
        for (Disbursement__c disb : disburseList) {
          if (
            disb.Split_Disbursements__r.size() > 0 &&
            disb.Total_Disb_Amt__c != disb.Split_Disbursement_s_Amount__c
          ) {
            errors.add(
              'Sum of all Split Disbursal Cheque Amount should be equal to Disbursal Amount.'
            );
            break;
          }
        }

        List<String> expiryList = VerificationExpiry.expiryDetail(loanId);
        if (expiryList != null && expiryList.size() > 0) {
          for (String expName : expiryList) {
            errors.add(expName + ' is expired');
          }
        }
        List<PDC__c> pdcList = [
          SELECT
            Loan_Application__c,
            Cheque_Amount__c,
            Cheque_Number_To__c,
            Cheque_Number_From__c,
            No_of_Cheques__c,
            Cheque_Purpose__c,
            Account_No__c,
            MICR_Code__c
          FROM PDC__c
          WHERE
            PDC_Type__c = 'SPDC'
            AND Loan_Application__c = :loanId
            AND Repayment_Account__r.Is_Active__c = TRUE
        ];
        if (pdcList != null && pdcList.size() > 0) {
          Decimal checkCount = 0;
          for (PDC__c pdc : pdcList) {
            if (pdc.No_of_Cheques__c != null) {
              checkCount += pdc.No_of_Cheques__c;
            }
            if (
              String.isBlank(pdc.Cheque_Number_To__c) ||
              String.isBlank(pdc.Cheque_Number_From__c) ||
              pdc.Cheque_Amount__c == null ||
              String.isBlank(pdc.MICR_Code__c) ||
              String.isBlank(pdc.Cheque_Purpose__c) ||
              String.isBlank(pdc.Account_No__c)
            ) {
              errors.add(
                'Please provide all required information for SPDC on Repayment Screen.'
              );
              break;
            }
          }
          if (checkCount < 3) {
            errors.add('Atleast 3 No Of Cheques should be in SPDC');
          }
        } else {
          errors.add(
            'Atleast 1 SPDC record should be there on Repayment Screen'
          );
        }
      }
      // for LAK-6330 // UW | Credit Appraisal | The user is able to proceed to UW Credit Appraisal without filling up the Regulatory Details.
      Map<Id, list<ApplRegltry__c>> appRegMap = new Map<Id, list<ApplRegltry__c>>();
      list<ApplRegltry__c> appRegList = [
        SELECT
          Id,
          LoanAppln__c,
          Appl__c,
          IsBorowrOrRelFFDir__c,
          FFDirRelIntrstAsSH__c,
          FFDirRelIntrstAsPart__c,
          IsUwVerified__c,
          (
            SELECT Id, name, DirName__c, Desgntn__c, Reltnshp__c
            FROM Regulatory_Personnel__r
          )
        FROM ApplRegltry__c
        WHERE LoanAppln__c = :loanId
        ORDER BY createdDate DESC
      ];

      boolean addError = false;
      if (!appRegList.isEmpty()) {
        for (id app : appMap.keySet()) {
          if (appMap.get(app).Constitution__c == 'INDIVIDUAL') {
            if (appRegList[0].IsBorowrOrRelFFDir__c == null) {
              addError = true;
              break;
            }
          }
          if (
            appMap.get(app).Constitution__c != 'INDIVIDUAL' &&
            (appMap.get(app).Constitution__c != 'PRIVATE LIMITED COMPANY' &&
            appMap.get(app).Constitution__c != 'PUBLIC LIMITED COMPANY')
          ) {
            if (appRegList[0].FFDirRelIntrstAsSH__c == null) {
              addError = true;
              break;
            }
          }
          if (
            appMap.get(app).Constitution__c != 'INDIVIDUAL' &&
            (appMap.get(app).Constitution__c == 'PRIVATE LIMITED COMPANY' ||
            appMap.get(app).Constitution__c == 'PUBLIC LIMITED COMPANY')
          ) {
            if (appRegList[0].FFDirRelIntrstAsPart__c == null) {
              addError = true;
              break;
            }
          }
        }
      } else {
        addError = true;
      }

      if (addError == false) {
        if (
          appRegList[0].IsBorowrOrRelFFDir__c == 'Yes' ||
          appRegList[0].FFDirRelIntrstAsSH__c == 'Yes' ||
          appRegList[0].FFDirRelIntrstAsPart__c == 'Yes'
        ) {
          if (!appRegList[0].Regulatory_Personnel__r.isEmpty()) {
            for (
              RegltryPrsonl__c regPerson : appRegList[0].Regulatory_Personnel__r
            ) {
              if (
                regPerson.DirName__c == null ||
                regPerson.Desgntn__c == null ||
                regPerson.Reltnshp__c == null
              ) {
                addError = true;
                break;
              }
            }
          } else {
            addError = true;
          }
        }
      }

      if (addError) {
        errors.add(
          'Mandatory fields on Regulatory details not entered. Please provide all required information.'
        );
      }

      if (
        (loan.Stage__c == 'Post Sanction' && loan.subStage__c == 'Ops Query') ||
        (loan.Stage__c == 'Disbursed' &&
        loan.subStage__c == 'Additional Processing')
      ) {
        if (loan.PendingDisbursalAmount__c != 0) {
          errors.add('Pending Disbursal amount should be 0');
        }
      }

      if (loan.Stage__c == 'Post Sanction' && loan.subStage__c == 'Ops Query') {
        if (loan.EffectiveNextIntStartDt__c < Date.today()) {
          errors.add(
            'Effective/interest date should be equal to Today Date/Future Date'
          );
        }
        List<Disbursement__c> firstTracncheDets = [
          SELECT Id, Date_of_Disbur__c
          FROM Disbursement__c
          WHERE Loan_Appli__c = :loanId AND DisbrDiscription__c = 'TRANCHE-1'
        ];

        if (
          firstTracncheDets != null &&
          firstTracncheDets.size() > 0 &&
          firstTracncheDets[0].Date_of_Disbur__c != Date.today()
        ) {
          errors.add(
            'First Tranche Date of Disbursement should be Equal to today date'
          );
        }
      }
      //Enach Rejection Reason Validation
      if (
        loan.Stage__c == 'Post Sanction' &&
        (loan.subStage__c == 'Ops Query' ||
        loan.subStage__c == 'Data Entry')
      ) {
        List<DocDtl__c> otherImpDocs = [
          SELECT
            Id,
            OpsVer__c,
            DocTyp__c,
            NDCDataEntry__c,
            Case__r.CaseType__c,
            Case__r.ApplAssetId__c,
            ApplAsset__c,
            DocSubTyp__c,
            DocCatgry__c,
            OriDoc__c
          FROM DocDtl__c
          WHERE
            LAN__c = :loanId
            AND (DocTyp__c = 'CAM Report'
            OR DocTyp__c = 'Sanction Letter'
                         OR (DocTyp__c ='Application Form' AND DocCatgry__c = 'System Generated Documents')
            OR DocCatgry__c = 'Property Documents'
            OR DocCatgry__c = 'Case Documents')
            AND IsLatest__c = TRUE
        ];
        
        List<NACH__c> nachRecrds = [
          SELECT Id, eNACH_Rejection_Reasons__c, eNACH_Registration_Status__c, Mandate_Type__c
          FROM NACH__c
          WHERE
            LoanAppl__c = :loanId
            AND RepayAcc__c != NULL
            AND RepayAcc__r.Repayment_Mode__c = 'NACH'
            AND RepayAcc__r.Is_Active__c = TRUE
            AND IsActive__c = TRUE
        ];
        List<NACH__c> enachRec = new List<NACH__c>();
        List<NACH__c> phyNachRec = new List<NACH__c>();

        for(NACH__c nach : nachRecrds){
          if(nach.Mandate_Type__c == 'Enach'){
            enachRec.add(nach);
          }
          else if(nach.Mandate_Type__c == 'Physical Nach'){
            phyNachRec.add(nach);
          }
        }
      if (enachRec != null && enachRec.size() > 0) {
      List<RejectReason_eNACH__c> rejectionRason = [
            SELECT
              id,
              Actionable__c,
              ImpactOnJourney__c,
              RejectionReason__c,
              ValidationMsg__c,
              Notification__c
            FROM RejectReason_eNACH__c
            WHERE RejectionReason__c = :enachRec[0].eNACH_Rejection_Reasons__c
          ];

          if (
            rejectionRason != null &&
            rejectionRason.size() > 0 &&
            String.isNotBlank(rejectionRason[0].ValidationMsg__c)
          ) {
            errors.add(rejectionRason[0].ValidationMsg__c);
          }
        }

        if (phyNachRec != null && phyNachRec.size() > 0) {
          List<DocDtl__c> nachForm = [
            SELECT Id, DocStatus__c
            FROM DocDtl__c
            WHERE LAN__c = :loanId AND DocCatgry__c = 'NACH Form'
          ];
          if (nachForm.size() == 0 ) {
            errors.add('Please Generate Nach Form');
          }
        }
        
        Map<String, List<DocDtl__c>> docDtlMap = new Map<String, List<DocDtl__c>>();
        if (otherImpDocs != null && otherImpDocs.size() > 0) {
          for (DocDtl__c docDtl : otherImpDocs) {
            if (docDtlMap.containsKey(docDtl.DocCatgry__c)) {
              docDtlMap.get(docDtl.DocCatgry__c).add(docDtl);
            } else {
              docDtlMap.put(docDtl.DocCatgry__c, new List<DocDtl__c>{ docDtl });
            }
          }
        }
        if (docDtlMap != null && docDtlMap.size() > 0) {
          List<DocDtl__c> otherImpDocsRecs = new List<DocDtl__c>();
          if (
            docDtlMap.get('CAM Report') != null &&
            docDtlMap.get('CAM Report').size() > 0
          ) {
            otherImpDocsRecs.addAll(docDtlMap.get('CAM Report'));
          }
          if (
            docDtlMap.get('Sanction Letter') != null &&
            docDtlMap.get('Sanction Letter').size() > 0
          ) {
            otherImpDocsRecs.addAll(docDtlMap.get('Sanction Letter'));
          }
          if (
                        docDtlMap.get('System Generated Documents') != null &&
                        docDtlMap.get('System Generated Documents').size() > 0
          ) {
                        otherImpDocsRecs.addAll(docDtlMap.get('System Generated Documents'));
          }
          List<DocDtl__c> propertyDocs = new List<DocDtl__c>();
          if (
            docDtlMap.get('Property Documents') != null &&
            docDtlMap.get('Property Documents').size() > 0
          ) {
            propertyDocs.addAll(docDtlMap.get('Property Documents'));
          }
          List<DocDtl__c> caseDocts = new List<DocDtl__c>();
          if (
            docDtlMap.get('Case Documents') != null &&
            docDtlMap.get('Case Documents').size() > 0
          ) {
            caseDocts.addAll(docDtlMap.get('Case Documents'));
          }
          if (otherImpDocsRecs != null && otherImpDocsRecs.size() > 0) {
            for (DocDtl__c docDt : otherImpDocsRecs) {
              if (String.isBlank(docDt.NDCDataEntry__c)) {
                errors.add('NDC DataEntry need to be filled on Ndc Stepper');
              }
            }
          }
          if (propertyDocs != null && propertyDocs.size() > 0) {
            for (DocDtl__c docDt : propertyDocs) {
              if (
                String.isBlank(docDt.OriDoc__c) && docDt.ApplAsset__c != null
              ) {
                errors.add(
                  'Original Document field value need to be filled on Ndc Stepper'
                );
              }
            }
          }
          if (caseDocts != null && caseDocts.size() > 0) {
            for (DocDtl__c docDt : caseDocts) {
              if (
                String.isBlank(docDt.NDCDataEntry__c) &&
                docDt.Case__r.CaseType__c != null &&
                (docDt.Case__r.CaseType__c == 'Technical' ||
                docDt.Case__r.CaseType__c == 'Vetting' ||
                docDt.Case__r.CaseType__c == 'Legal' ||
                docDt.Case__r.CaseType__c == 'TSR') &&
                docDt.Case__r.ApplAssetId__c != null
              ) {
                errors.add('NDC DataEntry need to be filled on Ndc Stepper');
              }
            }
          }
        }
      }

      //BO Handling Validations
      if (
        (loan.Stage__c == 'DDE' || loan.Stage__c == 'Post Sanction') &&
        (loan.subStage__c == 'CPA Data Entry' ||
        loan.subStage__c == 'Query' ||
        loan.subStage__c == 'Data Entry' ||
                 loan.subStage__c == 'Ops Query' || loan.subStage__c == 'CPA Vendor Data Entry')
      ) {
        if(!appl.isEmpty()){
          
          Set<Id> appIds = new Set<Id> ();
          Map<Id,List<LoanApplRelationship__c>> appWithRelationShipMap = new Map<Id,List<LoanApplRelationship__c>>();
          Map<Id,Applicant__c> appWithIdMap = new Map<Id,Applicant__c>();
          for (Applicant__c app : appl) {
            if (app.Constitution__c != null && app.Constitution__c != 'INDIVIDUAL') {
              appIds.add(app.Id);
              appWithIdMap.put(app.Id,app);
            }
          }
          if(!appIds.isEmpty()){
            List<LoanApplRelationship__c> apprelationships = [SELECT Id,Relationship_Type__c,BeneficialOwner__c,Shareholding__c,Loan_Applicant__c FROM LoanApplRelationship__c WHERE Loan_Applicant__c IN : appIds AND Relationship_Type__c IN ('ShareHolder','Beneficial Owner')];
            if(!apprelationships.isEmpty()){
                 for(LoanApplRelationship__c appRel : apprelationships){
                  if(appWithRelationShipMap.containsKey(appRel.Loan_Applicant__c)){
                    appWithRelationShipMap.get(appRel.Loan_Applicant__c).add(appRel);
                }else{
                  appWithRelationShipMap.put(appRel.Loan_Applicant__c,new List<LoanApplRelationship__c>{appRel});
                }  
                 }
            }

            for(Id appId : appIds){
              List<LoanApplRelationship__c> relashipsList = appWithRelationShipMap.get(appId);
              Applicant__c app = appWithIdMap.get(appId);
                            if(relashipsList != null && !relashipsList.isEmpty()){

                Decimal totalShareHolding = 0;
                for (LoanApplRelationship__c loanAppRel : relashipsList) {
                    if (loanAppRel.Shareholding__c != null) {
                        totalShareHolding += loanAppRel.Shareholding__c;
                    }
                }
                if (totalShareHolding != 100) {
                    errors.add('Controlling ownership interest % is not equal to 100% For: ' + app.FullName__c);
                }
              }else{
                errors.add('Please add ShareHolding Details For: ' + app.FullName__c);
              }
            }

          }
        //   for (Applicant__c app : appl) {
        //     if (app.Constitution__c != null && app.Constitution__c != 'INDIVIDUAL') {
        //         if (app.Loan_Applicant_Relationships__r != null && !app.Loan_Applicant_Relationships__r.isEmpty()) {
        //             Decimal totalShareHolding = 0;
        //             for (LoanApplRelationship__c loanAppRel : app.Loan_Applicant_Relationships__r) {
        //                 if (loanAppRel.Shareholding__c != null) {
        //                     totalShareHolding += loanAppRel.Shareholding__c;
        //                 }
        //             }
        //             if (totalShareHolding != 100) {
        //                 errors.add('Controlling ownership interest % is not equal to 100% For: ' + app.FullName__c);
        //             }
        //         } else {
        //             errors.add('Please add ShareHolding Details For: ' + app.FullName__c);
        //         }
        //     }
        // }
                    
                }
            }

        //Partner/Director Validations
        if (
          (loan.Stage__c == 'DDE' || loan.Stage__c == 'Post Sanction') &&
          (loan.subStage__c == 'CPA Data Entry' ||
          loan.subStage__c == 'Query' ||
          loan.subStage__c == 'Data Entry' ||
          loan.subStage__c == 'Ops Query' || loan.subStage__c == 'CPA Vendor Data Entry')
        ) {
          if(!appl.isEmpty()){
            
            Set<Id> appIds = new Set<Id> ();
            Map<Id,List<LoanApplRelationship__c>> appWithRelationShipMap = new Map<Id,List<LoanApplRelationship__c>>();
            Map<Id,Applicant__c> appWithIdMap = new Map<Id,Applicant__c>();
            for (Applicant__c app : appl) {
              if (app.Constitution__c != null && (app.Constitution__c == 'LIMITED LIABILITY PARTNERSHIP' || app.Constitution__c == 'PRIVATE LIMITED COMPANY' || app.Constitution__c == 'PUBLIC LIMITED COMPANY' || app.Constitution__c == 'PARTNERSHIP' )) {
                appIds.add(app.Id);
                appWithIdMap.put(app.Id,app);
              }
            }
            if(!appIds.isEmpty()){
              List<LoanApplRelationship__c> apprelationships = [SELECT Id,Relationship_Type__c,Loan_Applicant__r.Constitution__c,Loan_Applicant__c,Related_Person__r.Part_of_Loan_Propos__c FROM LoanApplRelationship__c WHERE Loan_Applicant__c IN : appIds AND Relationship_Type__c IN ('Partner','Director')];
              if (!apprelationships.isEmpty()) {
                for (LoanApplRelationship__c appRel : apprelationships) {
                    if (appWithRelationShipMap.containsKey(appRel.Loan_Applicant__c)) {
                        appWithRelationShipMap.get(appRel.Loan_Applicant__c).add(appRel);
                    } else {
                        appWithRelationShipMap.put(appRel.Loan_Applicant__c, new List<LoanApplRelationship__c>{appRel});
                    }
                }
            
                for (Id appId : appIds) {
                    List<LoanApplRelationship__c> relashipsList = appWithRelationShipMap.get(appId);
                    Applicant__c app = appWithIdMap.get(appId);
            
                    if (relashipsList != null && !relashipsList.isEmpty()) {
                        for (LoanApplRelationship__c loanAppRel : relashipsList) {
                            String constitution = app.Constitution__c;
            
                            // Check conditions based on Constitution__c
                            if ((constitution == 'PRIVATE LIMITED COMPANY' || constitution == 'PUBLIC LIMITED COMPANY') && 
                                loanAppRel.Relationship_Type__c == 'Director') {
                                // Check for Directors in these cases
                                if (loanAppRel.Related_Person__r.Part_of_Loan_Propos__c == null) {
                                    errors.add('Please fill all the Mandatory Details in Partner/Director Details Stepper for Director: ' + app.FullName__c);
                                }
                            } else if ((constitution == 'LIMITED LIABILITY PARTNERSHIP' || constitution == 'PARTNERSHIP') && 
                                       loanAppRel.Relationship_Type__c == 'Partner') {
                                // Check for Partners in these cases
                                if (loanAppRel.Related_Person__r.Part_of_Loan_Propos__c == null) {
                                    errors.add('Please fill all the Mandatory Details in Partner/Director Details Stepper for Partner: ' + app.FullName__c);
                                }
                            }
                        }
                    }else{
                        errors.add('Please add Atleast One Mandatory Partner/Director Details in Partner/Director Details Stepper for: ' + app.FullName__c);
                    }
                  }
              }
              else{
                for (Id appId : appIds) {
                  Applicant__c app = appWithIdMap.get(appId);
                errors.add('Please add Atleast One Mandatory Partner/Director Details in Partner/Director Details Stepper for: ' + app.FullName__c);
                }
            }
              
            }
            
          }
        }
      //Changes Started for LAK-6958
      if (
        loan.Stage__c == 'Post Sanction' &&
        (loan.SubStage__c == 'Data Entry' ||
        loan.SubStage__c == 'Ops Query')
      ) {
        if (appMap.keyset().size() > 0) {
          Map<Id, List<DocDtl__c>> appWithDocDtl = new Map<Id, List<DocDtl__c>>();
          for (Applicant__c app : appMap.values()) {
            if (
              app.Applicant_Document_Details__r != null &&
              app.Applicant_Document_Details__r.size() > 0
            ) {
              for (DocDtl__c docDtl : app.Applicant_Document_Details__r) {
                if (docDtl.DocCatgry__c == 'Insurance documents') {
                  if (appWithDocDtl.containsKey(app.id)) {
                    appWithDocDtl.get(app.Id).add(docDtl);
                  } else {
                    appWithDocDtl.put(app.Id, new List<DocDtl__c>{ docDtl });
                  }
                }
              }
            }
          }

          list<Insurance__c> insList = [
            SELECT
              Id,
              LoanAppln__c,
              Appl__c,
              Appl__r.id,
              Appl__r.FullName__c,
              IsActive__c,
              InsProvider__c,
              InsProvider__r.Name,
              InsProvider__r.MPHnm__c,
              InsProvider__r.MPno__c,
              InsType__c,
              SumAmount__c,
              SumInsuredType__c,
              PolicyTenute__c,
              PremiumAmount__c,
                        Penettration__c,
              isCoBorrNominee__c
            FROM Insurance__c
            WHERE LoanAppln__c = :loanId
          ];
          if (insList != null && insList.size() > 0) {
            for (Insurance__c ins : insList) {
              if (
                ins.IsActive__c == true &&
                ins.Appl__c != null &&
                ins.InsType__c != null &&
                ins.InsType__c == 'Life Insurance'
              ) {
                List<DocDtl__c> docDtlList = appWithDocDtl.get(ins.Appl__c);
                if (docDtlList != null && docDtlList.size() > 0) {
                  for (DocDtl__c doctl : docDtlList) {
                    if (doctl.DocTyp__c == 'Life Insurance documents') {
                      list<GetDocumentDetails.PreviewWrpr> returnVal = GetDocumentDetails.getFilePreviewDataList(
                        doctl.id
                      );
                      if (returnVal.isEmpty()) {
                        errors.add(
                          ins.Appl__r.FullName__c +
                          ': Please Upload Life Insurance Form'
                        );
                      }
                    }
                  }
                }
              } else if (
                ins.IsActive__c == true &&
                ins.Appl__c != null &&
                ins.InsType__c != null &&
                ins.InsType__c == 'General Insurance'
              ) {
                List<DocDtl__c> docDtlList = appWithDocDtl.get(ins.Appl__c);
                if (docDtlList != null && docDtlList.size() > 0) {
                  for (DocDtl__c doctl : docDtlList) {
                    if (doctl.DocTyp__c == 'General Insurance documents') {
                      list<GetDocumentDetails.PreviewWrpr> returnVal = GetDocumentDetails.getFilePreviewDataList(
                        doctl.id
                      );
                      if (returnVal.isEmpty()) {
                        errors.add(
                          ins.Appl__r.FullName__c +
                          ': Please Upload General Insurance Form'
                        );
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
            //add this for LAK-7930 Manual Banking Upload Validations
           // List<string> errorList= UWForwardValidations.validateDataBankStateCri(loanId); 
            //errors.addAll(errorList);
      //Changes Ended for LAK-6958
      return errors;
    } catch (exception e) {
      system.debug(
        'error occured ' +
          e.getMessage() +
          'get line number ' +
          e.getLineNumber() +
          ' get stack trace ' +
          e.getStackTraceString()
      );
      throw new AuraHandledException(e.getMessage());
    }
    }
    //add this for LAK-7930 Manual Banking Upload Validations
    @AuraEnabled
    public static List<string> validateDataBankStateCri(String loanId){
        List<string> errorForBnk=new List<string>();
        List<MasterData__c> masDataList=[select id, CustomerProfile__c, EligibilityProgram__c, Type__c, StatementPeriodNumber__c, Product__c from MasterData__c where Type__c ='Bank Statement Criteria' ];
        set<id> applIds= new set<id>();
        map<id, Applicant__c> idWithApp= new map<id, Applicant__c>();
        for(Applicant__c app: appRecList){
            applIds.add(app.Id);
            system.debug('app.Id'+app.Id);
            idWithApp.put(app.Id, app);
        }
        
        List<ApplBanking__c> appBnkList=[select id, Appl__c,Appl__r.FullName__c, Appl__r.Type_of_Borrower__c, Type__c, (SELECT Id,Year__c, Month__c FROM Applicant_Banking_Detail__r) from ApplBanking__c where Appl__c IN: applIds  AND Type__c = NULL AND Appl__r.Type_of_Borrower__c = 'Financial' ];
        Map<Id, List<ApplBanking__c>> mapOfAppIdWithBnkRec= new Map<Id, List<ApplBanking__c>>();
        Map<Id, List<ApplBankDetail__c>> mapOfAppIdWithBnkDetailRec= new Map<Id, List<ApplBankDetail__c>>();
        for (ApplBanking__c appBnk : appBnkList) {
            if (!mapOfAppIdWithBnkDetailRec.containsKey(appBnk.Appl__c)) {
                mapOfAppIdWithBnkDetailRec.put(appBnk.Appl__c, new List<ApplBankDetail__c>());
            }
            list<ApplBankDetail__c> appBnkDetailList=appBnk.Applicant_Banking_Detail__r;
            mapOfAppIdWithBnkDetailRec.get(appBnk.Appl__c).addAll(appBnkDetailList);
            if (!mapOfAppIdWithBnkRec.containsKey(appBnk.Appl__c)) {
                mapOfAppIdWithBnkRec.put(appBnk.Appl__c, new List<ApplBanking__c>());
            }
            mapOfAppIdWithBnkRec.get(appBnk.Appl__c).add(appBnk);
        }
        system.debug('mapOfAppIdWithBnkDetailRec'+mapOfAppIdWithBnkDetailRec.keySet());
        system.debug('mapOfAppIdWithBnkRec'+mapOfAppIdWithBnkRec.keySet());
        for(id applId: mapOfAppIdWithBnkDetailRec.keySet()){
            List<ApplBankDetail__c> appBnkDetailList=mapOfAppIdWithBnkDetailRec.get(applId);
            List<ApplBanking__c> bnkRecList=mapOfAppIdWithBnkRec.get(applId);
            system.debug('appBnkDetailList.size'+appBnkDetailList.size());
            system.debug('bnkRecList.size'+bnkRecList.size());
            set<string> monthYearSet=new set<string>();
            if(appBnkDetailList.size()>0 && bnkRecList.size()>0){
                for(ApplBankDetail__c bnkDe: appBnkDetailList){
                    string monthYear=bnkDe.Month__c+'-'+bnkDe.Year__c;
                    monthYearSet.add(monthYear);
                }
            }
            system.debug('monthYearSet.size'+monthYearSet.size());
            if(!string.isBlank(idWithApp.get(applId).CustProfile__c) && masDataList.size() > 0){
                
                for(MasterData__c masData: masDataList){
                    system.debug('masData.CustomerProfile__c'+masData.CustomerProfile__c);
                    if(idWithApp.get(applId).CustProfile__c==masData.CustomerProfile__c && masData.Product__c.contains(loanRec.Product__c)){
                        system.debug('idWithApp.get(applId).CustProfile__c'+idWithApp.get(applId).CustProfile__c);
                        if(monthYearSet.size()< masData.StatementPeriodNumber__c){
                            errorForBnk.add(idWithApp.get(applId).FullName__c+': please upload atleast '+masData.StatementPeriodNumber__c + ' Banking Detail Statment.');
                        }
                    }
                }
            }
            
            
        }
        system.debug('errorForBnk'+errorForBnk);
        
        return errorForBnk;
    }  
}