window.sdkAsyncInit = function() {
	var res = new EDMUNDSAPI('fhqnyq25f2xsr7f8p4aagk27');
	var options = {};
			// Callback function to be called when the API response is returned
	function success(res) {
		var manufacturer = document.getElementById("manufacturer");
		for (var i = 0; i < res.makes.length; i++){
			var opt = document.createElement("option");
			opt.value = res.makes[i].name;
			opt.innerHTML = res.makes[i].name;
			manufacturer.appendChild(opt);
		}
	}
			// Oops, Houston we have a problem!
	function fail(data) {
		console.log(data);
	}
	res.api('/api/vehicle/v2/makes', options, success, fail);
};
(function(d, s, id){
	var js, sdkjs = d.getElementsByTagName(s)[0];
	if (d.getElementById(id)) {return;}
	js = d.createElement(s); js.id = id;
	js.src = "assets/js/edmunds.api.sdk.js";
	    sdkjs.parentNode.insertBefore(js, sdkjs);	   
	}(document, 'script', 'edmunds-jssdk'));


function populateModelField(sel){
	var model = document.getElementById("model");
	console.log(sel.value);
	var res = new EDMUNDSAPI('fhqnyq25f2xsr7f8p4aagk27');
	var options = {};
			// Callback function to be called when the API response is returned
	function success(res) {
		enableField(model);
		model.options.length = 1;
		for (var i = 0; i < res.models.length; i++){
			var opt = document.createElement("option");
			opt.value = res.models[i].name;
			opt.innerHTML = res.models[i].name;
			model.appendChild(opt);
		}
	}
	function fail(data) {
		console.log(data);
	}
	res.api('/api/vehicle/v2/'+ sel.value, options, success, fail);
}

function populateDateField(sel){
	var model = document.getElementById("expiry-year");
	console.log(sel.value);
	var res = new EDMUNDSAPI('fhqnyq25f2xsr7f8p4aagk27');
	var options = {};
			// Callback function to be called when the API response is returned
	function success(res) {
		enableField(model);
		model.options.length = 1;
		for (var i = 0; i < res.models.length; i++){
			var opt = document.createElement("option");
			opt.value = res.models[i].name;
			opt.innerHTML = res.models[i].name;
			model.appendChild(opt);
		}
	}
	function fail(data) {
		console.log(data);
	}
	res.api('/api/vehicle/v2/'+ sel.value, options, success, fail);
}

function enableField(id){
	id.disabled = false;
}

function checkDetails(form){
	var inputs = form.getElementsByTagName('input');
	for (var i = 0; i <inputs.length; i++) {
		if (inputs[i].value == ""){
			alert("Please fill all required fields");
			return false;
		}
	}
	return true;
}

function getUrlParameter(sParam){
    var sPageURL = window.location.search.substring(1);
    var sURLVariables = sPageURL.split('&');
    for (var i = 0; i < sURLVariables.length; i++) 
    {
        var sParameterName = sURLVariables[i].split('=');
        if (sParameterName[0] == sParam) 
        {
            return sParameterName[1];
        }
    }
}