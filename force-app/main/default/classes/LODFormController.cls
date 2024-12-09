public class LODFormController {
	transient public String recordId{get;set;}
    transient public String header{get;set;}
    transient public String todaysDate{get;set;}
     transient public String CurrentDate{get;set;}
    transient public String ApplicantName{get;set;}
    transient public String FinnoneNumber{get;set;}
    transient public List<DOCWrapper> DocList{get;set;}
    transient public string loanApplicationId{get;set;}
    transient public string ResidenceAddress{get;set;}
    
     public LODFormController(){
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
        Applicant__c  App=[Select id,FullName__c,Constitution__c,ApplType__c,LoanAppln__r.Finnone_Loan_Number__c from Applicant__c where LoanAppln__c=:recordId AND (ApplType__c='P') limit 1];
            ApplicantName=App.FullName__c;
        	FinnoneNumber=App.LoanAppln__r.Finnone_Loan_Number__c;
        system.debug('FinnoneNumber'+FinnoneNumber);
        
         if(App.Constitution__c=='INDIVIDUAL'){
                 list<ApplAddr__c> ResAdd=[select id,AddrLine1__c, AddrLine2__c, City__c,State__c, Country__c,HouseNo__c,Pincode__c,AddrTyp__c from ApplAddr__c where Applicant__c =:App.id  and AddrTyp__c='Residence Address' limit 1];
         if(!ResAdd.isEmpty()){
         ResidenceAddress=ResAdd[0].HouseNo__c+' '+ResAdd[0].AddrLine1__c+' '+ResAdd[0].AddrLine2__c+' '+ResAdd[0].City__c+' '+ResAdd[0].State__c+' '+ResAdd[0].Country__c+ ''+ResAdd[0].Pincode__c!=NULL?String.valueOf(ResAdd[0].HouseNo__c+' '+ResAdd[0].AddrLine1__c+' '+ResAdd[0].AddrLine2__c+' '+ResAdd[0].City__c+' '+ResAdd[0].State__c+' '+ResAdd[0].Pincode__c):'';
           }
             }
             else{
                 list<ApplAddr__c> ResAdd=[select id,AddrLine1__c, AddrLine2__c, City__c,State__c, Country__c,HouseNo__c,Pincode__c,AddrTyp__c from ApplAddr__c where Applicant__c =:App.id  and AddrTyp__c='Registered place for business' limit 1];
         if(!ResAdd.isEmpty()){
         ResidenceAddress=ResAdd[0].HouseNo__c+' '+ResAdd[0].AddrLine1__c+' '+ResAdd[0].AddrLine2__c+' '+ResAdd[0].City__c+' '+ResAdd[0].State__c+' '+ResAdd[0].Country__c+ ''+ResAdd[0].Pincode__c!=NULL?String.valueOf(ResAdd[0].HouseNo__c+' '+ResAdd[0].AddrLine1__c+' '+ResAdd[0].AddrLine2__c+' '+ResAdd[0].City__c+' '+ResAdd[0].State__c+' '+ResAdd[0].Pincode__c):'';
           }
             }
    }
    
    public void getlodDetails(string recordId){
        DocList=new List<DOCWrapper>();
         list<DocDtl__c>  listLOD = [select id,DocDes__c, Rmrk__c,DocSubTyp__c, OriDoc__c,Originals__c,DocCatgry__c, DocStatus__c from DocDtl__c where LAN__c=:recordId and DocStatus__c IN ('Received', 'Completed') and DocCatgry__c='Property Documents'];
            if (listLOD.size()>0) {
                 for(DocDtl__c Docdtl: listLOD){
                      DOCWrapper DOCWpr=new DOCWrapper();
                     
                    // DOCWpr.Description=Docdtl.DocSubTyp__c;
                    /* if(Docdtl.Rmrk__c !=null){
                        DOCWpr.Description=Docdtl.Rmrk__c;
                    }else{
                        DOCWpr.Description=Docdtl.DocSubTyp__c; 
                    }   */
                   /* if(Docdtl.Originals__c ==true){
                        DOCWpr.OriginalPhoto = 'Original';
                    }else{
                        DOCWpr.OriginalPhoto = 'Photocopy'; 
                    }  */
                     DOCWpr.DOCName=Docdtl.DocSubTyp__c; 
                     DOCWpr.Description=Docdtl.Rmrk__c;
                     DOCWpr.OriginalPhoto =Docdtl.OriDoc__c;
                     DOCWpr.Status=Docdtl.DocStatus__c;
                    DocList.add(DOCWpr);
                     system.debug('DocList'+DocList);
                 }
            }
    }
    
    class DOCWrapper
    {
        transient public string DOCName{get;set;}
        transient public string Description{get;set;}
        transient public string OriginalPhoto{get;set;}
        transient public string Status{get;set;}
        
    }
    
}