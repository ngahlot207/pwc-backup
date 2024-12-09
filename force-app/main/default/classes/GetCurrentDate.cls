public class GetCurrentDate {
 
    @AuraEnabled
    public static date getDate(){
        system.debug('current date'+Date.Today());
        return  Date.Today(); 
    }
}