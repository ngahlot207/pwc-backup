@isTest
public class AgcLocaWrapperClassTest {

    @isTest
    static void AgcLocaWrapperClassTestMethod() {
        AgncLocMap__c agn1 = new AgncLocMap__c(LastAllocated__c = Datetime.newInstance(2024, 1, 2));
        AgncLocMap__c agn2 = new AgncLocMap__c(LastAllocated__c = Datetime.newInstance(1960, 1, 1));
        
        AgncLocMap__c agn3 = new AgncLocMap__c();
        AgncLocMap__c agn4 = new AgncLocMap__c();

        // Create instances of AgcLocaWrapperClass 
        AgcLocaWrapperClass wrapper1 = new AgcLocaWrapperClass(agn1); 
        AgcLocaWrapperClass wrapper2 = new AgcLocaWrapperClass(agn2);
        AgcLocaWrapperClass wrapper3 = new AgcLocaWrapperClass(agn3); 
        AgcLocaWrapperClass wrapper4 = new AgcLocaWrapperClass(agn4); 

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