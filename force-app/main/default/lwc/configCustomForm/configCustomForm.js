import { LightningElement, track, api, wire } from "lwc";
import getCustomData from "@salesforce/apex/CustomFormController.getCustomData";
import mapAndInsertData from "@salesforce/apex/CustomFormController.mapAndInsertData";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import {subscribe, publish, MessageContext, APPLICATION_SCOPE} from 'lightning/messageService';
import SaveProcessCalled from "@salesforce/messageChannel/SaveProcessCalled__c";
// Custom labels
import ConfiCustomForm_SuccessMessage from '@salesforce/label/c.ConfiCustomForm_SuccessMessage';
import ConfiCustomForm_ErrorMessage from '@salesforce/label/c.ConfiCustomForm_ErrorMessage';

export default class ConfigCustomForm extends LightningElement {
    label ={
        ConfiCustomForm_SuccessMessage,
        ConfiCustomForm_ErrorMessage

    }
    @track metadata;
    @track fieldsData;
    @track allData;
    @track objectName;

    @track dynamicQuery;
    @track lookupRec;
    @track recordId = "";
    @api configuration;
    @api applicantId;
    @api testId;

    @wire(MessageContext)
    MessageContext;

   
    sunscribeToMessageChannel() {
        this.subscription = subscribe(
            this.MessageContext,
            SaveProcessCalled,
            (values) => this.handleSaveThroughLms(values)
        );

    }
    connectedCallback() {
        console.log(
            "CONNECTED CALL BACK CALLED FROM CONFIG CUSTOM COMPONENT>>>>",
            this.recordId,
            "::::::::::::::test ID",
            this.testId,
            "::::::::::config:::::::",
            this.configuration
        );
        this.sunscribeToMessageChannel();
        // handleLoad() {
        getCustomData({
            recordId: this.testId,
            config: JSON.stringify(this.configuration)
        })
            .then((result) => {
                console.log("result>>>>", result);
                this.metadata = JSON.parse(result.recordConfig);
                console.log("metadata>>>>", this.metadata);
                let screenConfig = this.metadata;
                console.log("screenConfig>>>>", screenConfig);
                this.objectName = screenConfig.ObjectName;

                // this.ParentObjFieldNme = screenConfig.ParentObjFieldNme;

                this.fieldsData = screenConfig.fieldSets;
                console.log("this.fieldsData>>>>", this.fieldsData);

                console.log("mul", this.displayConfig);

                let apexResult = result.recordData;
                this.allData = result.recordData;
                console.log("this.allData>>>>>>>>>@@@", this.allData);

                if (apexResult) {
                    console.log("apexResult>>>>", apexResult);

                    for (let fieldSet of this.fieldsData) {
                        for (let field of fieldSet.fields) {
                            if (field.FieldName in apexResult) {
                                field.value = apexResult[field.FieldName];
                                // console.log('field.value>>', field.value);
                            }
                        }
                    }
                }
            })
            .catch((error) => {
                this.error = error;
            });
    }

