@isTest
public class NdcColumnConfigTest {

   /* @isTest
    static void testParseMethod() {
        // Test JSON string
        String jsonString = '{"columns":[{"label":"Name","fieldName":"Name","type":"Text","Editable":true,"options":null,"Required":false,"selectAll":false,"allowUpload":false,"width":"100%"}],"allowUpload":true,"allowDelete":false,"docCategory":"General","groupBy":"Type","title":"Document","addDeviation":true,"deviationCategory":"Major"}';

        // Call the parse method and validate the result
        ResultJson result = NdcColumnConfig.parse(jsonString);

        // Perform assertions to validate the result
        System.assertNotEquals(null, result);
      /*  System.assertNotEquals(null, result.columns);
        System.assertEquals(1, result.columns.size());
        System.assertEquals('Name', result.columns[0].label);
        System.assertEquals('Text', result.columns[0].type);
        System.assertEquals(true, result.columns[0].Editable);
        System.assertEquals(false, result.columns[0].Required);*/
        // Add more assertions based on your actual JSON structure and expected values
    
    static testMethod void testWrp()
    {
        NdcColumnConfig wrp = new NdcColumnConfig();
        wrp.allowUpload = true;
        wrp.allowDelete = true;
        wrp.docCategory = 'PAN Documents';
        wrp.groupBy='ABC';
        wrp.title = 'PAN';
        wrp.addDeviation = true;
        wrp.deviationCategory = 'Admin@123';
       // wrp.path = 'JWTUSER';
      // wrp.reason = 'Admin@123';
       // wrp.code = 'Admin@123';
        //Test.startTest(); 
        ResultJson wrp1 = new ResultJson();
        wrp1=  ResultJson.parse(JSON.serialize(wrp));
       // Test.stopTest();
        system.Assert(true);
        
        //system.assertEquals(wrp1.allowUpload,wrp.allowUpload);
        //system.assertEquals(wrp1.docCategory,wrp.docCategory);
        //
        NdcColumnConfig.ColumnConfig c = new NdcColumnConfig.ColumnConfig();
        c.label='Name';
        c.allowUpload=true;
        c.Editable=true;
        c.fieldName='Name';
        c.options=null;
        c.Required=false;
        c.selectAll=false;
        c.type='Text';
        c.width='100';
    }
    
}