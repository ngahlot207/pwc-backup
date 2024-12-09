/** 
* ********************************************************
* Created By : Paresh Saindane
* Created Date: 27-Jun-2024
* ********************************************************
*/
public class createLoanTeamForLoanAppealHandler {
    public static void createLoanTeam(List<LoanAppeal__c> newList){
        system.debug('newList::::::'+newList+newList.size());
        try{
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( 
                new List<SObjectType> { LoanTeam__c.SObjectType }
            );
            // list<Group> grpList = new list<Group>([SELECT Id, Name, DeveloperName, Type FROM Group Where Name = 'AllUWGroup' limit 1]);
            
            
            map<string,list<TeamHierarchy__c>> BranchEmpMap = new map<string,list<TeamHierarchy__c>>();
            map<string,list<LoanAppeal__c>> loanAppMap = new map<string,List<LoanAppeal__c>>();
            set<Id> loanAppealIdSet = new Set<Id>();
            set<Id> loanSet =new Set<Id>();
            map<string, string> loanApplMap= new map<string, string>();
             map<string, string> loanApplProdMap= new map<string, string>();
            Map<Id,Set<Id>> existingLoanTeamRecord = new Map<ID,Set<Id>>();
            List<LoanTeam__c > loanTeamList = new List<LoanTeam__c >();
            //Set<String> deleteExistingLoanTeamIds = new Set<Id>();
            Map<String,Id> uniqueTeamToLNTeamid = new Map<String,Id>();
            for(LoanAppeal__c ln : newList){
                loanSet.add(ln.LoanAppl__c);
                
            }
            
            for(LoanAppl__c ln : [select id,BrchCode__c,Product__c FROM LoanAppl__c WHERE Id in : loanSet]){
                loanApplMap.put(ln.Id, ln.BrchCode__c);
                loanApplProdMap.put(ln.Id,ln.Product__c);
            }
            
            for(LoanAppeal__c appeal : newList){
                loanAppealIdSet.add(appeal.id);
                String branchCode = loanApplMap.get(appeal.LoanAppl__c);
               // if(appeal.LoanAppl__c != null && appeal.LoanAppl__r.BrchCode__c != null){
                    if(loanAppMap.containskey(branchCode)){  
                        loanAppMap.get(branchCode).add(appeal);
                    }else{
                        loanAppMap.put(branchCode,new list<LoanAppeal__c>{appeal});
                    }
              //  }   
            }
            system.debug('loanAppMap::::47'+loanAppMap);
            
            for(LoanTeam__c existingLoanTeam: [Select Id,User__c,LoanAppeal__c,UniqueTeamId__c FROM LoanTeam__c WHERE LoanAppeal__c IN:loanAppealIdSet]){
                if(!String.isEmpty(existingLoanTeam.UniqueTeamId__c)){
                    uniqueTeamToLNTeamid.put(existingLoanTeam.UniqueTeamId__c,existingLoanTeam.Id);
                }                
            }
            
            for(TeamHierarchy__c T:[select employee__c,EmpBrch__r.BrchCode__c,EmpRole__c,Supervisor__c,Supervisor__r.Employee__c,Supervisor__r.Employee__r.isActive,
                                    Supervisor__r.emprole__c, Product_Type__c from TeamHierarchy__c
                                    where EmpBrch__r.BrchCode__c in :loanAppMap.keyset() and employee__r.isActive=true]){
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
            map<String,LoanTeam__c> mapLoanTeam = new map<String,LoanTeam__c>();
            for(LoanAppeal__c appeal : newList){
               String branchCode = loanApplMap.get(appeal.LoanAppl__c);
               string lanProduct = loanApplProdMap.get(appeal.LoanAppl__c);
                if(BranchEmpMap.containsKey(branchCode))
                    for(TeamHierarchy__c team : BranchEmpMap.get(branchCode)){
                        system.debug('BranchEmpMap::::83'+BranchEmpMap);
                        if(team.Product_Type__c != null && lanProduct != null){
                            if(team.Product_Type__c.contains(lanProduct) ){
                                
                                if(team.Supervisor__r.emprole__c != null && team.Supervisor__c !=null && sharingMdtMap.get(GlobalConstants.Sharing_Mdt_Sales).SupervisoreRoleSharing__c !=null && team.Supervisor__r.Employee__r.isActive==true){
                                    if(sharingMdtMap.get(GlobalConstants.Sharing_Mdt_Sales).SupervisoreRoleSharing__c.contains(team.Supervisor__r.emprole__c)){
                                        LoanTeam__c lnTeam = new LoanTeam__c();
                                        lnTeam.LoanAppeal__c = appeal.id;
                                        lnTeam.Stage__c = appeal.LoanAppl__r.Stage__c;
                                        lnTeam.SubStage__c = appeal.LoanAppl__r.SubStage__c;
                                        lnTeam.ObjAPIName__c = 'LoanAppeal__c';
                                        lnTeam.ObjAccess__c = 'Read';
                                        lnTeam.User__c = team.Supervisor__r.Employee__c;
                                        lnTeam.UserId__c = team.Supervisor__r.Employee__c;
                                        lnTeam.ShareReason__c = sharingMdtMap.get(GlobalConstants.Sharing_Mdt_Sales).SharingReason__c; 
                                        lnTeam.UniqueTeamId__c = appeal.id+'-'+lnTeam.User__c;
                                        if(uniqueTeamToLNTeamid.containsKey(lnTeam.UniqueTeamId__c)){
                                            uniqueTeamToLNTeamid.remove(lnTeam.UniqueTeamId__c);// in the in this map we will get only loan team which need to be deleted
                                        }
                                        mapLoanTeam.put(appeal.Id+'-'+lnTeam.User__c,lnTeam);
                                    }
                                    
                                }
                                if(team.emprole__c != null && sharingMdtMap.get(GlobalConstants.Sharing_Mdt_Sales).BrchRoleSharing__c !=null){
                                    if(sharingMdtMap.get(GlobalConstants.Sharing_Mdt_Sales).BrchRoleSharing__c.contains(team.emprole__c)){
                                        LoanTeam__c lnTeam = new LoanTeam__c();
                                        lnTeam.LoanAppeal__c = appeal.id;
                                        lnTeam.Stage__c = appeal.LoanAppl__r.Stage__c;
                                        lnTeam.SubStage__c = appeal.LoanAppl__r.SubStage__c;
                                        lnTeam.ObjAPIName__c = 'LoanAppeal__c';
                                        lnTeam.ObjAccess__c = 'Read';
                                        lnTeam.UserId__c = team.Employee__c; 
                                        lnTeam.User__c = team.Employee__c;
                                        lnTeam.ShareReason__c = sharingMdtMap.get(GlobalConstants.Sharing_Mdt_Sales).SharingReason__c;
                                        lnTeam.UniqueTeamId__c = appeal.id+'-'+lnTeam.User__c;
                                        if(uniqueTeamToLNTeamid.containsKey(lnTeam.UniqueTeamId__c)){
                                            uniqueTeamToLNTeamid.remove(lnTeam.UniqueTeamId__c);// in the in this map we will get only loan team which need to be deleted
                                        }
                                        mapLoanTeam.put(appeal.Id+'-'+lnTeam.User__c,lnTeam);
                                        
                                    } 
                                }
                                
                                if(Test.isRunningTest()){
                                    sharingMdtMap.get(GlobalConstants.Sharing_Mft_Credit).SupervisoreRoleSharing__c = 'RM,SM,BBH';
                                }
                                
                                if(team.Supervisor__r.emprole__c != null && team.Supervisor__c !=null  && sharingMdtMap.get(GlobalConstants.Sharing_Mft_Credit).SupervisoreRoleSharing__c !=null &&  team.Supervisor__r.Employee__r.isActive==true){
                                    if(sharingMdtMap.get(GlobalConstants.Sharing_Mft_Credit).SupervisoreRoleSharing__c.contains(team.Supervisor__r.emprole__c)){
                                        LoanTeam__c lnTeam = new LoanTeam__c();
                                        lnTeam.LoanAppeal__c = appeal.id;
                                        lnTeam.Stage__c = appeal.LoanAppl__r.Stage__c;
                                        lnTeam.SubStage__c = appeal.LoanAppl__r.SubStage__c;
                                        lnTeam.ObjAPIName__c = 'LoanAppeal__c';
                                        lnTeam.ObjAccess__c = 'Read';
                                        lnTeam.User__c = team.Supervisor__r.Employee__c;
                                        lnTeam.UserId__c = team.Supervisor__r.Employee__c; 
                                        lnTeam.ShareReason__c = sharingMdtMap.get(GlobalConstants.Sharing_Mft_Credit).SharingReason__c;
                                        //lnTeam.User__c = team.Employee__c; 
                                        lnTeam.UniqueTeamId__c = appeal.id+'-'+lnTeam.User__c;
                                        if(uniqueTeamToLNTeamid.containsKey(lnTeam.UniqueTeamId__c)){
                                            uniqueTeamToLNTeamid.remove(lnTeam.UniqueTeamId__c);// in the in this map we will get only loan team which need to be deleted
                                        }
                                        mapLoanTeam.put(appeal.Id+'-'+lnTeam.User__c,lnTeam);
                                        
                                    } 
                                }
                                if(team.emprole__c != null && sharingMdtMap.get(GlobalConstants.Sharing_Mft_Credit).BrchRoleSharing__c !=null){
                                    if(sharingMdtMap.get(GlobalConstants.Sharing_Mft_Credit).BrchRoleSharing__c.contains(team.emprole__c)){
                                        LoanTeam__c lnTeam = new LoanTeam__c();
                                        lnTeam.LoanAppeal__c = appeal.id;
                                        lnTeam.Stage__c = appeal.LoanAppl__r.Stage__c;
                                        lnTeam.SubStage__c = appeal.LoanAppl__r.SubStage__c;
                                        lnTeam.ObjAPIName__c = 'LoanAppeal__c';
                                        lnTeam.ObjAccess__c = 'Read';
                                        lnTeam.UserId__c = team.Employee__c; 
                                        lnTeam.User__c = team.Employee__c;
                                        lnTeam.UniqueTeamId__c = appeal.id+'-'+lnTeam.User__c;
                                        lnTeam.ShareReason__c = sharingMdtMap.get(GlobalConstants.Sharing_Mft_Credit).SharingReason__c;
                                        if(uniqueTeamToLNTeamid.containsKey(lnTeam.UniqueTeamId__c)){
                                            uniqueTeamToLNTeamid.remove(lnTeam.UniqueTeamId__c);// in the in this map we will get only loan team which need to be deleted
                                        }
                                        mapLoanTeam.put(appeal.Id+'-'+lnTeam.User__c,lnTeam);
                                        
                                    } 
                                    
                                }
                                
                                
                            }
                            
                            
                        }
                        
                        
                    }
                
                
                
            }
            system.debug('loanTeamList::::::'+loanTeamList+'loanTeamList'+loanTeamList.size());
            if(!loanAppealIdSet.isEmpty()){
                
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
    
}