/**
 * ─────────────────────────────────────────────────────────────────────────────────────────────────
 * @Author         PwC India
 * @Class          LeadBulkUpload
 * @TestClass      LeadBulkUpload_Test
 * @Description    This class is used for Bulk uplaod Lead from CSV file.
 * @CreatedDateBy  Shekhar kumar
 * @ModifiedBy
 * @ModifiedDate
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 */

public class LeadBulkUpload {
    
    @AuraEnabled
    public static ResponseWrapper processFile(String leadsStr, String csvHeader,String fileName){
        System.debug('leadsStr: ' + leadsStr);System.debug('csvHeader: ' + csvHeader);
        System.debug('filename:' + fileName);
        List<Sobject> leadsToInsert          = new List<Sobject>();
        List<List<String>> csvRowValues      = new List<List<String>>(); //used to hold csv file data so that it can be returned back to the UI in case of any failure
        map<string,string> errorStrMap = new  map<string,string> ();
        List<LeadGeneratorWrapper> goForSaveValues = new List<LeadGeneratorWrapper>(); //used to store the values which will go for insert
        List<LeadGeneratorWrapper> leadsList = (List<LeadGeneratorWrapper>)JSON.deserialize(leadsStr, List<LeadGeneratorWrapper>.class);
        Integer successRowCount              = 0; //used to count the number of rows sucessfully inserted
        Integer errorRowCount                = 0; //used to count the number of rows that got failed
        String errMsg; //used to assign error for csv file data
        Map<String,String> productCodeWithIdMap = new Map<String,String>(); //used to store ProductId against Product name
        List<Product2> prdList=[Select Id,Name,ProductCode,ExternalId From Product2 WHERE IsActive=true];
        system.debug('prdList=>'+prdList);
        if(prdList.size()>0){
            for(Product2 prd :prdList){
                productCodeWithIdMap.put(prd.Name,prd.Id);
                system.debug('Inside=>'+productCodeWithIdMap);
            }
        }
        //FirstName,LastName,DateOfBirth,MobileNumber,EmailId,CustomerProfile,Constitution,LeadSource,ResidentialCity,Product,ProductSubType,RequestedTenureInMonths,RequestedLoanAmount
        list<string> constitutionPickVal = getPicklistValues('Lead','Constitution__c');
        list<string> CustomerProfilePickVal = getPicklistValues('Lead','Customer_Profile__c');
        list<string> leadSourcePickVal = getPicklistValues('Lead','LeadSource');
        //  list<string> leadSourcePickVal = getPicklistValues('Lead','LeadSource');
        
        //Iterating wrapper and prepare lead records
        integer rowcount = 1;
        for(LeadGeneratorWrapper lgw : leadsList){
            system.debug('sub type=>'+lgw.ProductSubType);
            if(String.isNotBlank(lgw.ProductSubType)){
                system.debug('inside sub type=>'+lgw.ProductSubType);
                system.debug('map val=>'+productCodeWithIdMap.get(lgw.ProductSubType));
            }
            List<String> errorOccured  = new List<String> ();
            if( String.isBlank(lgw.MobileNumber) && String.isBlank(lgw.EmailId) && String.isBlank(lgw.Product) && (( (String.isBlank(lgw.LastName) && String.isNotBlank((lgw.Constitution.trim())) && (lgw.Constitution.trim()).toUpperCase() == 'INDIVIDUAL') &&  (String.isBlank(lgw.LastName) && String.isNotBlank((lgw.Constitution.trim())) && (lgw.Constitution.trim()).toUpperCase() != 'INDIVIDUAL')) ||  (String.isBlank(lgw.CompanyName) &&  String.isBlank((lgw.Constitution.trim())) && (lgw.Constitution.trim()).toUpperCase() != 'INDIVIDUAL' ) ) ){
                errorRowCount = errorRowCount + 1;
                errMsg='ALL_REQUIRED FIELDS MISSING';
                List<String> rowStr1 =assignRowValuesforReturnToFile(lgw,errMsg);
                errorStrMap.put('Row '+rowcount, errorStrMap.get('Row '+rowcount) !=null ?  errorStrMap.get('Row '+rowcount) +' , '+ errMsg : errMsg);
                csvRowValues.add(rowStr1);
                rowcount = rowcount+1;
                continue;
            }
            else{
                if(String.isBlank((lgw.FirstName.trim()))  &&  String.isBlank((lgw.Constitution.trim())) && (lgw.Constitution.trim()).toUpperCase() == 'INDIVIDUAL'){
                    errorRowCount = errorRowCount + 1;
                    errMsg='REQUIRED_FIELD_MISSING: Required fields are missing: [FirstName]';
                    List<String> rowStr1 =assignRowValuesforReturnToFile(lgw,errMsg);
                    errorOccured =  updateErrorMsz(errorOccured,rowStr1);
                    errorStrMap.put('Row '+rowcount, errorStrMap.get('Row '+rowcount) !=null ?  errorStrMap.get('Row '+rowcount) +' , '+ errMsg : errMsg);
                    // errorOccured =  updateErrorMsz(errorOccured,errMsg);
                    // csvRowValues.add(rowStr1);
                    // continue;
                }
                if(!validateCharacterStringForNumbers((lgw.FirstName.trim())) &&  String.isNotBlank((lgw.Constitution.trim())) && (lgw.Constitution.trim()).toUpperCase() == 'INDIVIDUAL' ){
                    errorRowCount = errorRowCount + 1;
                    errMsg='FIRST_NAME_VALIDATION: [FirstName] can only contain alphabets';
                    List<String> rowStr2 = assignRowValuesforReturnToFile(lgw,errMsg);
                    
                    errorStrMap.put('Row '+rowcount, errorStrMap.get('Row '+rowcount) !=null ?  errorStrMap.get('Row '+rowcount) +' , '+ errMsg : errMsg);
                    errorOccured =  updateErrorMsz(errorOccured,rowStr2);
                    // csvRowValues.add(rowStr2);
                    // continue;
                }
                
                
                if(String.isBlank(lgw.LastName) &&  String.isNotBlank((lgw.Constitution.trim())) && (lgw.Constitution.trim()).toUpperCase() == 'INDIVIDUAL' ){
                    errorRowCount = errorRowCount + 1;
                    System.debug('Last name error added : '+ lgw.LastName +' : '+ (lgw.Constitution.trim()));
                    errMsg='REQUIRED_FIELD_MISSING: Required fields are missing: [LastName]' ;
                    List<String> rowStr3 = assignRowValuesforReturnToFile(lgw,errMsg);
                    errorOccured =  updateErrorMsz(errorOccured,rowStr3);
                    errorStrMap.put('Row '+rowcount, errorStrMap.get('Row '+rowcount) !=null ?  errorStrMap.get('Row '+rowcount) +' , '+ errMsg : errMsg);
                    // csvRowValues.add(rowStr3);
                    //    continue;
                }
                if(!validateCharacterStringForNumbers(lgw.LastName) && String.isNotBlank(lgw.LastName) &&  String.isBlank((lgw.Constitution.trim())) && (lgw.Constitution.trim()).toUpperCase() == 'INDIVIDUAL' ){
                    errorRowCount = errorRowCount + 1;
                    
                    errMsg='LAST_NAME_VALIDATION: [LastName] can only contain alphabets';
                    List<String> rowStr4 = assignRowValuesforReturnToFile(lgw,errMsg);
                    errorOccured =  updateErrorMsz(errorOccured,rowStr4);
                    errorStrMap.put('Row '+rowcount, errorStrMap.get('Row '+rowcount) !=null ?  errorStrMap.get('Row '+rowcount) +' , '+ errMsg : errMsg);
                    //csvRowValues.add(rowStr4);
                    // continue;
                }
                
                if(String.isBlank(lgw.MobileNumber)){
                    errorRowCount = errorRowCount + 1;
                    errMsg = 'REQUIRED_FIELD_MISSING: Required fields are missing: [MobileNumber]';
                    List<String> rowStr5 = assignRowValuesforReturnToFile(lgw,errMsg);
                    errorOccured =  updateErrorMsz(errorOccured,rowStr5);
                    errorStrMap.put('Row '+rowcount, errorStrMap.get('Row '+rowcount) !=null ?  errorStrMap.get('Row '+rowcount) +' , '+ errMsg : errMsg);
                    // csvRowValues.add(rowStr5);
                    // continue;
                }
                if(lgw.MobileNumber.length() != 10 ){
                    errorRowCount = errorRowCount + 1;
                    errMsg='MOBILE_NUMBER_VALIDATION: [MobileNumber] should be 10 digit';
                    List<String> rowStr6 = assignRowValuesforReturnToFile(lgw,errMsg);
                    errorOccured =  updateErrorMsz(errorOccured,rowStr6);
                    errorStrMap.put('Row '+rowcount, errorStrMap.get('Row '+rowcount) !=null ?  errorStrMap.get('Row '+rowcount) +' , '+ errMsg : errMsg);
                    // csvRowValues.add(rowStr6);
                    // continue;
                }
                if(!validateMobileForNumbers(lgw.MobileNumber)){
                    errorRowCount = errorRowCount + 1;
                    errMsg='MOBILE_NUMBER_VALIDATION: [MobileNumber] cannot contain alpha-numeric values';
                    List<String> rowStr7 = assignRowValuesforReturnToFile(lgw,errMsg);
                    errorOccured =  updateErrorMsz(errorOccured,rowStr7);
                    errorStrMap.put('Row '+rowcount, errorStrMap.get('Row '+rowcount) !=null ?  errorStrMap.get('Row '+rowcount) +' , '+ errMsg : errMsg);
                    // csvRowValues.add(rowStr7);
                    // continue;
                }
                if(String.isNotBlank(lgw.MobileNumber) && validateMobileForStartingNumber(lgw.MobileNumber)){
                    errorRowCount = errorRowCount + 1;
                    errMsg='MOBILE_NUMBER_VALIDATION: [MobileNumber] cannot start with number 0-5';
                    List<String> rowStr8 = assignRowValuesforReturnToFile(lgw,errMsg);
                    errorOccured =  updateErrorMsz(errorOccured,rowStr8);
                    errorStrMap.put('Row '+rowcount, errorStrMap.get('Row '+rowcount) !=null ?  errorStrMap.get('Row '+rowcount) +' , '+ errMsg : errMsg);
                    // csvRowValues.add(rowStr8);
                    //continue;
                }
                if(String.isNotBlank(lgw.DateOfBirth) && !isValidDateFormat(lgw.DateOfBirth)){
                    System.debug('date of birth error occur ::'+lgw.DateOfBirth+ '::  ');
                    errorRowCount = errorRowCount + 1;
                    errMsg='DATE_OF_BIRTH_VALIDATION: [DateOfBirth] is not in correct format (dd/mm/yyyy)/(dd/mm/yy)/(yyyy-mm-dd) ';
                    List<String> rowStr9 = assignRowValuesforReturnToFile(lgw,errMsg);
                    errorOccured =  updateErrorMsz(errorOccured,rowStr9);
                    errorStrMap.put('Row '+rowcount, errorStrMap.get('Row '+rowcount) !=null ?  errorStrMap.get('Row '+rowcount) +' , '+ errMsg : errMsg);
                    // csvRowValues.add(rowStr9);
                    // continue;
                }
                if(String.isNotBlank(lgw.DateOfIncorporation) && !isValidDateFormat(lgw.DateOfIncorporation)){
                    errorRowCount = errorRowCount + 1;
                    errMsg='DATE_OF_INCORPORATION: [DateOfIncorporation] is not in correct format (dd/mm/yyyy)/(dd/mm/yy)/(yyyy-mm-dd) ';
                    List<String> rowStr10 = assignRowValuesforReturnToFile(lgw,errMsg);
                    errorOccured =  updateErrorMsz(errorOccured,rowStr10);
                    errorStrMap.put('Row '+rowcount, errorStrMap.get('Row '+rowcount) !=null ?  errorStrMap.get('Row '+rowcount) +' , '+ errMsg : errMsg);
                    // csvRowValues.add(rowStr10);
                    // continue;
                }
                if(String.isNotBlank(lgw.EmailId) && !validateEmail(lgw.EmailId)){
                    errorRowCount = errorRowCount + 1;
                    errMsg='EMAIL_VALIDATION:[EMAIL] not valid';
                    List<String> rowStr16 = assignRowValuesforReturnToFile(lgw,errMsg);
                    errorOccured =  updateErrorMsz(errorOccured,rowStr16);
                    errorStrMap.put('Row '+rowcount, errorStrMap.get('Row '+rowcount) !=null ?  errorStrMap.get('Row '+rowcount) +' , '+ errMsg : errMsg);
                    // csvRowValues.add(rowStr16);
                    // continue;
                }
                if( !constitutionPickVal.contains((lgw.Constitution.trim()).toUpperCase() )){
                    errorRowCount = errorRowCount + 1;
                    System.debug('error is '+constitutionPickVal +' ..  '+ (lgw.Constitution.trim()).toUpperCase() );
                    errMsg='CONSTITUTION: [Constitution]: Constitution Value is not correct';
                    List<String> rowStr17 = assignRowValuesforReturnToFile(lgw,errMsg);
                    errorOccured =  updateErrorMsz(errorOccured,rowStr17);
                    errorStrMap.put('Row '+rowcount, errorStrMap.get('Row '+rowcount) !=null ?  errorStrMap.get('Row '+rowcount) +' , '+ errMsg : errMsg);
                    // csvRowValues.add(rowStr17);
                    //continue;
                }
                if(!CustomerProfilePickVal.contains((lgw.CustomerProfile.trim()).toUpperCase())){
                    errorRowCount = errorRowCount + 1;
                    errMsg='COSTOMER_PROFILE: [CustomerProfile]: CustomerProfile Value is not correct';
                    List<String> rowStr18 = assignRowValuesforReturnToFile(lgw,errMsg);
                    errorOccured =  updateErrorMsz(errorOccured,rowStr18);
                    errorStrMap.put('Row '+rowcount, errorStrMap.get('Row '+rowcount) !=null ?  errorStrMap.get('Row '+rowcount) +' , '+ errMsg : errMsg);
                    // csvRowValues.add(rowStr18);
                    // continue;
                }
                if(String.isBlank(lgw.CompanyName) &&  String.isNotBlank((lgw.Constitution.trim())) && (lgw.Constitution.trim()).toUpperCase() != 'INDIVIDUAL' ){
                    errorRowCount = errorRowCount + 1;
                    errMsg='REQUIRED_FIELD_MISSING: Required fields are missing: [CompanyName]';
                    List<String> rowStr15 = assignRowValuesforReturnToFile(lgw,errMsg);
                    errorOccured =  updateErrorMsz(errorOccured,rowStr15);
                    errorStrMap.put('Row '+rowcount, errorStrMap.get('Row '+rowcount) !=null ?  errorStrMap.get('Row '+rowcount) +' , '+ errMsg : errMsg);
                    // csvRowValues.add(rowStr15);
                    // continue;
                }
                if(String.isBlank(lgw.Product)){
                    errorRowCount = errorRowCount + 1;
                    errMsg='REQUIRED_FIELD_MISSING: Required fields are missing: [Product]';
                    List<String> rowStr1 =assignRowValuesforReturnToFile(lgw,errMsg);
                    errorOccured =  updateErrorMsz(errorOccured,rowStr1);
                    errorStrMap.put('Row '+rowcount, errorStrMap.get('Row '+rowcount) !=null ?  errorStrMap.get('Row '+rowcount) +' , '+ errMsg : errMsg);
                    // csvRowValues.add(rowStr1);
                    //continue;
                }
                rowcount = rowcount + 1;
            }
            
            if(errorOccured.size()>0 ){
                csvRowValues.add(errorOccured);
                continue;
            }
            else{
                goForSaveValues.add(lgw);
                //assigning value in single lead object
                Lead ld =new Lead();
                
                
                
                ld.MobilePhone=lgw.MobileNumber;
                ld.Email=lgw.EmailId;
                
                ld.Bulk_Lead__c=true;
                ld.Status='New';
                ld.Product__c=lgw.Product;
                
                
                
                //address CompanyName,NameOfKeyman/AuthorisedIndividual,DateOfIncorporation,OfficeAddressCity
                if((lgw.Constitution.trim()).toUpperCase() != 'INDIVIDUAL'){
                    ld.LastName=lgw.CompanyName;
                    ld.City =  lgw.OfficeAddressCity;
                    ld.Company = lgw.CompanyName.toUpperCase();
                    ld.KeymanName__c = lgw.NameOfKeyman_AuthorisedIndividual.toUpperCase();
                    ld.DOI__c = String.isNotBlank(lgw.DateOfIncorporation)? convertDateToFormat(lgw.DateOfIncorporation):null;//shek added
                }else{
                    ld.DOB__c = String.isNotBlank(lgw.DateOfBirth)? convertDateToFormat(lgw.DateOfBirth):null;
                    ld.City  = lgw.ResidentialCity;
                    ld.FirstName =(lgw.FirstName.trim()).toUpperCase();
                    ld.LastName=lgw.LastName.toUpperCase();
                }
                ld.Customer_Profile__c=(lgw.CustomerProfile.trim()).toUpperCase();
                ld.Constitution__c = (lgw.Constitution.trim()).toUpperCase();
                ld.LeadSource=leadSourcePickVal.contains(lgw.LeadSource)?lgw.LeadSource:null; // only DSA /CONNECTOR
                ld.Requested_loan_amount__c=String.isNotBlank(lgw.RequestedLoanAmount)?Double.Valueof(lgw.RequestedLoanAmount):null;// Decimal.valueOf(currencyString)
                ld.Requested_tenure_in_Months__c=String.isNotBlank(lgw.RequestedTenureInMonths)?Integer.Valueof(lgw.RequestedTenureInMonths):null;
                // ld.Property_Identified__c=lgw.PropertyIdentified;
                
                leadsToInsert.add(ld);
            }
        }
        
        List<Database.SaveResult> saveResult = Database.insert(leadsToInsert, false);
        System.debug('saveResult: ' + saveResult);
        string errorString ='123';
        for(Integer k = 0; k < saveResult.size(); k++){
            if (saveResult[k].isSuccess()) {
                //Operation was successful.
                successRowCount = successRowCount + 1;
                String msg='Success';
                List<String> rowStr = assignRowValuesforReturnToFile(goForSaveValues.get(k),msg);
                csvRowValues.add(rowStr);
                system.debug('rowStr=>'+rowStr);
                errorString = 'error 123565';
            }
            else {
                
                //Operation failed, so get all errors
                errorRowCount = errorRowCount + 1;
                for(Database.Error err : saveResult[k].getErrors()) {
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    String errorMessage=err.getStatusCode() + ': ' + err.getMessage();
                    List<String> rowStr0 = assignRowValuesforReturnToFile(goForSaveValues.get(k),errorMessage);
                    errorString = 'error 123';
                    csvRowValues.add(rowStr0);
                }
            }
        }
        
        ResponseWrapper response = new ResponseWrapper(successRowCount, errorRowCount, csvRowValues, errorStrMap);
        System.debug('csvRowValues: ' + csvRowValues);System.debug('response: ' + response);
        
        return response;
    }
    private static List<String> updateErrorMsz (List<String> errorListOld , List<String> errorListNew){
        
        if(errorListOld.size()>0 ){
            errorListOld[0] = errorListOld[0] + ' ; '+ errorListNew[0];
            return  errorListOld;
        }else{
            return  errorListNew;
        }
        
        
        
        
    }
    
