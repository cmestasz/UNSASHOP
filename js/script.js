const navbarMenu = document.querySelector(".navbar .links");
const hamburgerBtn = document.querySelector(".hamburger-btn");
const hideMenuBtn = navbarMenu.querySelector(".close-btn");
const showPopupBtn = document.querySelector(".login-btn");
const formPopup = document.querySelector(".form-popup");
const hidePopupBtn = formPopup.querySelector(".close-btn");
const signupLoginLink = formPopup.querySelectorAll(".bottom-link a");

//menu responsive para movil
hamburgerBtn.addEventListener("click", () => {
    navbarMenu.classList.toggle("show-menu");
});

//oculta menu para movil
hideMenuBtn.addEventListener("click", () =>  hamburgerBtn.click());

//animacion popup
showPopupBtn.addEventListener("click", () => {
    document.body.classList.toggle("show-popup");
});

//oculta animacion popup
hidePopupBtn.addEventListener("click", () => showPopupBtn.click());

//registrarse muestra y oculta
signupLoginLink.forEach(link => {
    link.addEventListener("click", (e) => {
        e.preventDefault();
        formPopup.classList[link.id === 'signup-link' ? 'add' : 'remove']("show-signup");
    });
});

function redirectToProfile() {
    //lógica de verificación del usuario y contraseña(aun por completar)
    var userEmail = document.querySelector('#loginForm input[type="text"]').value;
    window.location.href = 'perfil.html?user=' + userEmail;
}