window.addEventListener('message', function(event) {
    if (event.data.type === "showIdentity") {
        document.getElementById("identityInfo").innerHTML = event.data.info;
        document.getElementById("identityCard").style.display = "block";
    }
});

document.getElementById("closeButton").addEventListener("click", function() {
    document.getElementById("identityCard").style.display = "none";
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST'
    });
});
