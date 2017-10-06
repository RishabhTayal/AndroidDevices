function clapClicked(device_id) {
	console.log('clap click');
	var button = document.getElementById('clap-button-'+ device_id);
	$.post('/clap', { device_id: device_id}).done(function(result) {
		button.innerHTML = result["claps_count"];
	}).fail(function() {

	});
};