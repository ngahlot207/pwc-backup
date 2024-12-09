import { LightningElement, api, track, wire } from 'lwc';

//Apex Methods
import upsertMultipleRecord from '@salesforce/apex/SObjectDynamicRecordProvider.upsertMultipleRecord';
import getSobjectDatas from '@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData';
import getSobjectData from '@salesforce/apex/SObjectDynamicRecordProvider.getAssetPropType';
import { formattedDate, formattedDateTimeWithoutSeconds } from 'c/dateUtility';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import formFactorPropertyName from "@salesforce/client/formFactor";
import { refreshApex } from '@salesforce/apex';
// Custom labels
import KycVerf_OCR_ErrorMessage from '@salesforce/label/c.KycVerf_OCR_ErrorMessage';
import KycVerf_SelRecords_ErrorMessage from '@salesforce/label/c.KycVerf_SelRecords_ErrorMessage';
import KycVerf_Int_SucessMessage from '@salesforce/label/c.KycVerf_Int_SucessMessage';
import KycVerf_Int_ErrorMessage from '@salesforce/label/c.KycVerf_Int_ErrorMessage';
import KycVerf_OCR_ErrorMes from '@salesforce/label/c.KycVerf_OCR_ErrorMes';

export default class KycVerificationDetails extends LightningElement {
    customLabel = {
        KycVerf_OCR_ErrorMessage,
        KycVerf_SelRecords_ErrorMessage,
        KycVerf_Int_SucessMessage,
        KycVerf_Int_ErrorMessage,
        KycVerf_OCR_ErrorMes

    }
    //  @api loanAppId = 'a08C4000007Kw2EIAS';
    @api hasEditAccess = false;

    @track _loanAppId;
    @api get loanAppId() {
        return this._loanAppId;
    }
    set loanAppId(value) {
        this._loanAppId = value;
        //this.setAttribute("loanAppId", 'a08C4000007Kw2EIAS');
        this.setAttribute("loanAppId", value);
        this.handleRecordIdChange(value);
    }

    // @track paramsData = {
    //     ParentObjectName: 'ApplKyc__c',
    //     ChildObjectRelName: 'Document_Details__r',
    //     parentObjFields: ['Id', 'kycDoc__c', 'OCRStatus__c', 'ValidationStatus__c', 'Applicant__r.TabName__c', 'toLabel(Applicant__r.ApplType__c)', 'Name__c', 'DtOfBirth__c', 'Address__c', 'toLabel(Gender__c)', 'FatherName__c'],
    //     childObjFields: ['Appl__c', 'Applicant_KYC__c', 'DocTyp__c', 'Id'],
    //     queryCriteria: ' where Applicant__r.LoanAppln__c = \'' + this.loanAppId + '\' ORDER BY CreatedDate DESC'
    // }


    @track formFactor = formFactorPropertyName;
    @track desktopBoolean = false;
    @track phoneBolean = false;
    @track intRecordsAll = [];
    @track intMsgIds = [];
    enableInfiniteScrolling = true;
    enableBatchLoading = true;
    @track isReadOnly = false;
    @track appkycData = [];
    @track showSpinner = false;
    @track activeSections = ["A", "B"];
    @track wiredAppKycData = {};
    @track message = 'All pending and failed KYC verifications can be completed from PAN & KYC page';

    @track paramsConsent = {};
    @track queryParam = [];
    @track columnsDataForConsent = [
        {
            "label": "Applicant Name",
            "fieldName": "Appl__r.TabName__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Applicant Type",
            "fieldName": "Appl__r.ApplType__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Consent Type",
            "fieldName": "Consent_Type__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Mobile Number",
            "fieldName": "MobNumber__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "OTP Consent Date Time",
            "fieldName": "ConsentDateTime__c",
            "type": "Date/Time",
            "Editable": false
        }
    ];

    @track queryDataForConsent = 'SELECT Appl__r.TabName__c,toLabel(Appl__r.ApplType__c),Consent_Type__c,MobNumber__c,ConsentDateTime__c,Id FROM ApplConsentHis__c WHERE LoanAppln__c =: loanAppId AND Appl__c != null ORDER BY Appl__r.ApplType__c';

