$(function() {
	$('details').details();

	$('form input[type=submit]').on('click', function() {
		var spinner_opts = { left: "85%" };
		var spinner = new Spinner(spinner_opts).spin();

		var message_elem = $('#wait-message');
		message_elem.show();
		message_elem.append(spinner.el);

		return true;
	});
});


// Licensed under the ISC licence, see LICENCE.ISC for details
