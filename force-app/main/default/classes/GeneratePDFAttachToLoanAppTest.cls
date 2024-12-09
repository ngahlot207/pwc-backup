@isTest
public class GeneratePDFAttachToLoanAppTest {
     @isTest
    static void testGenerateDocument() {
        // Create a test DocGenWrapper object
        GeneratePDFandAttachToLoanApplication.DocGenWrapper testWrapper = new GeneratePDFandAttachToLoanApplication.DocGenWrapper();
        testWrapper.pageUrl = '/apex/ContactDataPDF?id=001XXXXXXXXXXXXXXX';
        testWrapper.fileName = 'TestDocument';
        testWrapper.docDetailId = '001XXXXXXXXXXXXXXX';

        
        // Call the generateDocument method to test
        Test.startTest();
        String result = GeneratePDFandAttachToLoanApplication.generateDocument(testWrapper);
        Test.stopTest();
       
         
    

       
    }

}