    @track paramsNew = {
        ParentObjectName: 'DocDtl__c',
        parentObjFields: ['Id', 'DocValidStatus__c', 'Appl__r.Constitution__c', 'Applicant_KYC__r.Applicant__r.Constitution__c', 'Applicant_KYC__r.Applicant__r.TabName__c', 'Applicant_KYC__r.Name_Match_Score__c', 'Applicant_KYC__r.ExpiryDt__c', 'Applicant_KYC__r.KycDocNo__c', 'Applicant_KYC__r.kycDoc__c', 'toLabel(Applicant_KYC__r.Applicant__r.ApplType__c)', 'toLabel(Appl__r.ApplType__c)', 'Applicant_KYC__r.kycId__c', 'DocSubTyp__c', 'DocTyp__c', 'Applicant_KYC__r.Name__c', 'Applicant_KYC__r.DtOfBirth__c', 'Applicant_KYC__r.Address__c', 'Applicant_KYC__r.FatherName__c', 'toLabel(Applicant_KYC__r.Gender__c)', 'Applicant_KYC__r.HusbandName__c', 'Applicant_KYC__r.DtOfExp__c', 'Applicant_KYC__r.OCRStatus__c', 'Applicant_KYC__r.ValidationStatus__c', 'Applicant_KYC__r.Validation_Error_Message__c', 'Applicant_KYC__r.OCR_Error_Message__c', 'Appl__r.TabName__c', 'Appl__c'],
        queryCriteria: ' where LAN__c = \'' + this.loanAppId + '\' ORDER BY CreatedDate DESC'
    }


    @track docCat = ['KYC Documents', 'PAN Documents'];
    handleRecordIdChange() {
        console.log('loanAppId is ', this.loanAppId);
        console.log('_loanAppId is ', this._loanAppId);
        let paramsDataNew = this.paramsNew;
        paramsDataNew.queryCriteria = ' where LAN__c = \'' + this.loanAppId + '\' AND DocCatgry__c  IN (\'' + this.docCat.join('\', \'') + '\') ORDER BY CreatedDate DESC'
        this.paramsNew = { ...paramsDataNew };
    }

    @wire(getSobjectDatas, { params: '$paramsNew' })
    handleAppKyc(result) {
        const { data, error } = result;
        this.wiredAppKycData = result;
        console.log('result is ', JSON.stringify(result));
        console.log('wiredAppKycData is ', this.wiredAppKycData);
        if (data) {
            if (data.parentRecords !== undefined) {
                this.appkycData = JSON.parse(JSON.stringify(data.parentRecords));
                let docIds = [];
                this.appkycData.forEach(item => {
                    // item['selectCheckbox'] = false;
                    if (item.Applicant_KYC__r && item.Applicant_KYC__r.DtOfBirth__c && typeof item.Applicant_KYC__r.DtOfBirth__c !== 'undefined') {
                        const formattedDate1 = formattedDate(item.Applicant_KYC__r.DtOfBirth__c);
                        const dateFinal = `${formattedDate1}`;
                        item.Applicant_KYC__r.DtOfBirth__c = dateFinal;
                    }
                    if (item.Applicant_KYC__r && item.Applicant_KYC__r.ExpiryDt__c && typeof item.Applicant_KYC__r.ExpiryDt__c !== 'undefined') {
                        const formattedDate2 = formattedDate(item.Applicant_KYC__r.ExpiryDt__c);
                        const dateFinal1 = `${formattedDate2}`;
                        item.Applicant_KYC__r.ExpiryDt__c = dateFinal1;
                    }
                    docIds.push(item.Id);
                    //LAK-428
                    let cellClass = '';
                    if (item.Appl__c && item.Appl__r.Constitution__c) {
                        if (item.Appl__r.Constitution__c === 'INDIVIDUAL') {
                            if (item.Applicant_KYC__r && item.Applicant_KYC__r.Name_Match_Score__c !== undefined) {
                                if (item.Applicant_KYC__r.Name_Match_Score__c < 50) {
                                    cellClass = 'red-cell';
                                } else if (item.Applicant_KYC__r.Name_Match_Score__c >= 50 && item.Applicant_KYC__r.Name_Match_Score__c < 70) {
                                    cellClass = 'amber-cell';
                                } else if (item.Applicant_KYC__r.Name_Match_Score__c >= 70) {
                                    cellClass = 'green-cell';
                                }
                            }
                        } else {
                            if (item.Applicant_KYC__r && item.Applicant_KYC__r.Name_Match_Score__c !== undefined) {
                                if (item.Applicant_KYC__r.Name_Match_Score__c < 80) {
                                    cellClass = 'red-cell';
                                } else if (item.Applicant_KYC__r.Name_Match_Score__c >= 80 && item.Applicant_KYC__r.Name_Match_Score__c < 90) {
                                    cellClass = 'amber-cell';
                                } else if (item.Applicant_KYC__r.Name_Match_Score__c >= 90) {
                                    cellClass = 'green-cell';
                                }
                            }
                        }
                    }
                    item.cellClass = cellClass;
                    //LAK-428
                    console.log('this.appkycData is ', this.appkycData);
                });
                if (docIds.length > 0) {
                    this.getContentDocLinkData(docIds);
                }
                this.showSpinner = false;
            }
        } else if (error) {
            console.log('Error in Kyc data fetch=>' + error);
        }
    }

