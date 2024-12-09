@isTest
public class CriteriaConfigClassTest {

      @isTest
    static void criteriaConfigClassMethod(){
        String json = '{'+
		'\"criteriaConfig\":'+
		'{'+
		'\"criteria\": [{'+
		'\"objectAPIName\": \"Applicant__c\",'+
		'\"fieldName\" : \"Constitution__c\"'+
		'}],'+
		'\"expression\" :\"Constitution__c == \'Individual\' || Constitution__c != \'Individual\'\"'+
		'}'+
		'}';
		CriteriaConfigClass obj = CriteriaConfigClass.parse(json);
		System.assert(obj != null);
    }
}