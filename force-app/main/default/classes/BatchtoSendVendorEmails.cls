global class BatchtoSendVendorEmails implements Database.Batchable<SObject>, Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('Starting batch job');
        return Database.getQueryLocator([
            SELECT Id, CaseNumber, RecordType.Name, ContactId, Address_Type__c, Loan_Application__r.Name, Applicant__r.TabName__c,ApplAssetId__c,ApplAssetId__r.PropType__c,PropType__c 
            FROM Case
            WHERE CreatedDate = TODAY 
            AND (RecordType.Name = 'TSR' OR RecordType.Name = 'Legal' OR RecordType.Name = 'Vetting' OR RecordType.Name = 'CPVFI' OR RecordType.Name = 'Technical')
            ORDER BY ContactId , RecordType.Name ASC
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<Case> caseList) {
        system.debug('Executing batch job');
        
        if (caseList == null || caseList.isEmpty()) {
            system.debug('No cases to process');
            return;
        }
        
        try {
            Set<Id> contactIds = new Set<Id>();
            List<Case> cpvFICases = new List<Case> ();
            List<Case> technicalCases = new List<Case> ();
            List<Case> legalCases = new List<Case> ();
            List<Case> tsrCases = new List<Case> ();
            List<Case> vettigCases = new List<Case> ();
            for (Case c : caseList) {
                if (c.ContactId != null) {
                    contactIds.add(c.ContactId);
                    if(c.RecordType.Name == 'TSR'){
                        tsrCases.add(c);
                    }else if(c.RecordType.Name == 'Legal'){
                        legalCases.add(c);
                    }else if(c.RecordType.Name == 'Vetting'){
                        vettigCases.add(c);
                    }else if(c.RecordType.Name == 'CPVFI'){
                        cpvFICases.add(c);
                    }else if(c.RecordType.Name == 'Technical'){
                        technicalCases.add(c);
                    }
                }
            }
            
            if (contactIds.isEmpty()) {
                system.debug('No contact IDs found in case list');
                return;
            }
            
            List<User> userList = [SELECT Id, Email, ContactId FROM User WHERE ContactId IN :contactIds];
            Map<Id, String> contactToUserMap = new Map<Id, String>();
            
            for (User u : userList) {
                if (u.Email != null) {
                    contactToUserMap.put(u.ContactId, u.Email);
                }
            }
            
            if (contactToUserMap.isEmpty()) {
                system.debug('No users with valid emails found for contact IDs');
                return;
            }
            // Hub Legal Manager Team Hierarchy Record
            List<TeamHierarchy__c> teamHierarchyRecords = [SELECT employee__c, EmpRole__c, EmployeEmail__c FROM TeamHierarchy__c WHERE EmpRole__c = 'LHM' LIMIT 1];
            
            if (teamHierarchyRecords.isEmpty()) {
                throw new CustomException('No Team Hierarchy records found for role LHM.');
            }
            
            TeamHierarchy__c hubLegalManager = teamHierarchyRecords[0];
            
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :System.label.orgWideEmail];
            
            if(!tsrCases.isEmpty()){
                List<Messaging.SingleEmailMessage> newMailList = getMailList(tsrCases,contactToUserMap,'TSR',owea,hubLegalManager);
                mailList.addall(newMailList);
            }
            if(!legalCases.isEmpty()){
                List<Messaging.SingleEmailMessage> newMailList = getMailList(legalCases,contactToUserMap,'Legal verification',owea,hubLegalManager);
                mailList.addall(newMailList);
            }
            if(!vettigCases.isEmpty()){
                List<Messaging.SingleEmailMessage> newMailList = getMailList(vettigCases,contactToUserMap,'Legal Vetting',owea,hubLegalManager);
                mailList.addall(newMailList);
            }
            if(!cpvFICases.isEmpty()){
                List<Messaging.SingleEmailMessage> newMailList = getMailList(cpvFICases,contactToUserMap,'CPV',owea,null);
                mailList.addall(newMailList);
            }
            if(!technicalCases.isEmpty()){
                List<Messaging.SingleEmailMessage> newMailList = getMailList(technicalCases,contactToUserMap,'Technical',owea,hubLegalManager);
                mailList.addall(newMailList);
            }  
            if(!mailList.isEmpty() && !Test.isRunningTest()){
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
    
    global static List<Messaging.SingleEmailMessage> getMailList(List<Case> newList, Map<Id, String> contactToUserMap,String key,OrgWideEmailAddress[] owea,TeamHierarchy__c hubLegalManager){
        Map<Id, List<Case>> caseMap = new Map<Id, List<Case>>();
        List<String> hubLegalManEmails = new List<String> ();
        if(hubLegalManager != null){
        hubLegalManEmails.add(hubLegalManager.EmployeEmail__c);
        }
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        for (Case c : newList) {
            if (c.ContactId != null) {
                if (!caseMap.containsKey(c.ContactId)) {
                    caseMap.put(c.ContactId, new List<Case>());
                }
                caseMap.get(c.ContactId).add(c);
            }
        }
        if(!caseMap.keyset().isEmpty()){
            for(Id contactId : caseMap.keyset()){
                List<Case> cases = caseMap.get(contactId);
                if (cases == null || cases.isEmpty()) {
                    continue;
                }
                Messaging.SingleEmailMessage newMail = new Messaging.SingleEmailMessage();
                if (!owea.isEmpty()) {
                    newMail.setOrgWideEmailAddressId(owea[0].Id);
                }
                String recipientEmail = contactToUserMap.get(contactId);
                if (recipientEmail == null) {
                    continue;
                }
                newMail.setToAddresses(new List<String>{ recipientEmail });
                if(hubLegalManEmails != null){
                newMail.setCCAddresses(hubLegalManEmails);
                }
                newMail.setSubject('Cases assigned from Fedfina during the day');   
                //newMail.setTargetObjectId(UserInfo.getUserId());
                // Start composing the email body
                String body = '<p>Hi,</p>';
                body += '<p>Following case/s pertaining to ' + key + ' have been assigned to you today ' + Date.today().format() + '. Kindly access the portal for details. Remember to change the status of the case to WIP once the work has been commenced.</p>'; 
                body += '<table style="width:100%; border-collapse:collapse; font-family: Arial, sans-serif;">';
                
                // Table header
                body += '<thead style="background-color:#f2f2f2; text-align:left;">';
                body += '<tr>';
                body += '<th style="border: 1px solid #dddddd; padding: 8px;">Application Id</th>';
                body += '<th style="border: 1px solid #dddddd; padding: 8px;">Case Id</th>';
                body += '<th style="border: 1px solid #dddddd; padding: 8px;">Name of Borrower</th>';
                body += '<th style="border: 1px solid #dddddd; padding: 8px;">Property Type</th>';
                body += '</tr>';
                body += '</thead>';
                
                // Table body
                body += '<tbody>';
                for (Case c : cases) {
                    body += '<tr>';
                    body += '<td style="border: 1px solid #dddddd; padding: 8px;">' + (c.Loan_Application__r != null ? c.Loan_Application__r.Name : '') + '</td>';
                    body += '<td style="border: 1px solid #dddddd; padding: 8px;">' + (c.CaseNumber != null ? c.CaseNumber : '') + '</td>';
                    body += '<td style="border: 1px solid #dddddd; padding: 8px;">' + (c.Applicant__r != null ? c.Applicant__r.TabName__c : '') + '</td>';
                    body += '<td style="border: 1px solid #dddddd; padding: 8px;">' + (c.PropType__c != null ? c.PropType__c : '') + '</td>';
                    body += '</tr>';
                }
                body += '</tbody>';
                
                body += '</table>';
                body += '<p>Regards,</p>';
                // body += '<p>Your Company Name</p>'; // Optional: Include a signature or company name
                
                newMail.setHtmlBody(body);
                mailList.add(newMail);
                
            }
        }
        return mailList;
    }
    global void finish(Database.BatchableContext bc) {
        system.debug('Batch job finished');
    }
    
    global void execute(SchedulableContext sc) {
        BatchtoSendVendorEmails batchInstance = new BatchtoSendVendorEmails();
        Database.executeBatch(batchInstance);
    }
    // Custom Exception Class
    public class CustomException extends Exception {}
}