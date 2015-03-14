$(function() {

    function qs(key) {
        key = key.replace(/[*+?^$.\[\]{}()|\\\/]/g, "\\$&"); // escape RegEx meta chars
        var match = location.search.match(new RegExp("[?&]"+key+"=([^&]+)(&|$)"));
        return match && decodeURIComponent(match[1].replace(/\+/g, " "));
    }

    var appid = qs("app");
    $("#loginform").find("input[name='app']").val(appid || "");
    var txt = $("#h1-login").text(function(i, old) {
        if (appid) {
            return old + " - " + appid;
        } else {
            return old;
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
                document.location.href = qs("to");
            }
        });
        ev.preventDefault();
        return false;
    });
});
