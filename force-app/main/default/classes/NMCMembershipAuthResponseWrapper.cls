public class NMCMembershipAuthResponseWrapper {

    public String requestId;	//8c227db3-1969-474d-a19d-a1d9de0d24bb
	public Result result;
	public Integer statusCode;	//101
	public ClientData clientData;
	public class Result {
		public String doctorId;	//1000082
		public String additionalAddresses;	//
		public List<AdditionalQualifications> additionalQualifications;
		public String address;	//C/O. SHIVAJI BHAGAT , C-1-304 , VALLEY TOWERS , KHEVRA CIRCLE , POKHRAN ROAD-2 , MANPADA , THANE - 400607
		public String category;	//
		public String dateOfBirth;	//06-09-1986
		public String dateOfRegistration;	//07-10-2010
		public String fatherName;	//BHAGAT SHIVAJI LAHANUJI
		public String firstName;	//
		public String husbandName;	//
		public boolean isNewlyRegisteredDoctor;
		public String name;	//BHAGAT (Ms.) PRIYANKA SHIVAJI
		public Qualification qualification;
		public String registrationNumber;	//2010103028
		public boolean removedStatus;
		public String restoredOn;	//14-11-2023
		public boolean restoredStatus;
		public String stateMedicalCouncil;	//Maharashtra Medical Council
		public String stateMedicalCouncilId;	//16
		public String uniquePermanentRegistrationNumber;	//
		public String yearOfInfo;	//2010
		public String yearOfPassing;	//2010
		public boolean isBlacklistedDoctor;
		public List<Suspensions> suspensions;
	}
	public class AdditionalQualifications {
		public String qualification;	//
		public String qualificationYear;	//
		public String university;	//
		public String college;	//
	}
	public class Qualification {
		public String qualification;	//MBBS
		public String qualificationYear;	//2010
		public String university;	//U.Maha.Health Sciences, Nashik
		public String college;	//
	}
	public class Suspensions {
		public String suspensionDate;	//15/11/2018
		public String restorationDate;	//14/11/2023
		public String remarks;	//Vide Order no. MMC/DC/CPS/02/2018/2018/03879 dated 15.11.2018
	}
	public class ClientData {
		public String caseId;	//123456
	}
    
    public  Integer status; //400,
    public String error; //Bad Request
    
	public static NMCMembershipAuthResponseWrapper parse(String json){
		return (NMCMembershipAuthResponseWrapper) System.JSON.deserialize(json, NMCMembershipAuthResponseWrapper.class);
	}
}