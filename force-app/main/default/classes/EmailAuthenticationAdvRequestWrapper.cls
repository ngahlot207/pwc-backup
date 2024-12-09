public class EmailAuthenticationAdvRequestWrapper {
    
    public string email;
    public string individualName;
    public string organizationName;
    public Integer version;
    public string consent;
    public ClientData clientData;

    public class ClientData{
        public string caseId;
    }
}