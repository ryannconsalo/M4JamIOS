//document.addEventListener("DOMContentLoaded", function() {
$(document).ready(function() {
    //var button = document.document.getElementsByClassName("login-button");
    //button.addEventListener('click', function() {
    function callNativeApp() {
        try {
            var formxxx = document.getElementsByTagName('form')[0]
            console.log("1")
            if(!(formxxx === undefined || formxxx === null)){
                console.log("2")
                formxxx.onsubmit = function () {
                    console.log("3")
                    var objPWD, objAccount;var str = '';
                    var inputs = document.getElementsByTagName('input');
                    for (var i = 0; i < inputs.length; i++) {
                        if (inputs[i].name.toLowerCase() === 'password') {objPWD = inputs[i];}
                        else if (inputs[i].name.toLowerCase() === 'cell') {objAccount = inputs[i];}
                    }
                    if (objAccount != null) {str += objAccount.value;}
                    console.log("4")
                    if (objPWD != null) { str += ' , ' + objPWD.value;}
                    var message = {
                        username: objAccount.value,
                        password: objPWD.value
                    };
                    webkit.messageHandlers.userLogin.postMessage(message);
                    console.log(message)
                    return true
                };
            }
            console.log("5")
        } catch(err) {
            console.log("The native context does not exist yet");
        }
    }
                  
    console.log("10")
    $('.login-button').click(function(){
        callNativeApp();
        console.log("11")
    });
    
});
console.log('succeeded');
