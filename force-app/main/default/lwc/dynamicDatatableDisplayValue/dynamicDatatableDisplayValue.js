import { LightningElement, api, track } from 'lwc';
import { formattedDateTimeWithoutSeconds } from 'c/dateUtility';
export default class DynamicDatatableDisplayValue extends LightningElement {
    @api object;
    @api fieldName;
    @api type;
    @api editable = false;
    @api label = '';
    @track documentDetailId;
    @track hasDocumentId;
    @track showModalForFilePre;

    get fieldValue() {
        //console.log('object from child:::', JSON.stringify(this.object));
        /*  if (this.label == 'Borrower Name') {
           /*   if (this.fieldName == 'LoanApplicant__r.FName__c') {
                  console.log('Inside LoanApplicant__r.FName__c');
                  console.log('object from child:::', JSON.stringify(this.object));
                  if (this.object.LoanApplicant__r.FName__c && this.object.LoanApplicant__r.LName__c) {
                      
                      let fullName = this.object.LoanApplicant__r.FName__c + this.object.LoanApplicant__r.LName__c;
                      return fullName;
                  }
                  else {
                      return this.object.LoanApplicant__r.FName__c;
                  }
              }
              else {*/
        /*  if (this.object.FName__c && this.object.LName__c) {
              let fullName = this.object.FName__c +' '+ this.object.LName__c;
              return fullName;
          }
          else {
              return this.object.FName__c;
          }
     // }

  }
  else {
      return this.object[this.fieldName];
  } */
        //   ? this.object[this.fieldName] : ''
        let val;
        if (this.type == "Date") {
            if (this.object[this.fieldName]) {
                const rawDate = new Date(this.object[this.fieldName]);
                const day = rawDate.getDate().toString().padStart(2, '0');
                //const month = (rawDate.getMonth() + 1).toString().padStart(2, '0'); // Month is zero-based
                const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                const month = monthNames[rawDate.getMonth()]; // Month is zero-based
                const year = rawDate.getFullYear();
                val = `${day}-${month}-${year}`;
            } else {
                val = this.object[this.fieldName]
            }

            // val =
        }
        else if(this.type == "Date/Time"){
            //console.log('Inside DateTime-->');
            if (this.object[this.fieldName]) {
                const rawDate = new Date(this.object[this.fieldName]);
                const formattedDate1 = formattedDateTimeWithoutSeconds(rawDate); 
                val = formattedDate1;
               // console.log('Report Date-->'+val);
            } else {
                val = this.object[this.fieldName]
            }
           
        }
         else {
            val = this.object[this.fieldName]
        }
        return val;
    }
    get recordId() {
        return this.object['Id'];
    }

    connectedCallback() {
        console.log('type from child:::', this.type);
        console.log('object from child:::', this.object);
        console.log('fieldName from child:::', this.fieldName);
    }
    get stringBoolean() {
        return this.type == "text" ? true : false;
    }
    get numberBoolean() {
        return this.type == "number" ? true : false;
    }

    get urlBoolean() {
        return this.type == "url" ? true : false;
    }
    get phoneBoolean() {
        return this.type == "phone" ? true : false;
    }
    get datetimeBoolean() {
        return this.type == "Date/Time" ? true : false;
    }

    get dateBoolean() {
        return this.type == "Date" ? true : false;
    }

    get emailBooelan() {
        return this.type == "email" ? true : false;
    }
    get nullBoolean() {
        return this.type == null ? true : false;
    }
    //|| this.type == "boolean"
    get editBoolean() {
        return this.type == "boolean" && this.editable ? true : false;
    }
    get readBoolean() {
        return this.type == "boolean" && !this.editable ? true : false;
    }
    get previewBooelan() {
        return this.type == "preview" ? true : false;
    }

    handleClick(event) {
        console.log('value is', event.target.dataset.value);
    }
    handleDocumentView(event) {


        console.log("id is ==> " + event.currentTarget.dataset.documentid);
        this.documentDetailId = event.currentTarget.dataset.documentid;

        const selectedEvent = new CustomEvent("preview", { detail: this.documentDetailId });
        this.dispatchEvent(selectedEvent);


    }
}