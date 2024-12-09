public class BillDeskController {
    
    //Pre Request
    public Id recordId { get; set; }
    public Decimal totalPayableAmount { get; set; }
    public string sfdcError { get; set; }
    public string bdorderid { get; set; }
    public string merchantid { get; set; }
    public string rdata { get; set; }
    public string paymentUrl { get; set; }
    //post request
    public string paymentMethod {get;set;}
    public string orderId {get;set;}
    public string transactionId {get;set;}
    public string status {get;set;}
    public string statusDesc {get;set;}
    public string transactionDate {get;set;}
    public string customerName {get;set;}//Used in Pre Request
    public string loanAccountNo {get;set;}//Used in Pre Request
    public string amount {get;set;}
    public string errorMess {get;set;}
    public string header {get;set;}
    public string footer {get;set;}
    public string tcLink {get;set;}
    
    
    public void preRequest(){
        
        Map<String,sObject> sObjectMap =new Map<String,sObject>();
        
        try {
            
            
            List<Payment__c>  pay =[Select id,TransAmt__c,LoanAppl__r.Applicant__r.FullName__c,LoanAppl__r.Name,
                                    BDOrderId__c,RData__c,BDMercId__c,BDURL__c from Payment__c Where id =:recordId];
            
            List<ApplIMD__c>  appImd =[Select id,InstrumentAmt__c,LoanAppln__r.Applicant__r.FullName__c,LoanAppln__r.Name,
                                       BDOrderId__c,RData__c,BDMercId__c,BDURL__c from ApplIMD__c Where id =:recordId];
            
            if(!pay.isEmpty()){
                
                for(Payment__c payment:pay){
                    
                    sObjectMap.put(payment.id,payment);
                }
            }
            
            if(!appImd.isEmpty()){
                
                for(ApplIMD__c imd:appImd){
                    
                    sObjectMap.put(imd.id,imd);
                }
            }
            
            
            if(!sObjectMap.isEmpty() && sObjectMap.containsKey(recordId)){
                
                sobject retrievedSObject =sObjectMap.get(recordId);
                
                //Payment Obj
                if(retrievedSObject!=null && retrievedSObject instanceof Payment__c){
                    Payment__c payment=(Payment__c)retrievedSObject;
                    
                    customerName=(payment!=null && string.isNotblank(payment.LoanAppl__r.Applicant__r.FullName__c))?payment.LoanAppl__r.Applicant__r.FullName__c:'';
                    loanAccountNo=(payment!=null && string.isNotblank(payment.LoanAppl__r.Name))?payment.LoanAppl__r.Name:'';
                    bdorderid=(payment!=null && string.isNotblank(payment.BDOrderId__c))?payment.BDOrderId__c:'';
                    rdata=(payment!=null && string.isNotblank(payment.RData__c))?payment.RData__c:'';
                    merchantid=(payment!=null && string.isNotblank(payment.BDMercId__c))?payment.BDMercId__c:'';
                    paymentUrl=(payment!=null && string.isNotblank(payment.BDURL__c))?payment.BDURL__c:'';
                    
                    if(payment!=null && payment.TransAmt__c!=null){
                        totalPayableAmount= payment.TransAmt__c;
                    }
                    
                }
                
                //Applicant Imd Obj
                else if(retrievedSObject != null && retrievedSObject instanceof ApplIMD__c){
                    
                    ApplIMD__c imd=(ApplIMD__c)retrievedSObject;
                    
                    customerName=(imd!=null && string.isNotblank(imd.LoanAppln__r.Applicant__r.FullName__c))?imd.LoanAppln__r.Applicant__r.FullName__c:'';
                    loanAccountNo=(imd!=null && string.isNotblank(imd.LoanAppln__r.Name))?imd.LoanAppln__r.Name:'';
                    bdorderid=(imd!=null && string.isNotblank(imd.BDOrderId__c))?imd.BDOrderId__c:'';
                    rdata=(imd!=null && string.isNotblank(imd.RData__c))?imd.RData__c:'';
                    merchantid=(imd!=null && string.isNotblank(imd.BDMercId__c))?imd.BDMercId__c:'';
                    paymentUrl=(imd!=null && string.isNotblank(imd.BDURL__c))?imd.BDURL__c:'';
                    
                    if(imd!=null && imd.InstrumentAmt__c!=null){
                        totalPayableAmount= imd.InstrumentAmt__c;
                    }
                    
                }
                
                
            }
        }catch (Exception e) {
            sfdcError=e.getmessage();
        }
    }
    
    public void handleResponse(){
        recordId =ApexPages.currentPage().getParameters().get('id');
        
        header=system.label.BillDeskPageHeader;
        List<String> footerDetials = system.label.BillDeskPageFooter!=null? system.label.BillDeskPageFooter.split(';'): new List<String>();
        if(!footerDetials.isEmpty() && footerDetials.size()>=2){
            footer = footerDetials[0];
            tcLink = footerDetials[1];
        }
        
        
        if(recordId!=null){
            preRequest();
        }
        else{
            handleCallbackResponse();
        }
    }
    public  void handleCallbackResponse() {//Map<String, String> par
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String base64EncodeResponse;
        String base64DecodeResponse;
        Set<String> orderIds =new Set<String>();
        Map<String,sObject> sObjectMap =new Map<String,sObject>();
        JsonWrapper res;
        
        try {
            //Map<String, String> params=par;
            
            if(params.containskey('transaction_response')){
                base64EncodeResponse = params.get('transaction_response');
            }
            else if(params.containskey('encrypted_response')){
                base64EncodeResponse = params.get('encrypted_response');
            }
            
            if(String.isNotBlank(base64EncodeResponse)){
                List<String> response =base64EncodeResponse.split('\\.');
                
                
                if(response!=null && response[1]!=null){
                    base64DecodeResponse= EncodingUtil.base64Decode(response[1]).tostring();
                }
            }
            
            //Getting Order Id from Response
            if(String.isNotblank(base64DecodeResponse)){
                
                res =(JsonWrapper) JSON.deserialize(base64DecodeResponse,JsonWrapper.class);
                
                if(res!=null && string.isNotblank(res.orderid)){
                    orderIds.add(res.orderid);
                }
                
                if(string.isNotblank(res.payment_method_type)){
                    
                    paymentMethod=res.payment_method_type.substring(0, 1).toUpperCase() + res.payment_method_type.substring(1);
                    //paymentMethod=res.payment_method_type;
                }
                
                if(string.isNotblank(res.transactionid)){
                    transactionId=res.transactionid;
                }
                
                if(string.isNotblank(res.transaction_error_type)){
                    status=res.transaction_error_type.substring(0, 1).toUpperCase() + res.transaction_error_type.substring(1);
                    //status=res.transaction_error_type;
                }
                
                if(string.isNotblank(res.transaction_error_desc)){
                    statusDesc=res.transaction_error_desc;
                }
                
                if(string.isNotblank(res.transaction_date)){
                    string transDate=res.transaction_date.substring(0,19).replace('T', ' ');
                    Datetime parsedDate = Datetime.valueOf(transDate);
                    transactionDate=parsedDate.format('dd/MM/yyyy hh:mm a');
                }
                
                if(string.isNotblank(res.charge_amount)){
                    amount=res.charge_amount;
                }
                
                
                
                //error
                if(string.isNotblank(res.message)){
                    errorMess=res.message;
                    statusDesc='Transaction Failed';
                }
                
            }
            
            //Getting record from SFDC
            if(!orderIds.isEmpty()){
                
                List<Payment__c>  payment =[Select id,OrderId__c,LoanAppl__c,LoanAppl__r.Applicant__c,LoanAppl__r.Applicant__r.FullName__c,LoanAppl__r.Name from Payment__c Where OrderId__c IN:orderIds];
                List<ApplIMD__c>  appImd =[Select id,OrderId__c,LoanAppln__c,LoanAppln__r.Applicant__c,LoanAppln__r.Applicant__r.FullName__c,LoanAppln__r.Name from ApplIMD__c Where OrderId__c IN:orderIds];
                
                if(!payment.isEmpty()){
                    
                    for(Payment__c paym:payment){
                        
                        sObjectMap.put(paym.OrderId__c,paym);
                    }
                }
                
                if(!appImd.isEmpty()){
                    
                    for(ApplIMD__c imd:appImd){
                        
                        sObjectMap.put(imd.OrderId__c,imd);
                    }
                }
            }
            
            if(res!=null && !sObjectMap.isEmpty()){
                
                if(string.isNotblank(res.orderid) && sObjectMap.containsKey(res.orderid)){
                    orderId=res.orderid;
                    
                    sobject retrievedSObject =sObjectMap.get(res.orderid);
                    
                    if(retrievedSObject != null && retrievedSObject instanceof Payment__c){
                        Payment__c pay=(Payment__c)retrievedSObject;
                        
                        customerName=(pay!=null && string.isNotblank(pay.LoanAppl__r.Applicant__r.FullName__c))?pay.LoanAppl__r.Applicant__r.FullName__c:'';
                        loanAccountNo=(pay!=null && string.isNotblank(pay.LoanAppl__r.Name))?pay.LoanAppl__r.Name:'';
                        
                    }
                    
                    else if(retrievedSObject != null && retrievedSObject instanceof ApplIMD__c){
                        
                        ApplIMD__c imd=(ApplIMD__c)retrievedSObject;
                        
                        customerName=(imd!=null && string.isNotblank(imd.LoanAppln__r.Applicant__r.FullName__c))?imd.LoanAppln__r.Applicant__r.FullName__c:'';
                        loanAccountNo=(imd!=null && string.isNotblank(imd.LoanAppln__r.Name))?imd.LoanAppln__r.Name:'';
                    }
                    
                    
                }
            }
            
            
            
        } catch (Exception e) {
            errorMess=e.getmessage()+', Line'+e.getLineNumber();
            statusDesc='Transaction Failed';
        }
        
        //Integration Message
        if(String.isNotBlank(base64EncodeResponse)){
            
            IntgMsg__c msg =new IntgMsg__c();
            msg.Name='BillDesk Callback';
            msg.Status__c='Responded';
            msg.Resp__c=base64EncodeResponse;
            msg.IsActive__c=TRUE;
            msg.Inbound__c=TRUE;
            
            if(!sObjectMap.isEmpty() && res!=null && string.isNotblank(res.orderid) && sObjectMap.containsKey(res.orderid)){
                
                sobject retrievedSObject =sObjectMap.get(res.orderid);
                
                if(retrievedSObject != null && retrievedSObject instanceof Payment__c){
                    
                    Payment__c pay=(Payment__c)retrievedSObject;
                    
                    pay.TransStatus__c=(string.isNotblank(status) && status.tolowercase()=='success')?'Success':'Failure';
                    pay.PaymentReceived__c=(string.isNotblank(status) && status.tolowercase()=='success')?'Yes':'No';
                    if(string.isNotblank(amount)){
                        pay.TransAmt__c= Decimal.valueOf(amount);
                    }
                    pay.PaymentRefNo__c =String.isNotBlank(res.bank_ref_no)? res.bank_ref_no : transactionid;
                    pay.TransId__c=string.isNotblank(transactionId)?transactionId:'';
                    pay.TransDt__c=string.isNotblank(transactionDate)?CrimeCheckCallbackResponseprocessor.getDateTime(transactionDate):null;
                    pay.BillDeskAPIErrorMessage__c = String.isNotBlank(res.transaction_error_desc) ?  res.transaction_error_desc :  String.isNotBlank(res.message) ? res.message :'';
                    Update pay;
                    
                    //Integration Message
                    msg.LoanAppln__c=pay.LoanAppl__c;
                    msg.Appl__c=pay.LoanAppl__r.Applicant__c;
                    
                }
                else if(retrievedSObject != null && retrievedSObject instanceof ApplIMD__c){
                    
                    ApplIMD__c imd=(ApplIMD__c)retrievedSObject;
                    
                    imd.TransStatus__c=(string.isNotblank(status) && status.tolowercase()=='success')?'Success':'Failure';
                    imd.IMDReceived__c=(string.isNotblank(status) && status.tolowercase()=='success')?'Yes':'No';
                    if(string.isNotblank(status) && status.tolowercase()=='success'){
                        imd.IMDStatus__c = 'Cleared';
                    }
                    if(string.isNotblank(amount)){
                        imd.TransAmt__c = Decimal.valueOf(amount);
                        imd.InstrumentAmt__c = Decimal.valueOf(amount);
                    }
                    imd.PaymentRefNo__c =String.isNotBlank(res.bank_ref_no)? res.bank_ref_no : transactionid;
                    imd.TransId__c=string.isNotblank(transactionId)?transactionId:'';
                    imd.TransDt__c=string.isNotblank(transactionDate)?CrimeCheckCallbackResponseprocessor.getDateTime(transactionDate):null;
                    imd.BillDeskAPIErrorMessage__c = String.isNotBlank(res.transaction_error_desc) ?  res.transaction_error_desc :  String.isNotBlank(res.message) ? res.message :'';
                    Update imd;
                    
                    //Integration Message
                    msg.LoanAppln__c=imd.LoanAppln__c;
                    msg.Appl__c=imd.LoanAppln__r.Applicant__c;
                }
            }
            Insert msg;
        }
        
        
    }
    
    //JsonWrapper
    Public class JsonWrapper{
        
        public string payment_method_type;
        public string orderid;
        public string transactionid;
        public string bank_ref_no;
        public string transaction_error_type;
        public string transaction_error_desc;
        public string transaction_date;
        public string charge_amount;
        //Error
        public string message;
        
    }
    
}