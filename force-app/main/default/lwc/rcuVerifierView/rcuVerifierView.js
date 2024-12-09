import { LightningElement,track, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi'

import APPLICANT_ID from '@salesforce/schema/LoanAppl__c.Name';
import CHANNEL_CODE from '@salesforce/schema/LoanAppl__c.ChannelCode__c';
import CHANNEL_NAME from '@salesforce/schema/LoanAppl__c.ChannelName__c';
import PRODUCT from '@salesforce/schema/LoanAppl__c.Product__c';
import LOGIN_DATE from '@salesforce/schema/LoanAppl__c.LoginAcceptDate__c';
import RM_NAME from '@salesforce/schema/LoanAppl__c.RM__c';
import BRANCH_NAME from '@salesforce/schema/LoanAppl__c.BrchName__c';
import CITY from '@salesforce/schema/LoanAppl__c.City__c';
import SCHEME from '@salesforce/schema/LoanAppl__c.SchemeId__c';
import SCHEME_CODE from '@salesforce/schema/LoanAppl__c.SchmCode__c';
import LOAN_TENURE from '@salesforce/schema/LoanAppl__c.ReqTenInMonths__c';
import EFFECTIVE_ROI from '@salesforce/schema/LoanAppl__c.EffectiveROI__c';
import TOTAL_LOAN_AMT from '@salesforce/schema/LoanAppl__c.TotalLoanAmtInclInsurance__c';

import SCHEME_NAME from '@salesforce/schema/SchMapping__c.Name';

import { formatDateFunction, formattedDateTimeWithSeconds, formattedDate } from 'c/dateUtility';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import getLoanDetailsSummary from '@salesforce/apex/ObligationDetailsSummaryController.getLoanDetailsSummary';
import getBorrowerDetails from '@salesforce/apex/ObligationDetailsSummaryController.getBorrowerDetails';
import getCollateralVisitDetails from '@salesforce/apex/ObligationDetailsSummaryController.getCollateralVisitDetails';
import getApplicantEmploymentDetail from '@salesforce/apex/ObligationDetailsSummaryController.getApplicantEmploymentDetail';
import getSobjectDataNonCacheable from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectDataNonCacheable";

const fields = [APPLICANT_ID, LOGIN_DATE, BRANCH_NAME, CITY, PRODUCT, SCHEME, SCHEME_CODE,RM_NAME,
    CHANNEL_CODE, CHANNEL_NAME,LOAN_TENURE, EFFECTIVE_ROI,TOTAL_LOAN_AMT];


const SchemeFields = [SCHEME_NAME];
export default class RcuVerifierView extends LightningElement {
@api objectApiName="LoanAppl__c";

@track applicationId;
@track loginDate;
@track branchName;
@track city;
@track product;
@track schemeId;
@track schemeCode;
@track rMName;
@track channelCode;
@track channelName;
@track ChannelRName;
@track loanTenure;
@track effectiveROI;
@track totalLoanAnt;
@track hunterStatus;

@track borowerTypeName;
@track loanDetailsSummaryList=[];
@track listBorrowerDetails =[];
@track addrDetails=[];
@track financeBorrowerList =[];

@track kycVerifData=[];

@track buereauList=[];
@track propertyDetailsList=[];

@track activeSection = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O"];

@track _loanAppId;
@api get recordId() {
       return this._loanAppId;
}
set recordId(value) {
        this._loanAppId = value;
        this.setAttribute("loanAppId", value);  
       // this.handleLoanAppRecordIdChange(value); 
        this.handleRecordIdChange(value);     
        this.fetchHunterDetails(value);    
}
connectedCallback(){
    console.log('_loanAppId:::::::in RCU Verifier68', this.recordId, this._loanAppId);
}

    @wire(getRecord, { recordId: '$_loanAppId', fields: fields })
    recordLoadDetailsHandler({ data, error }) {
    if (data) {
        console.log('data:::::::in RCU Verifier72', data);
        this.applicationId = data.fields.Name.value;
        this.loginDate = formatDateFunction(data.fields.LoginAcceptDate__c.value);
        //console.log('loginDate:::::::', this.loginDate);
        this.branchName = data.fields.BrchName__c.value;
        this.city = data.fields.City__c.value;
        this.product = data.fields.Product__c.value;
        this.schemeId = data.fields.SchemeId__c.value;
        this.schemeCode = data.fields.SchmCode__c.value;
        this.rMName = data.fields.RM__c.value;
        this.channelCode = data.fields.ChannelCode__c.value ? data.fields.ChannelCode__c.value : '';
        this.channelName = data.fields.ChannelName__c.value ?data.fields.ChannelName__c.value : '';
       // this.loanAmount = data.fields.ReqLoanAmt__c.value;
        this.loanTenure = data.fields.ReqTenInMonths__c.value;
        this.effectiveROI = data.fields.EffectiveROI__c.value;
        //this.mainApplicant = data.fields.Final_MSME__c.value;
       // this.assessIncomeApp = data.fields.AssesIncomeAppl__c.value;
        this.totalLoanAnt = data.fields.TotalLoanAmtInclInsurance__c.value;
        // this.insuranceAmount = data.fields.Insurance_Amount__c.value;
        // this.insuAmount = data.fields.InsAmt__c.value;
       
    } if (error) {
        console.log('ERROR:::::::', error);
    }
}

@wire(getRecord, { recordId: '$schemeId', fields: SchemeFields })
recordSchemesHandler({ data, error }) {
   
    if (data) {
        this.schemeNameee = data.fields.Name.value;
       
    } if (error) {
        console.log('ERROR:::::::', error);
    }
}


@wire(getLoanDetailsSummary,{ recordId: '$recordId'})
getLoanDetailsSummary({ data, error }) {

    if (data) {
        this.loanDetailsSummaryList = data;
       
    } if (error) {
        console.log('ERROR:::::::', error);
    }
}


borrowerColumns = [
   
    { label: "Borrower Name", fieldName: "Borrower Name", type: "text" },
    { label: "Borrower Type", fieldName: "Borrower Type", type: "text" },
    { label: "Customer Segment", fieldName: "Customer Segment", type: "text" },
    { label: "Constitution", fieldName: "Constitution", type: "text" },
    { label: "Gender", fieldName: "Gender", type: "text" },
    { label: "Constitution", fieldName: "Constitution", type: "text" },
    { label: "Relationship with applicant", fieldName: "Relationship with applicant", type: "text" },
    { label: "Property Owner", fieldName: "Property Owner", type: "text" },
    { label: "Income Considered", fieldName: "Income Considered", type: "text" }
  
  ];

@wire(getBorrowerDetails,{ recordId: '$recordId'})
wiredgetBorrowerDetails({ data, error }) {
    if (data) {
        console.log('listBorrowerDetails--in RCU View 108>'+this.listBorrowerDetails);

        this.listBorrowerDetails = data.map(item => {
            return {
                ...item,
                'Borrower Name': item.applicantListForBorrowerWrapper ? item.applicantListForBorrowerWrapper.FullName__c : '',
                'Borrower Type': item.borrowerType ? item.borrowerType : '',
                'Customer Segment': item.applicantListForBorrowerWrapper ? item.applicantListForBorrowerWrapper.CustProfile__c : '',
                'Constitution': item.applicantListForBorrowerWrapper ? item.applicantListForBorrowerWrapper.Constitution__c : '',
                'Gender': item.gender ? item.gender : '',
                'Relationship with applicant': item.applicantListForBorrowerWrapper ? item.applicantListForBorrowerWrapper.Relationship__c : '',
                'Property Owner': item.propertyOwnerWrapper ? item.propertyOwnerWrapper : '',
                'Income Considered': item.financialBorrowerWrapper ? item.financialBorrowerWrapper : '',
            }
            })
        
    } else if (error) {
        console.error('Error loading Borrower Details In RCU View 112: ', error);
    }
}


borrowColumns = [
   
    { label: "Borrower Name", fieldName: "Borrower Name", type: "text" },
    { label: "Borrower Type", fieldName: "Borrower Type", type: "text" },
    { label: "Borrower Address", fieldName: "FullAdrs__c", type: "text" },
    { label: "Borrower Contact Number", fieldName: "Borrower Contact Number", type: "text" },
  
  ];

@track borrAddr = {
    ParentObjectName: 'ApplAddr__c',
    parentObjFields: ['Applicant__c','FullAdrs__c','LoanAppl__c','Applicant__r.MobNumber__c','AddrTyp__c',
        'Applicant__r.ApplType__c','Applicant__r.FullName__c'],
    queryCriteria: ' '
}
@wire(getSobjectData,{ params: '$borrAddr'})
getBorrowerAddressDetails(result) {
   const { data, error } = result;
   if (data) {
       if (data.parentRecords !== undefined) {
        console.log('data:::::::160',data);
       // this.addrDetails=result.parentRecords;
    //     this.addrDetails = JSON.parse(JSON.stringify(data.parentRecords));
    //     this.addrDetails.forEach(i=>{
    //         if(i.Applicant__r.ApplType__c==='P'){
    //             i.Applicant__r.ApplType__c= 'PRIMARY';
    //         }
    //         if(i.Applicant__r.ApplType__c==='C'){
    //             i.Applicant__r.ApplType__c='CO-APPLICANT'
    //         }
    //         if(i.Applicant__r.ApplType__c==='G'){
    //             i.Applicant__r.ApplType__c='GUARANTOR'
    //         }
    //         if(i.Applicant__r.ApplType__c==='N'){
    //             i.Applicant__r.ApplType__c='NOMINEE'
    //         }
    //         if(i.Applicant__r.ApplType__c==='A'){
    //             i.Applicant__r.ApplType__c='APPOINTEE'
    //         }
    //    })
        console.log('addrDetails--in RCU View 158>'+JSON.stringify(this.addrDetails));
        this.addrDetails = data.parentRecords.map(item => {
            return {
                ...item,
                'Borrower Name': item.Applicant__c ? item.Applicant__r.FullName__c : '',
                'Borrower Type': item.Applicant__c ? this.getApplicantType(item.Applicant__r.ApplType__c) : '',
                'Borrower Contact Number': item.Applicant__c ? item.Applicant__r.MobNumber__c : ''
            }
            })
       }
   } else if (error) {
       console.log('Error in Kyc data fetch=>', error);
   }

}

getApplicantType(type){
    let val;
                if(type==='P'){
                    val= 'PRIMARY';
                }
                if(type==='C'){
                    val='CO-APPLICANT'
                }
                if(type==='G'){
                    val='GUARANTOR'
                }
                if(type==='N'){
                    val='NOMINEE'
                }
                if(type==='A'){
                    val='APPOINTEE'
                }
                return val;
}

financeBorrowColumns = [
   
    { label: "Borrower Name", fieldName: "Borrower Name", type: "text" },
    { label: "Type of Employment", fieldName: "Type of Employment", type: "text" },
    { label: "Industry of main establishment/company", fieldName: "Industry of main establishment/company", type: "text" },
    { label: "Sub Industry of main establishment/company", fieldName: "Sub Industry of main establishment/company", type: "text" },
  
  ];
@wire(getApplicantEmploymentDetail,{ recordId: '$recordId'})
getFinanceBorrowerDetails({ data, error }) {
    if (data) {
        console.log('financeBorrowerList in RCU 125-->'+JSON.stringify(this.financeBorrowerList)); 
        this.financeBorrowerList = data.map(item => {
            return {
                ...item,
                'Borrower Name': item.borrowerName ? item.borrowerName : '',
                'Type of Employment': item.typeOfEmployment ? item.typeOfEmployment : '',
                'Industry of main establishment/company': item.industryOfMainEstablishment ? item.industryOfMainEstablishment : '',
                'Sub Industry of main establishment/company': item.industryOfMainEstablishment ? item.industryOfMainEstablishment : ''
            }
            })
        
    } else if (error) {
        console.error('Error loading Borrower Details in RCU 128: ', error);
    }
}


propDetColumns = [
   
    { label: "Property Address", fieldName: "Property Address", type: "text" },
    { label: "Property Owner", fieldName: "Property Owner", type: "text" },
    { label: "Nature of Property", fieldName: "Nature of Property", type: "text" },
    { label: "Property Type", fieldName: "Property Type", type: "text" },
    { label: "Property Sub Type", fieldName: "Property Sub Type", type: "text" }
  
  ];

@wire(getCollateralVisitDetails,{ recordId: '$recordId'})
getPropertyDetails({ data, error }) {
    if (data) {
       // this.propertyDetailsList = data;
        console.log('propertyDetailsList In RCU View-->138'+JSON.stringify(this.propertyDetailsList));
        this.propertyDetailsList = data.map(item => {
            return {
                ...item,
                'Property Address': item.PropAddrs__c ? item.PropAddrs__c : '',
                'Property Owner': item.Prop_Owners__c ? item.Prop_Owners__c : '',
                'Nature of Property': item.NatureofProp__c ? item.NatureofProp__c : '',
                'Property Type': item.PropType__c ? item.PropType__c : '',
                'Property Sub Type': item.PropSubType__c ? item.PropSubType__c : '',
            }
            })
    
        
    } else if (error) {
        console.error('Error loading in RCU View: 142', error);
    }
}



@track paramsNew = {
    ParentObjectName: 'DocDtl__c',
    parentObjFields: ['Id', 'Applicant_KYC__r.Applicant__r.FullName__c', 'Applicant_KYC__r.ExpiryDt__c',
         'Applicant_KYC__r.KycDocNo__c',
          'Applicant_KYC__r.kycDoc__c', 'toLabel(Applicant_KYC__r.Applicant__r.ApplType__c)',
           'toLabel(Appl__r.ApplType__c)', 'Applicant_KYC__r.kycId__c', 'DocSubTyp__c', 'DocTyp__c', 
           'Applicant_KYC__r.Name__c', 'Applicant_KYC__r.DtOfBirth__c', 'Applicant_KYC__r.Address__c', 
           'Applicant_KYC__r.FatherName__c', 'toLabel(Applicant_KYC__r.Gender__c)', 'Applicant_KYC__r.HusbandName__c',
            'Applicant_KYC__r.DtOfExp__c', 'Applicant_KYC__r.OCRStatus__c', 'Applicant_KYC__r.ValidationStatus__c', 
            'Applicant_KYC__r.Validation_Error_Message__c', 'Applicant_KYC__r.OCR_Error_Message__c', 
            'Appl__r.TabName__c', 'Appl__c'],
    queryCriteria: ' where LAN__c = \'' + this._loanAppId + '\' ORDER BY CreatedDate DESC'
}


@track docCat = ['KYC Documents', 'PAN Documents'];
handleRecordIdChange() {
    console.log('loanAppId is ', this.loanAppId);
    console.log('_loanAppId is ', this._loanAppId);
    let paramsDataNew = this.paramsNew;
    paramsDataNew.queryCriteria = ' where LAN__c = \'' + this._loanAppId + '\' AND DocCatgry__c  IN (\'' + this.docCat.join('\', \'') + '\') ORDER BY CreatedDate DESC'
    this.paramsNew = { ...paramsDataNew };


    let tempArr= this.buereauParams;
    tempArr.queryCriteria = ' where LoanApp__c = \'' + this._loanAppId + '\' ORDER BY CreatedDate DESC'
    this.buereauParams = { ...tempArr };


    let tempArr1= this.borrAddr;
    tempArr1.queryCriteria= ' where LoanAppl__c = \'' + this._loanAppId + '\' ORDER BY CreatedDate DESC'
    this.borrAddr = { ...tempArr1 };

}


kycVerColumns = [
   
    { label: "Applicant Name", fieldName: "Applicant Name", type: "text" },
    { label: "Applicant Type", fieldName: "Applicant Type", type: "text" },
    { label: "KYC Document No", fieldName: "KYC Document No", type: "text" },
    { label: "KYC Document Type", fieldName: "KYC Document Type", type: "text" },
    { label: "KYC Document For", fieldName: "KYC Document For", type: "text" },
    { label: "Constitution", fieldName: "Constitution", type: "text" },
    { label: "Output Name", fieldName: "Output Name", type: "text" },
    { label: "DOB/DOI", fieldName: "DOB/DOI", type: "text" },
    { label: "Address", fieldName: "Address", type: "text" }
  
  ];


@wire(getSobjectData, { params: '$paramsNew' })
handleAppKyc(result) {
    const { data, error } = result;
    this.wiredAppKycData = result;
    console.log('result is ', result);
    if (data) {
        if (data.parentRecords !== undefined) {            
        this.kycVerifData = data.parentRecords.map(item => {
            return {
                ...item,
                'Applicant Name': item.Applicant_KYC__r ? item.Applicant_KYC__r.Applicant__r.FullName__c : '',
                'Applicant Type': item.Applicant_KYC__r ? item.Applicant_KYC__r.Applicant__r.ApplType__c : '',
                'KYC Document No': item.Applicant_KYC__r ? item.Applicant_KYC__r.KycDocNo__c : '',
                'KYC Document Type': item.DocSubTyp__c ? item.DocSubTyp__c : '',
                'KYC Document For': item.DocTyp__c ? item.DocTyp__c : '',
                'Output Name': item.Applicant_KYC__r ? item.Applicant_KYC__r.Name__c : '',
                'DOB/DOI': item.Applicant_KYC__r ? formattedDate(item.Applicant_KYC__r.DtOfBirth__c) : '',
                'Address': item.Applicant_KYC__r ? item.Applicant_KYC__r.Applicant__r.Address__c : '',
            }
            })
            console.log('this.kycVerifData is ', this.kycVerifData);
          //  this.kycVerifData = JSON.parse(JSON.stringify(data.parentRecords));


            // let docIds = [];
            // this.kycVerifData.forEach(item => {
    
            //     if (item.Applicant_KYC__r && item.Applicant_KYC__r.DtOfBirth__c && typeof item.Applicant_KYC__r.DtOfBirth__c !== 'undefined') {
            //         const formattedDate1 = formattedDate(item.Applicant_KYC__r.DtOfBirth__c);
            //         const dateFinal = `${formattedDate1}`;
            //         item.Applicant_KYC__r.DtOfBirth__c = dateFinal;
            //     }
            //     if (item.Applicant_KYC__r && item.Applicant_KYC__r.ExpiryDt__c && typeof item.Applicant_KYC__r.ExpiryDt__c !== 'undefined') {
            //         const formattedDate2 = formattedDate(item.Applicant_KYC__r.ExpiryDt__c);
            //         const dateFinal1 = `${formattedDate2}`;
            //         item.Applicant_KYC__r.ExpiryDt__c = dateFinal1;
            //     }
            //     docIds.push(item.Id);
       

            //     console.log('this.kycVerifData is ', this.kycVerifData);
            // });
            this.showSpinner = false;
        }
    } else if (error) {
        console.log('Error in Kyc data fetch=>', error);
    }
}



cibilSummColumns = [
   
    { label: "Borrower Name", fieldName: "Borrower Name", type: "text" },
    { label: "Total No of Live loans", fieldName: "Total No of Live loans", type: "text" },
    { label: "Total Live loan exposure", fieldName: "Total Live loan exposure", type: "text" },
    { label: "Total Live Loan Overdue", fieldName: "Total Live Loan Overdue", type: "text" },
    { label: "Total Live Credit Card Overdue", fieldName: "Total Live Credit Card Overdue", type: "text" },
    { label: "Max current DPD of all Live Facilities", fieldName: "Max current DPD of all Live Facilities", type: "text" },
    { label: "Max DPD in last 12 months of all Live Facilities", fieldName: "Max DPD in last 12 months of all Live Facilities", type: "text" },
    { label: "Total Enquiries in last 30 days", fieldName: "Total Enquiries in last 30 days", type: "text" },
    { label: "Report Date", fieldName: "Report Date", type: "text" },
    { label: "Total Live Mortgage loan exposure", fieldName: "Total Live Mortgage loan exposure", type: "text" },
    { label: "Total Mortgage Enquiries in last 30 days", fieldName: "Total Mortgage Enquiries in last 30 days", type: "text" },
    { label: "Total Unsecured Enquiries in last 30 days", fieldName: "Total Unsecured Enquiries in last 30 days", type: "text" }
  
  ];
@track buereauParams = {
    ParentObjectName: 'Bureau__c',
    parentObjFields: ["Applicant__r.FullName__c","Totalliveloan__c","Totalloanexposure__c","Totalsecuredloan__c",
        "Totalunsecuredloan__c","Totalcreditcardoutstanding__c","Totaloanoverdue__c","Totalcreditcardoverdue__c",
        "MaxcurrentDPDLiveFacilities__c","MaxDPDlast12months__c","TotalEnquirieslast30day__c","Report_date__c",
        "TotalMortgageloan__c","TotalMortgageEnqlst30days__c","TotalUnsecuredEnqlast30day__c"
    ],
    queryCriteria: ' '
}


@wire(getSobjectData, { params: '$buereauParams' })
handleBuereau(result) {
    const { data, error } = result;
    console.log('result is 407', result);
    if (data) {
        if (data.parentRecords !== undefined) {
                   
        this.buereauList = data.parentRecords.map(item => {
            return {
                ...item,
                'Borrower Name': item.Applicant__r ? item.Applicant__r.FullName__c : '',
                'Total No of Live loans': item.Totalliveloan__c ? item.Totalliveloan__c : '',
                'Total Live loan exposure': item.Totalloanexposure__c ? item.Totalloanexposure__c : '',
                'Total Live Loan Overdue': item.Totaloanoverdue__c ? item.Totaloanoverdue__c : '',
                'Total Live Credit Card Overdue': item.Totalcreditcardoverdue__c ? item.Totalcreditcardoverdue__c : '',
                'Max current DPD of all Live Facilities': item.MaxcurrentDPDLiveFacilities__c ? item.MaxcurrentDPDLiveFacilities__c : '',
                'Max DPD in last 12 months of all Live Facilities': item.MaxDPDlast12months__c ? item.MaxDPDlast12months__c : '',
                'Total Enquiries in last 30 days': item.TotalEnquirieslast30day__c ? item.TotalEnquirieslast30day__c : '',
                'Report Date': item.Report_date__c ? formattedDate(item.Report_date__c) : '',
                'Total Live Mortgage loan exposure': item.TotalMortgageloan__c ? item.TotalMortgageloan__c : '',
                'Total Mortgage Enquiries in last 30 days': item.TotalMortgageEnqlst30days__c ? item.TotalMortgageEnqlst30days__c : '',
                'Total Unsecured Enquiries in last 30 days': item.TotalUnsecuredEnqlast30day__c ? item.TotalUnsecuredEnqlast30day__c : '',
            }
            })
            console.log('this.buereauList is ', this.buereauList);

            this.showSpinner = false;
        }
    } else if (error) {
        console.log('Error in Kyc data fetch=>', error);
    }
}

fetchHunterDetails() {
  let  hunterParams={
    ParentObjectName: 'HunterVer__c',
    parentObjFields: ["Id","HunMatchSta__c","LoanAplcn__c","LastModifiedDate"
       
    ],
    queryCriteria: ' Where LoanAplcn__c = \''+ this._loanAppId + '\' order by LastModifiedDate DESC'
  }

    getSobjectDataNonCacheable({ params: hunterParams })
      .then((result) => {
        if (
          result.parentRecords !== undefined &&
          result.parentRecords.length > 0
        ) {
          this.hunterStatus = result.parentRecords[0].HunMatchSta__c;
        }
      })
      .catch((error) => {
        console.log("HUNTER ERROR DETAILS #330", error);
      });
  }

}