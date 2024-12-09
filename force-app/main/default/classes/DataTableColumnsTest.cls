@isTest
public class DataTableColumnsTest {
    static testMethod void testWrp()
    {
        DataTableColumns wrp = new DataTableColumns('label', 'fieldName', 'type');
        wrp.label = 'test';
        wrp.fieldName = 'test';
        wrp.type = 'test';
        //Test.startTest(); 
        DataTableColumns wrp1 = new DataTableColumns('label', 'fieldName', 'type');
        wrp1=  DataTableColumns.parse(JSON.serialize(wrp));
       // Test.stopTest();
        system.Assert(true);
        
        system.assertEquals(wrp1.fieldName,wrp.fieldName);
        system.assertEquals(wrp1.label,wrp.label);
    }

}