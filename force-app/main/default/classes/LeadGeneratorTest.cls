@isTest
public class LeadGeneratorTest {
    @isTest
    public static void allparameter() {
        // Create a LeadGeneratorWrapper object
        LeadGenerator.LeadGeneratorWrapper lgw = new LeadGenerator.LeadGeneratorWrapper('John', 'test', 'Doe', '1234567890', 'john.doe@example.com', 'New York');

        // Serialize the wrapper object to JSON string
        String leadsStr = JSON.serialize(new List<LeadGenerator.LeadGeneratorWrapper>{lgw});
        String csvHeader = 'FirstName,MiddleName,LastName,MobileNumber,EmailId,CurrentCity';
        String fileName = 'TestFile.csv';

        // Call the method to be tested
        Test.startTest();
        LeadGenerator.ResponseWrapper result = LeadGenerator.processFile(leadsStr, csvHeader, fileName);
        Test.stopTest();

        
    }
    
    @isTest
    public static void parameterskip() {
        // Create a LeadGeneratorWrapper object
        LeadGenerator.LeadGeneratorWrapper lgw = new LeadGenerator.LeadGeneratorWrapper('', 'test', 'Doe', '1234567890', 'john.doe@example.com', 'New York');
        LeadGenerator.LeadGeneratorWrapper lgw1 = new LeadGenerator.LeadGeneratorWrapper('John', '', 'Doe', '1234567890', 'john.doe@example.com', 'New York');
        LeadGenerator.LeadGeneratorWrapper lgw2 = new LeadGenerator.LeadGeneratorWrapper('John', 'test', '', '1234567890', 'john.doe@example.com', 'New York');
        LeadGenerator.LeadGeneratorWrapper lgw3 = new LeadGenerator.LeadGeneratorWrapper('John', 'test', 'Doe', '', 'john.doe@example.com', 'New York');
        LeadGenerator.LeadGeneratorWrapper lgw4 = new LeadGenerator.LeadGeneratorWrapper('John', 'test', 'Doe', '1234567890A', '', 'New York');
        LeadGenerator.LeadGeneratorWrapper lgw5 = new LeadGenerator.LeadGeneratorWrapper('John', 'test', 'Doe', '12345678901', 'john.doe@example.com', '');
        
        
        
        
        // Serialize the wrapper object to JSON string
        String FirstNamemis = JSON.serialize(new List<LeadGenerator.LeadGeneratorWrapper>{lgw});
        String MiddleNamemis = JSON.serialize(new List<LeadGenerator.LeadGeneratorWrapper>{lgw1});
        String LastNamemis = JSON.serialize(new List<LeadGenerator.LeadGeneratorWrapper>{lgw2});
        String MobileNumbermis = JSON.serialize(new List<LeadGenerator.LeadGeneratorWrapper>{lgw3});
        String EmailIdmis = JSON.serialize(new List<LeadGenerator.LeadGeneratorWrapper>{lgw4});
        String CurrentCitymis = JSON.serialize(new List<LeadGenerator.LeadGeneratorWrapper>{lgw5});
        String csvHeader = 'FirstName,MiddleName,LastName,MobileNumber,EmailId,CurrentCity';
        String fileName = 'TestFile.csv';

        // Call the method to be tested
        Test.startTest();
        LeadGenerator.ResponseWrapper result = LeadGenerator.processFile(FirstNamemis, csvHeader, fileName);
        LeadGenerator.ResponseWrapper result1 = LeadGenerator.processFile(MiddleNamemis, csvHeader, fileName);
        LeadGenerator.ResponseWrapper result2 = LeadGenerator.processFile(LastNamemis, csvHeader, fileName);
        LeadGenerator.ResponseWrapper result3 = LeadGenerator.processFile(MobileNumbermis, csvHeader, fileName);
        LeadGenerator.ResponseWrapper result4 = LeadGenerator.processFile(EmailIdmis, csvHeader, fileName);
        LeadGenerator.ResponseWrapper result5 = LeadGenerator.processFile(CurrentCitymis, csvHeader, fileName);
        Test.stopTest();

        
    }
    
