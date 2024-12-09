public class CriteriaConfigClass{
    
    public class CriteriaConfig {
        public List<Criteria> criteria;
        public String expression;
    }
    
    public CriteriaConfig criteriaConfig;
    
    public class Criteria {
        public String objectAPIName;
        public String fieldName;
    }
    
    
    public static CriteriaConfigClass parse(String json) {
        return (CriteriaConfigClass) System.JSON.deserialize(json, CriteriaConfigClass.class);
    }
}