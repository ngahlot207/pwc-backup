/** 
* ********************************************************
* Created By : Paresh Saindane
* Created Date: 01-Sept-2023
* ********************************************************
*/
public without sharing class SharingRuleDefn implements TriggerAction.AfterInsert {
    public static void afterInsert(List<LoanTeam__c> newList) {
        createSharingRules(newList);
    }
    
    public static void createSharingRules(list<LoanTeam__c> newList) {
        try{
        system.debug('list of LoanTeam__c' + newList);
		List<Sobject> shList = new List<Sobject>();
		set<Id> loanApplicationIdSet = new Set<Id>();
        for (LoanTeam__c lnTeam : newList) {
            Id objId = null;
            Id  userOrGroupId;
            string objectApiName = '';
            if(lnTeam.User__c != null){
                  userOrGroupId = lnTeam.User__c;
            }
            else {
                  userOrGroupId = lnTeam.GroupId__c;
            }
            if(lnTeam.LoanApplication__c != null){
                objId = lnTeam.LoanApplication__c;
            }else if(lnTeam.LoanAppeal__c != null){
                objId = lnTeam.LoanAppeal__c;
            }else if(lnTeam.Case__c != null){
                objId = lnTeam.Case__c;
            }else if(lnTeam.Lead__c != null){
                objId = lnTeam.Lead__c;
            }
           
            
			loanApplicationIdSet.add(lnTeam.LoanApplication__c);
            objectApiName = lnTeam.ObjApiName__c;
            system.debug('lnTeam.ObjApiName__c' + lnTeam.ObjApiName__c);
           
            system.debug(
                'parameters /OBJECT ID/ ' +
                    objId +
                    '/USER OR GROUP ID /' +
                    lnTeam.User__c +
                    '/OBJECT ACCESS/' +
                    lnTeam.ObjAccess__c +
                    '/Obejct Api Name/' +
                    objectApiName +
                '//Share Reason::::'+lnTeam.ShareReason__c
            );
            if (
                (objId != null ||
                objId != '') &&
                (userOrGroupId != null ||
                userOrGroupId != '') &&
                (lnTeam.ObjAccess__c != null ||
                lnTeam.ObjAccess__c != '') &&
                (objectApiName != null ||
                 objectApiName != '') &&
                (lnTeam.ShareReason__c != null ||
                lnTeam.ShareReason__c != '')
            ) {
                sObject sh = manualShareRead(
                    objId,
                    userOrGroupId,
                    lnTeam.ObjAccess__c,
                    objectApiName,
                    lnTeam.ShareReason__c
                );
				shList.add(sh);
				
            }
        }
		
		/*if(!loanApplicationIdSet.isEmpty()){
			List<LoanAppl__share> deleteshList = new List<LoanAppl__share>();
			deleteshList = [
				SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause
				FROM LoanAppl__Share
				WHERE
					ParentId IN:loanApplicationIdSet
					AND RowCause IN ('Sales__c','Credit__c','Ops__c')
			];
			if(!deleteshList.isEmpty()){
				delete deleteshList;
			}
		}*/
		if(!shList.isEmpty()){
			insert shList;
		}
    }catch (Exception ex) {
        GlobalUtility.logMessage(
            'Error',
            'class name :: SharingRuleDefn and method names is :: crerateSharingRules' +
            ex.getLineNumber(),
            'Generate',
            null,
            null,
            ex.getMessage() + ' Line: ' + ex.getLineNumber(),
            null,
            ex,
            null
        );
        //throw new AuraHandledException(ex.getMessage());
    }
    }

    @AuraEnabled
    public static sObject manualShareRead(
        Id objId,
        Id userOrGroupId,
        string accessLvl,
        string sharingObjNm,
        string sharingReason
    ) {
        
			system.debug('manualShareRead called');
        if(sharingObjNm != 'Case' && sharingObjNm != 'Lead'){
            String shareObject = sharingObjNm.replace('__c', '__Share');
			sObject sh = (sObject) Type.forName(shareObject).newInstance();
            system.debug('inside if');
			sh.put('UserOrGroupId', userOrGroupId);
			sh.put('AccessLevel', accessLvl);
			sh.put('ParentId', objId);
			sh.put('RowCause',sharingReason);
            return sh;
        }else{
            if(sharingObjNm == 'Case'){
                sObject sh = new CaseShare();
			sh.put('UserOrGroupId', userOrGroupId);
			sh.put('CaseAccessLevel', accessLvl);
			sh.put('CaseId', objId);
			sh.put('RowCause',sharingReason);
            return sh;
            }
            else if(sharingObjNm == 'Lead'){
                system.debug('inside lead');
                sObject sh = new LeadShare();
			sh.put('UserOrGroupId', userOrGroupId);
			sh.put('LeadAccessLevel', accessLvl);
			sh.put('LeadId', objId);
			sh.put('RowCause',sharingReason);
            return sh;
            }
            return null;
        }	
			
			
    
    }

    /*@AuraEnabled
    public static string assignSharing(List<WrpSharing> sharingList) {
        try {
            for (WrpSharing sList : sharingList) {
                manualShareRead(
                    sList.objectId,
                    sList.userOrGroupId,
                    sList.accessLevel,
                    sList.sharingObjectName,
                    sList.sharingReason
                );
            }
            system.debug('assigneSharing done');
            return 'Sharing Setting Successful';
        } catch (Exception ex) {
            GlobalUtility.logMessage(
                'Error',
                'class name :: SharingRuleDefn and method names is :: assignSharing' +
                ex.getLineNumber(),
                'Generate',
                null,
                null,
                ex.getMessage() + ' Line: ' + ex.getLineNumber(),
                null,
                ex,
                null
            );
            //throw new AuraHandledException(ex.getMessage());
        }
    }*/

    public class WrpSharing {
        @AuraEnabled
        public Id objectId { get; set; }
        @AuraEnabled
        public Id userOrGroupId { get; set; }
        @AuraEnabled
        public string accessLevel { get; set; }
        @AuraEnabled
        public string sharingObjectName { get; set; }
        @AuraEnabled
        public string sharingReason { get; set; }
    }
}