    //This method returning list<String> to add a list for download log file
    private static List<string> assignRowValuesforReturnToFile(LeadGeneratorWrapper ldGenWrap, String errorMsg){
        List<String> listRowString =new List<String>();
        listRowString.add(errorMsg);
        listRowString.add(ldGenWrap.FirstName);
        listRowString.add(ldGenWrap.LastName);
        listRowString.add(ldGenWrap.DateOfBirth);
        listRowString.add(ldGenWrap.MobileNumber);
        listRowString.add(ldGenWrap.EmailId);
        listRowString.add(ldGenWrap.CustomerProfile);
        listRowString.add(ldGenWrap.Constitution);
        listRowString.add(ldGenWrap.CompanyName);
        listRowString.add(ldGenWrap.NameOfKeyman_AuthorisedIndividual);
        listRowString.add(ldGenWrap.DateOfIncorporation);
        listRowString.add(ldGenWrap.OfficeAddressCity);
        listRowString.add(ldGenWrap.LeadSource);
        listRowString.add(ldGenWrap.ResidentialCity);
        listRowString.add(ldGenWrap.Product);
        listRowString.add(ldGenWrap.ProductSubType);
        listRowString.add(ldGenWrap.RequestedTenureInMonths);
        listRowString.add(ldGenWrap.RequestedLoanAmount);
        
        return listRowString;
    }
    
