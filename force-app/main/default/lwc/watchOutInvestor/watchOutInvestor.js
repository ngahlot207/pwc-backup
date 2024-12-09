import { LightningElement, track, api } from 'lwc';

// import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class WatchOutInvestor extends LightningElement {

    @api loanAppId = 'a08C4000007Kw2EIAS';
    @api hasEditAccess = false;
    @track queryParam = [];
    @track params = {};
    @track paramsNoMatch = {};
    @track paramsAppl = {};
    @track isReadOnly = false;
    @track showSpinner = false;
    @track activeSections = ["A", "B"];
    @track columnsDataForTable = [
        {
            "label": "Applicant Name",
            "fieldName": "ApplNme__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Applicant Type",
            "fieldName": "ApplTyp__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Record ID",
            "fieldName": "RecId__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Regulator Competent Authority Name",
            "fieldName": "RegCompAuthName__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Date of Order",
            "fieldName": "OdrDt__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Defaulter Code",
            "fieldName": "DefCode__c",
            "type": "test",
            "Editable": false
        },
        {
            "label": "Defaulter Name",
            "fieldName": "DefName__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Defaulter Type Company Person",
            "fieldName": "DefTypCmpyPrsn__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Defaulter New Name1",
            "fieldName": "DefNewNme1__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Defaulter Old Name1",
            "fieldName": "DefOldNme1__c	",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Defaulter Merged With",
            "fieldName": "DefMrgWth__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "PAN CIN DIN",
            "fieldName": "PanCinDin__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Defaulter Other Details",
            "fieldName": "DefOthrDtls__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Not Defaulter Infact Associated Entity",
            "fieldName": "OthrEntAssosWthDefEnt__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Associated Entity Person",
            "fieldName": "AssocEntPrsn__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Regulatory Charges",
            "fieldName": "RegChngs__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Regulatory Actions",
            "fieldName": "RegActns__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Regulatory Action Source1",
            "fieldName": "RegActnSrc1__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Regulatory Action Source2",
            "fieldName": "RegActnsSrc2__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Regulatory Action Source3",
            "fieldName": "RegActnsSrc3__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Result Relevance",
            "fieldName": "Result_Relevance__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Internal Dedupe result remark",
            "fieldName": "IntDedRsltRmrks__c",
            "type": "text",
            "Editable": false
        },
        {
            "label": "Created Date",
            "fieldName": "CreatedDate",
            "type": "Date/Time",
            "Editable": false
        }
    ];
    @track isModalOpen = false;
    @track queryData = 'SELECT ApplNme__c,toLabel(ApplTyp__c),RecId__c,RegCompAuthName__c,OdrDt__c,DefCode__c,DefName__c,DefTypCmpyPrsn__c,DefNewNme1__c,DefOldNme1__c,DefMrgWth__c,PanCinDin__c,DefOthrDtls__c,OthrEntAssosWthDefEnt__c,AssocEntPrsn__c,RegChngs__c,RegActns__c,RegActnSrc1__c,RegActnsSrc2__c,RegActnsSrc3__c,Result_Relevance__c,IntDedRsltRmrks__c,CreatedDate,Id FROM APIVer__c WHERE LoanAplcn__c =: loanAppId AND recordtype.name =: recordTypeName AND IsLatest__c =: isActiveValue AND WatchoutInvestor__c =: watchInvestorValue';

    @track queryDataNoMatch = 'SELECT ApplNme__c,toLabel(ApplTyp__c),RecId__c,RegCompAuthName__c,OdrDt__c,DefCode__c,DefName__c,DefTypCmpyPrsn__c,DefNewNme1__c,DefOldNme1__c,DefMrgWth__c,PanCinDin__c,DefOthrDtls__c,OthrEntAssosWthDefEnt__c,AssocEntPrsn__c,RegChngs__c,RegActns__c,RegActnSrc1__c,RegActnsSrc2__c,RegActnsSrc3__c,Result_Relevance__c,IntDedRsltRmrks__c,CreatedDate,Id FROM APIVer__c WHERE LoanAplcn__c =: loanAppId AND recordtype.name =: recordTypeName AND IsLatest__c =: isActiveValue AND WatchoutInvestor__c =: watchInvestorValue';
    connectedCallback() {
        let paramVal = [];
        paramVal.push({ key: 'loanAppId', value: this.loanAppId });
        paramVal.push({ key: 'recordTypeName', value: 'Watchout' });
        paramVal.push({ key: 'isActiveValue', value: true });
        paramVal.push({ key: 'watchInvestorValue', value: true });
        this.queryParam = paramVal;
        console.log('map data:::', this.queryParam);
        this.params = {
            columnsData: this.columnsDataForTable,
            queryParams: this.queryParam,
            query: this.queryData
        }

        let paramValNoMatch = [];
        paramValNoMatch.push({ key: 'loanAppId', value: this.loanAppId });
        paramValNoMatch.push({ key: 'recordTypeName', value: 'Watchout' });
        paramValNoMatch.push({ key: 'isActiveValue', value: true });
        paramValNoMatch.push({ key: 'watchInvestorValue', value: false });
        this.paramsNoMatch = {
            columnsData: this.columnsDataForTable,
            queryParams: paramValNoMatch,
            query: this.queryDataNoMatch
        }
        //  this.hasEditAccess = false;
        if (this.hasEditAccess === true || this.hasEditAccess === undefined) {
            this.isReadOnly = false;
        }
        else {
            this.isReadOnly = true;
        }
    }

    handleIntialization() {
        this.isModalOpen = true;

    }



    handleCustomEvent(event) {
        this.isModalOpen = false;
        let spinnerValue = event.detail.spinner;
        if (spinnerValue) {
            this.showSpinner = true;
        } else {
            this.showSpinner = false;
        }
        let titleVal = event.detail.title;
        let variantVal = event.detail.variant;
        let messageVal = event.detail.message;
        console.log('val from return is', titleVal, 'variantVal', variantVal, 'messageVal', messageVal);
        if (titleVal && variantVal && messageVal) {
            // setTimeout(() => {
            //     this.showSpinner = false;
            //     this.handleRefreshClick();
            // }, 6000);
            this.handleRefreshClick();
            const evt = new ShowToastEvent({
                title: titleVal,
                variant: variantVal,
                message: messageVal
            });
            this.dispatchEvent(evt);

        }
    }


    handleRefreshClick() {
        // const childComponent = this.template.querySelector('[data-id="childComponent"]');
        // if (childComponent) {
        //     console.log('before');
        //     childComponent.handleGettingData();
        //     console.log('after');
        // }
        this.showSpinner = true;
        const childComponent = this.template.querySelector('[data-id="childComponentOne"]');
        if (childComponent) {
            console.log('before');
            childComponent.handleGettingData();
            console.log('after');

            const childComponentTwo = this.template.querySelector('[data-id="childComponentTwo"]');
            if (childComponentTwo) {
                console.log('before');
                childComponentTwo.handleGettingData();
                console.log('after');
            }
            this.showSpinner = false;
        }

    }
}