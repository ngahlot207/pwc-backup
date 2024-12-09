@isTest
public class SecurityUtilsTest {
    @isTest
    Public Static Void testCheckBypass(){
        boolean isError = true;
        try{
            BYPASS_INTERNAL_FLS_AND_CRUD__c byPassInt = new BYPASS_INTERNAL_FLS_AND_CRUD__c();
            byPassInt.Bypass_Security_Check__c = true;
            insert byPassInt;
            SecurityUtils.checkBypassSecurity();
            
        }catch(exception e){
            isError = false;
        }
        
        system.assertEquals(isError, true);
    }
        @isTest
    Public Static Void testCheckBypass1(){
        boolean isError = true;
        try{
            SecurityUtils.checkBypassSecurity();
            
        }catch(exception e){
            isError = false;
        }
        
        
        system.assertEquals(isError, true);
    }
}