    //This method checking for Mobile Number is only number or not
    private static Boolean validateMobileForNumbers(String mobNum){
        try{
            return mobNum.isNumeric();
        }
        catch(Exception e){
            return false;
        }
    }
    
    //This method checking for Mobile Number starts with [0-5]
    private static Boolean validateMobileForStartingNumber(String mobNum){
        Set<String> numberList = new Set<String>{'0', '1', '2', '3', '4','5'};
        try{
            return  numberList.contains(mobNum.left(1));
        }
        catch(Exception e){
            return false;
        }
    }
    //This method checking for date Format
    // public static Boolean isValidDateFormat(String dateString) {
        
        //     Date dateValue;
        
        //     try {
            //         // Try parsing ISO format (yyyy-MM-dd)
            //           dateValue = Date.valueOf(dateString);
            //           return true;
        //     } catch (Exception e) {
            //         try {
                //             // Try parsing MM/dd/yyyy format
                //               dateValue = Date.parse(dateString);
                //               return true;
            //         } catch (Exception ex) {
                //             // Handle the case where the date format is invalid
                //             return false;
                //           //  throw new IllegalArgumentException('Invalid date format: ' + dateStr);
            //         }
        //     }
    // }
    
    
    
    
    // public static Boolean isValidDateFormat(String dateString) {
        //     if (dateString == null || dateString =='') {
            //         System.debug('Null value  return '+dateString );
            //         return false;
        //     }
        
