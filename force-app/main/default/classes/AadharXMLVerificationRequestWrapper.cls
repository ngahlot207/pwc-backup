public class AadharXMLVerificationRequestWrapper {

   	public String reference_id;	//121343
	public String source_type;	//id
	public String source;	//240789858325
        
	public static AadharXMLVerificationRequestWrapper parse(String json){
        return (AadharXMLVerificationRequestWrapper) System.JSON.deserialize(json, AadharXMLVerificationRequestWrapper.class);
	}
}