public with sharing class ProbeCallbackResponseWrapper {
    public String cin;
	public String request_id;
	public String status;
    public String message;

	
	public static ProbeCallbackResponseWrapper parse(String json) {
		return (ProbeCallbackResponseWrapper) System.JSON.deserialize(json, ProbeCallbackResponseWrapper.class);
	}

}