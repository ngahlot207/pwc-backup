public without sharing class incomeDetailsController {
    
    @AuraEnabled(cacheable=true)
    public static Sobject getSobjectDataWithMultipleChildRelation(String query){
        if(!String.isBlank(query)){
            return Database.query(query);
        }else{
            return null;
        }
    }

}