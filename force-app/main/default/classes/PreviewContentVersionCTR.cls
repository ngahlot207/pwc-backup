public class PreviewContentVersionCTR {

    private final String versionData;

    public PreviewContentVersionCTR() {
        ContentVersion cv = [SELECT Id, VersionData FROM ContentVersion where contentdocumentId = '069C4000001Nek9IAC' LIMIT 1];       
        versionData = EncodingUtil.base64Encode(cv.VersionData);
    }

    public String getVersionData() {
        return versionData;
    }
}