        //     // Check ISO format (yyyy-MM-dd)
        //     try {
            //         Date.valueOf(dateString);
            //         System.debug(' Date.valueOf(dateString)'+dateString );
            //         return true;
        //     } catch (Exception e) {
            //         // ISO format parsing failed, continue to other formats
        //     }
        
        //     // Check MM/dd/yyyy format
        //     return isValidMMddyyyy(dateString);
    // }
    
    // private static Boolean isValidMMddyyyy(String dateString) {
        //     if (dateString == null ||  dateString =='') {
            //         System.debug('Null value in isValidMMddyyyy return  '+dateString );
            //         return false;
        //     }
        
        //     String regexFullYear = '^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/\\d{4}$';
        // // Regular expression to match MM/dd/yy format
        // String regexShortYear = '^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/(0[0-9]|[1-9][0-9])$';
        
        // Pattern patternFullYear = Pattern.compile(regexFullYear);
        // Matcher matcherFullYear = patternFullYear.matcher(dateString);
        
        // Pattern patternShortYear = Pattern.compile(regexShortYear);
        // Matcher matcherShortYear = patternShortYear.matcher(dateString);
        // if (!matcherFullYear.matches() ) {
            //     System.debug('Pattern mismatch matcherFullYear : ' + dateString);
            //    // return false;
        // }
        // if (!matcherShortYear.matches()) {
            //     System.debug('Pattern mismatch matcherShortYear : ' + dateString);
            //    // return false;
        // }
        
        
        // if (!matcherFullYear.matches() && !matcherShortYear.matches()) {
            //     System.debug('Pattern mismatch: ' + dateString);
            //     return false;
        // }
        //     // Further validate the date to handle cases like 02/30/yyyy
        //     try {
            //         Date parsedDate = null;
            //             if (matcherFullYear.matches()) {
                //                 parsedDate = Date.parse(dateString);
            //             } else if (matcherShortYear.matches()) {
                //                 // Convert to full year format for parsing (assuming a range for the century)
                //                 String[] parts = dateString.split('/');
                //                 Integer year = Integer.valueOf(parts[2]);
                //                 if (year < 100) {
                    //                     year += (year < 50) ? 2000 : 1900; // Simple logic to determine the full year
                //                 }
                //                 parsedDate = Date.newInstance(year, Integer.valueOf(parts[0]), Integer.valueOf(parts[1]));
            //             }
            
