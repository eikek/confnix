$(function() {
    $("#setpassform").submit(function(ev) {
        var form = $("#setpassform");
        var pw1 = form.find('[name="newpassword"]').val();
        var pw2 = form.find('[name="newpassword2"]').val();
        if (pw1 && pw1 != "") {
            if (pw1.length <= 7) {
                $("#password-bad-msg").message();
            } else if (pw1 === pw2) {
                $.ajax("/api/setpass/form", {
                    type: "POST",
                    data: $("#setpassform").serialize(),
                    error: function(xhr,status,error) {
                        form.find("input").val("");
                        $("#error-msg").message();
                    },
                    success: function(data, status, xhr) {
                        form.find("input").val("");
                        $("#success-msg").message();
                    }
                });
            } else {
                $("#password-mismatch-msg").message();
            }
        }
        ev.preventDefault();
        return false;
    });

    $.ajax("/api/verify/cookie", {
        error: function(xhr,status,error) {
            document.location = "signin.html?to=/";
        },
        success: function(data) {
            $.getJSON("/api/listapps", function(data) {
                var list1 = $("ul.shelter-app-select");
                var list2 = $("ul.shelter-application-list");
                data.apps.sort(function(a, b) {
                    return a.appname.localeCompare(b.appname);
                });
                $(data.apps).each(function (i, el) {
                    var li1 = '<li><a id="shelter-app-'+el.appid+'" class="shelter-pass-select" href="#">'+el.appname+'</a></li>';
                    $(li1).appendTo(list1);
                    var li2 = '<li><a href="'+el.url+'" target="_blank">'+el.appname+'</a></li>';
                    $(li2).appendTo(list2);
                });

                $(".shelter-pass-select").click(function(ev) {
                    var target = $(ev.target);
                    $("span.shelter-appname").text(target.text());
                    var app = target.attr("id").substring(12);
                    var form = $("#setpassform");
                    form.find('input[type="hidden"]').remove();
                    if (app != "Standard") {
                        $("<input>").attr({
                            type: "hidden",
                            name: "app",
                            value: app
                        }).appendTo(form);
                    }

                    target.parents("ul").find("li").each(function(i, el) { $(el).removeClass("active"); });
                    target.parent().addClass("active");
                    ev.preventDefault();
                    return false;
                });

                //select first
                $("ul.shelter-app-select").find("li a").first().click();
            });
        }
    });
});
