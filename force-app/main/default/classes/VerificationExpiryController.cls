public class VerificationExpiryController {
    
    @AuraEnabled
    Public static List<String> checkExpiry(String loanApplicationId){
        
        List<String> expiryList = new List<String>();
        try{
            expiryList = VerificationExpiry.expiryDetail(loanApplicationId);
            if(expiryList != null && !expiryList.isEmpty()){
            system.debug('expiryList:'+expiryList);
            return expiryList;

            }
          
        }catch(Exception e){
            system.debug('error message is' + e.getMessage()+'stack'+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
        
        
        return null;
        
    }
    
}