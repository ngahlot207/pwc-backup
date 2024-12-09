import { LightningElement, wire, api, track } from "lwc";
import getProductMappings from "@salesforce/apex/DataSearchClass.getProductMappings";
import getAccountDetails from "@salesforce/apex/DataSearchClass.getAccountDetails";
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import getProducts from "@salesforce/apex/DataSearchClass.getProducts";
import getAssetPropType from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import getSobjectData from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData";
import getSobjectDataWithoutCacheable from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataWithoutCacheable';
import deletebtLoanRecord from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';
import upsertSobjDataWIthRelatedChilds from '@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds';
import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";
import getSobjectDatawithRelatedRecords from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords';
import getRelatedFilesFinancialByRecordIdWire from '@salesforce/apex/FinancialFileUploadClass.getRelatedFilesFinancialByRecordIdWire';
import deleteDocRecord from '@salesforce/apex/DocumentDetailController.deleteDocDetWithCdl';
import getDataForFilterChild from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithFilterRelatedRecords';
import { formatDateFunction, formattedDateTimeWithoutSeconds } from 'c/dateUtility';

import {
  subscribe,
  publish,
  MessageContext,
  APPLICATION_SCOPE
} from "lightning/messageService";
import createLeadRecord from "@salesforce/apex/LeadHandler.createLeadRecord";
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
//import {FlowAttributeChangeEvent, FlowNavigationNextEvent} from 'lightning/flowSupport';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import {
  getObjectInfo,
  getPicklistValues,
  getPicklistValuesByRecordType
} from "lightning/uiObjectInfoApi";

//Lead Object & Fields
import LEAD_OBJECT from "@salesforce/schema/Lead";
import ACCOUNT_OBJECT from "@salesforce/schema/Account";
import LA_OBJECT from "@salesforce/schema/LoanAppl__c";
import TeamHier_OBJECT from "@salesforce/schema/TeamHierarchy__c";
import ProdMap_OBJECT from "@salesforce/schema/ProdMap__c";
import SFDC_LEAD_REF_NO_FIELD from "@salesforce/schema/LoanAppl__c.LeadId__c";
import LEAD_FIELD from "@salesforce/schema/LoanAppl__c.Lead__c";
import STAGE_FIELD from "@salesforce/schema/LoanAppl__c.Stage__c";
import SUB_STAGE_FIELD from "@salesforce/schema/LoanAppl__c.SubStage__c";
import LEAD_SOURCE_FIELD from "@salesforce/schema/LoanAppl__c.LeadSource__c";
import LMS_LEAD_ID_FIELD from "@salesforce/schema/LoanAppl__c.LMSLeadId__c";
import BRANCH_CODE_FIELD from "@salesforce/schema/LoanAppl__c.BrchCode__c";
import BRANCH_NAME_FIELD from "@salesforce/schema/LoanAppl__c.BrchName__c";
import RM_SM_NAME_FIELD from "@salesforce/schema/LoanAppl__c.RM__c";
import RM_SM_EMPL_ID_FIELD from "@salesforce/schema/LoanAppl__c.RMSMEmployeeID__c";
import REFERREL_EMP_CODE_FIELD from "@salesforce/schema/LoanAppl__c.RefEmpCode__c";
import CHANNEL_NAME_FIELD from "@salesforce/schema/LoanAppl__c.ChanelNme__c";
import CHANNEL_CODE_FIELD from "@salesforce/schema/LoanAppl__c.ChannelCode__c";
import PRODUCT_FIELD from "@salesforce/schema/LoanAppl__c.Product__c";
import PRODUCT_SUB_TYPE_FIELD from "@salesforce/schema/LoanAppl__c.ProductSubType__c";
import SCHEME_FIELD from "@salesforce/schema/LoanAppl__c.SchmCode__c";
import PROMOTION_FIELD from "@salesforce/schema/LoanAppl__c.PromCode__c";
import LOAN_PURPOSE_FIELD from "@salesforce/schema/LoanAppl__c.LoanPurpose__c";
import REQUESTED_LOAN_AMOUNT_FIELD from "@salesforce/schema/LoanAppl__c.ReqLoanAmt__c";
import REQUESTED_TENR_IN_MONTHS_FIELD from "@salesforce/schema/LoanAppl__c.ReqTenInMonths__c";
import BT_FINANCIER_FIELD from "@salesforce/schema/LoanAppl__c.BTFinancr__c";
import OTHER_BT_FINANCIER_FIELD from "@salesforce/schema/LoanAppl__c.OthrBTFinancr__c";
import BT_LOAN_AMOUNT_FIELD from "@salesforce/schema/LoanAppl__c.BTLoanAmt__c";
import BT_LOAN_OUTSTND_VAL_FIELD from "@salesforce/schema/LoanAppl__c.BTLoanOutstndVal__c";
import EXISTNG_FF_LOAN_ACC_NO_FIELD from "@salesforce/schema/LoanAppl__c.ExistngFedFinaLoanAccNo__c";
import ASSESED_INCOME_APPL_CheckBox from "@salesforce/schema/LoanAppl__c.AssessedIncAppln__c";
import ASSESED_INCOME_APPL_FIELD from "@salesforce/schema/LoanAppl__c.AssesIncomeAppl__c";
import DUE_DAY_FIELD from "@salesforce/schema/LoanAppl__c.DueDay__c";
import SCHEME_ID from "@salesforce/schema/LoanAppl__c.SchemeId__c";
import PROMOTION_ID from "@salesforce/schema/LoanAppl__c.PromotionId__c";
import CREATED_DATE from "@salesforce/schema/LoanAppl__c.formatCreateDate__c";
import LOAN_PURPOSE_ID from "@salesforce/schema/LoanAppl__c.LoanPurposeId__c";
import BT_FINANCIER_ID from "@salesforce/schema/LoanAppl__c.BTFinancierId__c";
import LOGIN_ACCEPT_DATE from "@salesforce/schema/LoanAppl__c.LoginAcceptDate__c";
import LEAD_SOURCE from "@salesforce/schema/Lead.LeadSource";
import CUSTOMER_PROFILE from "@salesforce/schema/Lead.Customer_Profile__c";
import PROPERTY_CATEGORY from "@salesforce/schema/Lead.Property_Category__c";
import PRODUCT_TYPE from "@salesforce/schema/TeamHierarchy__c.Product_Type__c";
import PRODUCT_SUB_TYPE from "@salesforce/schema/ProdMap__c.ProdSubType__c";
import IsBT from "@salesforce/schema/SchMapping__c.IsBT__c";
import IsFIXED from "@salesforce/schema/SchMapping__c.IsFixed__c";
import SELLER_BT from "@salesforce/schema/SchMapping__c.SellarBT__c";
import IS_INTERNAL_TOP_UP from "@salesforce/schema/SchMapping__c.IsInternalTopUp__c";
import PRODUCT_SUB_TYP_SCEME from "@salesforce/schema/SchMapping__c.ProductSubType__c";
import MAX_AMOUNT from "@salesforce/schema/SchMapping__c.MaxAmtFin__c";
import MIN_AMOUNT from "@salesforce/schema/SchMapping__c.MinAmtFin__c";
import MAX_TENURE from "@salesforce/schema/SchMapping__c.MaxTenure__c";
import MIN_TENURE from "@salesforce/schema/SchMapping__c.MinTenure__c";
import SCHEME_ID_FIELD from "@salesforce/schema/SchMapping__c.SchmId__c";
import PRIME_TYPE from "@salesforce/schema/SchMapping__c.PrimeType__c";
import FLOATING_RATE_TYPE from "@salesforce/schema/SchMapping__c.FloatingRateFlag__c";
import APPLICABLE_OWN_CONTRI from "@salesforce/schema/SchMapping__c.ApplicableOwnContribution__c";
import DSA_CONN_ID from "@salesforce/schema/Account.DSAConnId__c";
import VC_REFF_ID from "@salesforce/schema/Account.VCReferralCode__c";
import REPAYMENT_FREQUENCY from "@salesforce/schema/LoanAppl__c.Repayment_Frequency__c";
import Installment_Plan from "@salesforce/schema/LoanAppl__c.Installment_Plan__c";
import LOAN_PLR_RATE from "@salesforce/schema/LoanAppl__c.LoanPLRRate__c";
import LOAN_PLR_TYPE from "@salesforce/schema/LoanAppl__c.LoanPLRType__c";
import PLR_RATE from "@salesforce/schema/LoanAppl__c.Rate_Type_Floating_Flag__c";
import EFFECTIVE_ROI from "@salesforce/schema/LoanAppl__c.EffectiveROI__c";
import REVISED_ROI from "@salesforce/schema/LoanAppl__c.RevisedROI__c";
import SPREAD_ID from "@salesforce/schema/LoanAppl__c.SpreadID__c";
import HOLD_REASON from "@salesforce/schema/LoanAppl__c.Hold_Reason__c";
import OTHER_REASON from "@salesforce/schema/LoanAppl__c.Additional_Comments__c";
import REJECT_REASON from "@salesforce/schema/LoanAppl__c.RejectReason__c";
import CANCEL_REASON from "@salesforce/schema/LoanAppl__c.Cancel_Reason__c";
import STATUS from "@salesforce/schema/LoanAppl__c.Status__c";
import LOAN_TAKEOVER from "@salesforce/schema/LoanAppl__c.LoanTakeOverofRegMortgage__c";
import REQ_INTEREST_TYPE from "@salesforce/schema/LoanAppl__c.ReqInterestType__c";
import LEAD_ROI from "@salesforce/schema/LoanAppl__c.LeadROI__c";



import currentDateorFinnOneDate from "@salesforce/schema/LoanAppl__c.currentDateorFinnOneDate__c";
import First_EMI_Due_Month_1 from "@salesforce/schema/LoanAppl__c.First_EMI_Due_Month_1__c";
import First_EMI_Due_Year_1 from "@salesforce/schema/LoanAppl__c.First_EMI_Due_Year_1__c";


import TOTAL_LOAN_AMT from "@salesforce/schema/LoanAppl__c.TotalLoanAmtInclInsurance__c";
import DISBURSAL_TYPE from "@salesforce/schema/LoanAppl__c.DisbursalType__c";
import EMI_INC_INS from "@salesforce/schema/LoanAppl__c.EMIIcludingInsurance__c";
import EFF_INT_START from "@salesforce/schema/LoanAppl__c.EffectiveNextIntStartDt__c";
import DUE_MONTH from "@salesforce/schema/LoanAppl__c.FirstEMIDueMonth__c";
import DUE_YEAR from "@salesforce/schema/LoanAppl__c.FirstEMIDueYear__c";
import FIRST_EMI_DATE from "@salesforce/schema/LoanAppl__c.FirstEMIDate__c";
import PRE_EMI_TYPE from "@salesforce/schema/LoanAppl__c.PreEmiType__c";

import MORATORIUM_APPL from "@salesforce/schema/LoanAppl__c.MoratGraceApplicable__c";
import MORATORIUM_GRACE from "@salesforce/schema/LoanAppl__c.MoratGracePeriodMonths__c";
import IMPACT_TENURE from "@salesforce/schema/LoanAppl__c.ImpactOnTenure__c";
import CHARGE_INT from "@salesforce/schema/LoanAppl__c.ChargeInterest__c";
import ADDL_INT_SCH from "@salesforce/schema/LoanAppl__c.AddIntSchedule__c";

import IS_IT_SELL_BAL from "@salesforce/schema/LoanAppl__c.IsitSellerBalTransferTransaction__c";
import IS_SELL_LIST_DOC_AVAL from "@salesforce/schema/LoanAppl__c.IsSellerListDocLODAvl__c";
import IS_FORCLOSURE from "@salesforce/schema/LoanAppl__c.IsSellerBTLoanForeclosureAmt__c";
import DOC_REPORT_MATCH from "@salesforce/schema/LoanAppl__c.DocAsPerLegalReportMatches__c";
import SALE_DEED from "@salesforce/schema/LoanAppl__c.SaleDeedBetnBuyerBorr__c";
import OWN_CONTRI from "@salesforce/schema/LoanAppl__c.OwnContriPaid__c";
import LETTER_FROM_SELLER from "@salesforce/schema/LoanAppl__c.LetterFomSellerBTFinancier__c";
import CHQ_AMT from "@salesforce/schema/LoanAppl__c.ChequeForAmtEquiBTAmt__c";
import IS_IT_REFINANCE from "@salesforce/schema/LoanAppl__c.IsItRefinanceTransaction__c";
import SELLER_VER_KYC from "@salesforce/schema/LoanAppl__c.SellerVerificationKYCSellerTaken__c";
import SELLER_VER_CRED from "@salesforce/schema/LoanAppl__c.SellerVerCredTeleChk__c";
import ALL_SELLER_BT from "@salesforce/schema/LoanAppl__c.AllSellerBTNormMet__c";
import REFINANCE_AGREE_DATE from "@salesforce/schema/LoanAppl__c.RefinanceSaleAgreementDate__c";
import PERIOD_SINCE_AGREE_EXE from "@salesforce/schema/LoanAppl__c.PeriodSinceSaleAgreementExecuted__c";
import SALE_AGREE from "@salesforce/schema/LoanAppl__c.RefinanceSaleAgreementAmt__c";
import PAYMENT_6_CASH from "@salesforce/schema/LoanAppl__c.PaymentDoneInLast6MonthsCash__c";
import PAYMENT_6_BANK from "@salesforce/schema/LoanAppl__c.PaymentDoneInLast6MonthsBank__c";
import PAYMENT_12_CASH from "@salesforce/schema/LoanAppl__c.PaymentDoneInLast12MonthsCash__c";
import PAYMENT_12_BANK from "@salesforce/schema/LoanAppl__c.PaymentDoneInLast12MonthsBank__c";
import BAL_TRANS_FIN_STATUS from "@salesforce/schema/LoanAppl__c.BalTransferFinaStatus__c";
import BRANCH_TIER from "@salesforce/schema/LoanAppl__c.BranchTier__c";
import RATE_EMI_FLAG from "@salesforce/schema/LoanAppl__c.RateEMIFlag__c";
import EMI_OPTIONS_TRANCHE from "@salesforce/schema/LoanAppl__c.EMIOptionsintranchedisbursementCase__c";
import FILE_ACCEPT_OPTIONS from "@salesforce/schema/LoanAppl__c.CPASubSt__c";
import FINONE_LOAN_NO from "@salesforce/schema/LoanAppl__c.Finnone_Loan_Number__c";
import SANCTION_DATE from "@salesforce/schema/LoanAppl__c.FirstApprovalDate__c";
import OWN_CONTRI_BANK from "@salesforce/schema/LoanAppl__c.OwnContriBank__c";
import OWN_CONTRI_CASH from "@salesforce/schema/LoanAppl__c.OwnContriCash__c";
import TOTAL_CONTRI from "@salesforce/schema/LoanAppl__c.TotalOwnContri__c";
import TOTAL_PROP_COST from "@salesforce/schema/LoanAppl__c.TotalPropertyCost__c";
import SANCT_AMT from "@salesforce/schema/LoanAppl__c.SanLoanAmt__c";
import INTRST_WAIVER from "@salesforce/schema/LoanAppl__c.InterestWaiverTaken__c"; //LAK-4925
import OPS_STATUS from "@salesforce/schema/LoanAppl__c.OpsStatus__c"; //LAK-166
import CLONED_FOR from "@salesforce/schema/LoanAppl__c.ClonedForLAN__c"; 
import APPLCIATION_FORM_NO from "@salesforce/schema/LoanAppl__c.Application_Form_No__c";
import APPLCIATION_FORM_DATE from "@salesforce/schema/LoanAppl__c.Application_Form_Date__c";

