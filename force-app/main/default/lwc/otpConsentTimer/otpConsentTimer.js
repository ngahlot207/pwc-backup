import { LightningElement,api } from 'lwc';
import generateNewOtp from '@salesforce/apex/CreateLeadController.generateNewOtp';
import OTPTimer from '@salesforce/label/c.OTP_Timer';

export default class OtpConsentTimer extends LightningElement {
    @api generatedotp;

    intervalId;
    timeLeft = OTPTimer;
    otpTimerValue;
    isTimeLeftZero = false;

    connectedCallback(){
        this.startTimer();
    }

    startTimer(){
      
             this.intervalId = setInterval(() => {
             if (this.timeLeft > 0) {
                 var minutes = Math.floor(this.timeLeft / 60);
                 var seconds = this.timeLeft % 60;
                 minutes = String(minutes).padStart(2, '0');
                 seconds = String(seconds).padStart(2, '0');
                 this.otpTimerValue = minutes+':'+seconds;
                 this.timeLeft--;
             } else {
                this.isTimeLeftZero = true;
                 clearInterval(this.intervalId);
             }
         }, 1000);
     }

     handleResend(){
        generateNewOtp()
        .then(response=>{this.generatedotp=response})
     }
     
}