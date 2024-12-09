import { LightningElement, api } from "lwc";
import getData from "@salesforce/apex/SObjectDynamicRecordProvider.getSobjectData";
export default class ViewDocument extends LightningElement {
  @api documentDetailId;
  @api hasDocumentId;
  @api contVersDataList;
  childRecords;
  listOfConVerDocIds = [];
  parentRecsOfConVer;
  contDocType;
  contDocId;
  count = 0;
  disableForPre;
  disableForNext;
  lengthOfRecs;
  RecordForPrev;

  connectedCallback() {
    console.log("documentIdYes" + this.documentDetailId);
    if (this.hasDocumentId == true) {
      console.log("documentDetailId" + this.documentDetailId);
      let params = {
        ParentObjectName: "ContentDocumentLink",
        ChildObjectRelName: "",
        parentObjFields: ["ContentDocumentId", "LinkedEntityId"],
        childObjFields: [],
        queryCriteria: " where LinkedEntityId= '" + this.documentDetailId + "'"
      };
      getData({ params: params })
        .then((data) => {
          this.parentRecords = JSON.parse(JSON.stringify(data.parentRecords));
          var listOfContentDocumentIds = [];
          for (const record of this.parentRecords) {
            listOfContentDocumentIds.push(record.ContentDocumentId);
          }

          if (listOfContentDocumentIds.length > 0) {
            this.contentVerRecords(listOfContentDocumentIds);
          }
        })
        .catch((error) => {
          console.log("Errorured11111:- ",  error);
          this.disableForPre = true;
          this.disableForNext = true;
        });
    } else {
      this.listOfConVerDocIds = this.contVersDataList;
      this.lengthOfRecs = this.contVersDataList.length;
      this.RecordForPrev = this.contVersDataList[this.count];
      this.contDocId = this.RecordForPrev.contDocId;
      this.contDocType = this.RecordForPrev.FileExtension;
      this.cvId = this.RecordForPrev.Id;
      if (this.lengthOfRecs == 1) {
        this.disableForPre = true;
        this.disableForNext = true;
      } else {
        this.disableForPre = true;
        this.disableForNext = false;
      }
    }
  }
  contentVerRecords(listOfContentDocumentIds) {
    let paramsForCon = {
      ParentObjectName: "ContentVersion",
      ChildObjectRelName: "",
      parentObjFields: ["Id", "ContentDocumentId", "FileExtension"],
      childObjFields: [],
      queryCriteria:
        " WHERE ContentDocumentId IN ('" +
        listOfContentDocumentIds.join("', '") +
        "')"
    };
    const contentVersionMap = new Map();
    getData({ params: paramsForCon })
      .then((data) => {
        console.log("????????????????????????" + JSON.stringify(data));
        this.parentRecsOfConVer = JSON.parse(
          JSON.stringify(data.parentRecords)
        );
        for (const record of this.parentRecsOfConVer) {
          let DocIdExtTypeObj = {
            contDocType: record.FileExtension,
            contDocId: record.ContentDocumentId,
            Id: record.Id
          };
          this.listOfConVerDocIds.push(DocIdExtTypeObj);
        }
        this.lengthOfRecs = this.listOfConVerDocIds.length;
        this.RecordForPrev = this.listOfConVerDocIds[this.count];
        console.log("this.RecordForPrev" + JSON.stringify(this.RecordForPrev));
        this.contDocId = this.RecordForPrev.contDocId;
        this.contDocType = this.RecordForPrev.FileExtension;
        this.cvId = this.RecordForPrev.Id;
        if (this.lengthOfRecs == 1) {
          this.disableForPre = true;
          this.disableForNext = true;
        } else {
          this.disableForPre = true;
          this.disableForNext = false;
        }

        //console.log('mappppp>>'+JSON.stringify(this.listOfConVerDocIds))
      })
      .catch((error) => {
        console.log("Errorured3333:- " + error);
      });
  }
  handlePreviousFileView(event) {
    this.count--;
    console.log("RecordForPrev" + this.count);
    this.RecordForPrev = this.listOfConVerDocIds[this.count];
    //console.log('RecordForPrev'+JSON.stringify(RecordForPrev))
    this.contDocId = this.RecordForPrev.contDocId;
    this.contDocType = this.RecordForPrev.FileExtension;
    this.cvId = this.RecordForPrev.Id;
    if (this.count == 0) {
      this.disableForPre = true;
      this.disableForNext = false;
    } else {
      this.disableForPre = false;
      this.disableForNext = false;
    }
  }
  handleNextFileView(event) {
    this.count++;
    console.log("RecordForPrev" + this.count);
    console.log("this.lengthOfRecs" + this.lengthOfRecs);
    this.RecordForPrev = this.listOfConVerDocIds[this.count];
    this.contDocId = this.RecordForPrev.contDocId;
    this.contDocType = this.RecordForPrev.FileExtension;
    this.cvId = this.RecordForPrev.Id;
    if (this.count === this.lengthOfRecs - 1) {
      this.disableForPre = false;
      this.disableForNext = true;
    } else {
      this.disableForPre = false;
      this.disableForNext = false;
    }
  }
  handleCloseModalEvent(event) {
    console.log("jjjjjjjj");
    var selectedEvent = new CustomEvent("closepreview");
    this.dispatchEvent(selectedEvent);
  }
  closeModal() {
    var selectedEvent = new CustomEvent("closepreview");
    this.dispatchEvent(selectedEvent);
  }
}