public without sharing class LoanAppCommunicationMatrixHandler implements TriggerAction.AfterUpdate, TriggerAction.AfterInsert {
    public static void afterUpdate(
        List<LoanAppl__c> newList,
        List<LoanAppl__c> oldList
    ) {
        Map<Id, LoanAppl__c> loanMap = new Map<Id, LoanAppl__c>(oldList);
        List<LoanAppl__c> loanApps = new List<LoanAppl__c>();
        List<String> branchCodes = new List<String>();
        Set<String> rmsmUserSet = new Set<String>();
        for (LoanAppl__c loanApp : newList) {
            if (
                loanApp.BrchCode__c != null &&
                loanApp.LANRCUStatus__c != null &&
                (loanApp.LANRCUStatus__c == 'NEGATIVE' ||
                loanApp.LANRCUStatus__c == 'FRAUD') &&
                (loanMap == null ||
                loanApp.LANRCUStatus__c !=
                loanMap.get(loanApp.Id).LANRCUStatus__c)
            ) {
                branchCodes.add(loanApp.BrchCode__c);
                loanApps.add(loanApp);
            }
            if (loanApp.RMSMName__c != null) {
                loanApps.add(loanApp);
                rmsmUserSet.add(loanApp.RMSMName__c);
            }
        }
        communicationMatrixHandlerMethod(
            loanApps,
            loanMap,
            branchCodes,
            rmsmUserSet
        );
    }

    public static void afterInsert(List<LoanAppl__c> newList) {
        List<LoanAppl__c> loanApps = new List<LoanAppl__c>();
        List<String> branchCodes = new List<String>();
        Set<String> rmsmUserSet = new Set<String>();
        for (LoanAppl__c loanApp : newList) {
            branchCodes.add(loanApp.BrchCode__c);
            loanApps.add(loanApp);
            rmsmUserSet.add(loanApp.RMSMName__c);
        }
        communicationMatrixHandlerMethod(
            loanApps,
            null,
            branchCodes,
            rmsmUserSet
        );
    }

    public static void communicationMatrixHandlerMethod(
        List<LoanAppl__c> newList,
        Map<Id, LoanAppl__c> loanMap,
        List<String> branchCodes,
        Set<String> rmsmUserSet
    ) {
        try {
            NotificationWrapper notWrap;
            List<NotificationWrapper> notificationWrapList = new List<NotificationWrapper>();
            Set<String> recipientEmails = new Set<String>();
            Set<String> recipientEmailsNew = new Set<String>();
            List<String> recipientIds = new List<String>();
            //List<String> branchCodes = new List<String>();
            List<LoanAppl__c> loanApps = new List<LoanAppl__c>();
            // Query DSABranchJN records and populate rmtoDSABranchMap
            //Set<String> rmsmUserSet = new Set<String>();
            // Initialize map for RM to DSA Branch Join records
            Map<String, DSABrchJn__c> rmtoDSABranchMap = new Map<String, DSABrchJn__c>();

            // Get email templates
            EmailTemplate emailTem = getEmailTemplate(
                'RCU_Email_Template_of_loanApp_1726112313245'
            );
            EmailTemplate rmDsaMappingEmailTem = getEmailTemplate(
                'RM_DSA_mapping_template_1726551451467'
            );

            // Collect branch codes and loan apps based on LANRCUStatus
            /*for (LoanAppl__c loanApp : newList) {
                if (
                    loanMap != null &&
                    loanApp.BrchCode__c != null &&
                    loanApp.LANRCUStatus__c != null &&
                    (loanApp.LANRCUStatus__c == 'NEGATIVE' ||
                    loanApp.LANRCUStatus__c == 'FRAUD') &&
                    (loanMap == null ||
                    loanApp.LANRCUStatus__c !=
                    loanMap.get(loanApp.Id).LANRCUStatus__c)
                ) {
                    branchCodes.add(loanApp.BrchCode__c);
                    loanApps.add(loanApp);
                }
                if (loanApp.RMSMName__c != null) {
                    rmsmUserSet.add(loanApp.RMSMName__c);
                }
            }*/

            if (!rmsmUserSet.isEmpty()) {
                for (DSABrchJn__c dsaBranch : [
                    SELECT RMUsr__c, Account__c
                    FROM DSABrchJn__c
                    WHERE
                        RMUsr__c IN :rmsmUserSet
                        AND Account__c != NULL
                        AND InspectorID__c != NULL
                ]) {
                    rmtoDSABranchMap.put(
                        dsaBranch.RMUsr__c + '-' + dsaBranch.Account__c,
                        dsaBranch
                    );
                }
            }

            if (!branchCodes.isEmpty()) {
                List<TeamHierarchy__c> teamHierarchyRecords = [
                    SELECT
                        Product_Type__c,
                        Employee__c,
                        EmpRole__c,
                        EmployeEmail__c,
                        BranchCode__c,
                        EmpBrch__r.Name
                    FROM TeamHierarchy__c
                    WHERE
                        EmpRole__c IN (
                            'UW',
                            'CPA',
                            'ABH',
                            'RBH',
                            'ZSM',
                            'RM',
                            'SM'
                        )
                        AND BranchCode__c IN :branchCodes
                        AND employee__r.IsActive = TRUE
                ];

                Map<String, List<TeamHierarchy__c>> branchWithTH = new Map<String, List<TeamHierarchy__c>>();
                for (TeamHierarchy__c teamRecord : teamHierarchyRecords) {
                    if (branchWithTH.containsKey(teamRecord.BranchCode__c)) {
                        branchWithTH.get(teamRecord.BranchCode__c)
                            .add(teamRecord);
                    } else {
                        branchWithTH.put(
                            teamRecord.BranchCode__c,
                            new List<TeamHierarchy__c>{ teamRecord }
                        );
                    }
                }
                //Prepare RM-DSA Mapping Missing Email

                String title1;
                String body1;

                // Loop through LoanAppl__c records
                for (LoanAppl__c loanApp : newList) {
                    List<TeamHierarchy__c> teamHierarchyRecrds = branchWithTH.get(
                        loanApp.BrchCode__c
                    );

                    // Check if mapping exists in rmtoDSABranchMap
                    if (
                        !rmtoDSABranchMap.containsKey(
                            loanApp.RMSMName__c + '-' + loanApp.ChanelNme__c
                        )
                    ) {
                        // Prepare for email sending
                        recipientIds = new List<String>();
                        recipientEmails = new Set<String>();
                        String templateId1 = (rmDsaMappingEmailTem != null)
                            ? rmDsaMappingEmailTem.Id
                            : '';
                        if (rmDsaMappingEmailTem != null) {
                            title1 = rmDsaMappingEmailTem.Subject;
                            title1 = (loanApp.Name != null)
                                ? title1.replace(
                                      '{{{LoanAppl__c.Name}}}',
                                      loanApp.Name
                                  )
                                : title1;

                            body1 = rmDsaMappingEmailTem.HtmlValue;
                            body1 = body1.replaceAll('<br>', '\n');
                            body1 = body1.replaceAll('<[^>]+>', '');
                            body1 = (loanApp.RMSMName__c != null)
                                ? body1.replace(
                                      '{{{LoanAppl__c.RM__c}}}',
                                      loanApp.RMSMName__c
                                  )
                                : body1;
                            body1 = (loanApp.ChanelNme__c != null)
                                ? body1.replace(
                                      '{{{LoanAppl__c.ChanelNme__c}}}',
                                      loanApp.ChanelNme__c
                                  )
                                : body1;
                        }

                        System.debug('Subject: ' + title1);
                        System.debug('Body: ' + body1);

                        ////////////////
                        for (TeamHierarchy__c tH : teamHierarchyRecrds) {
                            if (
                                th.EmpRole__c == 'ABH' ||
                                th.EmpRole__c == 'RBH' ||
                                th.EmpRole__c == 'RBH' ||
                                th.EmpRole__c == 'ZSM'
                            ) {
                                recipientIds.add(tH.Employee__c);
                                recipientEmails.add(tH.EmployeEmail__c);
                            } else if (
                                (th.EmpRole__c == 'RM' ||
                                th.EmpRole__c == 'SM') &&
                                loanApp.RMSMName__c == tH.Employee__c
                            ) {
                                recipientIds.add(tH.Employee__c);
                                recipientEmails.add(tH.EmployeEmail__c);
                            }
                        }
                        //forbellNotification
                        notificationWrapList.add(
                            NotificationWrapper.prepareNotificationData(
                                loanApp.Id,
                                new Set<String>(recipientIds),
                                title1,
                                body1,
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
                                loanApp.Id,
                                new Set<String>(recipientIds),
                                '',
                                '',
                                'User',
                                recipientEmails,
                                null,
                                'Email',
                                templateId1
                            )
                        );
                    }
                    if (
                        loanApp.BrchCode__c != null &&
                        loanApp.LANRCUStatus__c != null &&
                        (loanApp.LANRCUStatus__c == 'NEGATIVE' ||
                        loanApp.LANRCUStatus__c == 'FRAUD') &&
                        (loanMap == null ||
                        loanApp.LANRCUStatus__c !=
                        loanMap.get(loanApp.Id).LANRCUStatus__c)
                    ) {
                        recipientIds = new List<String>();
                        recipientEmails = new Set<String>();
                        title1 = String.format(
                            System.Label.RCU_Status_Updation_Title,
                            new List<String>{
                                loanApp.Name,
                                loanApp.ApplicantName__c
                            }
                        );
                        body1 = String.format(
                            System.Label.RCU_Status_Updation_Body,
                            new List<String>{
                                loanApp.Name,
                                loanApp.ApplicantName__c
                            }
                        );

                        for (TeamHierarchy__c tH : teamHierarchyRecrds) {
                            recipientIds.add(tH.employee__c);
                            recipientEmails.add(tH.EmployeEmail__c);
                        }

                        if (!recipientIds.isEmpty()) {
                            //forbellNotification
                            notificationWrapList.add(
                                NotificationWrapper.prepareNotificationData(
                                    loanApp.Id,
                                    new Set<String>(recipientIds),
                                    title1,
                                    body1,
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
                                    loanApp.Id,
                                    new Set<String>(recipientIds),
                                    '',
                                    '',
                                    'User',
                                    recipientEmails,
                                    null,
                                    'Email',
                                    emailTem.Id
                                )
                            );
                        }
                    }
                }
            }
            for (NotificationWrapper wrapObj : notificationWrapList) {
                System.debug(wrapObj.recipientIds);
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
                    System.debug('Sending email with the following details:');
                    System.debug('Template ID: ' + wrapObj.templateId);
                    System.debug('Recipient IDs: ' + wrapObj.recipientIds);
                    System.debug(
                        'Recipient Emails: ' + wrapObj.recipientEmails
                    );
                    System.debug('Target ID: ' + wrapObj.targetId);
                    System.debug('Recipient Type: ' + wrapObj.recipientType);
                    CommunicationMatrixEmailNotification.sendEmail(
                        wrapObj.templateId,
                        new List<String>(wrapObj.recipientIds),
                        new List<String>(wrapObj.recipientEmails),
                        new List<String>(),
                        wrapObj.targetId,
                        wrapObj.recipientType
                    );
                    System.debug(
                        'Email sent successfully for template ID: ' +
                        wrapObj.templateId
                    );
                }
            }
        } catch (Exception ex) {
            System.debug(
                'Error Occured ' +
                    ex.getMessage() +
                    ' line ' +
                    ex.getLineNumber()
            );
        }
    }

    private static EmailTemplate getEmailTemplate(
        String templateDeveloperName
    ) {
        try {
            return [
                SELECT Id, Subject, HtmlValue, DeveloperName
                FROM EmailTemplate
                WHERE DeveloperName = :templateDeveloperName
                LIMIT 1
            ];
        } catch (QueryException e) {
            System.debug(
                'Email template \'' + templateDeveloperName + '\' not found.'
            );
            return null;
        }
    }
}