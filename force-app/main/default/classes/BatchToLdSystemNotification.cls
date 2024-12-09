global class BatchToLdSystemNotification implements Database.Batchable<SObject> {
    
    private List<String> leadIds;
    EmailTemplate emailTemAssi;
    String oweaAddress;
    // Constructor to initialize leadIds
    global BatchToLdSystemNotification(List<String> leadIds,EmailTemplate emailTemAssi,String owea) {
        this.leadIds = leadIds;
        this.emailTemAssi = emailTemAssi;
        this.oweaAddress = owea;
    }
    
    // Start method for batch processing
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('Starting batch job');
        return Database.getQueryLocator([SELECT Id,OwnerId,Status,Lead_Id__c,OwnerEmail__c FROM Lead WHERE Id IN :leadIds]);
    }
    
    global void execute(Database.BatchableContext bc, List<Lead> leadList) {
        system.debug('Processing batch records');
        Map<String, List<Lead>> leadBBHMap = new Map<String, List<Lead>>();
        Map<String, Set<String>> ownerEmailsMap = new Map<String, Set<String>>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        String titleLabel = System.Label.Lead_Assigned;
        String bodyLabel = System.Label.Lead_Assigned_Body;
        
        // Organize leads by owner and collect emails
        for (Lead ld : leadList) {
            if(ld.OwnerId != null){
                System.debug('Processing Lead ID: ' + ld.Id);
                if (!leadBBHMap.containsKey(ld.OwnerId)) {
                    leadBBHMap.put(ld.OwnerId, new List<Lead>());
                    ownerEmailsMap.put(ld.OwnerId, new Set<String>());
                }
                leadBBHMap.get(ld.OwnerId).add(ld);
                ownerEmailsMap.get(ld.OwnerId).add(ld.OwnerEmail__c);
            }
        }
        
        // Query for team hierarchy records
        List<TeamHierarchy__c> teamHierarchyRecords = [SELECT employee__c, EmpRole__c, EmployeEmail__c FROM TeamHierarchy__c WHERE employee__c IN :leadBBHMap.keySet() AND EmpRole__c IN ('BBH', 'RM', 'SM')];
        system.debug('teamHierarchyRecords ' + teamHierarchyRecords);
        
        if (!teamHierarchyRecords.isEmpty()) {
            for (TeamHierarchy__c teamHierarchy : teamHierarchyRecords) {
                List<Lead> leadsForOwner = leadBBHMap.get(teamHierarchy.employee__c);
                if (leadsForOwner != null && !leadsForOwner.isEmpty()) {
                    for (Lead ld : leadsForOwner) {
                        String title = String.format(titleLabel, new List<String> {ld.Lead_Id__c});
                        String body = String.format(bodyLabel, new List<String> {ld.Lead_Id__c});
                        System.debug('Title: ' + title);
                        System.debug('Body: ' + body);
                        
                        // Send communication matrix email notifications
                        CommunicationMatrixEmailNotification.notifyUsers(new Set<String> {ld.OwnerId}, ld.Id, title, body);
                        
                        // Send Apple push notifications
                        AppleNotification.sendAppleNotification(title, body, new List<String> {ld.OwnerId}, ld.Id);
                        
                        // Prepare and add email messages
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setOrgWideEmailAddressId(oweaAddress);
                        mail.setTargetObjectId(ld.OwnerId);
                        mail.setSubject(title);
                        mail.setHtmlBody(body);
                        mail.setSaveAsActivity(false);
                        mail.setWhatId(ld.Id);
                        mail.setToAddresses(new List<String>(ownerEmailsMap.get(ld.OwnerId)));
                        system.debug('mail.setToAddresses ' + new List<String>(ownerEmailsMap.get(ld.OwnerId)));
                        system.debug('mail  ' + mail);
                        mails.add(mail);
                    }
                }
            }
        }
        
        // Send all collected emails
        if (!mails.isEmpty()) {
            system.debug('Mail Body: ' + mails);
            Messaging.sendEmail(mails); 
            system.debug('Mail Body finished ');
        }
    }
    
    
    global void finish(Database.BatchableContext bc) {
        system.debug('Batch job finished');
    }
    
}