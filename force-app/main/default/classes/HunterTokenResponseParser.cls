/**
 * @description       : Hunter Response Parser Class
 * @author            : Ripul Rawat
 * @last modified on  : 10-09-2023
 * @last modified by  : Ripul Rawat
**/

public class HunterTokenResponseParser {
	public String issued_at;
	public String expires_in;
	public String token_type;
	public String access_token;
	public String refresh_token;
    
    public static HunterTokenResponseParser parse(String json){
        return (HunterTokenResponseParser) System.JSON.deserialize(json, HunterTokenResponseParser.class);
    }
}