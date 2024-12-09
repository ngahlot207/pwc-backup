/** 
* ********************************************************
* Created By : Tahura Bayazid
* Created Date: 05-Aug-2023
* ********************************************************
*/
public without sharing class InsertLeadSharingRule implements TriggerAction.AfterInsert {
    public static set<id> successRecord = new set<id>();
    public static void afterInsert(List<Lead> newList) {
       // createSharingRules(newList);
        createLeadTeamHandler.createLeadTeam(newList);
    }
    public static void createSharingRules(list<Lead> newList){
        list<LeadShare> leadShareRecords = new list<LeadShare>();        
        map<id,list<Lead>> leadOwner = new map<id,list<Lead>>();
        Map<Id,List<Id>> superVisorMap = new Map<Id,List<Id>>();        
        map<id,list<id>> ownerBranchMap = new map<id,List<Id>>();
        map<id,Lead> deduplicate = new map<id,Lead>();       
        map<id,list<id>> BranchEmpMap = new map<id,list<id>>();
        set<id> branchIds = new set<id>();
        
        
        for(Lead leadRec : newList){
            system.debug('Lead' +leadRec);
            
            if(leadOwner.containsKey(leadRec.ownerId)){
                leadowner.get(leadRec.OwnerId).add(leadRec);
            }else{
                leadOwner.put(leadRec.ownerId ,new list<Lead>{leadRec});
            }
            
            system.debug('leadOwner'+leadOwner);
        } 
        
        for(TeamHierarchy__c TH: [select employee__c,EmpBrch__c,EmpRole__c,Supervisor__r.emprole__c,Supervisor__r.EmpBrch__c,Supervisor__r.employee__c,Supervisor__r.Supervisor__r.Employee__c from TeamHierarchy__c where employee__c in: leadOwner.keyset()])
        {
            if(TH.EmpRole__c<> Null && (TH.EmpRole__c=='RM' || TH.EmpRole__c=='SM'))
            {
                //listOfSupervisorID
                if(superVisorMap.containsKey(th.employee__c)){
                    superVisorMap.get(th.employee__c).add(TH.Supervisor__r.employee__c);
                }else{
                    superVisorMap.put(TH.employee__c ,new list<Id>{TH.Supervisor__r.employee__c});
                }
                if(th.Supervisor__r.emprole__c == 'SM'){
                    if(superVisorMap.containsKey(th.employee__c)){
                        superVisorMap.get(th.employee__c).add(TH.Supervisor__r.Supervisor__r.Employee__c);
                    }else{
                        superVisorMap.put(TH.employee__c ,new list<Id>{TH.Supervisor__r.Supervisor__r.Employee__c});
                    }
                }
                system.debug('superVisorMap' +superVisorMap);
                
            } 
            
            
            
            if(TH.EmpRole__c<> Null)
            {
                branchIds.add(TH.EmpBrch__c);
                //ownerBranchMap.put(TH.employee__c,TH.EmpBrch__c);
                if(ownerBranchMap.containsKey(th.employee__c)){
                    ownerBranchMap.get(th.employee__c).add(TH.EmpBrch__c);
                }else{
                    ownerBranchMap.put(TH.employee__c ,new list<Id>{TH.EmpBrch__c});
                }                
            }
            system.debug('branchIds' +branchIds);
            system.debug('ownerBranchMap' +ownerBranchMap);
            
        }
        
        
        for(TeamHierarchy__c T:[select employee__c,EmpBrch__c,EmpRole__c,Supervisor__r.emprole__c,Supervisor__r.EmpBrch__c,Supervisor__r.employee__c from TeamHierarchy__c where EmpBrch__c in:branchIds and EmpRole__c in ('CBH','ABH','RBH','DBH','CBO','BH','NSM','BBH')]){
            
            if(BranchEmpMap.containsKey(T.EmpBrch__c)){
                BranchEmpMap.get(T.EmpBrch__c).add(T.employee__c);
            }else{
                BranchEmpMap.put(T.EmpBrch__c,new list<Id>{T.employee__c});
                
            }
        }
        system.debug('BranchEmpMap' +BranchEmpMap); 
        
        for(Lead L: newList ) 
        {
            
            if(superVisorMap.containsKey(l.ownerId))
            {
                for (Id userId: superVisorMap.get(L.ownerId))
                {
                    if(String.isNotEmpty(userId)){
                        deduplicate.put(userId,L);
                        // Create new sharing object for the custom object Job.
                        LeadShare jobShr  = new LeadShare();
                        // Set the ID of record being shared
                        jobShr.LeadId = L.Id;
                        // Set the ID of user or group being granted access.
                        jobShr.UserOrGroupId = userId;
                        // Set the access level.
                        jobShr.LeadAccessLevel = 'Edit';
                        jobShr.RowCause = 'Manual';
                        leadShareRecords.add(jobShr);
                        system.debug('jobShr'+jobShr);
                        system.debug('userid from supervisor' +userId);    
                    }
                    
                    
                }}
        }
        
        
        //createLead Share record;
        
        for(Lead L: newList)
        {
            if(ownerBranchMap.containsKey(l.ownerId)){
                for (Id branch_ID :ownerBranchMap.get(L.ownerId))
                    
                {
                    if(BranchEmpMap.containsKey(branch_ID)){
                        for (Id userId: BranchEmpMap.get(branch_ID))
                            //   system.debug('userId id in loop' +BranchEmpMap.get(branch_ID));
                        {
                            //deduplicate checking
                            if(!deduplicate.containskey(userId) && String.isNotEmpty(userId)){
                                LeadShare jobShr  = new LeadShare();
                                jobShr.LeadId = L.Id;
                                jobShr.UserOrGroupId = userId;
                                jobShr.LeadAccessLevel = 'Edit';
                                jobShr.RowCause = 'Manual';
                                leadShareRecords.add(jobShr);
                                system.debug('userid from higherrole' +userId);
                            }
                        }}}}}
        
        
        
        
        system.debug('leadShareRecords'+leadShareRecords);
        
        Database.SaveResult[] sr = Database.insert(leadShareRecords,false);
        for(Database.SaveResult s:sr){
            if(s.issuccess()){
                successRecord.add(s.getId());
                system.debug('successRecord' +successRecord);
                system.debug('successful LeadShare'  +s.getId());
            }
            else
            {
                for (database.Error err:s.getErrors())
                {
                    system.debug('error msg' +err.getMessage());
                }
            }
        }
        
        system.debug('sr'  +sr);
        //return leadShareRecords;
        
        
        
    }
}