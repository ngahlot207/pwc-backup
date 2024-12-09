global class UpdateLoanApplFieldsBatch implements Database.Batchable<SObject>,Database.Stateful {  
     global Map<String, Id> branchCodeToIdMap;  
    global UpdateLoanApplFieldsBatch() {  
        // Populate the branchCodeToIdMap in the constructor  
        branchCodeToIdMap = new Map<String, Id>();  
        for (BankBrchMstr__c branch : [SELECT Id, BrchCode__c FROM BankBrchMstr__c]) {  
            branchCodeToIdMap.put(branch.BrchCode__c, branch.Id);  
        }  
    }   
    global Database.QueryLocator start(Database.BatchableContext BC) {  
        // Query to get all LoanAppl__c records  
        return Database.getQueryLocator([SELECT Id, BrchCode__c FROM LoanAppl__c WHERE BrchCode__c != null]);  
    }  
    global void execute(Database.BatchableContext BC, List<LoanAppl__c> scope) {  
        List<LoanAppl__c> loanApplToUpdate = new List<LoanAppl__c>();  
        // Process LoanAppl__c records  
        for (LoanAppl__c loanAppl : scope) {  
            if (branchCodeToIdMap.containsKey(loanAppl.BrchCode__c)) {  
                loanAppl.Branch__c = branchCodeToIdMap.get(loanAppl.BrchCode__c);  
                loanApplToUpdate.add(loanAppl);  
            }  
        }  
        // Update LoanAppl__c records  
        if (!loanApplToUpdate.isEmpty()) {  
            update loanApplToUpdate;  
        }  
    }  
    global void finish(Database.BatchableContext BC) {  
        System.debug('Batch job completed for Loan Applications.');  
    }  
}