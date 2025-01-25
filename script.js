// JavaScript for SweetSlice Website

// Smooth scrolling for navbar links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener("click", function (e) {
        e.preventDefault();
        document.querySelector(this.getAttribute("href")).scrollIntoView({
            behavior: "smooth",
        });
    });
});

// Read More button functionality in the About section
document.querySelector("#bt button").addEventListener("click", () => {
    alert("More about SweetSlice coming soon!");
});

// Order Now button functionality in the Home section
document.querySelector(".btn").addEventListener("click", () => {
    alert("Thank you for your interest! Start your order by contacting us.");
});

// Contact form validation
document.querySelector("#messagebtn button").addEventListener("click", () => {
    const name = document.getElementById("user").value.trim();
    const email = document.getElementById("eml").value.trim();
    const phone = document.getElementById("phn").value.trim();
    const message = document.getElementById("comment").value.trim();

    if (!name || !email || !phone || !message) {
        alert("Please fill out all fields before submitting the form.");
    } else if (!validateEmail(email)) {
        alert("Please enter a valid email address.");
    } else {
        alert("Thank you for reaching out! We'll get back to you soon.");
    }
});

// Helper function for email validation
function validateEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(String(email).toLowerCase());
}

// Back to top button functionality
const backToTopButton = document.querySelector(".arrow");
backToTopButton.addEventListener("click", () => {
    window.scrollTo({
        top: 0,
        behavior: "smooth",
    });
});
