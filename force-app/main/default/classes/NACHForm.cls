public class NACHForm {
    public List<Repayment_Account__c> repayAcc{get;set;}
    public List<RepayAccVerify__c> repayAccVerify{get;set;}
    public String nachID{get;set;}
    public String recordId{get;set;}
    public String rupeeInWord{get;set;}
    public List<String> splittedMandateDates{get;set;}
    public List<String> splittedUMRN{get;set;}
    public List<String> utilityCodes{get;set;}
    public List<String> splittedAccNumInDigits{get;set;}
    public List<String> splittedIFSC{get;set;}
    public List<String> splittedMICR{get;set;}
    public List<String> splittedEmiStartDate{get;set;}
    public List<String> splittedEmiEndDate{get;set;}
    public String mandateDate {get;set;}
    public String maxDebitType_img {get;set;}
    public String fixedDebitType_img {get;set;}
    public String monFreq_img {get;set;}
    public String qtlyFreq_img {get;set;}
    public String hYearlyFreq_img {get;set;}
    public String yearlyFreq_img {get;set;}
    public String otherFreq_img {get;set;}
    public String sbDebit_img {get;set;}
    public String caccDebit_img {get;set;}
    public String amountInWords {get;set;}
    public Boolean isDebit {get;set;}
    public Boolean isCA_CC {get;set;}
    public Boolean isHDFCBank {get;set;}
    public String accHolderName {get;set;}

     
    public NACHForm(){
        isHDFCBank = false;
        isDebit = false;
        isCA_CC = true;
        repayAcc = new List<Repayment_Account__c>();
        repayAccVerify = new List<RepayAccVerify__c>();
        splittedMandateDates = new List<String>();
        splittedUMRN = new List<String>();
        utilityCodes = new List<String>();
        splittedAccNumInDigits = new List<String>();
        splittedIFSC = new List<String>();
        splittedMICR = new List<String>();
        splittedEmiStartDate = new List<String>();
        splittedEmiEndDate = new List<String>();
        monFreq_img = URL.getSalesforceBaseUrl().toExternalForm()+''+PageReference.forResource('Blank_Check_box').getUrl(); 
        qtlyFreq_img = URL.getSalesforceBaseUrl().toExternalForm()+''+PageReference.forResource('Blank_Check_box').getUrl();
        hYearlyFreq_img = URL.getSalesforceBaseUrl().toExternalForm()+''+PageReference.forResource('Blank_Check_box').getUrl();
        yearlyFreq_img = URL.getSalesforceBaseUrl().toExternalForm()+''+PageReference.forResource('Blank_Check_box').getUrl();
        otherFreq_img = URL.getSalesforceBaseUrl().toExternalForm()+''+PageReference.forResource('Blank_Check_box').getUrl();
        sbDebit_img = URL.getSalesforceBaseUrl().toExternalForm()+''+PageReference.forResource('Blank_Check_box').getUrl();
        caccDebit_img = URL.getSalesforceBaseUrl().toExternalForm()+''+PageReference.forResource('Blank_Check_box').getUrl();
        
        recordId=ApexPages.currentPage().getParameters().get('recordId');
        if(recordId==null){
            recordId = ApexPages.currentPage().getParameters().get('Id'); 
            System.debug('recordId***rk '+recordId);
        }
        if(recordId!=null){
            System.debug('recordId***rk '+recordId);
            getBankDetails();             
        }
        
    } 
    
    @testVisible
    private void getBankDetails(){
        repayAcc = [SELECT Id,Account_Number__c,Applicant_Banking__r.BankName__c,IFSC_Code__c,MICR_Code__c,Applicant_Banking__r.LoanAppl__r.EMIIcludingInsurance__c,
                    Loan_Application__r.Repayment_Frequency__c,Debit_Type__c,Loan_Application__r.FinnoneAppid__c,Applicant_Banking__r.Appl__r.EmailId__c,
                    Applicant_Banking__r.Appl__r.MobNumber__c,Loan_Application__r.FirstEMIDate__c,Applicant_Banking__r.AccountType__c,AccHolderName__c 
                    FROM Repayment_Account__c WHERE Id =: recordId LIMIT 1];
        
        repayAccVerify = [SELECT Id,NameRetuFromPennyDrop__c,RepayAcc__c FROM RepayAccVerify__c WHERE RepayAcc__c =: recordId AND NameRetuFromPennyDrop__c != null LIMIT 1];
        
        //System.debug('nachID** '+nachID);
        System.debug('Repayment Account Record ##69** '+repayAcc);
        System.debug('Repayment Account Verify Record ##70** '+repayAccVerify);
        
        // if(nach.UMRN__c != null){
        //     splittedUMRN = String.valueOf(nach.UMRN__c).split('');  
        // }

        accHolderName = repayAccVerify.size()> 0 && String.isNotBlank(repayAccVerify[0].NameRetuFromPennyDrop__c) ? repayAccVerify[0].NameRetuFromPennyDrop__c : repayAcc[0].AccHolderName__c;

        if(!String.isBlank(repayAcc[0].Applicant_Banking__r.BankName__c) && repayAcc[0].Applicant_Banking__r.BankName__c.contains(System.Label.NACH_HDFC_Bank)){
            isHDFCBank = true;
        }
        
        if(repayAcc[0].Applicant_Banking__r.LoanAppl__r.EMIIcludingInsurance__c != null){
            repayAcc[0].Applicant_Banking__r.LoanAppl__r.EMIIcludingInsurance__c = repayAcc[0].Applicant_Banking__r.LoanAppl__r.EMIIcludingInsurance__c * 2 ;
            amountInWords = NumberToStringConverter.convertToWords(Integer.valueOf(repayAcc[0].Applicant_Banking__r.LoanAppl__r.EMIIcludingInsurance__c));
        }else{
            amountInWords =''; 
        }

        date d = system.today(); 
        if(d.day()<10){
            mandateDate = '0'+d.day();
        }else{
            mandateDate = ''+d.day();
        }
        if(d.month()<10){
            mandateDate = mandateDate + '0'+d.month();
        }else{
            mandateDate = mandateDate + ''+d.month();
        }
        mandateDate = mandateDate + d.year();
        splittedMandateDates = mandateDate.split('');

        if(repayAcc[0].IFSC_Code__c !=null){
            splittedIFSC.addAll(repayAcc[0].IFSC_Code__c.split(''));
        }
        
        if(repayAcc[0].MICR_Code__c !=null){
            splittedMICR = new List<String>();
            if(repayAcc[0].MICR_Code__c !=null){ 
                splittedMICR.addAll(repayAcc[0].MICR_Code__c.split(''));
            } 
        }
        
        if(repayAcc[0].Loan_Application__r.FirstEMIDate__c != null){
            String frDate;
            String endDate;
            date existingDate  = date.valueOf(repayAcc[0].Loan_Application__r.FirstEMIDate__c); 
            date fromDate = existingDate;
            Date end_Date = fromDate.addYears(29);
            end_Date = end_Date.addMonths(6); 

            if(fromDate.day()<10){
                frDate = '0'+fromDate.day();  
            }else{
                frDate = ''+fromDate.day(); 
            }
            if(fromDate.month()<10){
            	frDate = frDate + '0'+fromDate.month();
            }else{
                frDate = frDate + ''+fromDate.month();
            }
            if(end_Date.day()<10){
                endDate = '0'+end_Date.day();  
            }else{
                endDate = ''+end_Date.day(); 
            }
            if(end_Date.month()<10){
            	endDate = endDate + '0'+end_Date.month();
            }else{
                endDate = endDate + ''+end_Date.month();
            }
            frDate = frDate + fromDate.year();
            splittedEmiStartDate = frDate.split('');  
            endDate = endDate + end_Date.year();
            splittedEmiEndDate =  endDate.split('');            
        }
          
        if(repayAcc[0].Account_Number__c != null){
            splittedAccNumInDigits = String.valueOf(repayAcc[0].Account_Number__c).split('');
        }
        
        if(repayAcc[0].Debit_Type__c == 'Maximum Amount'){ 
            maxDebitType_img = URL.getSalesforceBaseUrl().toExternalForm()+''+PageReference.forResource('Right_Checked_Checkbox').getUrl();
            fixedDebitType_img = URL.getSalesforceBaseUrl().toExternalForm()+''+PageReference.forResource('Blank_Check_box').getUrl();
        }else{
            maxDebitType_img = URL.getSalesforceBaseUrl().toExternalForm()+''+PageReference.forResource('Blank_Check_box').getUrl();
            fixedDebitType_img = URL.getSalesforceBaseUrl().toExternalForm()+''+PageReference.forResource('Right_Checked_Checkbox').getUrl();
        }
        if(repayAcc[0].Loan_Application__r.Repayment_Frequency__c == 'M'){
            monFreq_img = URL.getSalesforceBaseUrl().toExternalForm()+''+PageReference.forResource('Right_Checked_Checkbox').getUrl(); 
        }else if(repayAcc[0].Loan_Application__r.Repayment_Frequency__c == 'Q'){
            qtlyFreq_img = URL.getSalesforceBaseUrl().toExternalForm()+''+PageReference.forResource('Right_Checked_Checkbox').getUrl();            
        }else if(repayAcc[0].Loan_Application__r.Repayment_Frequency__c == 'H'){
            hYearlyFreq_img = URL.getSalesforceBaseUrl().toExternalForm()+''+PageReference.forResource('Right_Checked_Checkbox').getUrl();
        }else if(repayAcc[0].Loan_Application__r.Repayment_Frequency__c == 'A'){
            yearlyFreq_img = URL.getSalesforceBaseUrl().toExternalForm()+''+PageReference.forResource('Right_Checked_Checkbox').getUrl();
        }else{
            otherFreq_img = URL.getSalesforceBaseUrl().toExternalForm()+''+PageReference.forResource('Right_Checked_Checkbox').getUrl();
        } 
        
        if(repayAcc[0].Applicant_Banking__r.AccountType__c == 'CC' || repayAcc[0].Applicant_Banking__r.AccountType__c == 'CURRENT'){
            isCA_CC = true;
            isDebit = false;
            caccDebit_img = URL.getSalesforceBaseUrl().toExternalForm()+''+PageReference.forResource('Right_Checked_Checkbox').getUrl(); 
        }else if(repayAcc[0].Applicant_Banking__r.AccountType__c == 'SAVINGS'){
            isDebit = true;
            isCA_CC = false;
            sbDebit_img = URL.getSalesforceBaseUrl().toExternalForm()+''+PageReference.forResource('Right_Checked_Checkbox').getUrl();            
        }
        
    }
    
}