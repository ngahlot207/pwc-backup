@isTest
public class PreviewContentVersionCTRTest {
    @isTest
    static void testProcessMethod(){
        ContentVersion contentVersion = new ContentVersion(
          Title          = 'a picture',
          PathOnClient   = 'Pic.jpg',
          VersionData    = Blob.valueOf('Test Content'),
            contentdocumentId='069C4000001Nek9IAC',
          IsMajorVersion = true);
        	insert contentVersion; 
        PreviewContentVersionCTR classVar=new PreviewContentVersionCTR();
        string testdta=classVar.getVersionData();
    }

}