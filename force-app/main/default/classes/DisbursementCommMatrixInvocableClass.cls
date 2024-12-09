public without sharing class DisbursementCommMatrixInvocableClass {
    
    @InvocableMethod(label='Disbursement Communcation Matrix Email' description='Send Email to Employer' category='Email')
    public static void communicationDisbEmail(List<InputVariables> inputvariable) {
        system.debug('inputvariable:'+inputvariable);
        String loanApplicationId = inputvariable.get(0).targetId;
        String Stage = inputvariable.get(0).Stage;
        String subStage = inputvariable.get(0).Substage;
        String cpaUser = inputvariable.get(0).cpaUser;
        String opsUser = inputvariable.get(0).opsUser;
        String UwUser = inputvariable.get(0).UwUser;
        string rmSMUser = inputvariable.get(0).rmSMUser;
        String templateId = inputvariable.get(0).emailTeamplateId;
        String branchCodes = inputvariable.get(0).branchcode;
        
        List<String> setUserId = new List<String>();
        List<String> setOfCPAEmailAndL1L2 = new List<String>();
        List<String> setOpsUserId = new  List<String>();
        List<String> setOpsUserEmail  = new List<String>();
        
        List<TeamHierarchy__c> listCPAUser = new List<TeamHierarchy__c>();
        //FOR CPA user L1 and L2
        for(TeamHierarchy__c cpa: [SELECT Id,Employee__c,Employee__r.email, Supervisor__r.Employee__r.Email,Supervisor__r.Employee__c, Supervisor__r.Supervisor__r.Employee__r.Email,Supervisor__r.Supervisor__r.Employee__c  FROM TeamHierarchy__c WHERE Employee__c =: cpaUser  AND BranchCode__c =:branchCodes  LIMIT 1]){
            if(cpa.Employee__c != null){
                setUserId.add(cpa.Employee__c);
            }
            if(cpa.Supervisor__r.Employee__c != null){
                setUserId.add(cpa.Employee__c);   
            }
            if(cpa.Supervisor__r.Supervisor__r.Employee__c != null ){
                setUserId.add(cpa.Employee__c);   
            }
            if(String.isNotBlank(cpa.Employee__r.email)){
                setOfCPAEmailAndL1L2.add(cpa.Employee__r.email);
            }
            if(String.isNotBlank(cpa.Supervisor__r.Employee__r.Email)){
                setOfCPAEmailAndL1L2.add(cpa.Supervisor__r.Employee__r.Email);  
            }
            if(String.isNotBlank(cpa.Supervisor__r.Supervisor__r.Employee__r.Email )){
                setOfCPAEmailAndL1L2.add(cpa.Supervisor__r.Supervisor__r.Employee__r.Email);     
            }
        }
        
        //LAK-6110 Commented Code
        //FOR UW User and L1
        /*for(TeamHierarchy__c UW: [SELECT Id,Employee__c,Employee__r.email, Supervisor__r.Employee__r.Email,Supervisor__r.Employee__c, Supervisor__r.Supervisor__r.Employee__r.Email,Supervisor__r.Supervisor__r.Employee__c  FROM TeamHierarchy__c WHERE Employee__c =: UwUser  AND BranchCode__c =:branchCodes Limit 1]){
            if(UW.Employee__c != null){
                setUserId.add(UW.Employee__c);
            }
            if(UW.Supervisor__r.Employee__c != null){
                setUserId.add(UW.Employee__c);   
            }
            
            if(String.isNotBlank(UW.Employee__r.email)){
                setOfCPAEmailAndL1L2.add(UW.Employee__r.email);
            }
            if(String.isNotBlank(UW.Supervisor__r.Employee__r.Email)){
                setOfCPAEmailAndL1L2.add(UW.Supervisor__r.Employee__r.Email);  
            }
        }*/
        
        //RM SM and L1 and L2
        
        for(TeamHierarchy__c rmSm: [SELECT Id,Employee__c,Employee__r.email, Supervisor__r.Employee__r.Email,Supervisor__r.Employee__c, Supervisor__r.Supervisor__r.Employee__r.Email,Supervisor__r.Supervisor__r.Employee__c  FROM TeamHierarchy__c WHERE Employee__c =: rmSMUser  AND BranchCode__c =:branchCodes LIMIT 1]){
            if(rmSm.Employee__c != null){
                setUserId.add(rmSm.Employee__c);
            }
            if(rmSm.Supervisor__r.Employee__c != null){
                setUserId.add(rmSm.Employee__c);   
            }
            if(rmSm.Supervisor__r.Supervisor__r.Employee__c != null ){
                setUserId.add(rmSm.Employee__c);   
            }
            if(String.isNotBlank(rmSm.Employee__r.email)){
                setOfCPAEmailAndL1L2.add(rmSm.Employee__r.email);
            }
            if(String.isNotBlank(rmSm.Supervisor__r.Employee__r.Email)){
                setOfCPAEmailAndL1L2.add(rmSm.Supervisor__r.Employee__r.Email);  
            }
            if(String.isNotBlank(rmSm.Supervisor__r.Supervisor__r.Employee__r.Email )){
                setOfCPAEmailAndL1L2.add(rmSm.Supervisor__r.Supervisor__r.Employee__r.Email);     
            }
        }
        
        //OPS and L1 and L2
        
        for(TeamHierarchy__c ops: [SELECT Id,Employee__c,Employee__r.email, Supervisor__r.Employee__r.Email,Supervisor__r.Employee__c, Supervisor__r.Supervisor__r.Employee__r.Email,Supervisor__r.Supervisor__r.Employee__c  FROM TeamHierarchy__c WHERE Employee__c =: opsUser  AND BranchCode__c =:branchCodes Limit 1]){
            if(ops.Employee__c != null){
               setOpsUserId.add(ops.Employee__c);
            }
            if(ops.Supervisor__r.Employee__c != null){
               setOpsUserId.add(ops.Employee__c);   
            }
            if(ops.Supervisor__r.Supervisor__r.Employee__c != null ){
               setOpsUserId.add(ops.Employee__c);   
            }
            if(String.isNotBlank(ops.Employee__r.email)){
                setOpsUserEmail.add(ops.Employee__r.email);
            }
            if(String.isNotBlank(ops.Supervisor__r.Employee__r.Email)){
                setOpsUserEmail.add(ops.Supervisor__r.Employee__r.Email);  
            }
            if(String.isNotBlank(ops.Supervisor__r.Supervisor__r.Employee__r.Email )){
                setOpsUserEmail.add(ops.Supervisor__r.Supervisor__r.Employee__r.Email);     
            }
        }
          
        
       
        system.debug('setOpsUserId:' +setOpsUserId);
        system.debug('setOpsUserEmail:' +setOpsUserEmail);
        system.debug('setUserId:' +setUserId);
        system.debug('setOpsUserEmail:' +setOpsUserEmail);
        system.debug('setOfCPAEmailAndL1L2:' +setOfCPAEmailAndL1L2);
        
        
        if(Stage == 'Post Sanction' && subStage == 'Ops Query Pool' && !setUserId.isEmpty() && !setOfCPAEmailAndL1L2.isEmpty()){
            CommunicationMatrixEmailNotification.sendEmail(templateId,setUserId,setOfCPAEmailAndL1L2,setOpsUserEmail,loanApplicationId,'User');
        }
        
        if(subStage == 'DI Pool' && !setOpsUserEmail.isEmpty() && !setOpsUserId.isEmpty()){
           CommunicationMatrixEmailNotification.sendEmail(templateId,setOpsUserId,setOpsUserEmail,setOfCPAEmailAndL1L2,loanApplicationId,'User');

        }
        
    }
    
    
    
    Public class InputVariables{
        @InvocableVariable
        public String Stage;
        @InvocableVariable
        public String Substage;
        @InvocableVariable
        public String targetId;
        @InvocableVariable
        public String cpaUser; 
        @InvocableVariable
        public String opsUser; 
        @InvocableVariable
        public String UwUser;
        @InvocableVariable
        public String rmSMUser;
        @InvocableVariable
        public String emailTeamplateId;
        
        @InvocableVariable
        Public String branchcode;
        
    }
    
}