    getContentDocLinkData(docIds) {
        this.showSpinner = true;
        let paramsCDL = {
            ParentObjectName: 'ContentDocumentLink',
            parentObjFields: ['Id', 'LinkedEntityId'],
            queryCriteria: ` where LinkedEntityId IN ('${docIds.join("','")}')`
        }
        getSobjectData({ params: paramsCDL })
            .then((result) => {
                console.log('ContentDocumentLink Data is ', JSON.stringify(result));
                if (result.parentRecords) {
                    this.contendDocLinkData = result.parentRecords;
                }
                this.appkycData.forEach(ele => {
                    if (this.contendDocLinkData) {
                        let obj = this.contendDocLinkData.find(item => item.LinkedEntityId === ele.Id);
                        if (obj) {
                            ele.documentUpload = 'Yes';
                        } else {
                            ele.documentUpload = 'No';
                        }
                    } else {
                        ele.documentUpload = 'No';
                    }

                    console.log('this.appkycData after adding DD Upload is  ', JSON.stringify(this.appkycData));
                })
                this.showSpinner = false;
            })

            .catch((error) => {
                this.showSpinner = false;
                console.log('Error In getting ContentDocumentLink Data is ', error);
                //  this.fireCustomEvent("Error", "error", "Error occured in getActiveRepaymentAcc " + error);
            });
    }

    connectedCallback() {
        console.log('formFactor is ', this.formFactor);
        if (this.formFactor == "Large") {
            this.desktopBoolean = true;
            this.phoneBolean = false;
        } else if (this.formFactor == "Small") {
            this.desktopBoolean = false;
            this.phoneBolean = true;
        } else {
            this.desktopBoolean = false;
            this.phoneBolean = true;
        }
        //this.hasEditAccess = false;
        if (this.hasEditAccess === true || this.hasEditAccess === undefined) {
            this.isReadOnly = false;
        }
        else {
            this.isReadOnly = true;
        }

        let paramVal = [];
        paramVal.push({ key: 'loanAppId', value: this._loanAppId });
        this.queryParam = paramVal;
        this.paramsConsent = {
            columnsData: this.columnsDataForConsent,
            queryParams: this.queryParam,
            query: this.queryDataForConsent
        }
        refreshApex(this.wiredAppKycData);
    }
    handleRefreshClick() {
        this.showSpinner = true;
        setTimeout(() => {
            this.showSpinner = false;
            refreshApex(this.wiredAppKycData);
        }, 6000);

    }
    handleClick(event) {
        console.log('record ', event.target.dataset.recordid);
        let selectedRecordId = event.target.dataset.recordid;
        console.log('value is', event.target.checked);
        let val = event.target.checked;
        let recordData = {};
        let searchDoc = this.appkycData.find((doc) => doc.Id === selectedRecordId);
        if (searchDoc) {
            console.log('searchDoc', searchDoc);
            searchDoc['selectCheckbox'] = val;
        }
        else {
            recordData['Id'] = selectedRecordId;
            recordData['selectCheckbox'] = val;
            this.appkycData.push(recordData);
        }
        console.log('All selected Records', this.appkycData);
    }


