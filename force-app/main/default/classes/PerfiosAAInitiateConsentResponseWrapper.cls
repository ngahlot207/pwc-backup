public class PerfiosAAInitiateConsentResponseWrapper {
	public String consentHandle;	//7786bcb8-f326-4901-bdbe-0f3595f75f75
	public Integer status;	//200
	public String redirectURL;	//https://fiu.perfios.com/fiu/v1/api/web/Consent/Request/0b685d64-5536-41c5-824a-c0b96f1f883b
	public String qrCode;	//base64 Encoded URL
	public String txnId;	//ec1d46dd9b83465c90512f7e8f236a25
    
    public String errorCode;	//UnauthorizedAccess
	public String timestamp;	//2020-08-17T09:59:36.741Z
	public String errorMessage;	//Header validation failed, org_id or api_key is empty
    
	public static PerfiosAAInitiateConsentResponseWrapper parse(String json){
		return (PerfiosAAInitiateConsentResponseWrapper) System.JSON.deserialize(json, PerfiosAAInitiateConsentResponseWrapper.class);
	}
}