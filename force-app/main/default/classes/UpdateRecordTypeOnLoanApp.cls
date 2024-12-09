public class UpdateRecordTypeOnLoanApp implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate {
 
    
    private static Map<String, RecordType> recordTypeMap;
    private static void buildRecordTypeMap() {
        if (recordTypeMap == null) {
            recordTypeMap = new Map<String, RecordType>();
            for (RecordType rtype : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'LoanAppl__c']) {
                recordTypeMap.put(rtype.DeveloperName, rtype);
            }
        }
    }
    public static void beforeInsert(List<LoanAppl__c> newList) {
        buildRecordTypeMap();
        for (LoanAppl__c newLoanApp : newList) {
            String recordTypeName = getRecordTypeName(newLoanApp);
            if (recordTypeMap.containsKey(recordTypeName)) {
                newLoanApp.RecordTypeId = recordTypeMap.get(recordTypeName).Id;
            }
        }
    }
 
    public static void beforeUpdate(List<LoanAppl__c> newList, List<LoanAppl__c> oldList) {
        if (!newList.isEmpty()) {
            buildRecordTypeMap();
        }
        Set<Id> loanAppIdsForProductChange = new Set<Id>();
        Map<Id, LoanAppl__c> oldLoanAppMap = new Map<Id, LoanAppl__c>(oldList);
        for (LoanAppl__c newLoanApp : newList) {
            LoanAppl__c oldLoanApp = oldLoanAppMap.get(newLoanApp.Id);
            if (newLoanApp.Product__c != oldLoanApp.Product__c) {
                //String recordTypeName = getRecordTypeName(newLoanApp);
 				loanAppIdsForProductChange.add(newLoanApp.Id);
                /*if (recordTypeMap.containsKey(recordTypeName)) {
                    newLoanApp.RecordTypeId = recordTypeMap.get(recordTypeName).Id;
                }*/
            }
        }
        if(!loanAppIdsForProductChange.isEmpty()){
            buildRecordTypeMap();
            for (LoanAppl__c newLoanApp : newList) {
				LoanAppl__c oldLoanApp = oldLoanAppMap.get(newLoanApp.Id);
                if (newLoanApp.Product__c != oldLoanApp.Product__c) {
                    String recordTypeName = getRecordTypeName(newLoanApp);
                    
                    if (recordTypeMap.containsKey(recordTypeName)) {
                        newLoanApp.RecordTypeId = recordTypeMap.get(recordTypeName).Id;
                    }
                }
        	}
        }
    }
 
    private static String getRecordTypeName(LoanAppl__c loanApp) {
         If (loanApp.Product__c == 'Home Loan') {
            Return 'Home_Loan'; 
        } else if (loanApp.Product__c == 'Small Ticket LAP') {
            Return 'Small_Ticket_LAP'; 
        }
        else if (loanApp.Product__c == 'Business Loan') {
            Return 'Business_Loan'; 
        }
        else if (loanApp.Product__c == 'Loan Against Property') {
            Return 'Loan_Against_Property'; 
        }
        else if (loanApp.Product__c == 'Personal Loan') {
            Return 'Personal_Loan'; 
        }
        else {
            Return 'DefaultRecordType'; 
        }

    }
}