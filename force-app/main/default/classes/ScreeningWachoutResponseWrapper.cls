public class ScreeningWachoutResponseWrapper {
    
    Public WotJson WotJsonResult;
    
    public class WotJson{
    public List<table> Table;
    }
    
	
	Public class table {
		public String Record_ID;	//COMP13060
		public String Regulator_Competent_Authority_Name;	//SEBI
		public String Order_Date;	//31-Jul-2020
		public String Defaulter_Code;	//C0539749
		public String Defaulter_Name;	//AVENUE SUPERMARTS LTD.
		public String Defaulter_Type_Company_Person;	//C
		public String Defaulter_New_Name1;	//
		public String Defaulter_New_Name2;	//
		public String Defaulter_New_Name3;	//
		public String Defaulter_New_Name4;	//
		public String Defaulter_Old_Name1;	//
		public String Defaulter_Old_Name2;	//
		public String Defaulter_Old_Name3;	//
		public String Defaulter_Old_Name4;	//
		public String Defaulter_Merged_With;	//
		public String PAN_CIN_DIN;	//PAN:AACCA8432H
		public String Not_Defaulter_Infact_Associated_Entity;	//
		public String Defaulter_Other_Details;	//
		public String Alongwith;	//
		public String Associated_Entity_Person;	//
		public String Regulatory_Charges;	//DELAY IN MAKING DISCLOSURE OF SHAREHOLDING/CHANGES IN SHAREHOLDING TO STOCK EXCHANGES AS REQUIRED UNDER REGULATION 7(2) (B) OF SEBI (PIT) REGULATIONS, 2015
		public String Regulatory_Actions;	//IMPOSED PENALTY RS.3,00,000; (ORDER DATED:31-JUL-2020)
		public String Regulatory_Action_Source1;	//http://www.watchoutinvestors.com/Press_Rel-T/sebi/AO_1596212403003_1.pdf?cntrl_no=COMP13060
		public String Regulatory_Action_Source2;	//
		public String Regulatory_Action_Source3;	//
		public String Further_Development1;	//SAT: SAT VIDE ITS ORDER DATED 29/09/2020 GRANTED FOUR WEEKS TIME TO RESPONDENT TO FILE AFFIDAVIT IN REPLY AND TWO WEEKS THEREAFTER FOR FILING AFFIDAVIT IN REJOINDER, IF ANY AND PLACED THE APPEAL FOR FINAL DISPOSAL ON 25/11/2020. IN THE MEANTIME, THE EFFECT AND OPERATION OF IMPUGNED ORDER DIRECTED TO BE STAYED UPON DEPOSIT OF AMOUNT EQUAL TO PENALTY WITH RESPONDENT WITHIN THREE WEEKS FROM DATE OF THIS ORDER
		public String Further_Development1_Source;	//http://www.watchoutinvestors.com/Press_Rel-T/sat/ST3356.pdf
		public String Further_Development2;	//SAT: SAT VIDE ITS ORDER DATED 10/06/2021 DIRECTED RESPONDENT TO FILE ADDITIONAL AFFIDAVITS WITHIN TWO WEEKS FROM DATE OF THIS ORDER AND APPELLANT TO FILE REJOINDER TEN DAYS THEREAFTER
		public String Further_Development2_Source;	//http://www.watchoutinvestors.com/Press_Rel-T/sat/ST3773.pdf
		public String Further_Development3;	//SAT: SAT VIDE ITS ORDER DATED 17/01/2022 DISMISSED THE APPEAL. NO COSTS
		public String Further_Development3_Source;	//http://www.watchoutinvestors.com/Press_Rel-T/sat/ST4338.pdf
		public String Further_Development4;	//
		public String Further_Development4_Source;	//
		public String Further_Development5;	//
		public String Further_Development5_Source;	//
		public String Further_Development6;	//
		public String Further_Development6_Source;	//
		public String Further_Development7;	//
		public String Further_Development7_Source;	//
		public String Further_Development8;	//
		public String Further_Development8_Source;	//
		public String Further_Development9;	//
		public String Further_Development9_Source;	//
		public String Further_Development10;	//
		public String Further_Development10_Source;	//
		public String Further_Development11;	//
		public String Further_Development11_Source;	//
		public String Further_Development12;	//
		public String Further_Development12_Source;	//
		public String Further_Development13;	//
		public String Further_Development13_Source;	//
		public String Further_Development14;	//
		public String Further_Development14_Source;	//
		public String Further_Development15;	//
		public String Further_Development15_Source;	//
		public String Further_Development16;	//
		public String Further_Development16_Source;	//
		public String Further_Development17;	//
		public String Further_Development17_Source;	//
		public String Further_Development18;	//
		public String Further_Development18_Source;	//
		public String Further_Development19;	//
		public String Further_Development19_Source;	//
		public String Further_Development20;	//
		public String Further_Development20_Source;	//
		public String Further_Development21;	//
		public String Further_Development21_Source;	//
		public String Further_Development22;	//
		public String Further_Development22_Source;	//
	}
    public static ScreeningWachoutResponseWrapper parse(String json){
		return (ScreeningWachoutResponseWrapper) System.JSON.deserialize(json, ScreeningWachoutResponseWrapper.class);
	}
}