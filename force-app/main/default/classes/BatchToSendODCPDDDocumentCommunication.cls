global class BatchToSendODCPDDDocumentCommunication implements Database.Batchable<SObject>, Schedulable {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            select id, LAN__r.id, LAN__r.FinnSubDtTime__c, LAN__r.BrchCode__c, LAN__r.BrchName__c, LAN__r.RMSMName__c, LAN__r.UWUser__c,
                   LAN__r.Product__c, LAN__r.RMSMName__r.Email, LAN__r.Applicant__r.TabName__c, LAN__r.name, LAN__r.CPA_User__c, LAN__r.CPA_User__r.Email, LAN__r.UWUser__r.Email,
                   DocCatgry__c, DocTyp__c, DocSubTyp__c, DevLvl__c, DocStatus__c ,Rmrk__c
            from DocDtl__c 
            where LAN__r.Loan_Boarding_API_Status__c = 'Success' 
            and LAN__r.Stage__c = 'Disbursed' 
            AND DocStatus__c in ('OTC', 'PDD')
            and LAN__r.FinnSubDtTime__c = N_DAYS_AGO:7
        ]);
    }

    global void execute(Database.BatchableContext BC, List<DocDtl__c> docList) {
        try{
        Set<String> brchCode = new Set<String>();
        Set<String> productType = new Set<String>();
        Set<String> rmUser = new Set<String>();
        Set<String> cpaUser = new Set<String>();
        Set<String> uwUser = new Set<String>();
        Map<Id, List<DocDtl__c>> mapOfLoanDocument = new Map<Id, List<DocDtl__c>>();

        for (DocDtl__c doc : docList) {
            brchCode.add(doc.LAN__r.BrchCode__c);
            productType.add(doc.LAN__r.Product__c);
            rmUser.add(doc.LAN__r.RMSMName__c);
            cpaUser.add(doc.LAN__r.CPA_User__c);
            uwUser.add(doc.LAN__r.UWUser__c);

            if (!mapOfLoanDocument.containsKey(doc.LAN__r.id)) {
                mapOfLoanDocument.put(doc.LAN__r.id, new List<DocDtl__c>());
            }
            mapOfLoanDocument.get(doc.LAN__r.id).add(doc);
        }

        String productTypeString = String.join(new List<String>(productType), ';');
        List<TeamHierarchy__c> bbhlist = [
            select id,Employee__c, Employee__r.Email, Employee__r.Name, BranchCode__c, emprole__c, L2_Email__c 
            from TeamHierarchy__c 
            where emprole__c = 'BBH' 
            and BranchCode__c in :brchCode 
            and Product_Type__c INCLUDES (:productTypeString) 
            order by LastModifiedDate
        ];
        
        Map<String, String> BranchToBBhMap = new Map<String, String>();
        //LAK-8625 - Jayesh
        Map<String, Id> BranchToBBhMapId = new Map<String, Id>();
        Map<String, String> BranchToRBHMap = new Map<String, String>();
        for (TeamHierarchy__c bbhEmail : bbhlist) {
            BranchToBBhMap.put(bbhEmail.BranchCode__c, bbhEmail.Employee__r.Email);
            //LAK-8625 - Jayesh
            BranchToBBhMapId.put(bbhEmail.BranchCode__c,bbhEmail.Employee__c);
            BranchToRBHMap.put(bbhEmail.BranchCode__c, bbhEmail.L2_Email__c);
        }

        Map<String, String> branchsmMap = new Map<String, String>();
        List<TeamHierarchy__c> smList = [
            select id, employee__r.email, branchcode__c, L1Email__c, Employee__c 
            from TeamHierarchy__c 
            where Employee__c = :rmUser 
            and BranchCode__c in :brchCode 
            and Product_Type__c INCLUDES (:productTypeString)
        ];

        for (TeamHierarchy__c teamHList : smList) {
            branchsmMap.put(teamHList.branchcode__c, teamHList.L1Email__c);
        }

        Map<String, String> branchuwMap = new Map<String, String>();
        Map<String, String> branchuw2Map = new Map<String, String>();
        List<TeamHierarchy__c> uwHirachyList = [
            select id, employee__r.email, branchcode__c, L1Email__c, L2_Email__c 
            from TeamHierarchy__c 
            where Employee__c = :uwUser 
            and BranchCode__c in :brchCode 
            and Product_Type__c INCLUDES (:productTypeString)
        ];

        for (TeamHierarchy__c teamHList : uwHirachyList) {
            branchuwMap.put(teamHList.branchcode__c, teamHList.L1Email__c);
            branchuw2Map.put(teamHList.branchcode__c, teamHList.L2_Email__c);
        }

        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = :System.label.orgWideEmail];
        Set<Id> setIds = new Set<Id>();
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();

        for (DocDtl__c doc : docList) {
            if (setIds.contains(doc.LAN__r.id)) {
                continue;
            }

            List<String> sendToAddressesList = new List<String>();
            List<String> sendCCAddressesList = new List<String>();

            sendToAddressesList.add(doc.LAN__r.RMSMName__r.Email);
            sendToAddressesList.add(BranchToBBhMap.get(doc.LAN__r.BrchCode__c));
            sendToAddressesList.add(BranchToRBHMap.get(doc.LAN__r.BrchCode__c));
            sendToAddressesList.add(branchsmMap.get(doc.LAN__r.Brchcode__c));
            sendCCAddressesList.add(branchuwMap.get(doc.LAN__r.Brchcode__c));
            sendCCAddressesList.add(branchuw2Map.get(doc.LAN__r.Brchcode__c));
            sendCCAddressesList.add(doc.LAN__r.UWUser__r.Email);
            sendCCAddressesList.add(doc.LAN__r.CPA_User__r.Email);

            List<String> cleanedSendToAddressesList = new List<String>();
            for (String email : sendToAddressesList) {
                if (email != null) {
                    cleanedSendToAddressesList.add(email);
                }
            }

            List<String> cleanedSendCCAddressesList = new List<String>();
            for (String email : sendCCAddressesList) {
                if (email != null) {
                    cleanedSendCCAddressesList.add(email);
                }
            }

            Messaging.SingleEmailMessage newMail = new Messaging.SingleEmailMessage();
            if (!owea.isEmpty()) {
                newMail.setOrgWideEmailAddressId(owea[0].Id);
            }

            setIds.add(doc.LAN__r.id);
            //LAK-8625 - Jayesh
            if(BranchToBBhMapId.containsKey(doc.LAN__r.BrchCode__c)){
                newMail.setTargetObjectId(BranchToBBhMapId.get(doc.LAN__r.BrchCode__c));
                newMail.setSaveAsActivity(false);
            }
            newMail.setToAddresses(cleanedSendToAddressesList);
            newMail.setCcAddresses(cleanedSendCCAddressesList);
            newMail.setSubject('First Reminder: OTC/PDD Documents for ' + doc.LAN__r.Applicant__r.TabName__c + ' with Application ID ' + doc.LAN__r.name + ' for ' + doc.LAN__r.Product__c + ' CASE OF ' + doc.LAN__r.BrchName__c + ' Branch');
            String body = 'Hi, <br/><br/> Loan application bearing Application ID ' + doc.LAN__r.name + ' for the case of ' + doc.LAN__r.Applicant__r.TabName__c + ' has mentioned OTC/PDD Documents for ' + doc.LAN__r.BrchName__c + ' Branch. Kindly respond to it at earliest for timely closure.';   
            body += '<br/><br/> <table border="1" style="border-collapse: collapse">';
            body += '<tr>';
            body += '<th>Doc Status</th>';
            body += '<th>Doc Category</th>';
            body += '<th>Document Type</th>';
            body += '<th>Document Name</th>';
            body += '<th>Document Description</th>';
            body += '<th>Deviation level</th>';
            body += '</tr>';
            for (DocDtl__c docDetail : mapOfLoanDocument.get(doc.LAN__r.Id)) {
                body += '<tr>';
                body += '<td style="text-align: center; vertical-align: middle;">' + docDetail.DocStatus__c + '</td>';
                body += '<td style="text-align: center; vertical-align: middle;">' + docDetail.DocCatgry__c + '</td>';
                body += '<td style="text-align: center; vertical-align: middle;">' + docDetail.DocTyp__c + '</td>';
                body += '<td style="text-align: center; vertical-align: middle;">' + docDetail.DocSubTyp__c + '</td>';
                body += '<td style="text-align: center; vertical-align: middle;">' + docDetail.Rmrk__c + '</td>';
                body += '<td style="text-align: center; vertical-align: middle;">' + docDetail.DevLvl__c + '</td>';
                body += '</tr>';
            }
            body += '</table>';
            body += '<br/>Thanks & Rgds.,';
            newMail.setHtmlBody(body);
            mailList.add(newMail);
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
    }catch(Exception e){
        System.debug('Problem sending notification: ' + e.getMessage());
    }
    }

    global void finish(Database.BatchableContext BC) {}

    global void execute(SchedulableContext sc) {
        try{
        BatchToSendODCPDDDocumentCommunication batchToSendODCPDD = new BatchToSendODCPDDDocumentCommunication();
        Database.executeBatch(batchToSendODCPDD);
        }
        catch(Exception e){
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
}