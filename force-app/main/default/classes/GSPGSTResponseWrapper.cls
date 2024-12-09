public class GSPGSTResponseWrapper {
	public String requestId;
	public ResultClass result;
	public Integer statusCode;
	public ClientDataclass clientData;
    
    public  Integer status; //400,
    public String error; //Bad Request
	
	public class ResultClass {
		public String stjCd;
		public String lgnm;
		public String stj;
		public String dty;
		public List<ADADRClass> adadr;
		public String cxdt;
		public String gstin;
		public List<String> nba;
		public String lstupdt;
		public String rgdt;
		public String ctb;
		public ADADRClass pradr;
		public String sts;
		public String tradeNam;
		public String ctjCd;
		public String ctj;
		public String einvoiceStatus;
		public List<String> mbr;
		public String canFlag;
		public String cmpRt;
		public ContactedClass contacted;
		public String ppr;
	}
	
	public class ADADRClass {
		public ADDRClass addr;
		public String ntr;
	}
    
    public class ADDRClass {
        public String bnm;
		public String st;
		public String loc;
		public String bno;
		public String dst; 
        public String lt;
		public String locality;
		public String pncd;
		public String landMark;
		public String stcd;
        public String geocodelvl;
		public String flno;
		public String lg;
    }
	
	public class ContactedClass {
		public String email;
		public String mobNum;
		public String name;
	}
	
	public class ClientDataclass {
		public String caseId;
	}
}