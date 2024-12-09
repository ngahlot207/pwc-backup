@istest
public class ResultJsonTest {
    
    @isTest
    static void resultJsonTestMethod(){
        String json=		'{'+
            '"anyList": ['+
            '{'+
            '"docCategory": "Other Documents",'+
            '"docType": "Relationship proof",'+
            '"docSubType": ['+
            '"Relationship proof"'+
            '],'+
            '"osvRequired": "False"'+
            '},'+
            '{'+
            '"docCategory": "Other Documents",'+
            '"docType": "Additional documents",'+
            '"docSubType": ['+
            '"Additional documents"'+
            '],'+
            '"osvRequired": "False"'+
            '},'+
            '{'+
            '"docCategory": "Other Documents",'+
            '"docType": "Own house / office ownership proof",'+
            '"docSubType": ['+
            '"Own house / office ownership proof"'+
            '],'+
            '"osvRequired": "False"'+
            '}'+
            ']'+
            '}';
        ResultJson obj = ResultJson.parse(json);
        System.assert(obj != null);
    }
}