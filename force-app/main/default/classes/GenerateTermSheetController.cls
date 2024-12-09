public class GenerateTermSheetController {
    
    public Id recordId { get; set; }
    public LoanAppl__c loanAppData { get; set; }
    public Applicant__c mainApplicant { get; set; }
    public List<Sanction_Conditions__c> sancon{ get; set; }
    public List<String> Coapplicant{ get; set; }
    public ApplAddr__c mainApplicantAddress { get; set; }
    public Map<integer,String> mapofContent{get;set;}
    public String sanctionDate{ get; set; }
    public String applicantsNames{get;set;}
    public String typeofFacility{get;set;}
    public String typeofInterest{get;set;}
    public String security{get;set;}
    public String processingFeeforDescription{get;set;}
    public String descriptionContent{get;set;}
    //LAK-9940 Start
    public Datetime localDateTime { get; set; }
    //LAK-9940 End
    
    public GenerateTermSheetController(){
        //recordId ='a08C4000008EVIkIAO';//ApexPages.currentPage().getParameters().get('recordId');
         recordId =ApexPages.currentPage().getParameters().get('recordId');
        if(recordId!=null){
            fetchData();
        }
    }
    
    public void fetchData(){
        
        try{
            
            Map<Id,SchMapping__c> schemaMap;
            integer propertyNumber=1;
            
            loanAppData=[Select id,Product__c,TotalLoanAmtInclInsurance__c,Loan_Tenure_Months__c,Rate_Type_Floating_Flag__c,EffectiveROI__c,
                         EMIIcludingInsurance__c,InsAmt__c,LatestSanctionDate__c,SchemeId__c,
                         (SELECT ID ,PF__C,Revised_PF__c FROM Loan_Application_Charges__r WHERE ChargeCodeID__c=:System.Label.PFChargeCodeId LIMIT 1)
                         from LoanAppl__c Where Id =:recordId];
            
            List<Applicant__c> applicants=[Select id,LoanAppln__c,ApplType__c,FullName__c,MobNumber__c,LoanAppln__r.Name,Title__c,
                                           (Select Id,Applicant__c,AddrTyp__c,MailAddr__c,Applicant__r.ApplType__c,
                                            FullAdrs__c,City__c,State__c,HouseNo__c,AddrLine1__c,AddrLine2__c,
                                            Landmark__c from Applicant_Addresses__r Where Applicant__r.ApplType__c='P'AND MailAddr__c=true)
                                           from Applicant__c Where LoanAppln__c =:recordId];
            
            if(String.isNotblank(loanAppData.SchemeId__c)){
                schemaMap =new Map<Id,SchMapping__c>([Select Id,SchemeDesc__c from SchMapping__c Where Id=:loanAppData.SchemeId__c]);
            }
            
            List<ApplAsset__c> assetList=[SELECT Id, Name,PropAddrs__c FROM ApplAsset__c where LoanAppln__c =:recordId];
            
             sancon=[SELECT Remarks__c, Condition__c, Id, Loan_Application__c FROM Sanction_Conditions__c
                                                 where Loan_Application__c =:recordId];
             //sancon=[SELECT  Condition__c, Id, Loan_Application__c FROM Sanction_Conditions__c
                                                //where Loan_Application__c =:recordId];
            //Looping Applicant
            if(!applicants.isEmpty()){
                
                for(Applicant__c app:applicants){
                    
                    if(app.ApplType__c=='P'){
                        mainApplicant=app; 
                        
                        
                        if (app.Applicant_Addresses__r != null && !app.Applicant_Addresses__r.isEmpty()) {
                            mainApplicantAddress = app.Applicant_Addresses__r[0];
                        }
                        
                    }
                    
                    else if(app.ApplType__c=='C'){
                        
                        if(Coapplicant==null){
                            Coapplicant =new List<String>(); 
                        }
                        
                        Coapplicant.add(app.FullName__c);
                        
                    }
                    
                    if(String.isnotBlank(app.Title__c)){
                        
                        applicantsNames=string.isNotblank(applicantsNames)?applicantsNames+', '+app.Title__c+''+app.FullName__c:app.Title__c+''+app.FullName__c;
                    }else{
                        applicantsNames=string.isNotblank(applicantsNames)?applicantsNames+', '+app.FullName__c:app.FullName__c;
                    }
                    
                    
                }
                
            }
            
            //assign values to variables
            if(loanAppData!=null){
                
                //to get Metadata
                if(String.isNotblank(loanAppData.Product__c)){
                    
                    for(PDF_Generation_Metadata__mdt pdfObj:[select id,Content_Order__c,Content__c,Document_Type__c,Product_Type__c 
                                                             from PDF_Generation_Metadata__mdt where Document_Type__c='Term Sheet' AND
                                                             Product_Type__c =:loanAppData.Product__c])
                    {
                        
                        if(mapofContent==null){
                            mapofContent =new Map<Integer,String>();
                        }
                        mapofContent.put(integer.valueof(pdfObj.Content_Order__c),pdfObj.Content__c);
                    }
                }
                
                //To display the Sanction Date
                if(loanAppData.LatestSanctionDate__c!=null){
                    
                    DateTime date1 = DateTime.newInstance(loanAppData.LatestSanctionDate__c.year(),loanAppData.LatestSanctionDate__c.month(),loanAppData.LatestSanctionDate__c.day());
                    sanctionDate=date1.format('dd-MMM-yyyy');
                }
                
                // concatenate product with SchemeId
                if(String.isNotblank(loanAppData.Product__c) && String.isNotblank(loanAppData.SchemeId__c) &&
                   schemaMap.containsKey(loanAppData.SchemeId__c)){
                       typeofFacility =loanAppData.Product__c+'+'+schemaMap.get(loanAppData.SchemeId__c).SchemeDesc__c;
                   }
                
                //to display Type of Interest
                if(String.isNotblank(loanAppData.Rate_Type_Floating_Flag__c)){
                    
                    typeofInterest=loanAppData.Rate_Type_Floating_Flag__c=='Y'?'Floating Rate of Interest':'Fixed Rate of Interest';
                    descriptionContent=loanAppData.Rate_Type_Floating_Flag__c=='Y'?mapofContent.get(4):mapofContent.get(5);
                }
                
                //Processing fees
                if(loanAppData.Loan_Application_Charges__r.size()>0 ){
                    
                    if(loanAppData.Loan_Application_Charges__r[0].Revised_PF__c==null){
                        
                        processingFeeforDescription=loanAppData.Loan_Application_Charges__r[0].PF__c!=null?String.valueof(loanAppData.Loan_Application_Charges__r[0].PF__c):'0';
                    }
                    else{
                        processingFeeforDescription=loanAppData.Loan_Application_Charges__r[0].Revised_PF__c!=null?String.valueof(loanAppData.Loan_Application_Charges__r[0].Revised_PF__c):'0';
                    }
                }
            }
            
            //Looping Applicant Assert
            if(!assetList.isEmpty()){
                
                if(assetList.size()==1){
                    
                    for(ApplAsset__c applAss:assetList){
                        
                        security=string.isNotblank(applAss.PropAddrs__c)?applAss.PropAddrs__c:'';
                    }
                    
                }
                else{
                    for(ApplAsset__c applAss:assetList){
                       
                        if(String.isNotblank(security) && String.isNotblank(applAss.PropAddrs__c)){
                            
                            security=security+'<br/>'+propertyNumber+'. '+applAss.PropAddrs__c;
                            propertyNumber++;
                        }
                        else{
                          
                            security=String.isNotblank(applAss.PropAddrs__c)?propertyNumber+'. '+applAss.PropAddrs__c:'';
                            propertyNumber++;
                        }
                    }
                }
            }
            
            // Get the user's time zone 
            // LAK-9940 Start
            TimeZone tz = UserInfo.getTimeZone();
            localDateTime = System.now().addSeconds(tz.getOffset(System.now()) / 1000);
            // LAK-9940 End
            
        }catch(Exception ex){
            System.debug('Error--'+ex.getMessage() + ' line--' + ex.getLineNumber());
        }
    }
}