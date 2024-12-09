global class UpdateBranchFieldsBatch implements Database.Batchable<SObject>, Database.Stateful {  
    global Map<String, Id> branchCodeToIdMap;  
    global UpdateBranchFieldsBatch() {  
        // Populate the branchCodeToIdMap in the constructor  
        branchCodeToIdMap = new Map<String, Id>();  
        for (BankBrchMstr__c branch : [SELECT Id, BrchCode__c FROM BankBrchMstr__c]) {  
            branchCodeToIdMap.put(branch.BrchCode__c, branch.Id);  
        }  
    }  
    global Database.QueryLocator start(Database.BatchableContext BC) {  
        // Query to get all Lead records  
        return Database.getQueryLocator([SELECT Id, Branch_Code__c FROM Lead WHERE Branch_Code__c != null]);  
    }  
    global void execute(Database.BatchableContext BC, List<Lead> scope) {  
        List<Lead> leadsToUpdate = new List<Lead>();  
        // Process Leads  
        for (Lead lead : scope) {  
            if (branchCodeToIdMap.containsKey(lead.Branch_Code__c)) {  
               // lead.Lead_State__c = branchCodeToIdMap.get(lead.Branch_Code__c);  
                leadsToUpdate.add(lead);  
            }  
        }  
        // Update Lead records  
        if (!leadsToUpdate.isEmpty()) {  
            update leadsToUpdate;  
        }  
        // Process LoanAppl__c records in a separate batch  
        //Database.executeBatch(new UpdateLoanApplFieldsBatch(branchCodeToIdMap));  
    }  
    global void finish(Database.BatchableContext BC) {  
        System.debug('Batch job completed for Leads.');  
    }  
}