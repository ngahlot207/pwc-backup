/**
 * @description       : Hunter Request Parser Class
 * @author            : Ripul Rawat
 * @last modified on  : 10-09-2023
 * @last modified by  : Ripul Rawat
**/

public class HunterTokenRequestParser {
	public String username;
	public String password;
	public String client_id;
	public String client_secret;
    
    public static HunterTokenRequestParser parse(String json){
        return (HunterTokenRequestParser) System.JSON.deserialize(json, HunterTokenRequestParser.class);
    }
    
}