/** 
* ********************************************************
* Created By : Paresh Saindane
* Created Date: 01-Sept-2023
* ********************************************************
*/
public without sharing class test1  {
       
    public static void createUser(){
        Id portalProfileId = [SELECT Id FROM Profile WHERE Name = 'Agency Profile'].Id;
List<User> userList = new List<User>();
For(Contact c :[select id,account.IsPartner,account.name,email from Contact where account.IsPartner = false and recordtype.name = 'Agency Contact' and email like '%fedfina%' limit 1]){
    String accountName = c.account.name;
    User u = new User();
    u.username = c.email+'.'+accountName.deleteWhitespace();
    u.ProfileId=portalProfileId;
    u.FirstName=c.FirstName;
    u.LastName=c.LastName;
    u.Alias=c.FirstName+c.LastName;
    u.CommunityNickname=c.FirstName;
    u.EmailEncodingKey = 'UTF-8';
    u.LanguageLocaleKey = 'en_US';
    u.LocaleSidKey = 'en_US';
    u.TimeZoneSidKey = 'Asia/Kolkata';
    u.IsActive = true;
    userList.add(u);
    }
        insert userList;
}
    
}