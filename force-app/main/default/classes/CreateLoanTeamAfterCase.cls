public class CreateLoanTeamAfterCase implements TriggerAction.AfterInsert{
    
    public static void AfterInsert(List<Case> newList){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( 
            new List<SObjectType> { LoanTeam__c.SObjectType }
        );
        
        Set<Id> SetContactId = new Set<Id>();
        Set<Id> setLoanApplicationId = new Set<Id>();
        List<LoanTeam__c> listOfLoanTeam = new List<LoanTeam__c>();
        List<LoanTeam__c> inserLoanTeam = new List<LoanTeam__c>();
        Set<Id> setOfUserId = new Set<Id>();
        Map<Id,Id> mapOfUser = new Map<Id,Id>();
        map<String,LoanTeam__c> mapLoanTeam = new map<String,LoanTeam__c>();
        Map<Id,RecordType> recordTypeMap = new map<Id,RecordType>([ select Id,Name from RecordType where sObjectType='Case']);
        system.debug('recordTypeMap ' + recordTypeMap);
        for(Case c : newList){
            if(c.Loan_Application__c != null && c.AccountId != null && c.ContactId != null){
                SetContactId.add(c.ContactId);
                setLoanApplicationId.add(c.Loan_Application__c);
            }
        }
        system.debug('SetContactId:'+SetContactId);
        for(User u: [SELECT ID,ContactId From User WHERE ContactId IN : SetContactId AND IsActive = True]){
            setOfUserId.add(u.Id);
            mapOfUser.put(u.ContactId, u.Id);
        }
        system.debug('setLoanApplicationId:'+setLoanApplicationId);
        system.debug('mapOfUser:'+mapOfUser);
        
        for(Case cs : newList){
            if(cs.AccountId != null && cs.ContactId != null){
                LoanTeam__c lnTeam = new LoanTeam__c();
                lnTeam.LoanApplication__c = cs.Loan_Application__c;
                lnTeam.ObjAPIName__c = 'LoanAppl__c';
                lnTeam.ObjAccess__c = 'Read';
                lnTeam.RecordId__c = cs.Loan_Application__c;
                lnTeam.ShareReason__c = 'Agency__c';
                lnTeam.UserId__c = mapOfUser.get(cs.ContactId);
                lnTeam.User__c = mapOfUser.get(cs.ContactId);
                //lnTeam.UniqueTeamId__c = cs.Loan_Application__c +'-'+ lnTeam.User__c;
                String uniqueTeamId =  cs.Loan_Application__c +'-'+ lnTeam.User__c;
                if (!mapLoanTeam.containsKey(uniqueTeamId) && cs.AccountId != null && cs.ContactId != null && lnTeam.UserId__c != null) {
                    lnTeam.UniqueTeamId__c = uniqueTeamId;
                    mapLoanTeam.put( cs.Loan_Application__c+'-'+mapOfUser.get(cs.ContactId),lnTeam);
                    inserLoanTeam.add(lnTeam);    
                }
            }
            system.debug('cs.RecordType.Name'+cs.RecordType.DeveloperName);
            if(recordTypeMap.get(cs.RecordTypeId).Name=='RCU' && cs.AccountId == null && cs.ContactId == null){
                LoanTeam__c lnTeam = new LoanTeam__c();
                lnTeam.LoanApplication__c = cs.Loan_Application__c;
                lnTeam.ObjAPIName__c = 'LoanAppl__c';
                lnTeam.ObjAccess__c = 'Read';
                lnTeam.RecordId__c = cs.Loan_Application__c;
                lnTeam.ShareReason__c = 'Agency__c';
                lnTeam.UserId__c = cs.OwnerId;
                lnTeam.User__c = cs.OwnerId;
                //lnTeam.UniqueTeamId__c = cs.Loan_Application__c +'-'+ lnTeam.User__c;
                String uniqueTeamId =  cs.Loan_Application__c +'-'+ lnTeam.User__c;
                if (!mapLoanTeam.containsKey(uniqueTeamId) && lnTeam.UserId__c != null) {
                    lnTeam.UniqueTeamId__c = uniqueTeamId;
                    mapLoanTeam.put( cs.Loan_Application__c+'-'+mapOfUser.get(cs.ContactId),lnTeam);
                    inserLoanTeam.add(lnTeam); 
                }
            }
        }
        
        
        if(!inserLoanTeam.isEmpty()){
            /// upsert inserLoanTeam;
            system.debug('inserLoanTeam:'+inserLoanTeam);
        }
        
        if(!mapLoanTeam.isEmpty()){
            upsert mapLoanTeam.values() UniqueTeamId__c;
        }
    }
    
    
    
}