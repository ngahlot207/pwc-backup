/** 
* ********************************************************
* Created By : Paresh Saindane
* Created Date: 27-Jun-2024
* ********************************************************
*/

public class createLoanTeamForLoanAppeal implements TriggerAction.AfterInsert,TriggerAction.AfterUpdate{
    public static void afterInsert(List<LoanAppeal__c> newList){
        createLoanTeamForLoanAppealHandler.createLoanTeam(newList);
        SendEmailAfterLoanAppeal.SendEmail(newList);
    }
    public static void afterUpdate(List<LoanAppeal__c> newList, List<LoanAppeal__c> oldList){
        List<LoanAppeal__c> loanList = new List<LoanAppeal__c>();
        List<LoanAppeal__c> ownerChangedLoanList = new List<LoanAppeal__c>();//LAK-9884
        List<LoanAppeal__c> statusChangedLoanList = new List<LoanAppeal__c>();
        map <Id,LoanAppeal__c> oldMap = new map<Id,LoanAppeal__c>(oldList);
        for(LoanAppeal__c  loanNew : newList){
            // Check if the OwnerId has changed LAK-9884
            LoanAppeal__c oldLoan = oldMap.get(loanNew.Id);
            if (loanNew.OwnerId != oldLoan.OwnerId) {
            ownerChangedLoanList.add(loanNew);
            }
			system.debug('loanNew.Status__c: '+loanNew.Status__c);
            system.debug('oldLoan.Status__c: '+oldLoan.Status__c);
            if (loanNew.Status__c != oldLoan.Status__c && loanNew.Status__c == 'Reject') {
                system.debug('inside Reject: '+loanNew);
                statusChangedLoanList.add(loanNew);
                }

            if(loanNew.Id == oldMap.get(loanNew.Id).Id && loanNew.OwnerId != oldMap.get(loanNew.Id).ownerId){
                loanList.add(loanNew);
                 system.debug('loanList:::::::19'+loanList + loanList.size());
            }
            if(!loanList.isEmpty()){
                system.debug('loanList::ownerChangedLoanList ' + ownerChangedLoanList);
                createLoanTeamForLoanAppealHandler.createLoanTeam(loanList); 
                SendEmailAfterLoanAppeal.sendEmailAfterUpdate(loanList);
            }

            if(!ownerChangedLoanList.isEmpty()){
                SendEmailAfterLoanAppeal.sendNotificationOwnerChange(loanList);
            }
            if(!statusChangedLoanList.isEmpty()){
                system.debug('inside statusChangedLoanList: '+statusChangedLoanList);
                SendEmailAfterLoanAppeal.sendNotificationStatusChange(statusChangedLoanList);
            }
            
        }
    }
}