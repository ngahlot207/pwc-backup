/** 
* ********************************************************
* Created By : Paresh Saindane
* Created Date: 02-Jul-2024
* ********************************************************
*/
public class SendEmailAfterLoanAppeal {
    public static void SendEmail(List<LoanAppeal__c> newList){
        map<string,list<LoanAppeal__c>> loanAppMap = new map<string,List<LoanAppeal__c>>();
        map<string,list<id>> BranchEmpMap = new map<string,list<id>>();
        map<string,list<string>> userEmailMap = new map<string,list<string>>();
        set<Id> loanSet =new Set<Id>();
        map<string, string> loanApplMap= new map<string, string>();
        map<string, string> loanApplProdMap= new map<string, string>();
        
        EmailTemplate emailTem=[select Id, DeveloperName from EmailTemplate where DeveloperName ='Loan_Appeal_Email_template_1720004017477'];
        Map<Id, RecordTypeInfo> recordTypes = sObjectType.LoanAppeal__c.getRecordTypeInfosById();
        
        for(LoanAppeal__c ln : newList){
            loanSet.add(ln.LoanAppl__c);
            
        }
        
        for(LoanAppl__c ln : [select id,BrchCode__c,Product__c FROM LoanAppl__c WHERE Id in : loanSet]){
            loanApplMap.put(ln.Id, ln.BrchCode__c);
            loanApplProdMap.put(ln.Id,ln.Product__c);
        }
        
        for(LoanAppeal__c appeal : newList){
            String branchCode = loanApplMap.get(appeal.LoanAppl__c);
            if(loanAppMap.containskey(branchCode)){
                loanAppMap.get(branchCode).add(appeal);
            }else{
                loanAppMap.put(branchCode,new list<LoanAppeal__c>{appeal});
            }
            
        } 
        system.debug('loanAppMap22::::' +loanAppMap.keyset()); 
        
        for(TeamHierarchy__c T:[select employee__c,EmpBrch__c,EmpRole__c,Employee__r.Email,BranchCode__c,Supervisor__r.EmpBrch__c,Supervisor__r.employee__c,EmployeEmail__c from TeamHierarchy__c 
                                where BranchCode__c in:loanAppMap.keySet() and EmpRole__c in ('UW')]){   
                                    if(BranchEmpMap.containsKey(T.BranchCode__c)){
                                        BranchEmpMap.get(T.BranchCode__c).add(T.employee__c);
                                        userEmailMap.get(T.BranchCode__c).add(T.EmployeEmail__c);
                                    }else{
                                        BranchEmpMap.put(T.BranchCode__c,new list<Id>{T.employee__c});
                                        userEmailMap.put(T.BranchCode__c,new list<string>{T.EmployeEmail__c});
                                    }
                                }
        
        system.debug('BranchEmpMap51::::' +BranchEmpMap); 
        system.debug('userEmailMap52::::' +userEmailMap); 
        
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        // List<CommunicationMatrixEmailNotification.Notification> notifications = new List<CommunicationMatrixEmailNotification.Notification>();
        map<Id,list<string>> mapLoanApp = new map<Id,list<string>>();
        for(LoanAppeal__c appeal : newList){
            String recordTypeName = recordTypes.get(appeal.RecordTypeId)?.getName();
            if(recordTypeName != null && recordTypeName != 'Loan Term Negotiation'){
                String branchCode = loanApplMap.get(appeal.LoanAppl__c);
                string title= 'Loan Appeal has been Initiated '+appeal.LAN__c;
                string body='Hi, ';
                body+= 'Loan Appeal has been initiated for LAN no. '+appeal.LAN__c ;
                body+=' Loan Appeal No. is '+appeal.Name;
                body+= '. Regards';
                system.debug('branchCode::::55' +branchCode);
                
                if(userEmailMap.containsKey(branchCode)){
                    list<string> recipientIds = BranchEmpMap.get(branchCode);
                    list<string> emails = userEmailMap.get(branchCode);
                    system.debug('recipientIds59::::' +recipientIds);
                    system.debug('emails60::::' +emails);
                    
                    mapLoanApp.put(appeal.Id, recipientIds);
                    
                    CommunicationMatrixEmailNotification.sendEmail(emailTem.Id,recipientIds, emails, new list<string>(), appeal.Id, 'User');
                    CommunicationMatrixEmailNotification.notifyUsers(new set<string>(recipientIds),appeal.Id,title,body);
                    recipientIds.clear();
                    emails.clear();
                }
            }
        }
        list<string> lstRec = new list<string>();
        //  lstRec= mapLoanApp.values();        
    }
    
