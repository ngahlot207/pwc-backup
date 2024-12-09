public with sharing class verificationWrapper {
    @AuraEnabled
    public string recordTypeName;
    @AuraEnabled
    public Boolean showProfQuaCheck;
    @AuraEnabled
    public Boolean showVerStatus;
    @AuraEnabled
    public List<verificationRecord> verificationList;
    
    public class verificationRecord{
        @AuraEnabled
        public string applicantName;
        @AuraEnabled
        public string applicantId;
        @AuraEnabled
        public string verificationStatus;
        @AuraEnabled
        public string verificationId;
        @AuraEnabled
        public string cdlId;
        @AuraEnabled
        public string docDetailId;
        @AuraEnabled
        public string ProfQuaStatus;
    }
    public static verificationWrapper parse(String json) {
        return (verificationWrapper) System.JSON.deserialize(json, verificationWrapper.class );
    }
}