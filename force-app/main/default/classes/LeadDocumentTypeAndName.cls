public without sharing class LeadDocumentTypeAndName {
    @AuraEnabled(cacheable=true)
	public static Map<String, List<String>> fetchAllDocs(String constitution,String CustProfile) {
        
        Map<String, List<String>> documentTypesAndNames = new Map<String, List<String>>();
        if(constitution == 'Individual'  && (CustProfile!='SELF EMPLOYED NON PROFESSIONAL' && CustProfile!='SELF EMPLOYED PROFESSIONAL') ){
            documentTypesAndNames.put('Sign Proof', new List<String>{'Passport', 'PAN', 'Driving License'});
            documentTypesAndNames.put('PAN', new List<String>{ 'PAN'});
            documentTypesAndNames.put('Residence Address proof - OVD', new List<String>{'Passport', 'Voter ID', 'Driving License'});
            documentTypesAndNames.put('DOB Proof', new List<String>{'Passport', 'PAN', 'Voter ID', 'Driving License'});
            documentTypesAndNames.put('Identity Proof', new List<String>{'Passport', 'Voter ID', 'Driving License'});
            documentTypesAndNames.put('Residence Address proof - Deemed OVD', new List<String>{'Electricity Bill','Aadhaar Acknowledgment for address change','Leave and licence agreements with employers allotting official accommodation','Letter of allotment of accommodation from employer','Piped gas bill','Post-paid mobile phone bill','Property or Municipal tax receipt','Telephone Bill','Water bill'});
			 return documentTypesAndNames;
        }
        
        else if(constitution == 'Individual'  && (CustProfile=='SELF EMPLOYED NON PROFESSIONAL' || CustProfile=='SELF EMPLOYED PROFESSIONAL') ){
             documentTypesAndNames.put('PAN', new List<String>{ 'PAN'});
            documentTypesAndNames.put('Principal Place of Business - Address Proof', new List<String>{'Electricity Bill', 'Utility Bill','Shop & Establishment'});
           return documentTypesAndNames;
        }
        
       else if(constitution == 'PROPERITORSHIP' ){
             documentTypesAndNames.put('PAN', new List<String>{ 'PAN'});
            documentTypesAndNames.put('Principal Place of Business - Address Proof', new List<String>{'Electricity Bill', 'Utility Bill','Shop & Establishment'});
            return documentTypesAndNames;
        }
        
        else if(constitution != 'Individual' && constitution != 'PARTNERSHIP' && constitution != 'PROPERITORSHIP' ){
             documentTypesAndNames.put('PAN', new List<String>{ 'PAN'});
            documentTypesAndNames.put('Registered office - Address Proof', new List<String>{'Electricity Bill', 'Utility Bill','Shop & Establishment'});
           return documentTypesAndNames;
        }
        
        //if(constitution != 'Individual' )
        else
             documentTypesAndNames.put('PAN', new List<String>{'PAN'});
            documentTypesAndNames.put('Principal Place of Business - Address Proof', new List<String>{'Electricity Bill', 'Utility Bill','Shop & Establishment'});
           documentTypesAndNames.put('Registered office - Address Proof', new List<String>{'Electricity Bill', 'Utility Bill','Shop & Establishment'});
           
        
        return documentTypesAndNames;
    }
    }