@isTest
public class RiskRatingResponseWrapperTest { 
    
    static testMethod void RiskRatingResponseWrapperMethod()
    {
        

        String strRes = '{"Result":"test"}';
        
        
        RiskRatingResponseWrapper wrp1 = RiskRatingResponseWrapper.parse(strRes);
        
       
    }
}