// import LOC_MASTER from "@salesforce/schema/LoanAppl__c.LocMstr__c"; 
// import BRANCH from "@salesforce/schema/LoanAppl__c.Branch__c"; 
 import RM_SM_NAME from "@salesforce/schema/LoanAppl__c.RMSMName__c"; 
//LAK-5718
import INTWAIVERAPPROVER from "@salesforce/schema/LoanAppl__c.IntWaiverApprover__c";




import LoanDetailsSaved from '@salesforce/label/c.LoanDetailsSaved';
import LoanDetailsError from '@salesforce/label/c.LoanDetailsError';
import LoanDetailsErrorWithoutPermission from '@salesforce/label/c.LoanDetailsErrorWithoutPermission';
import LoanDetailsReqFieldsError from '@salesforce/label/c.LoanDetailsReqFieldsError';

import BTFinancierDeleteSuccess from '@salesforce/label/c.BTFinancierDeleteSuccess';
import BTFinancierRequired from '@salesforce/label/c.BTFinancierRequired';
import BTFinancierDuplicateRecordError from '@salesforce/label/c.BTFinancierDuplicateRecordError';
import BTFinancierAddedSuccess from '@salesforce/label/c.BTFinancierAddedSuccess';
import BTFinancierRequiredFields from '@salesforce/label/c.BTFinancierRequiredFields';

import { NavigationMixin } from "lightning/navigation";
import {
  getRecord,
  getFieldValue,
  getFieldDisplayValue
} from "lightning/uiRecordApi";
import { createRecord, updateRecord } from "lightning/uiRecordApi";
import Id from "@salesforce/user/Id";
import formFactorPropertyName from "@salesforce/client/formFactor";

import { CPARoles } from 'c/globalConstant';

const fields = [
  LOGIN_ACCEPT_DATE,
  IS_IT_REFINANCE,
  IS_IT_SELL_BAL,
  IS_SELL_LIST_DOC_AVAL,
  IS_FORCLOSURE,
  DOC_REPORT_MATCH,
  SALE_DEED,
  OWN_CONTRI,
  LETTER_FROM_SELLER,
  CHQ_AMT,
  SELLER_VER_KYC,
  SELLER_VER_CRED,
  ALL_SELLER_BT,
  REFINANCE_AGREE_DATE,
  PERIOD_SINCE_AGREE_EXE,
  SALE_AGREE,
  PAYMENT_6_CASH,
  PAYMENT_6_BANK,
  PAYMENT_12_CASH,
  PAYMENT_12_BANK,
  BAL_TRANS_FIN_STATUS,
  BRANCH_TIER,
  RATE_EMI_FLAG,
  EMI_OPTIONS_TRANCHE,
  FILE_ACCEPT_OPTIONS,
  TOTAL_LOAN_AMT,
  DISBURSAL_TYPE,
  EMI_INC_INS,
  EFF_INT_START,
  DUE_MONTH,
  DUE_YEAR,
  FIRST_EMI_DATE,
  PRE_EMI_TYPE,
  MORATORIUM_APPL,
  MORATORIUM_GRACE,
  IMPACT_TENURE,
  CHARGE_INT,
  ADDL_INT_SCH,
  HOLD_REASON,
  REJECT_REASON,
  OTHER_REASON,
  CANCEL_REASON,
  STATUS,
  STAGE_FIELD,
  SUB_STAGE_FIELD,
  SFDC_LEAD_REF_NO_FIELD,
  LMS_LEAD_ID_FIELD,
  LEAD_SOURCE_FIELD,
  BRANCH_CODE_FIELD,
  BRANCH_NAME_FIELD,
  RM_SM_NAME_FIELD,
  RM_SM_EMPL_ID_FIELD,
  REFERREL_EMP_CODE_FIELD,
  CHANNEL_NAME_FIELD,
  CHANNEL_CODE_FIELD,
  PRODUCT_FIELD,
  PRODUCT_SUB_TYPE_FIELD,
  SCHEME_FIELD,
  PROMOTION_FIELD,
  LOAN_PURPOSE_FIELD,
  REQUESTED_LOAN_AMOUNT_FIELD,
  REQUESTED_TENR_IN_MONTHS_FIELD,
  BT_FINANCIER_FIELD,
  OTHER_BT_FINANCIER_FIELD,
  BT_LOAN_AMOUNT_FIELD,
  BT_LOAN_OUTSTND_VAL_FIELD,
  EXISTNG_FF_LOAN_ACC_NO_FIELD,
  ASSESED_INCOME_APPL_FIELD,
  SCHEME_ID,
  LOAN_PURPOSE_ID,
  PROMOTION_ID,
  BT_FINANCIER_ID,
  ASSESED_INCOME_APPL_CheckBox,
  REPAYMENT_FREQUENCY,
  Installment_Plan,
  DUE_DAY_FIELD,
  LEAD_FIELD,
  PLR_RATE,
  EFFECTIVE_ROI,
  REVISED_ROI,
  SPREAD_ID,
  LOAN_PLR_TYPE,
  LOAN_PLR_RATE,
  PLR_RATE,
  LOAN_TAKEOVER,
  REQ_INTEREST_TYPE,
  LEAD_ROI,
  currentDateorFinnOneDate,
  First_EMI_Due_Year_1,
  First_EMI_Due_Month_1,
  FINONE_LOAN_NO,
  SANCTION_DATE,
  OWN_CONTRI_BANK,
  OWN_CONTRI_CASH,
  TOTAL_CONTRI,
  TOTAL_PROP_COST,
  SANCT_AMT,
  INTRST_WAIVER,
  INTWAIVERAPPROVER,
  CREATED_DATE,
  OPS_STATUS,
  CLONED_FOR,
  APPLCIATION_FORM_NO,
  APPLCIATION_FORM_DATE


];

const schemeFileds = [
  IsBT,
  IsFIXED,
  SELLER_BT,
  MAX_AMOUNT,
  MIN_AMOUNT,
  MIN_TENURE,
  MAX_TENURE,
  IS_INTERNAL_TOP_UP,
  PRODUCT_SUB_TYP_SCEME,
  SCHEME_ID_FIELD,
  FLOATING_RATE_TYPE,
  PRIME_TYPE,
  APPLICABLE_OWN_CONTRI
];
const accountFileds = [DSA_CONN_ID, VC_REFF_ID];
const leadFields = [CUSTOMER_PROFILE, PROPERTY_CATEGORY];
import getData from "@salesforce/apex/DataSearchClass.getData";
import { refreshApex } from "@salesforce/apex";
import CreatedDate from "@salesforce/schema/Account.CreatedDate";

const DELAY = 1000;

