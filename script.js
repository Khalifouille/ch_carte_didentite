window.addEventListener('message', function(event) {
    console.log('Message reçu:', event.data);
    if (event.data.type === "showIdentity") {
        var nameElement = document.getElementById("name");
        var surnameElement = document.getElementById("surname");
        var dobElement = document.getElementById("dob");
        var nationalityElement = document.getElementById("nationality");
        
        nameElement.innerHTML = event.data.info.name;
        surnameElement.innerHTML = event.data.info.surname;
        dobElement.innerHTML = new Date(event.data.info.dob * 1000).toLocaleDateString('fr-FR');
        nationalityElement.innerHTML = event.data.info.nationality;
        document.getElementById("identityCard").style.display = "block";
        $.post('https://ch_carte_didentite/showCursor', JSON.stringify({}));
    }
});

document.addEventListener('DOMContentLoaded', function() {
    var closeButton = document.getElementById("closeButton");
    if (closeButton) {
        closeButton.addEventListener("click", function() {
            document.getElementById("identityCard").style.display = "none";
            $.post('https://ch_carte_didentite/hideCursor', JSON.stringify({}));
            fetch(`https://${GetParentResourceName()}/close`, {
                method: 'POST'
            });
        });
    }
});