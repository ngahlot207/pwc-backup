public without sharing class CloneLoanAppJob  {
    // public CloneLoanAppController.CloneLoanAppwrpr inputData;
    // implements Queueable, Database.AllowsCallouts
    // public CloneLoanAppJob(CloneLoanAppController.CloneLoanAppwrpr inputData) {
    //     this.inputData = inputData;
    // }
    // public void execute(QueueableContext context) {
    public static  CloneLoanAppController.CloneLoanDetailsWrpr cloneLoanAppMethod(CloneLoanAppController.CloneLoanAppwrpr inputData) {
        LoanAppl__c clonedLoanApp;
        CloneLoanAppController.CloneLoanDetailsWrpr returnData = new  CloneLoanAppController.CloneLoanDetailsWrpr();
            system.debug('inputData ' + inputData);
            if (inputData.cloneReason != null) {
                TeamHierarchy__c teamHierarchy = [SELECT Id, EmpRole__c, Employee__c FROM TeamHierarchy__c WHERE Employee__c = :inputData.userId LIMIT 1];
                
                LoanAppl__c loanApp = [SELECT Id, Product__c, Stage__c, SubStage__c,LoginAcceptDate__c FROM LoanAppl__c WHERE Id = :inputData.recordId LIMIT 1];
                 
                //LAK-9375
                // Date todayDate = Date.today();
                // Date comparisonDate = todayDate.addDays(-30);
                
                // if (loanApp.LoginAcceptDate__c != null && loanApp.LoginAcceptDate__c <= comparisonDate) {
                //     inputData.cloneReason = 'Top up';
                // }
                CloneMetadataUtility.CloneMtdUtilityWrpr returnDat = CloneMetadataUtility.getCloneStatus('LoanAppl', inputData.cloneReason);
                List<String> products = returnDat.productType.split(':');
                
                if (returnDat.cloneStatus != null && returnDat.cloneStatus == 'Yes' && products.contains(loanApp.Product__c)) {
                    String loanQuery = 'SELECT ' + returnDat.fields + ',Name FROM LoanAppl__c WHERE Id = \'' + inputData.recordId + '\' LIMIT 1';
                    LoanAppl__c loanRecord = Database.query(loanQuery);
                    system.debug('loanRecord ' + loanRecord);
                    clonedLoanApp = loanRecord.clone(
                        false,
                        true,
                        false,
                        false
                    );
                    clonedLoanApp.ClonedBy__c = inputData.userId;
                    clonedLoanApp.ClonedFor__c = loanRecord.Id;
                    clonedLoanApp.Product__c = inputData.product;
                    clonedLoanApp.Branch__c = inputData.branch;
                    clonedLoanApp.ClonedForLAN__c = loanRecord.Name;
                    clonedLoanApp.RMSMName__c = inputData.rmSmId != null
                        ? inputData.rmSmId
                        : loanRecord.RMSMName__c;
                    if (loanRecord.LoginAcceptance__c == true) {
                        clonedLoanApp.LoginAcceptDate__c = Date.today();
                    }
                    if (loanRecord.FileAcceptance__c == true) {
                        clonedLoanApp.FileAcceptDate__c = Date.today();
                    }
                    clonedLoanApp.CloneRea__c = inputData.cloneReason;
                   // clonedLoanApp.Lead__c = null;
                    MetadataTriggerHandler.bypass('LoanTATHandler'); //LAK-8409
                    TriggerActionFlow.bypass('RT_After_Loan_Application_Flow');
                    insert clonedLoanApp;
                    MetadataTriggerHandler.clearBypass('LoanTATHandler');//LAK-8409
                    TriggerActionFlow.clearBypass('RT_After_Loan_Application_Flow');
                    
                    LoanAppl__c CloneloanAppNew = [SELECT Id,Name FROM LoanAppl__c WHERE Id = :clonedLoanApp.Id LIMIT 1];

                    returnData.clonedRecordId = clonedLoanApp.Id;
                    returnData.clonedLoanNumber = CloneloanAppNew.Name;
                    
                    createApplicantHistory(clonedLoanApp.Id, loanApp, teamHierarchy);
                    if(String.isNotBlank(loanRecord.FinnoneAppid__c)){
                        createIntegrationMessage(clonedLoanApp.Id);
                    }
                    system.debug('inputData in loan appJob'+ inputData);
                    // Enqueue the CloneApplicantsJob after cloning the Loan Application
                    if(!Test.isRunningTest()){
                        System.enqueueJob(
                            new CloneApplicantsJob(inputData, loanApp.Product__c, clonedLoanApp.Id)
                        );
                    }
                }
            }
        if(returnData != null){
            return returnData;
        }
        return null;
    }
    
    public static void createIntegrationMessage(String cloneLoanId){
        IntgMsg__c intMsg = new IntgMsg__c();
        intMsg.Name = 'Sequence API';
        intMsg.Status__c = 'New';
        intMsg.Svc__c = 'Sequence API';
        intMsg.BU__c = 'HL / STL';
        intMsg.IsActive__c = true;
        intMsg.RefId__c = cloneLoanId;
        intMsg.RefObj__c = 'LoanAppl__c';
        insert intMsg;
    }
    
    public static void createApplicantHistory(String cloneLoanId, LoanAppl__c loanRecord, TeamHierarchy__c teamHierarchy) {
        List<String> aftrtSanStages = new List<String>{'Post Sanction', 'Soft Sanction', 'Disbursement Initiation', 'Disbursed'};
            List<String> cpaHierarchy = new List<String>{'UW','ACM', 'RCM', 'ZCM', 'NCM', 'CH'};
                List<LoanTAT__c> loanTATs = new List<LoanTAT__c>();
        LoanAppl__c updateLoanRecord = new LoanAppl__c();
        updateLoanRecord.Id = cloneLoanId;
        updateLoanRecord.CloneStatus__c = 'In Progress';
        updateLoanRecord.Status__c = 'In Progress'; //LAK-8409
        //teamHierarchy.EmpRole__c == 'CPA' || removed for LAK-9677
        if ((loanRecord != null && aftrtSanStages.contains(loanRecord.Stage__c) && teamHierarchy != null && cpaHierarchy.contains(teamHierarchy.EmpRole__c)) || 
            (loanRecord != null && loanRecord.Stage__c == 'UnderWriting' && teamHierarchy != null && cpaHierarchy.contains(teamHierarchy.EmpRole__c))) { 
                updateLoanRecord.Stage__c = 'UnderWriting';
                updateLoanRecord.SubStage__c = 'Credit Appraisal';
                
                loanTATs.add(new LoanTAT__c(
                    Stage__c = 'QDE',
                    Sub_Stage__c = 'RM Data Entry',
                    EntryTime__c = Datetime.now(),
                    ExitTime__c = Datetime.now(),
                    LoanApplication__c = cloneLoanId,
                    Owner__c = teamHierarchy.Employee__c,
                    Status__c = 'In Progress',
                    UserRole__c = teamHierarchy.EmpRole__c
                ));
                loanTATs.add(new LoanTAT__c(
                    Stage__c = 'QDE',
                    Sub_Stage__c = 'Additional Data Entry Pool',
                    EntryTime__c = Datetime.now(),
                    ExitTime__c = Datetime.now(),
                    LoanApplication__c = cloneLoanId,
                    Status__c = 'In Progress',
                    Owner__c = teamHierarchy.Employee__c,
                    UserRole__c = teamHierarchy.EmpRole__c
                ));
                loanTATs.add(new LoanTAT__c(
                    Stage__c = 'QDE',
                    Sub_Stage__c = 'Additional Data Entry',
                    EntryTime__c = Datetime.now(),
                    ExitTime__c = Datetime.now(),
                    Status__c = 'In Progress',
                    LoanApplication__c = cloneLoanId,
                    Owner__c = teamHierarchy.Employee__c,
                    UserRole__c = teamHierarchy.EmpRole__c
                ));
                loanTATs.add(new LoanTAT__c(
                    Stage__c = 'DDE',
                    Sub_Stage__c = 'CPA Data Entry',
                    EntryTime__c = Datetime.now(),
                    ExitTime__c = Datetime.now(),
                    Status__c = 'In Progress',
                    LoanApplication__c = cloneLoanId,
                    Owner__c = teamHierarchy.Employee__c,
                    UserRole__c = teamHierarchy.EmpRole__c
                ));
                loanTATs.add(new LoanTAT__c(
                    Stage__c = 'UnderWriting',
                    Sub_Stage__c = 'UW Pool',
                    EntryTime__c = Datetime.now(),
                    ExitTime__c = Datetime.now(),
                    Status__c = 'In Progress',
                    LoanApplication__c = cloneLoanId,
                    Owner__c = teamHierarchy.Employee__c,
                    UserRole__c = teamHierarchy.EmpRole__c
                ));
                loanTATs.add(new LoanTAT__c(
                    Stage__c = 'UnderWriting',
                    Sub_Stage__c = 'Credit Appraisal',
                    EntryTime__c = Datetime.now(),
                    Status__c = 'In Progress',
                    LoanApplication__c = cloneLoanId,
                    Owner__c = teamHierarchy.Employee__c,
                    UserRole__c = teamHierarchy.EmpRole__c
                ));
            } else if ((loanRecord != null && aftrtSanStages.contains(loanRecord.Stage__c) && teamHierarchy != null && GlobalConstants.CPARoles.contains(teamHierarchy.EmpRole__c)) ||    //LAK-9244
            (loanRecord != null && loanRecord.Stage__c == 'UnderWriting' && teamHierarchy != null && GlobalConstants.CPARoles.contains(teamHierarchy.EmpRole__c))) {   //LAK-9244
                updateLoanRecord.Stage__c = 'DDE';
                updateLoanRecord.SubStage__c = 'CPA Data Entry';
                
                loanTATs.add(new LoanTAT__c(
                    Stage__c = 'QDE',
                    Sub_Stage__c = 'RM Data Entry',
                    EntryTime__c = Datetime.now(),
                    ExitTime__c = Datetime.now(),
                    Status__c = 'In Progress',
                    LoanApplication__c = cloneLoanId,
                    Owner__c = teamHierarchy.Employee__c,
                    UserRole__c = teamHierarchy.EmpRole__c
                ));
                loanTATs.add(new LoanTAT__c(
                    Stage__c = 'QDE',
                    Sub_Stage__c = 'Additional Data Entry Pool',
                    EntryTime__c = Datetime.now(),
                    ExitTime__c = Datetime.now(),
                    Status__c = 'In Progress',
                    LoanApplication__c = cloneLoanId,
                    Owner__c = teamHierarchy.Employee__c,
                    UserRole__c = teamHierarchy.EmpRole__c
                ));
                loanTATs.add(new LoanTAT__c(
                    Stage__c = 'QDE',
                    Sub_Stage__c = 'Additional Data Entry',
                    EntryTime__c = Datetime.now(),
                    ExitTime__c = Datetime.now(),
                    Status__c = 'In Progress',
                    LoanApplication__c = cloneLoanId,
                    Owner__c = teamHierarchy.Employee__c,
                    UserRole__c = teamHierarchy.EmpRole__c
                ));
                loanTATs.add(new LoanTAT__c(
                    Stage__c = 'DDE',
                    Sub_Stage__c = 'CPA Data Entry',
                    EntryTime__c = Datetime.now(),
                    Status__c = 'In Progress',
                    LoanApplication__c = cloneLoanId,
                    Owner__c = teamHierarchy.Employee__c,
                    UserRole__c = teamHierarchy.EmpRole__c
                ));
            } else if (loanRecord != null && loanRecord.Stage__c == 'DDE' && teamHierarchy != null && (GlobalConstants.CPARoles.contains(teamHierarchy.EmpRole__c) || cpaHierarchy.contains(teamHierarchy.EmpRole__c))) {  //LAK-9244
                loanTATs.add(new LoanTAT__c(
                    Stage__c = 'QDE',
                    Sub_Stage__c = 'RM Data Entry',
                    EntryTime__c = Datetime.now(),
                    ExitTime__c = Datetime.now(),
                    Status__c = 'In Progress',
                    LoanApplication__c = cloneLoanId,
                    Owner__c = teamHierarchy.Employee__c,
                    UserRole__c = teamHierarchy.EmpRole__c
                ));
                loanTATs.add(new LoanTAT__c(
                    Stage__c = 'QDE',
                    Sub_Stage__c = 'Additional Data Entry Pool',
                    EntryTime__c = Datetime.now(),
                    ExitTime__c = Datetime.now(),
                    Status__c = 'In Progress',
                    LoanApplication__c = cloneLoanId,
                    Owner__c = teamHierarchy.Employee__c,
                    UserRole__c = teamHierarchy.EmpRole__c
                ));
                loanTATs.add(new LoanTAT__c(
                    Stage__c = 'QDE',
                    Sub_Stage__c = 'Additional Data Entry',
                    EntryTime__c = Datetime.now(),
                    Status__c = 'In Progress',
                    LoanApplication__c = cloneLoanId,
                    Owner__c = teamHierarchy.Employee__c,
                    UserRole__c = teamHierarchy.EmpRole__c
                ));
            } else if (loanRecord != null && loanRecord.Stage__c == 'QDE' && loanRecord.SubStage__c == 'Additional Data Entry' && teamHierarchy != null && (GlobalConstants.CPARoles.contains(teamHierarchy.EmpRole__c) || teamHierarchy.EmpRole__c == 'UW')) {  //LAK-9244
                loanTATs.add(new LoanTAT__c(
                    Stage__c = 'QDE',
                    Sub_Stage__c = 'RM Data Entry',
                    EntryTime__c = Datetime.now(),
                    ExitTime__c = Datetime.now(),
                    Status__c = 'In Progress',
                    LoanApplication__c = cloneLoanId,
                    Owner__c = teamHierarchy.Employee__c,
                    UserRole__c = teamHierarchy.EmpRole__c
                ));
                loanTATs.add(new LoanTAT__c(
                    Stage__c = 'QDE',
                    Sub_Stage__c = 'Additional Data Entry Pool',
                    EntryTime__c = Datetime.now(),
                    ExitTime__c = Datetime.now(),
                    Status__c = 'In Progress',
                    LoanApplication__c = cloneLoanId,
                    Owner__c = teamHierarchy.Employee__c,
                    UserRole__c = teamHierarchy.EmpRole__c
                ));
                loanTATs.add(new LoanTAT__c(
                    Stage__c = 'QDE',
                    Sub_Stage__c = 'Additional Data Entry',
                    EntryTime__c = Datetime.now(),
                    Status__c = 'In Progress',
                    LoanApplication__c = cloneLoanId,
                    Owner__c = teamHierarchy.Employee__c,
                    UserRole__c = teamHierarchy.EmpRole__c
                ));
            } else if (loanRecord != null && loanRecord.Stage__c == 'QDE' && (loanRecord.SubStage__c == 'RM Data Entry' || loanRecord.SubStage__c == 'Pre login Query') && teamHierarchy != null && (GlobalConstants.CPARoles.contains(teamHierarchy.EmpRole__c) || teamHierarchy.EmpRole__c == 'UW')) {  //LAK-9244
                loanTATs.add(new LoanTAT__c(
                    Stage__c = 'QDE',
                    Sub_Stage__c = 'RM Data Entry',
                    EntryTime__c = Datetime.now(),
                    Status__c = 'In Progress',
                    LoanApplication__c = cloneLoanId,
                    Owner__c = teamHierarchy.Employee__c,
                    UserRole__c = teamHierarchy.EmpRole__c
                ));
            }
        
        if (!loanTATs.isEmpty()) {
            insert loanTATs;
        }
        if (updateLoanRecord != null) {
            MetadataTriggerHandler.bypass('LoanTATHandler'); //LAK-8409
            TriggerActionFlow.bypass('RT_After_Loan_Application_Flow'); 
            update updateLoanRecord;
            MetadataTriggerHandler.clearBypass('LoanTATHandler'); //LAK-8409
            TriggerActionFlow.clearBypass('RT_After_Loan_Application_Flow');
        }
    }
}