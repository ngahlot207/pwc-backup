public class BTApplicationPart1 {
	transient public String recordId{get;set;}
    transient public String header{get;set;}
    transient public String todaysDate{get;set;}
     transient public String CurrentDate{get;set;}
    transient public String ApplicantName{get;set;}
    transient public String FinnoneNumber{get;set;}
    transient public List<DOCWrapper> DocList{get;set;}
    transient public string loanApplicationId{get;set;}
    transient public List<getBorrowerDetailsWrapper> borrowerDetailsWrapper{get;set;}
    
    
     public BTApplicationPart1(){
         // recordId = loanApplicationId;
        recordId=ApexPages.currentPage().getParameters().get('recordId');
        if(recordId==null)
        {
            //recordId='a08C40000083Lt0IAE';
             recordId = ApexPages.currentPage().getParameters().get('Id');
        }
        if(recordId!=null)
        {
         setDateTime(); 
          getloanDetails(recordId);  
           getlodDetails(recordId);  
            borrowerDetailsWrapper=getBorrowerDetails(recordId);
        }
    }
    public void setDateTime()
    {
        DateTime dt = Datetime.now();
       // CurrentDateTime=system.Now().format('dd-MMM-yyyy')+', '+system.Now().format('h:mm a');
        CurrentDate=system.Now().format('dd-MMM-yyyy');
        system.debug('CurrentDate'+CurrentDate);
    }
    public void getloanDetails(string recordId){
        Applicant__c  App=[Select id,FullName__c,ApplType__c,LoanAppln__r.Name from Applicant__c where LoanAppln__c=:recordId AND (ApplType__c='P') limit 1];
            ApplicantName=App.FullName__c!=NULL?String.valueOf(App.FullName__c):'';
        	FinnoneNumber=App.LoanAppln__r.Name!=NULL?String.valueOf(App.LoanAppln__r.Name):'';
        system.debug('FinnoneNumber'+FinnoneNumber);
    }
    
    public void getlodDetails(string recordId){
        DocList=new List<DOCWrapper>();
         list<DocDtl__c>  listLOD = [select id,DocDes__c, DocSubTyp__c, OriDoc__c,Originals__c,DocCatgry__c, DocStatus__c from DocDtl__c where LAN__c=:recordId and DocStatus__c IN ('Received', 'Completed') and DocCatgry__c='Property Documents'];
            if (listLOD.size()>0) {
                 for(DocDtl__c Docdtl: listLOD){
                      DOCWrapper DOCWpr=new DOCWrapper();
                     
                     DOCWpr.Description=Docdtl.DocSubTyp__c;
                    
                   /* if(Docdtl.Originals__c ==true){
                        DOCWpr.OriginalPhoto = 'Original';
                    }else{
                        DOCWpr.OriginalPhoto = 'Photocopy'; 
                    }  */
                     DOCWpr.OriginalPhoto =Docdtl.OriDoc__c;
                     DOCWpr.Status=Docdtl.DocStatus__c;
                    DocList.add(DOCWpr);
                     system.debug('DocList'+DocList);
                 }
            }
    }
    
     public List<getBorrowerDetailsWrapper> getBorrowerDetails(String recordId){
        try{
            List<getBorrowerDetailsWrapper> borrowerwrapperData = new List<getBorrowerDetailsWrapper>();

            set<Id> setOfApplicantId = new set<Id>();
            Map<Id,String> mapOfDPD = new map<Id,String>();
           // List<Applicant__c>  listOfApplicantDetails = [Select id, FullName__c, TabName__c, ApplType__c, CustProfile__c, Constitution__c, Gender__c,Residential_Status__c, Relationship__c, Age__c, UCID__c, Type_of_Borrower__c,LoanAppln__r.Loan_Tenure_Months__c,(SELECT Id from ApplAssetJn__r), (select Id, Prop_Owners__c from Applicant_Assets__r), (Select Id,Score__c from Bureau_Responses__r order by Score__c,createddate desc ) from Applicant__c where LoanAppln__c=:recordId and ApplType__c in ('P','C','G') ORDER BY CreatedDate ASC];
            List<Applicant__c>  listOfApplicantDetails = [Select id, FullName__c, TabName__c,DOI__c, ApplType__c, CustProfile__c, Constitution__c, Gender__c,Residential_Status__c, Relationship__c, Age__c, UCID__c, Type_of_Borrower__c,LoanAppln__r.Loan_Tenure_Months__c,(SELECT Id from ApplAssetJn__r),(select id,AddrLine1__c, AddrLine2__c, City__c,State__c, Country__c,HouseNo__c,Pincode__c,   AddrTyp__c from Applicant_Addresses__r), (select Id, Prop_Owners__c from Applicant_Assets__r), (Select Id,Score__c from Bureau_Responses__r order by Score__c,createddate desc ) from Applicant__c where LoanAppln__c=:recordId and ApplType__c in ('P','C','G') ORDER BY CreatedDate ASC];
           
             
            if(listOfApplicantDetails.size()>0){
                
                system.debug('listOfApplicantDetails-->'+listOfApplicantDetails);


                for(Applicant__c applns: listOfApplicantDetails){

                    setOfApplicantId.add(applns.Id);
                }

               // List<Applicant__c>
               List<AggregateResult>  listOfDedupeResponse    = [select MAX(DPD__c)max,Applicant__c from DedupeResponse__c where LoanAppln__c =:recordId and   RecordType.Name = 'ENPA' and IsLatest__c = True AND Applicant__c in:setOfApplicantId Group BY Applicant__c]; 

               if(listOfDedupeResponse.size()>0){


                for (AggregateResult dedupResp: listOfDedupeResponse) {
                    if(dedupResp!=null){
                    String ApplicantId = (string)dedupResp.get('Applicant__c');
                    //decimal max = (decimal)dedupResp.get('max');
                    string max = (string)dedupResp.get('max');
                    mapOfDPD.put(ApplicantId,max);
                }
                }
                system.debug('mapOfDPD-->'+mapOfDPD);
                
        }
                
                for(Applicant__c appln: listOfApplicantDetails){
                    
                    getBorrowerDetailsWrapper getWrapperData = new getBorrowerDetailsWrapper();
                    getWrapperData.applicantListForBorrowerWrapper = appln;
					getWrapperData.RelationShip=appln.Relationship__c;
                    getWrapperData.ResidentStatus=appln.Residential_Status__c;
                    if(mapOfDPD.containsKey(appln.Id)){
                        getWrapperData.maxDPD = mapOfDPD.get(appln.Id);
                    }
                    
                    
                     if(appln.Residential_Status__c != null && appln.Residential_Status__c =='C'){
                getWrapperData.ResidenceType = 'CITIZEN';
            }else if(appln.Residential_Status__c != null && appln.Residential_Status__c =='NR'){
                getWrapperData.ResidenceType = 'NON RESIDENT';
            }
            else if(appln.Residential_Status__c != null && appln.Residential_Status__c =='PR'){
                getWrapperData.ResidenceType = 'PERMANENT RESIDENT';
            }
            else if(appln.Residential_Status__c != null && appln.Residential_Status__c =='R'){
                getWrapperData.ResidenceType = 'RESIDENT';
            }
                    
                    if(appln.ApplType__c != null && appln.ApplType__c =='P'){
                getWrapperData.borrowerType = 'PRIMARY';
            }else if(appln.ApplType__c != null && appln.ApplType__c =='C'){
                getWrapperData.borrowerType = 'CO-APPLICANT';
            }
            else if(appln.ApplType__c != null && appln.ApplType__c =='G'){
                getWrapperData.borrowerType = 'GUARANTOR';
            }
            else if(appln.ApplType__c != null && appln.ApplType__c =='N'){
                getWrapperData.borrowerType = 'NOMINEE';
            }
            else if(appln.ApplType__c != null && appln.ApplType__c =='A'){
                getWrapperData.borrowerType = 'APPOINTEE';
            }
            
            if(appln.Gender__c != null && appln.Gender__c =='F'){
                getWrapperData.gender = 'Female';
            }
            else if(appln.Gender__c != null && appln.Gender__c =='M'){
                getWrapperData.gender = 'Male';
            }

            if(appln.Type_of_Borrower__c != null && appln.Type_of_Borrower__c =='Financial'){
                getWrapperData.financialBorrowerWrapper = 'Yes';
            }
                    
                    if(appln.Type_of_Borrower__c != null && appln.Type_of_Borrower__c =='Financial'){
                        getWrapperData.financialBorrowerWrapper = 'Yes';
                    }
                    
                    if(appln.Age__c != null && appln.LoanAppln__r.Loan_Tenure_Months__c !=null){
                        
                        system.debug('Age-->'+appln.Age__c);
                        system.debug('Loan Tenure Months-->'+appln.LoanAppln__r.Loan_Tenure_Months__c);
                        
                        Decimal ageMaturity =0;
                        Integer ageAtMaturity;
                        ageMaturity = appln.Age__c + appln.LoanAppln__r.Loan_Tenure_Months__c/12;
                        ageAtMaturity = ageMaturity.intValue();
                        getWrapperData.ageAtLonaMaturityWrapper = ageAtMaturity;
                        system.debug('getWrapperData.ageAtLonaMaturityWrapper-->'+getWrapperData.ageAtLonaMaturityWrapper);
                    }
                    
                    List<ApplAsset__c> applAsstList = appln.Applicant_Assets__r;
                    List<ApplAssetJn__c> applAsstJnList = appln.ApplAssetJn__r;
                    List<Bureau__c> bureauList = appln.Bureau_Responses__r;
                     List<ApplAddr__c> AppAddList = appln.Applicant_Addresses__r;
                    system.debug('applAsstList-->'+applAsstList);
                    system.debug('bureauList-->'+bureauList);
                    
                     for(ApplAddr__c ad: AppAddList){
                            getWrapperData.AddressOfBorrowers = ad.HouseNo__c+' '+ad.AddrLine1__c+' '+ad.AddrLine2__c+' '+ad.City__c+' '+ad.State__c+' '+ad.Country__c+ ''+ad.Pincode__c;
                                              
                    }
                    /*for(ApplAsset__c applAss: applAsstList){
                        
                        if(applAss.Prop_Owners__c !=null){
                            getWrapperData.propertyOwnerWrapper = 'Yes';
                        }
                        else{
                            getWrapperData.propertyOwnerWrapper = 'No';
                        }                        
                        
                    }*/

                    if(applAsstJnList.size()>0){
                        getWrapperData.propertyOwnerWrapper = 'Yes';
                    }else{
                        getWrapperData.propertyOwnerWrapper = 'No';
                    }
                    

                    
                    for(Bureau__c bu: bureauList){
                        
                        if(bu.Score__c !=null){
                            getWrapperData.scoreWrapper = bu.Score__c;
                            break;
                        } 
                    }
                    
                    borrowerwrapperData.add(getWrapperData);
                }
                system.debug('borrowerwrapperData-->'+borrowerwrapperData);
                return borrowerwrapperData;
            }
            else{ 
                return null;
            }
            
        }
        Catch (exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    
    class DOCWrapper
    {
        transient public string Description{get;set;}
        transient public string OriginalPhoto{get;set;}
        transient public string Status{get;set;}
        
    }
       public class getBorrowerDetailsWrapper{
@AuraEnabled
public Applicant__c applicantListForBorrowerWrapper {get;set;}
@AuraEnabled
public String propertyOwnerWrapper {get;set;}
@AuraEnabled
public String scoreWrapper {get;set;}
@AuraEnabled
public Integer ageAtLonaMaturityWrapper {get;set;}
@AuraEnabled
public String financialBorrowerWrapper {get;set;}
@AuraEnabled
public String borrowerType {get;set;}
        @AuraEnabled
public String ResidenceType {get;set;}
@AuraEnabled
public String gender {get;set;}
@AuraEnabled
public String maxDPD {get;set;}
        @AuraEnabled
public String RelationShip {get;set;}
        @AuraEnabled
public String ResidentStatus {get;set;}
         @AuraEnabled
public String AddressOfBorrowers {get;set;}
       

}
    
}