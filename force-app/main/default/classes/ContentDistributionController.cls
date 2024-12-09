public with sharing class ContentDistributionController {
    @AuraEnabled
    public static List<ContentDistribution> getContentDistributionLink(String conVerId) {
        List<ContentDistribution> conDisList = new List<ContentDistribution>();
        system.debug('inContentDistributionController '+conVerId);
        DateTime dateTimeValue = DateTime.now(); 
		Date dateValue = dateTimeValue.date();
        system.debug('dateValue'+dateValue);
        system.debug('newdate'+ dateValue.addDays(1));
        ContentVersion conVer = [select id, title from ContentVersion where id =: conVerId];
        List<ContentDistribution> allConDisList = [select id,DistributionPublicUrl, pdfdownloadurl,name, expiryDate,ContentVersionId from ContentDistribution where ContentVersionId =: conVerId];
        system.debug('allConDisList'+allConDisList.size());
        if(allConDisList.size()>0){
           for(ContentDistribution conDe: allConDisList){
               system.debug('conDe'+conDe.expiryDate +'url' + conDe.pdfdownloadurl);
                if(conDe.distributionpublicurl != null && conDe.expiryDate > dateValue){
                   conDisList.add(conDe);
                }
                if(conDisList.size()>0){
                   break;
                }
               
        	}
        }
        system.debug('conDisList'+conDisList.size() + '>>>>'+conDisList);
        List<ContentDistribution> conDisListToInsert = new List<ContentDistribution>();
        if(conDisList.isEmpty()){
            ContentDistribution conDis = new ContentDistribution();
            conDis.Name = conVer.title;
            conDis.expiryDate = dateValue.addDays(1);
            conDis.ContentVersionId = conVer.id;
            conDis.preferencesExpires=true;
            conDis.PreferencesNotifyOnVisit=false;
            conDis.PreferencesAllowOriginalDownload=false;
            conDis.PreferencesAllowPDFDownload=false;
            conDisListToInsert.add(conDis);
        }
        if(conDisListToInsert.size()>0){
            system.debug('insert'+conDisListToInsert);
            insert conDisListToInsert;
            ContentDistribution conDistri = [select id,DistributionPublicUrl, pdfdownloadurl,name, expiryDate,ContentVersionId from ContentDistribution where id =: conDisListToInsert[0].id];
            conDisList.add(conDistri);
        }
        system.debug('return '+conDisList);
        return conDisList;
    }
}