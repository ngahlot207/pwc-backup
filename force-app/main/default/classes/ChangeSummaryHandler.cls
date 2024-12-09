public class ChangeSummaryHandler {
    
    @AuraEnabled
    public static List<ChangeSummaryData> getRetriggerData(String loanAppId){
        
        List<ChangeSummaryData> changeSummaryList = new List<ChangeSummaryData>();
        
        List<RetriggerUpsertAudit__c> retriggerUpsertAuditRecords = new List<RetriggerUpsertAudit__c>();
        
        if(loanAppId != null){
            retriggerUpsertAuditRecords = [SELECT Id,Appl__c,Appl__r.TabName__c,FieldApiName__c,ModTime__c,ModBy__c,ModBy__r.Name,NewValue__c,ObjApiName__c,OldValue__c,RefObj__c,UW_Reviewed__c,(SELECT   APIName__c,RefID__c , RefObj__c FROM API_Retrigger_Tracker__r WHERE IsProcessed__c = false) FROM RetriggerUpsertAudit__c WHERE LoanApp__c =: loanAppId];
        }
        
        system.debug('retriggerUpsertAuditRecords ' +retriggerUpsertAuditRecords);
        system.debug('retriggerUpsertAuditRecords size ' + retriggerUpsertAuditRecords.size());
        List<string> userIds= new List<string>();
        Map<Id, string> mapOfIdWithRole= new Map<Id, string>();
        for(RetriggerUpsertAudit__c reUpRec : retriggerUpsertAuditRecords){
	        userIds.add(reUpRec.ModBy__r.Id);
        }
        system.debug('userIds'+userIds);
        if(userIds.size()>0){
            List<TeamHierarchy__c> teamHieList=[Select id, EmpRole__c, Employee__c from TeamHierarchy__c where Employee__c IN: userIds];
            system.debug('teamHieList'+teamHieList);
            if(teamHieList.size()>0){
                mapOfIdWithRole.put(teamHieList[0].Employee__c, teamHieList[0].EmpRole__c);
                system.debug('mapOfIdWithRole'+mapOfIdWithRole);
            }
        }
        if(retriggerUpsertAuditRecords != null && retriggerUpsertAuditRecords.size() > 0){
            
            for(RetriggerUpsertAudit__c reUpRec : retriggerUpsertAuditRecords){
                ChangeSummaryData changeSum = new ChangeSummaryData();
                changeSum.applicantName = reUpRec.Appl__r.TabName__c;
                changeSum.fieldName = Schema.getGlobalDescribe().get(reUpRec.ObjApiName__c).getDescribe().fields.getMap().get(reUpRec.FieldApiName__c).getDescribe().getLabel();
                changeSum.oldValue = reUpRec.OldValue__c;
                changeSum.newValue = reUpRec.NewValue__c;
                changeSum.timeStamp = reUpRec.ModTime__c;
                changeSum.whoChanged = reUpRec.ModBy__r.Name;
                changeSum.Role = mapOfIdWithRole.get(reUpRec.ModBy__c) != null ? mapOfIdWithRole.get(reUpRec.ModBy__c) :  '';
                changeSum.uwReviewed = reUpRec.UW_Reviewed__c;
                changeSum.retriggerUpsertAuditId = reUpRec.Id;
                String reTriggerNames = '';
                for(APIRetriggerTracker__c apiRetrigger : reUpRec.API_Retrigger_Tracker__r){
                   reTriggerNames += apiRetrigger.APIName__c + ',';
                }
                reTriggerNames = reTriggerNames.removeEnd(',');
                changeSum.retriggerApis = reTriggerNames;
                changeSummaryList.add(changeSum);
            }   
        }
        if(changeSummaryList != null && changeSummaryList.size() > 0){
            system.debug('changeSummaryList ' + changeSummaryList);
            system.debug('changeSummaryList size  ' + changeSummaryList.size());
            return changeSummaryList;
        }
        return null;
    }

    @AuraEnabled
    public static void updateUwReviewedStatus(String retriggerUpsertAuditId, String loanAppId, Boolean uwReviewed) {
        // Query the specific RetriggerUpsertAudit record related to the loanAppId and auditId
        // RetriggerUpsertAudit__c auditRecord = [
        //     SELECT Id, UW_Reviewed__c 
        //     FROM RetriggerUpsertAudit__c 
        //     WHERE LoanApp__c = :loanAppId AND Id = :auditId 
        //     LIMIT 1
        // ];

        RetriggerUpsertAudit__c auditRecord = [
            SELECT Id, UW_Reviewed__c 
            FROM RetriggerUpsertAudit__c 
            WHERE LoanApp__c = :loanAppId AND Id = :retriggerUpsertAuditId
            LIMIT 1
        ];
        // RetriggerUpsertAudit__c auditRecord = [
        //     SELECT Id, LoanApp__r.UW_Reviewed__c 
        //     FROM RetriggerUpsertAudit__c 
        //     WHERE LoanApp__c = :loanAppId 
        //     LIMIT 1
        // ];

        // Update the UW_Reviewed__c field
        auditRecord.UW_Reviewed__c = uwReviewed;

        // Perform the update in the database
        update auditRecord;
    }
    
    public class ChangeSummaryData {
        @AuraEnabled
        public String retriggerUpsertAuditId { get; set; }
        @AuraEnabled
        public String applicantName { get; set; }
        @AuraEnabled
        public String fieldName { get; set; }
        @AuraEnabled
        public String oldValue { get; set; }
        @AuraEnabled
        public String newValue { get; set; }
        @AuraEnabled
        public Datetime timeStamp { get; set; }
        @AuraEnabled
        public String retriggerApis { get; set; }
        @AuraEnabled
        public String whoChanged { get; set; }
        @AuraEnabled
        public String Role { get; set; }
        @AuraEnabled
        public Boolean uwReviewed { get; set; }
        
    }
}