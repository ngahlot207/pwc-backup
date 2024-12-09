@isTest
public class IntOCRPanResponseWrapperTest {
    
    @isTest
    static void testParseMethod() {
        // Test JSON data to simulate a response
        String json = '{ "requestId": "4fcde3c9-825e-4927-9381-de9f23580d05", ' +
            '  "result": [ ' +
            '    { ' +
            '      "details": { ' +
            '        "dateValue": { ' +
            '          "conf": "1", ' +
            '          "value": "22/03/1994" ' +
            '        }, ' +
            '        "dateOfIssue": { ' +
            '          "conf": "0", ' +
            '          "value": "" ' +
            '        }, ' +
            '        "father": { ' +
            '          "conf": "0.81", ' +
            '          "value": "CHTTA RANJAN MOHAN" ' +
            '        }, ' +
            '        "name": { ' +
            '          "conf": "1", ' +
            '          "value": "ANUPAM MOHANTY" ' +
            '        }, ' +
            '        "panNo": { ' +
            '          "conf": "1", ' +
            '          "value": "CEEPM6433B" ' +
            '        }, ' +
            '        "qualityCheck": { ' +
            '          "brightness": "52", ' +
            '          "isBlackWhite": "no", ' +
            '          "isBlur": "yes", ' +
            '          "isCutCard": "no" ' +
            '        } ' +
            '      }, ' +
            '      "type": "Pan" ' +
            '    } ' +
            '  ], ' +
            '  "statusCode": 101 ' +
            '}';
        
        // Perform the deserialization and test the parse method
        Test.startTest();
        IntOCRPanResponseWrapper response = IntOCRPanResponseWrapper.parse(json);
        Test.stopTest();
        
        // Perform assertions to verify the parsed response
        System.assertEquals('4fcde3c9-825e-4927-9381-de9f23580d05', response.requestId);
        System.assertEquals(101, response.statusCode);
        System.assertNotEquals(null, response.result);
        System.assertEquals(1, response.result.size());
        System.assertEquals('Pan', response.result[0].type);
    }    
}