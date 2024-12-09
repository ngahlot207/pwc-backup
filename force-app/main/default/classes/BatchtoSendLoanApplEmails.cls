global class BatchtoSendLoanApplEmails implements Database.Batchable<SObject>, Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('Starting batch job');
        return Database.getQueryLocator([SELECT Id, LoanAppl__r.BrchCode__c,OwnerEmail__c,OwnerId,Status__c,Recommender__c,RecordType.Name,AppName__c,Approver__c,Decision__c,
                                         LoanAppl__c,LoanAppl__r.Name,LoanAppl__r.Applicant__r.TabName__c,
                                         LoanAppl__r.Application_Level_Assessment_Program__c,LoanAppl__r.SanLoanAmt__c, 
                                         ZoneRoi__c,LoanAppl__r.LeadROI__c,LoanAppl__r.PFInPercentage__c,RevisedRoi__c,RevisedPF__c FROM LoanAppeal__c Where CreatedDate = TODAY AND Status__c = 'In Progress' ORDER BY CreatedDate ASC]);
    }
    
    global void execute(Database.BatchableContext bc, List<LoanAppeal__c> newList) {
        system.debug('Executing batch job');
        
        if (newList == null || newList.isEmpty()) {
            system.debug('No loan Appeals to process');
            return;
        }
        
        try {
            Map<String, List<LoanAppeal__c>> recWithLoanAppl = new Map<String, List<LoanAppeal__c>>();
            Map<String, List<LoanAppeal__c>> appvrWithLoanAppl = new Map<String, List<LoanAppeal__c>>();
            system.debug('newList size is ' + newList.size());
            for (LoanAppeal__c loanApp : newList) {
                system.debug('Recommender is  ' + loanApp.Recommender__c);
                system.debug('Approver is  ' + loanApp.Approver__c);
                system.debug('RecordType.Name is  ' + loanApp.RecordType.Name);
                system.debug('Decision is  ' + loanApp.Decision__c);
                if (loanApp.Recommender__c != null && loanApp.RecordType.Name == 'Roi Pf Correction' && loanApp.Decision__c == 'Forward To Recommender') {
                    //recommenders.add(loanApp.Recommender__c);
                    if (recWithLoanAppl.containsKey(loanApp.Recommender__c)) {
                        recWithLoanAppl.get(loanApp.Recommender__c).add(loanApp);
                    } else {
                        recWithLoanAppl.put(loanApp.Recommender__c, new List<LoanAppeal__c>{loanApp});
                    }
                }else if(loanApp.Approver__c != null && loanApp.RecordType.Name == 'Roi Pf Correction' && loanApp.Decision__c == 'Forward To Approver'){
                    if (appvrWithLoanAppl.containsKey(loanApp.Approver__c)) {
                        appvrWithLoanAppl.get(loanApp.Approver__c).add(loanApp);
                    } else {
                        appvrWithLoanAppl.put(loanApp.Approver__c, new List<LoanAppeal__c>{loanApp});
                    }
                }
            }
            system.debug('appvrWithLoanAppl ' + appvrWithLoanAppl);
            Map<String, TeamHierarchy__c> approvedmap = new Map<String, TeamHierarchy__c>();
            List<TeamHierarchy__c> teamHierarchyRecords = [SELECT employee__c, EmpRole__c, EmployeEmail__c FROM TeamHierarchy__c WHERE employee__c IN :recWithLoanAppl.keySet() OR employee__c IN :appvrWithLoanAppl.keySet()];
            for (TeamHierarchy__c teamHier : teamHierarchyRecords) {
                approvedmap.put(teamHier.employee__c, teamHier);
            }
            Map<String,BRE__c> breMap = new Map<String,BRE__c>();
            List<BRE__c> breRecs = [SELECT Id,LoanAppl__c,RAACROI__c,Application_level_Assessment_program__c FROM BRE__c WHERE EligibilityType__c = 'Application' AND IsLatest__c =true];
            if(!breRecs.isEmpty()){
                for(BRE__c bre : breRecs){
                    breMap.put(bre.LoanAppl__c,bre);
                }
            }
             Map<String,ApplAsset__c> appAssetsMap = new Map<String,ApplAsset__c>();
             List<ApplAsset__c> appAssets = [SELECT Id,PropType__c,LoanAppln__c FROM ApplAsset__c];
            if(!appAssets.isEmpty()){
                for(ApplAsset__c appAsset : appAssets){
                    appAssetsMap.put(appAsset.LoanAppln__c,appAsset);
                }
            }
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :System.label.orgWideEmail];
            
            if(!recWithLoanAppl.keyset().isEmpty()){
                List<Messaging.SingleEmailMessage> newMailList = getEmaillist(recWithLoanAppl,owea,approvedmap,breMap,appAssetsMap);
                mailList.addall(newMailList);
                system.debug('recommender map mail list ' + newMailList);
            }
            if(!appvrWithLoanAppl.keyset().isEmpty()){
                List<Messaging.SingleEmailMessage> newMailList = getEmaillist(appvrWithLoanAppl,owea,approvedmap,breMap,appAssetsMap);
                mailList.addall(newMailList);
                system.debug('approver map mail list ' + newMailList);
            }
            if (!mailList.isEmpty() && !Test.isRunningTest()) {
                List<EmailMessage> EmailMessList = new List<EmailMessage>();
                for(Messaging.SingleEmailMessage mess : mailList){
                    
                    EmailMessage emailMess = new EmailMessage();
                    emailMess.ToAddress = String.join(mess.getToAddresses(), ', '); 
                    if(mess.getCcAddresses() != null){
                    emailMess.CcAddress = String.join(mess.getCcAddresses(), ', ');  
                    }           
                    emailMess.HtmlBody = mess.getHtmlBody();
                    emailMess.Subject = mess.getSubject();
                    emailMess.Status = '3';
                    if(mess.getWhatId() != null){
                    emailMess.RelatedToId = mess.getWhatId(); 
                    }
                    emailMess.BulkEmail__c=true;
                    EmailMessList.add(emailMess);
                }
            
                if(!EmailMessList.isEmpty() && EmailMessList != null) {
                Insert EmailMessList;
                }
                EmailMessageBatchHandler.handleEmailMessage(EmailMessList);
            }
            
        } catch (Exception ex) {
            system.debug('Error occurred: ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
        }
    }
    
    global static List<Messaging.SingleEmailMessage> getEmaillist( Map<String, List<LoanAppeal__c>> loanAppData,OrgWideEmailAddress[] owea,Map<String, TeamHierarchy__c> approvedmap,Map<String,BRE__c> breMap,Map<String,ApplAsset__c> appAssetsMap){
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        for (String recom : loanAppData.keyset()) {
            List<LoanAppeal__c> newListData = loanAppData.get(recom);
            Messaging.SingleEmailMessage newMail = new Messaging.SingleEmailMessage();
            newMail.setSaveAsActivity(false);
            if (!owea.isEmpty()) {
                newMail.setOrgWideEmailAddressId(owea[0].Id);
            }
            newMail.setTargetObjectId(UserInfo.getUserId());
            newMail.setSubject('Request for Pricing Approval Has Been Raised');
            String emailBody = '<p>Hi,</p>';
            emailBody += '<p>A request for pricing approval has been raised for the following applications. Kindly review and take further action.</p>';
            emailBody += '<table border="1" cellspacing="0" cellpadding="5" style="border-collapse: collapse; width: 100%;">';
            emailBody += '<thead><tr>';
            emailBody += '<th style="border: 1px solid #dddddd; text-align: left;">Application ID</th>';
            emailBody += '<th style="border: 1px solid #dddddd; text-align: left;">Borrower Name</th>';
            emailBody += '<th style="border: 1px solid #dddddd; text-align: left;">Assessment Program</th>';
            emailBody += '<th style="border: 1px solid #dddddd; text-align: left;">Loan Amount</th>';
            emailBody += '<th style="border: 1px solid #dddddd; text-align: left;">Property Type</th>';
            emailBody += '<th style="border: 1px solid #dddddd; text-align: left;">Region/State Weighted Avg ROI</th>';
            emailBody += '<th style="border: 1px solid #dddddd; text-align: left;">RACC ROI</th>';
            emailBody += '<th style="border: 1px solid #dddddd; text-align: left;">RACC PF</th>';
            emailBody += '<th style="border: 1px solid #dddddd; text-align: left;">Proposed ROI</th>';
            emailBody += '<th style="border: 1px solid #dddddd; text-align: left;">Proposed PF</th>';
            emailBody += '</tr></thead>';
            emailBody += '<tbody>';
            
            List<String> setToAddrss = new List<String>();
            for (LoanAppeal__c loanApp : newListData) {
                TeamHierarchy__c teamHierRec;
                BRE__c bre;
                ApplAsset__c appAsset;
                if(breMap != null){
                    bre = breMap.get(loanApp.LoanAppl__c);
                }
                if(appAssetsMap != null){
                    appAsset = appAssetsMap.get(loanApp.LoanAppl__c);
                }
                if (loanApp.Decision__c != null && loanApp.Decision__c == 'Forward To Approver') {
                    teamHierRec = approvedmap.get(loanApp.Approver__c);
                }else if(loanApp.Decision__c != null && loanApp.Decision__c == 'Forward To Recommender'){
                    teamHierRec = approvedmap.get(loanApp.Recommender__c);
                }
                if (teamHierRec != null) {
                    setToAddrss.add(teamHierRec.EmployeEmail__c);
                    emailBody += '<tr>';
                    emailBody += '<td>' + (loanApp.LoanAppl__r != null ? String.valueOf(loanApp.LoanAppl__r.Name) : '') + '</td>';
                    emailBody += '<td>' + (loanApp.LoanAppl__r != null && loanApp.LoanAppl__r.Applicant__c != null ? String.valueOf(loanApp.LoanAppl__r.Applicant__r.TabName__c) : '') + '</td>';
                    emailBody += '<td>' + (bre != null && bre.Application_level_Assessment_program__c != null ? String.valueOf(bre.Application_level_Assessment_program__c) : '') + '</td>';
                    emailBody += '<td>' + (loanApp.LoanAppl__r != null && loanApp.LoanAppl__r.SanLoanAmt__c != null ? formatDecimal(loanApp.LoanAppl__r.SanLoanAmt__c) : '0.00') + '</td>';
                    emailBody += '<td>' + (appAsset != null && appAsset.PropType__c != null ? String.valueOf(appAsset.PropType__c) : '') + '</td>';
                    emailBody += '<td>' + (loanApp.ZoneRoi__c != null ? formatDecimal(loanApp.ZoneRoi__c) : '0.00') + '</td>';
                    emailBody += '<td>' + (bre != null && bre.RAACROI__c != null ? formatDecimal(bre.RAACROI__c) : '0.00') + '</td>';
                    emailBody += '<td>' + (loanApp.LoanAppl__r != null && loanApp.LoanAppl__r.PFInPercentage__c != null ? formatDecimal(loanApp.LoanAppl__r.PFInPercentage__c) : '0.00') + '</td>';
                    emailBody += '<td>' + (loanApp.RevisedRoi__c != null ? formatDecimal(loanApp.RevisedRoi__c) : '0.00') + '</td>';
                    emailBody += '<td>' + (loanApp.RevisedPF__c != null ? formatDecimal(loanApp.RevisedPF__c) : '0.00') + '</td>';
                    emailBody += '</tr>';
                }           
            }
            emailBody += '</tbody>';
            emailBody += '</table>';
            //newMail.setTargetObjectId(teamHierRec.EmployeEmail__c);
            newMail.setToAddresses(setToAddrss);
            
            newMail.setHtmlBody(emailBody);
            mailList.add(newMail);
        }
        return mailList;
    }
    global void finish(Database.BatchableContext bc) {
        system.debug('Batch job finished');
    }
    
    global void execute(SchedulableContext sc) {
        BatchtoSendLoanApplEmails batchInstance = new BatchtoSendLoanApplEmails();
        Database.executeBatch(batchInstance);
    }
    public static String formatDecimal(Decimal value) {
        if (value == null) {
            return '0.00';
        }
        // Format the decimal to two decimal places
        return String.valueOf(value.setScale(2));
    }
    // Custom Exception Class
    public class CustomException extends Exception {}
}