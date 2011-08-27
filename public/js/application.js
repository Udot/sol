$(document).ready(function(){
	$('#submit_user').click(function() {
		if ($("#password1").val() != $("#password2").val()) {
			$("#password2").addClass("error");
			$("#password2").parent().append("<span class=\"help-inline\">Passwords don't match.</span>");
			return false;
		}
	});
	$("#password1").keypress(function() {
	  if ($("#password1").val() != $("#password2").val()) {
			$("#password2").addClass("error");
		} else {
			$("#password2").removeClass("error");
		}
	});
	$("#password2").keypress(function() {
	  if ($("#password1").val() != $("#password2").val()) {
			$("#password2").addClass("error");
		} else {
			$("#password2").removeClass("error");
		}
	});
});