    handleIntialization() {
        this.showSpinner = true;
        let arra = this.appkycData.filter((doc) => doc.selectCheckbox === true);
        console.log('arra length is ', arra.length);
        if (arra.length > 0) {
            let arraNew = arra.filter((doc) => doc.Applicant_KYC__r.OCRStatus__c === 'Success');
            console.log('arra length is ', arra.length);

            console.log('arra  is ', JSON.stringify(arra));
            arra.forEach(item => {
                console.log('ocr status is ', item.Applicant_KYC__r.OCRStatus__c);
                if (item.Applicant_KYC__r.OCRStatus__c === 'Failure' || item.Applicant_KYC__r.OCRStatus__c === 'Inprogress') {
                    this.showToast("Error", "error", item.Applicant_KYC__r.kycDoc__c + ' ' + this.customLabel.KycVerf_OCR_ErrorMessage + ' ' + item.Applicant_KYC__r.kycDoc__c + " Details");
                }
                if (item.Applicant_KYC__r.OCRStatus__c === undefined) {
                    this.showToast("Error", "error", item.Applicant_KYC__r.kycDoc__c + ' ' + this.customLabel.KycVerf_OCR_ErrorMes);
                }
            })
            if (arraNew.length > 0) {
                console.log('arraNew length is ', arraNew.length);
                console.log('arraNew  is ', JSON.stringify(arraNew));
                arraNew.forEach(item => {
                    let serviceName = '';
                    if (item.Applicant_KYC__r.kycDoc__c === 'Pan') {
                        serviceName = 'Pan Validation';
                    }
                    else if (item.Applicant_KYC__r.kycDoc__c === 'Aadhaar') {
                        // to be added later
                    }
                    else if (item.Applicant_KYC__r.kycDoc__c === 'Passport') {
                        serviceName = 'Passport Verification';
                    }
                    else if (item.Applicant_KYC__r.kycDoc__c === 'Driving License') {
                        serviceName = 'DL Authentication';
                    }
                    else if (item.Applicant_KYC__r.kycDoc__c === 'Voter Id') {
                        serviceName = 'Voterid Verification';
                    } else {
                        serviceName = "KYC OCR";
                    }
                    let fields = {};
                    fields['sobjectType'] = 'IntgMsg__c';
                    fields['Name'] = serviceName; //serviceName;//'KYC OCR'
                    fields['BU__c'] = 'HL / STL';
                    fields['IsActive__c'] = true;
                    fields['Svc__c'] = serviceName; //serviceName;
                    fields['ExecType__c'] = 'Async';
                    fields['Status__c'] = 'New';
                    fields['Mresp__c'] = 'Blank';
                    fields['Outbound__c'] = true;
                    fields['DocApi__c'] = true;
                    fields['Trigger_Platform_Event__c'] = false;
                    fields['ParentRefObj__c'] = "ApplKyc__c";
                    fields['ParentRefId__c'] = item.Applicant_KYC__r.Id ? item.Applicant_KYC__r.Id : '';
                    fields['RefObj__c'] = 'DocDtl__c';
                    fields['RefId__c'] = item.Id ? item.Id : '';
                    this.intRecordsAll.push(fields);
                })
                console.log('this.intRecords ', JSON.stringify(this.intRecordsAll));
                this.upsertIntRecord(this.intRecordsAll);
            } else {
                this.showSpinner = false;
                this.appkycData.forEach(item => {
                    item['selectCheckbox'] = false;
                });
                console.log('this.appKycDataNew ', this.appkycData);
            }
        } else {
            this.showSpinner = false;
            this.showToast("Error", "error", this.customLabel.KycVerf_SelRecords_ErrorMessage);

        }
    }

    upsertIntRecord(intRecords) {
        if (intRecords.length > 0) {
            console.log('int msgs records ', JSON.stringify(intRecords));
            upsertMultipleRecord({ params: intRecords })
                .then((result) => {
                    console.log('Result after creating Int Msgs is ', JSON.stringify(result));
                    result.forEach(item => {
                        this.intMsgIds.push(item.Id);
                    })
                    console.log('intMsgIds after creating Int Msgs is ', JSON.stringify(this.intMsgIds));
                    this.showToast("Success", "success", this.customLabel.KycVerf_Int_SucessMessage);

                    this.appkycData.forEach(item => {
                        item.selectCheckbox = false;
                    });
                    this.intRecordsAll = [];
                    this.showSpinner = false;
                })
                .catch((error) => {
                    this.showSpinner = false;
                    console.log('Error In creating Record', error);
                    this.showToast("Error", "error", this.customLabel.KycVerf_Int_ErrorMessage);

                });
        } else {
            this.showSpinner = false;
        }
    }


