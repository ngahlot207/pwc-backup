public without sharing class DisbursementCommunication {
    transient public string recordid{get;set;}
    transient public list<Application_Query__c> applicationQueryList{get;set;}
    transient public string loanApplicationId{get;set;}
    transient public list<DocDtl__c> OtcList{get;set;}
    transient public list<DocDtl__c> PddList{get;set;}
    //transient Public List<OpsQueryHandler.OpsQueryWrapper> OpsQueryResults{get;set;}
    
    public DisbursementCommunication() {
        recordId = loanApplicationId;
        /*if (recordId==null) {
            recordId='a08C4000007CR6rIAG';
        }*/if (recordId!=null) {
        	//applicationQueryList = getApplicationQuery(recordId);
        	//getDocDetails(recordId);
        } 
    }
    
     public List<OpsQueryHandler.OpsQueryWrapper> getOpsQueryResults() {
        // Assuming loanApplicationId is set appropriately in your class
        List<OpsQueryHandler.OpsQueryWrapper> opsQueryResults = OpsQueryHandler.getOpsqueryRema(loanApplicationId);
         system.debug('opsQueryResults:'+opsQueryResults);
        return opsQueryResults;
    }
    
    
    public list<Application_Query__c> getApplicationQuery() {
        //System.debug('RecordId: '+recordId);
        return [Select id, remarks__c from Application_Query__c where Responded__c = false AND QryTyp__c = 'NDC Query' AND NDC__r.LoanAppl__c =:loanApplicationId];    
    } 
    
    public list<DocDtl__c> getPDDDocDetails() {
        return [select id, DocCatgry__c, DocTyp__c, DocSubTyp__c, DevLvl__c, DocStatus__c,Rmrk__c from DocDtl__c where DocStatus__c = 'PDD' AND LAN__c =:loanApplicationId];
    }
        
        
    public list<DocDtl__c> getOTCDocDetails() {
        return [select id, DocCatgry__c, DocTyp__c, DocSubTyp__c, DevLvl__c, DocStatus__c,Rmrk__c from DocDtl__c where DocStatus__c ='OTC' AND LAN__c =:loanApplicationId];
    }

}