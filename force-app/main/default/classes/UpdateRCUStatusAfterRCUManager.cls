public without sharing class UpdateRCUStatusAfterRCUManager {
    @AuraEnabled
    public static void updateStatus(Id loanId){
        map<Id, CaseDoc__c> mapDocDtlCase = new map<Id, CaseDoc__c>();
        map<Id, CaseDoc__c> mapApplAddCase = new map<Id, CaseDoc__c>();
        
        map <Id, DocDtl__c> mapDocs = new map<Id,DocDtl__c>([Select Id, RCUInitiated__c, AgencyAssigned__c,LAN__c,AgencyDocStatus__c from DocDtl__c where
                                                             LAN__c =: loanId AND RCUInitiated__c =true AND AgencyAssigned__c =true]);
        system.debug('mapDocs::::::'+mapDocs.size());
        map <Id,ApplAddr__c> mapAppAdd = new map<Id,ApplAddr__c>([Select Id, RCUInitiated__c, AgencyAssigned__c,AgencyDocStatus__c from ApplAddr__c  where
                                                                  LoanAppl__c  =: loanId AND RCUInitiated__c =true AND AgencyAssigned__c =true]);
        system.debug('mapAppAdd:::::'+mapAppAdd.size());
        list<CaseDoc__c> caseDocUpdateList= new list<CaseDoc__c>();
        
        list <CaseDoc__c> lstCaseDoc = [SELECT Id,Case__c,DocDetail__c, Case__r.Loan_Application__c, Case__r.Account.Name, Case__r.Contact.Name,AgencyDocStatus__c,
                                        DocDetail__r.AgencyDocStatus__c, ApplAddr__r.AgencyDocStatus__c from CaseDoc__c
                                        WHERE Case__r.Loan_Application__c =: loanId AND Case__r.AccountId != null AND Case__r.CaseType__c ='RCU'];
        
        system.debug('lstCaseDoc::::::19:::::'+lstCaseDoc.size());
        if(!lstCaseDoc.isEmpty()){
            for(CaseDoc__c cs :lstCaseDoc){
                if(cs.DocDetail__c != null){
                    mapDocDtlCase.put(cs.DocDetail__c,cs); 
                }
                if(cs.ApplAddr__c != null){
                    mapApplAddCase.put(cs.ApplAddr__c,cs); 
                }
                
            }
        }
        system.debug('mapDocDtlCase::::::31::::'+mapDocDtlCase.size());
        if(!mapDocDtlCase.isEmpty()){
            for(CaseDoc__c cd : mapDocDtlCase.values()){
                if(cd.DocDetail__c != null){
                    DocDtl__c dt = mapDocs.get(cd.DocDetail__c);
                    CaseDoc__c c = new CaseDoc__c();
                    c.Id = cd.Id;
                    c.AgencyDocStatus__c = dt.AgencyDocStatus__c;
                    caseDocUpdateList.add(c);
                }                
            }
            
        }
        if(!mapApplAddCase.isEmpty()){
            for(CaseDoc__c cd : mapApplAddCase.values()){
                if(cd.ApplAddr__c != null){
                    ApplAddr__c appAdd = mapAppAdd.get(cd.ApplAddr__c);
                    CaseDoc__c c = new CaseDoc__c();
                    c.Id = cd.Id;
                    c.AgencyDocStatus__c = appAdd.AgencyDocStatus__c;
                    caseDocUpdateList.add(c);
                }  
            }
            
        }
        
        system.debug('caseDocUpdateList::::::50'+caseDocUpdateList);
        system.debug('caseDocUpdateList::SIZE::::51'+caseDocUpdateList.size());
        if(!caseDocUpdateList.isEmpty()){
            update caseDocUpdateList;
            updateChildCases(loanId);
        }
    }
    public static void updateChildCases(Id loanId){
        map<Id, list<CaseDoc__c>> mapChildCasDocs= new map<Id, list<CaseDoc__c>>();
        list <Case> lstChildCases = [SELECT Id,Loan_Application__c, RecordType.Name,AgcRCUReportStatus__c From Case
                                     WHERE Loan_Application__c =: loanId AND Accountid != null AND ContactId != null AND CaseType__c='RCU'];
        map<Id, Case> mapChildCases = new map<Id, Case>(lstChildCases);
        system.debug('mapChildCases SIZE 68:::::'+ mapChildCases.size());
        if(!mapChildCases.isEmpty()){
            for(CaseDoc__c cd:[SELECT Id,Case__c,DocDetail__c, Case__r.Loan_Application__c, Case__r.Account.Name, 
                               Case__r.Contact.Name,AgencyDocStatus__c from CaseDoc__c
                               WHERE Case__c IN: mapChildCases.keySet() AND Case__r.AccountId != null AND Case__r.CaseType__c ='RCU']){
                                   system.debug('cd:::::'+ cd);
                                   if(mapChildCasDocs.containsKey(cd.Case__c)){
                                       mapChildCasDocs.get(cd.Case__c).add(cd);
                                   }else{
                                       mapChildCasDocs.put(cd.Case__c,new list<CaseDoc__c>{cd});   
                                   }
                               }
            system.debug('mapChildCasDocs:::::'+ mapChildCasDocs);
        }
        // Updating Cases based on child Case Document statuses
        if(!mapChildCasDocs.isEmpty()){
            for (Id parentId : mapChildCasDocs.keySet()) {
                List<CaseDoc__c> lstCaseDocs = mapChildCasDocs.get(parentId);
                Boolean hasFraud = false;
                Boolean hasNegative = false;
                Boolean hasRefer = false;
                Boolean hasPending = false;
                Boolean allPositive = true;
                
                for (CaseDoc__c child : lstCaseDocs) {
                    String status = child.AgencyDocStatus__c;
                    if (status == 'Fraud') {
                        hasFraud = true;
                        break; // No need to check further if 'Fraud' is found
                    } else if (status == 'Negative') {
                        hasNegative = true;
                        allPositive = false;
                    } else if (status == 'Refer') {
                        hasRefer = true;
                        allPositive = false;
                    } else if (status == 'Pending') {
                        hasPending = true;
                        allPositive = false;
                    } else if (status != 'Positive') {
                        allPositive = false;
                    }
                }
                
                Case parentCase = mapChildCases.get(parentId);
                if (hasFraud) {
                    parentCase.AgcRCUReportStatus__c = 'FRAUD';
                } else if (hasNegative) {
                    parentCase.AgcRCUReportStatus__c = 'NEGATIVE';
                } else if (hasRefer) {
                    parentCase.AgcRCUReportStatus__c = 'REFER';
                } else if (hasPending) {
                    parentCase.AgcRCUReportStatus__c = 'PENDING';
                } else if (allPositive) {
                    parentCase.AgcRCUReportStatus__c = 'POSITIVE';
                }
            }  
        }
        if(!mapChildCases.isEmpty()){
            update mapChildCases.values();
            updateParentCase(loanId);
        }
    }
    public static void updateParentCase(Id loanId){
        map<Id, list<Case>> mapParentChildCases= new map<Id, list<Case>>();
        
        list <Case> lstParentCase = [SELECT Id,Loan_Application__c, RecordType.Name,AgcRCUReportStatus__c From Case
                                     WHERE Loan_Application__c =: loanId AND Accountid = null AND ContactId = null AND RecordType.Name='RCU'];
        map<Id, Case> mapParentCase = new map<Id, Case>(lstParentCase);
        system.debug('mapParentCase SIZE 137:::::'+ mapParentCase.size());
        if(!mapParentCase.isEmpty()){
            for(Case cs:[SELECT Id,Case__c, RecordType.Name,AgcRCUReportStatus__c From Case
                         WHERE Case__c IN : mapParentCase.keySet() AND Accountid != null AND ContactId != null AND CaseType__c='RCU']){
                             system.debug('cs:::::'+ cs);
                             if(mapParentChildCases.containsKey(cs.Case__c)){
                                 mapParentChildCases.get(cs.Case__c).add(cs);
                             }else{
                                 mapParentChildCases.put(cs.Case__c,new list<Case>{cs});   
                             }
                         }
            system.debug('mapParentChildCases:::::'+ mapParentChildCases);
        }
        // Updating parent cases based on child case statuses
        if(!mapParentChildCases.isEmpty()){
            for (Id parentId : mapParentChildCases.keySet()) {
                List<Case> childCases = mapParentChildCases.get(parentId);
                Boolean hasFraud = false;
                Boolean hasNegative = false;
                Boolean hasRefer = false;
                Boolean hasPending = false;
                Boolean allPositive = true;
                
                for (Case child : childCases) {
                    String status = child.AgcRCUReportStatus__c;
                    if (status == 'FRAUD') {
                        hasFraud = true;
                        break; // No need to check further if 'Fraud' is found
                    } else if (status == 'NEGATIVE') {
                        hasNegative = true;
                        allPositive = false;
                    } else if (status == 'REFER') {
                        hasRefer = true;
                        allPositive = false;
                    } else if (status == 'PENDING') {
                        hasPending = true;
                        allPositive = false;
                    } else if (status != 'POSITIVE') {
                        allPositive = false;
                    }
                }
                
                Case parentCase = mapParentCase.get(parentId);
                if (hasFraud) {
                    parentCase.AgcRCUReportStatus__c = 'FRAUD';
                } else if (hasNegative) {
                    parentCase.AgcRCUReportStatus__c = 'NEGATIVE';
                } else if (hasRefer) {
                    parentCase.AgcRCUReportStatus__c = 'REFER';
                } else if (hasPending) {
                    parentCase.AgcRCUReportStatus__c = 'PENDING';
                } else if (allPositive) {
                    parentCase.AgcRCUReportStatus__c = 'POSITIVE';
                }
            }  
        }
        if(!mapParentCase.isEmpty()){
            update mapParentCase.values();
        }
        
        
    }
    
}