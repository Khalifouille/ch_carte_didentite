window.addEventListener('message', function(event) {
    if (event.data.type === "showIdentity") {
        document.getElementById("identityInfo").innerHTML = event.data.info;
        document.getElementById("identityCard").style.display = "block";
        $.post('https://ch_carte_didentite/showCursor', JSON.stringify({}));
    }
});

document.addEventListener('DOMContentLoaded', function() {
    document.getElementById("closeButton").addEventListener("click", function() {
        document.getElementById("identityCard").style.display = "none";
        $.post('https://ch_carte_didentite/hideCursor', JSON.stringify({}));
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST'
        });
    });
});