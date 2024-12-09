global class ContactWrappeClass implements Comparable {

    public Contact con;

    // Constructor
    public ContactWrappeClass(contact conn) {
        if(conn == null) {
    		Exception ex = new NullPointerException();
    		ex.setMessage('contact argument cannot be null'); 
    		throw ex;
    	}
        con = conn;
    }

    // Compare opportunities based on the opportunity amount.
    global Integer compareTo(Object compareTo) {
        // Cast argument to OpportunityWrapper
        ContactWrappeClass compareToOppy = (ContactWrappeClass)compareTo;

        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
         if ((con.LastAllocated__c == null) && (compareToOppy.con.LastAllocated__c == null)) {
            // both wrappers have null Amounts
            returnValue = 0;
        } else if ((con.LastAllocated__c == null) && (compareToOppy.con.LastAllocated__c != null)){
            // nulls-first implementation
            returnValue = -1;
        } else if ((con.LastAllocated__c != null) && (compareToOppy.con.LastAllocated__c == null)){
            // nulls-first implementation
            returnValue = 1;
        } else if (con.LastAllocated__c > compareToOppy.con.LastAllocated__c) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (con.LastAllocated__c < compareToOppy.con.LastAllocated__c) {
            // Set return value to a negative value.
            returnValue = -1;
        } 
        return returnValue;      
    }
}