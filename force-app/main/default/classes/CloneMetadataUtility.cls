public class CloneMetadataUtility {
    
    public static CloneMtdUtilityWrpr getCloneStatus(String developerName,String cloneReason){
        String cloneRes = '';
        String fields = '';
        String cloneLoanSts = '';
        if (cloneReason != null) {
            if (cloneReason == 'BT + Top Up') {
                cloneRes = 'CloneBTTopUp__c';
            } else if (cloneReason == 'Top up') {
                cloneRes = 'CloneTopup__c';
            } else if (cloneReason == 'Different Property') {
                cloneRes = 'CloneDiffProp__c';
            } else if (cloneReason == 'Other') {
                cloneRes = 'CloneOthr__c';
            }
        }
        List<LoanCloningFieldDetails__mdt> loanCloningMdt = [
            SELECT
            Id,
            DeveloperName,
            Fields__c,
            ProdTyp__c,
            CloneTopup__c,
            CloneOthr__c,
            CloneDiffProp__c,
            CloneBTTopUp__c
            FROM LoanCloningFieldDetails__mdt
            WHERE DeveloperName = : developerName
        ];
        CloneMtdUtilityWrpr returnDtls = new CloneMtdUtilityWrpr();
        if(!loanCloningMdt.isEmpty()){
            returnDtls.cloneStatus = (String) loanCloningMdt[0].get(cloneRes);
            returnDtls.fields = loanCloningMdt[0].Fields__c;
            returnDtls.productType = loanCloningMdt[0].ProdTyp__c;
        }
        if(returnDtls != null){
            return returnDtls;
        }
        return null;
    }
    
    public class CloneMtdUtilityWrpr {
        public String cloneStatus { get; set; }
        public String fields { get; set; }
        public String productType { get; set; }
    }
}