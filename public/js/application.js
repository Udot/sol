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
	$(".secretB").click(function () {
		token_span = $(this).attr('rel');
		$("#"+token_span).toggle();
		if ($(this).hasClass("info")) {
			$(this).html("Hide");
			$(this).removeClass('info');
		} else {
			$(this).html("Show");
			$(this).addClass('info');
		}
	});
});