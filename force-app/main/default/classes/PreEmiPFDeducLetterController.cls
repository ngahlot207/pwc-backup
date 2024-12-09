public class PreEmiPFDeducLetterController {
    transient public String recordId{get;set;}
    public LoanAppl__c loanApplRec { get; set; }
    public List<Applicant__c> applicantList { get; set; }
	public String productName { get; set; }
    public Decimal amount { get; set; }
    public String amountInWords { get; set; }
    transient public String CurrentDateTime{get;set;}
    transient public String CurrentDate{get;set;}
	transient public String City{get;set;}
    public PreEmiPFDeducLetterController() {
        recordId=ApexPages.currentPage().getParameters().get('recordId');
        if(recordId==null){
            recordId = 'a08C40000082ahBIAQ'; //a08C4000007P6asIAC//a08C4000007x0uSIAQ
            System.debug('recordId '+recordId);
        }
        loanApplRec= [select id,SanLoanAmt__c, TotalLoanAmtInclInsurance__c,product__c,Formatted_Login_Acceptance_Date__c,BrchName__c, ReqLoanAmt__c  from LoanAppl__c where id=:recordId LIMIT 1];
        productName = loanApplRec.product__c;
        amount = loanApplRec.TotalLoanAmtInclInsurance__c;
        amountInWords= numberToEnglish(Integer.valueOf(loanApplRec.TotalLoanAmtInclInsurance__c));
        applicantList =[select id,FullName__c, ApplType__c, Constitution__c from Applicant__c where LoanAppln__c=:recordId AND (ApplType__c ='C' OR ApplType__c ='p')];
        string ConstType;
        List<string> applIds= new List<string>();
        for(Applicant__c app:  applicantList){
            if(app.ApplType__c=='P'){
                ConstType=app.Constitution__c;
                applIds.add(app.Id);
            }
        }
        list<ApplAddr__c> appliAdds=[select id,AddrTyp__c,City__c from ApplAddr__c where Applicant__c IN: applIds];
        if(ConstType=='INDIVIDUAL'){
            for(ApplAddr__c appAdd:  appliAdds){
                if(appAdd.AddrTyp__c=='Residence Address'){
                  City= appAdd.City__c;
                }
            }
        }else{
            for(ApplAddr__c appAdd:  appliAdds){
                if(appAdd.AddrTyp__c=='Registered place for business'){
                  City= appAdd.City__c;
                }else if(appAdd.AddrTyp__c=='Principal place for business'){
                    City= appAdd.City__c;
                }
            }
        }
        this.setDateTime();
    }
    static String[] firstTwenty = new String[] { 'NIL','One','Two','Three','Four','Five','Six','Seven','Eight','Nine',
            'Ten','Eleven','Twelve','Thirteen','Fourteen','Fifteen','Sixteen','Seventeen','Eighteen','Ninteen' };
    static String[] tens = new String[] { '','','Twenty','Thirty','Forty','Fifty','Sixty','Seventy','Eighty','Ninety' };
    static String[] powers = new String[] { 'Crore','Lakh','Thousand','Hundred' };
    static Integer[] thresholds = new Integer[] { 100000000, 100000, 1000, 100 };

    static String[] convert(Integer value) {
        String[] result = new String[0];
        Boolean less20 = value < 20, less100 = value < 100;
        if(less20) {
            result.add(firstTwenty[value]);
        } else if(less100) {
            Integer tenValue = value / 10, oneValue = Math.mod(value, 10);
            result.add(tens[tenValue]);
            if(oneValue > 0) {
                result.add(firstTwenty[oneValue]);
            }
        }
        if(less100) {
            return result;
        }
        if(value > 0) {
            for(Integer index = 0; index < thresholds.size(); index++) {
                if(thresholds[index] <= value) {
                    result.addAll(convert(value / thresholds[index]));
                    result.add(powers[index]);
                    value = Math.mod(value, thresholds[index]);
                }
            }
            if(value > 0) {
                result.addAll(convert(value));
            }
        }
        return result;
    }
    public static String numberToEnglish(Integer value) {
        return value != null && value >= 0? String.join(convert(value),' '): '';
    }
    public void setDateTime()
    {
        DateTime dt = Datetime.now();
        CurrentDateTime=system.Now().format('dd-MMM-yyyy')+', '+system.Now().format('h:mm a');
        CurrentDate=system.Now().format('dd-MMM-yyyy');
    }
    
}