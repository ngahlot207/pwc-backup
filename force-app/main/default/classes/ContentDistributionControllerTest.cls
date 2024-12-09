@isTest
private class ContentDistributionControllerTest {
	@isTest
	static void testGetContentDistributionLink() {
    ContentVersion testContentVersion = new ContentVersion(
	 Title = 'Test Content',
     PathOnClient ='testing', 
	 VersionData = Blob.valueOf('Test Content Data')
    );
	insert testContentVersion;
	List<ContentDistribution> result = ContentDistributionController.getContentDistributionLink(testContentVersion.Id);
	System.assertNotEquals(0, result.size());
   }

}