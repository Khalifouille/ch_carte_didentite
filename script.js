window.addEventListener('message', function(event) {
    console.log('Message reçu:', event.data);
    if (event.data.type === "showIdentity") {
        const nameElement = document.getElementById("name");
        const surnameElement = document.getElementById("surname");
        const dobElement = document.getElementById("dob");
        const nationalityElement = document.getElementById("nationality");

        nameElement.innerHTML = event.data.info.name;
        surnameElement.innerHTML = event.data.info.surname;
        dobElement.innerHTML = new Date(event.data.info.dob * 1000).toLocaleDateString('fr-FR');
        nationalityElement.innerHTML = event.data.info.nationality;
        document.getElementById("identityCard").style.display = "block";
        fetch('https://ch_carte_didentite/showCursor', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({})
        });
    }
});

document.addEventListener('DOMContentLoaded', function() {
    const closeButton = document.getElementById("closeButton");
    if (closeButton) {
        closeButton.addEventListener("click", function() {
            document.getElementById("identityCard").style.display = "none";
            fetch('https://ch_carte_didentite/hideCursor', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({})
            });
            fetch(`https://${GetParentResourceName()}/close`, {
                method: 'POST'
            });
        });
    }

    document.addEventListener('keydown', function(event) {
        if (event.key === "Escape") {
            document.getElementById("identityCard").style.display = "none";
            fetch('https://ch_carte_didentite/hideCursor', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({})
            });
            fetch(`https://${GetParentResourceName()}/close`, {
                method: 'POST'
            });
        }
    });
});