    handleInputChange(event) {
        //This handleInputChange is used to store the changed input values

        // handleInputChange(event) {
        const { fieldName, fieldValue } = event.detail;
        console.log("event.detail>>>>", event.detail);

        this.allData = { ...this.allData, [fieldName]: fieldValue };
        console.log("this.allData1>>>>>", JSON.stringify(this.allData));
        let field = this.fieldsData[0].fields;
        console.log("field>>>>>", JSON.stringify(field));

        // for (let i = 0; i < field.length; i++) {
        //     console.log(
        //         "IN FOR LOOP>>>>",
        //         field[i].FieldName,
        //         "::::::",
        //         ":::::",
        //         field
        //     );
        //     if (field[i].FieldName === fieldName) {
        //         console.log(
        //             "this.fieldsData.FieldName >>>>>",
        //             this.fieldsData[i].FieldName
        //         );
        //         if (field[i].childField) {
        //             console.log(
        //                 "tthis.fieldsData.childField>>>>>",
        //                 field[i].childField
        //             );
        //             for (let j = 0; j < field.length; j++) {
        //                 if (field[j].FieldName === field[j].childField) {
        //                     console.log(
        //                         "this.fieldsData.FieldName >>>>>",
        //                         field[j].FieldName
        //                     );
        //                     this.fieldsData[j].disabled = false;
        //                 }
        //             }
        //         }
        //     }
        // }

        const objKey = Object.keys(this.allData);
        console.log("this.objKey>>>>>", objKey);
        for (let k = 0; k < objKey.length; k++) {
            console.log("this.objKey 2>>>>>", objKey);

            for (let i = 0; i < field.length; i++) {
                if (field[i].type === "combobox") {
                    const found = objKey.find(
                        (element) => element === field[i].FieldName
                    );
                    console.log("found>>>>>", found);
                    if (found) {
                        console.log("found Inside if >>>>>", found);
                        if (field[i].childField) {
                            console.log(
                                "tthis.fieldsData.childField>>>>>",
                                field[i].childField
                            );
                            for (let j = 0; j < field.length; j++) {
                                if (
                                    field[j].FieldName === field[i].childField
                                ) {
                                    console.log(
                                        "this.fieldsData.FieldName >>>>>",
                                        field[j].FieldName,
                                        "::disabled::",
                                        field[j].disabled
                                    );
                                    field[j].disabled = false;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    handleSaveThroughLms(values) {
        console.log('values to save through Lms ', JSON.stringify(values));
        //if(values.recordId===this.recordId ){
            this.handleSave(values.validateBeforeSave);
        //}
    }

    handleSave(validate) {
        console.log('handleSaveCalled in CustomConfig');
        if(validate){
            let isInputCorrect = true;

            let allChilds = this.template.querySelectorAll(
                "c-config-custom-child-form"
            );
            allChilds.forEach((child) => {
                //isInputCorrect = child.reportValidity();
                console.log(" from main parent>>>", child);
                console.log("isInputCorrect>>>", isInputCorrect);
                if (!child.reportValidity()) {
                    child.reportValidity();
                    isInputCorrect = false;
                    console.log("isInputCorrect if false>>>", isInputCorrect);
                    // const event = new ShowToastEvent({
                    //     title: "error",
                    //     message:
                    //         "Record Insertion Failed. Please Enter Data Correctly!!",
                    //     variant: "error",
                    //     mode: "sticky"
                    // });
                    // this.dispatchEvent(event);
                    //return;
                }
            });
    
            if (isInputCorrect === true) {
                console.log("this.allData2>>>>>", JSON.stringify(this.allData));
                this.createRec();
              
            }
        }
       else{
        this.createRec();
       }
    }
createRec(){
  //From This Method we are Creating Record
  mapAndInsertData({
    dataMap: this.allData,
    objname: this.objectName
})
    .then((result) => {
        console.log("result>>>>>", result);
        const event = new ShowToastEvent({
            title: "success",
            message: this.label.ConfiCustomForm_SuccessMessage,
            variant: "success",
            mode: "dismissable"
        });
        this.dispatchEvent(event);
    })
    .catch((error) => {
        console.log("error>>>>>", error);
        const event = new ShowToastEvent({
            title: "error",
            message:
                this.label.ConfiCustomForm_ErrorMessage + error.body.message,
            variant: "error",
            mode: "sticky"
        });
        this.dispatchEvent(event);
    });
}
    handleValueSelect(event) {
        this.lookupRec = event.detail;
        console.log("this.lookupRec>>>>>", this.lookupRec);

        let lookupId = this.lookupRec.id;
        console.log("lookupId>>>", lookupId);
        let lookupAPIName = this.lookupRec.lookupFieldAPIName;

        const outputObj = { [lookupAPIName]: lookupId };
        console.log("outputObj>>>", outputObj);
        Object.assign(this.allData, outputObj);
        console.log(
            "Data with lookup object>>>>>",
            JSON.stringify(this.allData)
        );

        //let objName = this.ParentObjAPINme;
        //  console.log('objName>>>>>>',objName);
    }
}