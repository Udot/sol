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
		hide_str = token_span.replace(/token/i,'hide');
		$("#"+hide_str).toggle();
		$("#"+token_span).toggle().css("color", "#222222");
		if ($(this).hasClass("info")) {
			$(this).html("Hide");
			$(this).removeClass('info');
		} else {
			$(this).html("Show");
			$(this).addClass('info');
		}
	});
	$(function() {
			$(".tipsy_z").tipsy({fade: true, gravity: 'n'});
		});
	//$("#tipsy").tipsy({fade: true, gravity: 's'});
});