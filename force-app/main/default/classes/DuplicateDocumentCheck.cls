public class DuplicateDocumentCheck {
    public static String findDuplicateDocsForAppAndCoApp(string loanId) {
        
        list<ApplKyc__c> appKycList=new list<ApplKyc__c>([select id, AadharNo__c,Applicant__r.FullName__c, Pan__c,Applicant__r.ApplType__c,VotIdEpicNo__c, DLNo__c, PassNo__c,AadharEncripted__c,KycDocNo__c,kycDoc__c,Applicant__r.LoanAppln__c
                                                          from ApplKyc__c  where Applicant__r.LoanAppln__c =:loanId]);
        system.debug('appKycList --->'+appKycList);
        system.debug('appKycList size--->'+appKycList.size());
        
       //String panNumber;
      String docNumber; 
      Set<String> setOfPanNumber = New Set<String>();
      String error;
        
        for (ApplKyc__c a : appKycList) {
            String doctype = a.kycDoc__c;
            system.debug('a.kycDoc__c -->'+a.kycDoc__c);
            if(a.Applicant__r.ApplType__c == 'P'){
                if(doctype == 'Aadhaar'){
                docNumber = a.AadharEncripted__c;
                system.debug('docNumber Adhaar for Applicant--> '+docNumber);
                }
                else if(doctype == 'Pan' || doctype == 'Driving License' || doctype == 'Passport' || doctype == 'Voter Id'){
                system.debug('Applicant__r.FullName__c'+a.Applicant__r.FullName__c);
                system.debug('Applicant__r.FullName__c Id'+a.Applicant__r.Id);
                docNumber = a.KycDocNo__c;
                system.debug('docNumber Other than Adhaar for Applicant--> '+docNumber);
            }
        }
            else if(a.Applicant__r.ApplType__c != 'P'){
                if(doctype == 'Aadhaar'){
                docNumber = a.AadharEncripted__c;
                system.debug('docNumber Adhaar for Coapplicant--> '+docNumber);
                }    
                else if(doctype == 'Pan' || doctype == 'Driving License' || doctype == 'Passport' || doctype == 'Voter Id'){
                system.debug('Applicant__r.FullName__c CoApp'+a.Applicant__r.FullName__c);
                system.debug('Applicant__r.FullName__c CoApp Id'+a.Applicant__r.Id);
                //setOfPanNumber.add(a.Pan__c);
                docNumber = a.KycDocNo__c;
                setOfPanNumber.add(docNumber);
                system.debug('docNumber Adhaar for other than Coapplicant--> '+docNumber);
            }
         }
        
            
     }

       /* if(!String.isBlank(panNumber)){
            system.debug('panNumber -->'+panNumber.length());
        }
        if((setOfPanNumber.size()>0) && (!String.isBlank(panNumber))){
            system.debug('setOfPanNumber -->'+setOfPanNumber.size());
            if(setOfPanNumber.contains(panNumber)){
                system.debug('Duplicate KYC Found');
                error = 'Duplicate KYC Found';
            }
        }*/

        if((setOfPanNumber.size()>0) && (!String.isBlank(docNumber))){
            system.debug('setOfPanNumber -->'+setOfPanNumber.size());
            if(setOfPanNumber.contains(docNumber)){
                system.debug('Duplicate KYC Found');
                error = 'Duplicate KYC Found';
            }
        }

        return error;
}
}