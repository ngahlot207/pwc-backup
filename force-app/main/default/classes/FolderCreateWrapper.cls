/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-13-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class FolderCreateWrapper {
    public String ServerRelativeUrl;
    public MetadataClass metadata;

    public class MetadataClass{
        public String type;
    }
    
    public static FolderCreateWrapper parse(String json){
        return (FolderCreateWrapper) System.JSON.deserialize(json, FolderCreateWrapper.class);
    }
}