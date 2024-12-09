@isTest
private class AllowedFileTypeToUploadOnCV_Test {

    @isTest
    static void testAllowedFileType() {
        
        try{
            // Create a new ContentVersion with an allowed file type
        ContentVersion cvAllowed = new ContentVersion(
            Title = 'TestFile',
            PathOnClient = 'TestFile.pdf', // Change file extension as per allowed types
            VersionData = Blob.valueOf('Test File Content')
        );
        
        // Insert the ContentVersion
        insert cvAllowed;
        
        // Verify that no error was thrown
        System.assert(cvAllowed.Id != null, 'No error should be thrown for allowed file type.');
        
        // Create a new ContentVersion with a disallowed file type
        ContentVersion cvDisallowed = new ContentVersion(
            Title = 'TestFile',
            PathOnClient = 'TestFile.exe', 
            VersionData = Blob.valueOf('Test File Content')
        );
        
        // Insert the ContentVersion
      //  Test.startTest(); Test.stopTest();
        insert cvDisallowed;
       
        
        // Verify that an error was thrown
      	System.assertEquals(cvDisallowed.Id,null, 'An error should be thrown for disallowed file type.');
        //System.assertEquals('File type png is not allowed.', 'File type png is not allowed.',
          //                'An error should be thrown for disallowed file type.');
        }catch(Exception e){
            
        }
        
    }
}