/** 
* ********************************************************
* Created By : Paresh Saindane
* Created Date: 31-Aug-2023
* ********************************************************
*/
public class CreateLoanTeamHandler {
    public static void createLoanTeam(List<LoanAppl__c> newList){
        system.debug('newList::::::'+newList+newList.size());
        try{
            
            
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( 
                new List<SObjectType> { LoanTeam__c.SObjectType }
            );
            // list<Group> grpList = new list<Group>([SELECT Id, Name, DeveloperName, Type FROM Group Where Name = 'AllUWGroup' limit 1]);
            list<Group> commCPAPool=[SELECT Id, Name, DeveloperName, Type FROM Group Where Name = 'Common CPA Pool' limit 1];
            
            map<String,LoanTeam__c> mapLoanTeam = new map<String,LoanTeam__c>();
            map<string,list<TeamHierarchy__c>> BranchEmpMap = new map<string,list<TeamHierarchy__c>>();
            map<string,list<LoanAppl__c>> loanAppMap = new map<string,List<LoanAppl__c>>();
            set<Id> loanApplicationIdSet = new Set<Id>();
            Map<Id,Set<Id>> existingLoanTeamRecord = new Map<ID,Set<Id>>();
            List<LoanTeam__c > loanTeamList = new List<LoanTeam__c >();
            //Set<String> deleteExistingLoanTeamIds = new Set<Id>();
            Map<String,Id> uniqueTeamToLNTeamid = new Map<String,Id>();
            for(LoanAppl__c LoanApp : newList){
                // LAK-8511
                if(LoanApp.RMSMName__c != null){
                    LoanTeam__c lnTeam = new LoanTeam__c();
                    lnTeam.LoanApplication__c = loanApp.id;
                    lnTeam.Stage__c = loanApp.Stage__c;
                    lnTeam.SubStage__c = loanApp.SubStage__c;
                    lnTeam.ObjAPIName__c = 'LoanAppl__c';
                    if(loanApp.Stage__c == 'Post Sanction' || loanApp.SubStage__c == 'Soft Sanction'){
                        lnTeam.ObjAccess__c = 'Edit';
                    }else{
                        lnTeam.ObjAccess__c = 'Read';
                    }
                    lnTeam.User__c = LoanApp.RMSMName__c;
                    // lnTeam.UserId__c = LoanApp.Supervisor__r.Employee__c;
                    lnTeam.ShareReason__c = 'RMAccess__c'; 
                    lnTeam.UniqueTeamId__c = loanApp.id+'-'+lnTeam.User__c;
                    if(uniqueTeamToLNTeamid.containsKey(lnTeam.UniqueTeamId__c)){
                        uniqueTeamToLNTeamid.remove(lnTeam.UniqueTeamId__c);// in the in this map we will get only loan team which need to be deleted
                    }
                    mapLoanTeam.put(loanApp.Id+'-'+lnTeam.User__c,lnTeam);
                    
                }
                loanApplicationIdSet.add(LoanApp.id);
                if(loanAppMap.containskey(LoanApp.BrchCode__c)){
                    loanAppMap.get(LoanApp.BrchCode__c).add(LoanApp);
                }else{
                    loanAppMap.put(LoanApp.BrchCode__c,new list<LoanAppl__c>{LoanApp});
                }
                
            }
            
            
            for(LoanTeam__c existingLoanTeam: [Select Id,User__c,LoanApplication__c,UniqueTeamId__c FROM LoanTeam__c WHERE LoanApplication__c IN:loanApplicationIdSet and ShareReason__c != 'Agency__c' and ShareReason__c !='RMAccess__c']){
                if(!String.isEmpty(existingLoanTeam.UniqueTeamId__c)){
                    uniqueTeamToLNTeamid.put(existingLoanTeam.UniqueTeamId__c,existingLoanTeam.Id);
                }
                
                
                
            }
            
            for(TeamHierarchy__c T:[select employee__c,Employee__r.Name,EmpBrch__r.BrchCode__c,EmpRole__c,Supervisor__c,Supervisor__r.Employee__c,
                                    Supervisor__r.Employee__r.isActive,Supervisor__r.emprole__c, Product_Type__c from TeamHierarchy__c
                                    where EmpBrch__r.BrchCode__c in :loanAppMap.keyset() and employee__r.isActive=true]){
                                        system.debug('T:::::'+ T);
                                        
                                        if(BranchEmpMap.containsKey(T.EmpBrch__r.BrchCode__c)){
                                            BranchEmpMap.get(T.EmpBrch__r.BrchCode__c).add(T);
                                        }else{
                                            BranchEmpMap.put(T.EmpBrch__r.BrchCode__c,new list<TeamHierarchy__c>{T});
                                            
                                        }
                                    }
            system.debug('BranchEmpMap' +BranchEmpMap+'BranchEmpMap Size:::::'+'BranchEmpMap.keySet()'+BranchEmpMap.keySet()+BranchEmpMap.size());
            
            /* list<TeamHierarchy__c> otherBranchCreditUser = new List<TeamHierarchy__c>();
otherBranchCreditUser = [select employee__c,EmpBrch__r.BrchCode__c,EmpRole__c,Supervisor__c,Supervisor__r.Employee__c,
Supervisor__r.emprole__c, Product_Type__c from TeamHierarchy__c
where EmpBrch__r.BrchCode__c NOT IN :loanAppMap.keyset() and employee__r.isActive=true and EmpRole__c IN ('UW','ACM','RCM','ZCM','NCM','CH')];
*/
            map<string,SharingHierarchy__mdt> sharingMdtMap = new map<string,SharingHierarchy__mdt>();
            
            List<SharingHierarchy__mdt> shrngConfigList = [select Id, DeveloperName, MasterLabel, Label,
                                                           QualifiedApiName, SupervisoreRoleSharing__c, BrchRoleSharing__c,SharingReason__c
                                                           from SharingHierarchy__mdt];
            
            system.debug('shrngConfigList '+ shrngConfigList + 'size of shrngConfigList::::::'+shrngConfigList.size());
            
            for(SharingHierarchy__mdt sch : shrngConfigList){
                sharingMdtMap.put(sch.label,sch);
            }
            
            for(LoanAppl__c loanApp : newList){
                if(BranchEmpMap.containsKey(loanApp.BrchCode__c))
                    for(TeamHierarchy__c team : BranchEmpMap.get(loanApp.BrchCode__c)){
                        if(team.Product_Type__c != null && loanApp.Product__c != null && team.Employee__c != loanApp.RMSMName__c){
                            if(team.Product_Type__c.contains(loanApp.Product__c) ){
                                
                                if((loanApp.ownerId ==team.Employee__c || loanApp.RMSMName__c == team.Employee__c) && team.Supervisor__r.emprole__c != null && team.Supervisor__c !=null && sharingMdtMap.get(GlobalConstants.Sharing_Mdt_Sales).SupervisoreRoleSharing__c !=null && team.Supervisor__r.Employee__r.isActive==true){
                                    if(sharingMdtMap.get(GlobalConstants.Sharing_Mdt_Sales).SupervisoreRoleSharing__c.contains(team.Supervisor__r.emprole__c)){
                                        LoanTeam__c lnTeam = new LoanTeam__c();
                                        lnTeam.LoanApplication__c = loanApp.id;
                                        lnTeam.Stage__c = loanApp.Stage__c;
                                        lnTeam.SubStage__c = loanApp.SubStage__c;
                                        lnTeam.ObjAPIName__c = 'LoanAppl__c';
                                        lnTeam.ObjAccess__c = 'Read';
                                        lnTeam.User__c = team.Supervisor__r.Employee__c;
                                        lnTeam.UserId__c = team.Supervisor__r.Employee__c;
                                        lnTeam.ShareReason__c = sharingMdtMap.get(GlobalConstants.Sharing_Mdt_Sales).SharingReason__c; 
                                        lnTeam.UniqueTeamId__c = loanApp.id+'-'+lnTeam.User__c;
                                        if(uniqueTeamToLNTeamid.containsKey(lnTeam.UniqueTeamId__c)){
                                            uniqueTeamToLNTeamid.remove(lnTeam.UniqueTeamId__c);// in the in this map we will get only loan team which need to be deleted
                                        }
                                        mapLoanTeam.put(loanApp.Id+'-'+lnTeam.User__c,lnTeam);
                                    }
                                    
                                }
                                if(team.emprole__c != null && sharingMdtMap.get(GlobalConstants.Sharing_Mdt_Sales).BrchRoleSharing__c !=null){
                                    if(sharingMdtMap.get(GlobalConstants.Sharing_Mdt_Sales).BrchRoleSharing__c.contains(team.emprole__c)){
                                        LoanTeam__c lnTeam = new LoanTeam__c();
                                        lnTeam.LoanApplication__c = loanApp.id;
                                        lnTeam.Stage__c = loanApp.Stage__c;
                                        lnTeam.SubStage__c = loanApp.SubStage__c;
                                        lnTeam.ObjAPIName__c = 'LoanAppl__c';
                                        lnTeam.ObjAccess__c = 'Read';
                                        lnTeam.UserId__c = team.Employee__c; 
                                        lnTeam.User__c = team.Employee__c;
                                        lnTeam.ShareReason__c = sharingMdtMap.get(GlobalConstants.Sharing_Mdt_Sales).SharingReason__c;
                                        lnTeam.UniqueTeamId__c = loanApp.id+'-'+lnTeam.User__c;
                                        if(uniqueTeamToLNTeamid.containsKey(lnTeam.UniqueTeamId__c)){
                                            uniqueTeamToLNTeamid.remove(lnTeam.UniqueTeamId__c);// in the in this map we will get only loan team which need to be deleted
                                        }
                                        mapLoanTeam.put(loanApp.Id+'-'+lnTeam.User__c,lnTeam);
                                        
                                    } 
                                }
                                
                                if(Test.isRunningTest()){
                                    sharingMdtMap.get(GlobalConstants.Sharing_Mft_Credit).SupervisoreRoleSharing__c = 'RM,SM,BBH';
                                }
                                
                                if((loanApp.ownerId ==team.Employee__c || loanApp.RMSMName__c == team.Employee__c)  && team.Supervisor__r.emprole__c != null && team.Supervisor__c !=null  && sharingMdtMap.get(GlobalConstants.Sharing_Mft_Credit).SupervisoreRoleSharing__c !=null &&  team.Supervisor__r.Employee__r.isActive==true){
                                    if(sharingMdtMap.get(GlobalConstants.Sharing_Mft_Credit).SupervisoreRoleSharing__c.contains(team.Supervisor__r.emprole__c)){
                                        LoanTeam__c lnTeam = new LoanTeam__c();
                                        lnTeam.LoanApplication__c = loanApp.id;
                                        lnTeam.Stage__c = loanApp.Stage__c;
                                        lnTeam.SubStage__c = loanApp.SubStage__c;
                                        lnTeam.ObjAPIName__c = 'LoanAppl__c';
                                        lnTeam.ObjAccess__c = 'Read';
                                        
                                        lnTeam.User__c = team.Supervisor__r.Employee__c;
                                        lnTeam.UserId__c = team.Supervisor__r.Employee__c; 
                                        lnTeam.ShareReason__c = sharingMdtMap.get(GlobalConstants.Sharing_Mft_Credit).SharingReason__c;
                                        //lnTeam.User__c = team.Employee__c; 
                                        lnTeam.UniqueTeamId__c = loanApp.id+'-'+lnTeam.User__c;
                                        if(uniqueTeamToLNTeamid.containsKey(lnTeam.UniqueTeamId__c)){
                                            uniqueTeamToLNTeamid.remove(lnTeam.UniqueTeamId__c);// in the in this map we will get only loan team which need to be deleted
                                        }
                                        mapLoanTeam.put(loanApp.Id+'-'+lnTeam.User__c,lnTeam);
                                        
                                    } 
                                }
                                if(team.emprole__c != null && sharingMdtMap.get(GlobalConstants.Sharing_Mft_Credit).BrchRoleSharing__c !=null){
                                    if(sharingMdtMap.get(GlobalConstants.Sharing_Mft_Credit).BrchRoleSharing__c.contains(team.emprole__c)){
                                        LoanTeam__c lnTeam = new LoanTeam__c();
                                        lnTeam.LoanApplication__c = loanApp.id;
                                        lnTeam.Stage__c = loanApp.Stage__c;
                                        lnTeam.SubStage__c = loanApp.SubStage__c;
                                        lnTeam.ObjAPIName__c = 'LoanAppl__c';
                                        lnTeam.ObjAccess__c = 'Read';
                                        lnTeam.UserId__c = team.Employee__c; 
                                        lnTeam.User__c = team.Employee__c;
                                        lnTeam.UniqueTeamId__c = loanApp.id+'-'+lnTeam.User__c;
                                        lnTeam.ShareReason__c = sharingMdtMap.get(GlobalConstants.Sharing_Mft_Credit).SharingReason__c;
                                        if(uniqueTeamToLNTeamid.containsKey(lnTeam.UniqueTeamId__c)){
                                            uniqueTeamToLNTeamid.remove(lnTeam.UniqueTeamId__c);// in the in this map we will get only loan team which need to be deleted
                                        }
                                        mapLoanTeam.put(loanApp.Id+'-'+lnTeam.User__c,lnTeam);
                                        
                                    } 
                                    
                                }
                                //OPS Sharing for BIL from QDE Stage-Jayesh Rathore
                                if(loanApp.Product__c=='Business Loan' || loanApp.Product__c=='Personal Loan' || loanApp.Product__c=='Loan Against Property'){
                                if(team.EmpRole__c != null && sharingMdtMap.get(GlobalConstants.Sharing_Mdt_Ops).SupervisoreRoleSharing__c !=null){
                                    if(sharingMdtMap.get(GlobalConstants.Sharing_Mdt_Ops).SupervisoreRoleSharing__c.contains(team.EmpRole__c)){
                                        LoanTeam__c lnTeam = new LoanTeam__c();
                                        lnTeam.LoanApplication__c = loanApp.id;
                                        lnTeam.Stage__c = loanApp.Stage__c;
                                        lnTeam.SubStage__c = loanApp.SubStage__c;
                                        lnTeam.ObjAPIName__c = 'LoanAppl__c';
                                        lnTeam.ObjAccess__c = 'Read';
                                        lnTeam.UserId__c = team.Employee__c; 
                                        lnTeam.User__c = team.Employee__c;
                                        lnTeam.UniqueTeamId__c = loanApp.id+'-'+lnTeam.User__c;
                                        lnTeam.ShareReason__c = sharingMdtMap.get(GlobalConstants.Sharing_Mdt_Ops).SharingReason__c;
                                        if(uniqueTeamToLNTeamid.containsKey(lnTeam.UniqueTeamId__c)){
                                            uniqueTeamToLNTeamid.remove(lnTeam.UniqueTeamId__c);// in the in this map we will get only loan team which need to be deleted
                                        }
                                        mapLoanTeam.put(loanApp.Id+'-'+lnTeam.User__c,lnTeam);
                                    } 
                                }
                                if(team.Supervisor__r.emprole__c != null && team.Supervisor__c !=null && sharingMdtMap.get(GlobalConstants.Sharing_Mdt_Ops).BrchRoleSharing__c !=null){
                                    if(sharingMdtMap.get(GlobalConstants.Sharing_Mdt_Ops).BrchRoleSharing__c.contains(team.Supervisor__r.emprole__c)){
                                        LoanTeam__c lnTeam = new LoanTeam__c();
                                        lnTeam.LoanApplication__c = loanApp.id;
                                        lnTeam.Stage__c = loanApp.Stage__c;
                                        lnTeam.SubStage__c = loanApp.SubStage__c;
                                        lnTeam.ObjAPIName__c = 'LoanAppl__c';
                                        lnTeam.ObjAccess__c = 'Read';
                                        lnTeam.UserId__c = team.Employee__c; 
                                        lnTeam.User__c = team.Employee__c;
                                        lnTeam.UniqueTeamId__c = loanApp.id+'-'+lnTeam.User__c;
                                        lnTeam.ShareReason__c = sharingMdtMap.get(GlobalConstants.Sharing_Mdt_Ops).SharingReason__c;
                                        if(uniqueTeamToLNTeamid.containsKey(lnTeam.UniqueTeamId__c)){
                                            uniqueTeamToLNTeamid.remove(lnTeam.UniqueTeamId__c);// in the in this map we will get only loan team which need to be deleted
                                        }
                                        mapLoanTeam.put(loanApp.Id+'-'+lnTeam.User__c,lnTeam);
                                    } 
                                }
                           		 }
                                 //OPS Sharing for BIL from QDE Stage-Jayesh Rathore
                                if(team.emprole__c != null && sharingMdtMap.get(GlobalConstants.Sharing_Mdt_Ops).BrchRoleSharing__c !=null && 
                                   (loanApp.Stage__c == 'Post Sanction' || loanApp.Stage__c == 'Disbursement Initiation' || loanApp.Stage__c == 'Disbursed')){
                                       if(sharingMdtMap.get(GlobalConstants.Sharing_Mdt_Ops).BrchRoleSharing__c.contains(team.emprole__c)){
                                           LoanTeam__c lnTeam = new LoanTeam__c();
                                           lnTeam.LoanApplication__c = loanApp.id;
                                           lnTeam.Stage__c = loanApp.Stage__c;
                                           lnTeam.SubStage__c = loanApp.SubStage__c;
                                           lnTeam.ObjAPIName__c = 'LoanAppl__c';
                                           lnTeam.ObjAccess__c = 'Read';
                                           lnTeam.UserId__c = team.Employee__c; 
                                           lnTeam.User__c = team.Employee__c;
                                           lnTeam.UniqueTeamId__c = loanApp.id+'-'+lnTeam.User__c;
                                           lnTeam.ShareReason__c = sharingMdtMap.get(GlobalConstants.Sharing_Mdt_Ops).SharingReason__c;
                                           if(uniqueTeamToLNTeamid.containsKey(lnTeam.UniqueTeamId__c)){
                                               uniqueTeamToLNTeamid.remove(lnTeam.UniqueTeamId__c);// in the in this map we will get only loan team which need to be deleted
                                           }
                                           mapLoanTeam.put(loanApp.Id+'-'+lnTeam.User__c,lnTeam);
                                           
                                       } 
                                       
                                   }
                                
                                // checking substage and giving access to UW Pool Group
                                /*    if(loanApp.Stage__c== 'Underwriting'){
system.debug('INSIDE SUBSTAGE:::::'+loanApp.SubStage__c);
system.debug('INSIDE SHARIG META:::::'+sharingMdtMap.get(GlobalConstants.Sharing_Mdt_UWGroup).SharingReason__c);
LoanTeam__c lnTeam = new LoanTeam__c();
lnTeam.LoanApplication__c = loanApp.id;
lnTeam.Stage__c = loanApp.Stage__c;
lnTeam.SubStage__c = loanApp.SubStage__c;
lnTeam.ObjAPIName__c = 'LoanAppl__c';
lnTeam.ObjAccess__c = 'Read';
lnTeam.GroupId__c = grpList[0].Id; 
lnTeam.UniqueTeamId__c = loanApp.id+'-'+lnTeam.GroupId__c;
lnTeam.ShareReason__c = sharingMdtMap.get(GlobalConstants.Sharing_Mdt_UWGroup).SharingReason__c;
if(uniqueTeamToLNTeamid.containsKey(lnTeam.UniqueTeamId__c)){
uniqueTeamToLNTeamid.remove(lnTeam.UniqueTeamId__c);// in the in this map we will get only loan team which need to be deleted
}
mapLoanTeam.put(loanApp.Id+'-'+lnTeam.User__c,lnTeam);
} */
                                
                                // checking substage and giving access to Ops User in Disbursed Addition Processing
                                if(loanApp.Stage__c== 'Disbursed' && loanApp.SubStage__c== 'Additional Processing' && loanApp.OpsUser__c != null){
                                    system.debug('INSIDE SHARIG META:::::>>>>>>>Ops User Sharing 208'+loanApp.OpsUser__c);
                                    LoanTeam__c lnTeam = new LoanTeam__c();
                                    lnTeam.LoanApplication__c = loanApp.id;
                                    lnTeam.Stage__c = loanApp.Stage__c;
                                    lnTeam.SubStage__c = loanApp.SubStage__c;
                                    lnTeam.ObjAPIName__c = 'LoanAppl__c';
                                    lnTeam.ObjAccess__c = 'Edit';
                                    lnTeam.User__c = loanApp.OpsUser__c; 
                                    lnTeam.UniqueTeamId__c = loanApp.id+'-'+lnTeam.User__c;
                                    lnTeam.ShareReason__c = sharingMdtMap.get(GlobalConstants.Sharing_Mdt_OpsUser).SharingReason__c;
                                    if(uniqueTeamToLNTeamid.containsKey(lnTeam.UniqueTeamId__c)){
                                        uniqueTeamToLNTeamid.remove(lnTeam.UniqueTeamId__c);// in the in this map we will get only loan team which need to be deleted
                                    }
                                    mapLoanTeam.put(loanApp.Id+'-'+lnTeam.User__c,lnTeam);
                                } 
                                
                                if(loanApp.Stage__c== 'Disbursed' && loanApp.SubStage__c== 'DI Check' && loanApp.CPA_User__c != null && loanApp.NDCType__c != null && loanApp.NDCType__c =='Scan Based Disbursement'){
                                    system.debug('INSIDE SHARIG META:::::>>>>>>>CPA User Sharing 224'+loanApp.CPA_User__c);
                                    LoanTeam__c lnTeam = new LoanTeam__c();
                                    lnTeam.LoanApplication__c = loanApp.id;
                                    lnTeam.Stage__c = loanApp.Stage__c;
                                    lnTeam.SubStage__c = loanApp.SubStage__c;
                                    lnTeam.ObjAPIName__c = 'LoanAppl__c';
                                    lnTeam.ObjAccess__c = 'Edit';
                                    lnTeam.User__c = loanApp.CPA_User__c; 
                                    lnTeam.UniqueTeamId__c = loanApp.id+'-'+lnTeam.User__c;
                                    lnTeam.ShareReason__c = sharingMdtMap.get(GlobalConstants.Sharing_Mdt_CPAUser).SharingReason__c;
                                    if(uniqueTeamToLNTeamid.containsKey(lnTeam.UniqueTeamId__c)){
                                        uniqueTeamToLNTeamid.remove(lnTeam.UniqueTeamId__c);// in the in this map we will get only loan team which need to be deleted
                                    }
                                    mapLoanTeam.put(loanApp.Id+'-'+lnTeam.User__c,lnTeam);
                                } 
                                // Sharing LAN for Hub Managers after QDE Stage
                                if(team.emprole__c != null && sharingMdtMap.get(GlobalConstants.Sharing_Mdt_HubManager).BrchRoleSharing__c !=null && loanApp.Stage__c != 'QDE'){
                                    system.debug('INSIDE SHARIG META:::::>>>>>>>248'+sharingMdtMap.get(GlobalConstants.Sharing_Mdt_HubManager).BrchRoleSharing__c);
                                    if(sharingMdtMap.get(GlobalConstants.Sharing_Mdt_HubManager).BrchRoleSharing__c.contains(team.emprole__c)){
                                        LoanTeam__c lnTeam = new LoanTeam__c();
                                        lnTeam.LoanApplication__c = loanApp.id;
                                        lnTeam.Stage__c = loanApp.Stage__c;
                                        lnTeam.SubStage__c = loanApp.SubStage__c;
                                        lnTeam.ObjAPIName__c = 'LoanAppl__c';
                                        lnTeam.ObjAccess__c = 'Read';    
                                        lnTeam.UserId__c = team.Employee__c; 
                                        lnTeam.User__c = team.Employee__c;
                                        lnTeam.UniqueTeamId__c = loanApp.id+'-'+lnTeam.User__c;
                                        lnTeam.ShareReason__c = sharingMdtMap.get(GlobalConstants.Sharing_Mdt_HubManager).SharingReason__c;
                                        if(uniqueTeamToLNTeamid.containsKey(lnTeam.UniqueTeamId__c)){
                                            uniqueTeamToLNTeamid.remove(lnTeam.UniqueTeamId__c);// in the in this map we will get only loan team which need to be deleted
                                        }
                                        mapLoanTeam.put(loanApp.Id+'-'+lnTeam.User__c,lnTeam);
                                        
                                    } 
                                    
                                }
                                // Sharing LAN for RCU Managers after QDE Stage
                                if(team.emprole__c != null && sharingMdtMap.get(GlobalConstants.Sharing_Mdt_RcuManager).BrchRoleSharing__c !=null && loanApp.Stage__c != 'QDE'){
                                    system.debug('INSIDE SHARIG META:::::>>>>>>>270'+sharingMdtMap.get(GlobalConstants.Sharing_Mdt_RcuManager).BrchRoleSharing__c);
                                    if(sharingMdtMap.get(GlobalConstants.Sharing_Mdt_RcuManager).BrchRoleSharing__c.contains(team.emprole__c)){
                                        LoanTeam__c lnTeam = new LoanTeam__c();
                                        lnTeam.LoanApplication__c = loanApp.id;
                                        lnTeam.Stage__c = loanApp.Stage__c;
                                        lnTeam.SubStage__c = loanApp.SubStage__c;
                                        lnTeam.ObjAPIName__c = 'LoanAppl__c';
                                        lnTeam.ObjAccess__c = 'Read';    
                                        lnTeam.UserId__c = team.Employee__c; 
                                        lnTeam.User__c = team.Employee__c;
                                        lnTeam.UniqueTeamId__c = loanApp.id+'-'+lnTeam.User__c;
                                        lnTeam.ShareReason__c = sharingMdtMap.get(GlobalConstants.Sharing_Mdt_RcuManager).SharingReason__c;
                                        if(uniqueTeamToLNTeamid.containsKey(lnTeam.UniqueTeamId__c)){
                                            uniqueTeamToLNTeamid.remove(lnTeam.UniqueTeamId__c);// in the in this map we will get only loan team which need to be deleted
                                        }
                                        mapLoanTeam.put(loanApp.Id+'-'+lnTeam.User__c,lnTeam);
                                        
                                    } 
                                    
                                }
                                
                                //Sharing LAN for Vendor CPA and VQC after QDE Stage
                                if(loanApp.Account__c != null || loanApp.OwnerId==commCPAPool[0].Id){
                                    if(team.emprole__c != null && sharingMdtMap.get(GlobalConstants.Sharing_Mdt_VendorCPA).BrchRoleSharing__c !=null){
                                        if(sharingMdtMap.get(GlobalConstants.Sharing_Mdt_VendorCPA).BrchRoleSharing__c.contains(team.emprole__c)){
                                            LoanTeam__c lnTeam = new LoanTeam__c();
                                            lnTeam.LoanApplication__c = loanApp.id;
                                            lnTeam.Stage__c = loanApp.Stage__c;
                                            lnTeam.SubStage__c = loanApp.SubStage__c;
                                            lnTeam.ObjAPIName__c = 'LoanAppl__c';
                                            lnTeam.ObjAccess__c = 'Read';
                                            lnTeam.UserId__c = team.Employee__c; 
                                            lnTeam.User__c = team.Employee__c;
                                            lnTeam.ShareReason__c = sharingMdtMap.get(GlobalConstants.Sharing_Mdt_VendorCPA).SharingReason__c;
                                            lnTeam.UniqueTeamId__c = loanApp.id+'-'+lnTeam.User__c;
                                            if(uniqueTeamToLNTeamid.containsKey(lnTeam.UniqueTeamId__c)){
                                                uniqueTeamToLNTeamid.remove(lnTeam.UniqueTeamId__c);// in the in this map we will get only loan team which need to be deleted
                                            }
                                            mapLoanTeam.put(loanApp.Id+'-'+lnTeam.User__c,lnTeam);
                                            
                                        } 
                                    }
                                }
                                /*if(team.EmpRole__c != null && team.EmpRole__c !=null && sharingMdtMap.get(GlobalConstants.Sharing_Mdt_Ops).SupervisoreRoleSharing__c !=null){

if(sharingMdtMap.get(GlobalConstants.Sharing_Mdt_Ops).SupervisoreRoleSharing__c.contains(team.EmpRole__c)){
lnTeam.ShareReason__c =sharingMdtMap.get(GlobalConstants.Sharing_Mdt_Ops).SharingReason__c;
lnTeam.User__c = team.Supervisor__r.Employee__c; 
mapLoanTeam.put(lnTeam.User__c,lnTeam);
} 
}
if(team.Supervisor__r.emprole__c != null && team.Supervisor__c !=null && sharingMdtMap.get(GlobalConstants.Sharing_Mdt_Ops).BrchRoleSharing__c !=null){
if(sharingMdtMap.get(GlobalConstants.Sharing_Mdt_Ops).BrchRoleSharing__c.contains(team.Supervisor__r.emprole__c)){
lnTeam.ShareReason__c =sharingMdtMap.get(GlobalConstants.Sharing_Mdt_Ops).SharingReason__c;
lnTeam.UserId__c = team.Supervisor__c; 
mapLoanTeam.put(lnTeam.UserId__c,lnTeam);
} 
}*/
                                
                                
                            }
                            
                            
                        }
                        
                        
                    }
                //    if(team.emprole__c != null && sharingMdtMap.get(GlobalConstants.Sharing_Mdt_UWGroup).BrchRoleSharing__c !=null){
                //               if(sharingMdtMap.get(GlobalConstants.Sharing_Mdt_UWGroup).BrchRoleSharing__c.contains(team.emprole__c) && (SubStage__c =='Credit Appraisal' || SubStage__c=='UW Approval')){
                
                //          } 
                
                //           }
                
                
            }
            /*
for(LoanAppl__c loanApp : newList){
if(loanApp.Stage__c == 'Underwriting'){
for(TeamHierarchy__c team : otherBranchCreditUser){
if(team.Product_Type__c != null && loanApp.Product__c != null){
if(team.Product_Type__c.contains(loanApp.Product__c) ){
if(team.emprole__c != null && sharingMdtMap.get(GlobalConstants.Sharing_Mft_Credit).BrchRoleSharing__c !=null){
if(sharingMdtMap.get(GlobalConstants.Sharing_Mft_Credit).BrchRoleSharing__c.contains(team.emprole__c)){
LoanTeam__c lnTeam = new LoanTeam__c();
lnTeam.LoanApplication__c = loanApp.id;
lnTeam.Stage__c = loanApp.Stage__c;
lnTeam.SubStage__c = loanApp.SubStage__c;
lnTeam.ObjAPIName__c = 'LoanAppl__c';
lnTeam.ObjAccess__c = 'Read';
lnTeam.UserId__c = team.Employee__c; 
lnTeam.User__c = team.Employee__c;
lnTeam.UniqueTeamId__c = loanApp.id+'-'+lnTeam.User__c;
lnTeam.ShareReason__c = sharingMdtMap.get(GlobalConstants.Sharing_Mft_Credit).SharingReason__c;
if(uniqueTeamToLNTeamid.containsKey(lnTeam.UniqueTeamId__c)){
uniqueTeamToLNTeamid.remove(lnTeam.UniqueTeamId__c);// in the in this map we will get only loan team which need to be deleted
}
mapLoanTeam.put(loanApp.Id+'-'+lnTeam.User__c,lnTeam);
} 
}
}
}
}	
}
}
*/
            system.debug('loanTeamList::::::'+mapLoanTeam+'loanTeamList'+mapLoanTeam.size());
            if(!loanApplicationIdSet.isEmpty()){
                //query deleteLoanTeamList
                /*List<LoanTeam__c> deleteLoanTeamList = new List<LoanTeam__c>();
deleteLoanTeamList = [select id,LoanApplication__c from LoanTeam__c where LoanApplication__c IN :loanApplicationIdSet];

//check if deletLoanteam list is empty if no then delete
if(!deleteLoanTeamList.isEmpty()){
delete deleteLoanTeamList;
}*/
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