    showToast(title, variant, message) {
        const evt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message
        });
        this.dispatchEvent(evt);
    }

    //******************FOR HANDLING THE HORIZONTAL SCROLL OF TABLE MANUALLY******************//
    tableOuterDivScrolled(event) {
        this._tableViewInnerDiv = this.template.querySelector(".tableViewInnerDiv");
        if (this._tableViewInnerDiv) {
            if (!this._tableViewInnerDivOffsetWidth || this._tableViewInnerDivOffsetWidth === 0) {
                this._tableViewInnerDivOffsetWidth = this._tableViewInnerDiv.offsetWidth;
            }
            this._tableViewInnerDiv.style = 'width:' + (event.currentTarget.scrollLeft + this._tableViewInnerDivOffsetWidth) + "px;" + this.tableBodyStyle;
        }
        this.tableScrolled(event);
    }

    tableScrolled(event) {
        if (this.enableInfiniteScrolling) {
            if ((event.target.scrollTop + event.target.offsetHeight) >= event.target.scrollHeight) {
                this.dispatchEvent(new CustomEvent('showmorerecords', {
                    bubbles: true
                }));
            }
        }
        if (this.enableBatchLoading) {
            if ((event.target.scrollTop + event.target.offsetHeight) >= event.target.scrollHeight) {
                this.dispatchEvent(new CustomEvent('shownextbatch', {
                    bubbles: true
                }));
            }
        }
    }

    //******************************* RESIZABLE COLUMNS *************************************//
    handlemouseup(e) {
        this._tableThColumn = undefined;
        this._tableThInnerDiv = undefined;
        this._pageX = undefined;
        this._tableThWidth = undefined;
    }

    handlemousedown(e) {
        if (!this._initWidths) {
            this._initWidths = [];
            let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
            tableThs.forEach(th => {
                this._initWidths.push(th.style.width);
            });
        }

        this._tableThColumn = e.target.parentElement;
        this._tableThInnerDiv = e.target.parentElement;
        while (this._tableThColumn.tagName !== "TH") {
            this._tableThColumn = this._tableThColumn.parentNode;
        }
        while (!this._tableThInnerDiv.className.includes("slds-cell-fixed")) {
            this._tableThInnerDiv = this._tableThInnerDiv.parentNode;
        }
        console.log("handlemousedown._tableThColumn.tagName => ", this._tableThColumn.tagName);
        this._pageX = e.pageX;

        this._padding = this.paddingDiff(this._tableThColumn);

        this._tableThWidth = this._tableThColumn.offsetWidth - this._padding;
        console.log("handlemousedown._tableThColumn.tagName => ", this._tableThColumn.tagName);
    }

    handlemousemove(e) {
        console.log("mousemove._tableThColumn => ", this._tableThColumn);
        if (this._tableThColumn && this._tableThColumn.tagName === "TH") {
            this._diffX = e.pageX - this._pageX;

            this.template.querySelector("table").style.width = (this.template.querySelector("table") - (this._diffX)) + 'px';

            this._tableThColumn.style.width = (this._tableThWidth + this._diffX) + 'px';
            this._tableThInnerDiv.style.width = this._tableThColumn.style.width;

            let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
            let tableBodyRows = this.template.querySelectorAll("table tbody tr");
            let tableBodyTds = this.template.querySelectorAll("table tbody .dv-dynamic-width");
            tableBodyRows.forEach(row => {
                let rowTds = row.querySelectorAll(".dv-dynamic-width");
                rowTds.forEach((td, ind) => {
                    rowTds[ind].style.width = tableThs[ind].style.width;
                });
            });
        }
    }

    handledblclickresizable() {
        let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
        let tableBodyRows = this.template.querySelectorAll("table tbody tr");
        tableThs.forEach((th, ind) => {
            th.style.width = this._initWidths[ind];
            th.querySelector(".slds-cell-fixed").style.width = this._initWidths[ind];
        });
        tableBodyRows.forEach(row => {
            let rowTds = row.querySelectorAll(".dv-dynamic-width");
            rowTds.forEach((td, ind) => {
                rowTds[ind].style.width = this._initWidths[ind];
            });
        });
    }

    paddingDiff(col) {

        if (this.getStyleVal(col, 'box-sizing') === 'border-box') {
            return 0;
        }

        this._padLeft = this.getStyleVal(col, 'padding-left');
        this._padRight = this.getStyleVal(col, 'padding-right');
        return (parseInt(this._padLeft, 10) + parseInt(this._padRight, 10));

    }

    getStyleVal(elm, css) {
        return (window.getComputedStyle(elm, null).getPropertyValue(css))
    }
}