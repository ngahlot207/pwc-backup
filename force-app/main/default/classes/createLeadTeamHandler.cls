/** 
* ********************************************************
* Created By : Tahura bayazid
* Created Date: 11-Sep-2024
* ********************************************************
*/
public class createLeadTeamHandler {
    public static void createLeadTeam(List<Lead> newList){
        system.debug('newList::::::'+newList+newList.size());
        try{
            
            
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( 
                new List<SObjectType> { LoanTeam__c.SObjectType }
            );
           
            map<String,LoanTeam__c> mapLoanTeam = new map<String,LoanTeam__c>();
            map<string,list<TeamHierarchy__c>> BranchEmpMap = new map<string,list<TeamHierarchy__c>>();
            map<string,list<Lead>> loanAppMap = new map<string,List<Lead>>();
            set<Id> loanApplicationIdSet = new Set<Id>();
            Map<Id,Set<Id>> existingLoanTeamRecord = new Map<ID,Set<Id>>();
            List<LoanTeam__c > loanTeamList = new List<LoanTeam__c >();
            //Set<String> deleteExistingLoanTeamIds = new Set<Id>();
            Map<String,Id> uniqueTeamToLNTeamid = new Map<String,Id>();
            for(Lead LeadApp : newList){
                
               
                loanApplicationIdSet.add(LeadApp.id);
                if(loanAppMap.containskey(LeadApp.Branch_Code__c)){
                    loanAppMap.get(LeadApp.Branch_Code__c).add(LeadApp);
                }else{
                    loanAppMap.put(LeadApp.Branch_Code__c,new list<Lead>{LeadApp});
                }
                
            }
            
            
            
            
            for(TeamHierarchy__c T:[select employee__c,EmpBrch__r.BrchCode__c,EmpRole__c,Supervisor__c,Supervisor__r.Employee__c,Supervisor__r.Employee__r.isActive,
                                    Supervisor__r.emprole__c, Product_Type__c from TeamHierarchy__c
                                    where EmpBrch__r.BrchCode__c in :loanAppMap.keyset() and employee__r.isActive=true and EmpRole__c in ('RM','SM','BBH','CBH','ABH','RBH','DBH','CBO')]){
                                        system.debug('T:::::'+ T);
                                        
                                        if(BranchEmpMap.containsKey(T.EmpBrch__r.BrchCode__c)){
                                            BranchEmpMap.get(T.EmpBrch__r.BrchCode__c).add(T);
                                        }else{
                                            BranchEmpMap.put(T.EmpBrch__r.BrchCode__c,new list<TeamHierarchy__c>{T});
                                            
                                        }
                                    }
            system.debug('BranchEmpMap' +BranchEmpMap+'BranchEmpMap Size:::::'+'BranchEmpMap.keySet()'+BranchEmpMap.keySet()+BranchEmpMap.size());
            

            map<string,SharingHierarchy__mdt> sharingMdtMap = new map<string,SharingHierarchy__mdt>();
            
            List<SharingHierarchy__mdt> shrngConfigList = [select Id, DeveloperName, MasterLabel, Label,
                                                           QualifiedApiName, SupervisoreRoleSharing__c, BrchRoleSharing__c,SharingReason__c
                                                           from SharingHierarchy__mdt];
            
            system.debug('shrngConfigList '+ shrngConfigList + 'size of shrngConfigList::::::'+shrngConfigList.size());
            
            for(SharingHierarchy__mdt sch : shrngConfigList){
                sharingMdtMap.put(sch.label,sch);
            }
            
            for(Lead leadApp : newList){
                if(BranchEmpMap.containsKey(leadApp.Branch_Code__c))
                    for(TeamHierarchy__c team : BranchEmpMap.get(leadApp.Branch_Code__c)){
                        if(team.Product_Type__c != null && leadApp.Product__c != null){
                            if(team.Product_Type__c.contains(leadApp.Product__c) ){
                                
                                if((leadApp.ownerId ==team.Employee__c ) && team.Supervisor__r.emprole__c != null && team.Supervisor__c !=null &&  team.Supervisor__r.Employee__r.isActive==true){
                                   // if(sharingMdtMap.get(GlobalConstants.Sharing_Mdt_Sales).SupervisoreRoleSharing__c.contains(team.Supervisor__r.emprole__c)){
                                        LoanTeam__c lnTeam = new LoanTeam__c();
                                        lnTeam.Lead__c = leadApp.id;
                                       // lnTeam.Stage__c = loanApp.Stage__c;
                                        //lnTeam.SubStage__c = loanApp.SubStage__c;
                                        lnTeam.ObjAPIName__c = 'Lead';
                                        lnTeam.ObjAccess__c = 'Read';
                                        lnTeam.User__c = team.Supervisor__r.Employee__c;
                                        lnTeam.UserId__c = team.Supervisor__r.Employee__c;
                                        lnTeam.ShareReason__c = 'Manual'; 
                                        lnTeam.UniqueTeamId__c = leadApp.id+'-'+lnTeam.User__c;
                                        if(uniqueTeamToLNTeamid.containsKey(lnTeam.UniqueTeamId__c)){
                                            uniqueTeamToLNTeamid.remove(lnTeam.UniqueTeamId__c);// in the in this map we will get only loan team which need to be deleted
                                        }
                                        mapLoanTeam.put(leadApp.Id+'-'+lnTeam.User__c,lnTeam);
                                   // }
                                    
                                }
                                if(team.emprole__c != null ){
                                   // if(sharingMdtMap.get(GlobalConstants.Sharing_Mdt_Sales).BrchRoleSharing__c.contains(team.emprole__c)){
                                        LoanTeam__c lnTeam = new LoanTeam__c();
                                        lnTeam.Lead__c = leadApp.id;
                                        //lnTeam.Stage__c = loanApp.Stage__c;
                                        //lnTeam.SubStage__c = loanApp.SubStage__c;
                                        lnTeam.ObjAPIName__c = 'Lead';
                                        lnTeam.ObjAccess__c = 'Read';
                                        //lnTeam.UserId__c = team.Employee__c; 
                                        lnTeam.User__c = team.Employee__c;
                                        lnTeam.ShareReason__c = 'Manual';
                                        lnTeam.UniqueTeamId__c = leadApp.id+'-'+lnTeam.User__c;
                                        if(uniqueTeamToLNTeamid.containsKey(lnTeam.UniqueTeamId__c)){
                                            uniqueTeamToLNTeamid.remove(lnTeam.UniqueTeamId__c);// in the in this map we will get only loan team which need to be deleted
                                        }
                                        mapLoanTeam.put(leadApp.Id+'-'+lnTeam.User__c,lnTeam);
                                        
                                   // } 
                                }
                                
                                
                            }
                            
                            
                        }
                        
                        
                    }
                
                
                
            }
           if(!loanApplicationIdSet.isEmpty()){
               
            }
            if(!mapLoanTeam.isEmpty()){
                system.debug('loanTeamList::::::'+mapLoanTeam+'mapLoanTeam'+mapLoanTeam.size());
            
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
    
}