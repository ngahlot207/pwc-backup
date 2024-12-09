@isTest
public class LeadDocumentTypeAndNameTest {
    
    @isTest
    static void testFetchAllDocsForIndividualNonProfessional() {
        Map<String, List<String>> result = LeadDocumentTypeAndName.fetchAllDocs('Individual', 'Non Professional');
        System.assertEquals(5, result.size(), 'Incorrect number of document types returned');
        System.assert(result.containsKey('Sign Proof'), 'Sign Proof document type not found');
        System.assert(result.containsKey('Residence Address proof - OVD'), 'Residence Address proof - OVD document type not found');
        System.assert(result.containsKey('DOB Proof'), 'DOB Proof document type not found');
        System.assert(result.containsKey('Identity Proof'), 'Identity Proof document type not found');
        System.assert(result.containsKey('Residence Address proof - Deemed OVD'), 'Residence Address proof - Deemed OVD document type not found');
        // Add more assertions for specific document types and names returned
    }

    @isTest
    static void testFetchAllDocsForIndividualProfessional() {
        Map<String, List<String>> result = LeadDocumentTypeAndName.fetchAllDocs('Individual', 'SELF EMPLOYED NON PROFESSIONAL');
        System.assertEquals(2, result.size(), 'Incorrect number of document types returned');
        System.assert(result.containsKey('PAN'), 'PAN document type not found');
        System.assert(result.containsKey('Principal Place of Business - Address Proof'), 'Principal Place of Business - Address Proof document type not found');
        // Add more assertions for specific document types and names returned
    }
    
    @isTest
    static void testFetchAllDocsForProprietorship() {
        Map<String, List<String>> result = LeadDocumentTypeAndName.fetchAllDocs('PROPERITORSHIP', '');
        System.assertEquals(2, result.size(), 'Incorrect number of document types returned');
        System.assert(result.containsKey('PAN'), 'PAN document type not found');
        System.assert(result.containsKey('Principal Place of Business - Address Proof'), 'Principal Place of Business - Address Proof document type not found');
        // Add more assertions for specific document types and names returned
    }
    
    @isTest
    static void testFetchAllDocsForOtherConstitution() {
        Map<String, List<String>> result = LeadDocumentTypeAndName.fetchAllDocs('HUF', '');
        System.assertEquals(1, result.size(), 'Incorrect number of document types returned');
        System.assert(result.containsKey('Registered office - Address Proof'), 'Registered office - Address Proof document type not found');
        // Add more assertions for specific document types and names returned
    }
    
    @isTest
    static void testFetchAllDocsForPARTNERSHIP() {
        Map<String, List<String>> result = LeadDocumentTypeAndName.fetchAllDocs('PARTNERSHIP', '');
        System.assertEquals(3, result.size(), 'Incorrect number of document types returned');
        System.assert(result.containsKey('PAN'), 'PAN document type not found');
        System.assert(result.containsKey('Principal Place of Business - Address Proof'), 'Principal Place of Business - Address Proof document type not found');
        System.assert(result.containsKey('Registered office - Address Proof'), 'Registered office - Address Proof document type not found');
        // Add more assertions for specific document types and names returned
    }
    
    // Add more test methods to cover other scenarios and edge cases
}