public class LoanAppealCommunicationMatrixHandler implements TriggerAction.AfterInsert, TriggerAction.AfterUpdate {
    
    public static void afterInsert(List<LoanAppeal__c> newList) {
        communicationMatrixHandlerMethod(newList, null);
    }
    
    public static void afterUpdate(List<LoanAppeal__c> newList, List<LoanAppeal__c> oldList) {
        Map<Id, LoanAppeal__c> loanAppealOldMap = new Map<Id, LoanAppeal__c>(oldList);
        communicationMatrixHandlerMethod(newList, loanAppealOldMap);
    }
    
    public static void communicationMatrixHandlerMethod(List<LoanAppeal__c> newList, Map<Id, LoanAppeal__c> loanAppealOldMap) {
        try {
            List<NotificationWrapper> notificationWrapList = new List<NotificationWrapper>();

            List<String> recipientIds = new List<String>();
            List<String> recipientEmails = new List<String>();
            List<LoanAppeal__c> loanAppealsNew = new List<LoanAppeal__c>();
            Set<String> approvedIds = new Set<String>();
            Set<String> recommenderIds = new Set<String>();
            Set<String> loanBranIds = new Set<String> ();
            // Set<String> loanIds = new Set<String>();
            List<LoanAppeal__c> roiPfLoanApps = new List<LoanAppeal__c>();
            // Set<String> loanAppIds = new Set<String>();
            List<LoanAppeal__c> loanAppsNew = new List<LoanAppeal__c>();
            List<LoanAppeal__c> loanApps = new List<LoanAppeal__c>();
            Set<String> loanAppIdsNew = new Set<String> ();
            EmailTemplate emailTem = getEmailTemplate('Loan_Appeal_Raised_1721649485552');
            EmailTemplate emailTemApp = getEmailTemplate('Loan_Appeal_Approved_1721650173662');
            EmailTemplate emailTemRej = getEmailTemplate('Loan_Appeal_Rejected_1721650106817');
            EmailTemplate emailTemRequest = getEmailTemplate('Request_for_Loan_Appeal_Raised_1729597066402');
            
            for (LoanAppeal__c loanApp : newList) {
                loanAppIdsNew.add(loanApp.id);
                // if (loanApp.Status__c != null && loanApp.Approver__c != null && loanApp.RecordType.Name == 'Loan Term Negotiation' && loanApp.Status__c == 'New' && (loanAppealOldMap == null || loanApp.Status__c != loanAppealOldMap.get(loanApp.Id).Status__c)) {
                //     loanAppIds.add(loanApp.id);
                //     approvedIds.add(loanApp.Approver__c);
                // } else if (loanApp.Status__c != null && loanApp.RecordType.Name == 'Loan Term Negotiation' && loanApp.Status__c == 'Reject' && (loanAppealOldMap == null || loanApp.Status__c != loanAppealOldMap.get(loanApp.Id).Status__c)) {
                //     recipientEmails.add(loanApp.OwnerEmail__c);
                //     recipientIds.add(loanApp.OwnerId);
                //     String title = 'Appeal for Loan Term Negotiation has been rejected';
                //     String body = String.format(System.Label.Loan_Appean_Raised_Body, new List<String>{loanApp.AppName__c, 'rejected'});
                //     sendCommunication(recipientIds, recipientEmails, emailTemRej.Id, loanApp.Id, title, body);
                //     recipientIds.clear();
                //     recipientEmails.clear();
                // } else if (loanApp.Status__c != null && loanApp.RecordType.Name == 'Loan Term Negotiation' && loanApp.Status__c == 'Approve' && (loanAppealOldMap == null || loanApp.Status__c != loanAppealOldMap.get(loanApp.Id).Status__c)) {
                //     recipientEmails.add(loanApp.OwnerEmail__c);
                //     recipientIds.add(loanApp.OwnerId);
                //     String title = 'Appeal for Loan Term Negotiation has been approved';
                //     String body = String.format(System.Label.Loan_Appean_Raised_Body, new List<String>{loanApp.AppName__c, 'approved'});
                //     sendCommunication(recipientIds, recipientEmails, emailTemApp.Id, loanApp.Id, title, body);
                //     recipientIds.clear();
                //     recipientEmails.clear();
                // }else if(loanApp.Status__c != null && loanApp.Recommender__c != null && loanApp.RecordType.Name == 'Roi Pf Correction' && (loanApp.Status__c == 'New' || loanApp.Status__c == 'In Progress') && (loanAppealOldMap == null || loanApp.Status__c != loanAppealOldMap.get(loanApp.Id).Status__c)) {
                //     loanAppIds.add(loanApp.Id);
                //     approvedIds.add(loanApp.Recommender__c);
                // } else if (loanApp.Status__c != null && loanApp.RecordType.Name == 'Roi Pf Correction' && loanApp.Status__c == 'Approve' && (loanAppealOldMap == null || loanApp.Status__c != loanAppealOldMap.get(loanApp.Id).Status__c)) {
                //     loanIds.add(loanApp.Id);
                // }
            }
            if(!loanAppIdsNew.isEmpty()){
                List<LoanAppeal__c> loanAppeals = [SELECT Id, LAN__c,CreatedById,CreatedByUserEmail__c,LoanAppl__r.BrchCode__c,OwnerEmail__c,OwnerId,Status__c,Recommender__c,RecordType.Name,AppName__c,Approver__c,Decision__c,
                                                   LoanAppl__c,LoanAppl__r.Name,LoanAppl__r.Applicant__r.TabName__c,
                                                   LoanAppl__r.Application_Level_Assessment_Program__c,LoanAppl__r.SanLoanAmt__c, Recommender__r.Email,Approver__r.Email,
                                                   ZoneRoi__c,LoanAppl__r.LeadROI__c,LoanAppl__r.PFInPercentage__c,RevisedRoi__c,RevisedPF__c FROM LoanAppeal__c WHERE Id IN: loanAppIdsNew];
                if(!loanAppeals.isEmpty()){
                    system.debug('loanAppeals size is ' +  loanAppeals.size());
                    for (LoanAppeal__c loanApp : loanAppeals) {
                        // loanAppIdsNew.add(loanApp.Id);
                        system.debug('loanApp is ' +  loanApp);
                        system.debug('loanApp Status is ' +  loanApp.Status__c);
                        //system.debug('loanApp old Status is ' +  loanAppealOldMap.get(loanApp.Id).Status__c);
                        system.debug('loanApp record type is ' +  loanApp.RecordType.Name);
                        if (loanApp.Status__c != null && loanApp.RecordType.Name == 'Loan Term Negotiation' && loanApp.Status__c == 'New' && (loanAppealOldMap == null || loanApp.Status__c != loanAppealOldMap.get(loanApp.Id).Status__c) && loanApp.LoanAppl__c != null && loanApp.LoanAppl__r.BrchCode__c != null) {
                            loanApps.add(loanApp);
                            loanBranIds.add(loanApp.LoanAppl__r.BrchCode__c);
                        } else if (loanApp.Status__c != null && loanApp.RecordType.Name == 'Loan Term Negotiation' && loanApp.Status__c == 'Reject' && (loanAppealOldMap == null || loanApp.Status__c != loanAppealOldMap.get(loanApp.Id).Status__c)) {
                            recipientEmails.add(loanApp.CreatedByUserEmail__c);
                            recipientIds.add(loanApp.CreatedById);
                            String title = 'Appeal for Loan Term Negotiation has been rejected';
                            String body = String.format(System.Label.Loan_Appean_Raised_Body, new List<String>{loanApp.AppName__c, 'rejected'});
                            //forbellNotification
						    notificationWrapList.add(NotificationWrapper.prepareNotificationData(loanApp.LoanAppl__c,new Set<String>(recipientIds),title,body,'',null,null,'Bell','')); // changed loanApp.Id to  loanApp.LoanAppl__c for LAK-9584
						    //forEmailNotification
						    notificationWrapList.add(NotificationWrapper.prepareNotificationData(loanApp.Id,new Set<String>(recipientIds),'','','User',new Set<String>(recipientEmails),null,'Email',emailTemRej.Id)); // changed loanApp.Id to  loanApp.LoanAppl__c for LAK-9584
                          //  sendCommunication(recipientIds, recipientEmails, emailTemRej.Id, loanApp.Id, title, body);
                            recipientIds.clear();
                            recipientEmails.clear();
                        } else if (loanApp.Status__c != null && loanApp.RecordType.Name == 'Loan Term Negotiation' && loanApp.Status__c == 'Approve' && (loanAppealOldMap == null || loanApp.Status__c != loanAppealOldMap.get(loanApp.Id).Status__c)) {
                            recipientEmails.add(loanApp.CreatedByUserEmail__c);
                            recipientIds.add(loanApp.CreatedById);
                            String title = 'Appeal for Loan Term Negotiation has been approved';
                            String body = String.format(System.Label.Loan_Appean_Raised_Body, new List<String>{loanApp.AppName__c, 'approved'});
                            //forbellNotification
						    notificationWrapList.add(NotificationWrapper.prepareNotificationData(loanApp.LoanAppl__c,new Set<String>(recipientIds),title,body,'',null,null,'Bell',''));// changed loanApp.Id to  loanApp.LoanAppl__c for LAK-9584
						    //forEmailNotification
						    notificationWrapList.add(NotificationWrapper.prepareNotificationData(loanApp.Id,new Set<String>(recipientIds),'','','User',new Set<String>(recipientEmails),null,'Email',emailTemApp.Id));// changed loanApp.Id to  loanApp.LoanAppl__c for LAK-9584
                           // sendCommunication(recipientIds, recipientEmails, emailTemApp.Id, loanApp.Id, title, body);
                            recipientIds.clear();
                            recipientEmails.clear();
                        }else if(loanApp.Status__c != null && loanApp.Decision__c =='Forward To Recommender' && loanApp.Recommender__c != null && loanApp.RecordType.Name == 'Roi Pf Correction' && loanApp.Status__c == 'In Progress' && (loanAppealOldMap == null || loanApp.Status__c != loanAppealOldMap.get(loanApp.Id).Status__c)) {
                            loanAppsNew.add(loanApp);
                            approvedIds.add(loanApp.Recommender__c);
                        } else if(loanApp.Status__c != null && 
                                  loanApp.Decision__c == 'Forward To Approver' && 
                                  loanApp.Approver__c != null && 
                                  loanApp.RecordType.Name == 'Roi Pf Correction' && 
                                  loanApp.Status__c == 'In Progress' && 
                                  (loanAppealOldMap == null || 
                                   loanAppealOldMap.get(loanApp.Id).Status__c != null)) {
                                       System.debug('inside approved');
                                       loanAppsNew.add(loanApp);
                                       approvedIds.add(loanApp.Approver__c);
                                   }
                        else if (loanApp.Status__c != null && loanApp.RecordType.Name == 'Roi Pf Correction' && loanApp.Status__c == 'Approve' && (loanAppealOldMap == null || loanApp.Status__c != loanAppealOldMap.get(loanApp.Id).Status__c)) {
                            roiPfLoanApps.add(loanApp);
                        }
                    }
                }                         
            }
            if(!loanBranIds.isEmpty()){
                Map<String, Set<String>> branchWithIdTMMap = new Map<String, Set<String>>();
                Map<String, Set<String>> branchWithEmailTMMap = new Map<String, Set<String>>();
                List<TeamHierarchy__c> teamHierarchyRecords = [
                    SELECT employee__c, EmpRole__c, EmployeEmail__c, BranchCode__c
                    FROM TeamHierarchy__c
                    WHERE EmpRole__c IN ('UW', 'CPA') AND BranchCode__c IN :loanBranIds
                ];
                if(!teamHierarchyRecords.isEmpty()){
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
                    for (LoanAppeal__c loanApp : loanApps) {
                        Set<String> recipientIdsNew = new Set<String>();
                        Set<String> recipientEmailsNew = new Set<String>();
                        Set<String > emails = branchWithEmailTMMap.get(loanApp.LoanAppl__r.BrchCode__c);
                        Set<String > ids = branchWithIdTMMap.get(loanApp.LoanAppl__r.BrchCode__c);
                        // if (teamHierRec != null) {
                        recipientEmailsNew.addAll(emails);
                        recipientIdsNew.addAll(ids);
                        String title = 'Appeal for Loan Term Negotiation has been raised';
                        String body = String.format(System.Label.Loan_Appean_Raised_Body, new List<String>{loanApp.LoanAppl__r.Name, 'raised'});
                        // sendCommunication(recipientIds, recipientEmails, emailTem.Id, loanApp.Id, title, body);
                        //forbellNotification
						notificationWrapList.add(NotificationWrapper.prepareNotificationData(loanApp.LoanAppl__c,new Set<String>(recipientIdsNew),title,body,'',null,null,'Bell','')); // changed loanApp.Id to  loanApp.LoanAppl__c for LAK-9584
						//forEmailNotification
						notificationWrapList.add(NotificationWrapper.prepareNotificationData(loanApp.Id,new Set<String>(recipientIdsNew),'','','User',new Set<String>(recipientEmailsNew),null,'Email',emailTem.Id)); // changed loanApp.Id to  loanApp.LoanAppl__c for LAK-9584
                        // CommunicationMatrixEmailNotification.notifyUsers(new Set<String>(recipientIdsNew), loanApp.Id, title, body);
                        // AppleNotification.sendAppleNotification(title, body, new List<String>(recipientIdsNew), loanApp.Id);
                        // CommunicationMatrixEmailNotification.sendEmail(emailTem.Id, new List<String>(recipientIdsNew), new List<String>(recipientEmailsNew), new List<String>(), loanApp.Id, 'User');
                        system.debug('notificationWrapList new is'  + notificationWrapList);
                        recipientIds.clear();
                        recipientEmails.clear();
                        // }
                    }
                }  
            }
            if (!approvedIds.isEmpty()) {
                
                Map<String, TeamHierarchy__c> approvedmap = new Map<String, TeamHierarchy__c>();
                
                List<TeamHierarchy__c> teamHierarchyRecords = [SELECT employee__c, EmpRole__c, EmployeEmail__c FROM TeamHierarchy__c WHERE employee__c IN :approvedIds];
                for (TeamHierarchy__c teamHier : teamHierarchyRecords) {
                    approvedmap.put(teamHier.employee__c, teamHier);
                }
                
                for (LoanAppeal__c loanApp : loanAppsNew) {
                    if(loanApp.RecordType.Name == 'Roi Pf Correction'){
                        system.debug('approvedmap '+ approvedmap);
                        TeamHierarchy__c teamHierRec;
                        if(loanApp.Decision__c =='Forward To Recommender'){
                            teamHierRec = approvedmap.get(loanApp.Recommender__c);
                            // if(loanApp.Approver__c != null){
                            //     teamHierRec = approvedmap.get(loanApp.Approver__c);
                            // }
                        }else if(loanApp.Decision__c =='Forward To Approver'){
                            teamHierRec = approvedmap.get(loanApp.Approver__c);
                        }
                        if (teamHierRec != null) {
                            // setToAddrss.add(teamHierRec.EmployeEmail__c);
                            recipientEmails.add(teamHierRec.EmployeEmail__c);
                            recipientIds.add(teamHierRec.employee__c);
                            String title = 'Request for Pricing approval has been raised...';
                            if(loanApp.Status__c =='In Progress' && loanApp.Decision__c =='Forward To Recommender' ){
                                recipientIds.add(loanApp.Recommender__c); 
                                recipientEmails.add(loanApp.Recommender__r.Email); 
                                // if(loanApp.Approver__c != null){
                                //     recipientIds.add(loanApp.Approver__c);
                                // }  
                            }else if(loanApp.Status__c =='In Progress' && loanApp.Decision__c =='Forward To Approver'){
                                recipientIds.add(loanApp.Approver__c);  
                                recipientEmails.add(loanApp.Approver__r.Email); 
                                title = 'Request for pricing approval for Application ID <'+loanApp.LAN__c+'> has been raised';
                            }
                            
                            
                            String body = String.format(System.Label.Pricing_Approval_Approved_Body, new List<String>{loanApp.AppName__c,'raised'});
                            //forbellNotification
                            system.debug('recipientIds '+ recipientIds);
                            system.debug('recipientEmails '+ recipientEmails);
                            system.debug('emailTemRequest.Id '+ emailTemRequest.Id);
                            system.debug('loanApp.LoanAppl__c '+ loanApp.LoanAppl__c);
						    notificationWrapList.add(NotificationWrapper.prepareNotificationData(loanApp.LoanAppl__c,new Set<String>(recipientIds),title,body,'',null,null,'Bell',''));
                            notificationWrapList.add(NotificationWrapper.prepareNotificationData(loanApp.Id,new Set<String>(recipientIds),'','','User',new Set<String>(recipientEmails),null,'Email',emailTemRequest.Id));

                            // CommunicationMatrixEmailNotification.notifyUsers(new Set<String>(recipientIds), loanApp.LoanAppl__c, title, body);// loanApp.Id
                            // AppleNotification.sendAppleNotification(title, body, new List<String>(recipientIds), loanApp.LoanAppl__c);//  Id to LoanAppl__c
                            recipientIds.clear();
                            recipientEmails.clear();
                            
                        }  else {
                            System.debug('teamHierRec is null for ID: ' + (loanApp.Decision__c == 'Forward To Recommender' ? loanApp.Recommender__c : loanApp.Approver__c));
                        }         
                    }
                }
                // newMail.setToAddresses(setToAddrss);
                // emailBody += '</table>';
                // newMail.setHtmlBody(emailBody);
                // mailList.add(newMail);
                // if (!mailList.isEmpty() && !Test.isRunningTest()) {
                //     Messaging.sendEmail(mailList);
                // }
            }
            if(!roiPfLoanApps.isEmpty()){
                Set<String> branchCodes = new Set<String>();
                Map<String,List<String>> teamHierWithOwnerIds = new Map<String,List<String>> ();
                // List<LoanAppeal__c> loanApps = [SELECT LoanAppl__c,AppName__c, LoanAppl__r.BrchCode__c,OwnerEmail__c,OwnerId from LoanAppeal__c WHERE Id IN :loanIds];
                // if(!loanApps.isEmpty()){
                for(LoanAppeal__c loanApp : roiPfLoanApps){
                    if(loanApp.LoanAppl__r.BrchCode__c  != null){
                        branchCodes.add(loanApp.LoanAppl__r.BrchCode__c);
                    }
                }
                // }
                if(!branchCodes.isEmpty()){
                    List<TeamHierarchy__c> teamHierrecrds = [SELECT employee__c,EmpRole__c,EmployeEmail__c,BranchCode__c FROM TeamHierarchy__c WHERE BranchCode__c IN:branchCodes AND EmpRole__c in ('CPA','UW','ACM','RCM')];
                    if(!teamHierrecrds.isEmpty()){
                        for(TeamHierarchy__c teamHier : teamHierrecrds){
                            if(teamHierWithOwnerIds.containsKey(teamHier.BranchCode__c)){
                                teamHierWithOwnerIds.get(teamHier.BranchCode__c).add(teamHier.employee__c);
                            }else{
                                teamHierWithOwnerIds.put(teamHier.BranchCode__c,new List<String>{teamHier.employee__c});
                            } 
                        }
                    }
                    if(!roiPfLoanApps.isEmpty()){
                        for(LoanAppeal__c loanApp : roiPfLoanApps){
                            recipientEmails.add(loanApp.CreatedByUserEmail__c);
                            recipientIds.add(loanApp.CreatedById);
                            if(loanApp.LoanAppl__c != null && loanApp.LoanAppl__r.BrchCode__c != null){
                                List<String> ownerIds = teamHierWithOwnerIds.get(loanApp.LoanAppl__r.BrchCode__c);
                                recipientIds.addall(ownerIds);
                            }
                            String title = 'Request for Pricing approval has been approved';
                            String body = String.format(System.Label.Pricing_Approval_Approved_Body, new List<String>{loanApp.AppName__c,'approved'});
                            //forbellNotification
						    notificationWrapList.add(NotificationWrapper.prepareNotificationData(loanApp.Id,new Set<String>(recipientIds),title,body,'',null,null,'Bell',''));

                            // CommunicationMatrixEmailNotification.notifyUsers(new Set<String>(recipientIds), loanApp.Id, title, body);
                            // AppleNotification.sendAppleNotification(title, body, new List<String>(recipientIds), loanApp.Id);
                            recipientIds.clear();
                            recipientEmails.clear();
                        }
                    } 
                }
            }
            if(!notificationWrapList.isEmpty()){
                system.debug('notificationWrapList final is ' + notificationWrapList);
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
            System.debug('Error Occurred: ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
        }
    }
    
    private static EmailTemplate getEmailTemplate(String templateDeveloperName) {
        try {
            return [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName = :templateDeveloperName LIMIT 1];
        } catch (QueryException e) {
            System.debug('Email template \'' + templateDeveloperName + '\' not found.');
            return null;
        }
    }
    
    private static void sendCommunication(List<String> recipientIds, List<String> recipientEmails, Id templateId, Id loanAppId, String title, String body) {
        CommunicationMatrixEmailNotification.notifyUsers(new Set<String>(recipientIds), loanAppId, title, body);
        AppleNotification.sendAppleNotification(title, body, new List<String>(recipientIds), loanAppId);
        CommunicationMatrixEmailNotification.sendEmail(templateId, recipientIds, recipientEmails, new List<String>(), loanAppId, 'User');
    }
}