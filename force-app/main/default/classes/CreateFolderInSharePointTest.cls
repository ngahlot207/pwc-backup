@isTest
private class CreateFolderInSharePointTest {

    @isTest
    static void testCreateFolder() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorSharePoint());
        CreateFolderInSharePoint.createFolder('TestFolder');
        Test.stopTest();
    }
    
    @isTest
    static void testSerialization() {
        Test.startTest();
        String jsonString = '{"ServerRelativeUrl": "/sites/FedSaleForce_UAT/Shared%20Documents/TestFolder","metadata": {"type": "SP.Folder"}}';
        FolderCreateWrapper res = FolderCreateWrapper.parse(jsonString);
        Test.stopTest();
    }
}