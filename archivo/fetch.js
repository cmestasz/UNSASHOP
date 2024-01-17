// params son los id del formulario
// script es la ubicacion del archio perl, tiene que terminar en .pl
// func siempre debe tener el parametro (response)

function fetch2(params, script, func) {
    let xhttp = new XMLHttpRequest();
    let query = "";
    for (let i = 0; i < params.length; i++) {
        try {
            let param_value = document.getElementById(params[i]);
            query += params[i] + "=" + param_value + "&";
        } catch (err) {
            alert ("Error obteniendo " + params[i]);
        }
    }

    xhttp.onreadystatechange = function () {
        if (xhttp.readyState == 4 && xhttp.status == 200) {
            let response = xhttp.responseXML;
            func(response);
        }
    };

    xhttp.open("POST", "./cgi-bin/" + script, true);
    xhttp.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=ISO-8859-1');
    xhttp.send(query);
}