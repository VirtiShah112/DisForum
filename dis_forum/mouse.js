function AL(element, on) {
		element.style.textDecoration = 'underline';
		window.status = element.href;
		
}
function BL(element, on) {
		element.style.textDecoration = 'none';
		window.status = element.href;
}

function eConf() {
var a = document.myform.body.value;
document.myform.body.value =  a + " :confused:";
}
function eCry() {
var a = document.myform.body.value;
document.myform.body.value =  a + " :cry:";
}
function eHappy() {
var a = document.myform.body.value;
document.myform.body.value =  a + " :happy:";
}
function eHate() {
var a = document.myform.body.value;
document.myform.body.value =  a + " :hate:";
}
function eMad() {
var a = document.myform.body.value;
document.myform.body.value =  a + " :mad:";
}

function chkFrm() {
	var bReturn = true;
	var a = document.myform.name.value;
	var b = document.myform.email.value;
	var c = document.myform.subject.value;
	var d = document.myform.body.value; 
	
	if (a == "")
	{
		bReturn = false;
		document.myform.name.focus();
		alert('Your name is required !');
	}
	else if (b == "")
	{
		bReturn = false;
		document.myform.email.focus();
		alert('Your E-mail address is required !');
	}
	else if (c == "")
	{
		bReturn = false;
		document.myform.subject.focus();
		alert('The Subject field is required !');
	}
	else if (d == "")
	{
		bReturn = false;
		document.myform.body.focus();
		alert('You can not submit an empty message !');
	}

	return bReturn;
}