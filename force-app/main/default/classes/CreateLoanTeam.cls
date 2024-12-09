/** 
* ********************************************************
* Created By : Paresh Saindane
* Created Date: 31-Aug-2023
* ********************************************************
*/

public class CreateLoanTeam implements TriggerAction.AfterInsert,TriggerAction.AfterUpdate {
    public static void afterInsert(List<LoanAppl__c> newList){
        CreateLoanTeamHandler.createLoanTeam(newList);
    }
    public static void afterUpdate(List<LoanAppl__c> newList, List<LoanAppl__c> oldList){
        List<LoanAppl__c> loanList = new List<LoanAppl__c>();
        map <Id,LoanAppl__c> oldMap = new map<Id,LoanAppl__c>(oldList);
        for(LoanAppl__c  loanNew : newList){
            if(loanNew.Id == oldMap.get(loanNew.Id).Id && (loanNew.OwnerId != oldMap.get(loanNew.Id).ownerId || (loanNew.Stage__c == 'DDE' && oldMap.get(loanNew.Id).Stage__c=='QDE'))){
                loanList.add(loanNew);
            }else if(loanNew.OpsUser__c != null && loanNew.OpsUser__c != oldMap.get(loanNew.Id).OpsUser__c){
                loanList.add(loanNew);   
            }else if(loanNew.CPA_User__c != null && loanNew.CPA_User__c != oldMap.get(loanNew.Id).CPA_User__c){
                loanList.add(loanNew);
            }else if(loanNew.OwnerId == oldMap.get(loanNew.Id).ownerId && loanNew.Stage__c != oldMap.get(loanNew.Id).Stage__c && loanNew.Stage__c == 'DDE' && oldMap.get(loanNew.Id).Stage__c=='QDE'){
                loanList.add(loanNew);
            }else if(loanNew.RMSMName__c != null && loanNew.RMSMName__c != oldMap.get(loanNew.Id).RMSMName__c){
                loanList.add(loanNew);
            }else if(loanNew.Account__c != null && loanNew.Account__c != oldMap.get(loanNew.Id).Account__c){
                loanList.add(loanNew);
            }
            
        }
        if(!loanList.isEmpty()){
            CreateLoanTeamHandler.createLoanTeam(loanList); 
        }
        
    }
    
    
    
}