    public static void sendEmailAfterUpdate(List<LoanAppeal__c> newList){
        list <string> lstEmail = new list<string>();
        list <string> lstOwnerids = new list<string>();
        system.debug('INSIDE AFTER UPDATE LOAN APPEAL SEND EMAIL85:::::');
        EmailTemplate emailTem=[select Id, DeveloperName from EmailTemplate where DeveloperName ='Loan_Appeal_Claim_Email_template_1720111428563'];
         Map<Id, RecordTypeInfo> recordTypes = sObjectType.LoanAppeal__c.getRecordTypeInfosById();
        map<string, string> ownerEmailMap= new map<string, string>();
        for(LoanAppeal__c appeal : newList){
             String recordTypeName = recordTypes.get(appeal.RecordTypeId)?.getName();
            system.debug('appeal.Owner.Email:::::'+appeal.OwnerEmail__c);
            if(appeal.OwnerEmail__c != null && recordTypeName != null && recordTypeName != 'Loan Term Negotiation'){
                lstEmail.add(appeal.OwnerEmail__c);
                lstOwnerids.add(appeal.OwnerId);
                string title= 'Loan Appeal has been Claimed '+appeal.LAN__c;
                string body='Hi';
                body+= ' Loan Appeal has been Claimed for LAN no. '+appeal.LAN__c ;
                body+=' Loan Appeal No. is '+appeal.Name;
                body+= 'Regards';
                system.debug('lstEmail::::77' +lstEmail);
                system.debug('lstOwnerids::::78' +lstOwnerids);
                CommunicationMatrixEmailNotification.sendEmail(emailTem.Id,lstOwnerids, lstEmail, new list<string>(), appeal.Id, 'User');
                CommunicationMatrixEmailNotification.notifyUsers(new set<string>(lstOwnerids),appeal.Id,title,body);
                lstOwnerids.clear();
                lstEmail.clear();
            }
            
        }
    }


    //LAK-9884
    public static void sendNotificationOwnerChange(List<LoanAppeal__c> newList){
        list <string> lstEmail = new list<string>();
        list <string> lstOwnerids = new list<string>();
        for(LoanAppeal__c appeal : newList){
            //String recordTypeName = recordTypes.get(appeal.RecordTypeId)?.getName();
           system.debug('appeal.Owner.Email:::::'+appeal.OwnerEmail__c);
           //if(appeal.OwnerEmail__c != null && recordTypeName != null && recordTypeName != 'Loan Term Negotiation' && recordTypeName != 'Roi Pf Correction' ){
               lstEmail.add(appeal.OwnerEmail__c);
               lstOwnerids.add(appeal.OwnerId);
               string title= 'Loan Appeal has been forwarded for your opinion '+appeal.LAN__c;
               string body='Hi,';
               body+= ' Loan Appeal has been forwarded for your opinion for LAN no. '+appeal.LAN__c ;
               body+=' Loan Appeal No. is '+appeal.Name;
               body+= ' Regards.';
               system.debug('lstEmail::::77' +lstEmail);
               system.debug('lstOwnerids::::forwarded ' +lstOwnerids);
               system.debug('lstOwnerids::::appeal.Id ' +appeal.Id);
               system.debug('lstOwnerids::::title ' +title);
               system.debug('lstOwnerids::::body ' +body);
               //CommunicationMatrixEmailNotification.sendEmail(emailTem.Id,lstOwnerids, lstEmail, new list<string>(), appeal.Id, 'User');
               CommunicationMatrixEmailNotification.notifyUsers(new set<string>(lstOwnerids),appeal.Id,title,body);
               lstOwnerids.clear();
               lstEmail.clear();
           //}
       }
    }


    public static void sendNotificationStatusChange(List<LoanAppeal__c> newList){
        //list <string> lstEmail = new list<string>();
        list <string> lstOwnerids = new list<string>();
        for(LoanAppeal__c appeal : newList){
               lstOwnerids.add(appeal.CreatedById);
               string title= 'Loan Appeal has been rejected for '+appeal.LAN__c;
               string body='Hi,';
               body+= ' Loan appeal No. ' +appeal.Name;
               body+=' for Loan application ID '+appeal.LAN__c;
               body+= ' has been rejected.';
               //system.debug('lstEmail::::77' +lstEmail);
               system.debug('Loan Appeal has been rejected ' +lstOwnerids);
               system.debug('Loan Appeal has been rejected ' +appeal.Id);
               system.debug('Loan Appeal has been rejected ' +title);
               system.debug('Loan Appeal has been rejected ' +body);
               //CommunicationMatrixEmailNotification.sendEmail(emailTem.Id,lstOwnerids, lstEmail, new list<string>(), appeal.Id, 'User');
               CommunicationMatrixEmailNotification.notifyUsers(new set<string>(lstOwnerids),appeal.Id,title,body);
               lstOwnerids.clear();
               //lstEmail.clear();
           //}
       }
    }

}