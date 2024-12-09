global class BatchToSendScanBasedDisbursementEmail implements Database.Batchable<sobject>,schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT ID, DateofReceiptbyOps__c, DateofDispatch__c, DisType__c, LoanAppln__c,
            LoanAppln__r.NDCType__c, LoanAppln__r.BrchCode__c, LoanAppln__r.OpsUser__c,LoanAppln__r.Finnone_Loan_Number__c,
            LoanAppln__r.BrchName__c, LoanAppln__r.Product__c, LoanAppln__r.Name,LoanAppln__r.OpsUser__r.Email
            FROM DocDispatch__c
            WHERE Type__c IN ('OTC', 'PDD')
            AND LoanAppln__r.NDCType__c = 'Scan Based Disbursement'
            AND UserRole__c IN ('CPA', 'UW', 'ACM', 'RCM', 'ZCM', 'NCM', 'CH')
            AND DateofReceiptbyOps__c = null And LoanAppln__r.OpsUser__c != null AND DateofDispatch__c < LAST_N_DAYS:5
        ]);
    }
    
    global void execute(Database.BatchableContext BC, List<DocDispatch__c> DocDispatchList) {
        try{
        Set<String> branchCodes = new Set<String>();
        Set<String> setToAddresses = new Set<String>();
        Set<Id> SetOfOpsUser = new  Set<Id>();
        Map<Id,Set<String>> MapOfEmailToBranchCode = new  Map<Id,Set<String>>();
        Map<String, Integer> mapOfDocDispOf5Days = new Map<String, Integer>();
        Map<String, Integer> mapOfDocDispOf10Days = new Map<String, Integer>();
        set<string> productType = new set<string>();
        
        String productTypeString;
        for (DocDispatch__c docDispatch : DocDispatchList) {
            Integer differenceBetweenDays = docDispatch.DateofDispatch__c.daysBetween(date.Today());
            system.debug('Days diff: '+differenceBetweenDays);
            if (differenceBetweenDays > 10 && docDispatch.LoanAppln__c != null && docDispatch.LoanAppln__r.BrchCode__c != null) {
                system.debug('Inside 10 days');
                branchCodes.add(docDispatch.LoanAppln__r.BrchCode__c);
                mapOfDocDispOf10Days.put(docDispatch.LoanAppln__c+'-'+docDispatch.Id, 10);
                productType.add(docDispatch.LoanAppln__r.Product__c);
                SetOfOpsUser.add(docDispatch.LoanAppln__r.OpsUser__c);
            }
            
            else if (differenceBetweenDays > 5 && docDispatch.LoanAppln__r.OpsUser__c != null && differenceBetweenDays <= 10) {
                mapOfDocDispOf5Days.put(docDispatch.LoanAppln__c+'-'+docDispatch.Id , 5);
                system.debug('Inside 5 days');
                
            }
        }
        
        productTypeString = String.join(productType,',');
        system.debug('productTypeString-->'+productTypeString);
        system.debug('productTypeString-->'+productTypeString);
        system.debug('mapOfDocDispOf5Days:'+mapOfDocDispOf5Days);
        system.debug('SetOfOpsUser:'+SetOfOpsUser);
        System.debug('branchCodes:'+branchCodes);
        
        if (!branchCodes.isEmpty()) {
            for (TeamHierarchy__c team : [SELECT Employee__c,BranchCode__c,EmpRole__c,EmployeEmail__c,
                                          L1Email__c,L2_Email__c,L3Email__c,L4Email__c
                                          FROM TeamHierarchy__c WHERE BranchCode__c IN :branchCodes
                                          AND Employee__c != null AND BranchCode__c != null AND Employee__c IN :SetOfOpsUser ]) {
                                              system.debug('Enter this');
                                              // Check if the Branch Code exists in the map
                                              if (!MapOfEmailToBranchCode.containsKey(team.Employee__c)) {
                                                  // If not, initialize a new set for the Branch Code
                                                  MapOfEmailToBranchCode.put(team.Employee__c, new Set<String>());
                                              }
                                              
                                              // Add email addresses based on EmpRole__c
                                              if (team.EmpRole__c == 'BOM') {
                                                  if (team.L1Email__c != null && String.isNotBlank(team.L1Email__c)) {
                                                      MapOfEmailToBranchCode.get(team.Employee__c).add(team.L1Email__c);
                                                  }
                                                  if (team.L2_Email__c != null && String.isNotBlank(team.L2_Email__c)) {
                                                      MapOfEmailToBranchCode.get(team.Employee__c).add(team.L2_Email__c);
                                                  }
                                                  if (team.L3Email__c != null && String.isNotBlank(team.L3Email__c)) {
                                                      MapOfEmailToBranchCode.get(team.Employee__c).add(team.L3Email__c);
                                                  }
                                                  if (team.L4Email__c != null && String.isNotBlank(team.L4Email__c)) {
                                                      MapOfEmailToBranchCode.get(team.Employee__c).add(team.L4Email__c);
                                                  }
                                              } else if (team.EmpRole__c == 'AOM') {
                                                  if (team.L1Email__c != null && String.isNotBlank(team.L1Email__c)) {
                                                      MapOfEmailToBranchCode.get(team.Employee__c).add(team.L1Email__c);
                                                  }
                                                  if (team.L2_Email__c != null && String.isNotBlank(team.L2_Email__c)) {
                                                      MapOfEmailToBranchCode.get(team.Employee__c).add(team.L2_Email__c);
                                                  }
                                                  if (team.L3Email__c != null && String.isNotBlank(team.L3Email__c)) {
                                                      MapOfEmailToBranchCode.get(team.Employee__c).add(team.L3Email__c);
                                                  }
                                              } else if (team.EmpRole__c == 'ROM') {
                                                  if (team.L1Email__c != null && String.isNotBlank(team.L1Email__c)) {
                                                      MapOfEmailToBranchCode.get(team.Employee__c).add(team.L1Email__c);
                                                  }
                                                  if (team.L2_Email__c != null && String.isNotBlank(team.L2_Email__c)) {
                                                      MapOfEmailToBranchCode.get(team.Employee__c).add(team.L2_Email__c);
                                                  }
                                              } else if (team.EmpRole__c == 'ZOM') {
                                                  if (team.L1Email__c != null && String.isNotBlank(team.L1Email__c)) {
                                                      MapOfEmailToBranchCode.get(team.Employee__c).add(team.L1Email__c);
                                                  }
                                              }
                                          }
        }
        
        
        system.debug('MapOfEmailToBranchCode:'+MapOfEmailToBranchCode);
        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :System.Label.orgWideEmail];
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        
        if(mapOfDocDispOf5Days != null && !mapOfDocDispOf5Days.isEmpty() || mapOfDocDispOf10Days != null && !mapOfDocDispOf10Days.isEmpty()){
            for (DocDispatch__c docDispatch : DocDispatchList) {
                
                Messaging.SingleEmailMessage newMail = new Messaging.SingleEmailMessage();
                if (!owea.isEmpty()) {
                    newMail.setOrgWideEmailAddressId(owea[0].Id);
                }
                setToAddresses.clear(); 
  
                if (mapOfDocDispOf10Days.containsKey(docDispatch.LoanAppln__c+'-'+docDispatch.Id) && mapOfDocDispOf10Days.get(docDispatch.LoanAppln__c+'-'+docDispatch.Id) == 10 && MapOfEmailToBranchCode.containsKey(docDispatch.LoanAppln__r.OpsUser__c) && !MapOfEmailToBranchCode.get(docDispatch.LoanAppln__r.OpsUser__c).isEmpty() ) {
                    setToAddresses.clear();  
                    setToAddresses.addAll(MapOfEmailToBranchCode.get(docDispatch.LoanAppln__r.OpsUser__c));
                    system.debug('Inside To Address of 10');
                    setToAddresses.remove(docDispatch.LoanAppln__r.OpsUser__r.Email);
                    newMail.setCcAddresses(new List<String>{docDispatch.LoanAppln__r.OpsUser__r.Email});
                }
                
                else if (mapOfDocDispOf5Days.containsKey(docDispatch.LoanAppln__c+'-'+docDispatch.Id) && mapOfDocDispOf5Days.get(docDispatch.LoanAppln__c+'-'+docDispatch.Id) == 5 && docDispatch.LoanAppln__r.OpsUser__c != null ) {
                     setToAddresses.clear(); 
                     system.debug('Inside To Address of 5');
                     setToAddresses.add(docDispatch.LoanAppln__r.OpsUser__r.Email);
                     system.debug('Ops Email:'+docDispatch.LoanAppln__r.OpsUser__r.Email);
                }
                if(docDispatch.LoanAppln__r.OpsUser__c != null ){
                    //LAK-8625 - Jayesh
                    newMail.setTargetObjectId(docDispatch.LoanAppln__r.OpsUser__c);
                    newMail.setSaveAsActivity(false);
                }
                String htmlBody = '<html><body>';
                htmlBody += '<p>Dear Team,</p>';
                htmlBody += '<p>This is a reminder email towards pending dispatch of physical file for Product - ' + docDispatch.LoanAppln__r.Product__c + ' having lead ID ' + docDispatch.LoanAppln__r.Name + ' disbursed with loan account no. ' + docDispatch.LoanAppln__r.Finnone_Loan_Number__c + ' for the location ' + docDispatch.LoanAppln__r.BrchName__c + '.</p>';
                htmlBody += '<p>The loan cancellation process will begin after the 10th day of loan disbursement in the event that a physical file containing the entire set of papers has not been received at Operations.</p>';
                htmlBody += '</body></html>';
                
                newMail.setSubject('Physical File not reached at Disbursement HUB Product Name : '+docDispatch.LoanAppln__r.Product__c+', SFDC Lead ID : '+docDispatch.LoanAppln__r.Name+', LAN No : '+ docDispatch.LoanAppln__r.Finnone_Loan_Number__c+ ', Branch Name: '+docDispatch.LoanAppln__r.BrchName__c);
                if(!setToAddresses.isEmpty()){

                    newMail.setToAddresses(new List<String>(setToAddresses));
                    newMail.setHtmlBody(htmlBody);
                    mailList.add(newMail);

                }
               
                system.debug('setToAddresses:'+setToAddresses); 
                system.debug('mailList:'+mailList.size());  

                
            }
            
            system.debug('mailList:'+mailList);
            
            if (!mailList.isEmpty()) {
                system.debug('mailList List :'+mailList.size());  
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
    }catch(Exception e){
        System.debug('Problem sending notification: ' + e.getMessage());
    }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    global void execute(SchedulableContext sc) {
        try{
    BatchToSendScanBasedDisbursementEmail BatchToSendScanBasedDisb = new BatchToSendScanBasedDisbursementEmail();
    Database.executeBatch(BatchToSendScanBasedDisb);
        }
        catch(Exception e){
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
    
}