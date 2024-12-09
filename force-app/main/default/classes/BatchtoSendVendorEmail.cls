global class BatchtoSendVendorEmail implements Database.Batchable<sobject>, schedulable{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
      // String caselist = [ Select id, RecordType.Name, ContactId from Case
        //            where createddate = today and RecordType.Name IN ('Technical','CPVFI') Order by ContactId];
        system.debug('1');
        return Database.getQueryLocator([Select id, CaseNumber, RecordType.Name, ContactId, Address_Type__c, Loan_Application__r.Name, Applicant__r.TabName__c from Case
                    where createddate = today and RecordType.Name = 'CPVFI' Order by ContactId]);
    }
    
    global void execute(Database.BatchableContext BC, list<case> caselist) {
        try{
        system.debug('1');
        List<Messaging.SingleEmailMessage> mailList =  new List<Messaging.SingleEmailMessage>();
        //Map<String,Map<Id,List<Case>>> recordTypeToConatctToCaseMap = new Map<String,Map<Id,List<Case>>>();
        Map<Id,List<Case>> CaseMap = new Map<Id,List<Case>>();
        list<case> listofcase = new list<case>();
        set<id> contactids = new set<id>();
       // list<case> listofTechnicalCase = new list<case>();
        for (case c: caselist) {
            system.debug('1');
          //if (c.RecordType.Name=='CPVFI') {
                listofcase.add(c);
                CaseMap.put(c.contactid, listofcase);
                contactids.add(c.contactid);
               // recordTypeToConatctToCaseMap.put(c.RecordType.Name, innerCaseMap);
         //  }else {
           //     listofTechnicalCase.add(c);
           //     innerCaseMap.put(c.contactid, listofTechnicalCase);
            //    recordTypeToConatctToCaseMap.put(c.RecordType.Name, innerCaseMap);
           // }
        }
        List<User> userList = [Select id ,Email, ContactId From User where ContactId in:contactids];
        Map<Id,String> contactToUserMap = new map<id,String>();
        Map<Id,String> contactToUserIDMap = new map<id,String>();
        System.debug('userList-->'+userList);
        for(User u: userList){
            System.debug('userList-->'+u.Email);
            contactToUserMap.put(u.contactId,u.Email);
            contactToUserIDMap.put(u.contactId,u.id);
        }
        System.debug('caseMap-->'+CaseMap);
        
        for (id conId: CaseMap.keyset()){
            Messaging.SingleEmailMessage newMail = new Messaging.SingleEmailMessage();
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:system.label.orgWideEmail];
        	if ( owea.size() > 0 ) {
    			newMail.setOrgWideEmailAddressId(owea.get(0).Id);
			}
            List<String> sendToAddressesList = new list<String>();
           // if (contactToUserMap.containsKey(conId)){
            //    sendToAddressesList.add(contactToUserMap.get(conId).email);
            //}
            sendToAddressesList.add(contactToUserMap.get(conId));
            system.debug('sendToAddressesList-->'+sendToAddressesList);
            //LAK-8625 - Jayesh
            if (contactToUserMap.containsKey(conId)){
                newMail.setTargetObjectId(contactToUserIDMap.get(conId));
                newMail.setSaveAsActivity(false);
            }
            newMail.setToAddresses(sendToAddressesList);
            newMail.setSubject('Cases assigned from Fedfina during the day ');
            String body = 'Hi, Following case/s pertaining to CPV have been assigned to you today '+Date.today()+ '. Kindly access the portal for details. Remember to change the status of the case to WIP once the work has been commenced.';   
            body+='<table>';
            body+='<tr>';
            body+='<th>Application Id</th>';
            body+='<th>Case Number</th>';
            body+='<th>Name of Borrower</th>';
            body+='<th>Type of FI</th>';
            body+='</tr>';
            for (case c: CaseMap.get(conId)){
                system.debug('case-->'+c);
                body+='<tr>';
                    body+='<td>'+c.Loan_Application__r.Name+'</td>';
                    body+='<td>'+c.CaseNumber+'</td>';
                    body+='<td>'+c.Applicant__r.TabName__c+'</td>';
                	body+='<td>'+c.Address_Type__c+'</td>';
                body+='</tr>';
            }
            body+='</table>';
            newMail.setHtmlBody(body);
            system.debug('After Html body '+body);
            mailList.add(newMail);
            system.debug('new mail-->'+newMail);
        } 
        
        if(!mailList.isEmpty() && !Test.isRunningTest()){
            // Messaging.sendEmail(mailList);
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
        catch(Exception e){
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    global void execute(SchedulableContext sc) {
        try{
        BatchtoSendVendorEmail BSVendorEmail = new BatchtoSendVendorEmail();
        Database.executeBatch(BSVendorEmail);
        }
        catch(Exception e){
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }

}