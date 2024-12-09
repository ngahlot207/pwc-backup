global class AgcLocaWrapperClass implements Comparable {

    public AgncLocMap__c AGLM;

    // Constructor
    public AgcLocaWrapperClass(AgncLocMap__c op) {
        if(op == null) {
    		Exception ex = new NullPointerException();
    		ex.setMessage('Agency Location Mapper argument cannot be null'); 
    		throw ex;
    	}
        AGLM = op;
    }

    // Compare opportunities based on the opportunity amount.
    global Integer compareTo(Object compareTo) {
        
        // Cast argument to OpportunityWrapper
        AgcLocaWrapperClass compareToOppy = (AgcLocaWrapperClass)compareTo;
        
         // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;

         if ((AGLM.LastAllocated__c == null) && (compareToOppy.AGLM.LastAllocated__c == null)) {
            // both wrappers have null Amounts
            returnValue = 0;
        } else if ((AGLM.LastAllocated__c == null) && (compareToOppy.AGLM.LastAllocated__c != null)){
            // nulls-first implementation
            returnValue = -1;
        } else if ((AGLM.LastAllocated__c != null) && (compareToOppy.AGLM.LastAllocated__c == null)){
            // nulls-first implementation
            returnValue = 1;
        } else if (AGLM.LastAllocated__c > compareToOppy.AGLM.LastAllocated__c) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (AGLM.LastAllocated__c < compareToOppy.AGLM.LastAllocated__c) {
            // Set return value to a negative value.
            returnValue = -1;
        } 
        return returnValue;      
    }
}