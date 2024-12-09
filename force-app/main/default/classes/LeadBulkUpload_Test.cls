@isTest
public class LeadBulkUpload_Test {

    @isTest
    static void testProcessFile() {
   
        // creating a list of testLeadWrappers
        List<LeadBulkUpload.LeadGeneratorWrapper> LeadWrappers = new List<LeadBulkUpload.LeadGeneratorWrapper>();
        
        
        // creating tests for LeadGeneratorWrapper
        
        LeadBulkUpload.LeadGeneratorWrapper testLeadWrapper1 = new LeadBulkUpload.LeadGeneratorWrapper(
            'firstName',  'lastName', '20/06/1887' ,
                                     '9090909098', 'test@mail.com', 'SALARIED',
                                     'INDIVIDUAL', 'companyName',
                                     'nameOfKeyman_AuthorisedIndividual',
                                     '20/07/1886', 'PUNE',
                                     'Digital', 'PUNE', 'product',
                                     'productSubType', '45',
                                     '1992829'
            
        );
        
         LeadBulkUpload.LeadGeneratorWrapper testLeadWrapper2 = new LeadBulkUpload.LeadGeneratorWrapper(
            'firstName',  '', '20/06/1887' ,
                                     '9090909098', 'test@mail.com', 'SALARIED',
                                     'INDIVIDUAL', 'companyName',
                                     'nameOfKeyman_AuthorisedIndividual',
                                     '20/07/1886', 'PUNE',
                                     'Digital', 'PUNE', 'product',
                                     'productSubType', '45',
                                     '1992829'
            
        );
        
        
        LeadBulkUpload.LeadGeneratorWrapper testLeadWrapper3 = new LeadBulkUpload.LeadGeneratorWrapper(
            'firstName12',  'lastName32', '20/06/1887' ,
                                     '9090909098', 'test@mail.com', 'SALARIED',
                                     'INDIVIDUAL', 'companyName',
                                     'nameOfKeyman_AuthorisedIndividual',
                                     '20/07/1886', 'PUNE',
                                     'Digital', 'PUNE', 'product',
                                     'productSubType', '45',
                                     '1992829'
        );
        
        LeadBulkUpload.LeadGeneratorWrapper testLeadWrapper4 = new LeadBulkUpload.LeadGeneratorWrapper(
             'firstName',  'lastName', '20/06/1887' ,
                                     '9090909098', 'test', 'SALARIED',
                                     'INDIVIDUAL', 'companyName',
                                     'nameOfKeyman_AuthorisedIndividual',
                                     '20/07/1886', 'PUNE',
                                     'Digital', 'PUNE', 'product',
                                     'productSubType', '45',
                                     '1992829'
        );
        
        LeadBulkUpload.LeadGeneratorWrapper testLeadWrapper5 = new LeadBulkUpload.LeadGeneratorWrapper(
             '',  '', '20/06/1887' ,
                                     '9090909098', 'test@mail.com', 'SALARIED',
                                     'INDIVIDUAL', 'companyName',
                                     'nameOfKeyman_AuthorisedIndividual',
                                     '20/07/1886', 'PUNE',
                                     'Digital', 'PUNE', 'product',
                                     'productSubType', '45',
                                     '1992829'
        );
        
        LeadBulkUpload.LeadGeneratorWrapper testLeadWrapper6 = new LeadBulkUpload.LeadGeneratorWrapper(
           'firstName',  'lastName', '20/06/1887' ,
                                     '9090909098', 'test@mail.com', 'SALARIED',
                                     'INDIVIDUAL', 'companyName',
                                     'nameOfKeyman_AuthorisedIndividual',
                                     '20/07/1886', 'PUNE',
                                     'Digital', 'PUNE', 'product',
                                     'productSubType', '45',
                                     '1992829'
        );
        
        LeadBulkUpload.LeadGeneratorWrapper testLeadWrapper7 = new LeadBulkUpload.LeadGeneratorWrapper(
              'firstName',  'lastName', '20/06/1887' ,
                                     '9090909098', 'test@mail.com', 'SALARIED',
                                     'INDIVIDUAL', 'companyName',
                                     'nameOfKeyman_AuthorisedIndividual',
                                     '20/07/1886', 'PUNE',
                                     'Digital', 'PUNE', 'product',
                                     'productSubType', '45',
                                     '1992829'
         );
         
		
       LeadBulkUpload.LeadGeneratorWrapper testLeadWrapper8 = new LeadBulkUpload.LeadGeneratorWrapper(
            'firstName',  'dsdsds323', '20/06/1887' ,
                                     '9090909098', 'test@mail.com', 'SALARIED',
                                     'INDIVIDUAL', 'companyName',
                                     'nameOfKeyman_AuthorisedIndividual',
                                     '20/07/1886', 'PUNE',
                                     'Digital', 'PUNE', 'product',
                                     'productSubType', '45',
                                     '1992829'
            
        );	 
    LeadBulkUpload.LeadGeneratorWrapper testLeadWrapper9 = new LeadBulkUpload.LeadGeneratorWrapper(
            'firstName',  'dsdsds323', '20/06/1887' ,
                                     '', 'test@mail.com', 'SALARIED',
                                     'INDIVIDUAL', 'companyName',
                                     'nameOfKeyman_AuthorisedIndividual',
                                     '20/07/1886', 'PUNE',
                                     'Digital', 'PUNE', 'product',
                                     'productSubType', '45',
                                     '1992829'
            
        ); 
LeadBulkUpload.LeadGeneratorWrapper testLeadWrapper10 = new LeadBulkUpload.LeadGeneratorWrapper(
            'firstName',  'dsdsds323', '20/06/1887' ,
                                     '', 'test@mail.com', 'SALARIED',
                                     'INDIVIDUAL', 'companyName',
                                     'nameOfKeyman_AuthorisedIndividual',
                                     '20/07/1886', 'PUNE',
                                     'Digital', 'PUNE', 'product',
                                     'productSubType', '45',
                                     '1992829'
            
        );       
        
        LeadBulkUpload.LeadGeneratorWrapper testLeadWrapper15 = new LeadBulkUpload.LeadGeneratorWrapper(
             '','','','','','',
             '','','','','',
             '','','','','',''
         ); 
      

        
    
        
        LeadWrappers.add(testLeadWrapper1);
        LeadWrappers.add(testLeadWrapper2);
       
        LeadWrappers.add(testLeadWrapper3);
        LeadWrappers.add(testLeadWrapper4);
        LeadWrappers.add(testLeadWrapper5);
      	LeadWrappers.add(testLeadWrapper6);
        LeadWrappers.add(testLeadWrapper7);
        LeadWrappers.add(testLeadWrapper8);
          LeadWrappers.add(testLeadWrapper9);
         LeadWrappers.add(testLeadWrapper10);
        LeadWrappers.add(testLeadWrapper15);
      
        
        
        //String of JSONS
        
        List<String> JSONS= new List<String>();
        for(LeadBulkUpload.LeadGeneratorWrapper Wrapper : LeadWrappers){
            String testLeadWrapperJson = JSON.serialize(new List<LeadBulkUpload.LeadGeneratorWrapper>{Wrapper});
            JSONS.add(testLeadWrapperJson);
        }
        
        
        List<LeadBulkUpload.ResponseWrapper> Results = new List<LeadBulkUpload.ResponseWrapper>();
        
        integer i =0;
        for(String JSON:JSONS){
             LeadBulkUpload.ResponseWrapper result = LeadBulkUpload.processFile(JSON, '', 'test'+i+'.csv');
            Results.add(result);
            i++;
            
        }
        
        // Call the target method with the test data
       
        
        
         // Example of creating a test LeadGeneratorWrapper
        
        
     
        // Perform assertions to validate the results
        for(LeadBulkUpload.ResponseWrapper result: Results){
            
            
        System.assertEquals(1, result.csvData.size(), 'There should be one row in the CSV data.');
       
        
        // Example of asserting specific values in the CSV data
        List<List<String>> csvDataRow = result.csvData;
        
        
        if(result.errorRowCounter!=0){
            System.debug(csvDataRow[0]);
        }
        else{
        	System.assertEquals('Success', csvDataRow[0][0], 'The first column should contain success message.');
        }
        
     
       }
    }
}