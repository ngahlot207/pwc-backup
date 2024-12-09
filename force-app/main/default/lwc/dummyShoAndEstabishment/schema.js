import INTG_MSG from "@salesforce/schema/IntgMsg__c";
import NAME from "@salesforce/schema/IntgMsg__c.Name";
import REF_ID from "@salesforce/schema/IntgMsg__c.RefId__c";
import BU from "@salesforce/schema/IntgMsg__c.BU__c";
import IS_ACTIVE from "@salesforce/schema/IntgMsg__c.IsActive__c";
import SVC from "@salesforce/schema/IntgMsg__c.Svc__c";
import EXUC_TYPE from "@salesforce/schema/IntgMsg__c.ExecType__c";
import STATUS from "@salesforce/schema/IntgMsg__c.Status__c";
import REF_OBJ from "@salesforce/schema/IntgMsg__c.RefObj__c";
import DOC_API from "@salesforce/schema/IntgMsg__c.DocApi__c";
import OUTBOUND from "@salesforce/schema/IntgMsg__c.Outbound__c";
import PARENT_REF_ID from "@salesforce/schema/IntgMsg__c.ParentRefId__c";
import PARENT_REF_OBJ from "@salesforce/schema/IntgMsg__c.ParentRefObj__c";
import TRIGGER_PLATFORM_EVENT from "@salesforce/schema/IntgMsg__c.Trigger_Platform_Event__c";
import FILE_NO from "@salesforce/schema/ApplKyc__c.FileNo__c";
import DATE_OF_BIRTH from "@salesforce/schema/ApplKyc__c.DtOfBirth__c";
import DL_EXP_DATE from "@salesforce/schema/ApplKyc__c.DLExpDt__c";
import PASS_EXP_DATE from "@salesforce/schema/ApplKyc__c.PassExpDt__c";
import PASS_NO from "@salesforce/schema/ApplKyc__c.PassNo__c";
import VOTER_EPIC_NO from "@salesforce/schema/ApplKyc__c.VotIdEpicNo__c";
import DL_NO from "@salesforce/schema/ApplKyc__c.DLNo__c";
import APP_KYC_ID from "@salesforce/schema/ApplKyc__c.Id";
import PAN from "@salesforce/schema/ApplKyc__c.Pan__c";
import AADHAR from "@salesforce/schema/ApplKyc__c.AadharNo__c";
import AADHAR_ENCRIPTED from "@salesforce/schema/ApplKyc__c.AadharEncripted__c";
import OTP from "@salesforce/schema/ApplKyc__c.OTP__c";
import OTP_COUNT from "@salesforce/schema/ApplKyc__c.OTP_Count__c";
import NPR_Number from "@salesforce/schema/ApplKyc__c.NPRNumber__c";
import APPLICANT_ID from "@salesforce/schema/Applicant__c.Id";
import APPLICANT_ID_PROOF_Type from "@salesforce/schema/Applicant__c.ID_proof_type__c";
import APPLICANT_ID_PROOF_NO from "@salesforce/schema/Applicant__c.ID_Number__c";
import DocDet_ID from "@salesforce/schema/DocDtl__c.Id";
import Utility_Bill_Date from "@salesforce/schema/DocDtl__c.UtilityBillDate__c";
import Shop_N_Establishment_Date from "@salesforce/schema/DocDtl__c.ShopAndEstablishmentDate__c";
import Date_Of_Expiry from "@salesforce/schema/ApplKyc__c.DtOfExp__c";
import AREA from "@salesforce/schema/ApplKyc__c.Area__c";
import AREA_CODE from "@salesforce/schema/ApplKyc__c.AreaCode__c";
import REG_NUMBER from "@salesforce/schema/ApplKyc__c.RegNo__c";
import SVC_PROVIDER from "@salesforce/schema/ApplKyc__c.SvcProvider__c";
import SVC_PROVIDER_CODE from "@salesforce/schema/ApplKyc__c.ScvProviderCode__c";
import CONSUMER_ID from "@salesforce/schema/ApplKyc__c.ConsumerId__c";
import BILL_DIST from "@salesforce/schema/ApplKyc__c.BillDist__c";


export const SCHEMA = {
    INTG_MSG: INTG_MSG,
    NAME: NAME,
    REF_ID: REF_ID,
    BU: BU,
    IS_ACTIVE: IS_ACTIVE,
    SVC: SVC,
    EXUC_TYPE: EXUC_TYPE,
    STATUS: STATUS,
    REF_OBJ: REF_OBJ,
    DOC_API: DOC_API,
    OUTBOUND: OUTBOUND,
    PARENT_REF_ID: PARENT_REF_ID,
    PARENT_REF_OBJ: PARENT_REF_OBJ,
    TRIGGER_PLATFORM_EVENT: TRIGGER_PLATFORM_EVENT,
    FILE_NO: FILE_NO,
    DATE_OF_BIRTH: DATE_OF_BIRTH,
    DL_EXP_DATE: DL_EXP_DATE,
    PASS_EXP_DATE: PASS_EXP_DATE,
    PASS_NO: PASS_NO,
    VOTER_EPIC_NO: VOTER_EPIC_NO,
    DL_NO: DL_NO,
    APP_KYC_ID: APP_KYC_ID,
    PAN: PAN,
    AADHAR: AADHAR,
    AADHAR_ENCRIPTED: AADHAR_ENCRIPTED,
    OTP: OTP,
    OTP_COUNT: OTP_COUNT,
    NPR_Number: NPR_Number,
    APPLICANT_ID: APPLICANT_ID,
    APPLICANT_ID_PROOF_Type: APPLICANT_ID_PROOF_Type,
    APPLICANT_ID_PROOF_NO: APPLICANT_ID_PROOF_NO,
    DocDet_ID: DocDet_ID,
    Utility_Bill_Date: Utility_Bill_Date,
    Shop_N_Establishment_Date: Shop_N_Establishment_Date,
    Date_Of_Expiry: Date_Of_Expiry,
    AREA: AREA,
    AREA_CODE: AREA_CODE,
    REG_NUMBER: REG_NUMBER,
    SVC_PROVIDER: SVC_PROVIDER,
    SVC_PROVIDER_CODE: SVC_PROVIDER_CODE,
    CONSUMER_ID: CONSUMER_ID,
    BILL_DIST: BILL_DIST
}