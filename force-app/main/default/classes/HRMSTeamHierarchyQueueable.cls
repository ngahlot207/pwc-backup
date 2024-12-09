public class HRMSTeamHierarchyQueueable implements Queueable{
    
    Private Map<Id,TeamHierarchy__c> existingTeamHierarchyMap;
    Private Map<String,HRMSAPIResponseWrapper.Data> empDataMap;
    Private Set<String> branchCodes;
    Private Set<String> priorBranchCodes;
    
    public HRMSTeamHierarchyQueueable(Map<Id,TeamHierarchy__c> existingTeamHierarchyMap,Map<String,HRMSAPIResponseWrapper.Data> empDataMap,Set<String> branchCodes,Set<String> priorBranchCodes){
        this.existingTeamHierarchyMap=existingTeamHierarchyMap;
        this.empDataMap=empDataMap;
        this.branchCodes=branchCodes;
        this.priorBranchCodes=priorBranchCodes;
    }
    public void execute(QueueableContext context){
        
        if(!existingTeamHierarchyMap.isEmpty()){
            HRMSAPIResponseProcessor.deleteTeamHierarchies(existingTeamHierarchyMap);
        }
        
        if(!empDataMap.isEmpty() && !branchCodes.isEmpty()){
            HRMSAPIResponseProcessor.createTeamHierarchies(empDataMap, branchCodes);
        }
        
        if(!branchCodes.isEmpty() || !priorBranchCodes.isEmpty()){
            Set<String> allBranchCodes = new Set<String>();
            
            if(!branchCodes.isEmpty()){
                allBranchCodes.addAll(branchCodes);
            }
            if(!priorBranchCodes.isEmpty()){
                allBranchCodes.addAll(priorBranchCodes);
            }
            
            if(!allBranchCodes.isEmpty()){
                try{
                    BatchClassForLoanSharing obj = new BatchClassForLoanSharing(new Set<Id>{},allBranchCodes);
                    Database.executeBatch(obj,1);
                }
                catch(Exception ex){
                    system.debug(ex.getMessage());
                }
            }
        }
    }
}