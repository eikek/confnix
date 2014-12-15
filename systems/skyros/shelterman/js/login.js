$(function() {
    $.ajax("/api/verify/cookie", {
        success: function(xhr,status,error) {
            document.location = "";
        }
    });

    $("#loginform").submit(function(ev) {
        $.ajax("/api/verify/form", {
            type: "POST",
            data: $("#loginform").serialize(),
            error: function(xhr,status,error) {
                $("#error-msg").message();
            },
            success: function(data, status, xhr) {
                document.location = "/";
            }
        });
        ev.preventDefault();
        return false;
    });
});
