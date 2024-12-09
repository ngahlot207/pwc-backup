@isTest
public class FileControllerTest {
	@isTest
    static void getVersionFilesTest(){
        
        ContentVersion contentVersion = new ContentVersion(
          Title          = 'a picture',
          PathOnClient   = 'Pic.jpg',
          VersionData    = Blob.valueOf('Test Content'),
          IsMajorVersion = true);
        	insert contentVersion; 
        List<ContentVersion> conVer=[SELECT id,FirstPublishLocationId FROM ContentVersion WHERE id=:contentVersion.Id];
        system.debug('FirstPublishLocationId'+conVer[0].FirstPublishLocationId);
		List<ContentVersion> result = FileController.getVersionFiles(conVer[0].FirstPublishLocationId);
        system.debug('result.size()'+result.size());
		System.assertEquals(1, result.size(), 'Expected one ContentVersion record');
		
        
    }
    
}