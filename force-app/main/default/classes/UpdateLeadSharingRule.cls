/** 
* ********************************************************
* Created By : Tahura Bayazid
* Created Date: 05-Aug-2023
* ********************************************************
*/
//public class UpdatetLeadSharingRule {

public without sharing class UpdateLeadSharingRule implements TriggerAction.AfterUpdate {
    
    public static void afterUpdate(List<Lead> newList, List<Lead> oldList) {
        //updateSharingRules(newList,oldList);
        Map<Id, Lead> LeadMap = new Map<Id, Lead>(oldList);
        
            for(Lead L: newList){
            if(L.ownerId != LeadMap.get(L.Id).ownerId){
        createLeadTeamHandler.createLeadTeam(newList);
            }}
        
    }
    public static Void updateSharingRules(List<Lead> newList, List<Lead> oldList){
        list<Lead> updateNewList = new list<Lead>();
        list<Lead> updatedList = new list<Lead>();
        Map<Id, Lead> ownerChange = new Map<Id, Lead>();
        Map<Id, Lead> NewownerChange = new Map<Id, Lead>();
        Map<Id, Lead> LeadMap = new Map<Id, Lead>(oldList);
        // Map<Id, Lead> NewLeadMap = new Map<Id, Lead>(newList);
        set<id> Leadids = new set<id>();
        Map<id, LeadShare> UpdatedLeadShareMap = new Map<id, LeadShare>();
        for(Lead L: newList){
            if(L.ownerId != LeadMap.get(L.Id).ownerId){
                ownerChange.put(LeadMap.get(L.Id).ownerId ,LeadMap.get(L.Id));
                NewownerChange.put(L.ownerId ,L);
                
                updateNewList.add(L);
                Leadids.add(L.id);
                system.debug('ownerChange' +ownerChange);
                system.debug('Leadids' +Leadids);
                system.debug('updateNewList' +updateNewList);
                // delete doomedLead;
            }}
        
        if(!ownerChange.isEmpty()){
            LeadShare[] LS = [SELECT Id, LeadId,UserorGroupId FROM LeadShare WHERE UserorGroupId in:ownerChange.keyset() and LeadId in:Leadids and RowCause='Manual'  ];
            delete LS;
            InsertLeadSharingRule.createSharingRules(updateNewList);
            
            //system.debug('The updated LeadShareId' +UpdatedLeadShareMap.keySet());
            //To Update RM/SM Name in owner updated record
            Map<id, TeamHierarchy__c> Map_TeamHierarchy = new Map<id,TeamHierarchy__c>();
            for(TeamHierarchy__c t :[select Employee__c,Emprole__c,Employee__r.Name from TeamHierarchy__c where Employee__c in:NewownerChange.keySet()])
            {
                Map_TeamHierarchy.put(t.Employee__c,t);
            }
            system.debug('The Map of filtered TeamHi '+Map_TeamHierarchy);
            
            Id profileId=userinfo.getProfileId();
            String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
            for(Lead LeadRec : updateNewList)
            {
                //system.debug(updateNewList);
                //system.debug('The Current Lead OwnerId '+LeadRec.OwnerId);
                if(LeadRec.Bulk_Lead__c != true){
                    if(profileName <> 'System Administrator'){
                        if(Map_TeamHierarchy.get(LeadRec.OwnerId).Emprole__c=='RM' || Map_TeamHierarchy.get(LeadRec.OwnerId).Emprole__c=='SM') {
                            
                            Lead l = new lead();
                            l.id=LeadRec.id;
                            l.RM_SM_Name__c= Map_TeamHierarchy.get(LeadRec.ownerId).Employee__c;
                            updatedList.add(l) ;
                        }
                        else{
                            Lead l = new lead();
                            l.id=LeadRec.id;
                            l.RM_SM_Name__c=null;
                            updatedList.add(l) ;
                        }  
                    }
                }
                
                
                
                
            }
            if(!updatedList.isEmpty()){
            update updatedList;    
            }
            
            
            
        }  
        
        
    }
}