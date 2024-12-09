public without sharing class IMDController {
    
    @AuraEnabled
    public static List<ApplIMD__c> validateAmount(List<ApplIMD__c> imdRecords ,LoanAppl__c loanAppl){
        Set<Id> loanAppIds = new Set<Id>();
        List<ApplIMD__c> imdRecordsToUpdate = new List<ApplIMD__c>();
        try{
            if(imdRecords != null && imdRecords.size()>0){
                for (ApplIMD__c imdRec : imdRecords) {
                    loanAppIds.add(imdRec.LoanAppln__c);
                }
            LoanAppl__c loanApp = [SELECT Id, IMDAmount__c FROM LoanAppl__c WHERE Id IN :loanAppIds LIMIT 1];

            for (ApplIMD__c imdRec : imdRecords) {
                if(imdRec.IMDAmt__c != loanApp.IMDAmount__c){
                    throw new AuraHandledException('IMD amount does not match with the loan application IMD amount');
                }else if(imdRec.InstrumentAmt__c != loanApp.IMDAmount__c && imdRec.PaymentMode__c == 'Payment Gateway'){
                    throw new AuraHandledException('IMD amount does not match with the loan application IMD amount');
                }else{
                    imdRecordsToUpdate.add(imdRec);
                }  
            }    
            if(imdRecordsToUpdate != null && imdRecordsToUpdate.size()>0){
                if(loanAppl != null){
                    system.debug('LoanAppl__c record --> '+ loanAppl);
                	update loanAppl;
                }
                upsert imdRecordsToUpdate; 
            }
        }
        return imdRecordsToUpdate != null && imdRecordsToUpdate.size()>0 ? imdRecordsToUpdate : imdRecords ;
    }catch(Exception e){
        throw new AuraHandledException(e.getMessage());
    }
}
}