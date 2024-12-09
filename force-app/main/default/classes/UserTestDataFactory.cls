public with sharing class UserTestDataFactory {
    
    public static User UserTestDataFactoryMethod(String profielName, String permissionSetName){
        
        Profile prof = [select id from profile where name= :profielName];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =:permissionSetName ];
        
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test2';
        user.profileId = prof.id;
        if(permissionSetName == 'DSA_user'){
            user.username = 'test876785813322DSA@test.com';
            user.Role__c = 'DSA';
        }else if(permissionSetName == 'Permission_Set_For_Underwritter_User'){
            user.username = 'test8763322Underwriter@test.com';
            user.Role__c = 'Underwriter';
        }else if(permissionSetName == 'Permission_set_for_CPV_User_For_Testing'){
            user.username = 'test8763322CPV@test.com';
            
        }else{
            user.username = 'test87633227678CPA@test.com'; 
            user.Role__c = 'CPA';
        }       
        user.email = 'test@test.com';
        user.Alias = 'abcs';
        user.LocaleSidKey = 'en_US';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.EmailEncodingKey = 'UTF-8';
        user.LanguageLocaleKey = 'en_US';
        insert user;
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);
        if(user != null){
            return user;
        }
        return null;
    }
}