            //     System.debug('Parsed date: ' + parsedDate);
            //     return true;
        //     } catch (Exception e) {
            //         System.debug('exception final   '+e );
            //         return false;
        //     }
    // }
    // public static Date convertDateToFormat(String dateStr) {
        //     Date dateValue;
        
        //     // Try parsing the date in different formats
        //     try {
            //         // Try parsing ISO format (yyyy-MM-dd)
            //         dateValue = Date.valueOf(dateStr);
        //     } catch (Exception e) {
            //         try {
                //             // Try parsing MM/dd/yyyy format
                //             dateValue = Date.parse(dateStr);
                
            //         } catch (Exception ex) {
                
                //             try {
                    //                 Date parsedDate = null;
                    
                    //                 // Convert to full year format for parsing (assuming a range for the century)
                    //                 String[] parts = dateStr.split('/');
                    //                 Integer year = Integer.valueOf(parts[2]);
                    //                 if (year < 100) {
                        //                     year += (year < 50) ? 2000 : 1900; // Simple logic to determine the full year
                    //                 }
                    //                 parsedDate = Date.newInstance(year, Integer.valueOf(parts[0]), Integer.valueOf(parts[1]));
                    
                    
                    //             System.debug('Parsed date: ' + parsedDate);
                    //             dateValue = parsedDate;
                    //             //return true;
                //             }
                //             catch (Exception exc) {
                    //                  // Handle the case where the date format is invalid
                    //                 throw new IllegalArgumentException('Invalid date format: ' + dateStr);
                //             }
            //         }
        //     }
        
