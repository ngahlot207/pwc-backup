import { LightningElement, api, wire, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getSobjectDatawithRelatedRecords from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords";
import getSobjectData from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData";
import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";


import getAssetPropType from "@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType";
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
import {
  subscribe,
  publish,
  MessageContext,
  unsubscribe,
  releaseMessageContext,
  createMessageContext
} from "lightning/messageService";
import RECORDCREATE from "@salesforce/messageChannel/RecordCreate__c";
import {
  getObjectInfo,
  getPicklistValues,
  getPicklistValuesByRecordType
} from "lightning/uiObjectInfoApi";
import {
  getRecord,
  getFieldValue,
  getFieldDisplayValue
} from "lightning/uiRecordApi";
import {
  createRecord,
  updateRecord
} from "lightning/uiRecordApi";
import deleteRecord from '@salesforce/apex/SObjectDynamicRecordProvider.deleteRecord';

import upsertSobjDataWIthRelatedChilds from "@salesforce/apex/SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds";
import APPLICANT_ADDRESS_OBJECT from "@salesforce/schema/ApplAddr__c";
import ADDRESS_TYPE_FIELD from "@salesforce/schema/ApplAddr__c.AddrTyp__c";
import ISERVICEABLE_FIELD from "@salesforce/schema/LocMstr__c.IsServiceable__c";
import APPLICANT_ASSET_OBJECT from "@salesforce/schema/ApplAsset__c";
import PROPERTY_IDENTI_FIELD from "@salesforce/schema/ApplAsset__c.PropIdentified__c";
import COPY_ADD__FROM_EXI_ADD_FIELD from "@salesforce/schema/ApplAsset__c.CopyAddFrmExAdd__c";
import PROPERTY_TYPE_FIELD from "@salesforce/schema/ApplAsset__c.PropType__c";
import PROPERTY_CATE_FIELD from "@salesforce/schema/ApplAsset__c.PropCat__c";
import NATURE_OF_PRO_FIELD from "@salesforce/schema/ApplAsset__c.NatureofProp__c";
import ISERVI_FIELD_LOCBRNCH from "@salesforce/schema/LocBrchJn__c.IsActive__c";

import { refreshApex } from "@salesforce/apex";
import { RefreshEvent } from 'lightning/refresh';

import UserId from "@salesforce/user/Id";
import UserNameFIELD from "@salesforce/schema/User.Name";
import { NavigationMixin } from 'lightning/navigation';
import IsBT from "@salesforce/schema/SchMapping__c.IsBT__c";
import schemeId from "@salesforce/schema/SchMapping__c.SchmId__c";

//const fieldOfIsServiceable = [ISERVICEABLE_FIELD];
const fieldOfIsServiceable = [ISERVI_FIELD_LOCBRNCH];

const propertyType = [PROPERTY_TYPE_FIELD];
const userId = [UserId];
const schemeFileds = [
  IsBT, schemeId
];
// Custom labels
import PropertyDetails_Save_SuccessMessage from '@salesforce/label/c.PropertyDetails_Save_SuccessMessage';
import PropertyDetails_PropType_ErrorMessage from '@salesforce/label/c.PropertyDetails_PropType_ErrorMessage';
import PropertyDetails_ReqFields_ErrorMessage from '@salesforce/label/c.PropertyDetails_ReqFields_ErrorMessage';
import PropertyDetails_Branch_ErrorMessage from '@salesforce/label/c.PropertyDetails_Branch_ErrorMessage';

export default class CapturePropertyDetails extends NavigationMixin(LightningElement) {

  label = {
    PropertyDetails_Save_SuccessMessage,
    PropertyDetails_PropType_ErrorMessage,
    PropertyDetails_ReqFields_ErrorMessage,
    PropertyDetails_Branch_ErrorMessage

  }
  // @api applicantId;
  @api layoutSize;
  @api hasEditAccess;
  @track disableMode;
  @track _currentTabId;
  @api get currentTabId() {
    return this._currentTabId;
  }
  set currentTabId(value) {
    this._currentTabId = value;
    this.setAttribute("currentTabId", value);

    this.handleRecordIdChange(value);
  }
  @track _loanAppId;
  @track docDisplayDisable;
  @api get loanAppId() {
    return this._loanAppId;
  }
  set loanAppId(value) {
    this._loanAppId = value;
    this.setAttribute("loanAppId", value);

    this.handleRecordAppIdChange(value);
    // this.handleLeadRecord(value);
  }
  @track _applicantId;
  @api get applicantId() {
    return this._applicantId;
  }
  set applicantId(value) {
    this._applicantId = value;
    this.setAttribute("applicantId", value);

    this.handleAddrRecordChange(value);
  }
  subscription = null;
  context = createMessageContext();

  requiredFlag = true;
  @track isReqDownPay = false
  @track isPropVal = false;
  @track isPinReq = false;
  @track isRequired = false;
  @track addrTypeValue;
  // @track disabled = true;
  @track isDisabled = false;
  @track disPropIden = false;
  @track disbNatProp = false
  @track reqTotConsEst = false
  @track cityId;
  @track pinId;
  @track stateId;
  @track cityNm;
  @track selectedRecordName;
  @track activeSection = ["A", "C"];
  @track propIden = true;
  @track addrTyVisi = true;
  @track propTypeList = [];
  @track wingNameOp = [];
  @track cautionAreaOptions = [];
  @track imprmntEstConstrDocOptions = [];
  @track multiTenatPropOptions = [];
  @track chngeValPolcyNormOptions = [];
  @track bndryOfPropMatchOptions = [];
  @track isTitleClrOptions = [];

  @track isConstrEstDocFieldVsbl = false;
  @track apprCostConstrFieldVsbl = false;
  @track estArchAgreeFieldVsibl = false;
  @track showValuationFields = false
  @track showDownPayNBalOCRValFields = false
  @track showBalanceOCRField = false;
  @track isReqCautionArea;
  @track reqPropCarpArea;
  @track reqRateLandArea;
  @track reqImprvEstmCost;
  @track reqApprCostConstr;
  @track reqIsPropMultTent;
  @track reqNoOfTents;
  @track reqRentlBankCrdt;
  @track reqStageOfConstr;
  @track reqEstmtArchAgrmnt;
  @track reqValPolcyNorms;
  @track reqChangeReqInPolNorm;
  @track reqTakenValAhdCalc;

  @track exiAddrCopy = true
  @track showFieldsAtDDE = false;
  @track isReqLandm = false
  @track reqIsTitle = false
  @track isApfYesOrNo = false
  @track ifChangReqInValua = false
  @track ifNoSelectedInChangReqInValua = false

  @track
  params = {
    ParentObjectName: "LoanAppl__c",
    ChildObjectRelName: "Applicants__r",
    parentObjFields: [
      "Id",
      "Name",
      "Product__c",
      "Stage__c",
      "SubStage__c",
      "ProductSubType__c",
      "BrchCode__c",
      "SchmCode__c",
      "SchemeId__c",
      "SanLoanAmt__c"
    ],
    childObjFields: [
      "Id",
      "FName__c",
      "MName__c",
      "LName__c",
      "LoanAppln__c",
      "CompanyName__c",
      "Constitution__c",
      "ApplType__c"
    ],
    queryCriteria: ""
  };

  //SELECT Id, Name, Appl__c, ApplAsset__c FROM ApplAssetJn__c where Appl__c = 'a0AC4000000KDAnMAO'

  @track applAssetJnParams = {
    ParentObjectName: 'ApplAssetJn__c',
    ChildObjectRelName: '',
    parentObjFields: ['Id', 'Appl__c', 'ApplAsset__c'],
    childObjFields: [],
    queryCriteria: ''
  }

  @track propSubTy = [];
  @track
  appAddrParam = {
    ParentObjectName: "ApplAddr__c",
    ChildObjectRelName: "",
    parentObjFields: [
      "HouseNo__c",
      "AddrLine1__c",
      "AddrLine2__c",
      "Landmark__c",
      "Locality__c",
      "City__c",
      "State__c",
      "Pincode__c",
      "AddrTyp__c",
      "CityId__c",
      "PinId__c",
      "StateId__c",
      "Applicant__c"
    ],
    childObjFields: [],
    queryCriteria: ""
  };
  @track
  aPFMasterParam = {
    ParentObjectName: "APF_Master__c",
    ChildObjectRelName: "",
    parentObjFields: [
      "APF_Appr_Dt__c",
      "APF_Ref__c",
      "Addr_Ln1__c",
      "Addr_Ln2__c",
      "Area_or_Loca__c",
      "Branch__c",
      "BuildNm_BlokNo_WinNm__c",
      "Build_Cate__c",
      "Build_Grp_Na__c",
      "Build_Id__c",
      "Build_Na__c",
      "City__c",
      "Date_of_Last_Proj_Sta_Upd__c",
      "Hou_Flat_Shop_PlotNo__c",
      "Landmark__c",
      "Pin_Code__c",
      "Proj_Id__c",
      "Proj_Na__c",
      "State__c"
    ],
    childObjFields: [],
    queryCriteria: ""
  };
  @track
  propMastParam = {
    ParentObjectName: "PropSubTypeMstr__c",
    ChildObjectRelName: "",
    parentObjFields: ["Id", "Desc__c", "Value__c"],
    childObjFields: [],
    queryCriteria: ""
  };
  @track
  pincodeParams = {
    ParentObjectName: "PincodeMstr__c",
    ChildObjectRelName: "",
    parentObjFields: ["Id", "City__r.City__c"],
    childObjFields: [],
    queryCriteria: ""
  };

  @track
  cityParams = {
    ParentObjectName: "LocMstr__c",
    ChildObjectRelName: "",
    parentObjFields: ["Id", "State__c", "IsServiceable__c"],
    childObjFields: [],
    queryCriteria: ""
  };
  //    "SELECT Id,AccountId,Account.Name, Land_Area_Sq_Ft__c, Property_Built_up_area_Sq_Ft__c, Land_Valuation_in_Rs__c,Built_up_area_Valuation_In_Rs__c,Total_Valuation_Land_Valuation_B__c,  Approx_Age_of_Property_in_Years__c, Residual_Age_in_Years__c,   Applicant__c, Loan_Application__c, Product_Type__c, ApplAssetId__c, DateofInitiation__c FROM Case WHERE Loan_Application__c =: loanAppId AND recordtype.name =: techRecordType AND ApplAssetId__c=: currentTabId";

  @track caseParameters = {
    ParentObjectName: "Case",
    ChildObjectRelName: "",
    parentObjFields: ["Id", "ApplAssetId__c", "Loan_Application__c", "Total_Valuation_Land_Valuation_B__c", "Status"],
    childObjFields: [],
    queryCriteria: ""
  };
  // SELECT Id, Name, Location__c, Branch__c, ProductType__c, IsActive__c FROM LocBrchJn__c where Location__r.City__c = 'Nagpur'
  @track
  locBranMastParams = {
    ParentObjectName: "LocBrchJn__c",
    ChildObjectRelName: "",
    parentObjFields: [
      "Id",
      "Name",
      "Location__c",
      "Branch__c",
      "ProductType__c",
      "IsActive__c"
    ],
    childObjFields: [],
    queryCriteria: ""
  };

  // @track
  // bankBrnchMast = {
  //   ParentObjectName: "BankBrchMstr__c",
  //   ChildObjectRelName: "",
  //   parentObjFields: ["Id", "Name", "BrchCode__c"],
  //   childObjFields: [],
  //   queryCriteria: ""
  // };

  @track
  assetParams = {
    ParentObjectName: "ApplAsset__c",
    ChildObjectRelName: "ApplAssetJn__r",
    parentObjFields: [
      "Id",
      "Name",
      "Appl__c",
      "LoanAppln__c",
      "PropIdentified__c",
      "CopyAddFrmExAdd__c",
      "AddrType__c",
      "FlatNo__c",
      "AddrLn1__c",
      "AddrLn2__c",
      "Landmark__c",
      "AreaLocality__c",
      "City__c",
      "Pin_Code__c",
      "State__c",
      "ServiceableCity__c",
      "DistFrmSourceBrch__c",
      "PropType__c",
      "DistFrmNearBrch__c",
      "PropSubType__c",
      "PropSubTypeDesc__c",
      "NatureofProp__c",
      "Property_Usage__c",
      "PropCat__c",
      "CityId__c",
      "PinId__c",
      "StateId__c",
      "Prop_Sub_TyId__c",
      "Is_it_an_APF__c",
      "APF_Ref_No__c",
      "Builder_ID__c",
      "Builder_nm__c",
      "ProjID__c",
      "Proj_Nm__c",
      "APFWingNo__c",
      "APFAddrLn1__c",
      "APFAddrLn2__c",
      "APFLandmk__c",
      "APFAreaOrLoc__c",
      "APFCity__c",
      "APFPinCode__c",
      "APFState__c",
      "Agrem_Value__c",
      "Appr_Cost_of_Const__c",
      "Regi_Cost__c",
      "Stamp_Duty__c",
      "Amenities__c",
      "Total_Prop_Cost__c",
      "APFRefId__c",
      "APFHouse_Flat_PlotNo__c",
      "Cost_of_Plot__c",
      "Negative_Caution_Area__c",
      "Property_Carpet_area_Sq_Ft__c",
      "Improvement_construction_estimate_docum__c",
      "Per_Sq_Ft_Approved_Cost_of_Construction__c",
      "Per_Sq_Ft_Approved_Cost_of_Const__c",
      "Is_the_property_Multi_Tenanted__c",
      "No_of_Tenants__c",
      "AveNetMnthlyRentalAsPerBankCredit__c",
      "Stage_of_Construction__c",
      "Total_estimate_as_per_architect_agreemen__c",
      "Valuation_as_per_policy_norms__c",
      "ChangeRequiredInValuationAsPerPolicyNorm__c",
      "ValuationToBeTakenAheadForCalculation__c",
      "Comments_on_Collateral__c",
      "Down_payment_PartORegisteredAgreement__c",
      "Balance_OCR_to_be_arranged_by_customer__c",
      "Rera__c",
      "Is_the_title_clear_markateble__c",
      "IdentiAndBoundaryOfProprtyMatchWithPaper__c",
      "Approx_Age_of_Prop__c",
      "Resi_Age__c",
      "Prop_Bui_up_ar__c",
      "Land_Area__c",
      "Total_Valua__c",
      "Built_up_area_Valu__c",
      "Land_Valu__c",
      "PerSqFtRateLandArea__c",
      "PerSqFtRateBuiltUpArea__c",
      "Bound_are_prop_dem_n_ide__c",
      "Addr_of_prop_veri_as_per_Tit__c"
    ],
    childObjFields: [
      "Id",
      "Name",
      "ApplAsset__c",
      "Appl__c",
      "Appl__r.CompanyName__c"
    ],
    queryCriteria: ""
  };

  @track
  assetPropType = {
    ParentObjectName: "ApplAsset__c",
    ChildObjectRelName: "",
    parentObjFields: ["Id", "PropType__c", "Appl__c", "LoanAppln__c"],
    childObjFields: [],
    queryCriteria: ""
  };
  @track teamHier = {
    ParentObjectName: "TeamHierarchy__c",
    ChildObjectRelName: "",
    parentObjFields: [
      "Id",
      "IsActive__c",
      "Product_Type__c",
      "EmpRole__c",
      "Employee__c"
    ],
    childObjFields: [],
    queryCriteria:
      " where IsActive__c = true AND Employee__c = '" + userId + "'"
  };

  @track caseParams = {};
  // @track disbApf = false;
  @track apfReq = false;
  @track propValuReq = false;
  @track isApf = false;
  @track isApfSelectNo = false;
  @track natureOfProOp = [];
  propIdetifiedPikVal = [];
  existingAddrOpt = [];
  @track addrTyOption = [];
  propertyTyOpt = [];
  prpertyCateOpt = [];
  @track wrapAddressObj = {
    ChangeRequiredInValuationAsPerPolicyNorm__c: 'NO'
  };
  @track natureOfPropOpti = [];
  @track selectedValueList = [];
  @track optionOfApp = [];
  @track parentRds;
  @track propValue;
  @track propSubTyDesc = [];
  @track parentRecord = [];
  @track _wiredAssetData;
  @track plotNoList = [];
  @track housePlotNoOp = [];
  @track quesProp = false;
  @track isReqRera = false
  @track reqForPostVer = false
  @track propFields = false
  @track propCate = false
  @track NatOfProp = false
  @track showSpinner;

  @wire(MessageContext)
  MessageContext;

  @track columnsDataForTable = [
    {
      label: "Technical Agency Name",
      fieldName: "Account.Name",
      type: "text",
      Editable: false
    },
    {
      label: "Land Area (Sq Ft)",
      fieldName: "Land_Area_Sq_Ft__c",
      type: "number",
      Editable: false
    },
    {
      label: "Property Built up area (Sq Ft)",
      fieldName: "Property_Built_up_area_Sq_Ft__c",
      type: "number",
      Editable: false
    },
    {
      label: "Land Valuation (₹)",
      fieldName: "Land_Valuation_in_Rs__c",
      type: "number",
      Editable: false
    },
    {
      label: "Built up area Valuation (₹)",
      fieldName: "Built_up_area_Valuation_In_Rs__c",
      type: "number",
      Editable: false
    },
    {
      label: "Total Valuation",
      fieldName: "Total_Valuation_Land_Valuation_B__c",
      type: "number",
      Editable: false
    },
    {
      label: "Approx. Age of Property - in Years",
      fieldName: "Approx_Age_of_Property_in_Years__c",
      type: "number",
      Editable: false
    },
    {
      label: "Residual Age - in Years",
      fieldName: "Residual_Age_in_Years__c",
      type: "number",
      Editable: false
    },
    {
      label: "Report date",
      fieldName: "DateTimeInitiation__c",
      type: "Date/Time",
      Editable: false
    }
  ];
  @track wingNoHelpText = "Please populate APF Ref No First";
  @track flatNoHelpText = "Please select Wing No First";
  @track mandBefFnSanc = "This field is mandatory before final sanction."
  @track stageN = "propertyDetails"
  handleRecordIdChange(value) {
    let tempParams = this.assetParams;
    tempParams.queryCriteria = " where Id = '" + this._currentTabId + "'";
    this.assetParams = { ...tempParams };
  }
  handleRecordAppIdChange(value) {
    let tempParams = this.params;
    tempParams.queryCriteria = " where Id = '" + this._loanAppId + "'";
    this.params = { ...tempParams };
  }

  @track propOwnerSelectList = [];
  @track assetJnId;
  handleSelectPropertOwners(event) {
    this.selectedValueList = event.detail;
    this.propOwnerSelectList = event.detail;
    console.log('kfasfk', this.propOwnerSelectList);
    this.propOnwerSaveHandler();
  }

  @track handlePill;
  handleDeletedPillValue(event) {
    this.handlePill = event.detail;
    let deletedApplValue = event.detail;
    console.log('handle delete pill', event.detail);
    this.applAssetJnParams.queryCriteria = " where Appl__c = '" + deletedApplValue + "' AND ApplAsset__c = '" + this._currentTabId + "'";

    getSobjectDataNonCacheable({ params: this.applAssetJnParams })
      .then((result) => {
        console.log('result from appl asset jn', result);
        if (result.parentRecords && result.parentRecords.length > 0) {
          this.assetJnId = result.parentRecords[0].Id;
          // jknkj
          if (this.assetJnId && result.parentRecords[0].Id) {
            this.showSpinner = true;

            let deleteRecordJson = [{
              Id: this.assetJnId,
              sobjectType: 'ApplAssetJn__c'
            }];
            console.log('print delete id of pill', this.assetJnId, result.parentRecords[0].Id);
            deleteRecord({ rcrds: deleteRecordJson })
              .then(() => {
                console.log('deleted successfully!!!');
                refreshApex(this._wiredAssetData);
                this.showSpinner = false;

              }).catch(error => {
                console.log('error print while delete pill', error);
                console.log('pill error in catch', error.message);
                console.log('pill body error in catch', error.body.message);

                this.showSpinner = false;
              });

          }

        }

      })
      .catch((error) => {
        console.error("Error", error);
      });

  }

  handleAddrRecordChange(event) {
    let tempParams = this.appAddrParam;
    tempParams.queryCriteria =
      "  where Applicant__c = '" + this._applicantId + "'";
    this.appAddrParam = { ...tempParams };
  }

  get apfOption() {
    return [
      { label: "Yes", value: "Yes" },
      { label: "No", value: "No" }
    ];
  }

  @track disbValToTakCal;
  @track isServCity;
  @track fullName;
  @track dataId;
  @track _prodTy;
  get prodTy() {
    return this._prodTy;
  }
  set prodTy(value) {
    this._prodTy = value;
    this.setAttribute("prodTy", value);

    // this.handleRecordAppIdChange(value);
    // this.handleLeadRecord(value);
  }
  @track _subProdTy;
  get subProdTy() {
    return this._subProdTy;
  }
  set subProdTy(value) {
    this._subProdTy = value;
    this.setAttribute("subProdTy", value);
  }
  subscription = null;
  @track branCode;
  @track _wiredPropOwnerData;
  @track stageOfLAN
  @track ownerList = [];


  @track schemeBT
  @wire(getRecord, { recordId: "$schemId", fields: schemeFileds })
  recordSchemesHandler({ data, error }) {
    if (data) {
      this.schemeBT = data.fields.IsBT__c.value;
      console.log('schemeBT'+data.fields.IsBT__c.value);
      this.scheIdFromRd = data.fields.SchmId__c.value;
      if (this.schemeBT === true) {
        if (this._prodTy !== undefined && this._subProdTy !== undefined) {
          if (
            this._prodTy === "Home Loan" ||
            (this._prodTy === "Small Ticket LAP" &&
              this._subProdTy === "Commercial Property Purchase") ||
            (this._prodTy === "Loan Against Property" &&
                this._subProdTy === "Commercial Property Purchase")
          ) {
            this.showValuationFields = false//LAK-7857
            // this.estArchAgreeFieldVsibl = false;
            this.propValuReq = false;
          }
        }
        if (this.scheIdFromRd && this._prodTy === "Home Loan") {
          if (this.scheIdFromRd && (this.scheIdFromRd === "546" || this.scheIdFromRd === "549" || this.scheIdFromRd === "545" || this.scheIdFromRd === "554" || this.scheIdFromRd === "555" || this.scheIdFromRd === "557")) {
            this.isReqDownPay = false
            this.showDownPayNBalOCRValFields = false
          } else {
            this.showDownPayNBalOCRValFields = true
            this.showBalanceOCRField = this.scheIdFromRd === "558" ? false : true; //LAK-7660
            if (this.loanApplStage && this.loanApplStage !== "DDE") {
              this.isReqDownPay = true

            }
          }
        }
      } else {
        if (this._prodTy !== undefined && this._subProdTy !== undefined) {
          if (
            this._prodTy === "Home Loan" ||
            (this._prodTy === "Small Ticket LAP" &&
              this._subProdTy === "Commercial Property Purchase") ||
              (this._prodTy === "Loan Against Property" &&
                this._subProdTy === "Commercial Property Purchase")
          ) {
            this.showValuationFields = true
            // this.estArchAgreeFieldVsibl = true;
            if (this.loanApplStage && this.loanApplStage !== "DDE") {
              this.propValuReq = true;
            }
          }
        }
        if (this.scheIdFromRd && this._prodTy === "Home Loan") {
          if (this.scheIdFromRd && (this.scheIdFromRd === "546" || this.scheIdFromRd === "549" || this.scheIdFromRd === "545" || this.scheIdFromRd === "554" || this.scheIdFromRd === "555" || this.scheIdFromRd === "557")) {
            this.showDownPayNBalOCRValFields = false
            this.isReqDownPay = false
          } else {
            this.showDownPayNBalOCRValFields = true
            this.showBalanceOCRField = this.scheIdFromRd === "558" ? false : true;//LAK-7660
            if (this.loanApplStage && this.loanApplStage !== "DDE") {
              this.isReqDownPay = true
            }
          }
        }
      }

    }
    if (error) {
      console.log("ERROR::::::: #376", error);
    }
  }

  @track schemId
  @track loanApplStage
  @track sancLoanAmt

  @wire(getSobjectDatawithRelatedRecords, { params: "$params" })
  handleResponse(result) {
    // const { data, error } = result;
    this._wiredPropOwnerData = result;

    let tempSelectedPropertyOwners = [];
    let propertyOwnersList = [];
    this.optionOfApp = [];
    if (result.data) {
      this.prodTy = result.data.parentRecord.Product__c;
      this.subProdTy = result.data.parentRecord.ProductSubType__c;
      this.branCode = result.data.parentRecord.BrchCode__c;
      this.schemId = result.data.parentRecord.SchemeId__c
      this.sancLoanAmt = result.data.parentRecord.SanLoanAmt__c

      this.loanApplStage = result.data.parentRecord.Stage__c
      let stage = result.data.parentRecord.Stage__c;
      this.stageOfLAN = result.data.parentRecord.Stage__c
      let subStage = result.data.parentRecord.SubStage__c;
      let prductSubType = result.data.parentRecord.ProductSubType__c;
      let schemeCode = result.data.parentRecord.SchmCode__c;
      let product = result.data.parentRecord.Product__c;
       if(stage==='Post Sanction' && (subStage === 'Ops Query' || subStage === 'UW Approval' || subStage === 'Data Entry') && this.hasEditAccess === false ){
        this.docDisplayDisable = false;
        this.propIden = true;
       }
       else if(this.hasEditAccess === false){
        this.docDisplayDisable = true;

       }
      if (this._currentTabId === "new") {
        if (this._prodTy && this._subProdTy &&
          (this._prodTy === "Small Ticket LAP" || this._prodTy === "Loan Against Property") &&
          this._subProdTy === "LAP Commercial"
        ) {
          this.wrapAddressObj.PropIdentified__c = "Yes";
        } else if (this._prodTy && this._subProdTy &&
          (this._prodTy === "Small Ticket LAP" || this._prodTy === "Loan Against Property") &&
          this._subProdTy === "LAP Residential"
        ) {
          this.wrapAddressObj.PropIdentified__c = "Yes";
        }
      }

      //LAK-9174
      if (this._currentTabId === "new"){
        if (this._prodTy && this._prodTy === "Small Ticket LAP") {
          this.wrapAddressObj.PropIdentified__c = "Yes";
          this.disPropIden = true;
        }
      }

      if (this.wrapAddressObj.Id === undefined) {
        this.disbNatProp = true
      }
      if (this.wrapAddressObj.Is_it_an_APF__c === undefined) {
        this.wrapAddressObj.Is_it_an_APF__c = "No";
        this.exiAddrCopy = true
        this.isApfYesOrNo = true
      }

      if (stage !== "QDE") {
        this.isPropVal = true;
        this.quesProp = true;
        this.wrapAddressObj.Is_it_an_APF__c = "No";
        if (
          (this._prodTy === "Small Ticket LAP" || this._prodTy === "Loan Against Property") &&
          this._subProdTy === "LAP Commercial"
        ) {
          this.showValuationFields = false;

        } else if (
          (this._prodTy === "Small Ticket LAP" || this._prodTy === "Loan Against Property") &&
          this._subProdTy === "LAP Residential"
        ) {
          this.showValuationFields = false;

        }
      }

      if (stage && stage === "DDE") {
        this.propValuReq = false
        this.isReqCautionArea = true;
        this.reqRateLandArea = false;
        this.reqRateBuldUpArea = false;
        this.reqImprvEstmCost = false;
        this.reqApprCostConstr = false;
        this.reqNoOfTents = false;
        this.reqIsPropMultTent = false;
        this.reqRentlBankCrdt = false;
        this.reqPropCarpArea = false;
        this.reqStageOfConstr = false;
        this.reqEstmtArchAgrmnt = false;
        this.reqValPolcyNorms = false;
        this.reqChangeReqInPolNorm = false;
        this.reqTakenValAhdCalc = false;
        this.reqForPostVer = false
        this.propFields = false
        this.propCate = false
        this.NatOfProp = false
      } else if (stage && stage === "QDE") {
        this.propFields = false
        this.propCate = false
        this.NatOfProp = false
        this.reqApprCostConstr = false;
        this.wrapAddressObj.Is_it_an_APF__c = "No";
      } else {
        this.isReqCautionArea = false;
        this.reqRateLandArea = true;
        this.reqRateBuldUpArea = true;
        this.reqImprvEstmCost = true;
        this.reqApprCostConstr = true;
        // this.reqNoOfTents = true;
        // this.reqIsPropMultTent = true;
        // this.reqRentlBankCrdt = true;
        this.reqPropCarpArea = true;
        this.reqStageOfConstr = true;
        this.reqEstmtArchAgrmnt = true;
        this.reqValPolcyNorms = true;
        this.reqChangeReqInPolNorm = true;
        this.reqTakenValAhdCalc = true;
        this.propValuReq = true
        this.reqForPostVer = true
        this.propFields = true
        this.propCate = true
        this.NatOfProp = true
      }

      //field disable logic

      // if (stage && stage !== "DDE") {
      //   this.disPropCarpArea = false;
      // }

      if (stage && stage !== "QDE") {
        this.showFieldsAtDDE = true;
        this.isReqRera = true
        this.isReqCautionArea = true;
      }
      if (stage && stage === "Post Sanction") {
        this.reqIsTitle = true
      }

      //Field visibility logic

      if (
        (prductSubType && prductSubType === "Home Improvement loan") ||
        (schemeCode && schemeCode == "HL - PLOT + CONSTRUCTION") ||
        schemeCode == "HL - PLOT + CONSTRUCTION - FIXED" ||
        schemeCode == "HL - CONSTRUCTION" ||
        schemeCode == "HL - CONSTRUCTION - FIXED"
      ) {
        this.apprCostConstrFieldVsbl = true;
        this.estArchAgreeFieldVsibl = true;
        // this.stgeOfConstrFieldVsbl = true;
      } else {
        this.apprCostConstrFieldVsbl = false;
        this.estArchAgreeFieldVsibl = false;
      }

      if (schemeCode && (schemeCode == "HL - PLOT + CONSTRUCTION" ||
        schemeCode == "HL - PLOT + CONSTRUCTION - FIXED" ||
        schemeCode == "HL - CONSTRUCTION" ||
        schemeCode == "HL - CONSTRUCTION - FIXED")
      ) {
        this.isConstrEstDocFieldVsbl = true;
      }

      // to hide fields in QDE stage we can write uniform logic like stage !== QDE field visibility =true
      if (result.data.ChildReords) {
        result.data.ChildReords.forEach((data1) => {
          // this.dataId = data1.Id;
          if (
            data1.Constitution__c === "INDIVIDUAL" &&
            data1.ApplType__c !== null &&
            data1.ApplType__c !== undefined &&
            data1.ApplType__c !== ""
          ) {
            if (data1.FName__c === null) {
              this.fullName = data1.LName__c;
              this.dataId = data1.Id;
            } else if (data1.FName__c !== null) {
              this.fullName = `${data1.FName__c} ${data1.LName__c}`;
              this.dataId = data1.Id;
            }
          } else if (
            data1.Constitution__c !== "INDIVIDUAL" &&
            data1.ApplType__c !== null &&
            data1.ApplType__c !== undefined &&
            data1.ApplType__c !== ""
          ) {
            this.fullName = data1.CompanyName__c;
            this.dataId = data1.Id;
          }

          if (
            data1.ApplType__c !== null &&
            data1.ApplType__c !== undefined &&
            data1.ApplType__c !== ""
          ) {
            propertyOwnersList.push({
              label: this.fullName,
              value: this.dataId
            });
          }
          tempSelectedPropertyOwners.push(data1.Id);
        });

        this.propList = propertyOwnersList.filter(
          (item) => item.label !== undefined && item.value !== undefined
        );

        this.optionOfApp = this.propList;

        let tempParams = this.assetParams;
        tempParams.queryCriteria = " where Id = '" + this._currentTabId + "'";
        this.assetParams = { ...tempParams };
      }
    }
    if (result.error) {
      console.log("error print", result.error);
    }
  }
  @track apfNoList = [];
  @track oldPropTy
  @track valuToBeTaken = []
  @track valuToBeTakForCalOption = []

  @wire(getSobjectData, { params: '$caseParameters' })
  apfRefData({ error, data }) {
    if (data) {
      if (data.parentRecords) {
        data.parentRecords.forEach(element => {
          const roundedValue = parseFloat(element.Total_Valuation_Land_Valuation_B__c).toFixed(2);
          const labelWithRupees = `₹${roundedValue}`;
          this.valuToBeTaken.push({ label: labelWithRupees, value: roundedValue });
          // this.valuToBeTaken.push({ label: element.Total_Valuation_Land_Valuation_B__c, value: element.Total_Valuation_Land_Valuation_B__c });
        });
        this.valuToBeTakForCalOption = [...this.valuToBeTaken];
        if (this.valuToBeTakForCalOption && this.wrapAddressObj.ChangeRequiredInValuationAsPerPolicyNorm__c === "YES") {
          this.ifChangReqInValua = true
          this.ifNoSelectedInChangReqInValua = false
          this.wrapAddressObj.ValuationToBeTakenAheadForCalculation__c = parseFloat(this.wrapAddressObj.ValuationToBeTakenAheadForCalculation__c).toFixed(2);

        }

      }

    } else if (error) {
      console.log('error ', error);
    }
  }

  @track reqApprAgeOfProp = false
  @track propOwner = []; // hold Asset JN Records
  @track assetJnRecords = []
  @track valAsPerPropNorms
  @wire(getSobjectDatawithRelatedRecords, { params: "$assetParams" })
  applAssetData(wiredAssetData) {
    const { data, error } = wiredAssetData;
    this._wiredAssetData = wiredAssetData;
    this.selectedValueList = [];
    this.assetJnRecords = [];
    if (data) {

      if (data.parentRecord != undefined) {
        this.wrapAddressObj = { ...data.parentRecord };

        if (this.wrapAddressObj.Is_it_an_APF__c === undefined) {
          this.wrapAddressObj.Is_it_an_APF__c = "No";
          this.exiAddrCopy = true
          this.isApfYesOrNo = true
        }
        if (this.wrapAddressObj.ChangeRequiredInValuationAsPerPolicyNorm__c === undefined) {
          this.wrapAddressObj.ChangeRequiredInValuationAsPerPolicyNorm__c = "NO";
          this.disbValToTakCal = true;
          console.log('print 1', this.wrapAddressObj.ChangeRequiredInValuationAsPerPolicyNorm__c);
          if (this.wrapAddressObj.ChangeRequiredInValuationAsPerPolicyNorm__c === "NO") {
            this.disbValToTakCal = true;
            console.log('print 2', this.wrapAddressObj.ChangeRequiredInValuationAsPerPolicyNorm__c);

            this.wrapAddressObj.ValuationToBeTakenAheadForCalculation__c = data.parentRecord.Valuation_as_per_policy_norms__c
            console.log('print 3', this.wrapAddressObj.ValuationToBeTakenAheadForCalculation__c);

          }
        }
        if (this.wrapAddressObj.ChangeRequiredInValuationAsPerPolicyNorm__c !== undefined) {
          console.log('print print 1', this.wrapAddressObj.ChangeRequiredInValuationAsPerPolicyNorm__c);

          if (this.wrapAddressObj.ChangeRequiredInValuationAsPerPolicyNorm__c === "NO") {
            this.ifChangReqInValua = false
            this.ifNoSelectedInChangReqInValua = true
            this.disbValToTakCal = true;
            if (data.parentRecord.Valuation_as_per_policy_norms__c) {
              this.wrapAddressObj.ValuationToBeTakenAheadForCalculation__c = data.parentRecord.Valuation_as_per_policy_norms__c
            }
          } else {
            this.ifChangReqInValua = true
            this.ifNoSelectedInChangReqInValua = false
          }
        }
        if (data.parentRecord.Prop_Bui_up_ar__c !== undefined && data.parentRecord.Appr_Cost_of_Const__c) {
          const apprCostOfConst = parseFloat(data.parentRecord.Appr_Cost_of_Const__c) || 0;
          const propBuilUpArea = parseFloat(data.parentRecord.Prop_Bui_up_ar__c) || 0;
//commented for LAK-8215
          //this.wrapAddressObj.Per_Sq_Ft_Approved_Cost_of_Construction__c = apprCostOfConst / propBuilUpArea;
        }
        if (data.parentRecord.Valuation_as_per_policy_norms__c !== undefined) {
          this.valAsPerPropNorms = data.parentRecord.Valuation_as_per_policy_norms__c
        }
        if (data.parentRecord.CopyAddFrmExAdd__c) {
          if (
            data.parentRecord.CopyAddFrmExAdd__c != null &&
            data.parentRecord.CopyAddFrmExAdd__c === "No"
          ) {
            this.addrTyVisi = false;
          } else {
            this.addrTyVisi = true;
            this.exiAddrCopy = true
            if (data.parentRecord.AddrTyp__c !== null) {
              this.appAddrParam.queryCriteria =
                " where Applicant__c = '" + this.applicantId + "'";
              getSobjectData({ params: this.appAddrParam }).then((data) => {
                if (data) {
                  let addrTypeList = [];
                  if (data.parentRecords) {
                    data.parentRecords.forEach((element) => {
                      addrTypeList.push({
                        label: element.AddrTyp__c,
                        value: element.AddrTyp__c
                      });
                    });
                    this.addrTyOption = [...addrTypeList];
                    if (this.wrapAddressObj.AddrType__c !== undefined) {

                      this.appAddrParam.queryCriteria =
                        " where Applicant__c = '" +
                        this.applicantId +
                        "' AND AddrTyp__c = '" +
                        this.wrapAddressObj.AddrType__c +
                        "'";

                      getSobjectDataNonCacheable({ params: this.appAddrParam }).then((data) => {
                        if (data) {
                          if (data.parentRecords) {
                            this.wrapAddressObj.FlatNo__c = data.parentRecords[0].HouseNo__c;
                            this.wrapAddressObj.AddrLn1__c = data.parentRecords[0].AddrLine1__c;
                            this.wrapAddressObj.AddrLn2__c = data.parentRecords[0].AddrLine2__c;
                            this.wrapAddressObj.Landmark__c = data.parentRecords[0].Landmark__c;
                            this.wrapAddressObj.AreaLocality__c =
                              data.parentRecords[0].Locality__c;
                            this.wrapAddressObj.CityId__c = data.parentRecords[0].CityId__c;

                            this.wrapAddressObj.StateId__c = data.parentRecords[0].StateId__c;
                            if(data.parentRecords[0].Pincode__c){
                              this.wrapAddressObj.Pin_Code__c = data.parentRecords[0].Pincode__c;
                            }
                            this.wrapAddressObj.State__c = data.parentRecords[0].State__c;
                            this.wrapAddressObj.City__c = data.parentRecords[0].City__c;
                            if (data.parentRecords[0].PinId__c) {
                            this.wrapAddressObj.PinId__c = data.parentRecords[0].PinId__c;
                            }
                          }
                        }
                      });

                    }
                  }
                } else if (error) {
                  console.error("Error", error);
                }
              });
              this.isDisabled = true;

            }
          }
        }

        if (data.parentRecord.StateId__c != null) {
          this.wrapAddressObj.StateId__c = data.parentRecord.StateId__c;
        }
        if (
          data.parentRecord.ServiceableCity__c !== null &&
          data.parentRecord.CityId__c !== null
        ) {
          if (data.parentRecord.ServiceableCity__c === true) {
            this.isServCity = "Yes";
          } else if (
            data.parentRecord.CityId__c === undefined &&
            data.parentRecord.ServiceableCity__c === false
          ) {
            this.isServCity = null;
          } else {
            this.isServCity = "No";
          }
        }
        if (data.parentRecord.PinId__c) {
          this.wrapAddressObj.PinId__c = data.parentRecord.PinId__c;
        }
        if (
          data.parentRecord.PropIdentified__c === "No" &&
          (this._prodTy === "Home Loan" || this._prodTy === "Small Ticket LAP" || this._prodTy === "Loan Against Property")
        ) {
          this.propIden = false;
          this.wrapAddressObj.PropCat__c = "";
        }
        if (
          data.parentRecord.PropIdentified__c === "Yes" &&
          (this._prodTy === "Small Ticket LAP" || this._prodTy === "Loan Against Property")
        ) {
          this.disPropIden = true;
        }
        if (this.stageOfLAN == "UnderWriting" && data.parentRecord.PropIdentified__c === "Yes") {
          this.reqApprAgeOfProp = true
        }

        if (this.loanApplStage !== undefined) {
          if (this.loanApplStage !== "DDE" && this.loanApplStage !== "QDE") {
            if (data.parentRecord.Property_Usage__c !== undefined) {
              if (data.parentRecord.Property_Usage__c === "PARTLY OCCUPIED AND PARTLY RENTED" || data.parentRecord.Property_Usage__c === "RENTED") {
                this.reqIsPropMultTent = true
                this.reqRentlBankCrdt = true
              }

            }
          }
        }

        if (this.loanApplStage !== undefined) {
          if (this.loanApplStage !== "DDE" && this.loanApplStage !== "QDE") {
            if (data.parentRecord.Is_the_property_Multi_Tenanted__c === "Yes") {
              // this.isMultiTentProp = true;
              this.reqNoOfTents = true;
            } else {
              // this.isMultiTentProp = false;
              this.reqNoOfTents = false;
            }
          }
        }

        if (data.parentRecord.APFWingNo__c) {
          this.aPFMasterParam.queryCriteria =
            " where BuildNm_BlokNo_WinNm__c = '" +
            data.parentRecord.APFWingNo__c +
            "'";

          getSobjectData({ params: this.aPFMasterParam }).then((data) => {
            if (data) {
              let apfWingN = [];
              this.wingNameOp = [];
              if (data.parentRecords) {
                let buildOrWingNm = data.parentRecords.forEach((element) => {
                  apfWingN.push({
                    label: element.BuildNm_BlokNo_WinNm__c,
                    value: element.BuildNm_BlokNo_WinNm__c
                  });
                });
                this.wingNameOp = [...apfWingN];
              }
            } else if (error) {
              console.error("Error", error);
            }
          });
        }
        if (data.parentRecord.APFWingNo__c) {
          this.aPFMasterParam.queryCriteria =
            " where BuildNm_BlokNo_WinNm__c = '" +
            data.parentRecord.APFWingNo__c +
            "'";
          getSobjectData({ params: this.aPFMasterParam }).then((data) => {
            if (data) {
              let houseNo = [];
              this.housePlotNoOp = [];
              if (data.parentRecords) {
                data.parentRecords.forEach((element) => {
                  houseNo.push({
                    label: element.Hou_Flat_Shop_PlotNo__c,
                    value: element.Hou_Flat_Shop_PlotNo__c
                  });
                });
                this.housePlotNoOp = [...houseNo];
              }
            } else if (error) {
              console.error("Error", error);
            }
          });
        }
        if (data.parentRecord.APF_Ref_No__c) {
          this.aPFMasterParam.queryCriteria =
            " where APF_Ref__c = '" +
            data.parentRecord.APF_Ref_No__c +
            "'";
          getSobjectData({ params: this.aPFMasterParam }).then((data) => {
            if (data) {
              if (data.parentRecords) {
                this.apfNoList = data.parentRecords.map(element => ({
                  label: element.BuildNm_BlokNo_WinNm__c,
                  value: element.BuildNm_BlokNo_WinNm__c
                }));

                this.wingNameOp = this.apfNoList.filter((item, index, self) =>
                  index === self.findIndex(t => t.value === item.value)
                );
              }

            } else if (error) {
              console.error("Error", error);
            }
          });
        }
        if (data.parentRecord.Improvement_construction_estimate_docum__c) {
          if (data.parentRecord.Improvement_construction_estimate_docum__c === "Yes") {
            this.estArchAgreeFieldVsibl = true
            this.reqTotConsEst = true
          }
        }

        if (data.parentRecord.PropType__c === undefined) {
          this.disbNatProp = true
        }
        if (data.parentRecord.PropType__c !== undefined && this.propertyTyOpt !== undefined && this.natureOfProOp !== undefined) {
          this.oldPropTy = data.parentRecord.PropType__c;
          if (this.hasEditAccess === false) {
            this.disbNatProp = true;
          } else {
            this.disbNatProp = false;
          }


          console.log('Inside if');
          // this.wrapAddressObj.PropType__c = oldPropTy
          if (this.oldPropTy !== undefined && this.oldPropTy !== null && this.oldPropTy !== '' && this.natureOfProOp !== undefined &&
            this.natureOfProOp?.controllerValues?.[this.oldPropTy] !== undefined) {
            let key = this.natureOfProOp.controllerValues[this.oldPropTy];
            if (key !== undefined) {
              this.natureOfPropOpti = this.natureOfProOp.values.filter((opt) =>
                opt.validFor.includes(key)
              );
            }
          }
        }


        if (data.parentRecord.Is_it_an_APF__c === "Yes") {
          this.isApfSelectNo = true;
          this.isApfYesOrNo = false;
          this.exiAddrCopy = false;
          if (this._prodTy === "Home Loan") {
            this.apfReq = true;
          } else {
            this.apfReq = false;
          }
        }
        if (data.parentRecord.Is_it_an_APF__c === "No") {
          this.isApfYesOrNo = true
          this.exiAddrCopy = true
        }
        if (this._prodTy !== undefined && this._subProdTy !== undefined && this.schemId == undefined) {
          if (
            this._prodTy === "Home Loan" ||
            (this._prodTy === "Small Ticket LAP" &&
              this._subProdTy === "Commercial Property Purchase") ||
            (this._prodTy === "Loan Against Property" &&
                this._subProdTy === "Commercial Property Purchase")
          ) {
            this.showValuationFields = true
          } else {
            this.showValuationFields = false
          }
        }
      }
      this.propOwner = [];
      if (data.ChildReords != undefined) {
        let propertyOwnersList = [];
        let tempSelectedPropertyOwners = [];
        let tempOldApplAssetJnRedcord = []
        let oldAsstJn = []
        this.propOwner = data.ChildReords;

        let applAssetJun = data.ChildReords;
        if (applAssetJun) {
          tempSelectedPropertyOwners = [];
          tempOldApplAssetJnRedcord = [];
          data.ChildReords.forEach((data1) => {
            oldAsstJn.push({
              value: data1.Id
            })
            propertyOwnersList.push({
              label: data1.Appl__c,
              value: data1.Appl__c
            });
            tempSelectedPropertyOwners.push(data1.Appl__c);
            tempOldApplAssetJnRedcord.push(data1.Appl__c)
          });
          this.selectedValueList = [...tempSelectedPropertyOwners];
          this.assetJnRecords = [...tempOldApplAssetJnRedcord]
          console.log('child obj appl asset junction', this.selectedValueList, this.assetJnRecords);
        }

      }
    } else if (error) {
      console.log(error);
    }

    let tempParams = this.caseParameters;
    tempParams.queryCriteria = ' where ApplAssetId__c = \'' + this._currentTabId + '\' AND recordtype.name =\'' + this.recType + '\' AND Status =\'' + this.statusOfCase + '\''
    this.caseParameters = { ...tempParams };
  }

  @track recType = 'Technical';
  @track statusOfCase = "Closed"
  @track isRendered = false;
  @track propertyId;

  renderedCallback() {

    if (this.isRendered === false) {

      let tempParams = this.assetPropType;
      tempParams.queryCriteria = " where LoanAppln__c = '" + this._loanAppId + "'";
      this.assetPropType = { ...tempParams };

      getAssetPropType({ params: this.assetPropType }).then((data) => {
        if (data && data.parentRecords) {
          this.propTypeList = [];
          const filteredRecords = data.parentRecords.filter(element => element.Id !== this._currentTabId);

          filteredRecords.forEach((element) => {
            if (element.PropType__c !== null && element.PropType__c !== undefined) {
              this.propertyId = element.Id;
              this.propTypeList.push(element.PropType__c);
            }
          });
        }
      });
      this.isRendered = true;
    }
    refreshApex(this._wiredAssetData);

  }

  @track queryData =
    "SELECT Id,AccountId,Account.Name, Land_Area_Sq_Ft__c, Property_Built_up_area_Sq_Ft__c, Land_Valuation_in_Rs__c,Built_up_area_Valuation_In_Rs__c,Total_Valuation_Land_Valuation_B__c,  Approx_Age_of_Property_in_Years__c, Residual_Age_in_Years__c,   Applicant__c, Loan_Application__c, Product_Type__c, ApplAssetId__c, DateTimeInitiation__c FROM Case WHERE Loan_Application__c =: loanAppId AND recordtype.name =: techRecordType AND ApplAssetId__c=: currentTabId";

  @track queryParam = [];

  @track userRole = [];
  connectedCallback() {
    if (this._wiredAssetData && this._wiredAssetData.data) {
      refreshApex(this._wiredAssetData);
    }

    console.log("loanAppId", this._loanAppId);
    console.log("currentTabId", this.currentTabId);
    console.log("applicant id get set ", this._applicantId);
    this.activeSection = ["A", "C"];
    if (this.hasEditAccess === false) {
      this.disableMode = true;
      this.disPropIden = true;
      this.isDisabled = true;
      this.disbNatProp = true;
      this.disbValToTakCal = true;
    } else {
      this.disableMode = false;
    }

    getSobjectData({ params: this.teamHier })
      .then((data) => {
        data.parentRecords.forEach((element) => {
          this.userRole = element.EmpRole__c;
        });
        if (
          this.userRole === "RM" ||
          this.userRole === "SM" ||
          this.userRole === "BBH"
        ) {
          this.isRequired = false;
          this.isPinReq = false;
          refreshApex(this._wiredPropOwnerData);

        } else {
          this.isRequired = true;
          this.isPinReq = true;
          refreshApex(this._wiredPropOwnerData);
        }
      })
      .catch((error) => {
        console.error("Error", error);
      });
    this.scribeToMessageChannel();

    let paramVal = [];
    paramVal.push({ key: "loanAppId", value: this._loanAppId });
    paramVal.push({ key: "techRecordType", value: "Technical" });
    paramVal.push({ key: "currentTabId", value: this._currentTabId });

    this.queryParam = paramVal;
    this.caseParams = {
      columnsData: this.columnsDataForTable,
      queryParams: this.queryParam,
      query: this.queryData
    };
  }

  showToastMessage(title, message, variant, mode) {
    const evt = new ShowToastEvent({
      title,
      message,
      variant,
      mode
    });
    this.dispatchEvent(evt);
  }

  reportValidity() {
    let isValid = true;
    if (!this.checkValidityLookup()) {
      isValid = false;
    }
    if (!this.checkValidityMultiPick()) {
      isValid = false;
    }
    if (this.currentTabId !== "new") {
      if (!this.checkValidityOfDocument()) {
        isValid = false;
      }
    }

    this.template.querySelectorAll("lightning-combobox").forEach((element) => {
      if (element.reportValidity()) {
      } else {
        isValid = false;
      }
    });

    this.template.querySelectorAll("lightning-input").forEach((element) => {
      if (element.reportValidity()) {
      } else {
        isValid = false;
      }
    });
    return isValid;
  }

  scribeToMessageChannel() {
    this.subscription = subscribe(
      this.MessageContext,
      SaveProcessCalled,
      (values) => this.handleSaveThroughLms(values)
    );
  }


  reloadTabset(event) {
    const selectEvent = new CustomEvent("refreshtab", {
      detail: event
    });
  }


  handleSaveThroughLms(values) {
    if (values.tabId && values.tabId === this._currentTabId) {
      this.handleSave(values.validateBeforeSave);
    }
  }
  @track propList = [];
  @track valueOfPropTy;
  handleSave(validate) {
    if (validate) {
      let isInputCorrect = this.reportValidity();
      if (isInputCorrect === true) {
        this.isRendered = false;
        if (this.isRendered === true) {
          this.isRendered = false;
        }
        if (this._currentTabId !== undefined) {
          const onChangeValue = this.wrapAddressObj.PropType__c;
          if ( this.propTypeList[0] !== undefined && this.propTypeList !== null && this.propTypeList.length >= 1) {
            console.log('property type list', this.propTypeList);
            const isValueInList = this.propTypeList.every((element) => {
              if (element === onChangeValue) {
                return true;
              } else if (element !== onChangeValue) {

                if (this.wrapAddressObj.PropIdentified__c === "Yes") {
                  const propTypeSet = new Set(this.propTypeList);
                  if (propTypeSet.size > 1) {

                    this.showToastMessage(
                      "Error",
                      this.label.PropertyDetails_PropType_ErrorMessage,
                      "error",
                      "sticky"
                    );
                  } else {
                    propTypeSet.forEach((value) => {
                      if (onChangeValue === value) {
                        return true;
                      } else {
                        return false;
                      }
                    });
                  }
                } else {
                  return true;
                }
              } else {
                this.showToastMessage(
                  "Error",
                  this.label.PropertyDetails_PropType_ErrorMessage,
                  "error",
                  "sticky"
                );
                return false;
              }
            });
         
         
            if (isValueInList === true) {
              this.handleUpsert();
              // this[NavigationMixin.Navigate]({
              //   type: 'standard__recordPage',
              //   attributes: {
              //     recordId: this._loanAppId,
              //     actionName: 'view'
              //   }
              // });
            } else {
              this.showToastMessage(
                "Error",
                this.label.PropertyDetails_PropType_ErrorMessage,
                "error",
                "sticky"
              );
            }
          } else if (
            this.propTypeList[0] !== undefined &&
            this.propTypeList !== null &&
            this.propTypeList.length == 1
          ) {
            const isValueInList = this.propTypeList.every((element) => {
              if (element === onChangeValue) {
                return true;
              } else if (
                element !== onChangeValue &&
                this.propertyId !== undefined &&
                this._currentTabId !== "new"
              ) {
                return true;
              } else {
                return false;
              }
            });
            if (isValueInList === true) {
              this.handleUpsert();

              this.reloadTabset(true);

              // this[NavigationMixin.Navigate]({
              //   type: 'standard__recordPage',
              //   attributes: {
              //     recordId: this._loanAppId,
              //     actionName: 'view'
              //   }
              // });
            } else {
              this.showToastMessage(
                "Error",
                this.label.PropertyDetails_PropType_ErrorMessage,
                "error",
                "sticky"
              );
            }
          } else {
            this.handleUpsert();
            this.reloadTabset(true);
            // this[NavigationMixin.Navigate]({
            //   type: 'standard__recordPage',
            //   attributes: {
            //     recordId: this._loanAppId,
            //     actionName: 'view'
            //   }
            // });
          }
        }
      } else {
        this.showToastMessage(
          "Error",
          this.label.PropertyDetails_ReqFields_ErrorMessage,
          "error",
          "sticky"
        );
      }
    } else {
      this.handleUpsert();
      this.showToastMessage(
        "Success",
        this.label.PropertyDetails_Save_SuccessMessage,
        "success",
        "sticky"
      );
      this.reloadTabset(true);
      // this[NavigationMixin.Navigate]({
      //   type: 'standard__recordPage',
      //   attributes: {
      //     recordId: this._loanAppId,
      //     actionName: 'view'
      //   }
      // });
    }
  }

  checkValidityLookup() {
    let isInputCorrect = true;
    let allChilds = this.template.querySelectorAll("c-custom-lookup");

    allChilds.forEach((child) => {
      if (!child.checkValidityLookup()) {
        child.checkValidityLookup();
        isInputCorrect = false;
      }
    });
    return isInputCorrect;
  }

  checkValidityMultiPick() {
    let isInputCorrect = true;
    let allChilds = this.template.querySelectorAll("c-multi-select-dropdown");

    allChilds.forEach((child) => {
      if (!child.checkValidityMultiPick()) {
        child.checkValidityMultiPick();
        isInputCorrect = false;
      }
    });
    return isInputCorrect;
  }

  checkValidityOfDocument() {
    let isInputCorrect = true;
    let allChilds = this.template.querySelectorAll("c-capture-documents");
    allChilds.forEach((child) => {
      if (!child.checkValidityOfDocument()) {
        child.checkValidityOfDocument();
        isInputCorrect = false;
      }
    });
    return isInputCorrect;
  }

  @track resultOfCompareArrays = [];
  propOnwerSaveHandler() {

    let arrayOfSelectedValues = [];
    let alloptOfOwner = [];
    arrayOfSelectedValues = this.propOwnerSelectList;
    alloptOfOwner = this.propList;

    this.resultOfCompareArrays = alloptOfOwner
      .filter((o) => arrayOfSelectedValues.find((x) => x === o.value))
      .map((o) => o.label);
    console.log('property owner save handler', this.resultOfCompareArrays);
  }

  @track resultOfCompArrayBetnOldNNew = []
  withoutUpdPropOwner() {
    let arrayOfSelectedValues = [];
    let alloptOfOwner = [];
    arrayOfSelectedValues = this.selectedValueList;
    alloptOfOwner = this.propList;

    this.resultOfCompArrayBetnOldNNew = alloptOfOwner
      .filter((o) => arrayOfSelectedValues.find((x) => x === o.value))
      .map((o) => o.label);
    console.log('without update property owner save handler', this.resultOfCompArrayBetnOldNNew);
  }

  @track newAssetRdId;
  @track wrapAppAssetJun = {};
  @track unmatchedIds = []
  @track isClick = false;
  handleUpsert() {

    if(this.isClick){
      return isClick;
     }

    this.isClick = true;
    
    this.showSpinner = true;
    let propertyOwnersList = [];
    const uniqueApplValues = [];
    this.unmatchedIds = []
    let arrayOfSelectedValues = [];
    let alloptOfOwner = [];
    arrayOfSelectedValues = this.propOwnerSelectList;
    alloptOfOwner = this.assetJnRecords;
    this.unmatchedIds = arrayOfSelectedValues.filter(id => !alloptOfOwner.includes(id));

    if (this.unmatchedIds.length > 0) {
      for (var i = 0; i < this.unmatchedIds.length; i++) {
        var propertyOwner = {};

        propertyOwner.sobjectType = "ApplAssetJn__c";
        if (this._currentTabId === "new") {
          delete this.wrapAddressObj.Id;
        } else {
          propertyOwner.ApplAsset__c = this._currentTabId;
        }
        propertyOwner.Appl__c = this.unmatchedIds[i];

        propertyOwnersList.push(propertyOwner);
      }
    }

    // if (this.handlePill !== undefined)
    if (this.resultOfCompareArrays.length == 0) {
      this.withoutUpdPropOwner();
      if (this.resultOfCompArrayBetnOldNNew.length > 0) {
        const joinedString = this.resultOfCompArrayBetnOldNNew.join(", ");
        this.ownerList = joinedString.replace(/,/g, "; ");
        console.log("without update print owner in semi colon", this.ownerList);
        console.log('empty property owner');
      } else {
        console.log('zero records of owner prop');
        this.ownerList = '';
      }
      // let ownerlist = this.propList.filter(
      //   (item) => item.label !== undefined
      // );
      // this.ownerList = ownerlist.map(item => item.label).join(';');
      // this.ownerList = '';
    }
    //   let comparePropeOwn = []
    //   let selectedOwners = []
    //   comparePropeOwn = this.selectedValueList
    //   .filter((o) => selectedOwners.find((x) => x === o.value))
    //   .map((o) => o.label);
    // console.log('property owner comapre', comparePropeOwn);

    //   console.log('owner seleced',this.selectedValueList);
    // if(this.resultOfCompArrayBetnOldNNew.length == 0){
    //   console.log('zero records of owner prop');
    // }
    if (this.resultOfCompareArrays.length > 0) {
      const joinedString = this.resultOfCompareArrays.join(", ");
      this.ownerList = joinedString.replace(/,/g, "; ");
      console.log("print owner in semi colon", this.ownerList);

    }

    if (this.isServCity === "Yes") {
      this.wrapAddressObj.ServiceableCity__c = true;
    } else {
      this.wrapAddressObj.ServiceableCity__c = false;
    }

    this.wrapAddressObj.Prop_Owners__c = this.ownerList;
    this.wrapAddressObj.sobjectType = "ApplAsset__c";
    this.wrapAddressObj.Appl__c = this.applicantId;
    this.wrapAddressObj.LoanAppln__c = this._loanAppId;

    if (this.currentTabId !== "new") {
      this.wrapAddressObj.Id = this.currentTabId;
    } else {
      delete this.wrapAddressObj.Id;
    }

    let upsertData = {
      parentRecord: this.wrapAddressObj,
      ChildRecords: propertyOwnersList,
      ParentFieldNameToUpdate: "ApplAsset__c"
    };

    console.log('upsert data asset', upsertData);
    upsertSobjDataWIthRelatedChilds({ upsertData: upsertData })
      .then((result) => {
        this.showToastMessage(
          "Success",
          this.label.PropertyDetails_Save_SuccessMessage,
          "success",
          "sticky"
        );
        if (result.parentRecord.Id) {
          this.newAssetRdId = result.parentRecord.Id;

          this.publishMC(this.newAssetRdId);
        }
        refreshApex(this._wiredAssetData);
        this.showSpinner = false;
        this.isClick = false;

      })
      .catch((error) => {
        this.showSpinner = false;
        this.isClick = false;
        console.error(error);
      });
  }

  generatePicklist(data) {
    return data.values.map((item) => ({
      label: item.label,
      value: item.value
    }));
  }

  @wire(getObjectInfo, { objectApiName: APPLICANT_ASSET_OBJECT })
  objInfo;

  @wire(getPicklistValues, {
    recordTypeId: "$objInfo.data.defaultRecordTypeId",
    fieldApiName: PROPERTY_IDENTI_FIELD
  })
  propertyIndentiPicklistHandler({ data, error }) {
    if (data) {
      this.propIdetifiedPikVal = [...this.generatePicklist(data)];
    }
    if (error) {
      console.log("error ", error);
    }
  }

  @wire(getObjectInfo, { objectApiName: APPLICANT_ASSET_OBJECT })
  objInfo;

  @wire(getPicklistValues, {
    recordTypeId: "$objInfo.data.defaultRecordTypeId",
    fieldApiName: COPY_ADD__FROM_EXI_ADD_FIELD
  })
  copyExistingAdrPicklistHandler({ data, error }) {
    if (data) {
      this.existingAddrOpt = [...this.generatePicklist(data)];
    }
    if (error) {
      console.log("error ", error);
    }
  }

  @wire(getObjectInfo, { objectApiName: APPLICANT_ASSET_OBJECT })
  objInfo;

  @wire(getPicklistValues, {
    recordTypeId: "$objInfo.data.defaultRecordTypeId",
    fieldApiName: PROPERTY_TYPE_FIELD
  })
  propertTypePicklistHandler({ data, error }) {
    if (data) {
      this.propertyTyOpt = [...this.generatePicklist(data)];
    }
    if (error) {
      console.log("error ", error);
    }
  }

  @wire(getObjectInfo, { objectApiName: APPLICANT_ASSET_OBJECT })
  objInfo;

  @wire(getPicklistValues, {
    recordTypeId: "$objInfo.data.defaultRecordTypeId",
    fieldApiName: NATURE_OF_PRO_FIELD
  })
  natureOfPropPicklistHandler({ data, error }) {
    if (data) {
      this.natureOfProOp = data;
      this.natureOfPropOpti = [...this.generatePicklist(data)];

      if (this.oldPropTy !== undefined && this.natureOfProOp !== undefined) {
        let key = this.natureOfProOp.controllerValues[this.oldPropTy];
        this.natureOfPropOpti = this.natureOfProOp.values.filter((opt) =>
          opt.validFor.includes(key)
        );
      }
    }
    if (error) {
      console.log("error ", error);
    }
  }

  @wire(getObjectInfo, { objectApiName: APPLICANT_ASSET_OBJECT })
  objInfo;

  @wire(getPicklistValues, {
    recordTypeId: "$objInfo.data.defaultRecordTypeId",
    fieldApiName: PROPERTY_CATE_FIELD
  })
  propertyCatePicklistHandler({ data, error }) {
    if (data) {
      this.prpertyCateOpt = [...this.generatePicklist(data)];
    }
    if (error) {
      console.log("error ", error);
    }
  }

  @wire(getPicklistValuesByRecordType, {
    objectApiName: APPLICANT_ASSET_OBJECT,
    recordTypeId: "$objInfo.data.defaultRecordTypeId"
  })
  picklistHandler({ data, error }) {
    if (data) {
      this.cautionAreaOptions = [
        ...this.generatePicklist(
          data.picklistFieldValues.Negative_Caution_Area__c
        )
      ];
      this.imprmntEstConstrDocOptions = [
        ...this.generatePicklist(
          data.picklistFieldValues.Improvement_construction_estimate_docum__c
        )
      ];
      this.multiTenatPropOptions = [
        ...this.generatePicklist(
          data.picklistFieldValues.Is_the_property_Multi_Tenanted__c
        )
      ];
      this.chngeValPolcyNormOptions = [
        ...this.generatePicklist(
          data.picklistFieldValues.ChangeRequiredInValuationAsPerPolicyNorm__c
        )
      ];
      this.bndryOfPropMatchOptions = [
        ...this.generatePicklist(
          data.picklistFieldValues.IdentiAndBoundaryOfProprtyMatchWithPaper__c
        )
      ];
      this.boundOfPropDemOptions = [
        ...this.generatePicklist(
          data.picklistFieldValues.Bound_are_prop_dem_n_ide__c
        )
      ];
      this.bundryOfAddrVerOptions = [
        ...this.generatePicklist(
          data.picklistFieldValues.Addr_of_prop_veri_as_per_Tit__c
        )
      ];
      this.isTitleClrOptions = [
        ...this.generatePicklist(
          data.picklistFieldValues.Is_the_title_clear_markateble__c
        )
      ];
      this.propUsgOption = [
        ...this.generatePicklist(
          data.picklistFieldValues.Property_Usage__c
        )
      ]
    }
    if (error) {
      console.log("Error in picklist handler ", error);
    }
  }

  publishMC(recordId) {
    const messageChannelMessage = {
      recordId: recordId,
      message: "New Property Created"
    };
    publish(this.context, RECORDCREATE, messageChannelMessage);
  }
  unsubscribeMC() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }

  disconnectedCallback() {
    this.unsubscribeMC();
    releaseMessageContext(this.context);
  }

  @track docId
  handleValidDocument(event) {

    if (event.detail) {
      this.docId = event.detail
    }
  }

  @track filterConditionCity;
  @track citName;
  @track pincode;
  @track apfID;

  handleValueSelect(event) {
    this.lookupRec = event.detail;
    console.log('Handle Value Select :',JSON.stringify(event.detail));
    if (event.target.label === "City") {
      this.wrapAddressObj.City__c = this.lookupRec.mainField;
      this.wrapAddressObj.CityId__c = this.lookupRec.id;

      this.cityParams.queryCriteria =
        " where City__c = '" + this.wrapAddressObj.City__c + "'";
      getSobjectData({ params: this.cityParams })
        .then((result) => {
          this.wrapAddressObj.StateId__c = result.parentRecords[0].Id;

          this.wrapAddressObj.State__c = result.parentRecords[0].State__c;
        })
        .catch((error) => {
          this.showToastMessage(
            "Error",
            this.label.PropertyDetails_Branch_ErrorMessage,
            "error",
            "sticky"
          );
          console.error("Error", error);
        });
      this.cityId = event.detail.id;
      if (this.cityId === null) {
        this.isServCity = "";
      }
      this.serveaCity();

      this.citName = this.lookupRec.mainField;
    }
    if (event.target.label === "State/UT") {
      this.wrapAddressObj.State__c = this.lookupRec.mainField;
      this.wrapAddressObj.StateId__c = this.lookupRec.id;
    }
    if (event.target.label === "Pincode") {

      this.wrapAddressObj.Pin_Code__c = this.lookupRec.mainField;
      this.wrapAddressObj.PinId__c = this.lookupRec.id;
      this.pincode = this.lookupRec.mainField;
      console.log('Handle Value Select in Pin Id :',this.lookupRec.id);

      if (this.lookupRec.mainField === null || this.lookupRec.id === null) {

        this.wrapAddressObj.CityId__c = "";
        this.wrapAddressObj.StateId__c = "";
        this.isServCity = "";
      }

      this.pincodeParams.queryCriteria =
        " where PIN__c = '" + this.wrapAddressObj.Pin_Code__c + "'";
      getSobjectData({ params: this.pincodeParams })
        .then((result) => {
          this.cityNm = result.parentRecords[0].City__r.City__c;
          this.wrapAddressObj.CityId__c = result.parentRecords[0].City__r.Id;
          this.wrapAddressObj.City__c = result.parentRecords[0].City__r.City__c;
          this.cityId = result.parentRecords[0].City__r.Id;
          this.serveaCity();
          this.searchCityNstate();
        })
        .catch((error) => {
          console.error("Error in line ##189", error);
        });

      this.pinId = event.detail.id;
    }
    if (event.target.label === "Property Sub Type") {
      this.wrapAddressObj.PropSubType__c = this.lookupRec.mainField;
      this.wrapAddressObj.Prop_Sub_TyId__c = this.lookupRec.id;

      this.propMastParam.queryCriteria =
        " where Desc__c = '" + this.wrapAddressObj.PropSubType__c + "'";

      getSobjectData({ params: this.propMastParam }).then((data) => {
        if (data) {
          if (data.parentRecords) {
            this.wrapAddressObj.PropSubTypeDesc__c =
              data.parentRecords[0].Value__c;
          }
        } else if (error) {
          console.log("error +", error);
        }
      });
    }
    if (event.target.label === "APF Ref No") {
      try {
        this.wrapAddressObj.APF_Ref_No__c = this.lookupRec.mainField;
        this.wrapAddressObj.APFRefId__c = this.lookupRec.id;
      } catch (error) {
        console.log("error on apf ref no change ", error);
      }

      if (this.wrapAddressObj.APFRefId__c) {
        this.aPFMasterParam.queryCriteria =
          " where APF_Ref__c = '" + this.wrapAddressObj.APF_Ref_No__c + "'";

        getSobjectData({ params: this.aPFMasterParam })
          .then((result) => {
            this.wrapAddressObj.Builder_ID__c =
              result.parentRecords[0].Build_Id__c;
            this.wrapAddressObj.Builder_nm__c =
              result.parentRecords[0].Build_Na__c;
            this.wrapAddressObj.ProjID__c = result.parentRecords[0].Proj_Id__c;
            this.wrapAddressObj.Proj_Nm__c = result.parentRecords[0].Proj_Na__c;
            this.wrapAddressObj.APFAddrLn1__c =
              result.parentRecords[0].Addr_Ln1__c;
            this.wrapAddressObj.APFAddrLn2__c =
              result.parentRecords[0].Addr_Ln2__c;
            this.wrapAddressObj.APFLandmk__c =
              result.parentRecords[0].Landmark__c;
            this.wrapAddressObj.APFAreaOrLoc__c =
              result.parentRecords[0].Area_or_Loca__c;
            this.wrapAddressObj.APFCity__c = result.parentRecords[0].City__c;
            this.wrapAddressObj.APFPinCode__c =
              result.parentRecords[0].Pin_Code__c;
            this.wrapAddressObj.APFState__c = result.parentRecords[0].State__c;
            //address pop. in applAsset obj
            this.wrapAddressObj.AddrLn1__c = result.parentRecords[0].Addr_Ln1__c;
            this.wrapAddressObj.AddrLn2__c = result.parentRecords[0].Addr_Ln2__c;
            this.wrapAddressObj.Landmark__c = result.parentRecords[0].Landmark__c;
            this.wrapAddressObj.AreaLocality__c = result.parentRecords[0].Area_or_Loca__c;
            this.wrapAddressObj.City__c = result.parentRecords[0].City__c;
            this.wrapAddressObj.Pin_Code__c = result.parentRecords[0].Pin_Code__c;
            this.isDisabled = true
            this.handleCity();
            this.handlePincode();

            this.apfNoList = [];

            if (result.parentRecords) {
              this.apfNoList = result.parentRecords.map(element => ({
                label: element.BuildNm_BlokNo_WinNm__c,
                value: element.BuildNm_BlokNo_WinNm__c
              }));

              this.wingNameOp = this.apfNoList.filter((item, index, self) =>
                index === self.findIndex(t => t.value === item.value)
              );
            }

          })
          .catch((error) => {
            console.error("Error", error);
          });
      } else {
        this.wrapAddressObj.Builder_ID__c = "";
        this.wrapAddressObj.Builder_nm__c = "";
        this.wrapAddressObj.ProjID__c = "";
        this.wrapAddressObj.Proj_Nm__c = "";
        this.wrapAddressObj.APFAddrLn1__c = "";
        this.wrapAddressObj.APFAddrLn2__c = "";
        this.wrapAddressObj.APFLandmk__c = "";
        this.wrapAddressObj.APFAreaOrLoc__c = "";
        this.wrapAddressObj.APFCity__c = "";
        this.wrapAddressObj.APFPinCode__c = "";
        this.wrapAddressObj.APFState__c = "";
        this.wrapAddressObj.APFHouse_Flat_PlotNo__c = "";
        this.wrapAddressObj.APFWingNo__c = "";
        this.housePlotNoOp = [];
        this.wingNameOp = [];
        //applicant asset address fields
        this.wrapAddressObj.FlatNo__c = ""
        this.wrapAddressObj.AddrLn1__c = ""
        this.wrapAddressObj.AddrLn2__c = ""
        this.wrapAddressObj.Landmark__c = ""
        this.wrapAddressObj.AreaLocality__c = ""
        this.wrapAddressObj.CityId__c = ""
        this.wrapAddressObj.City__c = ""
        this.wrapAddressObj.Pin_Code__c = ""
        this.wrapAddressObj.PinId__c = ""
        this.wrapAddressObj.StateId__c = ""
        this.wrapAddressObj.State__c = ""
        this.wrapAddressObj.City__c = ""
        this.wrapAddressObj.FlatNo__c = ""
        this.isServCity = ""
        this.isDisabled = false
      }
    }

    this.dispatchEvent(
      new CustomEvent("handle", {
        detail: this.wrapAddressObj
      })
    );
  }

  handleFocus() {
  }

  handleCity() {
    this.cityParams.queryCriteria = " where City__c = '" + this.wrapAddressObj.APFCity__c + "'";
    getSobjectData({ params: this.cityParams })
      .then((result) => {
        this.wrapAddressObj.StateId__c = result.parentRecords[0].Id;
        this.wrapAddressObj.State__c = result.parentRecords[0].State__c;

      })
      .catch((error) => {
        this.showToastMessage("Error", this.label.PropertyDetails_Branch_ErrorMessage, "error", "sticky");
        console.error("Error", error);
      });
  }

  handlePincode() {
    this.pincodeParams.queryCriteria = " where City__r.City__c = '" + this.wrapAddressObj.APFCity__c + "'";
    getSobjectData({ params: this.pincodeParams })
      .then((result) => {
        this.wrapAddressObj.CityId__c = result.parentRecords[0].City__r.Id;
        this.wrapAddressObj.City__c = result.parentRecords[0].City__r.City__c;
        this.wrapAddressObj.PinId__c = result.parentRecords[0].Id
        this.cityId = result.parentRecords[0].City__r.Id;
        this.serveaCity();
      })
      .catch((error) => {
        console.error("Error in line ##189", error);
      });
  }

  searchCityNstate() {
    this.cityParams.queryCriteria = " where City__c = '" + this.cityNm + "'";
    getSobjectData({ params: this.cityParams })
      .then((result) => {
        this.wrapAddressObj.StateId__c = result.parentRecords[0].Id;
        this.wrapAddressObj.State__c = result.parentRecords[0].State__c;

      })
      .catch((error) => {
        console.error("Error ", error);
      });
  }

  serveaCity() {
    if (this.cityId && this._prodTy) {

      this.locBranMastParams.queryCriteria = ' where Location__c = \'' + this.cityId + '\'' + ' AND ProductType__c INCLUDES (\'' + this._prodTy + '\') LIMIT 1';

      getSobjectData({ params: this.locBranMastParams })
        .then((data) => {
          if (data.parentRecords !== undefined) {
            let servCity = data.parentRecords[0].IsActive__c;
            if (servCity === true) {
              this.isServCity = "Yes";
            } else {
              this.isServCity = "No";
            }
          } else {
            this.isServCity = "No";
          }
        })
        .catch((error) => {
          this.showToastMessage(
            "Error",
            this.label.PropertyDetails_Branch_ErrorMessage,
            "error",
            "sticky"
          );
          console.error("Error", error);
        });
    } else {
      console.error(
        "One or more of the required parameters (cityId, _prodTy) are undefined."
      );
    }
  }

  @track searchAPFNo;
  @track apfRefList = "";

  handleInputChange(event) {
    try {
      if (event.target.dataset.type === 'string') {
        let strVal = event.target.value;
        this.wrapAddressObj[event.target.dataset.name] = strVal.toUpperCase();

      } else {
        this.wrapAddressObj[event.target.dataset.name] = event.target.value;
      }
      this.calculateTotalPropCost();
    } catch (e) {
      console.log(e);
    }

    //DDE stage field addition
    if (event.target.dataset.name === "Property_Usage__c") {
      this.wrapAddressObj.Property_Usage__c = event.target.value;
      if (this.loanApplStage !== undefined) {
        if (this.loanApplStage !== "DDE" && this.loanApplStage !== "QDE") {

          if (this.wrapAddressObj.Property_Usage__c === "RENTED" || this.wrapAddressObj.Property_Usage__c === "PARTLY OCCUPIED AND PARTLY RENTED") {
            this.reqIsPropMultTent = true
            this.reqRentlBankCrdt = true
            // this.isMultiTentFieldVsbl = true;
          } else {
            // this.isMultiTentFieldVsbl = false;
            this.reqIsPropMultTent = false
            this.reqRentlBankCrdt = false
          }
        }
      }
    }

    if (event.target.dataset.name === "CopyAddFrmExAdd__c") {
      this.wrapAddressObj.CopyAddFrmExAdd__c = event.target.value;
      if (this.wrapAddressObj.CopyAddFrmExAdd__c === "Yes") {
        this.wrapAddressObj.FlatNo__c = "";
        this.wrapAddressObj.AddrLn1__c = "";
        this.wrapAddressObj.AddrLn2__c = "";
        this.wrapAddressObj.Landmark__c = "";
        this.wrapAddressObj.AreaLocality__c = "";
        this.wrapAddressObj.CityId__c = "";
        this.wrapAddressObj.PinId__c = "";
        this.wrapAddressObj.StateId__c = "";
        this.isServCity = "";
        this.addrTyVisi = true;
        this.exiAddrCopy = true
        this.appAddrParam.queryCriteria =
          " where Applicant__c = '" + this.applicantId + "'";
        getSobjectData({ params: this.appAddrParam }).then((data) => {
          if (data) {
            let addrTypeList = [];
            if (data.parentRecords) {
              data.parentRecords.forEach((element) => {
                addrTypeList.push({
                  label: element.AddrTyp__c,
                  value: element.AddrTyp__c
                });
              });

              this.addrTyOption = [...addrTypeList];
            }
          } else if (error) {
            console.error("Error", error);
          }
        });
      } else if (this.wrapAddressObj.CopyAddFrmExAdd__c === "No") {
        this.addrTyVisi = false;
        this.isDisabled = false;
        this.wrapAddressObj.AddrType__c = "";
        this.wrapAddressObj.FlatNo__c = "";
        this.wrapAddressObj.AddrLn1__c = "";
        this.wrapAddressObj.AddrLn2__c = "";
        this.wrapAddressObj.Landmark__c = "";
        this.wrapAddressObj.AreaLocality__c = "";
        this.wrapAddressObj.CityId__c = "";
        this.wrapAddressObj.PinId__c = "";
        this.wrapAddressObj.StateId__c = "";
        this.wrapAddressObj.Pin_Code__c = "";
        this.wrapAddressObj.State__c = "";
        this.wrapAddressObj.City__c = "";
        this.isServCity = "";
      }
    } else if (event.target.dataset.name === "AddrType__c") {
      this.wrapAddressObj.AddrType__c = event.target.value;
      this.wrapAddressObj.PinId__c = "";
      this.wrapAddressObj.Pin_Code__c = "";
      this.wrapAddressObj.StateId__c = "";
      this.appAddrParam.queryCriteria =
        " where Applicant__c = '" +
        this.applicantId +
        "' AND AddrTyp__c = '" +
        this.wrapAddressObj.AddrType__c +
        "'";

      getSobjectData({ params: this.appAddrParam }).then((data) => {
        if (data) {
          if (data.parentRecords) {
            this.wrapAddressObj.FlatNo__c = data.parentRecords[0].HouseNo__c;
            this.wrapAddressObj.AddrLn1__c = data.parentRecords[0].AddrLine1__c;
            this.wrapAddressObj.AddrLn2__c = data.parentRecords[0].AddrLine2__c;
            this.wrapAddressObj.Landmark__c = data.parentRecords[0].Landmark__c;
            this.wrapAddressObj.AreaLocality__c =
              data.parentRecords[0].Locality__c;
            this.wrapAddressObj.CityId__c = data.parentRecords[0].CityId__c;

            this.wrapAddressObj.StateId__c = data.parentRecords[0].StateId__c;
            this.wrapAddressObj.Pin_Code__c = data.parentRecords[0].Pincode__c;
            this.wrapAddressObj.State__c = data.parentRecords[0].State__c;
            this.wrapAddressObj.City__c = data.parentRecords[0].City__c;
            this.wrapAddressObj.PinId__c = data.parentRecords[0].PinId__c;

            
            console.log('this.wrapAddressObj.City__c:',this.wrapAddressObj.City__c);

            if (this.wrapAddressObj.City__c != null) {
               this.cityParams.queryCriteria =
                " where City__c = '" + this.wrapAddressObj.City__c + "'";
                getSobjectData({ params: this.cityParams })
                .then((result) => {
                  this.wrapAddressObj.StateId__c = result.parentRecords[0].Id;
                })
                .catch((error) => {
                  console.error("Error", error);
                });
            }

             console.log('Pincode:',data.parentRecords[0].Pincode__c);
            if (data.parentRecords[0].Pincode__c ) {
                console.log('Pincode 1:',data.parentRecords[0].Pincode__c);
              
              this.pincodeParams.queryCriteria = " where PIN__c = '" + data.parentRecords[0].Pincode__c + "'";
              getSobjectData({ params: this.pincodeParams })
                .then((result) => {
                  this.wrapAddressObj.CityId__c = result.parentRecords[0].City__r.Id;
                  this.cityId = result.parentRecords[0].City__r.Id;
                  this.serveaCity();
                  this.wrapAddressObj.City__c = result.parentRecords[0].City__r.City__c;
                  this.wrapAddressObj.PinId__c = result.parentRecords[0].Id;
                  console.log('PinId:',this.wrapAddressObj.PinId__c);
                })
                .catch((error) => {
                  console.error("Error ", error);
                });
            }
          }
        } else if (error) {
          console.error("Error", error);
        }
      });
      this.isDisabled = true;
    } else if (event.target.dataset.name === "PropType__c") {
      this.wrapAddressObj.PropType__c = event.target.value;
      this.wrapAddressObj.NatureofProp__c = '';
      this.disbNatProp = false
      let key = this.natureOfProOp.controllerValues[event.target.value];
      this.natureOfPropOpti = this.natureOfProOp.values.filter((opt) =>
        opt.validFor.includes(key)
      );
      this.isRendered = false;
      if (this.isRendered === true) {
        this.isRendered = false;
      }
    } else if (event.target.dataset.name === "PropIdentified__c") {
      this.wrapAddressObj.PropIdentified__c = event.target.value;

      const propIdenti = new CustomEvent('propidentidropdchange', {
        detail: { value: this.wrapAddressObj.PropIdentified__c }
      });
      this.dispatchEvent(propIdenti);

      if (this.wrapAddressObj.PropIdentified__c == "Yes") {
        this.propIden = true;
      } else {
        this.propIden = false;
        this.wrapAddressObj.PropType__c = "";
        this.wrapAddressObj.Is_it_an_APF__c = "";
        this.wrapAddressObj.APF_Ref_No__c = "";
        this.wrapAddressObj.APFRefId__c = "";
        this.wrapAddressObj.Builder_ID__c = "";
        this.wrapAddressObj.Builder_nm__c = "";
        this.wrapAddressObj.ProjID__c = "";
        this.wrapAddressObj.Proj_Nm__c = "";
        this.wrapAddressObj.APFWingNo__c = "";
        this.wrapAddressObj.APFAddrLn1__c = "";
        this.wrapAddressObj.APFAddrLn2__c = "";
        this.wrapAddressObj.APFLandmk__c = "";
        this.wrapAddressObj.APFAreaOrLoc__c = "";
        this.wrapAddressObj.APFCity__c = "";
        this.wrapAddressObj.APFPinCode__c = "";
        this.wrapAddressObj.APFState__c = "";
        this.wrapAddressObj.APFHouse_Flat_PlotNo__c = "";
        this.wrapAddressObj.Rera__c = "";
        this.wrapAddressObj.CopyAddFrmExAdd__c = "";
        this.wrapAddressObj.AddrType__c = "";
        this.wrapAddressObj.FlatNo__c = "";
        this.wrapAddressObj.AddrLn1__c = "";
        this.wrapAddressObj.AddrLn2__c = "";
        this.wrapAddressObj.Landmark__c = "";
        this.wrapAddressObj.AreaLocality__c = "";
        this.wrapAddressObj.CityId__c = "";
        this.wrapAddressObj.City__c = "";
        this.wrapAddressObj.PinId__c = "";
        this.wrapAddressObj.Pin_Code__c = "";
        this.wrapAddressObj.State__c = "";
        this.wrapAddressObj.StateId__c = "";
        this.wrapAddressObj.ServiceableCity__c = "";
        this.wrapAddressObj.Negative_Caution_Area__c = "";
        this.wrapAddressObj.DistFrmSourceBrch__c = "";
        this.wrapAddressObj.DistFrmNearBrch__c = "";
        this.wrapAddressObj.Prop_Owners__c = "";
        this.wrapAddressObj.Prop_Sub_TyId__c = "";
        this.wrapAddressObj.PropSubType__c = "";
        this.wrapAddressObj.PropCat__c = "";
        this.wrapAddressObj.NatureofProp__c = "";
        this.wrapAddressObj.Comments_on_Collateral__c = "";
        this.wrapAddressObj.Agrem_Value__c = "";
        this.wrapAddressObj.Improvement_construction_estimate_docum__c = "";
        this.wrapAddressObj.Appr_Cost_of_Const__c = "";
        this.wrapAddressObj.Regi_Cost__c = "";
        this.wrapAddressObj.Stamp_Duty__c = "";
        this.wrapAddressObj.Amenities__c = "";
        this.wrapAddressObj.Total_Prop_Cost__c = "";
        this.wrapAddressObj.Down_payment_PartORegisteredAgreement__c = "";
        this.wrapAddressObj.Balance_OCR_to_be_arranged_by_customer__c = "";
        this.wrapAddressObj.Is_the_title_clear_markateble__c = "";
        this.wrapAddressObj.Bound_are_prop_dem_n_ide__c = "";
        this.wrapAddressObj.Addr_of_prop_veri_as_per_Tit__c = "";
        this.wrapAddressObj.Property_Usage__c = "";
        this.wrapAddressObj.Is_the_property_Multi_Tenanted__c = "";
        this.wrapAddressObj.No_of_Tenants__c = "";
        this.wrapAddressObj.AveNetMnthlyRentalAsPerBankCredit__c = "";
        this.wrapAddressObj.Stage_of_Construction__c = "";
        this.wrapAddressObj.Approx_Age_of_Prop__c = "";
        this.wrapAddressObj.Resi_Age__c = "";
        this.wrapAddressObj.Property_Carpet_area_Sq_Ft__c = "";
        this.wrapAddressObj.Prop_Bui_up_ar__c = "";
        this.wrapAddressObj.Land_Area__c = "";
        this.wrapAddressObj.PerSqFtRateLandArea__c = "";
        this.wrapAddressObj.PerSqFtRateBuiltUpArea__c = "";
        this.wrapAddressObj.Valuation_as_per_policy_norms__c = "";
        this.wrapAddressObj.ChangeRequiredInValuationAsPerPolicyNorm__c = "";
        this.wrapAddressObj.ValuationToBeTakenAheadForCalculation__c = "";
        this.wrapAddressObj.Total_Valua__c = "";
        this.wrapAddressObj.Land_Valu__c = "";
        this.wrapAddressObj.Built_up_area_Valu__c = "";

      }
    } else if (event.target.dataset.name === "Appl__c") {
      this.wrapAppAssetJun.Appl__c = event.target.value;
    } else if (event.target.dataset.name === "Is_it_an_APF__c") {
      this.wrapAddressObj.Is_it_an_APF__c = event.target.value;
      if (this.wrapAddressObj.Is_it_an_APF__c === "Yes") {
        this.wrapAddressObj.CopyAddFrmExAdd__c = ""
        this.wrapAddressObj.AddrType__c = ""
        this.exiAddrCopy = false
        this.isApfSelectNo = true;
        this.isApfYesOrNo = false
        if (this.loanApplStage !== "QDE") {
          this.isReqLandm = false
        }
        if (
          this._prodTy === "Home Loan" ||
          (this._prodTy === "Small Ticket LAP" &&
            this._subProdTy === "Commercial Property Purchase") ||
          (this._prodTy === "Loan Against Property" &&
            this._subProdTy === "Commercial Property Purchase")
        ) {
          this.apfReq = true;
        } else {
          this.apfReq = false;
        }
      } else {
        this.wrapAddressObj.APFRefId__c = "";
        this.wrapAddressObj.Builder_ID__c = "";
        this.wrapAddressObj.Builder_nm__c = "";
        this.wrapAddressObj.ProjID__c = "";
        this.wrapAddressObj.Proj_Nm__c = "";
        this.wrapAddressObj.APFWingNo__c = "";
        this.wrapAddressObj.APFAddrLn1__c = "";
        this.wrapAddressObj.APFAddrLn2__c = "";
        this.wrapAddressObj.APFLandmk__c = "";
        this.wrapAddressObj.APFAreaOrLoc__c = "";
        this.wrapAddressObj.APFCity__c = "";
        this.wrapAddressObj.APFPinCode__c = "";
        this.wrapAddressObj.APFState__c = "";
        this.wrapAddressObj.APFHouse_Flat_PlotNo__c = "";
        // this.disabled = true;
        this.apfReq = false;
        this.isApfSelectNo = false;
        this.exiAddrCopy = true
        this.isApfYesOrNo = true
        if (this.loanApplStage !== "QDE") {
          this.isReqLandm = true
        }
      }
    } else if (event.target.dataset.name === "APFWingNo__c") {
      this.wrapAddressObj.APFWingNo__c = event.target.value;
      if (this.wrapAddressObj.APFWingNo__c) {
        this.aPFMasterParam.queryCriteria =
          " where BuildNm_BlokNo_WinNm__c = '" +
          this.wrapAddressObj.APFWingNo__c +
          "'";

        getSobjectData({ params: this.aPFMasterParam }).then((result) => {
          if (result.parentRecords) {
            let houseNoList = [];
            result.parentRecords.forEach((element) => {
              houseNoList.push({
                label: element.Hou_Flat_Shop_PlotNo__c,
                value: element.Hou_Flat_Shop_PlotNo__c
              });
            });
            this.housePlotNoOp = [...houseNoList];
          }
        });
      } else {
        this.wrapAddressObj.Hou_Flat_Shop_PlotNo__c = [];
      }
    } else if (event.target.dataset.name === "ChangeRequiredInValuationAsPerPolicyNorm__c") {
      this.wrapAddressObj.ChangeRequiredInValuationAsPerPolicyNorm__c = event.target.value;
      if (this.wrapAddressObj.ChangeRequiredInValuationAsPerPolicyNorm__c === "YES") {
        this.disbValToTakCal = this.hasEditAccess == false ? true : false;
        this.ifChangReqInValua = true
        this.ifNoSelectedInChangReqInValua = false
      } else {
        this.wrapAddressObj.ValuationToBeTakenAheadForCalculation__c = this.valAsPerPropNorms;
        this.disbValToTakCal = true
        this.ifChangReqInValua = false
        this.ifNoSelectedInChangReqInValua = true
      }
    } else if (event.target.dataset.name === "APFHouse_Flat_PlotNo__c") {
      this.wrapAddressObj.APFHouse_Flat_PlotNo__c = event.target.value;
      this.wrapAddressObj.FlatNo__c = this.wrapAddressObj.APFHouse_Flat_PlotNo__c
    } else if (event.target.dataset.name === "ValuationToBeTakenAheadForCalculation__c") {
      this.wrapAddressObj.ValuationToBeTakenAheadForCalculation__c = event.target.value;
    } else if (event.target.dataset.name === "Improvement_construction_estimate_docum__c") {
      this.wrapAddressObj.Improvement_construction_estimate_docum__c = event.target.value;
      if (this.wrapAddressObj.Improvement_construction_estimate_docum__c === "Yes") {
        this.estArchAgreeFieldVsibl = true
        this.reqTotConsEst = true
      } else {
        this.wrapAddressObj.Appr_Cost_of_Const__c = "";
        this.estArchAgreeFieldVsibl = false
        this.reqTotConsEst = false
        this.calculateTotalPropCost();
        const totalPropCost = parseFloat(this.wrapAddressObj.Total_Prop_Cost__c) || 0;
        const sanLoanAmount = parseFloat(this.sancLoanAmt) || 0;
        const downPayRegAgre = parseFloat(this.wrapAddressObj.Down_payment_PartORegisteredAgreement__c) || 0;
        this.wrapAddressObj.Balance_OCR_to_be_arranged_by_customer__c = totalPropCost - sanLoanAmount - downPayRegAgre || 0;

      }
    } else if (event.target.dataset.name === "Down_payment_PartORegisteredAgreement__c") {
      this.wrapAddressObj.Down_payment_PartORegisteredAgreement__c = event.target.value;
      const downPay = parseFloat(event.target.value) || 0;
      const totalPropCost = parseFloat(this.wrapAddressObj.Total_Prop_Cost__c) || 0;
      const sanLoanAmount = parseFloat(this.sancLoanAmt) || 0;
      this.wrapAddressObj.Balance_OCR_to_be_arranged_by_customer__c = totalPropCost - sanLoanAmount - downPay;
    } else if (event.target.dataset.name === "Appr_Cost_of_Const__c") {
      this.wrapAddressObj.Appr_Cost_of_Const__c = event.target.value;
      const apprCostOfConst = parseFloat(this.wrapAddressObj.Appr_Cost_of_Const__c) || 0;
      const propBuilUpArea = parseFloat(this.wrapAddressObj.Prop_Bui_up_ar__c) || 0;
      //commented for LAK-8215
     // this.wrapAddressObj.Per_Sq_Ft_Approved_Cost_of_Construction__c = apprCostOfConst / propBuilUpArea;
      const totalPropCost = parseFloat(this.wrapAddressObj.Total_Prop_Cost__c) || 0;
      const sanLoanAmount = parseFloat(this.sancLoanAmt) || 0;
      const downPayRegAgre = parseFloat(this.wrapAddressObj.Down_payment_PartORegisteredAgreement__c) || 0;
      this.wrapAddressObj.Balance_OCR_to_be_arranged_by_customer__c = totalPropCost - sanLoanAmount - downPayRegAgre || 0;

    }
  }

  calculateTotalPropCost() {
    let fields = [
      "Cost_of_Plot__c",
      "Agrem_Value__c",
      "Appr_Cost_of_Const__c",
      "Regi_Cost__c",
      "Stamp_Duty__c",
      "Amenities__c"
    ];
    let fldValue = 0;
    fields.forEach((fld) => {

      let tempVar = this.wrapAddressObj[fld] === undefined || this.wrapAddressObj[fld] === "" ? 0 : parseInt(this.wrapAddressObj[fld]);
      fldValue = parseInt(fldValue) + tempVar;
    });
    this.wrapAddressObj["Total_Prop_Cost__c"] = fldValue;

    const totalPropCost = fldValue;
    const downPayRegAgre = parseFloat(this.wrapAddressObj.Down_payment_PartORegisteredAgreement__c) || 0;
    const sanLoanAmount = parseFloat(this.sancLoanAmt) || 0;

    this.wrapAddressObj.Balance_OCR_to_be_arranged_by_customer__c = totalPropCost - sanLoanAmount - downPayRegAgre || 0;
  }
}