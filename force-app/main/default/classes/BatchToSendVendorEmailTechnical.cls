global class BatchToSendVendorEmailTechnical implements Database.Batchable<sobject>, schedulable{
    
	global Database.QueryLocator start(Database.BatchableContext bc) {
      // String caselist = [ Select id, RecordType.Name, ContactId from Case
        //            where createddate = today and RecordType.Name IN ('Technical','CPVFI') Order by ContactId];
        return Database.getQueryLocator([Select id, CaseNumber, RecordType.Name, ContactId, Address_Type__c, Loan_Application__r.Name, Applicant__r.TabName__c, ApplAssetId__r.PropType__c from Case
                    where createddate = today and RecordType.Name = 'Technical' Order by ContactId]);
    }
    
    global void execute(Database.BatchableContext BC, list<case> caselist) {
        try{
        List<Messaging.SingleEmailMessage> mailList =  new List<Messaging.SingleEmailMessage>();
        Map<Id,List<Case>> CaseMap = new Map<Id,List<Case>>();
        list<case> listofcase = new list<case>();
        set<id> contactids = new set<id>();
        for (case c: caselist) {
            if (CaseMap.containsKey(c.contactid)) {
                //listofcase.add(c);
                CaseMap.get(c.contactid).add(c);
                contactids.add(c.contactid);
            } else {
                casemap.put(c.contactid, new list<case>{c});
            }
        }
        List<User> userList = [Select id ,Email, ContactId From User where ContactId in:contactids];
        Map<Id,String> contactToUserMap = new map<id,String>();
        //LAK-8625 - Jayesh
        Map<Id,String> contactToUserIDMap = new Map<Id,String>();
        for(User u: userList){
            contactToUserMap.put(u.contactId,u.Email);
            //LAK-8625 - Jayesh
            contactToUserIDMap.put(u.contactId,u.id);
        }
        
        for (id conId: CaseMap.keyset()){
            Messaging.SingleEmailMessage newMail = new Messaging.SingleEmailMessage();
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:system.label.orgWideEmail];
        	if ( owea.size() > 0 ) {
    			newMail.setOrgWideEmailAddressId(owea.get(0).Id);
			}
            List<String> sendToAddressesList = new list<String>();
            if (contactToUserMap.containskey(conId)) {
            	sendToAddressesList.add(contactToUserMap.get(conId));
                //LAK-8625 - Jayesh
                newMail.setTargetObjectId(contactToUserIDMap.get(conId));
                newMail.setSaveAsActivity(false);
            }
            newMail.setToAddresses(sendToAddressesList);
            newMail.setSubject('Cases assigned from Fedfina during the day ');
            String body = 'Hi, Following case/s pertaining to technical verification have been assigned to you today'+Date.today()+'. Kindly access the portal for details. Remember to change the status of the case to WIP once the work has been commenced.';   
            body+='<table>';
            body+='<tr>';
            body+='<th>Application Id</th>';
            body+='<th>Case ID</th>';
            body+='<th>Name of Main Applicant</th>';
            body+='<th>Property Type</th>';
            body+='</tr>';
            for (case c: CaseMap.get(conId)){
                body+='<tr>';
                    body+='<td>'+c.Loan_Application__r.Name+'</td>';
                    body+='<td>'+c.CaseNumber+'</td>';
                    body+='<td>'+c.Applicant__r.TabName__c+'</td>';
                	body+='<td>'+c.ApplAssetId__r.PropType__c+'</td>';
                body+='</tr>';
            }
            body+='</table>';
            newMail.setHtmlBody(body);
            mailList.add(newMail);
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
    }catch(Exception e){
        System.debug('Problem sending notification: ' + e.getMessage());
    }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    global void execute(SchedulableContext sc) {
        try{
        BatchToSendVendorEmailTechnical BSVendorEmailTechnical = new BatchToSendVendorEmailTechnical();
        Database.executeBatch(BSVendorEmailTechnical);
        }
        catch(Exception e){
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
}