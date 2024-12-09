public class BureauQueueable implements Queueable {
    
    private string jsonData;
    
    Public BureauQueueable(String jsonData){
        this.jsonData =jsonData;
    }
    
    public void execute(QueueableContext context) {
     
        JsonBody res=(JsonBody) JSON.deserialize(jsonData, JsonBody.class);
        
        IntgMsg__c msg =new IntgMsg__c();

        if(!String.isBlank(res.Name)){
            msg.Name=res.Name;
        }
        if(!String.isBlank(res.Status)){
            msg.Status__c=res.Status;
        }
        if(!String.isBlank(res.MStatus)){
            msg.MStatus__c=res.MStatus;
        }
        if(!String.isBlank(res.BU)){
            msg.BU__c=res.BU;
        }
        if(!String.isBlank(res.RefId)){
            msg.RefId__c=res.RefId;
        }
        if(!String.isBlank(res.RefObj)){
            msg.RefObj__c=res.RefObj;
        }
        if(!String.isBlank(res.Svc)){
            msg.Svc__c=res.Svc;
        }
        if(!String.isBlank(res.ApiVendor)){
            msg.ApiVendor__c=res.ApiVendor;
        }
        if(!String.isBlank(res.IsActive)){
            msg.IsActive__c=Boolean.valueof(res.IsActive);
        }
       insert msg;
    }
    
    
    public class JsonBody{
        public string Name;
        public string Status;
        public string MStatus;
        public string BU;
        public string RefId;
        public string RefObj;
        public string Svc;
        public string ApiVendor;
        public string IsActive;
    }

}