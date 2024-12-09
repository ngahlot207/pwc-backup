public class Trackwizz_CKYC_A37_RequestWrapper {
	
	public A37ImageIntegrationRequestClass A37ImageIntegrationRequest;
	
	public class A37ImageIntegrationRequestClass {
		public String ApiToken;
		public String RequestId;
		public RequestDataDetailClass RequestDataDetail;
	}
	
	public class RequestDataDetailClass {
		public CustomerRequest CustomerRequestDetails;
	}
	
	public class CustomerRequest {
		public CustomerRequestDetailClass CustomerRequestDetail;
	}
	
	public class CustomerRequestDetailClass {
		public String TransactionId;
		public String SourceSystemName;
		public String SourceSystemCustomerCode;
		public String AppRefNumberOfImages;
		public String HolderForImages;
		public ImageRequestDetailsClass ImageRequestDetails;
	}
	
	public class ImageRequestDetailsClass {
		public List<ImageRequest> ImageRequestDetail;
	}
	
	public class ImageRequest {
		public String ImageTransactionId;
		public String AttachmentCode;
		public String AttachmentBlob;
		public String ImageExtension;
	}
	
	public static Trackwizz_CKYC_A37_RequestWrapper parse(String json){
        return (Trackwizz_CKYC_A37_RequestWrapper) System.JSON.deserialize(json, Trackwizz_CKYC_A37_RequestWrapper.class);
    }
}