        //     // Format the date to MM/dd/yyyy
        //     return dateValue;
    // }
    
    // private static Date formatDateToMMDDYYYY(Date dateValue) {
        //     if (dateValue == null) {
            //         return null ;
        //     }
        
        //     // Extract day, month, and year
        //     Integer day = dateValue.day();
        //     Integer month = dateValue.month();
        //     Integer year = dateValue.year();
        //     System.debug('date is  '+ day + month+ year);
        
        //     // Format the date as MM/dd/yyyy manually
        //     String formattedDate = (month < 10 ? '0' + string.valueOf(month) : string.valueOf(month)) + '/' +
        //                            (day < 10 ? '0' + string.valueOf(day) : string.valueOf(day)) + '/' +
        //                            year;
        //     return Date.parse(formattedDate);
    // }
    
    
    public static boolean isValidDateFormat(String dateString){
        try {
            Date dateValue = convertDateToFormat(dateString);
            System.debug('Converted Date: ' + dateValue);
            
            dateValue = convertDateToFormat(dateString);//('20-06-1992');
            System.debug('Converted Date: ' + dateValue);
            return true;
        } catch (IllegalArgumentException e) {
            return false;
        }
        
    }
    public static Date convertDateToFormat(String dateString) {
        if (String.isBlank(dateString)) {
            throw new IllegalArgumentException('Date string cannot be null or empty.');
        }
        
        Date parsedDate;
        
        // Check for dd/MM/yyyy format
        String regexSlashFormat = '^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/\\d{4}$';
        Pattern patternSlash = Pattern.compile(regexSlashFormat);
        Matcher matcherSlash = patternSlash.matcher(dateString);
        
        // Check for dd-MM-yyyy format
        String regexDashFormat = '^(0[1-9]|[12][0-9]|3[01])-(0[1-9]|1[0-2])-\\d{4}$';
        Pattern patternDash = Pattern.compile(regexDashFormat);
        Matcher matcherDash = patternDash.matcher(dateString);
        
        if (matcherSlash.matches()) {
            // Convert dd/MM/yyyy to Date
            String[] parts = dateString.split('/');
            parsedDate = Date.newInstance(Integer.valueOf(parts[2]), Integer.valueOf(parts[1]), Integer.valueOf(parts[0]));
        } else if (matcherDash.matches()) {
            // Convert dd-MM-yyyy to Date
            String[] parts = dateString.split('-');
            parsedDate = Date.newInstance(Integer.valueOf(parts[2]), Integer.valueOf(parts[1]), Integer.valueOf(parts[0]));
        } else {
            throw new IllegalArgumentException('Invalid date format. Expected formats: dd/MM/yyyy or dd-MM-yyyy.');
        }
        
        return parsedDate;
    }
    
    
    
    
    //This method checking for any character string (ie. First Name, Last Name, Middle Name) contains any number or special character
    private static Boolean validateCharacterStringForNumbers(String cString){
        try{
            return cString.isAlpha();
        }
        catch(Exception e){
            return false;
        }
    }
    // public class DateConverterDDMMYY {
        //     public static Date convertStringToDate(String dateString) {
            //         // Check if the input string is in the expected format
            //         if (dateString.length() != 8 || dateString[2] != '/' || dateString[5] != '/') {
                //             throw new IllegalArgumentException('Date must be in DD/MM/YY format');
            //         }
            
