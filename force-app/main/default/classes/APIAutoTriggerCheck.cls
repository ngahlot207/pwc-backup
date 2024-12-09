public class APIAutoTriggerCheck {
	
    @auraEnabled
    public static List<APIToRunWrapper> checkAPIToRun(List<String> applicantId){
        List<String> apiToRun = new List<String>{'Consumer ACK Request','Dedupe'};
        List<String> stageNames = new List<String>{'QDE','DDE'};
        List<String> applTypes = new List<String>{'G','C','P'};
        list<Applicant__c> applicantrecList = new List<Applicant__c>();
        List<APIToRunWrapper> wrapList = new List<APIToRunWrapper>();
        APIToRunWrapper wrap = new APIToRunWrapper();

        Set<String> homeLoanProducts = new Set<String>{'Home Loan', 'Small Ticket LAP', 'Loan Against Property'};
        Set<String> businessLoanProducts = new Set<String>{'Business Loan', 'Personal Loan'};

        applicantrecList = [SELECT Id,ApplType__c,Constitution__c,FName__c,Gender__c,MobNumber__c,DOB__c,CompanyName__c,LoanAppln__r.Stage__c ,LoanAppln__c,
                                        PAN__c,FullName__c,LoanAppln__r.Product__c, LoanAppln__r.ReqLoanAmt__c,LoanAppln__r.LMSUpdTrig__c,
                                        (Select id,AddrTyp__c from Applicant_Addresses__r WHERE (AddrTyp__c = 'Residence Address' OR AddrTyp__c = 'Residence Cum Office') 
                                        AND AddrLine1__c != null AND AddrLine2__c != null AND City__c != null AND Pincode__c != NULL 
                                        AND State__c != null Limit 1)
                                        FROM Applicant__c 
                                        WHERE ID IN:applicantId and LoanAppln__r.Stage__c IN:stageNames];
        system.debug('applicantrecList'+applicantrecList);
        List<APICoutTrckr__c> trackList = new List<APICoutTrckr__c>();
        trackList = [SELECT Appl__c,APIName__c 
                    FROM APICoutTrckr__c
                    WHERE Appl__c IN:applicantId 
                    and APIName__c IN: apiToRun AND LstSucesDtTime__c != NULL ];
        Map<String,APICoutTrckr__c> applToTracker = new Map<String,APICoutTrckr__c>();
        Map<String,Map<String,String>> applKycMap = new Map<String,Map<String,String>>();
        for(ApplKyc__c applkyc:[select id,Applicant__c,kycDoc__c,Pan__c,Name__c,VotIdEpicNo__c,PassNo__c,DLNo__c,AadharNo__c,Applicant__r.LoanAppln__r.Product__c,Applicant__r.ApplType__c from ApplKyc__c where Applicant__c IN:applicantId AND kycDoc__c !=null]){
            //appKycMap.put(appkyclist.Applicant__c,appkyclist);

            Boolean isApplicantInMap = applKycMap.containsKey(applkyc.Applicant__c);

            if(!isApplicantInMap){
            if (!isApplicantInMap && (
                ((applkyc.Applicant__r.ApplType__c == 'G' || applkyc.Applicant__r.ApplType__c == 'C') && homeLoanProducts.contains(applkyc.Applicant__r.LoanAppln__r.Product__c)) ||
                ((applkyc.Applicant__r.ApplType__c == 'G' || applkyc.Applicant__r.ApplType__c == 'C' || applkyc.Applicant__r.ApplType__c == 'P') && businessLoanProducts.contains(applkyc.Applicant__r.LoanAppln__r.Product__c))
            )) {
               
                System.debug('applKycMap debug'+applKycMap);
                if (applkyc.kycDoc__c == 'Pan' && String.isNOTBlank(applkyc.Pan__c)) {
                    system.debug('applKyc pan debug'+applkyc.Applicant__c + ' ' + applkyc.Pan__c);
                    applKycMap.put(applkyc.Applicant__c,new Map<String,String>{'01'=>applkyc.Pan__c});
                }
                else if (applkyc.kycDoc__c == 'Passport' && String.isNOTBlank(applkyc.PassNo__c)) {
                    system.debug('applKyc passport debug'+applkyc.Applicant__c + ' ' + applkyc.Pan__c);
                    applKycMap.put(applkyc.Applicant__c,new Map<String,String>{'04'=>applkyc.PassNo__c});
                }
                else if (applkyc.kycDoc__c == 'Voter Id' && String.isNOTBlank(applkyc.VotIdEpicNo__c)) {
                    system.debug('applKyc voter debug'+applkyc.Applicant__c + ' ' + applkyc.Pan__c);
                    applKycMap.put(applkyc.Applicant__c,new Map<String,String>{'07'=>applkyc.VotIdEpicNo__c});
                }
                else if (applkyc.kycDoc__c == 'Driving License' && String.isNOTBlank(applkyc.DLNo__c)) {
                    system.debug('applKyc dl debug'+applkyc.Applicant__c + ' ' + applkyc.Pan__c);
                    applKycMap.put(applkyc.Applicant__c,new Map<String,String>{'10'=>applkyc.DLNo__c});
                }
                else if (applkyc.kycDoc__c == 'Aadhaar' && String.isNOTBlank(applkyc.AadharNo__c)) {
                    system.debug('applKyc Aadhaar debug'+applkyc.Applicant__c + ' ' + applkyc.AadharNo__c);
                    applKycMap.put(applkyc.Applicant__c,new Map<String,String>{'13'=>applkyc.AadharNo__c});
                }
            }
        }
        }

        for(APICoutTrckr__c calloutTracker: trackList){
            applToTracker.put(calloutTracker.Appl__c+'-'+calloutTracker.APIName__c,calloutTracker);
        }
        for(Applicant__c applicantrec : applicantrecList){
            if (((applicantrec.ApplType__c == 'G' || applicantrec.ApplType__c == 'C') && homeLoanProducts.contains(applicantrec.LoanAppln__r.Product__c)) ||
                ((applicantrec.ApplType__c == 'G' || applicantrec.ApplType__c == 'C' || applicantrec.ApplType__c == 'P') && businessLoanProducts.contains(applicantrec.LoanAppln__r.Product__c))
            ){
            for(String apiName: apiToRun){
                wrap = new APIToRunWrapper();
                if(apiName == 'Dedupe'){
                   
                    wrap.apiName = apiName;
                    wrap.runAPI = true;
                    wrap.applicantId =applicantrec.Id;
                    wrap.applicantName = applicantrec.FullName__c;
                    if(applicantrec.Constitution__c == 'INDIVIDUAL' && String.isBlank(applicantrec.FName__c)){
                        //to remove Dedupe
                        wrap.runAPI = false;
                        wrap.missingFields = true;
                        wrap.missingFieldDetails = 'First Name is missing';
                    }else if(applicantrec.Constitution__c != 'INDIVIDUAL' && String.isBlank(applicantrec.CompanyName__c)){
                        
                        wrap.runAPI = false;
                        wrap.missingFields = true;
                        wrap.missingFieldDetails = 'Company Name is missing';
                        
                    }

                    //if it is already run then make it false;
                    if(applToTracker.containskey(applicantrec.Id+'-'+apiName)){
                        wrap.runAPI = false;
                        wrap.missingFields = false;
                        wrap.missingFieldDetails = '';
                    }
                    wrapList.add(wrap);
                }else if(apiName == 'Consumer ACK Request'){
                    wrap.apiName = apiName;
                    wrap.runAPI = true;
                    wrap.applicantId =applicantrec.Id;
                    wrap.applicantName = applicantrec.FullName__c;
                    system.debug('debug issue applKycMap id'+applKycMap+' ' +applicantrec.Id);
                    if(applicantrec.Constitution__c != 'INDIVIDUAL'){
                        //for non individual do not have to run the consumer
                        wrap.runAPI = false;
                        wrap.missingFields = false;
                        wrap.missingFieldDetails = '';
                    }else if(String.isBlank(applicantrec.LoanAppln__r.Product__c) || applicantrec.LoanAppln__r.ReqLoanAmt__c == null 
                            || String.isBlank(applicantrec.Gender__c) || applicantrec.DOB__c == NULL || String.isBlank(applicantrec.MobNumber__c)
                            || applicantrec.Applicant_Addresses__r.size() == 0
                            ){
                                wrap.runAPI = false;
                                wrap.missingFields = false;
                                wrap.missingFieldDetails = 'Either Product, Requested Loan Amount, Gender,Mobile Number, Address Details are missing';
                                
                    }else if(!applKycMap.containsKey(applicantrec.Id)){
                        

                                
                                wrap.missingFields = true;
                                wrap.runlmstoUpdate= false;
                                wrap.missingFieldDetails = 'Pls retry to validate the ID proof document or input the ID details manually in PAN & KYC page';
                    }else if(applToTracker.containskey(applicantrec.Id+'-'+apiName)){
                        wrap.runAPI = false;
                        wrap.missingFields = false;
                        wrap.missingFieldDetails = '';
                    }
                    

                    wrapList.add(wrap);

                    
                }
            }
        }    
        }
        return wrapList;
        
    }

    public Class APIToRunWrapper{
        @auraEnabled public Boolean runAPI{get;set;}
        @auraEnabled public Boolean missingFields{get;set;}
        @auraEnabled public String missingFieldDetails{get;set;}
        @auraEnabled public String applicantName{get;set;}
        @auraEnabled public String applicantId{get;set;}
        @auraEnabled public String apiName{get;set;}
        @auraEnabled public Boolean runlmstoUpdate{get;set;}
    }
}