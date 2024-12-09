public class ExcelDataToJsonApexClass {
	
    @AuraEnabled(cacheable=true)
    public static List<EXCELTOJSONNEW__c> getJsonToExcelMetadataForAppliBank(){
        List<EXCELTOJSONNEW__c> jsonMetaDataList=[select SourceColumn__c,Target_Object_Name__c, Field_API_Name__c from EXCELTOJSONNEW__c where Target_Object_Name__c='ApplBanking__c'];
        system.debug('jsonMetaDataList'+jsonMetaDataList);
        return jsonMetaDataList;
    }
    @AuraEnabled(cacheable=true)
    public static List<EXCELTOJSONNEW__c> MetadataForAppliBankDetail(){
        List<EXCELTOJSONNEW__c> jsonMetaDataList=[select SourceColumn__c, Field_API_Name__c from EXCELTOJSONNEW__c where Target_Object_Name__c='ApplBankDetail__c' ORDER BY Sequence__c];
        system.debug('jsonMetaDataList>>>>>>'+jsonMetaDataList);
        return jsonMetaDataList;
    }
   /* @AuraEnabled
    public static SobjctDataWrapper upsertSobjDataWIthRelatedChilds(SobjectUpsertData upsertData){
        system.debug('upsertData' + upsertData);
        SobjctDataWrapper sobjWrp = new SobjctDataWrapper();
        try{
            system.debug('upsertData' + upsertData);
            
            String ParentFieldApiNameToUpdate = upsertData.ParentFieldNameToUpdate != null ? upsertData.ParentFieldNameToUpdate : null;   
            
            if(upsertData != null ){
                
                SObject parentRecordDetails = upsertData.parentRecord != null ? upsertData.parentRecord : null ;
                
                // system.debug('parent record id' + (Id)parentRecordDetails.get('Id')); 
                if(parentRecordDetails != null ){
                    
                    upsert parentRecordDetails;
                    sobjWrp.parentRecord = parentRecordDetails;
                }
                
                if(upsertData.ChildRecords != null  ){
                    
                    for(SObject record : upsertData.ChildRecords)  {          
                        //record.ParentFieldApiNameToUpdate = (Id)parentRecordDetails.get('Id');
                        //system.debug('parent record id' + (Id)parentRecordDetails.get('Id'));
                        Object childRecordId = record.get('Id');
                        system.debug('childRecordId' +childRecordId);
                        if(childRecordId == null){  
                            record.put(ParentFieldApiNameToUpdate, (Id)parentRecordDetails.get('Id'));
                        }     
                    }
                    
                    List<SObject> childRecordDetails = upsertData.ChildRecords;
                    system.debug('childRecordDetails'+childRecordDetails);
                    
                    if(!childRecordDetails.isEmpty()){
                        
                        upsert childRecordDetails;
                        sobjWrp.ChildReords = childRecordDetails;
                    }
                    
                }  
            }
        }catch(exception e){
            system.debug('error message is'+ e.getMessage() + 'Line Number ' + e.getLineNumber() + 'get trace' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }  
        system.debug('parentRecord'+sobjWrp);
        return sobjWrp;
    }
    public class SobjectQueryParams {
        @AuraEnabled
        public String ParentObjectName { get; set; }
        @AuraEnabled
        public String ChildObjectRelName { get; set; }
        @AuraEnabled
        public List<String> parentObjFields { get; set; }
        @AuraEnabled
        public List<String> childObjFields { get; set; }
        @AuraEnabled
        public String queryCriteria { get; set; } 
        @AuraEnabled
        public String queryCriteriaForChild { get; set; } 
    }
    
    public class SobjctDataWrapper {
        @AuraEnabled
        public SObject parentRecord { get; set; }
        @AuraEnabled
        public List<SObject> ChildReords { get; set; }     
    }
    
    public class ParentSobjctDataWrapper {
        @AuraEnabled
        public List<SObject> parentRecords { get; set; }    
    }
     public class SobjectUpsertData {
        @AuraEnabled
        public SObject parentRecord { get; set; }
        @AuraEnabled
        public List<SObject> ChildRecords { get; set; }  
        @AuraEnabled
        public String ParentFieldNameToUpdate { get; set; }
    }*/
     @AuraEnabled
    public static string CreateDocumentLink(string parentId, String excelData){ 
       Blob contentData = EncodingUtil.base64Decode(excelData);
        list<Id> contVerLin=new list<Id>();
        list<Id> conDocIds=new list<Id>();
        List<contentVersion> listForDel=new List<contentVersion>();
        // Create ContentVersion record
        List<ContentDocumentLink> oldcontDocRec=[select LinkedEntityId, ContentDocumentId from ContentDocumentLink where LinkedEntityId=:parentId];
        for(ContentDocumentLink con : oldcontDocRec){
            contVerLin.add(con.ContentDocumentId);
        }
        List<contentVersion> conVerRecList=[select id, FileExtension, ContentDocumentId from contentVersion where ContentDocumentId IN : contVerLin];
        if(conVerRecList.size()>0){
            for(contentVersion conver: conVerRecList){
                if(conver.FileExtension ==	'xlsx'){
                   conDocIds.add(conver.ContentDocumentId);
                 }
            }
            
        } 
        if(conDocIds.size()>0){
            List<ContentDocument> condocdelete=[select id from ContentDocument where id IN: conDocIds];
            delete condocdelete;
        }
       
        
        ContentVersion cv = new ContentVersion();
        cv.VersionData = contentData;
        cv.Title = 'Banking Details'; // Provide a suitable file name
        cv.PathOnClient = 'Banking Details.xlsx'; // Provide a suitable file name with extension
        cv.FirstPublishLocationId = parentId; // Id of the record to associate the ContentVersion with
        insert cv;
        contentVersion conVerRec=[select id, FileExtension, ContentDocumentId from contentVersion where id=:cv.Id  Limit 1];
        system.debug('cv'+conVerRec);
        return 'name';
    

    }
     @AuraEnabled(cacheable=false)
    public static Id uploadExcelFile(String fileContents, String fileName, string recordId) {
        // Decode base64 string to binary
        Blob fileBlob = EncodingUtil.base64Decode(fileContents);
        
        // Create ContentVersion record
        ContentVersion cv = new ContentVersion();
        cv.VersionData = fileBlob;
        cv.Title = fileName;
        cv.PathOnClient = fileName;
        cv.FirstPublishLocationId = recordId; // Provide the Id of the record to associate with
        insert cv;
        contentVersion conVerRec=[select id, FileExtension, ContentDocumentId from contentVersion where id=:cv.Id  Limit 1];
        return cv.Id;
    }
    @AuraEnabled(cacheable=false)
    public static void getAllDocDetaRecs(string AppliBnkId) {
        // Decode base64 string to binary
        List<DocDtl__c> docListtoupdate =new List<DocDtl__c>();
        List<DocDtl__c> docList=[select id, IsLatest__c from DocDtl__c where ApplBanking__c =:AppliBnkId];
        for(DocDtl__c doc: docList){
            doc.IsLatest__c=false;
            docListtoupdate.add(doc);
        }
        update docListtoupdate;
        
    }
    
}