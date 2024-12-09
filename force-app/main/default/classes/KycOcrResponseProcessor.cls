public class KycOcrResponseProcessor implements IintMsgCalloutResponseProcessor{
    public static void process(List<IntgMsg__c> responses){ 
        try{
            Set<Id> ids = new set<Id>();
            for(IntgMsg__c integrationMessage : responses){
                ids.add(integrationMessage.ParentRefId__c);
            }
            
                Map<Id,ApplKyc__c> applKycMap = new Map<Id,ApplKyc__c>([SELECT Id,kycDoc__c FROM ApplKyc__c WHERE Id IN: ids]);
            List<IntgMsg__c> aadharResponses = new List<IntgMsg__c>();
            List<IntgMsg__c> voterIdResponses = new List<IntgMsg__c>();
            List<IntgMsg__c> passportResponses = new List<IntgMsg__c>();
            List<IntgMsg__c> dlResponses = new List<IntgMsg__c>();
            List<IntgMsg__c> panResponses = new List<IntgMsg__c>();
            
            for(IntgMsg__c integrationMessage : responses){
                
                if(applKycMap.containsKey(integrationMessage.ParentRefId__c) && applKycMap.get(integrationMessage.ParentRefId__c).kycDoc__c!=''){
                    if(applKycMap.get(integrationMessage.ParentRefId__c).kycDoc__c=='Aadhaar'){
                        aadharResponses.add(integrationMessage);
                    } 
                    if(applKycMap.get(integrationMessage.ParentRefId__c).kycDoc__c=='Voter Id'){
                        voterIdResponses.add(integrationMessage);
                    }
                    if(applKycMap.get(integrationMessage.ParentRefId__c).kycDoc__c=='Passport'){
                        passportResponses.add(integrationMessage);
                    }
                     if(applKycMap.get(integrationMessage.ParentRefId__c).kycDoc__c=='Driving License'){
                        dlResponses.add(integrationMessage);
                    }
                     if(applKycMap.get(integrationMessage.ParentRefId__c).kycDoc__c=='Pan'){
                        panResponses.add(integrationMessage);
                    }
                }
                
            }
            
            if(!aadharResponses.isEmpty()){
                IntOCRAhdarServiceResponseProcessor.process(aadharResponses);
            }
            if(!voterIdResponses.isEmpty()){
                OCRVoterIdResponseProcessor.process(voterIdResponses);
            }
            if(!passportResponses.isEmpty()){
                IntOCRPassportResponseProcessor.process(passportResponses);
            }
            
            if(!dlResponses.isEmpty()){
                OcrDLServiceResponseProcessor.process(dlResponses);
            }
            if(!panResponses.isEmpty()){
                IntOCRPanResponseProcessor.process(panResponses);
            }
            
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'KycOcrResponseProcessor class', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }  
    }
}