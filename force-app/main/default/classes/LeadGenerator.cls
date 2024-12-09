public class LeadGenerator {
    static final String COUNTRY_CODE = '+91';
    static final String COMPANY      = 'FedFina';
    static final String STAGE        = 'New';
    static final String SUB_STAGE    = 'Non-Verified';
    

	@AuraEnabled
    public static ResponseWrapper processFile(String leadsStr, String csvHeader,String fileName){
        System.debug('leadsStr: ' + leadsStr);System.debug('csvHeader: ' + csvHeader);
       System.debug('filename:' + fileName);
        
        

        List<Sobject> leadsToInsert             = new List<Sobject>();
        List<List<String>> csvRowValues      = new List<List<String>>(); //used to hold csv file data so that it can be returned back to the UI in case of any failure
        List<LeadGeneratorWrapper> leadsList = (List<LeadGeneratorWrapper>)JSON.deserialize(leadsStr, List<LeadGeneratorWrapper>.class);
        Integer successRowCount              = 0; //used to count the number of rows suucessfully inserted
        Integer errorRowCount                = 0; //used to count the number of rows that got failed
        Id recordTypeId =[select Id from RecordType where sobjectType='Lead' and name='Staged Lead'].id; //fetching Staged Lead Record Type
        //creating record for Bulk Upload Summary
       
        BlkUploadSummary__c bus = new BlkUploadSummary__c();        
        bus.FileName__c=fileName;
        bus.SuccessRecords__c=successRowCount;
        bus.ErrorRecords__c=errorRowCount;  
        
       // bus.Branch__c= [select EmpBrch__c from TeamHierarchy__c];
       // insert bus;
        
        //Iterating wrapper and prepared lead records
        for(LeadGeneratorWrapper lgw : leadsList){
            
            if(String.isBlank(lgw.LastName) && String.isBlank(lgw.MobileNumber) && String.isBlank(lgw.EmailId) && String.isBlank(lgw.FirstName) && String.isBlank(lgw.CurrentCity) && String.isBlank(lgw.MiddleName)){
                continue;
            }
            else if(String.isBlank(lgw.FirstName)){
                errorRowCount = errorRowCount + 1;
                List<String> rowStr3 = new List<String>();
                rowStr3.add('REQUIRED_FIELD_MISSING: Required fields are missing: [First Name]');
                rowStr3.add(lgw.FirstName);
                rowStr3.add(lgw.MiddleName);
                rowStr3.add(lgw.LastName);
                rowStr3.add(lgw.MobileNumber);
                rowStr3.add(lgw.EmailId);
                rowStr3.add(lgw.CurrentCity);
                csvRowValues.add(rowStr3);
                continue;
            }
            else if(String.isBlank(lgw.LastName)){
                errorRowCount = errorRowCount + 1;
                List<String> rowStr4 = new List<String>();
                rowStr4.add('REQUIRED_FIELD_MISSING: Required fields are missing: [Last Name]');
                rowStr4.add(lgw.FirstName);
                rowStr4.add(lgw.MiddleName);
                rowStr4.add(lgw.LastName);
                rowStr4.add(lgw.MobileNumber);
                rowStr4.add(lgw.EmailId);
                rowStr4.add(lgw.CurrentCity);
                csvRowValues.add(rowStr4);
                continue;
            }
            else if(String.isBlank(lgw.MobileNumber)){
                errorRowCount = errorRowCount + 1;
                List<String> rowStr5 = new List<String>();
                rowStr5.add('REQUIRED_FIELD_MISSING: Required fields are missing: [MobileNumber]');
                rowStr5.add(lgw.FirstName);
                rowStr5.add(lgw.MiddleName);
                rowStr5.add(lgw.LastName);
                rowStr5.add(lgw.MobileNumber);
                rowStr5.add(lgw.EmailId);
                rowStr5.add(lgw.CurrentCity);
                csvRowValues.add(rowStr5);
                continue;
            }
            else if(lgw.MobileNumber.length() > 10){
                errorRowCount = errorRowCount + 1;
                List<String> rowStr5 = new List<String>();
                rowStr5.add('MOBILE_NUMBER_VALIDATION: [MobileNumber] cannot be more than 10 characters');
                rowStr5.add(lgw.FirstName);
                rowStr5.add(lgw.MiddleName);
                rowStr5.add(lgw.LastName);
                rowStr5.add(lgw.MobileNumber);
                rowStr5.add(lgw.EmailId);
                rowStr5.add(lgw.CurrentCity);
                csvRowValues.add(rowStr5);
                continue;
            }
            else if(!validateMobileForNumbers(lgw.MobileNumber)){
                errorRowCount = errorRowCount + 1;
                List<String> rowStr5 = new List<String>();
                rowStr5.add('MOBILE_NUMBER_VALIDATION: [MobileNumber] cannot contain alpha-numeric values');
                rowStr5.add(lgw.FirstName);
                rowStr5.add(lgw.MiddleName);
                rowStr5.add(lgw.LastName);
                rowStr5.add(lgw.MobileNumber);
                rowStr5.add(lgw.EmailId);
                rowStr5.add(lgw.CurrentCity);
                csvRowValues.add(rowStr5);
                continue;
            }
            else if(lgw.MobileNumber.startsWithIgnoreCase('0') || lgw.MobileNumber.startsWithIgnoreCase('1') || lgw.MobileNumber.startsWithIgnoreCase('2')
                    || lgw.MobileNumber.startsWithIgnoreCase('3') || lgw.MobileNumber.startsWithIgnoreCase('4') || lgw.MobileNumber.startsWithIgnoreCase('5')){
                errorRowCount = errorRowCount + 1;
                List<String> rowStr5 = new List<String>();
                rowStr5.add('MOBILE_NUMBER_VALIDATION: [MobileNumber] cannot start with number 0-5');
                rowStr5.add(lgw.FirstName);
                rowStr5.add(lgw.MiddleName);
                rowStr5.add(lgw.LastName);
                rowStr5.add(lgw.MobileNumber);
                rowStr5.add(lgw.EmailId);
                rowStr5.add(lgw.CurrentCity);
                csvRowValues.add(rowStr5);
                continue;
            }
            else if(!validateFirstNameForNumbers(lgw.FirstName)){
                errorRowCount = errorRowCount + 1;
                List<String> rowStr5 = new List<String>();
                rowStr5.add('FIRST_NAME_VALIDATION: [FirstName] can only contain alphabets');
                rowStr5.add(lgw.FirstName);
                rowStr5.add(lgw.MiddleName);
                rowStr5.add(lgw.LastName);
                rowStr5.add(lgw.MobileNumber);
                rowStr5.add(lgw.EmailId);
                rowStr5.add(lgw.CurrentCity);
                csvRowValues.add(rowStr5);
                continue;
            }
            else if(!String.isBlank(lgw.MiddleName) && !validateMiddleNameForNumbers(lgw.MiddleName)){
                errorRowCount = errorRowCount + 1;
                List<String> rowStr5 = new List<String>();
                rowStr5.add('MIDDLE_NAME_VALIDATION: [MiddleName] can only contain alphabets');
                rowStr5.add(lgw.FirstName);
                rowStr5.add(lgw.MiddleName);
                rowStr5.add(lgw.LastName);
                rowStr5.add(lgw.MobileNumber);
                rowStr5.add(lgw.EmailId);
                rowStr5.add(lgw.CurrentCity);
                csvRowValues.add(rowStr5);
                continue;
            }
            else if(!validateLastNameForNumbers(lgw.LastName)){
                errorRowCount = errorRowCount + 1;
                List<String> rowStr5 = new List<String>();
                rowStr5.add('LAST_NAME_VALIDATION: [LastName] can only contain alphabets');
                rowStr5.add(lgw.FirstName);
                rowStr5.add(lgw.MiddleName);
                rowStr5.add(lgw.LastName);
                rowStr5.add(lgw.MobileNumber);
                rowStr5.add(lgw.EmailId);
                rowStr5.add(lgw.CurrentCity);
                csvRowValues.add(rowStr5);
                continue;
            }
            else{
                leadsToInsert.add(new Lead(FirstName       = lgw.FirstName,                                           
                                           MiddleName = lgw.MiddleName,  
                                           LastName        = lgw.LastName, 
                                           Phone     = COUNTRY_CODE + lgw.MobileNumber, 
                                           Email           = lgw.EmailId,
                                          City = lgw.CurrentCity,
                                           Bulk_Lead__c=true,
                                           //Stage__c        = STAGE,
                                           //Sub_Stage__c    = SUB_STAGE
                                           Company         = COMPANY,
                                           RecordTypeId=recordTypeId
                                          ));
            }
        }
        
        List<Database.SaveResult> saveResult = Database.insert(leadsToInsert, false);
        System.debug('saveResult: ' + saveResult);
        
        for(Integer k = 0; k < saveResult.size(); k++){
            if (saveResult[k].isSuccess()) {
                //Operation was successful.
                successRowCount = successRowCount + 1;
                List<String> rowStr = new List<String>();
                rowStr.add('Success');
                rowStr.add(leadsList.get(k).FirstName);
                rowStr.add(leadsList.get(k).MiddleName);
                rowStr.add(leadsList.get(k).LastName);
                rowStr.add(leadsList.get(k).MobileNumber);
                rowStr.add(leadsList.get(k).EmailId);
                rowStr.add(leadsList.get(k).CurrentCity);
                csvRowValues.add(rowStr);
            }
            else {
                //Operation failed, so get all errors
                errorRowCount = errorRowCount + 1;
                for(Database.Error err : saveResult[k].getErrors()) {
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    
                    List<String> rowStr2 = new List<String>();
                    rowStr2.add(err.getStatusCode() + ': ' + err.getMessage());
                    rowStr2.add(leadsList.get(k).FirstName);
                    rowStr2.add(leadsList.get(k).MiddleName);
                    rowStr2.add(leadsList.get(k).LastName);
                    rowStr2.add(leadsList.get(k).MobileNumber);
                    rowStr2.add(leadsList.get(k).EmailId);
                    rowStr2.add(leadsList.get(k).CurrentCity);
                    csvRowValues.add(rowStr2);
                }
            }
        }
        //updating bulk summary
        BlkUploadSummary__c busUpdate = new BlkUploadSummary__c();
        
        busUpdate.id=bus.id;
        busUpdate.SuccessRecords__c=successRowCount;
        busUpdate.ErrorRecords__c=errorRowCount;  
       
      // update busUpdate;
       
        ResponseWrapper response = new ResponseWrapper(successRowCount, errorRowCount, csvRowValues);
        System.debug('csvRowValues: ' + csvRowValues);System.debug('response: ' + response);
        
        return response;
    }
    
    private static Boolean validateMobileForNumbers(String mobNum){
        
        try{
            return mobNum.isNumeric();
        }
        catch(Exception e){
            return false;
        }
        /*System.debug('mobNum: ' + mobNum);
        Pattern MyPattern = Pattern.compile('[0-9]{1,10}');
        
        Matcher MyMatcher = MyPattern.matcher('mobNum');
        
        System.debug('MyMatcher.matches(): ' + MyMatcher.matches());
        return MyMatcher.matches();*/
    }
    private static Boolean validateFirstNameForNumbers(String fName){
        
        try{
            return fName.isAlpha();
        }
        catch(Exception e){
            return false;
        }
    }
    private static Boolean validateMiddleNameForNumbers(String mName){
        
        try{
            return mName.isAlpha();
        }
        catch(Exception e){
            return false;
        }
    }
    private static Boolean validateLastNameForNumbers(String lName){
        
        try{
            return lName.isAlpha();
        }
        catch(Exception e){
            return false;
        }
    }


    
    
    public class LeadGeneratorWrapper{
        
        public LeadGeneratorWrapper(String firstName, String middleName, String lastName, String mobileNumber, String emailId, String currentCity){
            this.FirstName    = firstName;
            this.MiddleName   = middleName;
            this.LastName     = lastName;
            this.MobileNumber = mobileNumber;
            this.EmailId      = emailId;
            this.CurrentCity  = currentCity;
        }
        
        @AuraEnabled public String FirstName;
        @AuraEnabled public String MiddleName;
        @AuraEnabled public String LastName;
        @AuraEnabled public String MobileNumber;
        @AuraEnabled public String EmailId;
        @AuraEnabled public String CurrentCity;
        @AuraEnabled public String Status;
    }
    
    public class ResponseWrapper{
        
        public ResponseWrapper(Integer successRowCounter, Integer errorRowCounter, List<List<String>> csvData){
            this.successRowCounter = successRowCounter;
            this.errorRowCounter   = errorRowCounter;
            this.csvData           = csvData;
            
        }
        @AuraEnabled public Integer successRowCounter;
        @AuraEnabled public Integer errorRowCounter;
        @AuraEnabled public List<List<String>> csvData;
    }

}