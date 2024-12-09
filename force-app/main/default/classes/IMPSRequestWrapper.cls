public class IMPSRequestWrapper {
    public String respUrl;	//http://10.250.14.46:7831/Remmitance_Consumer
    public String userid;	//federal
    public String password;	//federal@123
    public String sendercd;	//BNKCD
    public String tranDate;	//10-04-2018
    public String ReferenceId;	//Test201899079
    public String Cust_Ref_No;	//Test20190741127
    public RemmiterDetails RemmiterDetails;
    public BeneficiaryDetails BeneficiaryDetails;
    public String Amount;	//200.60
    public String Remarks;	//remarks
    public String Sender_Data;	//1000003982 IMPS Danish Qadri 309004470629.
    
    Public class RemmiterDetails {
        public String Name;	//Naveed Anjum
        public String AccNumber;	//99980100068100
        public String Acctype;	//10
        public String Mobile;	//9867374437
        public String Email;	//naveed.anjum@tmwpay.com
        public String Notification_Flag;	//NONE
    }
    public class BeneficiaryDetails {
        public String Name;	//Danish Qadri
        public String AccNumber;	//15125000217628
        public String IFSC;	//FDRL0001001
        public String Mobile;	//9892020030
        public String Email;	//danish.qadri@tmwpay.com
        public String Notification_Flag;	//NONE
    }
    public static IMPSRequestWrapper parse(String json){
        return (IMPSRequestWrapper) System.JSON.deserialize(json, IMPSRequestWrapper.class);
    }
}