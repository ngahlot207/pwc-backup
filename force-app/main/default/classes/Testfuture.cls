public class Testfuture {
    @future
    public static void pdfcls(List<Integer> values) {
        String DocDtlId;

        // Create DocDtl__c record
        DocDtl__c doc = new DocDtl__c(
            Appl__c = 'a0AC4000000JaB3MAK',
            LAN__c = 'a08C4000006Ayh2IAC',
            DocMstr__c = 'a0JC40000009iQ1MAI',
            DocCatgry__c = 'Bureau Report',
            DocTyp__c = 'Bureau Report',
            DocSubTyp__c = 'Bureau Report'
        );
        insert doc;

        DocDtlId = doc.Id;

        // Convert list of integers to hex-encoded Blob
        String hexval = convertToHex(values);
        Blob result = EncodingUtil.convertFromHex(hexval);

        // Create ContentVersion record
        ContentVersion contentVersion = new ContentVersion(
            VersionData = result,
            Title = 'Report',
            PathOnClient = 'Report.pdf'
        );
        insert contentVersion;

        // Get ContentDocumentId
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1].ContentDocumentId;

        // Link ContentVersion to DocDtl__c record
        ContentDocumentLink contentLink = new ContentDocumentLink(
            ContentDocumentId = contentDocumentId,
            LinkedEntityId = DocDtlId,
            ShareType = 'V'
        );
        insert contentLink;
    }

    private static String convertToHex(List<Integer> values) {
        String[] hexValues = new String[0];
        String[] hex = '0123456789abcdef'.split('');

        for (Integer byteValue : values) {
            Integer highNybble = (byteValue & 240) >> 4;
            Integer lowNybble = byteValue & 15;
            hexValues.add(hex[highNybble]);
            hexValues.add(hex[lowNybble]);
        }

        return String.join(hexValues, '');
    }
}