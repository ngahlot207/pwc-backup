public class LeadCommunicationMatrixHandler implements TriggerAction.AfterInsert, TriggerAction.AfterUpdate {
    public static void afterInsert(List<Lead> newList) {
        communicationMatrixHandlerMethod(newList, null);
    }
    public static void afterUpdate(List<Lead> newList, List<Lead> oldList) {
        Map<Id, Lead> leadMap = new Map<Id, Lead>(oldList);
        communicationMatrixHandlerMethod(newList, leadMap);
    }
    public static void communicationMatrixHandlerMethod(
        List<Lead> newList,
        Map<Id, Lead> leadMap
    ) {
        List<NotificationWrapper> notificationWrapList = new List<NotificationWrapper>();
        // List<NotificationWrapper> notificationWrapListNew = new List<NotificationWrapper>();

        List<string> recipientIds = new List<string>();
        List<string> recipientEmails = new List<string>();
        List<string> ReferleadIds = new List<string>();
        List<string> leadOwnerIds = new List<string>();
        List<string> leadIds = new List<string>();
        List<string> leadOwnerChangeIds = new List<string>();
        List<string> rmSmIds = new List<string>();
        List<string> InProleadIds = new List<string>();
        List<Case> caseRecrds = new List<Case>();
        Map<String, List<Lead>> leadRmSmMap = new Map<String, List<Lead>>();
        Map<String, List<Lead>> leadBBHMap = new Map<String, List<Lead>>();
        try {
            // EmailTemplate emailTeminPro = [select Id, DeveloperName from EmailTemplate where DeveloperName ='Lead_Decisoned_By_BBH_1721372044382'];
            String titleLabel = System.Label.Lead_Assigned;
            String bodyLabel = System.Label.Lead_Assigned_Body;
            String titleLabelInPro = System.Label.LeadDecByBBHSub;
            String bodyLabelInPro = System.Label.LeadDecByBBHBody;
            String titleLabelRef = System.Label.LeadReftoBBH;
            String bodyLabelRef = System.Label.LeadReftoBBHBody;
            OrgWideEmailAddress[] owea = [
                SELECT Id
                FROM OrgWideEmailAddress
                WHERE Address = :system.label.orgWideEmail
            ];
            String oweaAddress = owea.get(0).Id;
            Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage>();

            for (Lead ld : newList) {
                if (
                    (ld.Status != null &&
                    ld.Status == 'New' &&
                    (leadMap == null ||
                    ld.Status != leadMap.get(ld.Id).Status)) ||
                    (ld.Status != 'New' &&
                    ld.OwnerId != null &&
                    leadMap.get(ld.Id).OwnerId != null &&
                    ld.OwnerId != leadMap.get(ld.Id).OwnerId)
                ) {
                    leadIds.add(ld.Id);
                    system.debug('leadIds ' + leadIds.size());
                    leadOwnerIds.add(ld.OwnerId);
                    if (leadBBHMap.containsKey(ld.OwnerId)) {
                        leadBBHMap.get(ld.OwnerId).add(ld);
                    } else {
                        leadBBHMap.put(ld.OwnerId, new List<Lead>{ ld });
                    }
                    system.debug('leadBBHMap ' + leadBBHMap);
                } else if (
                    ld.Status != null &&
                    (ld.Status == 'Referred to BBH' || ld.Status == 'Referred to RSM') &&
                    (leadMap == null ||
                    ld.Status != leadMap.get(ld.Id).Status)
                ) {
                    ReferleadIds.add(ld.Id);
                } else if (
                    ld.Status != null &&
                    ld.Status == 'In Progress' &&
                    ld.RM_SM_Name__c != null &&
                    (leadMap == null ||
                    ld.Status != leadMap.get(ld.Id).Status)
                ) {
                    rmSmIds.add(ld.RM_SM_Name__c);
                    if (leadRmSmMap.containsKey(ld.RM_SM_Name__c)) {
                        leadRmSmMap.get(ld.RM_SM_Name__c).add(ld);
                    } else {
                        leadRmSmMap.put(ld.RM_SM_Name__c, new List<Lead>{ ld });
                    }
                }


                Lead oldLead = leadMap.get(ld.Id);
                if (ld.OwnerId != oldLead.OwnerId && ld.Status == 'New') {
                    leadOwnerChangeIds.add(ld.Id);
                    leadOwnerIds.add(ld.OwnerId);
                    if (leadBBHMap.containsKey(ld.OwnerId)) {
                        leadBBHMap.get(ld.OwnerId).add(ld);
                    } else {
                        leadBBHMap.put(ld.OwnerId, new List<Lead>{ ld });
                    }
                }
            }
            if(!leadOwnerChangeIds.isEmpty() && leadOwnerChangeIds.size() > 4){
                //if (!leadIds.isEmpty() && leadIds.size() > 4) {
                    EmailTemplate emailTemAssi = [
                        SELECT Id, DeveloperName
                        FROM EmailTemplate
                        WHERE DeveloperName = 'Lead_Assigned_1699527501917'
                    ];
                    BatchToLdSystemNotification batchCls = new BatchToLdSystemNotification(
                        leadOwnerChangeIds,
                        emailTemAssi,
                        oweaAddress
                    );
                    database.executebatch(batchCls, 5);
            }else {
                    if (!leadOwnerIds.isEmpty()) {
                        List<TeamHierarchy__c> teamHierrecrdsNew = [
                            SELECT employee__c, EmpRole__c, EmployeEmail__c
                            FROM TeamHierarchy__c
                            WHERE
                                employee__c IN :leadOwnerIds
                                AND EmpRole__c IN ('RM')
                        ];
                        system.debug('teamHierrecrdsNew ' + teamHierrecrdsNew);
                        if (!teamHierrecrdsNew.isEmpty()) {
                            for (TeamHierarchy__c teamhie : teamHierrecrdsNew) {
                                List<Lead> leadRecrds = leadBBHMap.get(
                                    teamhie.employee__c
                                );
                                if (!leadRecrds.isEmpty()) {
                                    for (Lead ld : leadRecrds) {
                                        recipientEmails.add(ld.OwnerEmail__c);
                                        recipientIds.add(ld.OwnerId);
                                        system.debug('ld.OwnerId ' + ld.OwnerId);
                                        String title = String.format(
                                            titleLabel,
                                            new List<String>{ ld.Lead_Id__c }
                                        );
                                        String body = String.format(
                                            bodyLabel,
                                            new List<String>{ ld.Lead_Id__c }
                                        );
                                        System.debug('Title: ' + title);
                                        System.debug('Body: ' + body);
                                        system.debug(
                                            'recipientIds ' + recipientIds
                                        );
                                        if (!recipientIds.isEmpty()) {

                                            CommunicationMatrixEmailNotification.sendEmailNew(
                                                oweaAddress,
                                                teamhie.employee__c,
                                                title,
                                                body,
                                                ld.Id,
                                                recipientEmails
                                            );

                                            
                                            notificationWrapList.add(
                                                NotificationWrapper.prepareNotificationData(
                                                    ld.Id,
                                                    new Set<String>(recipientIds),
                                                    title,
                                                    body,
                                                    '',
                                                    null,
                                                    null,
                                                    'Bell',
                                                    ''
                                                )
                                            );
                                            //forEmailNotification
                                            // notificationWrapListNew.add(NotificationWrapper.prepareNotificationData(ld.Id,null,teamhie.employee__c,oweaAddress,'User',recipientEmails,null,'Email',''));
                                            recipientIds.clear();
                                            recipientEmails.clear();
                                        }
                                    }
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
            

            if (!leadIds.isEmpty() && leadIds.size() > 4) {
                EmailTemplate emailTemAssi = [
                    SELECT Id, DeveloperName
                    FROM EmailTemplate
                    WHERE DeveloperName = 'Lead_Assigned_1699527501917'
                ];
                BatchToLdSystemNotification batchCls = new BatchToLdSystemNotification(
                    leadIds,
                    emailTemAssi,
                    oweaAddress
                );
                database.executebatch(batchCls, 5);
            } else {
                if (!leadOwnerIds.isEmpty()) {
                    List<TeamHierarchy__c> teamHierrecrdsNew = [
                        SELECT employee__c, EmpRole__c, EmployeEmail__c
                        FROM TeamHierarchy__c
                        WHERE
                            employee__c IN :leadOwnerIds
                            AND EmpRole__c IN ('BBH','DSA')
                    ];
                    system.debug('teamHierrecrdsNew ' + teamHierrecrdsNew);
                    if (!teamHierrecrdsNew.isEmpty()) {
                        for (TeamHierarchy__c teamhie : teamHierrecrdsNew) {
                            List<Lead> leadRecrds = leadBBHMap.get(
                                teamhie.employee__c
                            );
                            if (!leadRecrds.isEmpty()) {
                                for (Lead ld : leadRecrds) {
                                    recipientEmails.add(ld.OwnerEmail__c);
                                    recipientIds.add(ld.OwnerId);
                                    system.debug('ld.OwnerId ' + ld.OwnerId);
                                    String title = String.format(
                                        titleLabel,
                                        new List<String>{ ld.Lead_Id__c }
                                    );
                                    String body = String.format(
                                        bodyLabel,
                                        new List<String>{ ld.Lead_Id__c }
                                    );
                                    System.debug('Title: ' + title);
                                    System.debug('Body: ' + body);
                                    system.debug(
                                        'recipientIds ' + recipientIds
                                    );
                                    if (!recipientIds.isEmpty()) {
                                        // Messaging.SingleEmailMessage mailAs = new Messaging.SingleEmailMessage ();
                                        // mailAs.setOrgWideEmailAddressId(oweaAddress);
                                        // mailAs.setTargetObjectId(teamhie.employee__c);
                                        // mailAs.setSubject(title);
                                        // mailAs.setHtmlBody(body);
                                        // mailAs.setSaveAsActivity(false);
                                        // mailAs.setWhatId(ld.Id);
                                        // mailAs.setToAddresses(recipientEmails);
                                        // mails.add(mailAs);
                                        CommunicationMatrixEmailNotification.sendEmailNew(
                                            oweaAddress,
                                            teamhie.employee__c,
                                            title,
                                            body,
                                            ld.Id,
                                            recipientEmails
                                        );
                                        //CommunicationMatrixEmailNotification.sendEmail(emailTemAssi.Id,recipientIds, recipientEmails, new list<string>(), ld.Id, 'User');
                                        // CommunicationMatrixEmailNotification.notifyUsers(new set<string>(recipientIds),ld.Id,title,body);
                                        // AppleNotification.sendAppleNotification(title,body,new List<string>(recipientIds),ld.Id);
                                        //forbellNotification
                                        notificationWrapList.add(
                                            NotificationWrapper.prepareNotificationData(
                                                ld.Id,
                                                new Set<String>(recipientIds),
                                                title,
                                                body,
                                                '',
                                                null,
                                                null,
                                                'Bell',
                                                ''
                                            )
                                        );
                                        //forEmailNotification
                                        // notificationWrapListNew.add(NotificationWrapper.prepareNotificationData(ld.Id,null,teamhie.employee__c,oweaAddress,'User',recipientEmails,null,'Email',''));
                                        recipientIds.clear();
                                        recipientEmails.clear();
                                    }
                                }
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

            if (!ReferleadIds.isEmpty()) {
                system.debug('ReferleadIds ' + ReferleadIds);
                caseRecrds = [
                    SELECT
                        Id,
                        OwnerId,
                        OwnerEmail__c,
                        Lead__c,
                        Lead__r.Lead_Id__c,
                        LeadNum__c
                    FROM Case
                    WHERE
                        Lead__c IN :ReferleadIds
                        AND RecordType.Name = 'Lead Journey'
                        AND Status = 'New'
                ];
                ReferleadIds.clear();
                system.debug('caseRecrds ' + caseRecrds);
                if (!caseRecrds.isEmpty()) {
                    EmailTemplate emailTem = [
                        SELECT Id, DeveloperName
                        FROM EmailTemplate
                        WHERE DeveloperName = 'Lead_Refer_to_BBH_1721369461764'
                    ];
                    for (Case cas : caseRecrds) {
                        String title = String.format(
                            titleLabelRef,
                            new List<String>{ cas.Lead__r.Lead_Id__c }
                        );
                        String body = String.format(
                            bodyLabelRef,
                            new List<String>{ cas.Lead__r.Lead_Id__c }
                        );
                        System.debug('Title: ' + title);
                        System.debug('Body: ' + body);
                        recipientEmails.add(cas.OwnerEmail__c);
                        recipientIds.add(cas.OwnerId);
                        notificationWrapList.add(
                            NotificationWrapper.prepareNotificationData(
                                cas.Id,
                                new Set<String>(recipientIds),
                                title,
                                body,
                                '',
                                null,
                                null,
                                'Bell',
                                ''
                            )
                        );
                        //forEmailNotification
                        notificationWrapList.add(
                            NotificationWrapper.prepareNotificationData(
                                cas.Id,
                                new Set<String>(recipientIds),
                                '',
                                '',
                                'User',
                                new Set<String>(recipientEmails),
                                null,
                                'Email',
                                emailTem.Id
                            )
                        );
                        // CommunicationMatrixEmailNotification.sendEmail(emailTem.Id,recipientIds, recipientEmails, new list<string>(), cas.Id, 'User');
                        // CommunicationMatrixEmailNotification.notifyUsers(new set<string>(recipientIds),cas.Id,title,body);
                        // AppleNotification.sendAppleNotification(title,body,new List<string>(recipientIds),cas.Id);
                        recipientEmails.clear();
                        recipientIds.clear();
                    }
                }
            }
            if (!rmSmIds.isEmpty()) {
                List<TeamHierarchy__c> teamHierrecrds = [
                    SELECT employee__c, EmpRole__c, EmployeEmail__c
                    FROM TeamHierarchy__c
                    WHERE employee__c IN :rmSmIds AND EmpRole__c IN ('RM', 'SM')
                ];
                if (!teamHierrecrds.isEmpty()) {
                    for (TeamHierarchy__c teamhie : teamHierrecrds) {
                        recipientEmails.add(teamhie.EmployeEmail__c);
                        recipientIds.add(teamhie.employee__c);
                        List<Lead> leadRecrds = leadRmSmMap.get(
                            teamhie.employee__c
                        );
                        if (!leadRecrds.isEmpty()) {
                            for (Lead ld : leadRecrds) {
                                if (
                                    teamhie.EmpRole__c != null &&
                                    ld != null &&
                                    ((teamhie.EmpRole__c == 'RM' &&
                                    ld.Approved_Rejected__c != null &&
                                    ld.Approved_Rejected__c == 'Approved') ||
                                    teamhie.EmpRole__c == 'SM')
                                ) {
                                    String title = String.format(
                                        titleLabelInPro,
                                        new List<String>{ ld.Lead_Id__c }
                                    );
                                    String body = String.format(
                                        bodyLabelInPro,
                                        new List<String>{ ld.Lead_Id__c }
                                    );
                                    System.debug('Title: ' + title);
                                    System.debug('Body: ' + body);
                                    notificationWrapList.add(
                                        NotificationWrapper.prepareNotificationData(
                                            ld.Id,
                                            new Set<String>(recipientIds),
                                            title,
                                            body,
                                            '',
                                            null,
                                            null,
                                            'Bell',
                                            ''
                                        )
                                    );
                                    // CommunicationMatrixEmailNotification.notifyUsers(new set<string>(recipientIds),ld.Id,title,body);
                                    // AppleNotification.sendAppleNotification(title,body,new List<string>(recipientIds),ld.Id);
                                    // Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage ();
                                    // mail.setOrgWideEmailAddressId(oweaAddress);
                                    // mail.setTargetObjectId(teamhie.employee__c);
                                    // mail.setSubject(title);
                                    // mail.setHtmlBody(body);
                                    // mail.setSaveAsActivity(false);
                                    // mail.setWhatId(ld.Id);
                                    // mail.setToAddresses(recipientEmails);
                                    // mails.add(mail);
                                    // notificationWrapListNew.add(NotificationWrapper.prepareNotificationData(ld.Id,null,title,body,'User',recipientEmails,null,'Email',teamhie.employee__c));
                                    CommunicationMatrixEmailNotification.sendEmailNew(
                                        oweaAddress,
                                        teamhie.employee__c,
                                        title,
                                        body,
                                        ld.Id,
                                        recipientEmails
                                    );
                                    // CommunicationMatrixEmailNotification.sendEmail(emailTeminPro.Id,recipientIds, recipientEmails, new list<string>(), ld.Id, 'User');
                                    recipientIds.clear();
                                    recipientEmails.clear();
                                }
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

            if (!notificationWrapList.isEmpty()) {
                for (NotificationWrapper wrapObj : notificationWrapList) {
                    if (wrapObj.notificationType == 'Bell') {
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
                    } else if (wrapObj.notificationType == 'Email') {
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
        } catch (Exception ex) {
            system.debug(
                'Error Occured ' +
                    ex.getMessage() +
                    ' line ' +
                    ex.getLineNumber()
            );
        }
    }
}