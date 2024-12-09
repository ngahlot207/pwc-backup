public class SecurityUtils {
    public static boolean checkBypassSecurity(){
        List<BYPASS_INTERNAL_FLS_AND_CRUD__c> lstBypassSec = New List<BYPASS_INTERNAL_FLS_AND_CRUD__c>([select Id, Bypass_Security_Check__c  from BYPASS_INTERNAL_FLS_AND_CRUD__c LIMIT 1]);
        if (!lstBypassSec.isEmpty()){
            return lstBypassSec[0].Bypass_Security_Check__c;
        }
        else return true;
    }
}