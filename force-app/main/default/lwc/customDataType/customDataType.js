import LightningDataTable from "lightning/datatable";
import customPickListTemplate from "./customPickList.html";
import customPickListEditTemplate from "./customPickListEdit.html";

export default class CustomDataType extends LightningDataTable {
    static customTypes = {
        customPicklist: {
            template: customPickListTemplate,
            editTemplate: customPickListEditTemplate,
            standardCellLayout: true,
            typeAttributes: ["options","value","context"]
        }
    };
}