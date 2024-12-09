public class AddressSplitAPIRequestWrapper {
    
    public String address;
    public String version;
    public Config config;
    public ClientData clientData;
    
    
    public class Config{
        public Boolean get_state_by_brute_force;
    }

    public class ClientData{
       public String caseId; 
    }
}