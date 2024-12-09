global class BatchToSendOTCPDDDocumentAfterfourteenDy implements Database.Batchable<sObject>,schedulable{
  
    global Database.QueryLocator start(Database.BatchableContext bc) {
    
        system.debug('1');
        return Database.getQueryLocator([select id,LAN__r.id,LAN__r.Lead__r.Lead_Id__c,LAN__r.FinnSubDtTime__c,LAN__r.BrchCode__c,LAN__r.BrchName__c,LAN__r.RMSMName__c,LAN__r.UWUser__c,
                                        LAN__r.Product__c,LAN__r.RMSMName__r.Email,LAN__r.Applicant__r.TabName__c,LAN__r.name,LAN__r.CPA_User__c,LAN__r.CPA_User__r.Email,LAN__r.UWUser__r.Email,
                                        DocCatgry__c, DocTyp__c, DocSubTyp__c, DevLvl__c,DocStatus__c,Rmrk__c from DocDtl__c where LAN__r.Loan_Boarding_API_Status__c ='Success' 
                                        and LAN__r.Stage__c ='Disbursed' AND DocStatus__c in('OTC','PDD')
                                        and  LAN__r.FinnSubDtTime__c = N_DAYS_AGO:14]); // and LAN__r.FinnSubDtTime__c = LAST_N_DAYS:14
    }
    
    global void execute(Database.BatchableContext BC, list<DocDtl__c> docList) {
        try{
    system.debug('2');

    
        set<string> brchCode = new set<string>();
        set<string> productType = new set<string>();
        set<string> rmUser = new set<string>();
        set<string> cpaUser = new set<string>();
        set<string> uwUser = new set<string>();
        Map<Id, List<DocDtl__c>> mapOfLoanDocument = new Map<Id, List<DocDtl__c>>();
        List<DocDtl__c> lstDocumentDetails = new List<DocDtl__c>();
        String productTypeString;
        if(docList.size()>0){
        for (DocDtl__c doc: docList){
                brchCode.add(doc.LAN__r.BrchCode__c);
                productType.add(doc.LAN__r.Product__c);
            	rmUser.add(doc.LAN__r.RMSMName__c);
            	cpaUser.add(doc.LAN__r.CPA_User__c);
            	uwUser.add(doc.LAN__r.UWUser__c);
                lstDocumentDetails.add(doc);

                // if(mapOfLoanDocument.containsKey(doc.LAN__r.id)){
                //     mapOfLoanDocument.get(doc.LAN__r.id).add(doc);
                // }else{
                //     mapOfLoanDocument.put(doc.LAN__r.id, new List<DocDtl__c>{doc});
                // }

                if(mapOfLoanDocument.containsKey(doc.LAN__r.id)){
                    
                    mapOfLoanDocument.put(doc.LAN__r.id,lstDocumentDetails);
            }
            else{
                     lstDocumentDetails.clear();
                     lstDocumentDetails.add(doc);
                     mapOfLoanDocument.put(doc.LAN__r.id,lstDocumentDetails);
                     
            }
            

        }
    }

        productTypeString = String.join(productType,';');
        system.debug('productTypeString-->'+productTypeString);
        //LAK-8625 - Jayesh
        list<TeamHierarchy__c> bbhlist = [select id,Employee__c,Employee__r.Email,Employee__r.Name,BranchCode__c,emprole__c,L2_Email__c,L1Email__c from TeamHierarchy__c where emprole__c = 'BBH' and BranchCode__c in:brchCode and Product_Type__c INCLUDES(:productTypeString) order by LastModifiedDate];
        Map<string, string> BranchToBBhMap = new Map<string, string>();
        Map<string, Id> BranchtoBBhMapId = new Map<String, Id>();
        Map<string, string> BranchToRBHMap = new Map<string, string>();
        Map<string, string> BranchToABHMap = new Map<string, string>();
        for (TeamHierarchy__c bbhEmail: bbhlist) {
            BranchToBBhMap.put(bbhEmail.BranchCode__c, bbhEmail.Employee__r.Email);
            BranchToABHMap.put(bbhEmail.BranchCode__c, bbhEmail.L1Email__c);
            BranchToRBHMap.put(bbhEmail.BranchCode__c, bbhEmail.L2_Email__c);
            BranchtoBBhMapId.put(bbhEmail.BranchCode__c,bbhEmail.Employee__c);
        }
        system.debug('BranchToBBhMap-->'+BranchToBBhMap);
        
    Map<string, String> branchsmMap = new Map<string, String>();
        List<String> sendToAddressesList = new List<String>();
        List<String> sendCCAddressesList = new List<String>();
    

    list<TeamHierarchy__c> smList = [Select id, employee__r.email, branchcode__c,L1Email__c,Employee__c  from TeamHierarchy__c where Employee__c =: rmUser and BranchCode__c in:brchCode and Product_Type__c INCLUDES(:productTypeString)];
        
        for(TeamHierarchy__c teamHList : smList){
            
            branchsmMap.put(teamHList.branchcode__c,teamHList.L1Email__c);
            // cpaUWEmailList
        }
        system.debug('branchsmMap-->'+branchsmMap);
        
        Map<string, String> branchuwMap = new Map<string, String>();
        Map<string, String> branchuw2Map = new Map<string, String>();
       list<TeamHierarchy__c> uwHirachyList = [Select id, employee__r.email, branchcode__c,L1Email__c,L2_Email__c  from TeamHierarchy__c where Employee__c =: uwUser and BranchCode__c in:brchCode and Product_Type__c INCLUDES(:productTypeString)];
        
        for(TeamHierarchy__c teamHList : uwHirachyList){
            
            branchuwMap.put(teamHList.branchcode__c,teamHList.L1Email__c);
            branchuw2Map.put(teamHList.branchcode__c,teamHList.L2_Email__c);
            // cpaUWEmailList
        }
        system.debug('branchuwMap-->'+branchuwMap);

    OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:system.label.orgWideEmail];
   
    Set<Id> setIds = new set<Id>();
    if(docList.size()>0){
    for (DocDtl__c doc: docList){
        if(setIds.contains(doc.LAN__r.id)){
            continue;
        }
        // if(sendToAddressesList.contains(doc.LAN__r.RMSMName__r.Email)){
        //     sendToAddressesList.clear();
        // }
        // 
        	if (doc.LAN__r.RMSMName__r.Email != null) {
        	sendToAddressesList.add(doc.LAN__r.RMSMName__r.Email);
            }
        	if (BranchToBBhMap.containsKey(doc.LAN__r.BrchCode__c)) {
            sendToAddressesList.add(BranchToBBhMap.get(doc.LAN__r.BrchCode__c));
            }
        	if (BranchToABHMap.containsKey(doc.LAN__r.BrchCode__c)) {
        	sendToAddressesList.add(BranchToABHMap.get(doc.LAN__r.BrchCode__c));
            }
        	if (BranchToRBHMap.containsKey(doc.LAN__r.BrchCode__c)) {
                sendToAddressesList.add(BranchToRBHMap.get(doc.LAN__r.BrchCode__c));
            }
        	if (branchsmMap.containsKey(doc.LAN__r.BrchCode__c)) {
            sendToAddressesList.add(branchsmMap.get(doc.LAN__r.Brchcode__c));
            }
        	if (branchuwMap.containsKey(doc.LAN__r.BrchCode__c)) {
                sendCCAddressesList.add(branchuwMap.get(doc.LAN__r.Brchcode__c));
            }
        	if (branchuw2Map.containsKey(doc.LAN__r.BrchCode__c)) {
                sendCCAddressesList.add(branchuw2Map.get(doc.LAN__r.Brchcode__c));
            }
        	if (doc.LAN__r.UWUser__r.Email != null) {
                sendCCAddressesList.add(doc.LAN__r.UWUser__r.Email);
            }
        	if (doc.LAN__r.CPA_User__r.Email != null) {
            sendCCAddressesList.add(doc.LAN__r.CPA_User__r.Email);
            }
        
         system.debug('sendToAddressesList'+sendToAddressesList);
            system.debug('sendCCAddressesList'+sendCCAddressesList);
        
        List<String> cleanedSendToAddressesList = new List<String>();
		for (String email : sendToAddressesList) {
    	if (email != null) {
        cleanedSendToAddressesList.add(email);
    	}
	    }

	    sendToAddressesList = cleanedSendToAddressesList;
        
        List<String> cleanedsendCCAddressesList = new List<String>();
		for (String email : sendCCAddressesList) {
    	if (email != null) {
        cleanedsendCCAddressesList.add(email);
    	}
	}

	sendCCAddressesList = cleanedsendCCAddressesList;
        
    List<Messaging.SingleEmailMessage> mailList =  new List<Messaging.SingleEmailMessage>();
    Messaging.SingleEmailMessage newMail = new Messaging.SingleEmailMessage();

    if ( owea.size() > 0 ) {
        newMail.setOrgWideEmailAddressId(owea.get(0).Id);
    }

    setIds.add(doc.LAN__r.id);
        //  sendToAddressesList.add(sendToAddressesList);
        //  system.debug('sendToAddressesList-->'+sendToAddressesList);
        newMail.setToAddresses(sendToAddressesList);
        newMail.setCcAddresses(sendCCAddressesList);
        //LAK-8625 - Jayesh
        if(BranchtoBBhMapId.containsKey(doc.LAN__r.BrchCode__c)){
            newMail.setTargetObjectId(BranchtoBBhMapId.get(doc.LAN__r.BrchCode__c));
            newMail.setSaveAsActivity(false);
        }
        newMail.setSubject('Final Reminder: OTC/PDD Documents for '+ doc.LAN__r.Applicant__r.TabName__c +' with lead ID '+ doc.LAN__r.Lead__r.Lead_Id__c +' and LAN '+ doc.LAN__r.Name +' for LAP/HL CASE OF '+ doc.LAN__r.BrchName__c +' BRANCH.');
        String body = 'Hi, <br/><br/> Final Reminder for Loan application bearing lead ID '+ doc.LAN__r.Lead__r.Lead_Id__c +' for the case of '+ doc.LAN__r.Applicant__r.TabName__c +' has mentioned OTC/PDD Documents for '+ doc.LAN__r.BrchName__c +' Branch.  Kindly respond to it at earliest for timely closure.';   
       // body+='<h3> OTC Documents</h3>';
        body+='<br/><br/> <table border="1" style="border-collapse: collapse">';
        body+='<tr>';
        body+='<th>Doc Status</th>';
        body+='<th>Doc Category</th>';
        body+='<th>Document Type</th>';
        body+='<th>Document Name</th>';
        body += '<th>Document Description</th>';
        body+='<th>Deviation level</th>';
        body+='</tr>';
        for (DocDtl__c docDetail: mapOfLoanDocument.get(doc.LAN__r.Id) ){
           // system.debug('loanId-->'+c);
            body+='<tr>';
                body+='<td style="text-align: center; vertical-align: middle;">'+docDetail.DocStatus__c+'</td>';
                body+='<td style="text-align: center; vertical-align: middle;">'+docDetail.DocCatgry__c+'</td>';
                body+='<td style="text-align: center; vertical-align: middle;">'+docDetail.DocTyp__c+'</td>';
                body+='<td style="text-align: center; vertical-align: middle;">'+docDetail.DocSubTyp__c+'</td>';
            	body += '<td style="text-align: center; vertical-align: middle;">' + docDetail.Rmrk__c + '</td>';
            	body+='<td style="text-align: center; vertical-align: middle;">'+docDetail.DevLvl__c+'</td>';
            body+='</tr>';
        }
        body+='</table>';
        body+='<br/>';
        body+='Thanks & Rgds.,';
        newMail.setHtmlBody(body);
        system.debug('After Html body '+body);
        mailList.add(newMail);
        sendToAddressesList.clear();
        sendCCAddressesList.clear();
        system.debug('new mail-->'+newMail);

        if(!mailList.isEmpty()){
            //Added to by pass the send email method to test class.
            if(!Test.IsRunningTest()){
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
        }
    }
}   }catch(Exception e){
    System.debug('Problem sending notification: ' + e.getMessage());
    }
    } 
    
    



global void finish(Database.BatchableContext BC) {
    
}

global void execute(SchedulableContext sc) {
    //LAK-8625 - Jayesh
    try{
    BatchToSendOTCPDDDocumentAfterfourteenDy BatchToSendODCPDD = new BatchToSendOTCPDDDocumentAfterfourteenDy();
    Database.executeBatch(BatchToSendODCPDD);
    }catch(Exception e){
        System.debug('Problem sending notification: ' + e.getMessage());
    }
}
}