@isTest
public class DataTableResponseTest {

     static testMethod void testWrp()
    {
        
       list<DataTableColumns> dtCol = new list <DataTableColumns>();
        list<sObject> sObj = new list <sObject>();
        DataTableResponse wrp = new DataTableResponse(dtCol, sObj, 'tableTitle');
        wrp.tableTitle = 'test';
        wrp.lstDataTableColumns = dtCol;
        wrp.lstDataTableData = sObj;
        //Test.startTest(); 
        DataTableResponse wrp1 = new DataTableResponse(dtCol, sObj, 'tableTitle');
        wrp1=  DataTableResponse.parse(JSON.serialize(wrp));
       // Test.stopTest();
        system.Assert(true);
        
        system.assertEquals(wrp1.tableTitle,wrp.tableTitle);
        system.assertEquals(wrp1.lstDataTableColumns,wrp.lstDataTableColumns);
    }

}