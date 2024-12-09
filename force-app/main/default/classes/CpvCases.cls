public class CpvCases {
    //UWApprovalValidation
    public static List<String> validateCpv(string loanId){
        List<String> errors = new List<String>();
        Map<string,List<string>> metadataMap = new Map<string,List<string>>();
         Map<string,List<string>> caseMap = new Map<string,List<string>>();
        for(MandatoryAddrList__mdt meta : [SELECT Constitution__c,CustProf__c,TypeOfAppl__c,AddrType__c FROM MandatoryAddrList__mdt ]){
            String key = meta.Constitution__c + '-' + meta.CustProf__c + '-' +meta.TypeOfAppl__c ;
            if(metadataMap.containsKey(key)){
                metadataMap.get(key).add(meta.AddrType__c);
            } else {
                metadataMap.put(key, new List<string>{meta.AddrType__c});
            }
        }
        
        Map<Id, Applicant__c> appMap = new Map<Id, Applicant__c>([SELECT Id,CustProfile__c,Constitution__c,Type_of_Borrower__c,TabName__c FROM Applicant__c WHERE LoanAppln__c =:loanId]);
        for(Case c : [SELECT Id,WaiveCPV__c,Status,Address_Type__c,Applicant__c FROM Case WHERE Loan_Application__c =:loanId AND RecordType.Name ='CPVFI']){
            if (c.Status == 'Closed' || c.WaiveCPV__c == 'Yes') {
            if(caseMap.containsKey(c.Applicant__c)){
                caseMap.get(c.Applicant__c).add(c.Address_Type__c);
            } else {
                caseMap.put(c.Applicant__c, new List<string>{c.Address_Type__c});
            }       
            }
    	}
        for(string appId :appMap.keyset()){
            string uniKey ;
           Applicant__c appl = appMap != null && appMap.size()>0 ? appMap.get(appId):null;
           uniKey = appl.Constitution__c + '-' + appl.CustProfile__c + '-' +appl.Type_of_Borrower__c ;
           List<String> requiredCPVs = metadataMap.get(uniKey);
           List<String> appCPVs = caseMap.get(appId);
           for(String cpv : requiredCPVs) {
                if(appCPVs == null || appCPVs.contains(cpv)) {
                    errors.add(cpv + ' CPV is required for ' + appl.TabName__c);
                }
           }
        }
        return errors;
}
}