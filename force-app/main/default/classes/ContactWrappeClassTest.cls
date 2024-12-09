@isTest
public class ContactWrappeClassTest {

    @isTest
    static void ContactWrappeClassTestMethod() {
        Contact contact1 = new Contact(LastAllocated__c = Datetime.newInstance(2024, 1, 2),LastName='Test1');
        Contact contact2 = new Contact(LastAllocated__c = Datetime.newInstance(1960, 1, 1),LastName='Test2');
        
        Contact contact3 = new Contact(LastName='Test3');
        Contact contact4 = new Contact(LastName='Test4');

        // Create instances of ContactWrapperClass 
        ContactWrappeClass wrapper1 = new ContactWrappeClass(contact1); 
        ContactWrappeClass wrapper2 = new ContactWrappeClass(contact2);
        
        // Create instances of ContactWrapperClass 
        ContactWrappeClass wrapper3 = new ContactWrappeClass(contact3); 
        ContactWrappeClass wrapper4 = new ContactWrappeClass(contact4);

        Integer result = wrapper1.compareTo(wrapper2);
        System.assertEquals(1, result);
        
        Integer result1 = wrapper2.compareTo(wrapper1);
        System.assertEquals(-1, result1);

        Integer result2 = wrapper3.compareTo(wrapper4);
        System.assertEquals(0, result2);
        
        Integer result3 = wrapper3.compareTo(wrapper1);
        System.assertEquals(-1, result3);
        
        Integer result4 = wrapper1.compareTo(wrapper3);
        System.assertEquals(1, result);        

    }
}