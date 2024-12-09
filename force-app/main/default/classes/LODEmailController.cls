public class LODEmailController {
    
     transient public string recordid{get;set;}    
    transient public string loanApplicationId{get;set;}   
    transient public list<DocDtl__c> DataList{get;set;}
    transient public List<DOCWrapper> DocList{get;set;}
    
     public LODEmailController() {
        recordId = loanApplicationId;
         system.debug('recordId:'+recordId);
        /*if (recordId==null) {
            recordId='a08C4000007CR6rIAG';
        }*/if (recordId!=null) {
        	
        	//getDocDetails(recordId);
        } 
    }

   public  List<DOCWrapper> getDocDetails() {
       
        //System.debug('RecordId: '+recordId);
      // return [select id,DocDes__c, DocSubTyp__c, Originals__c,DocCatgry__c, DocStatus__c from DocDtl__c where LAN__c=:recordId and DocStatus__c IN ('Received', 'Completed') and DocCatgry__c='Property Documents'];
        DocList=new List<DOCWrapper>();
         list<DocDtl__c>  listLOD = [select id,DocDes__c,Rmrk__c, DocSubTyp__c, OriDoc__c,Originals__c,DocCatgry__c, DocStatus__c from DocDtl__c where LAN__c=:loanApplicationId and DocStatus__c IN ('Received', 'Completed') and DocCatgry__c='Property Documents'];
            if (listLOD.size()>0) {
                 for(DocDtl__c Docdtl: listLOD){
                      DOCWrapper DOCWpr=new DOCWrapper();
                     
                     //DOCWpr.Description=Docdtl.DocSubTyp__c;
                     
                    
                    /* if(Docdtl.Rmrk__c !=null){
                        DOCWpr.Description=Docdtl.Rmrk__c;
                    }else{
                        DOCWpr.Description=Docdtl.DocSubTyp__c; 
                    } */  
                    
                   /* if(Docdtl.Originals__c ==true){
                        DOCWpr.OriginalPhoto = 'Original';
                    }else{
                        DOCWpr.OriginalPhoto = 'Photocopy'; 
                    }   */
                     DOCWpr.DOCName=Docdtl.DocSubTyp__c; 
                     DOCWpr.Description=Docdtl.Rmrk__c;
                     DOCWpr.OriginalPhoto =Docdtl.OriDoc__c;
                     DOCWpr.Status=Docdtl.DocStatus__c;
                    DocList.add(DOCWpr);
                     system.debug('DocList'+DocList);
                 }
                
            }
       return DocList;
   }  
    
    
    class DOCWrapper
    {
        transient public string DOCName{get;set;}
        transient public string Description{get;set;}
        transient public string OriginalPhoto{get;set;}
        transient public string Status{get;set;}
        
    }
}