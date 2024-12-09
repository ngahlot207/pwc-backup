public class CloneLoanAppController {
    @AuraEnabled
    public static CloneLoanDetailsWrpr cloneLoanApp(CloneLoanAppwrpr inputData) {
        try {
            if(inputData.recordId != null && inputData.userId != null && inputData.cloneReason!= null){
                //  System.enqueueJob(new CloneLoanAppJob(inputData));
                CloneLoanDetailsWrpr returnData = CloneLoanAppJob.cloneLoanAppMethod(inputData);
                if(returnData != null){
                    return returnData;
                }
                return null;
                //return 'Loan Cloning Process Started Successfully';
            } else{
                throw new AuraHandledException(
                    'Input Data is Empty' 
                );
            }
        } catch (Exception e) {
            GlobalUtility.logMessage(
                'Error',
                'CloneLoanAppController',
                'Process',
                null,
                null,
                e.getMessage() + ' line ' + e.getLineNumber(),
                null,
                e,
                null
            );
            throw new AuraHandledException(
                'Error during cloning process: ' + e.getMessage()
            );
        }
    }
    
    public class CloneLoanAppwrpr {
        @AuraEnabled
        public String recordId { get; set; }
        @AuraEnabled
        public String userId { get; set; }
        @AuraEnabled
        public String rmSmId { get; set; }
        @AuraEnabled
        public String cloneReason { get; set; }
        @AuraEnabled
        public Boolean financial { get; set; }
        @AuraEnabled
        public Boolean banking { get; set; }
        @AuraEnabled
        public Boolean income { get; set; }
        @AuraEnabled
        public String branch { get; set; }
        @AuraEnabled
        public String product { get; set; } 
    }
    public class CloneLoanDetailsWrpr {
        @AuraEnabled
        public String clonedRecordId { get; set; }
        @AuraEnabled
        public String clonedLoanNumber { get; set; }
    }
}