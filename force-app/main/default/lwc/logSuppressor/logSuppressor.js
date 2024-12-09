import { LightningElement, track } from 'lwc';
import hasPermission from "@salesforce/customPermission/AccessConsoleLogs";


export default class LogSuppressor extends LightningElement {

    connectedCallback(){
        console.log('Do You have log access? !!! '+ hasPermission);
        if(hasPermission && hasPermission === true){
            
        }else{
            console.log = function() {};
        }
    }
}