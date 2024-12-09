public class DomainNameProvider {
    @AuraEnabled
    public static string getLightningHostname(){  
        Profile pfile = [Select Name from Profile where Id =: userinfo.getProfileid()];
        if(UserInfo.getUITheme() == 'Theme4d'){
            String urlis = 'https://'+DomainCreator.getLightningHostname();
            return urlis; 
        }else if(pfile.Name == 'Agency Profile'){
            return System.Label.Community_Agency_Url + '/apex/uploadDocumentLOS';
        }else if(pfile.Name == 'DSA'){
            return System.Label.Community_DSA_Url + '/apex/uploadDocumentLOS';
        }else if(pfile.Name == 'Vendor CPA'){
            return System.Label.Community_DSA_Url + '/apex/uploadDocumentLOS';
        }else{
            return System.Label.community_Url;    
        }
    }   
   @AuraEnabled
    public static String getVisualforceDomain(){ 
        Organization a_ORG = [Select Id, Name, IsSandbox from Organization];
        Profile pfile = [Select Name from Profile where Id =: userinfo.getProfileid()];
        if(UserInfo.getUITheme() == 'Theme4d'){
            if(a_ORG.IsSandbox){
               return 'https://'+getMyDomain() + '--c.' +'sandbox.vf.force.com/apex/uploadDocumentLOS';
            }else{
               return 'https://'+getMyDomain() + '--c.'+'vf.force.com/apex/uploadDocumentLOS';
            }
            
           // return 'https://'+getMyDomain() + '--c.' + getInstance() + '.vf.force.com/apex/uploadDocumentLOS';
        }else if(pfile.Name == 'Agency Profile'){
            return System.Label.Community_Agency_Url + '/apex/uploadDocumentLOS';
        }else if(pfile.Name == 'DSA'){
            return System.Label.Community_DSA_Url + '/apex/uploadDocumentLOS';
        }else if(pfile.Name == 'Vendor CPA'){
            return System.Label.Community_DSA_Url + '/apex/uploadDocumentLOS';
        }else{
            return System.Label.community_Url + '/apex/uploadDocumentLOS'; 
        }
       
    }      
   public static String getLightningDomain(){
        Organization a_ORG = [Select Id, Name, IsSandbox from Organization];
        if(a_ORG.IsSandbox){
        return getMyDomain() + '.sandbox.lightning.force.com';
        }else{
        return getMyDomain() + '.lightning.force.com';
        }
      
    }    
    public static String getMyDomain(){
        return URL.getOrgDomainUrl().getHost().split('\\.')[0].toLowerCase();
    }    
    private static String instance = 'sandbox';
    public static String getInstance(){
        if(String.isBlank(instance)){
            instance = [SELECT InstanceName FROM Organization LIMIT 1].InstanceName.toLowerCase();
        }
        return instance;
    }
    
}