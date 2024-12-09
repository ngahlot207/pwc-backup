/** 
* ********************************************************
* Created By : Paresh Saindane
* Created Date: 07-Aug-2024
* ********************************************************
*/
public class CreateLoanTeamForCase implements TriggerAction.AfterInsert, TriggerAction.AfterUpdate{
    public static void AfterInsert(List<Case> newList){
        system.debug('newList::::::'+newList+newList.size());
        try{
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( 
                new List<SObjectType> { LoanTeam__c.SObjectType }
            );
            
            list<string> sharingRole = new list<string>(); 
            map<string,list<TeamHierarchy__c>> BranchEmpMap = new map<string,list<TeamHierarchy__c>>();
            map<string,list<Case>> caseMap = new map<string,List<Case>>();
            set<Id> caseIdSet = new Set<Id>();
            set<Id> loanSet =new Set<Id>();
            map<string, string> loanApplMap= new map<string, string>();
            map<string, string> loanApplProdMap= new map<string, string>();
            Map<Id,Set<Id>> existingLoanTeamRecord = new Map<ID,Set<Id>>();
            List<LoanTeam__c > loanTeamList = new List<LoanTeam__c >();
            Map<String,Id> uniqueTeamToLNTeamid = new Map<String,Id>();
            for(Case c : newList){
                loanSet.add(c.Loan_Application__c);
                if(c.CaseType__c == 'Legal' || c.CaseType__c == 'TSR' || c.CaseType__c == 'Vetting'){
                    list<string> hubManagerRoles=system.label.RoleHubManager.split(',');
                    sharingRole.addAll(hubManagerRoles);
                }else if(c.CaseType__c == 'RCU'){
                    list<string> rcuRoles=system.label.RolesRCUManager.split(',');
                    sharingRole.addAll(rcuRoles);
                }
            }
            system.debug('sharingRole::::36'+sharingRole);
            for(LoanAppl__c ln : [select id,BrchCode__c,Product__c FROM LoanAppl__c WHERE Id in : loanSet]){
                loanApplMap.put(ln.Id, ln.BrchCode__c);
                loanApplProdMap.put(ln.Id,ln.Product__c);
            }
            
            for(Case cs : newList){
                caseIdSet.add(cs.id);
                String branchCode = loanApplMap.get(cs.Loan_Application__c);
                if(caseMap.containskey(branchCode)){  
                    caseMap.get(branchCode).add(cs);
                }else{
                    caseMap.put(branchCode,new list<Case>{cs});
                }
            }
            system.debug('loanAppMap::::47'+caseMap);
            
            for(LoanTeam__c existingLoanTeam: [Select Id,User__c,Case__c,UniqueTeamId__c FROM LoanTeam__c WHERE Case__c IN:caseIdSet]){
                if(!String.isEmpty(existingLoanTeam.UniqueTeamId__c)){
                    uniqueTeamToLNTeamid.put(existingLoanTeam.UniqueTeamId__c,existingLoanTeam.Id);
                }                
            }
            
            for(TeamHierarchy__c T:[select employee__c,EmpBrch__r.BrchCode__c,EmpRole__c,Supervisor__c,Supervisor__r.Employee__c,Supervisor__r.Employee__r.isActive,
                                    Supervisor__r.emprole__c, Product_Type__c from TeamHierarchy__c
                                    where EmpBrch__r.BrchCode__c in :caseMap.keyset() and employee__r.isActive=true AND EmpRole__c IN : sharingRole]){
                                        system.debug('T:::::62'+ T);
                                        if(BranchEmpMap.containsKey(T.EmpBrch__r.BrchCode__c)){
                                            BranchEmpMap.get(T.EmpBrch__r.BrchCode__c).add(T);
                                        }else{
                                            BranchEmpMap.put(T.EmpBrch__r.BrchCode__c,new list<TeamHierarchy__c>{T});
                                            
                                        }
                                    }
            system.debug('BranchEmpMap' +BranchEmpMap+'BranchEmpMap Size:::::'+'BranchEmpMap.keySet()'+BranchEmpMap.keySet()+BranchEmpMap.size());
            
            map<String,LoanTeam__c> mapLoanTeam = new map<String,LoanTeam__c>();
            for(Case cs : newList){
                String branchCode = loanApplMap.get(cs.Loan_Application__c);
                string lanProduct = loanApplProdMap.get(cs.Loan_Application__c);
                if(BranchEmpMap.containsKey(branchCode))
                    for(TeamHierarchy__c team : BranchEmpMap.get(branchCode)){
                        system.debug('BranchEmpMap::::83'+BranchEmpMap);
                        if(team.Product_Type__c != null && lanProduct != null){
                            if(team.Product_Type__c.contains(lanProduct) ){
                                if(team.emprole__c != null){
                                    if(cs.CaseType__c == 'Legal' || cs.CaseType__c == 'TSR' || cs.CaseType__c == 'Vetting' || cs.CaseType__c =='RCU'){
                                        LoanTeam__c lnTeam = new LoanTeam__c();
                                        lnTeam.Case__c = cs.id;
                                        lnTeam.Stage__c = cs.Loan_Application__r.Stage__c;
                                        lnTeam.SubStage__c = cs.Loan_Application__r.SubStage__c;
                                        lnTeam.ObjAPIName__c = 'Case';
                                        lnTeam.ObjAccess__c = 'Read';
                                        lnTeam.UserId__c = team.Employee__c; 
                                        lnTeam.User__c = team.Employee__c;
                                        lnTeam.ShareReason__c = 'Manual';
                                        lnTeam.UniqueTeamId__c = cs.id+'-'+lnTeam.User__c;
                                        if(uniqueTeamToLNTeamid.containsKey(lnTeam.UniqueTeamId__c)){
                                            uniqueTeamToLNTeamid.remove(lnTeam.UniqueTeamId__c);// in the in this map we will get only loan team which need to be deleted
                                        }
                                        mapLoanTeam.put(cs.Id+'-'+lnTeam.User__c,lnTeam);
                                    }
                                    
                                }
                                
                                
                            }
                            
                            
                        }
                        
                        
                    }
                
                
                
            }
            system.debug('loanTeamList::::::'+loanTeamList+'loanTeamList'+loanTeamList.size());
            if(!caseIdSet.isEmpty()){
                
            }
            if(!mapLoanTeam.isEmpty()){
                upsert mapLoanTeam.values() UniqueTeamId__c;
            }
            if(!uniqueTeamToLNTeamid.isEmpty()){
                Database.delete(uniqueTeamToLNTeamid.values());
            }
            //uow.registerUpsert(mapLoanTeam.values());
            //uow.commitWork();
        }catch(exception e){
            system.debug('EXCEPTION:::::::::'+e.getMessage()+e.getLineNumber());
        }
        
    }
    public static void AfterUpdate(List<Case> newList, List<Case> oldList){
        List<Case> caseList = new List<Case>();
        map <Id,Case> oldMap = new map<Id,Case>(oldList);
        for(Case  c : newList){
            if(c.Id == oldMap.get(c.Id).Id && (c.Description != oldMap.get(c.Id).Description)){
                caseList.add(c);
            }
            
        }
        if(!caseList.isEmpty()){
            AfterInsert(caseList); 
        }
    }
}