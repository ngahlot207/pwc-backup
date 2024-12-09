public class CaseCommunicationMatrixHandler implements TriggerAction.AfterInsert, TriggerAction.AfterUpdate {
    public static void afterInsert(List<Case> newList) {
        communicationMatrixHandlerMethod(newList, null);
    }
    
    public static void afterUpdate(List<Case> newList, List<Case> oldList) {
        Map<Id, Case> caseMap = new Map<Id, Case>(oldList);
        communicationMatrixHandlerMethod(newList, caseMap);
    }
    
    public static void communicationMatrixHandlerMethod(
        List<Case> newList,
        Map<Id, Case> caseMap
    ) {
        try {
            // Email Templates
            Map<String, EmailTemplate> emailTemplates = getEmailTemplates();
            List<NotificationWrapper> notificationWrapList = new List<NotificationWrapper>();
            // Hub Legal Manager Team Hierarchy Record
            List<TeamHierarchy__c> teamHierarchyRecords = [
                SELECT employee__c, EmpRole__c, EmployeEmail__c
                FROM TeamHierarchy__c
                WHERE EmpRole__c = 'LHM'
                LIMIT 1
            ];
            
            if (teamHierarchyRecords.isEmpty()) {
                throw new CustomException(
                    'No Team Hierarchy records found for role LHM.'
                );
            }
            
            TeamHierarchy__c hubLegalManager = teamHierarchyRecords[0];
            
            // Process cases
            List<Id> newCases = new List<Id>();
            Map<Id, List<Case>> contactWithCaseMap = new Map<Id, List<Case>>();
            List<Id> updatedCasesIds = new List<Id>();
            List<Id> lipVendorCasesIds = new List<Id>();
            List<Id> rcuCaseIds = new List<Id>();
            List<Id> rcuManCaseIds  = new List<Id>();
            
            for (Case cas : newList) {
                system.debug('contact id is  ' + cas.ContactId);
                system.debug('status is ' + isNewOrStatusChanged(cas, caseMap));
                // system.debug('condition is '  + cas.RecordType.Name + ' status ' +  cas.Status + ' cas.Status != caseMap.get(cas.Id).Status ' + caseMap);
                if (isNewOrStatusChanged(cas, caseMap)) {
                    if (cas.ContactId != null) {
                        newCases.add(cas.Id);
                        addToContactWithCaseMap(contactWithCaseMap, cas);
                    }
                } else if (isReportResultFinalOrNegative(cas,caseMap)) {
                    updatedCasesIds.add(cas.Id);
                } else if (isLipVendorCase(cas,caseMap)) {
                    lipVendorCasesIds.add(cas.Id);
                } else if (
                    cas.AgcRCUReportStatus__c != null &&
                    (cas.AgcRCUReportStatus__c == 'FRAUD' ||
                     cas.AgcRCUReportStatus__c == 'NEGATIVE') && cas.AccountId != null
                    && cas.ContactId != null && (caseMap == null || cas.AgcRCUReportStatus__c != caseMap.get(cas.Id).AgcRCUReportStatus__c)
                ) {
                    rcuCaseIds.add(cas.Id);
                }
            }
            system.debug('contactWithCaseMap  ' + contactWithCaseMap);
            system.debug('newCases are ' + newCases);
            system.debug('rcuCaseIds are ' + rcuCaseIds);
            if (!newCases.isEmpty()) {
                notificationWrapList =  handleNewCases(
                    newCases,
                    contactWithCaseMap,
                    emailTemplates,
                    hubLegalManager
                );
            }
            if (!updatedCasesIds.isEmpty()) {
                notificationWrapList = handleUpdatedCases(updatedCasesIds, hubLegalManager, emailTemplates);
            }
            if (!lipVendorCasesIds.isEmpty()) {
                notificationWrapList =  handleLipVendorCases(
                    lipVendorCasesIds,
                    hubLegalManager,
                    emailTemplates,
                    contactWithCaseMap
                );
            }
            if (!rcuCaseIds.isEmpty()) {
                //rcuCaseIds, emailTemplates, new Set<String>{ 'RCUM' };
                notificationWrapList =  handleRcuCases(rcuCaseIds, emailTemplates, new Set<String>{ 'RCUM' });
            }
            if (!rcuManCaseIds.isEmpty()) {
                notificationWrapList =   handleRcuCases(rcuManCaseIds, emailTemplates, new Set<String>{ 'CPA', 'UW' });
            }
            if(!notificationWrapList.isEmpty()){
                for(NotificationWrapper wrapObj : notificationWrapList){
                    if(wrapObj.notificationType == 'Bell'){
                        CommunicationMatrixEmailNotification.notifyUsers(
                            wrapObj.recipientIds,
                            wrapObj.targetId,
                            wrapObj.title,
                            wrapObj.body
                        );
                        AppleNotification.sendAppleNotification(
                            wrapObj.title,
                            wrapObj.body,
                            new List<String>(wrapObj.recipientIds),
                            wrapObj.targetId
                        );
                    }else if(wrapObj.notificationType == 'Email'){
                        if (wrapObj.ccReciepientEmails != null && !wrapObj.ccReciepientEmails.isEmpty()) {
                            CommunicationMatrixEmailNotification.sendEmail(
                                wrapObj.templateId, 
                                new List<String>(wrapObj.recipientIds), 
                                new List<String>(wrapObj.recipientEmails), 
                                new List<String>(wrapObj.ccReciepientEmails), 
                                wrapObj.targetId, 
                                wrapObj.recipientType
                            );
                        } else {
                            CommunicationMatrixEmailNotification.sendEmail(
                                wrapObj.templateId, 
                                new List<String>(wrapObj.recipientIds), 
                                new List<String>(wrapObj.recipientEmails), 
                                new List<String>(), 
                                wrapObj.targetId, 
                                wrapObj.recipientType
                            );
                        }
                        
                    }
                }
            }           
        } catch (Exception ex) {
            System.debug(
                'Error Occured ' + ex.getMessage() + ' line ' + ex.getLineNumber()
            );
        }
    }
    
    private static Map<String, EmailTemplate> getEmailTemplates() {
        Map<String, EmailTemplate> templates = new Map<String, EmailTemplate>();
        List<EmailTemplate> emailTemplates = [
            SELECT Id, DeveloperName
            FROM EmailTemplate
            WHERE
            DeveloperName IN (
                'Case_Assigned_Legal_1721627102311',
                'RCU_Email_Template_1722331169231',
                'Case_Assigned_Vetting_1721627219451',
                'Case_Assigned_TSR_1721627276013',
                'Case_Assigned_LIP_1721627379273',
                'RCU_Email_Template_New_1727417265814',
                'Case_Update_LIP_1727416776403'
            )
        ];
        for (EmailTemplate template : emailTemplates) {
            templates.put(template.DeveloperName, template);
        }
        return templates;
    }
    
    private static Boolean isNewOrStatusChanged(Case cas, Map<Id, Case> caseMap) {
        return cas.Status == 'New' &&
            (caseMap == null ||
             cas.Status != caseMap.get(cas.Id).Status);
    }
    
    private static Boolean isReportResultFinalOrNegative(Case cas,Map<Id, Case> caseMap) {
        return cas.ReportResult__c != null &&
            ((cas.ReportResult__c == 'Negative' ||
              cas.ReportResult__c == 'Final' ||
              cas.ReportResult__c == 'Withdrawn')) && (caseMap == null ||
                                                       cas.ReportResult__c != caseMap.get(cas.Id).ReportResult__c);
    }
    
    private static Boolean isLipVendorCase(Case cas,Map<Id, Case> caseMap) {
        return cas.ReportResult__c != null &&
            (cas.ReportResult__c == 'Negative' ||
             cas.ReportResult__c == 'Positive' ||
             cas.ReportResult__c == 'Credit Refer') && (caseMap == null ||
                                                        cas.ReportResult__c != caseMap.get(cas.Id).ReportResult__c);
    }
    
    private static void addToContactWithCaseMap(
        Map<Id, List<Case>> contactWithCaseMap,
        Case cas
    ) {
        if (contactWithCaseMap.containsKey(cas.ContactId)) {
            contactWithCaseMap.get(cas.ContactId).add(cas);
        } else {
            contactWithCaseMap.put(cas.ContactId, new List<Case>{ cas });
        }
    }
    
    private static List<NotificationWrapper> handleNewCases(
        List<Id> caseIds,
        Map<Id, List<Case>> contactWithCaseMap,
        Map<String, EmailTemplate> emailTemplates,
        TeamHierarchy__c hubLegalManager
    ) {
        // if (contactWithCaseMap.keySet().isEmpty()) {
        //     return;
        // }
        List<NotificationWrapper> notificationWrapList = new List<NotificationWrapper>();
        
        Map<Id, String> userWithEmailMap = getUserEmailMap(
            contactWithCaseMap.keySet(),
            'Email'
        );
        Map<Id, String> userWithIdMap = getUserEmailMap(
            contactWithCaseMap.keySet(),
            'Id'
        );
        system.debug('userWithEmailMap ' + userWithEmailMap);
        system.debug('userWithIdMap ' + userWithIdMap);
        Set<String> recipientEmails = new Set<String>();
        Set<String> recipientIds = new Set<String>();
        Set<String> hubLegalManEmails = new Set<String>();
        List<String> caseBranchCodes = new List<String>();
        Map<String, Set<String>> branchWithEmailTMMap = new Map<String, Set<String>>();
        Map<String, Set<String>> branchWithIdTMMap = new  Map<String, Set<String>> ();
        if (!caseIds.isEmpty()) {
            List<Case> newCases = [
                SELECT
                Id,
                CaseNumber,
                LAN__c,
                Property_Type__c,
                RecordType.Name,
                ContactId,
                ApplAssetId__c,
                ApplAssetId__r.PropType__c,
                PropType__c,Loan_Application__c,Loan_Application__r.BrchCode__c
                FROM Case
                WHERE Id IN :caseIds
            ];
            if (!newCases.isEmpty()) {
                for (Case cas : newCases) {
                    if (
                        cas.Loan_Application__c != null &&
                        cas.Loan_Application__r.BrchCode__c != null &&
                        cas.RecordType.Name == 'LIP Vendor case'
                    ) {
                        caseBranchCodes.add(cas.Loan_Application__r.BrchCode__c);
                    }
                }
                if (!caseBranchCodes.isEmpty()) {
                    branchWithIdTMMap = getTMEmailMap(caseBranchCodes,'Id');
                    branchWithEmailTMMap = getTMEmailMap(caseBranchCodes, 'Email');
                }
                for (Case cas : newCases) {
                    if (
                        cas.RecordType.Name == 'LIP Vendor case' ||
                        cas.RecordType.Name == 'TSR' ||
                        cas.RecordType.Name == 'Vetting' ||
                        cas.RecordType.Name == 'Legal'
                    ) {
                        String title = 'Case ID has been assigned';
                        String body = getBodyForNewCase(cas);
                        String key;
                        if (cas.RecordType.Name == 'Legal') {
                            key = 'Case_Assigned_Legal_1721627102311';
                            hubLegalManEmails.add(hubLegalManager.EmployeEmail__c);
                            recipientIds.add(hubLegalManager.employee__c);
                        } else if (cas.RecordType.Name == 'Vetting') {
                            key = 'Case_Assigned_Vetting_1721627219451';
                            hubLegalManEmails.add(hubLegalManager.EmployeEmail__c);
                            recipientIds.add(hubLegalManager.employee__c);
                        } else if (cas.RecordType.Name == 'TSR') {
                            key = 'Case_Assigned_TSR_1721627276013';
                            hubLegalManEmails.add(hubLegalManager.EmployeEmail__c);
                            recipientIds.add(hubLegalManager.employee__c);
                        } else if (cas.RecordType.Name == 'LIP Vendor case') {
                            key = 'Case_Assigned_LIP_1721627379273';
                            if (
                                cas.Loan_Application__c != null &&
                                cas.Loan_Application__r.BrchCode__c != null
                            ) {
                                if (!branchWithIdTMMap.keyset().isEmpty()) {
                                    Set<String> Ids = branchWithIdTMMap.get(
                                        cas.Loan_Application__r.BrchCode__c
                                    );
                                    recipientIds.addAll(Ids);
                                }
                                if (!branchWithEmailTMMap.keyset().isEmpty()) {
                                    Set<String> emails = branchWithEmailTMMap.get(
                                        cas.Loan_Application__r.BrchCode__c
                                    );
                                    hubLegalManEmails.addAll(emails);
                                }
                            }
                        }
                        recipientEmails.add(userWithEmailMap.get(cas.ContactId));
                        recipientIds.add(userWithIdMap.get(cas.ContactId));
                        
                        if (!recipientIds.isEmpty()) {
                            //forbellNotification
                            notificationWrapList.add(NotificationWrapper.prepareNotificationData(cas.Id,new Set<String>(recipientIds),title,body,'',null,null,'Bell',''));
                            //forEmailNotification
                            notificationWrapList.add(NotificationWrapper.prepareNotificationData(cas.Id,new Set<String>(recipientIds),'','','User',new Set<String>(recipientEmails),new List<String>(hubLegalManEmails),'Email',emailTemplates.get(key).Id));
                            //assigneNotificationWrapperContent
                            // CommunicationMatrixEmailNotification.sendEmail(
                            //     emailTemplates.get(key).Id,
                            //     new List<String>(recipientIds),
                            //     new List<String>(recipientEmails),
                            //     new List<String>(hubLegalManEmails),
                            //     cas.Id,
                            //     'User'
                            // );
                            // // CommunicationMatrixEmailNotification.notifyUsers(
                            //     new Set<String>(recipientIds),
                            //     cas.Id,
                            //     title,
                            //     body
                            // );
                            // AppleNotification.sendAppleNotification(
                            //     title,
                            //     body,
                            //     new List<String>(recipientIds),
                            //     cas.Id
                            // );
                            recipientIds.clear();
                            recipientEmails.clear();
                            hubLegalManEmails.clear();
                        }
                    }
                }
            }
        }
        if(!notificationWrapList.isEmpty()){
            return notificationWrapList;
        }
        return null;
    }
    
    private static Map<String, Set<String>> getTMEmailMap(
        List<String> branchIds,
        String key
    ) {
        Map<String, Set<String>> branchWithIdTMMap = new Map<String, Set<String>>();
        Map<String, Set<String>> branchWithEmailTMMap = new Map<String, Set<String>>();
        List<TeamHierarchy__c> teamHierarchyRecords = [
            SELECT employee__c, EmpRole__c, EmployeEmail__c, BranchCode__c
            FROM TeamHierarchy__c
            WHERE EmpRole__c IN ('ACM', 'RCM') AND BranchCode__c IN :branchIds
        ];
        
        for (TeamHierarchy__c teamRecord : teamHierarchyRecords) {
            if (branchWithIdTMMap.containsKey(teamRecord.BranchCode__c)) {
                branchWithIdTMMap.get(teamRecord.BranchCode__c)
                    .add(teamRecord.employee__c);
            } else {
                branchWithIdTMMap.put(
                    teamRecord.BranchCode__c,
                    new Set<String>{ teamRecord.employee__c }
                );
            }
            if (branchWithEmailTMMap.containsKey(teamRecord.BranchCode__c)) {
                branchWithEmailTMMap.get(teamRecord.BranchCode__c)
                    .add(teamRecord.EmployeEmail__c);
            } else {
                branchWithEmailTMMap.put(
                    teamRecord.BranchCode__c,
                    new Set<String>{ teamRecord.EmployeEmail__c }
                );
            }
        }
        if (key == 'Email') {
            return branchWithEmailTMMap;
        } else if (key == 'Id') {
            return branchWithIdTMMap;
        }
        return null;
    }
    
    private static Map<Id, String> getUserEmailMap(
        Set<Id> contactIds,
        String key
    ) {
        Map<Id, String> userWithEmailMap = new Map<Id, String>();
        Map<Id, String> userWithIdMap = new Map<Id, String>();
        List<User> userList = [
            SELECT Id, Email, ContactId
            FROM User
            WHERE ContactId IN :contactIds
        ];
        for (User u : userList) {
            userWithEmailMap.put(u.ContactId, u.Email);
            userWithIdMap.put(u.ContactId, u.Id);
        }
        if (key == 'Email') {
            return userWithEmailMap;
        } else if (key == 'Id') {
            return userWithIdMap;
        }
        return null;
    }
    
    private static String getBodyForNewCase(Case cas) {
        String body;
        if (cas.RecordType.Name == 'Legal') {
            body = String.format(
                System.Label.CaseAssignedBody,
                new List<String>{ cas.CaseNumber, cas.PropType__c, cas.LAN__c }
            );
        } else if (cas.RecordType.Name == 'Vetting') {
            body = String.format(
                System.Label.Case_Assigned_Body,
                new List<String>{ cas.CaseNumber, cas.PropType__c, cas.LAN__c }
            );
        } else if (cas.RecordType.Name == 'TSR') {
            body = String.format(
                System.Label.CaseAssignedBodyTSR,
                new List<String>{ cas.CaseNumber, cas.PropType__c, cas.LAN__c }
            );
        } else if (cas.RecordType.Name == 'LIP Vendor case') {
            body = String.format(
                System.Label.Case_Assigned_Body_LIP,
                new List<String>{ cas.CaseNumber, cas.LAN__c }
            );
        } else {
            body = 'Unknown Record Type';
        }
        return body;
    }
    
    private static List<NotificationWrapper> handleUpdatedCases(
        List<Id> caseIds,
        TeamHierarchy__c hubLegalManager,
        Map<String, EmailTemplate> emailTemplates
    ) {
        List<NotificationWrapper> notificationWrapList = new List<NotificationWrapper>();
        
        Set<String> recipientIds = new Set<String>();
        if (!caseIds.isEmpty()) {
            List<Case> updatedCases = [
                SELECT
                Id,
                ReportResult__c,
                OwnerId,
                CaseNumber,
                LAN__c,
                Property_Type__c,
                RecordType.Name,
                ContactId,
                ApplAssetId__c,
                ApplAssetId__r.PropType__c,
                PropType__c
                FROM Case
                WHERE Id IN :caseIds
            ];
            // recipientEmails.clear();
            if (!updatedCases.isEmpty()) {
                for (Case cas : updatedCases) {
                    if (
                        cas.ReportResult__c != null &&
                        (((cas.ReportResult__c == 'Negative' ||
                           cas.ReportResult__c == 'Final') &&
                          (cas.RecordType.Name == 'Legal' ||
                           cas.RecordType.Name == 'TSR')) ||
                         ((cas.ReportResult__c == 'Withdrawn' ||
                           cas.ReportResult__c == 'Final' ||
                           cas.ReportResult__c == 'Negative') &&
                          cas.RecordType.Name == 'Vetting'))
                    ) {
                        recipientIds.add(cas.OwnerId);
                        recipientIds.add(hubLegalManager.employee__c);
                        String title = getSubjectForUpdatedCase(cas);
                        String body = getBodyForUpdatedCase(cas);
                        if (!recipientIds.isEmpty()) {
                            notificationWrapList.add(NotificationWrapper.prepareNotificationData(cas.Id,new Set<String>(recipientIds),title,body,'',null,null,'Bell',''));
                            // //forEmailNotification
                            // notificationWrapList.add(NotificationWrapper.prepareNotificationData(cas.Id,new Set<String>(recipientIds),'','','User',new Set<String>(recipientEmails),new List<String>(hubLegalManEmails),'Email',emailTemplates.get(key).Id));
                            //     CommunicationMatrixEmailNotification.notifyUsers(
                            //         new Set<String>(recipientIds),
                            //         cas.Id,
                            //         title,
                            //         body
                            //     );
                            //     AppleNotification.sendAppleNotification(
                            //         title,
                            //         body,
                            //         new List<String>(recipientIds),
                            //         cas.Id
                            //     );
                            recipientIds.clear();
                        }
                    }
                }
            }
        }
        if(!notificationWrapList.isEmpty()){
            return notificationWrapList;
        }
        return null;
    }
    
    private static String getSubjectForUpdatedCase(Case cas) {
        String title;
        if (cas.RecordType.Name == 'Legal') {
            title = 'Case ID assigned to legal agency has been updated';
        } else if (cas.RecordType.Name == 'Vetting') {
            title = 'Case ID assigned to legal agency has been updated';
        } else if (cas.RecordType.Name == 'TSR') {
            title = 'Case ID assigned for TSR has been updated';
        } else if (cas.RecordType.Name == 'LIP Vendor case') {
            title = 'Case ID assigned for LIP has been updated';
        } else {
            title = 'Unknown Record Type';
        }
        return title;
    }
    private static String getBodyForUpdatedCase(Case cas) {
        String body;
        if (cas.RecordType.Name == 'Legal') {
            body = String.format(
                System.Label.Case_Updated_Body_Legal,
                new List<String>{ cas.CaseNumber, cas.LAN__c }
            );
        } else if (cas.RecordType.Name == 'Vetting') {
            body = String.format(
                System.Label.Case_Updated_Body_Vetting,
                new List<String>{ cas.CaseNumber, cas.LAN__c }
            );
        } else if (cas.RecordType.Name == 'TSR') {
            body = String.format(
                System.Label.Case_Updated_Body_TSR,
                new List<String>{ cas.CaseNumber, cas.LAN__c }
            );
        } else if (cas.RecordType.Name == 'LIP Vendor case') {
            body = String.format(
                System.Label.Case_Updated_Body_LIP,
                new List<String>{ cas.CaseNumber, cas.LAN__c }
            );
        } else {
            body = 'Unknown Record Type';
        }
        return body;
    }
    
    private static List<NotificationWrapper> handleLipVendorCases(
        List<Id> lipVendorCasesIds,
        TeamHierarchy__c hubLegalManager,
        Map<String, EmailTemplate> emailTemplates,
        Map<Id, List<Case>> contactWithCaseMap//
    ) {
        List<NotificationWrapper> notificationWrapList = new List<NotificationWrapper>();
        Set<String> recipientIds = new Set<String>();
        Set<String> recipientEmails = new Set<String>();
        Set<String> hubLegalManEmails = new Set<String>();
        List<String> caseBranchCodes = new List<String>();
        // Map<String, List<String>> branchWithEmailTMMap = new Map<String, List<String>>();
        Map<String, Set<String>> branchWithIdTMMap = new  Map<String, Set<String>> ();
        if (!lipVendorCasesIds.isEmpty()) {
            List<Case> lipVendorCases = [
                SELECT
                Id,
                OwnerId,
                Owner.Email,
                ReportResult__c,
                CaseNumber,
                LAN__c,
                Loan_Application__c,
                Loan_Application__r.BrchCode__c,
                Property_Type__c,
                RecordType.Name,
                ContactId
                FROM Case
                WHERE Id IN :lipVendorCasesIds
            ];
            if (!lipVendorCases.isEmpty()) {
                for (Case cas : lipVendorCases) {
                    if (
                        cas.Loan_Application__c != null &&
                        cas.Loan_Application__r.BrchCode__c != null &&
                        cas.RecordType.Name == 'LIP Vendor case'
                    ) {
                        caseBranchCodes.add(cas.Loan_Application__r.BrchCode__c);
                    }
                }
                if (!caseBranchCodes.isEmpty()) {
                    branchWithIdTMMap = getTMEmailMap(caseBranchCodes,'Id');
                    for (Case cas : lipVendorCases) {  
                        if (
                            cas.Loan_Application__c != null &&
                            cas.Loan_Application__r.BrchCode__c != null
                        ) {
                            if (!branchWithIdTMMap.keyset().isEmpty()) {
                                Set<String> acmRcmIds = branchWithIdTMMap.get(
                                    cas.Loan_Application__r.BrchCode__c
                                );
                                recipientIds.addAll(acmRcmIds);
                            }
                        }
                        
                        //
                        String key = 'Case_Update_LIP_1727416776403';
                        Map<Id, String> userWithEmailMap = getUserEmailMap(
                            contactWithCaseMap.keySet(),
                            'Email'
                        );
                        
                        //
                        recipientIds.add(cas.OwnerId);
                        recipientEmails.add(cas.Owner.Email);
                        String title = 'Case ID assigned for LIP has been updated';
                        String body = String.format(
                            System.Label.Case_Updated_Body_LIP,
                            new List<String>{ cas.CaseNumber,cas.LAN__c }
                        );
                        if (!recipientIds.isEmpty()) {
                            notificationWrapList.add(NotificationWrapper.prepareNotificationData(cas.Id,new Set<String>(recipientIds),title,body,'',null,null,'Bell',''));
                            // //forEmailNotification
                            notificationWrapList.add(NotificationWrapper.prepareNotificationData(cas.Id,new Set<String>(recipientIds),'','','User',new Set<String>(recipientEmails),new List<String>(hubLegalManEmails),'Email',emailTemplates.get(key).Id));
                            //     CommunicationMatrixEmailNotification.notifyUsers(
                            //         new Set<String>(recipientIds),
                            //         cas.Id,
                            //         title,
                            //         body
                            //     );
                            //     AppleNotification.sendAppleNotification(
                            //         title,
                            //         body,
                            //         new List<String>(recipientIds),
                            //         cas.Id
                            //     );
                            recipientIds.clear();
                        }
                    } 
                }
            }
        }
        if(!notificationWrapList.isEmpty()){
            return notificationWrapList;
        }
        return null;
    }
    
    private static List<NotificationWrapper> handleRcuCases(
        List<Id> caseIds,
        Map<String, EmailTemplate> emailTemplates,
        Set<String> roles
    ) {
        List<NotificationWrapper> notificationWrapList = new List<NotificationWrapper>();
        if (!caseIds.isEmpty()) { 
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:system.label.orgWideEmail];
            String oweaAddress = owea.get(0).Id;
            Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage>();
            
            List<String> recipientIds = new List<String>();
            List<String> recipientEmails = new List<String>();
            List<String> caseBranchCodes = new List<String>();
            List<Case> rcuCases = new  List<Case> ();
            rcuCases = [
                SELECT
                Id,
                ReportResult__c,Branch_Name__c,
                Loan_Application__c,
                Loan_Application__r.Applicant__r.FullName__c,
                OwnerId,
                CaseNumber,
                LAN__c,
                Property_Type__c,
                RecordType.Name,
                ContactId,
                AgcRCUReportStatus__c,
                Loan_Application__r.BrchCode__c
                FROM Case
                WHERE Id IN :caseIds 
            ];
            
            if (!rcuCases.isEmpty()) {
                for (Case cas : rcuCases) {
                    if (
                        cas.Loan_Application__c != null &&
                        cas.Loan_Application__r.BrchCode__c != null &&
                        cas.RecordType.Name == 'RCU'
                    ) {
                        caseBranchCodes.add(cas.Loan_Application__r.BrchCode__c);
                    }
                }
                
                if (!caseBranchCodes.isEmpty()) {
                    
                    List<TeamHierarchy__c> teamHierarchyRecords = [
                        SELECT employee__c, EmpRole__c, EmployeEmail__c, BranchCode__c,EmpBrch__r.Name
                        FROM TeamHierarchy__c
                        WHERE EmpRole__c IN :roles AND BranchCode__c IN :caseBranchCodes
                    ];
                    
                    Map<String, List<TeamHierarchy__c>> branchWithTH = new Map<String, List<TeamHierarchy__c>>();
                    for (TeamHierarchy__c teamRecord : teamHierarchyRecords) {
                        if (branchWithTH.containsKey(teamRecord.BranchCode__c)) {
                            branchWithTH.get(teamRecord.BranchCode__c).add(teamRecord);
                        } else {
                            branchWithTH.put(
                                teamRecord.BranchCode__c,
                                new List<TeamHierarchy__c>{ teamRecord }
                            );
                        }
                    }
                    
                    for (Case cas : rcuCases) {
                        if (
                            cas.Loan_Application__c != null &&
                            cas.Loan_Application__r.BrchCode__c != null
                        ) {
                            List<TeamHierarchy__c> teamHierarchyRecrds = branchWithTH.get(
                                cas.Loan_Application__r.BrchCode__c
                            );
                            String title = String.format(
                                System.Label.Case_Updated_by_RCU_Title,
                                new List<String>{ cas.CaseNumber, cas.LAN__c ,cas.Branch_Name__c}
                            );
                            String body = String.format(
                                System.Label.case_updated_by_RCU,
                                new List<String>{ cas.CaseNumber, cas.LAN__c,cas.Loan_Application__r.Applicant__r.FullName__c ,cas.Branch_Name__c}
                            );
                            
                            if (!teamHierarchyRecrds.isEmpty()) {
                                for (TeamHierarchy__c tH : teamHierarchyRecrds) {
                                    recipientIds.add(tH.employee__c);
                                    recipientEmails.add(tH.EmployeEmail__c);
                                    if (!recipientIds.isEmpty()) {
                                        
                                        // CommunicationMatrixEmailNotification.notifyUsers(
                                        //     new Set<String>(recipientIds),
                                        //     cas.Id,
                                        //     title,
                                        //     body
                                        // );
                                        // AppleNotification.sendAppleNotification(
                                        //     title,
                                        //     body,
                                        //     new List<String>(recipientIds),
                                        //     cas.Id
                                        // );
                                        // CommunicationMatrixEmailNotification.sendEmailNew(oweaAddress,tH.employee__c, title,body,cas.Id,recipientEmails );
                                        // Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage ();
                                        // mail.setOrgWideEmailAddressId(oweaAddress);
                                        // mail.setTargetObjectId(tH.employee__c);
                                        // mail.setSubject(title);
                                        // mail.setHtmlBody(body);
                                        // mail.setSaveAsActivity(false);
                                        // mail.setWhatId(cas.Id);
                                        // mail.setToAddresses(recipientEmails);
                                        // mails.add(mail);
                                        
                                    }
                                }
                            }
                            if(!recipientIds.isEmpty()){
                                notificationWrapList.add(NotificationWrapper.prepareNotificationData(cas.Id,new Set<String>(recipientIds),title,body,'',null,null,'Bell',''));
                                //forEmailNotification
                                notificationWrapList.add(NotificationWrapper.prepareNotificationData(cas.Id,new Set<String>(recipientIds),'','','User',new Set<String>(recipientEmails),null,'Email',emailTemplates.get('RCU_Email_Template_New_1727417265814').Id));
                            }  
                        }
                    }
                    // if (!mails.isempty()) {          
                    //     system.debug('Mail Body:'+mails);                        
                    //     Messaging.sendEmail(mails);
                    //     mails.clear();
                    // }
                }
            }
        }
        if(!notificationWrapList.isEmpty()){
            system.debug('notificationWrapList rcu' + notificationWrapList);
            return notificationWrapList;
        }
        return null;
    }
    
    // Custom Exception Class
    public class CustomException extends Exception {
    }
}