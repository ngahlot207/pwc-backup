public class NameSimilarityRequestWrapper {

	public String name1;
	public String name2;
	public String type;
	public String preset;
	public Boolean allowPartialMatch;
	public Boolean suppressReorderPenalty;
	public ClientData clientData;

	public class ClientData {
		public String caseId;
	}

	
	public static NameSimilarityRequestWrapper parse(String json) {
		return (NameSimilarityRequestWrapper) System.JSON.deserialize(json, NameSimilarityRequestWrapper.class);
	}
}