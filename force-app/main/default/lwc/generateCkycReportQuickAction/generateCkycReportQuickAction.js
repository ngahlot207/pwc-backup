import { LightningElement, wire, api } from 'lwc';
import fetchApplCKYCDataReport from '@salesforce/apex/Trackwizz_CKYC_A63_RequestGenerator.fetchApplCKYCDataReport';
export default class GenerateCkycReportQuickAction extends LightningElement {

    @api recordId;
    columns = [];
    ckycData = [];
    colHeaders = [];

    @wire(fetchApplCKYCDataReport, {lanIds : '$recordId'})
    applCKYCData({data, error}) {
        if (data) {
            const reversedData = this.getSortedData(JSON.parse(data));
            console.log('###Reversed CKYC Data---->'+JSON.stringify(reversedData));
            this.columns = this.extractColumns(reversedData);
            this.ckycData = reversedData;
        }
        if(error) {
            console.log('###Error in getting data---->'+error);
        }
    }

    getSortedData(initData) {
        let finalData = [];
        for (let i = 0; i < initData.length; i++) {
            const reversedObj = Object.fromEntries(Object.entries(initData[i]).reverse());
            finalData.push(reversedObj);
        }
        return finalData;
    }

    extractColumns(data) {
        const firstRecord = data[0];
        let procCols = [];
        for (let key in firstRecord) {
            this.colHeaders.push(key);
            procCols.push({
                label: key,
                fieldName: key,
            })
        }
        return procCols;
    }

    handleDownloadClick() {
        
        let doc = '<table>';
        doc += '<style>';
        doc += 'table, th,td{';
        doc += 'border: 1px solid black;';
        doc += 'border-collapse:collapse;';
        doc += '}';
        doc += '</style>';

        /** Add table headers */
        doc += '<tr>';
        if(!(this.colHeaders || this.colHeaders.length)) {
            return null;
        }
        
        this.colHeaders.forEach(head =>{
            doc += '<th>' + head + '</th>';
        })
        
        doc += '</tr>';

        /**Add data */

        if(!(this.ckycData || this.ckycData.length)) {
            return null;
        }
        
        let arrayMap = [];
        this.ckycData.forEach(data => {
            arrayMap.push(new Map(Object.entries(data)))
        })
        
        if(!(arrayMap || arrayMap.length)) {
            return null;
        }
        
        let fileName = typeof(this.recordId) === 'string' ? arrayMap[0].get('LAN') : 'CKYC_Report';

        arrayMap.forEach(data => {
            doc += '<tr>';
            this.colHeaders.forEach(head =>{
                doc += '<td>' + data.get(head) + '</td>';
            })
            doc += '</tr>';
        })
        doc += '</table>';

        let ele = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downlEle = document.createElement('a');
        downlEle.href = ele;
        downlEle.target = '_self';
        downlEle.download = fileName + '.xls';
        document.body.appendChild(downlEle);
        downlEle.click();
    }
}