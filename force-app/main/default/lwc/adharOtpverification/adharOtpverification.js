import { LightningElement, track, api } from 'lwc';

export default class AdharOtpverification extends LightningElement {
    @track aadharno;
    @track otp;
    @track timeVal = '00:00:00';
    timeIntervalInstance
    totalMilliseconds = 0;
    @track showSpinner = false;
    timerStart = false;
    handleChange(event) {
        let val = event.target.value;
        if (event.target.name == 'aadharno') {
            console.log('aadharno ', this.aadharno);
            this.aadharno = val;
            // this.validation(this.aadharno);
        } else if (event.target.name == 'otp') {
            this.otp = val;
            console.log('otp is===>>>>>>>>>', this.otp);
        }

    }

    // validation(val) {
    //     var regexp = /^[2-9]{1}[0-9]{3}\s{1}[0-9]{4}\s{1}[0-9]{4}$/;
    //     var x = document.getElementById("aadhaar").value;
    //     if (regexp.test(val)) {
    //         window.alert("Valid Aadhar no.");
    //     }
    // }
    handleButtonClick(event) {
        let name = event.target.name;
        var parentThis = this;
        if (name == 'sendotp') {

            this.timerStart = true;
            // Run timer code in every 100 milliseconds
            this.timeIntervalInstance = setInterval(function () {

                // Time calculations for hours, minutes, seconds and milliseconds
                // var hours = Math.floor((parentThis.totalMilliseconds % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                var minutes = Math.floor((parentThis.totalMilliseconds % (1000 * 60 * 60)) / (1000 * 60));
                var seconds = Math.floor((parentThis.totalMilliseconds % (1000 * 60)) / 1000);
                var milliseconds = Math.floor((parentThis.totalMilliseconds % (1000)));

                // Output the result in the timeVal variable
                parentThis.timeVal = minutes + ":" + seconds + ":" + milliseconds;

                parentThis.totalMilliseconds += 100;
            }, 100);
        }

        if (name == 'validateotp') {
            clearInterval(this.timeIntervalInstance);
        }
    }
}