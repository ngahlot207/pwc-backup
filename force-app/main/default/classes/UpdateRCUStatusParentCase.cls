public class UpdateRCUStatusParentCase implements TriggerAction.AfterUpdate{
    public static void afterUpdate(List<Case>newList, List<Case>oldList){
        system.debug('newList:::::3'+newList);
        Map<Id,RecordType> mapOfRecordTypeId = new Map<Id,RecordType>();
        List<RecordType> recordTypeId = [SELECT Name, DeveloperName, Id FROM RecordType];
        for(RecordType rec :recordTypeId){
            mapOfRecordTypeId.put(rec.Id,rec);    
        }
        map<Id, Case> mapOldCase = new map<Id, Case>(oldList);
        set<Id> parentCaseIds = new set<Id>();
        list<Case> listParentCaseUpdate = new list<Case>();
        if(!newList.isEmpty()){
            for(Case c : newList){
                if(mapOfRecordTypeId.get(c.RecordTypeId).DeveloperName =='RCU' && mapOldCase.get(c.Id).Status != c.Status && c.AccountId != null 
                   && c.ContactId != null && c.Case__c != null){
                       parentCaseIds.add(c.Case__c);
                   }
                /*else if(mapOfRecordTypeId.get(c.RecordTypeId).DeveloperName =='RCU' && c.AccountId == null && c.ContactId == null 
&& mapOldCase.get(c.Id).Status != c.Status){
parentCaseIds.add(c.Id);
} */
            }
            system.debug('parentCaseIds:::::14'+parentCaseIds);
            
            if(!parentCaseIds.isEmpty()){
                updateFinalRCUStatusReasonParentCase(parentCaseIds);
            }  
        }
        Map<Id,List<Case>> mapOfChildCaseNotClosed = new Map<Id,List<Case>>();
        for(Case childCase : [SELECT Id, Status,Case__c from Case where Case__c IN : parentCaseIds]){
            if(childCase.status != 'Closed'){
                if(mapOfChildCaseNotClosed.containskey(childCase.Case__c)){
                    mapOfChildCaseNotClosed.get(childCase.Case__c).add(childCase);
                }else{
                    mapOfChildCaseNotClosed.put(childCase.Case__c,new list<case>{childCase});
                }
            }
            
        }
        
        system.debug('mapOfChildCaseNotClosed:::::14'+mapOfChildCaseNotClosed);     
        if(!parentCaseIds.isEmpty()){
            For(Case parentCase : [SELECT id, Status,AgcRCUReportStatus__c From Case WHERE Id IN :parentCaseIds AND AccountId = null AND ContactId = null AND
                                   RecordType.DeveloperName='RCU']){ 
                                       if(!mapOfChildCaseNotClosed.containsKey(parentCase.Id) ||mapOfChildCaseNotClosed.get(parentCase.Id).isEmpty()){
                                           parentCase.Status = 'Closed';
                                           parentCase.Date_of_Report__c=system.today();
                                           parentCase.ReportResult__c=parentCase.AgcRCUReportStatus__c;
                                           listParentCaseUpdate.add(parentCase);
                                       }
                                       
                                   }
        }       
        system.debug('listParentCaseUpdate:::::37'+listParentCaseUpdate);
        if(!listParentCaseUpdate.isEmpty()){
            update listParentCaseUpdate;
        }
        
    }
    public static void updateFinalRCUStatusReasonParentCase(set<Id> parentCases){
        map<Id, list<Case>> mapParentChildCases= new map<Id, list<Case>>();
        
        list <Case> lstParentCase = [SELECT Id,Loan_Application__c, CaseType__c,AgcRCUReportStatus__c,Final_RCU_status_Reason__c,ClosedDate From Case
                                     WHERE Id In : parentCases AND Accountid = null AND ContactId = null AND CaseType__c='RCU'];
        map<Id, Case> mapParentCase = new map<Id, Case>(lstParentCase);
        system.debug('mapParentCase SIZE 68:::::'+ mapParentCase.size());
        if(!mapParentCase.isEmpty()){
            for(Case cs:[SELECT Id,Case__c, CaseType__c,AgcRCUReportStatus__c,Final_RCU_status_Reason__c From Case
                         WHERE Case__c IN : mapParentCase.keySet() AND Accountid != null AND ContactId != null AND CaseType__c='RCU' order by ClosedDate DESC]){
                             system.debug('cs:::::72'+ cs);
                             if(mapParentChildCases.containsKey(cs.Case__c)){
                                 mapParentChildCases.get(cs.Case__c).add(cs);
                             }else{
                                 mapParentChildCases.put(cs.Case__c,new list<Case>{cs});   
                             }
                         }
            system.debug('mapParentChildCases:::::79'+ mapParentChildCases);
        }
        // Updating parent cases based on child case statuses
        if(!mapParentChildCases.isEmpty()){
            for (Id parentId : mapParentChildCases.keySet()) {
                List<Case> childCases = mapParentChildCases.get(parentId);
                Boolean hasFraud = false;
                Boolean hasNegative = false;
                Boolean hasRefer = false;
                Boolean hasPending = false;
                Boolean allPositive = true;
                string finalRCUReason='';
                for (Case child : childCases) {
                    String status = child.AgcRCUReportStatus__c;
                    if (status == 'FRAUD') {
                        hasFraud = true;
                        finalRCUReason=child.Final_RCU_status_Reason__c;
                        break; // No need to check further if 'Fraud' is found
                    } else if (status == 'NEGATIVE') {
                        hasNegative = true;
                        finalRCUReason=child.Final_RCU_status_Reason__c;
                        allPositive = false;
                    } else if (status == 'REFER') {
                        hasRefer = true;
                        finalRCUReason=child.Final_RCU_status_Reason__c;
                        allPositive = false;
                    } else if (status == 'PENDING') {
                        hasPending = true;
                        finalRCUReason=child.Final_RCU_status_Reason__c;
                        allPositive = false;
                    } else if (status != 'POSITIVE') {
                        finalRCUReason=child.Final_RCU_status_Reason__c;
                        allPositive = false;
                    }
                }
                
                Case parentCase = mapParentCase.get(parentId);
                if (hasFraud) {
                    parentCase.Final_RCU_status_Reason__c = finalRCUReason;
                } else if (hasNegative) {
                    parentCase.Final_RCU_status_Reason__c = finalRCUReason;
                } else if (hasRefer) {
                    parentCase.Final_RCU_status_Reason__c = finalRCUReason;
                } else if (hasPending) {
                    parentCase.Final_RCU_status_Reason__c = finalRCUReason;
                } else if (allPositive) {
                    parentCase.Final_RCU_status_Reason__c = finalRCUReason;
                }
            }  
        }
        system.debug('mapParentCase:::::129'+ mapParentCase);
        if(!mapParentCase.isEmpty()){
            update mapParentCase.values();
            updateFinalRCUStatusReasonLAN(parentCases);
        }        
    }
    
    public static void updateFinalRCUStatusReasonLAN(set<Id> parentCases){
        map<Id, LoanAppl__c> mapLoanAppl = new map<Id, LoanAppl__c>();
        set<Id> loanIds= new set<Id>();
        list <Case> lstParentCase = [SELECT Id,Loan_Application__c, CaseType__c,AgcRCUReportStatus__c,Final_RCU_status_Reason__c,ClosedDate From Case
                                     WHERE Id In : parentCases AND Accountid = null AND ContactId = null AND CaseType__c='RCU' AND Final_RCU_status_Reason__c != null
                                     order by ClosedDate DESC];
        system.debug('lstParentCase SIZE 143:::::'+ lstParentCase.size());
        // Checking parent cases statuses 
        if(!lstParentCase.isEmpty()){
            Boolean hasFraud = false;
            Boolean hasNegative = false;
            Boolean hasRefer = false;
            Boolean hasPending = false;
            Boolean allPositive = true;
            string finalRCUReason='';
            for (Case c : lstParentCase) {
                loanIds.add(c.Loan_Application__c);
                String status = c.AgcRCUReportStatus__c;
                if (status == 'FRAUD') {
                    hasFraud = true;
                    finalRCUReason=c.Final_RCU_status_Reason__c;
                    break; // No need to check further if 'Fraud' is found
                } else if (status == 'NEGATIVE') {
                    hasNegative = true;
                    finalRCUReason=c.Final_RCU_status_Reason__c;
                    allPositive = false;
                } else if (status == 'REFER') {
                    hasRefer = true;
                    finalRCUReason=c.Final_RCU_status_Reason__c;
                    allPositive = false;
                } else if (status == 'PENDING') {
                    hasPending = true;
                    finalRCUReason=c.Final_RCU_status_Reason__c;
                    allPositive = false;
                } else if (status != 'POSITIVE') {
                    finalRCUReason=c.Final_RCU_status_Reason__c;
                    allPositive = false;
                }
            }
            for(Id l : loanIds){
                LoanAppl__c ln = new LoanAppl__c();
                ln.Id = l;
                if (hasFraud) {
                    ln.FinalRCUStatusReason__c = finalRCUReason;
                } else if (hasNegative) {
                    ln.FinalRCUStatusReason__c = finalRCUReason;
                } else if (hasRefer) {
                    ln.FinalRCUStatusReason__c = finalRCUReason;
                } else if (hasPending) {
                    ln.FinalRCUStatusReason__c = finalRCUReason;
                } else if (allPositive) {
                    ln.FinalRCUStatusReason__c = finalRCUReason;
                }
                mapLoanAppl.put(l,ln);
            }
        }
        system.debug('mapLoanAppl:::::193'+ mapLoanAppl);
        if(!mapLoanAppl.isEmpty()){
            update mapLoanAppl.values();
        } 
        
    }   
    
}