     @isTest
    public static void emptyparameter() {
        // Create a LeadGeneratorWrapper object
        LeadGenerator.LeadGeneratorWrapper lgw = new LeadGenerator.LeadGeneratorWrapper('', '', '', '', '', '');

        // Serialize the wrapper object to JSON string
        String leadsStr = JSON.serialize(new List<LeadGenerator.LeadGeneratorWrapper>{lgw});
        String csvHeader = 'FirstName,MiddleName,LastName,MobileNumber,EmailId,CurrentCity';
        String fileName = 'TestFile.csv';

        // Call the method to be tested
        Test.startTest();
        LeadGenerator.ResponseWrapper result = LeadGenerator.processFile(leadsStr, csvHeader, fileName);
        Test.stopTest();

        
    }
    
     @isTest
    public static void mobilenumbercheck() {
        // Create a LeadGeneratorWrapper object
        LeadGenerator.LeadGeneratorWrapper lgw = new LeadGenerator.LeadGeneratorWrapper('john', 'test', 'Doe', '9972749458', 'john.doe@example.com', 'New York');
        LeadGenerator.LeadGeneratorWrapper lgwalpha = new LeadGenerator.LeadGeneratorWrapper('john', 'test', 'Doe', 'AS972749458', 'john.doe@example.com', 'New York');
        
        
        // Serialize the wrapper object to JSON string
        String leadstr = JSON.serialize(new List<LeadGenerator.LeadGeneratorWrapper>{lgw});
        String leadalpha = JSON.serialize(new List<LeadGenerator.LeadGeneratorWrapper>{lgwalpha});
        String csvHeader = 'FirstName,MiddleName,LastName,MobileNumber,EmailId,CurrentCity';
        String fileName = 'TestFile.csv';

        // Call the method to be tested
        Test.startTest();
        LeadGenerator.ResponseWrapper result = LeadGenerator.processFile(leadstr, csvHeader, fileName);
        LeadGenerator.ResponseWrapper result1 = LeadGenerator.processFile(leadalpha, csvHeader, fileName);
       Test.stopTest();

        
    }
    
     @isTest
    public static void firstnamecheck() {
        // Create a LeadGeneratorWrapper object
       LeadGenerator.LeadGeneratorWrapper firstnamealpha = new LeadGenerator.LeadGeneratorWrapper('123', 'test', 'Doe', '9972749458', 'john.doe@example.com', 'New York');
        
        
        
        // Serialize the wrapper object to JSON string
        String leadfirstnamealpha = JSON.serialize(new List<LeadGenerator.LeadGeneratorWrapper>{firstnamealpha});
        String csvHeader = 'FirstName,MiddleName,LastName,MobileNumber,EmailId,CurrentCity';
        String fileName = 'TestFile.csv';

        // Call the method to be tested
        Test.startTest();
        LeadGenerator.ResponseWrapper result = LeadGenerator.processFile(leadfirstnamealpha, csvHeader, fileName);
        Test.stopTest();

        
    }
    
    @isTest
    public static void middlenamecheck() {
        // Create a LeadGeneratorWrapper object
       LeadGenerator.LeadGeneratorWrapper middlenamealpha = new LeadGenerator.LeadGeneratorWrapper('Doe', '123', 'Doe', '9972749458', 'john.doe@example.com', 'New York');
        
        
        
        // Serialize the wrapper object to JSON string
        String leadmiddlenamealpha = JSON.serialize(new List<LeadGenerator.LeadGeneratorWrapper>{middlenamealpha});
        String csvHeader = 'FirstName,MiddleName,LastName,MobileNumber,EmailId,CurrentCity';
        String fileName = 'TestFile.csv';

        // Call the method to be tested
        Test.startTest();
        LeadGenerator.ResponseWrapper result = LeadGenerator.processFile(leadmiddlenamealpha, csvHeader, fileName);
        Test.stopTest();

        
    }
    
    @isTest
    public static void Lastnamecheck() {
        // Create a LeadGeneratorWrapper object
       LeadGenerator.LeadGeneratorWrapper Lastnamealpha = new LeadGenerator.LeadGeneratorWrapper('test', 'test', '123', '9972749458', 'john.doe@example.com', 'New York');
        
        
        
        // Serialize the wrapper object to JSON string
        String Lastname = JSON.serialize(new List<LeadGenerator.LeadGeneratorWrapper>{Lastnamealpha});
        String csvHeader = 'FirstName,MiddleName,LastName,MobileNumber,EmailId,CurrentCity';
        String fileName = 'TestFile.csv';

        // Call the method to be tested
        Test.startTest();
        LeadGenerator.ResponseWrapper result = LeadGenerator.processFile(Lastname, csvHeader, fileName);
        Test.stopTest();

        
    }
    
    

}