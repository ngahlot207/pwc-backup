public class CompReportResponseProcessor implements IintMsgCalloutResponseProcessor {

    public static void process(List<IntgMsg__c> responses) {

        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> {DocDtl__c.SObjectType });
        fflib_SObjectUnitOfWork uow1 = new fflib_SObjectUnitOfWork( new List<SObjectType> {ContentDocumentLink.SObjectType});


        if (responses.isEmpty()) {
            return; // Exit if there are no responses to process
        }

        Set<Id> idsIngMsg = new Set<Id>();
        Set<Id> applicantIds = new Set<Id>();
        for (IntgMsg__c intmsg : responses) {
            idsIngMsg.add(intmsg.Id);
            applicantIds.add(intmsg.RefId__c);
        }
        List<ContentVersion> contentVersions = [SELECT Id, Title, ContentDocumentId,FirstPublishLocationId FROM ContentVersion WHERE FirstPublishLocationId IN :idsIngMsg];
 

        // Handle case where no ContentVersions are found
        if (contentVersions.isEmpty()) {

            
            return; // Exit if no related ContentVersions are found
        }

        // Create a map to store IntgMsg__c Id and corresponding ContentDocumentId
        Map<Id, Id> intMsgToContentDocMap = new Map<Id, Id>();
        for (ContentVersion cv : contentVersions) {
            intMsgToContentDocMap.put(cv.FirstPublishLocationId, cv.ContentDocumentId);
        }

        //Making existing Doc dtls rec as false
        if(!applicantIds.isEmpty()){
            List<DocDtl__c> existingRec = getExistingDocDtlsRecords(applicantIds);
            if (!existingRec.isEmpty()) {
                IntegrationUtility.updateBooleanFlag(existingRec, 'IsLatest__c', false);
            }
        }

        

        // Prepare lists to insert DocDtl__c records and ContentDocumentLinks
        List<DocDtl__c> listDocDtls = new List<DocDtl__c>();
        List<ContentDocumentLink> contentDocLinks = new List<ContentDocumentLink>();

        // Create DocDtl__c records and ContentDocumentLinks
        for (IntgMsg__c intmsg : responses) {
            if (intMsgToContentDocMap.containsKey(intmsg.Id)) {
                DocDtl__c docDtlObj = new DocDtl__c();
                docDtlObj.DocCatgry__c = 'Probe42 Documents'; //Added val to picklist
                docDtlObj.DocSubTyp__c = 'Company Comprehensive Report Probe'; //Text
                docDtlObj.DocTyp__c = 'Company Report'; //Added val to picklist
                docDtlObj.Appl__c = intmsg.RefId__c;  
                docDtlObj.LAN__c=intmsg.ParentRefId__c;
                docDtlObj.ReferenceId__c=intmsg.Id;
                
                listDocDtls.add(docDtlObj);
                APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Success');
            }else{
                APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Failure');
            }
        }

        if (!listDocDtls.isEmpty()) {
            // Insert DocDtl__c records in bulk
            if(!listDocDtls.isEmpty()) {
                String sObjectName = 'DocDtl__c';
                List<String> fieldNamesList = new List<String>{'DocCatgry__c','Catgry__c','DocSubTyp__c','DocTyp__c','Appl__c','LAN__c'};
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerNew(listDocDtls);
                uow.commitWork();
            }

            // Create ContentDocumentLinks
            for (DocDtl__c docDtl : listDocDtls) {
                Id contentDocId = intMsgToContentDocMap.get(docDtl.ReferenceId__c);
                System.debug('contentDocId =='+contentDocId);
                System.debug('docDtl.Id =='+docDtl.Id);
                if (contentDocId != null) {
                    System.debug('if condition inside');
                    ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
                    contentDocumentLink.ContentDocumentId = contentDocId;
                    contentDocumentLink.LinkedEntityId = docDtl.Id;
                    contentDocumentLink.ShareType = 'V'; // Collaborate (Read/Write/Download)
                    //contentDocumentLink.Visibility = 'AllUsers';  
                    contentDocLinks.add(contentDocumentLink);
                }
            }
        }

        if(!contentDocLinks.isEmpty()) {
            System.debug('content ver inserted Start');
            // String sObjectName = 'ContentDocumentLink';
            // List<String> fieldNamesList = new List<String>{'ContentDocumentId','LinkedEntityId','ShareType','Visibility'};
            //     Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
            // fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
            // uow1.registerNew(contentDocLinks);
            // uow1.commitWork();
            insert contentDocLinks;
            System.debug('content ver inserted ');
        }
    }

    private static List<DocDtl__c> getExistingDocDtlsRecords(Set<Id> applicantIds) {
        system.debug('making list true');
        return [SELECT Id,DocSubTyp__c, DocTyp__c,IsLatest__c,Appl__c, LAN__c,DocCatgry__c from DocDtl__c WHERE Appl__c IN :applicantIds AND DocCatgry__c ='Probe42 Documents' AND DocSubTyp__c='Company Comprehensive Report Probe' AND DocTyp__c='Company Report' AND IsLatest__c =true];
    }

}