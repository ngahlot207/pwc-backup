public class RecordAccessController {
    @AuraEnabled
    public static WrpSharing getAccess(string recordId){
        WrpSharing wrp = new WrpSharing();
        wrp.isEditAccess = false;
        wrp.isReadAccess = false;       
        Id userId = UserInfo.getUserId();
        if(recordId != null){
            list<UserRecordAccess > userList = [SELECT RecordID,HasReadAccess,HasEditAccess FROM
                                                UserRecordAccess WHERE UserId =:userId AND RecordID=:recordId limit 1];
            if(!userList.isEmpty()){
                
                wrp.isEditAccess = userList[0].HasEditAccess;
                wrp.isReadAccess = userList[0].HasReadAccess;            
            }
        }
        
        
        system.debug('EDIT::::'+wrp.isEditAccess+'READ:::::'+wrp.isReadAccess);
        return wrp;
    }
      @AuraEnabled
    public static WrpSharing getsubStage(string recordId){
        WrpSharing wrp = new WrpSharing();     
        //Id userId = UserInfo.getUserId();
        if(recordId != null){
            list<LoanAppl__C > loanList = [SELECT Id,CloneStatus__c, Name, SubStage__c, Stage__c, FileAcceptance__c,Status__c,OwnerId FROM LoanAppl__c WHERE
                                           Id=:recordId limit 1];
            if(!loanList.isEmpty()){
                
                wrp.stage = loanList[0].stage__c;
                wrp.subStage = loanList[0].subStage__c;
                wrp.fileAccept = loanList[0].FileAcceptance__c;
                wrp.status = loanList[0].Status__c;
                wrp.ownerId = loanList[0].OwnerId;
                wrp.cloneStatus = loanList[0].CloneStatus__c; //LAK-496
            }
        }
        
        
        system.debug('EDIT::::'+wrp.isEditAccess+'READ:::::'+wrp.isReadAccess);
        return wrp;
    }
    
   
    
    
    public class WrpSharing {
        @AuraEnabled
        public boolean isEditAccess { get; set; }
        @AuraEnabled
        public boolean isReadAccess { get; set; }
        @AuraEnabled
        public string stage { get; set; }
        @AuraEnabled
        public string subStage { get; set; } 
        @AuraEnabled
        public boolean fileAccept { get; set; }
        @AuraEnabled
        public string status { get; set; } 
        @AuraEnabled
        public string ownerId { get; set; }
        @AuraEnabled //LAK-496
        public string cloneStatus { get; set; } //LAK-496
    }
}