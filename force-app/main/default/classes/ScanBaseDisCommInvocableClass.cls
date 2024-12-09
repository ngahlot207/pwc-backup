public  without sharing class ScanBaseDisCommInvocableClass {
 @InvocableMethod(label=' Scan based Disbursement Communcation Matrix Email' description='Send Email to Employer' category='Email')
    
    Public static void scanCommunicationDisbEmail(List<InputVariables> inputvariable){
        String documentDisPatchId = inputvariable.get(0).targetId;
        String cpaUser = inputvariable.get(0).cpaUser;
        String opsUser = inputvariable.get(0).opsUser;
        string rmSMUser = inputvariable.get(0).rmSMUser;
        String templateId = inputvariable.get(0).emailTeamplateId;
        String branchCodes = inputvariable.get(0).branchcode;    
        String triggerPoint = inputvariable.get(0).triggerPoint;
        list<string> reciepientEmailAddressList = inputvariable.get(0).ToAddress;

        List<String> ccAddressList = new List<String>();
        if(triggerPoint == 'Disbursal files from CPA To Ops'){
            System.debug('Enter');
         List<User> lstOpsEmail = [Select id,Email from User WHERE Id =: opsUser];
          ccAddressList = getCCEmailAddress(new List<String> {cpaUser,opsUser,rmSMUser},branchCodes);
         if(ccAddressList != null && !ccAddressList.isEmpty()){
            for (Integer i = 0; i < ccAddressList.size(); i++) {
                if (ccAddressList[i] == lstOpsEmail[0].Email) {
                    ccAddressList.remove(i);
                    break; 
                }
             }
         }
            system.debug('ccAddressList:'+ccAddressList);
             system.debug('reciepientEmailAddressList:'+reciepientEmailAddressList);
            CommunicationMatrixEmailNotification.sendEmail(templateId,new List<String> {opsUser},reciepientEmailAddressList,ccAddressList,documentDisPatchId,'User');

        }else if(triggerPoint == 'Automated Email Replay To CPA'){
            List<User> lstCPAEmail = [Select id,Email from User WHERE Id =: cpaUser];
            
             ccAddressList = getCCEmailAddress(new List<String> {cpaUser,opsUser,rmSMUser},branchCodes);
         if(ccAddressList != null && !ccAddressList.isEmpty()){
            for (Integer i = 0; i < ccAddressList.size(); i++) {
                if (ccAddressList[i] == lstCPAEmail[0].Email) {
                    ccAddressList.remove(i);
                    break; 
                }
             }
             
         }
            CommunicationMatrixEmailNotification.sendEmail(templateId,new List<String> {cpaUser},reciepientEmailAddressList,ccAddressList,documentDisPatchId,'User');
            
        }
        
    }
    
    Public static List<String> getCCEmailAddress(List<String> UserId, String BranchCode){
        system.debug('Enter this below');
        system.debug('BranchCode:'+BranchCode);
       Set<String> CCAddress = new Set<String>();
        system.debug('UserId:'+UserId);
        For(TeamHierarchy__c teamHirc : [SELECT Id,Employee__c, Supervisor__r.Employee__r.Email,Supervisor__r.Employee__c,Employee__r.Email  FROM TeamHierarchy__c WHERE Employee__c IN :  UserId  AND BranchCode__c =:BranchCode]){
            system.debug('Enter 1');
            if(teamHirc.Employee__c != null){
              CCAddress.add(teamHirc.Employee__r.Email);   
            }
            if(teamHirc.Supervisor__r.Employee__c != null){
              CCAddress.add(teamHirc.Supervisor__r.Employee__r.Email);   
            }

        }
      
        if(CCAddress != null && !CCAddress.isEmpty()){
          List<String> ccAddressList = new List<String>(CCAddress);
            Return ccAddressList;
        }
       Return null;
        
    }
    
     Public class InputVariables{
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
        @InvocableVariable
        Public String triggerPoint;
         
        @InvocableVariable
        Public List<String> ToAddress;
        
    }
}