            //         // Extract day, month, and year from the string
            //         String dayString = dateString.substring(0, 2);
            //         String monthString = dateString.substring(3, 5);
            //         String yearString = dateString.substring(6, 8);
            
            //         // Convert to integers
            //         Integer day = Integer.valueOf(dayString);
            //         Integer month = Integer.valueOf(monthString);
            //         Integer year = Integer.valueOf(yearString);
            
            //         // Adjust year to four digits
            //         year += (year < 50) ? 2000 : 1900;
            
            //         // Create and return the Date object
            //         return Date.newInstance(year, month, day);
        //     }
    // }
    
    
    //This method checking for Email validation
    private static Boolean validateEmail(String emailString){
        String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
        Pattern regxPattern = Pattern.compile(emailRegex);
        Matcher emailMatcher = regxPattern.matcher(emailString);
        try{
            return emailMatcher.matches();
        }
        catch(Exception e){
            return false;
        }
    }
    //This method returns Picklist vaue in list of string of a field
    public static List<String> getPicklistValues(String objectName, String fieldName) {
        List<String> picklistValues = new List<String>();
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeFieldResult fieldResult = sObjectType.getDescribe().fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry entry : picklistEntries) {
            picklistValues.add(entry.getLabel());
        }
        System.debug(' pick vals '+objectName + '  >> '+fieldName+'  == '+picklistValues);
        return picklistValues;
    }
    
    public class LeadGeneratorWrapper{
        public LeadGeneratorWrapper(String firstName, String lastName,string dateOfBirth ,
        String mobileNumber,String emailId,string customerProfile,
        string constitution,string companyName,
        string nameOfKeyman_AuthorisedIndividual,
        string dateOfIncorporation,string officeAddressCity,
        string leadSource,string residentialCity,string product,
        string productSubType,string requestedTenureInMonths,
        string requestedLoadAmount
        ){
            this.FirstName    = firstName;
            this.LastName     = lastName;
            this.DateOfBirth = dateOfBirth;
            this.MobileNumber = mobileNumber;
            this.EmailId      = emailId;
            this.ResidentialCity      = residentialCity;
            this.AlternativeMobileNumber = alternativeMobileNumber;
            this.CustomerProfile = customerProfile;
            this.Constitution = constitution;
            this.LeadSource      = leadSource;
            this.CompanyName  = companyName;
            this.NameOfKeyman_AuthorisedIndividual = nameOfKeyman_AuthorisedIndividual;
            this.DateOfIncorporation  = dateOfIncorporation;
            this.OfficeAddressCity      = officeAddressCity;
            this.ResidentialAddress   = residentialAddress;
            this.Pincode = pincode;
            this.Product = product;
            this.ProductSubType = productSubType;
            this.RequestedTenureInMonths = requestedTenureInMonths;
            this.RequestedLoanAmount = requestedLoanAmount;
        }
        
        @AuraEnabled public String FirstName;
        @AuraEnabled public String MiddleName;
        @AuraEnabled public String LastName;
        @AuraEnabled public String DateOfBirth;
        @AuraEnabled public String MobileNumber;
        @AuraEnabled public String EmailId;
        @AuraEnabled public String Constitution;
        @AuraEnabled public String ResidentialCity;
        @AuraEnabled public String AlternativeMobileNumber;
        @AuraEnabled public String CustomerProfile;
        @AuraEnabled public String LeadSource;
        @AuraEnabled public String ResidentialAddress;
        @AuraEnabled public String Pincode;
        @AuraEnabled public String CompanyName;
        @AuraEnabled public String NameOfKeyman_AuthorisedIndividual;
        @AuraEnabled public String DateOfIncorporation;
        @AuraEnabled public String OfficeAddressCity;
        @AuraEnabled public String Product;
        @AuraEnabled public String ProductSubType;
        @AuraEnabled public String RequestedTenureInMonths;
        @AuraEnabled public String RequestedLoanAmount;
        @AuraEnabled public String PropertyIdentified;
    }
    
    public class ResponseWrapper{
        
        public ResponseWrapper(Integer successRowCounter, Integer errorRowCounter, List<List<String>> csvData,map<string,string> errorString){
            this.successRowCounter = successRowCounter;
            this.errorRowCounter   = errorRowCounter;
            this.csvData           = csvData;
            this.errorString       = errorString;
            
        }
        @AuraEnabled public Integer successRowCounter;
        @AuraEnabled public Integer errorRowCounter;
        @AuraEnabled public List<List<String>> csvData;
        @AuraEnabled public map<string,string> errorString;
    }
    
}