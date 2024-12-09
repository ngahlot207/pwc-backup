import { LightningElement } from 'lwc';

export default class LeadProgressBar extends LightningElement {

    currentStep='step-1'; 

    get currentStage(){
        return this.currentStep;
    }

    steps = [
        { label: 'Basic Details', value: 'Basic Details'},
        { label: 'OTP Verification', value: 'OTP Verification' },
        { label: 'Document Upload', value: 'Document Upload' }
    ];
}