export default class CaptureLoanDetails extends NavigationMixin(
  LightningElement
) {
  fieldsVal = fields;
  digitalValue = false;
  directValue = false;
  fedFinaEmpValue = false;
  dsaValue = false;
  searchResult1 = false;
  errorMessage1 = false;
  searchResult2 = false;
  errorMessage2 = false;
  searchResult = false;
  errorMessage = false;
  requiredFlag = true;

  leadValueOptions = [];
  picklistOptions = [];
  resultData = [];
  productOptions = [];
  productSubTypeOptions = [];
  accountRecordTypes = [];
  assesedOptions = [
    { value: "Yes", label: "Yes" },
    { value: "No", label: "No" }
  ];
  rePaymentFrequencyOption = [];
  installmentPlanOption = [];
  rateTypeFloatingFlag = [];
  @track loggedInUser = Id;
  @api searchInput = "";
  @api layoutSize;
  @api isReadOnly;
  @api hasEditAccess;
  @track currentUserId = Id;
  @track disableMode;
  lmsLeadIdRequiredFlag;
  @track hideChannel = true;
  @track hideLMSId;
  @track hideBT;
  @track isFixed;
  @track isSellerBt;
  @track showSpinner = false;
  @track loginAccept;
  //@track erroMsg = "Non numeric value should not be accepted";
  @track showOtherBT;
  @track showExtFedAcc;
  @track filterCondition;
  @track filterConditionPromotion;
  @track filtCondnLoanPurpose;
  @track dsaRecordTypeId;
  @track connectorRecordTypeId;
  @track fedFinaEmp;
  @track channelFlag = true;
  @track formFactor = formFactorPropertyName;
  @track errorOverflowMsg;
  @track errorUnderflowMsg;
  @track maxTenureError;
  @track minTenureError;
  @track productSubTypeNew;
  @track custProf;
  @track leadId;
  @track effectiveRoi;
  @track finoneLoanNo;
  @track sanctDate;
  @track ownContriBank;
  @track ownContriCash;
  @track totalContri;
  @track totalPropCost;
  @track sanctAmt;
  @track loanCreatedDate;
  @track loanCreatedDateTime;
  desktopBoolean = false;
  phoneBolean = false;
  salesEmp;
  filterConditionForLookup;

  @track _recordId;
  @api get recordId() {
    return this._recordId;
  }
  set recordId(value) {
    this._recordId = value;
    this.setAttribute("recordId", value);
    this.handleRecordIdChange(value);
  }

  
  @track sfdcLeadRefNo;
  leadSource;
  @track stage;
  @track subStage;
  //@track showDDEFields;
  @track showHoldReason;
  @track showRejectReason;
  @track showCancelReason;
  @track cancelReasonValue;
  @track cancelReasonOtherValue;
  @track showCancelReasonOther;
  @track schemeId;
  @track channelId;
  @track applicableOwnContri;
  //@track ownContriFlag;
  @track productValue;
  @track spreadIdVal;
  @track metaCustProf;
  @track rackRate;
  @track addRateCatg;
  @track addMstTkt;
  @track dueDay;
  @track loanTakeover;
  @track reqIntType = 'E';
  @track LeadRoi;
  @track status;
  @track fileAcceptValue;
  @track opsStatus;
  @track clonedLAN;
  @track intrstWaiverValue;
  @track intrstWaiverApprover; //LAK-5718
  @track disbTypeOptions = [];
  @track monthOptions = [];
  @track yearOptions = [];
  @track emiTypeOptions = [];
  @track graceAppOptions = [];
  @track graceMonthOptions = [];
  @track impTenOptions = [];
  @track chargeIntOptions = [];
  @track addlIntOptions = [];
  @track emiTrancheOptions = [];
  @track fileAcceptOptions = [];
  @track interestWaiverOptions = [];

  @track totalAmtIncIns;
  @track firstEMI;
  @track emiType;
  @track graceApp = 'N';
  @track gracePeriod;
  @track impactTen;
  @track chargeInt;
  @track addlInt;
  @track rateEmiFlag;

  @track balTransOptions = [];
  @track sellListDocOptions = [];

  @track legalRepOptions = [];
  @track saleDeedOptions = [];
  @track forclosureOptions = [];
  @track ownContriOptions = [];
  @track letterFormOptions = [];
  @track chqEquOptions = [];
  @track sellerVerOptions = [];
  @track sellerVerCredOptions = [];
  @track balTransStatusOptions = [];
  @track rateEmiFlagOptions = [];

  @track sellBt;
  @track refinance;
  @track agreeDate;
  @track agreeError;
  @track emiTrache;
  @track shwoBtTable = false;
  lmsLeadId;
  branchCode;
  branchName;
  rmsmName;
  rmsmEmpId;
  @track channelName;
  channelCode;
  referralEmployeeCode;
  product;
  productSubType;
  scheme;
  @track promotion;
  loanPurpose;
  reqLoanAmount;
  reqLoanTenInMonths;
  btFinancier;
  otherBTFinancier;
  btLoanAmount;
  btLoanOutstnadingValue;
  minAmt;
  maxAmt;
  maxTenure;
  minTenure;
  isInterTopUp;
  schSubType;
  disbType;
  emiIncIns;
  effIntStartDt;
  emiMonth;
  emiYear;
  label = {
    LoanDetailsSaved,
    LoanDetailsError,
    LoanDetailsErrorWithoutPermission,
    LoanDetailsReqFieldsError,
    BTFinancierDeleteSuccess,
    BTFinancierRequired,
    BTFinancierDuplicateRecordError,
    BTFinancierAddedSuccess,
    BTFinancierRequiredFields
  };

  @track currentDate = new Date().toJSON().slice(0, 10);

  @track wrpLoanApp = {};

  @track rackRateMst = {
    ParentObjectName: "Rack_Rate_Master__mdt",
    ChildObjectRelName: "",
    parentObjFields: [
      "Id",
      "Label",
      "Customer_Profile__c",
      "Product__c",
      "Product_Sub_Type__c",
      "Rack_Rate__c"
    ],
    childObjFields: [],
    queryCriteria: ""
  };

  @track addlRateMst = {
    ParentObjectName: "Additional_rate_Master__mdt",
    ChildObjectRelName: "",
    parentObjFields: [
      "Id",
      "DeveloperName",
      "Label",
      "Additional_Rate__c",
      "Max_Amount__c",
      "Min_Amount__c"
    ],
    childObjFields: [],
    queryCriteria: ""
  };

  // @track floatingRate = {
  //   ParentObjectName: "SchMapping__c",
  //   ChildObjectRelName: "",
  //   parentObjFields: ["Id", "SchmId__c", "PrimeType__c", "FloatingRateFlag__c"],
  //   childObjFields: [],
  //   queryCriteria: ' where SchmId__c = \''+ this.schmMapId + '\''
  // };

  @track primeTypeParams = {
    ParentObjectName: "PLRRateMapping__c",
    ChildObjectRelName: "",
    parentObjFields: ["Id", "PLR_Rate__c", "PLR_Type__c"],
    childObjFields: [],
    queryCriteria: ""
  };
  //existingFFLoanAccNo;
  assesedIncomeAppl;

  @wire(MessageContext)
  MessageContext;

  connectedCallback() {
    this.showSpinner=true;

    this.getBtLoanRecords();
    this.checkIfCpaUser();
    if (
      this.productValue &&
      this.wrpLoanApp.productSubType &&
      this.metaCustProf
    ) {
      let tempParams = this.rackRateMst;
      tempParams.queryCriteria =
        " where Product__c =  '" +
        this.productValue +
        "' AND Product_Sub_Type__c = '" +
        this.wrpLoanApp.productSubType +
        "' AND Customer_Profile__c = '" +
        this.metaCustProf +
        "'";
      this.rackRateMst = { ...tempParams };
    }

    console.log("isReadOnly:::::::: ", this.isReadOnly);
    console.log("hasEditAccess:::::::: ", this.hasEditAccess);
    if (this.hasEditAccess === false) {
      this.disableMode = true;
      this.disableDocumentUpload = true;
      this.deleteIconDisabled = true;
    }
    if (this.formFactor === "Large") {
      this.desktopBoolean = true;
      this.phoneBolean = false;
    } else if (this.formFactor === "Small") {
      this.desktopBoolean = false;
      this.phoneBolean = true;
    } else {
      this.desktopBoolean = false;
      this.phoneBolean = true;
    }

    this.sunscribeToMessageChannel();
    this.getTeamHierarchyData();
    this.getLoanTatData(); 
  }

  @track eligibiltyProOptions = [];
  @track eligibiltyProgramValue;
  getEligibiltyProgramDetails(appProfile,product){
    this.showSpinner  = true;
    let type = 'Eligibility Program';
    let params = {
        ParentObjectName: 'MasterData__c',
        parentObjFields: ['Id', 'Name','SalesforceCode__c','Type__c','Product__c','CustomerProfile__c'],
        queryCriteria: ' where Type__c = \'' + type + '\' AND CustomerProfile__c = \'' + appProfile + '\' AND Product__c INCLUDES (\'' + product + '\')'
    }
    getSobjectData({ params: params })
        .then((result) => {
            // this.showSpinner = true;
            console.log('Master Data is ', JSON.stringify(result));
            if (result.parentRecords) {
              result.parentRecords.forEach((child) => {
                let option = { label: child.Name, value: child.SalesforceCode__c };
                this.eligibiltyProOptions = [...this.eligibiltyProOptions, option];
                this.eligibiltyProOptions.sort(this.compareByLabel);
            });
            }
  
           this.showSpinner = false;
        })
        .catch((error) => {
            this.showSpinner = false;
            console.log('Error In getting Master Data is ', error);
            //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
        });
  }
   //method to sort array of objects alphabetically
   compareByLabel(a, b) {
    const nameA = a.label.toUpperCase();
    const nameB = b.label.toUpperCase();
    if (nameA < nameB) {
        return -1;
    }
    if (nameA > nameB) {
        return 1;
    }
    return 0;
}
  @track searchInputName;
  @track appCustProfile;
  getLoanTatData(){
    this.showSpinner  = true;
        let params = {
            ParentObjectName: 'LoanAppl__c',
            parentObjFields: ['Id', 'Stage__c','SubStage__c','Branch__c','LocMstr__c','RMSMName__c','ChanelNme__c','ChanelNme__r.Name','Product__c','Applicant__c','Applicant__r.CustProfile__c','EligibilityProgram__c'],
            queryCriteria: ' where Id = \'' + this.recordId + '\''
        }
        getSobjectData({ params: params })
            .then((result) => {
                // this.showSpinner = true;
                console.log('Loan App Data is ', JSON.stringify(result));
                if (result.parentRecords) {
                  this.selectDSACityId = result.parentRecords[0].LocMstr__c ? result.parentRecords[0].LocMstr__c : '';
                  this.selectDSABranchId = result.parentRecords[0].Branch__c ? result.parentRecords[0].Branch__c : '';
                  this.selectedDsaRmId = result.parentRecords[0].RMSMName__c ? result.parentRecords[0].RMSMName__c : '';
                  this.searchInputName = result.parentRecords[0].ChanelNme__c? result.parentRecords[0].ChanelNme__r.Name : "";
                 this.eligibiltyProgramValue = result.parentRecords[0].EligibilityProgram__c ? result.parentRecords[0].EligibilityProgram__c : "";
                  this.appCustProfile = result.parentRecords[0].Applicant__c ? result.parentRecords[0].Applicant__r.CustProfile__c : "";
                 if(result.parentRecords[0].Product__c && (result.parentRecords[0].Product__c === 'Business Loan' || result.parentRecords[0].Product__c === 'Personal Loan') && result.parentRecords[0].Applicant__c && result.parentRecords[0].Applicant__r.CustProfile__c){
                    this.getEligibiltyProgramDetails(result.parentRecords[0].Applicant__r.CustProfile__c,result.parentRecords[0].Product__c);
                  }
                }

                //  this.selectDSACityId = data.fields.LocMstr__c.value
        // ? data.fields.LocMstr__c.value
        // : "";
        // this.selectDSABranchId = data.fields.Branch__c.value
        // ? data.fields.Branch__c.value
        // : "";
        if(this.selectDSABranchId){
          this.getLocBranJunId();
        }  
        // this.selectedDsaRmId = data.fields.RMSMName__c.value
        // ? data.fields.RMSMName__c.value
        // : "";
        if(this.selectedDsaRmId){
          this.getteamHierarchyId();
        }
        this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting Loan App Data is ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    
}

   @track isDsaUser = false;
   @track isCpaUser = false;
   @track empRole;
   @track loggedInUSerCityId;
   getTeamHierarchyData() {
    let paramsLoanApp = {
        ParentObjectName: 'TeamHierarchy__c',
        parentObjFields: ['Id', 'Employee__c', 'EmpRole__c','EmpLoc__c','EmpBrch__c'],
        queryCriteria: ' where Employee__c = \'' + this.currentUserId + '\' AND EmpRole__c != null ORDER BY LastModifiedDate DESC'
    }
    getSobjectData({ params: paramsLoanApp })
        .then((result) => {
            console.log('team hierarchy data is', JSON.stringify(result.parentRecords));
            if (result.parentRecords) {
              this.empRole = result.parentRecords[0].EmpRole__c;
              this.loggedInUSerCityId = result.parentRecords[0].EmpBrch__c;
                if(result.parentRecords[0].EmpRole__c && result.parentRecords[0].EmpRole__c === 'DSA'){
                  this.isDsaUser = true;
                }
            }
            this.showSpinner = false;
            console.log('this.isDsaUser', this.isDsaUser);
        })
        .catch((error) => {
            this.showSpinner = false;
            console.log('Error In getting team hierarchy details ', error);
            //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
        });
}



checkIfCpaUser() {
  // Define the parameters for the query to get the user's role
  let params = {
      ParentObjectName: 'TeamHierarchy__c',
      parentObjFields: ['Id', 'Employee__c', 'EmpRole__c'],
      queryCriteria: ' where Employee__c = \'' + this.currentUserId + '\' AND EmpRole__c != null ORDER BY LastModifiedDate DESC'
  };

  // Make the call to getSobjectData to retrieve the user's role
  getSobjectData({ params: params })
      .then((result) => {
          if (result.parentRecords && result.parentRecords.length > 0) {
              // Check if the user's role is CPA
              if (CPARoles && CPARoles.includes(result.parentRecords[0].EmpRole__c)) {  //LAK-9244
                  this.isCpaUser = true;
                  this.disableMode = false;

                  console.log('User is CPA:', this.isCpaUser);
              } else {
                  this.isCpaUser = false;
                  // this.disableMode = true;


              }
          }
      })
      .catch((error) => {
          console.error('Error in checking CPA role:', error);
      });
}

@track errorMessage = ''; 
@track errorMessage3='';







// get hideBasedOnProd(){
//   if(this.wrpLoanApp.Product__c && (this.wrpLoanApp.Product__c === 'Personal Loan' || this.wrpLoanApp.Product__c === 'Business Loan')){
//       return true;
//   }
//   return false;
// }

// get disableFieldsOnProd(){
//   if((this.wrpLoanApp.Product__c && (this.wrpLoanApp.Product__c === 'Personal Loan' || this.wrpLoanApp.Product__c === 'Business Loan')) || this.isDsaUser){
//       return true;
//   }
//   return this.disableAll;
// }
@track selectDSACity;
@track selectDSACityId;
handleLookupFieldChange(event) {
    if (event.detail) {
        console.log('currentUserId====> ', this.currentUserId);
        console.log('Event detail in Sourcing Location Change====> ', event.detail);
        this.selectDSACity = event.detail.mainField;
        this.selectDSACityId = event.detail.id;
        this.wrpLoanApp.LocMstr__c = event.detail.id;
        console.log("selectDSACity>>>", this.selectDSACity);
    }
}

get disableBranch(){
    return this.isDsaUser && !this.selectDSACityId;
}
@track selectDSABranch;
@track selectDSABranchId;
handleBranchChange(event) {
    if (event.detail) {
        console.log('Event detail in Branch Change====> ', event.detail);
        this.selectDSABranch = event.detail.mainField;
        this.locationBranJnId = event.detail.id;
        this.selectDSABranchId = event.detail.record ? event.detail.record.Branch__c : '';
        this.wrpLoanApp.Branch__c = event.detail.record ? event.detail.record.Branch__c : '';
        this.wrpLoanApp.BrchCode__c = event.detail.record ? event.detail.record.Branch__r.BrchCode__c   : '';
        this.wrpLoanApp.BrchName__c = event.detail.record ? event.detail.record.Branch__r.Name   : '';
        console.log("selectDSABranch>>>", this.selectDSABranch);
        console.log("selectDSABranchId>>>", this.selectDSABranchId);
    }
}
get filterConditionForBranc() {
  let returVal ;
  if(this.wrpLoanApp.Product__c && (this.wrpLoanApp.Product__c === 'Business Loan' || this.wrpLoanApp.Product__c === 'Personal Loan')){
        returVal = ' Location__c = \'' + this.selectDSACityId + '\'';
    }else{
        if(this.empRole == 'RM' || this.empRole == 'DSA'){
        returVal = ' Branch__c = \'' + this.loggedInUSerCityId + '\'';
        }
        else{
          returVal = ' Employee__c = \'' + this.selectedDsaRmId + '\'';
        }
    }

  // if(this.empRole && this.empRole === 'DSA'){
  //     returVal = ' Location__c = \'' + this.selectDSACityId + '\'';
  // }
  return returVal;
}
get disableLeadSource(){
  return !(this.wrpLoanApp.Product__c === 'Business Loan' || this.wrpLoanApp.Product__c === 'Personal Loan')
}

get filterConditionForRM() {
  return 'EmpBrch__c = \'' + this.selectDSABranchId + '\' AND Product_Type__c INCLUDES (\'' + this.wrpLoanApp.Product__c + '\')';
}
@track selectedDsaRmId;
@track selectedDsaRm;
handleRmSelection(event) {
    if (event.detail) {
        console.log('Event detail in handleRmSelection====> ', event.detail);
        this.selectedDsaRm = event.detail.mainField;
        this.teamHierId = event.detail.id;
        this.selectedDsaRmId = event.detail.record.Employee__c;
        this.rmNameId = this.selectedDsaRmId;
        this.wrpLoanApp.RMSMName__c = event.detail.record.Employee__c;
        console.log("selectedDsaRmId>>>", this.selectedDsaRmId);
    }
}
get disableDSARM(){
  if(this.productValue && this.selectDSABranchId){
      return false;
  }
  return true;
}
  sunscribeToMessageChannel() {
    this.subscription = subscribe(
      this.MessageContext,
      SaveProcessCalled,
      (values) => this.handleSaveThroughLms(values)
    );
  }
  @track schmMapId;
  @track primeType;
  @track primeRate;
  
  @wire(getRecord, { recordId: "$schemeId", fields: schemeFileds })
  recordSchemesHandler({ data, error }) {
    if (data) {
      console.log("SCEHEM MAPPING RECORDS:::::::", data);
      this.hideBT = data.fields.IsBT__c.value;
      this.maxAmt = data.fields.MaxAmtFin__c.value;
      this.minAmt = data.fields.MinAmtFin__c.value;
      this.maxTenure = data.fields.MaxTenure__c.value;
      this.minTenure = data.fields.MinTenure__c.value;
      this.isInterTopUp = data.fields.IsInternalTopUp__c.value;
      this.schSubType = data.fields.ProductSubType__c.value;
      this.schmMapId = data.fields.SchmId__c.value;
      this.rateType = data.fields.FloatingRateFlag__c.value;
      this.primeType = data.fields.PrimeType__c.value;
      this.isFixed = data.fields.IsFixed__c.value;
      this.isSellerBt = data.fields.SellarBT__c.value;
      this.applicableOwnContri = data.fields.ApplicableOwnContribution__c.value;
      console.log("applicableOwnContri:::::", this.applicableOwnContri);
      this.errorOverflowMsg = "Maximum requested loan amount: " + this.maxAmt;
      this.errorUnderflowMsg = "Minimum requested loan amount: " + this.minAmt;
      this.maxTenureError = "Maximum tenure allowed: " + this.maxTenure;
      this.minTenureError = "Minimum tenure allowed: " + this.minTenure;

      if (this.primeType && !this.isFixed) {
        this.getPrimeRate();
      }
      if (this.hideBT === false) {
        this.showOtherBT = false;
        // this.loanTakeReq = false;
      }
      console.log(
        "SCEHEM MAPPING RECORDS:::::::",
        this.schSubType,
        this.wrpLoanApp.ProductSubType__c
      );
      if (
        (this.schSubType === this.wrpLoanApp.ProductSubType__c ||
          this.schSubType === null) &&
        this.isInterTopUp === true
      ) {
        this.showExtFedAcc = true;
      } else {
        this.showExtFedAcc = false;
      }
    }
    if (error) {
      console.log("ERROR::::::: #376", error);
    }
  }

  // LAK-6477 - As per this story 12 fields are updated as editable if user has edit access.
  get disableAll() {
    return this.hasEditAccess === false || (this.stage === 'Post Sanction' && this.subStage === 'UW Approval');
  }
  get showDDEFields() {
    return this.stage !== "QDE";
  }

  //LAK-7750 eff roi disable except qde and dde stage
  get disableEffRoi() {
    return this.disablemode === true || (this.stage !== 'QDE' && this.stage != 'DDE');
  }

  get showDueDay() {
    return this.wrpLoanApp.SchemeId__c && this.stage !== "QDE";
  }
  get showreason() {
    return this.status === "Hold";
  }
  get showCancel() {
    return this.status === "Cancelled";
  }
  get showOthserCancel() {
    return this.status === "Cancelled";
  }
  get showReject() {
    return this.status === "Rejected";
  }
  get postFields() {
    return this.stage === "Post Sanction" || this.stage === 'Disbursed' || this.stage === 'Disbursement Initiation';
  }

  get disbursalType() {
    return this.stage === "UnderWriting" || this.stage === "Post Sanction" || this.stage === 'Disbursed' || this.stage === 'Disbursement Initiation';
  }
  get postGraceAppFields() {
    return this.stage === "Post Sanction" && this.applicableOwnContri === true;
  }
  get trancheEmiOpt() {
    return (this.stage === "Post Sanction" || this.stage === 'Disbursed' || this.stage === 'Disbursement Initiation') && this.disbType === 'Multiple';
  }
  get postMoratoriumApplicable() {
    return (this.stage === "Post Sanction" || this.stage === 'Disbursed' || this.stage === 'Disbursement Initiation') && (this.wrpLoanApp.Product__c != 'Personal Loan') && (this.wrpLoanApp.Product__c != 'Business Loan');
  }
  get postGracePeriodMonth() {
    return (this.stage === "Post Sanction" || this.stage === 'Disbursed' || this.stage === 'Disbursement Initiation') && this.graceApp === 'Y';
  }
  get showLoanTakeover() {
    return this.stage !== 'QDE' && (this.hideBT === true || this.isInterTopUp === true);
  }
  get loanTakeOverReq() {
    return this.hideBT === true && this.isSellerBt === false;
  }

  get disabledFlag() {
    return this.disableMode || this.graceApp === "N";
  }

  get editableSellBt() {
    return this.disableMode || this.sellBt === 'N';
  }
  get showSellBTTrans() {
    return this.sellBt === "Y";
  }

  get requiredSellarTBT() {
    return this.stage === "UnderWriting" || this.stage === "Post Sanction" || this.stage === 'Disbursed' || this.stage === 'Disbursement Initiation';
  }

  get fineOneField() {
    return this.stage === 'Disbursed' || this.stage === 'Disbursement Initiation';
  }
  get isItRefinance() {
    return this.wrpLoanApp.Product__c === 'Home Loan';
  }

  get showRefinance() {
    return this.wrpLoanApp.IsItRefinanceTransaction__c === "Y";
  }

  get btTransferStatus() {
    return this.wrpLoanApp.IsItRefinanceTransaction__c === "Y" && this.hideBT === true;
  }

  get firstSactDate() {
    return (this.stage === "Post Sanction" || this.stage === "Soft Sanction") && this.sanctDate !== undefined
  }

  get ownContri() {
    return this.disableMode || (this.productValue !== 'Home Loan' && this.wrpLoanApp.ProductSubType__c !== 'Commercial Property Purchase');
  }

  get disablePreEmi() {
    return this.disableMode || this.disbType === 'MULTIPLE';
  }

  get disableDisbursalType() {
    return ((this.stage === "Post Sanction" || this.stage === 'Disbursed' || this.stage === 'Disbursement Initiation') && (this.wrpLoanApp.Product__c === 'Personal Loan' || this.wrpLoanApp.Product__c === 'Business Loan'));
  }

  get sellBtValue() {
    let val = 'N'
    if (this.wrpLoanApp.ProductSubType__c === "Seller BT - 100% Ready Property" || this.isSellerBt === true) {
      val = 'Y'
      this.sellBt = 'Y';
    } else {
      val = 'N'
      this.sellBt = 'N';
    }
    return val;
  }

  get btTableVisible() {
    return this.hideBT || this.showExtFedAcc || this.isInterTopUp;
  }

  get isItRefinaceValue() {
    let val
    if (this.wrpLoanApp.ProductSubType__c === 'Refinance') {
      val = 'Y';
    } else {
      val = 'N';
    }
    this.wrpLoanApp.IsItRefinanceTransaction__c = val;
    return this.wrpLoanApp.IsItRefinanceTransaction__c;
  }



  get maxAgreeDate() {
    let val = this.currentDate;
    if (this.loginAccept) {
      val = this.loginAccept
    }
    return val;
  }
@track disableFieldsOnProd = false;
  @wire(getRecord, { recordId: "$recordId", fields: fields })
  recordDetailsHandler({ data, error }) {
    if (data) {
      console.log("current_LA_Record ", JSON.stringify(data), ":::::::", data);
      this.stage = data.fields.Stage__c.value ? data.fields.Stage__c.value : "";
      this.subStage = data.fields.SubStage__c.value;
      this.status = data.fields.Status__c.value
        ? data.fields.Status__c.value
        : "";
      this.schemeId = data.fields.SchemeId__c.value
        ? data.fields.SchemeId__c.value
        : "";
        if(this.schemeId){
          this.getSchemeDetails();
        }
      this.leadId = data.fields.Lead__c.value ? data.fields.Lead__c.value : "";
      this.channelId = data.fields.ChanelNme__c.value
        ? data.fields.ChanelNme__c.value
        : "";
      this.leadSource = data.fields.LeadSource__c.value
        ? data.fields.LeadSource__c.value
        : "";
      this.sfdcLeadRefNo = data.fields.LeadId__c.value
        ? data.fields.LeadId__c.value
        : "";
      this.wrpLoanApp.LeadSource__c = data.fields.LeadSource__c.value
        ? data.fields.LeadSource__c.value
        : "";
      this.wrpLoanApp.LMSLeadId__c = data.fields.LMSLeadId__c.value
        ? data.fields.LMSLeadId__c.value
        : "";
      this.wrpLoanApp.BrchName__c = data.fields.BrchName__c.value
        ? data.fields.BrchName__c.value
        : "";
      this.wrpLoanApp.BrchCode__c = data.fields.BrchCode__c.value;
      this.rmsmName = data.fields.RM__c.value ? data.fields.RM__c.value : "";
      //this.wrpLoanApp.RMSMName__c = data.fields.rmsmEmpId.value;
      this.rmsmEmpId = data.fields.RMSMEmployeeID__c.value
        ? data.fields.RMSMEmployeeID__c.value
        : "";
      this.wrpLoanApp.RefEmpCode__c = data.fields.RefEmpCode__c.value
        ? data.fields.RefEmpCode__c.value
        : "";
      this.channelName = data.fields.ChanelNme__c.value
        ? data.fields.ChanelNme__c.value
        : "";
      this.wrpLoanApp.ChannelCode__c = data.fields.ChannelCode__c.value
        ? data.fields.ChannelCode__c.value
        : "";
      this.wrpLoanApp.Product__c = data.fields.Product__c.value
        ? data.fields.Product__c.value
        : "";
      this.wrpLoanApp.ProductSubType__c = data.fields.ProductSubType__c.value
        ? data.fields.ProductSubType__c.value
        : "";
      this.wrpLoanApp.SchmCode__c = data.fields.SchmCode__c.value
        ? data.fields.SchmCode__c.value
        : "";
      this.scheme = data.fields.SchmCode__c.value
        ? data.fields.SchmCode__c.value
        : "";
      this.promotion = data.fields.PromCode__c.value
        ? data.fields.PromCode__c.value
        : "";
      this.loanPurpose = data.fields.LoanPurpose__c.value
        ? data.fields.LoanPurpose__c.value
        : "";
      //LAK-5718
      this.intrstWaiverApprover = data.fields.IntWaiverApprover__c.value
        ? data.fields.IntWaiverApprover__c.value
        : "";
      this.reqLoanAmount = data.fields.ReqLoanAmt__c.value
        ? data.fields.ReqLoanAmt__c.value
        : "";
      this.wrpLoanApp.ReqTenInMonths__c = data.fields.ReqTenInMonths__c.value;
      this.btFinancier = data.fields.BTFinancr__c.value
        ? data.fields.BTFinancr__c.value
        : "";
      this.wrpLoanApp.OthrBTFinancr__c = data.fields.OthrBTFinancr__c.value
        ? data.fields.OthrBTFinancr__c.value
        : "";
      this.wrpLoanApp.BTLoanAmt__c = data.fields.BTLoanAmt__c.value;
      this.wrpLoanApp.BTLoanOutstndVal__c =
        data.fields.BTLoanOutstndVal__c.value;
      this.wrpLoanApp.ExistngFedFinaLoanAccNo__c = data.fields
        .ExistngFedFinaLoanAccNo__c.value
        ? data.fields.ExistngFedFinaLoanAccNo__c.value
        : "";
      this.wrpLoanApp.AssessedIncAppln__c = data.fields.AssessedIncAppln__c
        .value
        ? data.fields.AssessedIncAppln__c.value
        : false;
      this.wrpLoanApp.AssesIncomeAppl__c = data.fields.AssesIncomeAppl__c.value
        ? data.fields.AssesIncomeAppl__c.value
        : "";
      this.wrpLoanApp.SchemeId__c = data.fields.SchemeId__c.value
        ? data.fields.SchemeId__c.value
        : "";
      this.wrpLoanApp.PromotionId__c = data.fields.PromotionId__c.value
        ? data.fields.PromotionId__c.value
        : "";
      this.wrpLoanApp.LoanPurposeId__c = data.fields.SchemeId__c.value
        ? data.fields.LoanPurposeId__c.value
        : "";
      this.wrpLoanApp.BTFinancierId__c = data.fields.BTFinancierId__c.value
        ? data.fields.BTFinancierId__c.value
        : "";
      //LAK-5718 
      this.wrpLoanApp.IntWaiverApprover__c = data.fields.IntWaiverApprover__c.value
        ? data.fields.IntWaiverApprover__c.value
        : "";
      this.wrpLoanApp.Repayment_Frequency__c = data.fields
        .Repayment_Frequency__c.value
        ? data.fields.Repayment_Frequency__c.value
        : "M";
      this.wrpLoanApp.Installment_Plan__c = data.fields.Installment_Plan__c
        .value
        ? data.fields.Installment_Plan__c.value
        : "E";
      this.rateType = data.fields.Rate_Type_Floating_Flag__c.value;

      this.emiTrache = data.fields.EMIOptionsintranchedisbursementCase__c.value
        ? data.fields.EMIOptionsintranchedisbursementCase__c.value
        : "";

      this.primeType = data.fields.LoanPLRType__c.value
        ? data.fields.LoanPLRType__c.value
        : "";

  
      this.dueDay = data.fields.DueDay__c.value
        ? data.fields.DueDay__c.value
        : "7";
      this.primeRate = data.fields.LoanPLRRate__c.value
        ? data.fields.LoanPLRRate__c.value
        : '';
      this.effectiveRoi = data.fields.EffectiveROI__c.value
        ? data.fields.EffectiveROI__c.value
        : "";
      this.spreadIdVal = data.fields.SpreadID__c.value
        ? data.fields.SpreadID__c.value
        : "";
      this.holdReasonValue = data.fields.Hold_Reason__c.value
        ? data.fields.Hold_Reason__c.value
        : "";
      this.cancelReasonValue = data.fields.Cancel_Reason__c.value
        ? data.fields.Cancel_Reason__c.value
        : "";
      this.cancelReasonOtherValue = data.fields.Additional_Comments__c.value
        ? data.fields.Additional_Comments__c.value
        : "";
      this.rejectReasonValue = data.fields.RejectReason__c.value
        ? data.fields.RejectReason__c.value
        : "";
      this.loanTakeover = data.fields.LoanTakeOverofRegMortgage__c.value
        ? data.fields.LoanTakeOverofRegMortgage__c.value
        : "";
      this.reqIntType = data.fields.ReqInterestType__c.value
        ? data.fields.ReqInterestType__c.value
        : "E";
      this.LeadRoi = data.fields.LeadROI__c.value
        ? data.fields.LeadROI__c.value
        : "";
      this.productValue = this.wrpLoanApp.Product__c;

      if(this.wrpLoanApp.Product__c && (this.wrpLoanApp.Product__c === 'Business Loan' || this.wrpLoanApp.Product__c === 'Personal Loan')){
        this.disableFieldsOnProd = true;
      }else{
        this.disableFieldsOnProd = false;
      }
      this.totalAmtIncIns = data.fields.TotalLoanAmtInclInsurance__c.value
        ? data.fields.TotalLoanAmtInclInsurance__c.value
        : "";
      this.disbType = this.disableDisbursalType ? 'SINGLE' : data.fields.DisbursalType__c.value;
      this.emiIncIns = data.fields.EMIIcludingInsurance__c.value
        ? data.fields.EMIIcludingInsurance__c.value
        : "";
      this.effIntStartDt = data.fields.EffectiveNextIntStartDt__c.value
        ? data.fields.EffectiveNextIntStartDt__c.value
        : this.currentDate;
      this.emiMonth = data.fields.First_EMI_Due_Month_1__c.value
        ? data.fields.First_EMI_Due_Month_1__c.value
        : "";
      this.emiYear = data.fields.First_EMI_Due_Year_1__c.value
        ? data.fields.First_EMI_Due_Year_1__c.value
        : "";
      this.firstEMI = data.fields.FirstEMIDate__c.value
        ? data.fields.FirstEMIDate__c.value
        : "";
      this.emiType = data.fields.PreEmiType__c.value
        ? data.fields.PreEmiType__c.value
        : "";
      this.graceApp = data.fields.MoratGraceApplicable__c.value
        ? data.fields.MoratGraceApplicable__c.value
        : "N";
      this.gracePeriod = data.fields.MoratGracePeriodMonths__c.value
        ? data.fields.MoratGracePeriodMonths__c.value
        : "";
      this.impactTen = data.fields.ImpactOnTenure__c.value
        ? data.fields.ImpactOnTenure__c.value
        : "";
      this.chargeInt = data.fields.ChargeInterest__c.value
        ? data.fields.ChargeInterest__c.value
        : "";
      this.addlInt = data.fields.AddIntSchedule__c.value
        ? data.fields.AddIntSchedule__c.value
        : "";
      this.sellBt = data.fields.IsitSellerBalTransferTransaction__c.value
        ? data.fields.IsitSellerBalTransferTransaction__c.value
        : "";
      this.wrpLoanApp.IsSellerListDocLODAvl__c = data.fields
        .IsSellerListDocLODAvl__c.value
        ? data.fields.IsSellerListDocLODAvl__c.value
        : "";
      this.wrpLoanApp.IsSellerBTLoanForeclosureAmt__c = data.fields
        .IsSellerBTLoanForeclosureAmt__c.value
        ? data.fields.IsSellerBTLoanForeclosureAmt__c.value
        : "";
      this.wrpLoanApp.DocAsPerLegalReportMatches__c = data.fields
        .DocAsPerLegalReportMatches__c.value
        ? data.fields.DocAsPerLegalReportMatches__c.value
        : "";
      this.wrpLoanApp.SaleDeedBetnBuyerBorr__c = data.fields
        .SaleDeedBetnBuyerBorr__c.value
        ? data.fields.SaleDeedBetnBuyerBorr__c.value
        : "";
      this.wrpLoanApp.OwnContriPaid__c = data.fields.OwnContriPaid__c.value
        ? data.fields.OwnContriPaid__c.value
        : "";
      this.wrpLoanApp.LetterFomSellerBTFinancier__c = data.fields
        .LetterFomSellerBTFinancier__c.value
        ? data.fields.LetterFomSellerBTFinancier__c.value
        : "";
      this.wrpLoanApp.ChequeForAmtEquiBTAmt__c = data.fields
        .ChequeForAmtEquiBTAmt__c.value
        ? data.fields.ChequeForAmtEquiBTAmt__c.value
        : "";
      this.wrpLoanApp.SellerVerificationKYCSellerTaken__c = data.fields
        .SellerVerificationKYCSellerTaken__c.value
        ? data.fields.SellerVerificationKYCSellerTaken__c.value
        : "";
      this.wrpLoanApp.SellerVerCredTeleChk__c = data.fields
        .SellerVerCredTeleChk__c.value
        ? data.fields.SellerVerCredTeleChk__c.value
        : "";
      this.wrpLoanApp.AllSellerBTNormMet__c = data.fields.AllSellerBTNormMet__c
        .value
        ? data.fields.AllSellerBTNormMet__c.value
        : "";
      this.wrpLoanApp.IsItRefinanceTransaction__c = data.fields.IsItRefinanceTransaction__c.value
        ? data.fields.IsItRefinanceTransaction__c.value
        : "";
      this.agreeDate = data.fields.RefinanceSaleAgreementDate__c.value
        ? data.fields.RefinanceSaleAgreementDate__c.value
        : "";
      this.wrpLoanApp.PeriodSinceSaleAgreementExecuted__c = data.fields
        .PeriodSinceSaleAgreementExecuted__c.value
        ? data.fields.PeriodSinceSaleAgreementExecuted__c.value
        : "";
      this.wrpLoanApp.RefinanceSaleAgreementAmt__c = data.fields.RefinanceSaleAgreementAmt__c.value;
      this.wrpLoanApp.PaymentDoneInLast6MonthsCash__c = data.fields
        .PaymentDoneInLast6MonthsCash__c.value;

      this.wrpLoanApp.PaymentDoneInLast6MonthsBank__c = data.fields
        .PaymentDoneInLast6MonthsBank__c.value;

      this.wrpLoanApp.PaymentDoneInLast12MonthsCash__c = data.fields
        .PaymentDoneInLast12MonthsCash__c.value;

      this.wrpLoanApp.PaymentDoneInLast12MonthsBank__c = data.fields
        .PaymentDoneInLast12MonthsBank__c.value;

      this.wrpLoanApp.BalTransferFinaStatus__c = data.fields
        .BalTransferFinaStatus__c.value
        ? data.fields.BalTransferFinaStatus__c.value
        : "";

      this.wrpLoanApp.BranchTier__c = data.fields.BranchTier__c.value
        ? data.fields.BranchTier__c.value
        : "";

      this.loginAccept = data.fields.LoginAcceptDate__c.value
        ? data.fields.LoginAcceptDate__c.value
        : "";

      this.rateEmiFlag = data.fields.RateEMIFlag__c.value
        ? data.fields.RateEMIFlag__c.value
        : "R";

      this.fileAcceptValue = data.fields.CPASubSt__c.value
        ? data.fields.CPASubSt__c.value
        : "";
//LAK-166
      this.opsStatus = data.fields.OpsStatus__c.value
        ? data.fields.OpsStatus__c.value
        : "";

      this.clonedLAN = data.fields.ClonedForLAN__c.value
      ? data.fields.ClonedForLAN__c.value
      : "";

      this.finoneLoanNo = data.fields.Finnone_Loan_Number__c.value
        ? data.fields.Finnone_Loan_Number__c.value
        : "";

      this.sanctDate = data.fields.FirstApprovalDate__c.value
        ? data.fields.FirstApprovalDate__c.value
        : "";


        this.wrpLoanApp.Application_Form_No__c = data.fields.Application_Form_No__c.value
        ? data.fields.Application_Form_No__c.value
           : "";

         this.wrpLoanApp.Application_Form_Date__c = data.fields.Application_Form_Date__c.value
         ? data.fields.Application_Form_Date__c.value
              : "";
        


        //  this.selectDSACityId = data.fields.LocMstr__c.value
        // ? data.fields.LocMstr__c.value
        // : "";
        // this.selectDSABranchId = data.fields.Branch__c.value
        // ? data.fields.Branch__c.value
        // : "";
        // if(this.selectDSABranchId){
        //   this.getLocBranJunId();
        // }
        // this.selectedDsaRmId = data.fields.RMSMName__c.value
        // ? data.fields.RMSMName__c.value
        // : "";
        // if(this.selectedDsaRmId){
        //   this.getteamHierarchyId();
        // }
      this.ownContriBank = data.fields.OwnContriBank__c.value;
      this.ownContriCash = data.fields.OwnContriCash__c.value;
      this.totalContri = data.fields.TotalOwnContri__c.value;
      this.sanctAmt = data.fields.SanLoanAmt__c.value;
      this.totalPropCost = data.fields.TotalPropertyCost__c.value;
      this.loanCreatedDate = data.fields.formatCreateDate__c.value;
       console.log('this.loanCreatedDateTime',this.loanCreatedDate);
      // this.loanCreatedDate = this.loanCreatedDateTime.date();
      //LAK-4925
      this.intrstWaiverValue = data.fields.InterestWaiverTaken__c.value ? data.fields.InterestWaiverTaken__c.value : null;
      if (this.effectiveRoi && this.primeRate) {
        this.spreadIDCalculate();
      }

      if (this.schemeId) {
        this.getDueDay();
      }

      console.log("selectedRecordId ", this.selectedRecordId, this.scheme);
      if (this.wrpLoanApp.AssessedIncAppln__c === true) {
        this.wrpLoanApp.AssesIncomeAppl__c = "Yes";
      } else {
        this.wrpLoanApp.AssesIncomeAppl__c = "No";
      }
      if (this.wrpLoanApp.LeadSource__c === "Digital") {
        this.hideLMSId = true;
      } else {
        this.hideLMSId = false;
      }
      if (this.wrpLoanApp.LeadSource__c === "Fedfina Emp") {
        this.fedFinaEmp = true;
      } else {
        this.fedFinaEmp = false;
      }
      if (
        this.wrpLoanApp.LeadSource__c === "DSA" ||
        this.wrpLoanApp.LeadSource__c === "Connector"
      ) {
        this.hideChannel = false;
      } else {
        this.hideChannel = true;
      }
      console.log(
        "this.wrpLoanApp.Product__c:::::>>>  ",
        this.wrpLoanApp.Product__c
      );
      if (this.wrpLoanApp.Product__c) {
        console.log('this.loanCreatedDate',this.loanCreatedDate);
        this.filterCondition = ' ProductType__c  = \'' + this.wrpLoanApp.Product__c + '\' AND EndDate__c >=TODAY AND StartDate__c <= TODAY';
        this.filterConditionPromotion = ' ProductType__c  = \'' + this.wrpLoanApp.Product__c +  '\' AND (   (EndDate__c >= ' + this.loanCreatedDate + ' AND StartDate__c <= '+this.loanCreatedDate + ')   ) ' + 'AND Scheme__c = \'' + this.schemeId + '\'';

        this.filtCondnLoanPurpose = ' ProdType__c  includes ( \'' + this.wrpLoanApp.Product__c + '\')';
        // "ProdType__c  includes " + "('" + this.wrpLoanApp.Product__c + "' )";
      }

      this.checkSellerBTTrans();
      this.showSpinner=false;
    }
    if (error) {
      console.log("ERROR::::::: #506", error);
    }
  }

  getSchemeDetails(){
    this.showSpinner = true;
    let params = {
        ParentObjectName: 'SchMapping__c',
        parentObjFields: ['Id','IsInternalTopUp__c'],
        queryCriteria: ` WHERE Id = '${this.schemeId}'`
    };
    getAssetPropType({ params: params })
        .then((result) => {
            console.log('Team Hierarchy Data is ', JSON.stringify(result));
            if (result.parentRecords) {
                this.isInterTopUp = result.parentRecords[0].IsInternalTopUp__c;
            }
             this.showSpinner = false;
        })
        .catch((error) => {
            this.showSpinner = false;
            console.log('Error in getting Scheme details is ', error);
        });
  }
  @track teamHierId;
    getteamHierarchyId(){
        this.showSpinner = true;
        let params = {
            ParentObjectName: 'TeamHierarchy__c',
            parentObjFields: [
                'Id'
            ],
            queryCriteria: ` WHERE Employee__c = '${this.selectedDsaRmId}'`
        };
         // Call the Apex method and handle the result
        getAssetPropType({ params: params })
            .then((result) => {
                console.log('Team Hierarchy Data is ', JSON.stringify(result));
                if (result.parentRecords) {
                    this.teamHierId = result.parentRecords[0].Id;
                }
                // this.getLocBranJunId();
                 this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error in getting Team Hierarchy Data is ', error);
            });
    }
    @track locationBranJnId;
    getLocBranJunId(){
      this.showSpinner = true;
        let params = {
            ParentObjectName: 'LocBrchJn__c',
            parentObjFields: ['Id'],
            queryCriteria: ` WHERE Branch__c = '${this.selectDSABranchId}'`
        };
         // Call the Apex method and handle the result
        getAssetPropType({ params: params })
            .then((result) => {
                console.log(' Data is ', JSON.stringify(result));
                if (result.parentRecords) {
                    this.locationBranJnId = result.parentRecords[0].Id;
                }
                // this.getLocBranJunId();
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log('Error in getting Team Hierarchy Data is ', error);
            });
    }
  get firtsEmiDate() {
    if (this.firstEMI) {
      console.log('this.firstEMI: Line 1128:' + this.firstEMI)
      // //const d = new Date(this.firstEMI);
      // //const formattedDate = d.toLocaleDateString('en-GB'); // 'en-GB' represents the British English locale

      return this.firstEMI;
    }
  }

  @track propCat;
  @wire(getRecord, { recordId: "$leadId", fields: leadFields })
  recordLeadHandler({ data, error }) {
    if (data) {
      console.log("LEAD RECORDS:::::::", data);
      this.custProf = data.fields.Customer_Profile__c.value;
      this.propCat = data.fields.Property_Category__c.value;
      if (
        this.custProf === "SALARIED" &&
        this.wrpLoanApp.AssessedIncAppln__c === true
      ) {
        this.metaCustProf = "Salaried Assessed Income";
      } else if (
        this.custProf === "SALARIED" &&
        this.wrpLoanApp.AssessedIncAppln__c === false
      ) {
        this.metaCustProf = "Salaried Regular Income";
      } else if (
        this.custProf !== "SALARIED" &&
        this.wrpLoanApp.AssessedIncAppln__c === true
      ) {
        this.metaCustProf = "Self Employed Assessed Income";
      } else {
        this.metaCustProf = "Self Employed Regular Income";
      }
      let tempParams = this.rackRateMst;
      tempParams.queryCriteria =
        " where Product__c =  '" +
        this.productValue +
        "' AND Product_Sub_Type__c = '" +
        this.wrpLoanApp.ProductSubType__c +
        "' AND Customer_Profile__c = '" +
        this.metaCustProf +
        "'";
      this.rackRateMst = { ...tempParams };

      let tempParamsAdd = this.addlRateMst;
      tempParamsAdd.queryCriteria =
        " where Label =  '" +
        this.propCat +
        "' OR Label = '" +
        this.addMstTkt +
        "' OR Label = '" +
        this.addMstLoc +
        "'";
      this.addlRateMst = { ...tempParamsAdd };
    }
    if (error) {
      console.log("ERROR::::::: #543", error);
    }
  }

  @wire(getRecord, { recordId: "$channelId", fields: accountFileds })
  recordAccountHandler({ data, error }) {
    if (data) {
      console.log("data for Account record:::::::", data);

      if (data.fields.DSAConnId__c.value) {
        this.wrpLoanApp.ChannelCode__c = data.fields.DSAConnId__c.value;
      } else {
        this.wrpLoanApp.ChannelCode__c = data.fields.VCReferralCode__c.value;
      }
      //this.hideChannel = false;
      console.log(
        "result from this.wrpLoanApp.ChannelCode__c>>>>>",
        this.wrpLoanApp.ChannelCode__c
      );
    }
    if (error) {
      console.log("ERROR::::::: #564", error);
    }
  }
  get ChannelCode() {
    if (this.wrpLoanApp.LeadSource__c === "DSA") {
      return "Account__r.DSAConnId__c";
    } else if (this.wrpLoanApp.LeadSource__c === "Connector") {
      return "Account__r.VCReferralCode__c";
    }
  }
  get filterCondnChannel() {
    console.log(
      "this.wrpLoanApp.LeadSource__c==",
      this.wrpLoanApp.LeadSource__c
    );
    if (this.leadSource === "DSA") {
      return (
        "Account__r.RecordTypeId=" +
        "'" +
        this.dsaRecordTypeId +
        "'" +
        " AND RMUsr__c=" +
        "'" +
        this.selectedDsaRmId +
        "'"
      );
    } else if (this.leadSource === "Connector") {
      return (
        "Account__r.RecordTypeId=" +
        "'" +
        this.connectorRecordTypeId +
        "'" +
        " AND RMUsr__c=" +
        "'" +
        this.loggedInUser +
        "'"
      );
    }
  }

  checkSellerBTTrans() {
    if (
      // this.wrpLoanApp.Product__c === "Home Loan" &&                      //As per LAK-4599 Bug fixed
      (this.wrpLoanApp.ProductSubType__c ===
        "Seller BT - 100% Ready Property" || this.isSellerBt === true
      )
    ) {
      this.sellBt = "Y";
    } else {
      this.sellBt = "N";
    }
  }
  // Handler Functions For Each Field

  // checking All Seller BT norms
  get checkAllSellBT() {
    let allSeller;
    if (
      this.wrpLoanApp.IsSellerListDocLODAvl__c === "Y" &&
      this.wrpLoanApp.IsSellerBTLoanForeclosureAmt__c === "Y" &&
      this.wrpLoanApp.DocAsPerLegalReportMatches__c === "Y" &&
      this.wrpLoanApp.SaleDeedBetnBuyerBorr__c === "Y" &&
      this.wrpLoanApp.OwnContriPaid__c === "Y" &&
      this.wrpLoanApp.LetterFomSellerBTFinancier__c === "Y" &&
      this.wrpLoanApp.ChequeForAmtEquiBTAmt__c === "Y" &&
      this.wrpLoanApp.SellerVerificationKYCSellerTaken__c === "Y" &&
      this.wrpLoanApp.SellerVerCredTeleChk__c === "Y"
    ) {
      allSeller = "Y";
    } else {
      allSeller = "N";
    }
    this.wrpLoanApp.AllSellerBTNormMet__c = allSeller;
    return this.wrpLoanApp.AllSellerBTNormMet__c;
  }

  handleInputChange(event) {
    this.tenureValid();
    console.log("input value", event.target.value);
    console.log(
      "input value before",
      this.wrpLoanApp[event.target.dataset.name]
    );

    if (event.target.label === "Refinance Sale agreement date") {
      this.agreeDate = event.target.value;
      if (this.loginAccept) {
        if (new Date(this.loginAccept).getTime() - new Date(this.agreeDate).getTime() >= 1) {
          this.agreeError = "";
          const { months, days } = this.dateDiffInMonthsAndDays(this.agreeDate);
          this.wrpLoanApp.PeriodSinceSaleAgreementExecuted__c = `${months} months and ${days} days`;
          console.log(`Difference: ${months} months and ${days} days`);
        } else {
          this.agreeError = "Future date is not allowed";
        }
      }
      else {
        if (new Date().getTime() - new Date(this.agreeDate).getTime() >= 1) {
          this.agreeError = "";
          const { months, days } = this.dateDiffInMonthsAndDays(this.agreeDate);
          this.wrpLoanApp.PeriodSinceSaleAgreementExecuted__c = `${months} months and ${days} days`;

        } else {
          this.agreeError = "Future date is not allowed";
        }
      }
    }
    //LAK-4925
    if (event.target.label === "Interest Waiver Taken") {
      //LAK-5718
      this.salesEmp = 'SALES';
      this.filterConditionForLookup = 'Department IN(\'' + this.salesEmp + '\') ' + 'AND Id != \'' + this.currentUserId + '\''

      this.intrstWaiverValue = event.target.value;
      if (this.intrstWaiverValue === 'N') {
        this.deleteDocDet(this._docmntDetId, true);
      }

    }

    if (event.target.label === "Own Contribution in Cash") {
      this.ownContriCash = event.target.value;
      this.calculateOwnContriBank();
    }
    if (event.target.label === "Effective ROI") {
      this.effectiveRoi = event.target.value;
      this.spreadIDCalculate();
    }
    if (event.target.label === "Loan takeover of registered mortgage") {
      this.loanTakeover = event.target.value;
    }
    if (event.target.label === "Requested Interest Type") {
      this.reqIntType = event.target.value;
    }
    if (event.target.label === "Due Day") {
      this.dueDay = event.target.value;
    }
    if (event.target.label === "Disbursal Type") {
      this.disbType = event.target.value;
      if (this.disbType === 'MULTIPLE') {
        this.emiType = 'R';
      }
    }
    if (event.target.label === "EMI (₹) -(Loan amount including insurance)") {
      this.emiIncIns = event.target.value;
    }
    if (event.target.label === "Effective/Next Interest Start Date") {
      this.effIntStartDt = event.target.value;
    }

    if (event.target.label === "Pre-EMI Type") {
      this.emiType = event.target.value;
    }

    if (event.target.label === "Moratorium/Grace Applicable") {
      this.graceApp = event.target.value;
      if (this.graceApp === 'N') {
        this.gracePeriod = '';
      }

    }
    if (event.target.label === "Moratorium/Grace Period(in months)") {
      this.gracePeriod = event.target.value;
    }
    if (event.target.label === "Impact on Tenure") {
      this.impactTen = event.target.value;
    }
    if (event.target.label === "Charge Interest") {
      this.chargeInt = event.target.value;
    }
    if (event.target.label === "Add Interest in Schedule") {
      this.addlInt = event.target.value;
    }

    if (event.target.label === "Lead Source") {
      this.leadSource = event.target.value;
      if (event.target.value === "DSA" || event.target.value === "Connector") {
        this.hideChannel = false;
      } else {
        this.hideChannel = true;
      }

      if (event.target.value === "Fedfina Emp") {
        this.fedFinaEmp = true;
      } else {
        this.fedFinaEmp = false;
      }

      if (event.target.value === "Digital") {
        this.hideLMSId = true;
      } else {
        this.hideLMSId = false;
      }
    }

    if (
      event.target.label === "Requested loan Amount" ||
      event.target.label === "Balance Transfer Loan Outstanding Value (₹)" ||
      event.target.label === "Balance Transfer Original Loan Amount (₹)"
    ) {
      var charCode = event.which ? event.which : event.keyCode;
      console.log("charCode--" + charCode);

      if (charCode === 46) {
        if (event.preventDefault) {
          event.preventDefault();
        }
      }
    }

    if (event.target.label === "Product") {
      this.wrpLoanApp.ProductSubType__c = "";
      this.wrpLoanApp.Product__c = event.target.value;
      this.filterCondition = ' ProductType__c  = \'' + this.wrpLoanApp.Product__c + '\' AND EndDate__c >=TODAY AND StartDate__c <= TODAY';
      //LAk-7939 filter condition for promotion added depending on scheme
      this.filterConditionPromotion = ' ProductType__c  = \'' + this.wrpLoanApp.Product__c +  '\' AND (     (EndDate__c >= ' + this.loanCreatedDate + ' AND StartDate__c <= '+this.loanCreatedDate + ')   ) ' + 'AND Scheme__c = \'' + this.schemeId + '\'';
      this.filtCondnLoanPurpose = ' ProdType__c  includes ( \'' + this.wrpLoanApp.Product__c + '\')';
      //   "ProdType__c  includes " + "('" + this.wrpLoanApp.Product__c + "' )";
      console.log(
        "values of scheme and promo before",
        this.wrpLoanApp.PromotionId__c,
        this.wrpLoanApp.SchemeId__c
      );
      this.wrpLoanApp.PromotionId__c = "";
      this.wrpLoanApp.PromCode__c = "";
      this.wrpLoanApp.SchemeId__c = "";
      this.wrpLoanApp.SchmCode__c = "";
      //LAK-5718
      this.wrpLoanApp.IntWaiverApprover__c = "";

      this.schemeId = "";
      this.hideBT = false;
      console.log(
        "values of scheme and promo after",
        this.wrpLoanApp.PromotionId__c,
        this.wrpLoanApp.SchemeId__c
      );
      if(this.wrpLoanApp.Product__c && (this.wrpLoanApp.Product__c === 'Business Loan' || this.wrpLoanApp.Product__c === 'Personal Loan')){
        this.disableFieldsOnProd = true;
      }else{
        this.disableFieldsOnProd =false;
      }
    }

    if (event.target.type === "checkbox") {
      console.log(
        "input value after if",
        this.wrpLoanApp[event.target.dataset.name]
      );
      if (event.target.checked) {
        this.wrpLoanApp[event.target.dataset.name] = true;
      } else {
        this.wrpLoanApp[event.target.dataset.name] = false;
      }
    } else {
      this.wrpLoanApp[event.target.dataset.name] = event.target.value;
    }

    if (event.target.label === "Balance Transfer Loan Outstanding Value (₹)") {
      if (this.wrpLoanApp.BTLoanAmt__c < this.wrpLoanApp.BTLoanOutstndVal__c) {
        console.log(
          "INSIDE IF BLOCK TO CHECK BTLOAN AMOUNT LESS THAT OUST VALUE"
        );
        this.maxAmt = "Please Enter Lesser Value than Original Loan Amount";
      }
    }
    if (event.target.label === "Existing FedFina Loan Account Number") {
      this.wrpLoanApp.ExistngFedFinaLoanAccNo__c =
        event.target.value.toUpperCase();
    }
    if (event.target.label === "Product") {
      this.wrpLoanApp.Product__c = event.target.value;
      this.productValue = this.wrpLoanApp.Product__c;
      //this.ownContriFlag=true;
      if (this.wrpLoanApp.Product__c) {
        this.checkSellerBTTrans();
      }

      if(this.wrpLoanApp.Product__c && (this.wrpLoanApp.Product__c === 'Business Loan' || this.wrpLoanApp.Product__c === 'Personal Loan') && this.appCustProfile){
        this.getEligibiltyProgramDetails(this.appCustProfile,this.wrpLoanApp.Product__c);
      }
    }
    if (event.target.label === "Product Sub Type") {
      if (this.wrpLoanApp.ProductSubType__c) {
        this.checkSellerBTTrans();
      }

    }

    if (event.target.label === "Is this an assessed income application") {
      this.wrpLoanApp.AssesIncomeAppl__c = event.target.value;
      if (this.wrpLoanApp.AssesIncomeAppl__c === "No") {
        this.wrpLoanApp.AssessedIncAppln__c = false;
      } else {
        this.wrpLoanApp.AssessedIncAppln__c = true;
      }
    }
    console.log("input value after", this.wrpLoanApp);

    if (event.target.label === "Application Form No") {
        const inputValue = event.target.value;
        const isNumber =/^\d*$/.test(inputValue);
        if(!isNumber){
          this.errorMessage3='Only numeric values are allowed ';
        }
        else {
          this.errorMessage3 = ''; 
      }
      this.wrpLoanApp.Application_Form_No__c = inputValue;
    }

    if (event.target.label === "Application Form Date") {
      this.wrpLoanApp.Application_Form_Date__c = event.target.value;
      const selectedDate = new Date(event.target.value);
      const today = new Date();
      today.setHours(0, 0, 0, 0); 

      if (selectedDate > today) {
          this.errorMessage = 'Future dates are not allowed.';
      } else {
          this.errorMessage = ''; 
      }

   //this.wrpLoanApp.Application_Form_Date__c = event.target.value;
    }



  }

  dateDiffInMonthsAndDays(date1) {
    let dt = this.loginAccept ? new Date(this.loginAccept) : new Date();
    const d1 = new Date(date1);
    const d2 = dt;

    const yearsDiff = d2.getFullYear() - d1.getFullYear();
    const monthsDiff = d2.getMonth() - d1.getMonth();
    const daysDiff = d2.getDate() - d1.getDate();

    let months = yearsDiff * 12 + monthsDiff;
    let days = daysDiff;

    if (days < 0) {
      const lastDayOfMonth = new Date(
        d1.getFullYear(),
        d1.getMonth() + 1,
        0
      ).getDate();
      months -= 1;
      days += lastDayOfMonth;
    }

    return { months, days };
  }

  checkDate() {
    let isValid = true
    const emiMonth = this.getMonthNumber(this.emiMonth)
    const firstEmiDate = new Date(parseInt(this.emiYear), parseInt(emiMonth), parseInt(this.dueDay), 0, 0, 0, 0);

    if (new Date().getTime() - new Date(firstEmiDate).getTime() >= 1) {
      this.emiDateErrMessage = 'Please enter future date'
      isValid = false;
    } else {
      isValid = true
      this.emiDateErrMessage = ''
    }
    return isValid;
  }


  calculateOwnContriBank() {
    this.ownContriBank = this.totalContri - this.ownContriCash;
  }
  getMonthNumber(monthString) {
    // Convert month names to lower case to make the comparison case-insensitive
    var lowerCaseMonth = monthString.toLowerCase();

    // Array of month names
    var months = [
      "january", "february", "march", "april",
      "may", "june", "july", "august",
      "september", "october", "november", "december"
    ];

    // Find the index of the month in the array
    var monthIndex = months.indexOf(lowerCaseMonth);

    // If the month is found in the array, return its corresponding number (adding 1 as months are 0-based)
    if (monthIndex !== -1) {
      return monthIndex;
    } else {
      // If the month is not found, return an indication that it's invalid (you may handle this differently based on your requirements)
      return -1;
    }
  }

  //reusable piclist generator method
  generatePicklist(data) {
    return data.values.map((item) => ({
      label: item.label,
      value: item.value
    }));
  }

  @wire(getObjectInfo, { objectApiName: LEAD_OBJECT })
  objInfo1;

  @wire(getPicklistValues, {
    recordTypeId: "$objInfo1.data.defaultRecordTypeId",
    fieldApiName: LEAD_SOURCE
  })
  leadSourcePicklistHandler({ data, error }) {
    if (data) {
      this.leadValueOptions = [...this.generatePicklist(data)];
    }
    if (error) {
      console.log(error);
    }
  }

  @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
  Function({ error, data }) {
    if (data) {
      console.log("this.accountRecordTypes>>>>>", data);
      this.accountRecordTypes = data.recordTypeInfos;
      console.log("this.accountRecordTypes>>>>>", this.accountRecordTypes);
      for (let key in data.recordTypeInfos) {
        let recordType = data.recordTypeInfos[key];
        console.log("recordType.value>>>>>", recordType.name);
        if (recordType.name === "DSA") {
          this.dsaRecordTypeId = key;
        } else if (recordType.name === "Connector") {
          this.connectorRecordTypeId = key;
        }
        console.log("data.recordTypeInfos", key);
      }
    } else if (error) {
    }
  }

  @wire(getObjectInfo, { objectApiName: TeamHier_OBJECT })
  objInfo2;

  @wire(getObjectInfo, { objectApiName: LA_OBJECT })
  objInfo;

  @wire(getPicklistValuesByRecordType, {
    objectApiName: LA_OBJECT,
    recordTypeId: "$objInfo.data.defaultRecordTypeId"
  })
  picklistHandler({ data, error }) {
    if (data) {
      console.log(
        "DATA IN LOAN DETAILS COMPONENT PICKLIST HANDLER METHOD:::#918",
        data
      );
      this.disbTypeOptions = [
        ...this.generatePicklist(data.picklistFieldValues.DisbursalType__c)
      ];
      this.monthOptions = [
        ...this.generatePicklist(data.picklistFieldValues.FirstEMIDueMonth__c)
      ];
      this.yearOptions = [
        ...this.generatePicklist(data.picklistFieldValues.FirstEMIDueYear__c)
      ];
      this.emiTypeOptions = [
        ...this.generatePicklist(data.picklistFieldValues.PreEmiType__c)
      ];

      this.graceAppOptions = [
        ...this.generatePicklist(
          data.picklistFieldValues.MoratGraceApplicable__c
        )
      ];

      this.impTenOptions = [
        ...this.generatePicklist(data.picklistFieldValues.ImpactOnTenure__c)
      ];
      this.chargeIntOptions = [
        ...this.generatePicklist(data.picklistFieldValues.ChargeInterest__c)
      ];
      this.addlIntOptions = [
        ...this.generatePicklist(data.picklistFieldValues.AddIntSchedule__c)
      ];

      this.balTransOptions = [
        ...this.generatePicklist(
          data.picklistFieldValues.IsitSellerBalTransferTransaction__c
        )
      ];
      this.sellListDocOptions = [
        ...this.generatePicklist(
          data.picklistFieldValues.IsSellerListDocLODAvl__c
        )
      ];
      this.forclosureOptions = [
        ...this.generatePicklist(
          data.picklistFieldValues.IsSellerBTLoanForeclosureAmt__c
        )
      ];
      this.legalRepOptions = [
        ...this.generatePicklist(
          data.picklistFieldValues.DocAsPerLegalReportMatches__c
        )
      ];
      this.saleDeedOptions = [
        ...this.generatePicklist(
          data.picklistFieldValues.SaleDeedBetnBuyerBorr__c
        )
      ];
      this.ownContriOptions = [
        ...this.generatePicklist(data.picklistFieldValues.OwnContriPaid__c)
      ];
      this.letterFormOptions = [
        ...this.generatePicklist(
          data.picklistFieldValues.LetterFomSellerBTFinancier__c
        )
      ];
      this.chqEquOptions = [
        ...this.generatePicklist(
          data.picklistFieldValues.ChequeForAmtEquiBTAmt__c
        )
      ];
      this.sellerVerOptions = [
        ...this.generatePicklist(
          data.picklistFieldValues.SellerVerificationKYCSellerTaken__c
        )
      ];
      this.sellerVerCredOptions = [
        ...this.generatePicklist(
          data.picklistFieldValues.SellerVerCredTeleChk__c
        )
      ];

      this.balTransStatusOptions = [
        ...this.generatePicklist(
          data.picklistFieldValues.BalTransferFinaStatus__c
        )
      ];

      this.rateEmiFlagOptions = [
        ...this.generatePicklist(
          data.picklistFieldValues.RateEMIFlag__c
        )
      ];

      this.emiTrancheOptions = [
        ...this.generatePicklist(
          data.picklistFieldValues.EMIOptionsintranchedisbursementCase__c
        )
      ];

      this.fileAcceptOptions = [
        ...this.generatePicklist(
          data.picklistFieldValues.CPASubSt__c
        )
      ];

      //LAK-4925
      this.interestWaiverOptions = [
        ...this.generatePicklist(
          data.picklistFieldValues.InterestWaiverTaken__c
        )
      ];

    }

    if (error) {
      console.error(
        "ERROR IN LOAN DETAILS COMPONENT PICKLIST HANDLER METHOD:::",
        error
      );
    }
  }


  @wire(getPicklistValues, {
    recordTypeId: "$objInfo.data.defaultRecordTypeId",
    fieldApiName: REPAYMENT_FREQUENCY
  })
  paymentFrequencyPicklistHandler({ data, error }) {
    if (data) {
      this.rePaymentFrequencyOption = [...this.generatePicklist(data)];
      console.log("repayment option : ", this.rePaymentFrequencyOption);
    }
    if (error) {
      console.log(error);
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "$objInfo.data.defaultRecordTypeId",
    fieldApiName: REQ_INTEREST_TYPE
  })
  requestInterestTypePicklistHandler({ data, error }) {
    if (data) {
      this.reqInterestTypeOption = [...this.generatePicklist(data)];
      console.log(
        "reqInterestTypeOption option : ",
        this.reqInterestTypeOption
      );
    }
    if (error) {
      console.log(error);
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "$objInfo.data.defaultRecordTypeId",
    fieldApiName: Installment_Plan
  })
  installamentValuePicklistHandler({ data, error }) {
    if (data) {
      console.log("DATA:", JSON.stringify(data));
      this.installmentPlanOption = [...this.generatePicklist(data)];
      console.log("installamentValuePicklist : ", this.installmentPlanOption);
    }
    if (error) {
      console.log(error);
    }
  }

  @track rateType;




  getPrimeRate() {
    let primeTypeParams = {
      ParentObjectName: "PLRRateMapping__c",
      ChildObjectRelName: "",
      parentObjFields: ["Id", "PLR_Rate__c", "PLR_Type__c"],
      childObjFields: [],
      queryCriteria: " where PLR_Type__c =  '" + this.primeType + "'"
    };
    getSobjectDataNonCacheable({ params: primeTypeParams })
      .then((result) => {
        console.log("Prime Rate Result 2019::::", JSON.stringify(result));
        this.primeRate = result.parentRecords[0].PLR_Rate__c;
        this.showSpinner=false;
      })
      .catch((error) => {
        this.showSpinner=false;
        console.log("Prime Rate Error 2024::::", JSON.stringify(error));
      });

  }

  @wire(getProducts, { rmName: "$currentUserId" })
  productHandler({ data, error }) {
    if (data) {
      this.productOptions = data.map((item) => ({ label: item, value: item }));
    }
    if (error) {
      console.error(error);
    }
  }

  @wire(getProductMappings, { product: "$productValue" })
  productSubTypesHandler({ data, error }) {
    if (data) {
      this.productSubTypeOptions = data.map((item) => ({
        label: item,
        value: item
      }));
    }
  }

  getDueDay() {
    let dueDays = {
      ParentObjectName: "DueDay__c",
      ChildObjectRelName: "",
      parentObjFields: ["Id", "Name", "DueDate__c", "SchemeMapping__c"],
      childObjFields: [],
      queryCriteria: " where SchemeMapping__c = '" + this.schemeId + "'"
    };
    getSobjectDataNonCacheable({ params: dueDays })
      .then((result) => {
        this.dueDayOptions = [];
        console.log("DATA IN GETSOBJECT DUE DAYS ::::>>>>", result);
        let rec = result.parentRecords;
        let options = [];
        for (let i = 0; i < rec.length; i++) {
          let opt = { label: rec[i].DueDate__c, value: rec[i].DueDate__c };
          options.push(opt);
        }
        let intOptions = []
        options.forEach(item => {
          intOptions.push(parseInt(item.value));
        })
        console.log('intOptions', options, intOptions);
        let compare = (a, b) => {
          return a - b;
        };
        let sortedArray = intOptions.sort(compare)
        console.log('sortedArray', sortedArray);
        let dueDayOpt = []
        sortedArray.forEach(item => {
          let obj = new Object();
          obj["label"] = `${item}`,
            obj["value"] = `${item}`
          dueDayOpt.push(obj)
        })
        console.log('dueDayOpt', dueDayOpt);
        this.dueDayOptions = dueDayOpt

      })
      .catch((error) => {
        console.log("Due day Error 2128::::", JSON.stringify(error));
      });

  }

  spreadIDCalculate() {
    this.spreadIdVal = this.effectiveRoi - this.primeRate;
  }

  @track addMstRate = 0;
  @track addMstLoc = "Tier 2";
  loanAmountErrorMessage;
  loanAmountFlag = false;
  tenureErrorMessage;
  tenureErrorFlag = false;

  //validate tenure
  tenureValid() {
    let validate = true;
    if (this.productValue === "Small Ticket LAP" || this.productValue === "Loan Against Property") {
      if (this.tenure < 12 || this.tenure > 180) {
        this.tenureErrorMessage = this.label.SMALL_Ticket_LAP_Label;
        validate = false;
        this.tenureErrorFlag = true;
      } else {
        this.tenureErrorMessage = "";
        this.tenureErrorFlag = false;
        validate = true;
      }
      if (!this.tenure) {
        this.tenureErrorMessage = "";
        this.tenureErrorFlag = false;
      }
    }
    if (this.productValue === "Home Loan") {
      if (this.tenure < 12 || this.tenure > 240) {
        this.tenureErrorMessage = this.label.HL_Label;
        validate = false;
        this.tenureErrorFlag = true;
      } else {
        this.tenureErrorMessage = "";
        this.tenureErrorFlag = false;
        validate = true;
      }
      if (!this.tenure) {
        this.tenureErrorMessage = "";
        this.tenureErrorFlag = false;
      }
    }
    return validate;
  }

  @track isUpdating = false;
  chequeInterval;
  startPolling() {
    this.isUpdating=true;
    console.log("Polling has started ##973");
    this.chequeInterval = setInterval(() => {
      this.waitForChequeResponse();
    }, 5000);
  }
  waitForChequeResponse() {
    try {
      console.log("this.schmMapId:::::1037", this.schmMapId);
      if (this.schmMapId) {
        clearInterval(this.chequeInterval);
        this.isUpdating = false;
        console.log("this.schmMapId:::::1042>>>>", this.schmMapId);
        let tempParamsFloat = this.floatingRate;
        tempParamsFloat.queryCriteria =
          " where SchmId__c =  '" + this.schmMapId + "'";
        this.floatingRate = { ...tempParamsFloat };

      }
      // refreshApex(this.wiredIMRecord)
    } catch (e) {
      console.log(e);
    }
  }

  @track wrpBtLoan = []
  @track btLoan = []
  handleBtLoanValueSelect(event) {
    let btLoanObj = [...event.detail];
    console.log("btLoanObj>>>>>", btLoanObj);
    this.wrpBtLoan = [...btLoanObj]
    this.btLoan = [...this.wrpBtLoan];
    this.btLoanRec = [...this.wrpBtLoan];
    console.log(' this.btLoan:::::1971', this.btLoan);
  }

  @track lookupRec;
  handleValueSelect(event) {
    // console.log('BT FINANCIER CLERED 00000');
    this.lookupRec = event.detail;
    console.log("this.lookupRec>>>>>", this.lookupRec);

    //wrpLoanApp.ChannelCode__c=
    let lookupId = this.lookupRec.id;
    console.log("lookupId>>>", lookupId);
    let lookupAPIName = this.lookupRec.lookupFieldAPIName;

    const outputObj = { [lookupAPIName]: lookupId };
    console.log("outputObj>>>", outputObj);
    Object.assign(this.wrpLoanApp, outputObj);
    console.log(
      "Data with lookup object>>>>>",
      JSON.stringify(this.wrpLoanApp)
    );
    if (
      this.lookupRec.lookupFieldAPIName === "SchmCode__c" &&
      this.lookupRec.id === null
    ) {
      // console.log('BT scheme CLERED');
      this.hideBT = false;
      this.wrpLoanApp.SchemeId__c = lookupId;
      this.wrpLoanApp.SchmCode__c = this.lookupRec.mainField;
      this.schemeId = lookupId;
      this.wrpLoanApp.ExistngFedFinaLoanAccNo__c = "";
      // this.wrpLoanApp.LoanPurposeId__c = lookupId;
      // this.wrpLoanApp.LoanPurpose__c = this.lookupRec.mainField;
      this.wrpLoanApp.BTFinancierId__c = lookupId;
      this.wrpLoanApp.BTFinancr__c = this.lookupRec.mainField;
      this.wrpLoanApp.OthrBTFinancr__c = "";
      this.wrpLoanApp.BTLoanAmt__c = "";
      this.wrpLoanApp.BTLoanOutstndVal__c = "";
      this.wrpLoanApp.DueDay__c = "";
      this.primeType = "";
      this.primeRate = '';
      this.wrpLoanApp.PromotionId__c = '';
      this.wrpLoanApp.PromCode__c = '';
      this.showSpinner=false;
      try {
        this.deletBtLoan();
      }
      catch (e) {
        console.error('BEFORE DELETING BT LOAN RE #2005', e);
      }

      this.errorOverflowMsg = "Maximum requested loan amount: " + this.maxAmt;
      this.errorUnderflowMsg = "Minimum requested loan amount: " + this.minAmt;
    }
    if (
      this.lookupRec.lookupFieldAPIName === "BTFinancr__c" &&
      this.lookupRec.id === null
    ) {
      console.log("BT FINANCIER CLERED");
      this.showOtherBT = false;
      this.wrpLoanApp.BTFinancierId__c = lookupId;
      this.wrpLoanApp.BTFinancr__c = this.lookupRec.mainField;
      console.log("BT FINANCIER CLERED2222");
    }
    if (event.target.label === "Schemes") {
      this.showSpinner=true;
      this.wrpLoanApp.SchemeId__c = lookupId;
      this.wrpLoanApp.SchmCode__c = this.lookupRec.mainField;
      this.schemeId = lookupId;
      this.wrpLoanApp.PromotionId__c = "";
      this.wrpLoanApp.PromCode__c = "";
      
      this.filterConditionPromotion = ' ProductType__c  = \'' + this.wrpLoanApp.Product__c +  '\' AND (     (EndDate__c >= ' + this.loanCreatedDate + ' AND StartDate__c <= '+this.loanCreatedDate + ')   ) ' + 'AND Scheme__c = \'' + this.schemeId + '\'';

      console.log("this.schemeId::::::>>>>>>", this.schemeId);
      if(this.lookupRec.record){
        this.hideBT = this.lookupRec.record.IsBT__c ? this.lookupRec.record.IsBT__c : false ;
       // this.hideBT = this.lookupRec.record.IsInternalTopUp__c ? this.lookupRec.record.IsInternalTopUp__c : false ;
        this.maxAmt = this.lookupRec.record.MaxAmtFin__c;
        this.minAmt = this.lookupRec.record.MinAmtFin__c;
        this.maxTenure = this.lookupRec.record.MaxTenure__c;
        this.minTenure = this.lookupRec.record.MinTenure__c;
        this.isInterTopUp = this.lookupRec.record.IsInternalTopUp__c;
        this.schSubType = this.lookupRec.record.ProductSubType__c;
        this.schmMapId = this.lookupRec.record.SchmId__c;
        this.rateType = this.lookupRec.record.FloatingRateFlag__c;
        this.primeType = this.lookupRec.record.PrimeType__c;
        this.isFixed = this.lookupRec.record.IsFixed__c ? this.lookupRec.record.IsFixed__c : false;
        this.isSellerBt = this.lookupRec.record.SellarBT__c ? this.lookupRec.record.SellarBT__c : false;
        this.applicableOwnContri = this.lookupRec.record.ApplicableOwnContribution__c;
      }else{
        this.showSpinner=false;
      }
      
     
      console.log("applicableOwnContri:::::", this.applicableOwnContri);
      this.errorOverflowMsg = "Maximum requested loan amount: " + this.maxAmt;
      this.errorUnderflowMsg = "Minimum requested loan amount: " + this.minAmt;
      this.maxTenureError = "Maximum tenure allowed: " + this.maxTenure;
      this.minTenureError = "Minimum tenure allowed: " + this.minTenure;
     

      if (this.primeType && !this.isFixed) {
        this.getPrimeRate();
      }else{
        this.showSpinner = false;
      }
      if (this.hideBT === false) {
        this.showOtherBT = false;
        // this.loanTakeReq = false;
      }
      console.log(
        "SCEHEM MAPPING RECORDS:::::::",
        this.schSubType,
        this.wrpLoanApp.ProductSubType__c
      );
      if (
        (this.schSubType === this.wrpLoanApp.ProductSubType__c ||
          this.schSubType === null) &&
        this.isInterTopUp === true
        // || (this.wrpLoanApp.Product__c && (this.wrpLoanApp.Product__c === 'Business Loan' || this.wrpLoanApp.Product__c === 'Personal Loan') && this.isInterTopUp === true && this.wrpLoanApp.SchmCode__c && (this.wrpLoanApp.SchmCode__c === 'BUSINESS LOAN- TOPUP'))
      ) {
        this.showExtFedAcc = true;
      } else {
        this.showExtFedAcc = false;
      }

      if (this.wrpLoanApp.SchmCode__c) {
        this.checkSellerBTTrans();
      }
     // this.startPolling();

      console.log("this.schmMapId:::::>>>>", this.schmMapId);
      if (this.schemeId) {
        this.getDueDay();
      }

      console.log("this.dueDays::::::>>>>>>", this.dueDays);

      if (this.hideBT === false) {
        this.showOtherBT = false;
      }

      if (this.isFixed === true && this.rateType === 'N') {
        //  this.primeType = "";
        this.primeRate = '';
      }
      if (
        this.isInterTopUp === true &&
        (this.schSubType === this.wrpLoanApp.ProductSubType__c ||
          this.schSubType === null) &&
        this.schemeId !== null
        // || (this.wrpLoanApp.Product__c && (this.wrpLoanApp.Product__c === 'Business Loan' || this.wrpLoanApp.Product__c === 'Personal Loan') && this.isInterTopUp === true && this.wrpLoanApp.SchmCode__c && (this.wrpLoanApp.SchmCode__c === 'BUSINESS LOAN- TOPUP'))
      ) {
        this.showExtFedAcc = true;
      } else {
        this.showExtFedAcc = false;
      }
    }
    if (event.target.label === "Promotion") {
      this.wrpLoanApp.PromotionId__c = lookupId;
      this.wrpLoanApp.PromCode__c = this.lookupRec.mainField;
    }
    if (event.target.label === "Loan Purpose") {
      this.wrpLoanApp.LoanPurposeId__c = lookupId;
      this.wrpLoanApp.LoanPurpose__c = this.lookupRec.mainField;
    }
    //LAK-5718
    if (event.target.label === "Interest Waiver Taken from") {
      this.wrpLoanApp.IntWaiverApprover__c = lookupId;

      console.log('this.lookupRec.mainField', this.wrpLoanApp.IntWaiverApprover__c);
    }
    if (event.target.label === "Balance Transfer Financier") {
      this.wrpLoanApp.BTFinancierId__c = lookupId;
      this.wrpLoanApp.BTFinancr__c = this.lookupRec.mainField;

      if (this.wrpLoanApp.BTFinancierId__c) {
        let otherFinValu = this.lookupRec.mainField.toLocaleLowerCase();
        let otherFinValue = otherFinValu.search(/other/);
        console.log("otherFinValue:::::", otherFinValue);
        if (otherFinValue === 0) {
          this.showOtherBT = true;
        }
      } else {
        this.showOtherBT = false;
      }
    }
    if (
      this.lookupRec.id != null &&
      this.lookupRec.lookupFieldAPIName === "ChanelNme__c"
    ) {
      //this.wrpLoanApp.ChannelCode__c = this.lookupRec.id;
      this.channelName = this.lookupRec.id;
      this.channelId = this.lookupRec.id;
      this.getChannelCode();
    }
  }


  @track btLoanRec = []
  getBtLoanRecords() {
    let params_btLoan = {
      ParentObjectName: 'LoanAppl__c',
      ChildObjectRelName: 'BT_Loans__r',
      parentObjFields: ['Id'],
      childObjFields: ['Id', 'BTFinancier__c', 'BTOriginalLoanAmt__c', 'BTLoanOutstandingValue__c', 'SpecifyOtherBTFinancier__c', 'BTFinancierStatus__c','EMI__c','Loantobeclosedinternally__c'],
      queryCriteria: ' where Id = \'' + this.recordId + '\' limit 1'

    }
    getSobjectDataWithoutCacheable({ params: params_btLoan })
      .then((result) => {
        console.log('Data #161 in bt loan', result)
        // let conIds = new Set();
        let newArray = result;

        if (newArray[0].ChildReords) {
          this.btLoanRec = [...newArray];
        }

        console.log('Data #2116 in bt loan', this.btLoanRec)
        if (result.error) {
          console.error('appl result getting error=', result.error);
        }
      })
  }

  deletBtLoan() {
    if (this.btLoanRec) {
      let del_recIds = []
      this.btLoanRec[0].ChildReords.forEach(item => {
        let fields = {};
        fields['sobjectType'] = 'BTLoan__c';
        fields['Id'] = item.Id

        del_recIds.push(fields)
        console.log("deleteRec_Array ", del_recIds);
        deletebtLoanRecord({ rcrds: del_recIds }).then((result) => {
          //alert("Record Delete Successfully", result);
        });
      })

    }

  }

  getChannelCode() {
    getAccountDetails({ channelCode: this.lookupRec.id })
      .then((result) => {
        this.hideChannel = true;

        console.log("result in getChannelCode methoda>>>>>", result);
        if (result.DSAConnId__c) {
          this.wrpLoanApp.ChannelCode__c = result.DSAConnId__c;
        } else {
          this.wrpLoanApp.ChannelCode__c = result.VCReferralCode__c;
        }
        this.hideChannel = false;
      })
      .catch((error) => {
        console.log(error);
      });
  }
  handleSaveThroughLms(values) {
    console.log("values to save through Lms ", JSON.stringify(values));
    if (values.recordId === this.recordId) {
      if (this.hasEditAccess === false) {
        this.ShowToastMessage('Error', this.label.LoanDetailsErrorWithoutPermission, 'error', 'sticky')
      } else {
        this.handleSave(values.validateBeforeSave);
      }
    }
  }

  handleSave(validate) {
    if (validate) {
      let isChildInputCorrect
      if (this.stage !== 'QDE') {
        if (this.hideBT === true || this.showExtFedAcc === true) {
          if (this.btLoanRec.length >= 1) {
            isChildInputCorrect = this.checkValidtyChild();

          } else {
            this.ShowToastMessage('Error', this.label.BTFinancierRequired, 'error', 'sticky')
          }
        }
        else {
          isChildInputCorrect = true
        }

      } else {
        isChildInputCorrect = true
      }

      let isInputCorrect = this.reportValidity();
      if (isInputCorrect === true && isChildInputCorrect === true) {

        this.updateRec();
        //  this.createBTLoanRec();

      } else {
        if (this.requiredField == false) {
          this.ShowToastMessage('Error', 'Please fill required fields', 'error', 'sticky')
        } else {
          if (this.requiredField == true) {
            this.ShowToastMessage('Error', 'Interest waiver document is not provided.', 'error', 'sticky')
          }

        }

      }
    } else {
      // if(this.isUpdating){
      //   this.ShowToastMessage('Error', 'Cannot save while updates are in progress. Please wait for 5 seconds.', 'error', 'sticky')
      // }
      // else{
       this.updateRec();
      // }
                  // this.createBTLoanRec();
    }

  }

  updateRec() {
    this.showSpinner = true;
    this.wrpLoanApp["Id"] = this.recordId;
    console.log(" this.wrpLoanApp['Id']", JSON.stringify(this.wrpLoanApp));
    console.log(
      "this.spreadIdVal::::1236",
      this.spreadIdVal,
      this.effectiveRoi,
      this.primeType,
      this.rateType
    );
    if (this.stage !== "QDE") {
      this.wrpLoanApp.SpreadID__c = this.spreadIdVal;
      this.wrpLoanApp.EffectiveROI__c = this.effectiveRoi;
      this.wrpLoanApp.RevisedROI__c = this.effectiveRoi;

      this.wrpLoanApp.LoanPLRType__c = this.primeType;
      this.wrpLoanApp.LoanPLRRate__c = this.primeRate;

      this.wrpLoanApp.DueDay__c = this.dueDay;
      this.wrpLoanApp.LoanTakeOverofRegMortgage__c = this.loanTakeover;
      this.wrpLoanApp.ReqInterestType__c = this.reqIntType;
      //this.wrpLoanApp.LeadROI__c = this.LeadRoi;

      this.wrpLoanApp.DisbursalType__c = this.disbType;
      this.wrpLoanApp.EMIIcludingInsurance__c = this.emiIncIns;
      this.wrpLoanApp.EffectiveNextIntStartDt__c = this.effIntStartDt;
      // this.wrpLoanApp.First_EMI_Due_Month_1__c = this.emiMonth;
      // this.wrpLoanApp.First_EMI_Due_Year_1__c = this.emiYear;
      this.wrpLoanApp.PreEmiType__c = this.emiType;
      this.wrpLoanApp.MoratGraceApplicable__c = this.graceApp;
      this.wrpLoanApp.MoratGracePeriodMonths__c = this.gracePeriod;
      this.wrpLoanApp.ImpactOnTenure__c = this.impactTen;
      this.wrpLoanApp.ChargeInterest__c = this.chargeInt;
      this.wrpLoanApp.AddIntSchedule__c = this.addlInt;
      this.wrpLoanApp.RateEMIFlag__c = this.rateEmiFlag;
      this.wrpLoanApp.EMIOptionsintranchedisbursementCase__c = this.emiTrache;
      this.wrpLoanApp.InterestWaiverTaken__c = this.intrstWaiverValue; //LAK-4925
    }
    this.wrpLoanApp.Rate_Type_Floating_Flag__c = this.rateType;
    const obje = this.wrpLoanApp;

    console.log(" this.wrpLoanApp ::::::>>>>>#1291", this.wrpLoanApp);
    let newArray = [];
    if (obje) {
      newArray.push(obje);
  }
  if (newArray) {
      console.log('new array is ', JSON.stringify(newArray));
      upsertMultipleRecord({ params: newArray })
          .then((result) => {
            console.log(" INSIDE UPDATE RECORD SUCCESS>>>");
            this.ShowToastMessage('Success', this.label.LoanDetailsSaved, 'success', 'sticky')
            if (this.btLoan && this.btLoan.length > 0) {
              this.createBTLoanRec();
            } else {
              this.showSpinner = false;
            }
          })
          .catch((error) => {
            console.log(
              " iINSIDE UPDATE RECORD ERROR>>>",
              error
            );
            this.ShowToastMessage('Error', this.label.LoanDetailsError, 'error', 'sticky')
            this.showSpinner = false;
          });
  }
    // const recordInput = { fields };
    // updateRecord(recordInput)
    //   .then(() => {
        // console.log(" iINSIDE UPDATE RECORD SUCCESS>>>");

        // this.ShowToastMessage('Success', this.label.LoanDetailsSaved, 'success', 'sticky')
        // if (this.btLoan && this.btLoan.length > 0) {
        //   this.createBTLoanRec();
        // } else {
        //   this.showSpinner = false;
        // }

     // })
    //   .catch((error) => {
        // console.log(
        //   " iINSIDE UPDATE RECORD ERROR>>>",
        //   error,
        //   error.body.message
        // );
        // this.ShowToastMessage('Error', this.label.LoanDetailsError, 'error', 'sticky')
        // this.showSpinner = false;
    //   });
  }

  checkValidtyChild() {
    let isInputCorrect = true;
    let allChilds = this.template.querySelectorAll("c-bt-loan-details");
    console.log("custom lookup allChilds>>>", allChilds);
    allChilds.forEach((child) => {
      console.log("validateForm>>>", child);
      console.log("validateForm>>>", isInputCorrect);
      if (!child.validateForm()) {
        child.validateForm();
        isInputCorrect = false;
        console.log("validateForm for bt loan #2343>>>", isInputCorrect);
      }
    });
    return isInputCorrect;
  }

  checkValidityLookup() {
    let isInputCorrect = true;
    let allChilds = this.template.querySelectorAll("c-custom-lookup");
    console.log("custom lookup allChilds>>>", allChilds);
    allChilds.forEach((child) => {
      console.log("custom lookup child>>>", child);
      console.log("custom lookup validity custom lookup >>>", isInputCorrect);
      if (!child.checkValidityLookup()) {
        child.checkValidityLookup();
        isInputCorrect = false;
        console.log("custom lookup validity if false>>>", isInputCorrect);
      }
    });
    return isInputCorrect;
  }

  handleSectionToggle(event) {
    const openSections = event.detail.openSections;
    if (openSections.length === 0) {
      this.activeSectionsMessage = "All sections are closed";
    } else {
      this.activeSectionsMessage = "Open sections: " + openSections.join(", ");
    }
  }

  @track requiredField = false;
  reportValidity() {
    let isValid = true;
    if (!this.checkValidityLookup()) {
      isValid = false;
    }
    if (!this.checkValidtyChild()) {
      isValid = false;
    }
    if (this.postFields) {
      if (this.emiYear && !this.checkDate()) {
        isValid = false;
      }
    }

    this.template.querySelectorAll("lightning-combobox").forEach((element) => {
      if (element.reportValidity()) {
        console.log("element passed combobox");
        console.log("element if--" + element.value);
      } else {
        isValid = false;
        console.log("element else--" + element.value);
      }
    });

    this.template.querySelectorAll("lightning-input").forEach((element) => {
      if (element.reportValidity()) {
        console.log("element passed lightning input");
      } else {
        isValid = false;
      }
    });

    //LAK-4925
    if (this.postFields) {
      if (this.intrstWaiverValue && this.intrstWaiverValue === 'Y') {
        if (this.waiverDocList && this.waiverDocList.length > 0) {
          this.requiredField = false;
        } else {
          if (isValid == false) {
            this.requiredField = false;
          } else {
            this.requiredField = true;
            isValid = false;
          }
        }
      } else {
        this.requiredField = false;
      }
    }

    return isValid;
  }

  @track finalArr = [];
  createBTLoanRec() {
    try {
      console.log(' this.btLoan:::::1971', this.btLoan);
      this.finalArr = this.btLoan.filter(item => item.isDirty === true)
      console.log('Filtered Final Array//1556', JSON.stringify(this.finalArr))

      let tempArray = [];
      let btLoanObj = {};

      for (let i = 0; i < this.finalArr.length; i++) {
        btLoanObj = {};
        btLoanObj.sobjectType = 'BTLoan__c'
        btLoanObj.BTFinancier__c = this.finalArr[i].BTFinancier__c
        btLoanObj.BTOriginalLoanAmt__c = this.finalArr[i].BTOriginalLoanAmt__c
        btLoanObj.BTLoanOutstandingValue__c = this.finalArr[i].BTLoanOutstandingValue__c
        btLoanObj.SpecifyOtherBTFinancier__c = this.finalArr[i].SpecifyOtherBTFinancier__c
        btLoanObj.BTFinancierStatus__c = this.finalArr[i].BTFinancierStatus__c
        btLoanObj.ExistFedfinaAccNo__c = this.finalArr[i].ExistFedfinaAccNo__c
        btLoanObj.EMI__c = this.finalArr[i].EMI__c;
        btLoanObj.Loantobeclosedinternally__c = this.finalArr[i].Loantobeclosedinternally__c;
        btLoanObj.LoanAppl__c = this.recordId
        btLoanObj.Id = this.finalArr[i].Id;
        tempArray.push(btLoanObj);
      }

      let upsertData = {
        parentRecord: { "Id": this.recordId },
        ChildRecords: tempArray,
        ParentFieldNameToUpdate: 'LoanAppl__c'
      }

      upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
        .then(result => {
          console.log('Loan Application Charge Record Created ##1538', result);
          this.refreshBtTable();
          this.showSpinner = false;

        })
        .catch(error => {
          console.error('Line no ##276', error)
        })

    } catch (e) {
      console.error('Final Error', e)
    }

  }

  refreshBtTable() {
    let child = this.template.querySelector('c-bt-loan-details');
    child.getBtLoanRecords();
  }

  ShowToastMessage(title, message, variant, mode) {
    const evt = new ShowToastEvent({
      title,
      message,
      variant,
      mode
    });
    this.dispatchEvent(evt);
  }

  // Changes Done Under LAK-4925(Interest Waiver Document) Developer Name: Dhananjay Gadekar
  @track documentTypeOptions = [{ label: "Interest waiver", value: "Interest waiver" }];
  @track documentNameOptions = [{ label: "Approval for Interest Waiver", value: "Approval for Interest Waiver" }]
  @track documentNameValue = 'Approval for Interest Waiver'; //LAK-5718
  @track documentTypeValue = 'Interest waiver';
  @track documentCategory = 'Other Documents';
  @track applicantId;
  @track disableDocumentUpload = false;
  @track convertToSingleImage = false;
  @track docmntDetId;
  @track waiverDocList = [];
  @track isFileDataPresent = false;
  @track deleteIconDisabled = false;
  @track hideAttachButton = false;
  @track removeModalMessage = "Do you really want to delete this file ?";
  @track showModalForFilePre = false;
  @track hasDocumentId = false
  @track documentDetailIdPreview;
  @track wiredDocumentList;
  @track isDeleteModalOpen = false;

  //It will show or hide Document upload section on the basis of Stage and interest waiver taken field value
  get showDocUploadSection() {
    if (this.stage && (this.stage === "Post Sanction" || this.stage === 'Disbursed' || this.stage === 'Disbursement Initiation')) {
      if (this.intrstWaiverValue && this.intrstWaiverValue === 'Y') {
        return true;
      }
      else
        if (this.intrstWaiverValue && this.intrstWaiverValue === 'N') {
          return false;
        }
    }
    else {
      return false;
    }
  }

  handleRecordIdChange() {
    let tempParams = this.paramsforDoc;
    tempParams.queryCriteria = ' where LoanAppln__c = \'' + this._recordId + '\' AND ApplType__c =\'' + 'P' + '\''
    this.paramsforDoc = { ...tempParams };
  }

  @track paramsforDoc = {
    ParentObjectName: 'Applicant__c',
    ChildObjectRelName: 'Applicant_Document_Details__r',
    parentObjFields: ['Id', 'ApplType__c', 'LoanAppln__c'],
    childObjFields: ['Id', 'DocTyp__c', 'DocSubTyp__c', 'Appl__c', 'DocCatgry__c', 'format(CreatedDate)'],
    queryCriteriaForChild: ' where DocTyp__c = \'' + this.documentTypeValue + '\'',
    queryCriteria: ' where LoanAppln__c = \'' + this.recordId + '\' AND ApplType__c =\'' + 'P' + '\''
  }

  //To get applicant data as well as uploaded files data for Interest waiver. 
  @wire(getDataForFilterChild, { params: '$paramsforDoc' })
  handleApplWiredData(result) {
    const { data, error } = result;
    this.wiredDocumentList = result;
    console.log('wiredDocumentList--------------->', JSON.stringify(this.wiredDocumentList))
    if (data) {
      if (data.parentRecord) {
        this.applicantId = data.parentRecord.Id;
      } else {
        console.log("No data in Applicant details ##2863");
      }

      if (data.parentRecord && data.parentRecord.Applicant_Document_Details__r && data.parentRecord.Applicant_Document_Details__r.length > 0) {
        this.handleDocumentDetails(data.parentRecord.Applicant_Document_Details__r);
      } else {
        this.isFileDataPresent = false;
        this.waiverDocList = [];
        console.log("No data in Applicant Document details ##2869");
      }

    } else if (error) {
      console.log('Applicant Details Error ##2711', error);
    }
  }

  //Processing interest waiver document data to show on UI.
  handleDocumentDetails(documentDetails) {
    this.docmntDetId = undefined;
    this.waiverDocList = [];
    let docmnetArr = [];
    let tempFiles = [];
    if (documentDetails && documentDetails.length > 0) {
      documentDetails.forEach(record => {
        if (record.DocTyp__c && record.DocCatgry__c && record.DocSubTyp__c && record.DocCatgry__c == 'Other Documents'
          && record.DocTyp__c == 'Interest waiver' && record.DocSubTyp__c == 'Approval for Interest Waiver') {
          this.isFileDataPresent = true;
          this.docmntDetId = record.Id;
          docmnetArr = [...docmnetArr, record];
        } else {
          this.isFileDataPresent = false;
        }
      })
      this.waiverDocList = [...docmnetArr];
    }
  }

  //After file upoaded succesfully this method will get call from child component & It will process uploaded file details 
  docUploadRespHandler(event) {
    let isFileUploaded = event.detail.fileUploaded;
    let fileUploadData = event.detail;
    if (isFileUploaded == true) {
      this.hideAttachButton = true;
      this.docmntDetId = fileUploadData.docDetailId;
      this.showSpinner = false;
      this.hasDocumentId = false;
      refreshApex(this.wiredDocumentList);
    } else {
      this.showSpinner = false;
    }
  }

  //To handle document preview
  handleDocumentViewPreview(event) {
    var documentIdPreview = event.currentTarget.dataset.documentid;
    this.documentDetailIdPreview = documentIdPreview;
    this.hasDocumentId = true;
    this.showModalForFilePre = true;
  }

  // To close Document preview modal
  handleCloseModalEvent(event) {
    this.showModalForFilePre = false;
  }

  //To get document detail id to delete
  handleDocumentDelete(event) {
    this.parentSection = '';
    this.docIdToDelete = event.currentTarget.dataset.documentid;
    this.isDeleteModalOpen = true;
  }

  // To close delete modal popup
  closeModalDelete() {
    this.isDeleteModalOpen = false;
  }

  handleRemoveRecord(event) {
    this.showSpinner = true;
    this.deleteDocDet(this.docIdToDelete, false);
    this.isDeleteModalOpen = false;
  }

  //To delete Interest waiver document detail record.
  deleteDocDet(docIdToDelete, hideToastMessage) {
    if (docIdToDelete) {
      deleteDocRecord({ docDtlId: docIdToDelete })
        .then((result) => {
          this.showModalForFilePre = false;
          this.docmntDetId = undefined;
          this.showSpinner = false;
          this.isDeleteModalOpen = false;
          refreshApex(this.wiredDocumentList);
          if (!hideToastMessage) {
            this.ShowToastMessage('Success', 'Document Deleted Successfully', 'success', "sticky");
          }
        })
        .catch((error) => {
          this.showSpinner = false;
          this.isDeleteModalOpen = false;
          this.ShowToastMessage('Error', 'Unexpected error occurred. Please try again!! ', 'error', "sticky");
        });
    } else {
      this.showSpinner = false;
      this.isDeleteModalOpen = false;
    }
  }

  //To start spinner when we upload document
  spinnerStatus(event) {
    this.showSpinner = false;
    this.showSpinner = event.detail;
  }

  get _docmntDetId() {
    return this.docmntDetId;
  }

  // To capture document name change
  documentNameChangeHandler(event) {
    this.documentNameValue = event.target.value;
  }

  renderedCallback() {
    refreshApex(this.wiredDocumentList);
  }

}