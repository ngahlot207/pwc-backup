public class RiskRatingResponseWrapper {

    public String Result;
    
    public static RiskRatingResponseWrapper parse(String json) {
        return (RiskRatingResponseWrapper) System.JSON.deserialize(json, RiskRatingResponseWrapper.class );
    } 
}