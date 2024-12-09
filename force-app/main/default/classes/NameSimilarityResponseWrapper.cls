public class NameSimilarityResponseWrapper {

	public Integer statusCode;
	public String requestId;
	public Result result;
	public ClientData clientData;

	public class ClientData {
		public String caseId;
	}

	public class Result {
		public Double score;
		public Boolean result;
	}

	
	public static NameSimilarityResponseWrapper parse(String json) {
		return (NameSimilarityResponseWrapper) System.JSON.deserialize(json, NameSimilarityResponseWrapper.class);
	}
}