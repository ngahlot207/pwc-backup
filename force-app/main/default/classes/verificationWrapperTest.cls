@isTest
public class verificationWrapperTest{
     @isTest
    static void testverificationWrapper() {
       
        verificationWrapper wrp = new verificationWrapper();
        wrp.recordTypeName = 'test';
        wrp.showProfQuaCheck = true;
        wrp.showVerStatus = true;
       // wrp.verificationList= [];
        
 		verificationWrapper wrp1 = new verificationWrapper();
        wrp1=  verificationWrapper.parse(JSON.serialize(wrp));
     
        system.Assert(true);
        system.assertEquals(wrp1.recordTypeName,wrp.recordTypeName);
        system.assertEquals(wrp1.showProfQuaCheck,wrp.showProfQuaCheck);
        
      
        
        // Add more assertions for other fields

        // Add more test cases as needed based on the business logic and requirements
    }

}