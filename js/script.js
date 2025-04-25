// Wrap all code in a function to avoid global scope pollution
(function() {
    'use strict'; // Enable strict mode

    /**
     * Smooth Scrolling for Anchor Links
     */
    function smoothScroll() {
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function(e) {
                const targetId = this.getAttribute('href');
                // Ensure it's a valid internal link and not just '#'
                if (targetId && targetId.length > 1 && targetId.startsWith('#')) {
                    try { // Add try-catch for robustness
                        const targetElement = document.querySelector(targetId);
                        if (targetElement) {
                            e.preventDefault();
                            targetElement.scrollIntoView({
                                behavior: 'smooth',
                                block: 'start' // Align to top
                            });
                        } else {
                             console.warn('Smooth scroll target not found:', targetId);
                        }
                    } catch (error) {
                        console.error('Error during smooth scroll:', error);
                    }
                }
            });
        });
    }

    /**
     * Back to Top Button Visibility
     */
    function handleScrollButton() {
        const backToTopButton = document.querySelector('.scroll-to-top-arrow');
        if (!backToTopButton) return; // Exit if button not found

        window.addEventListener('scroll', () => {
            if (window.pageYOffset > 300) { // Show after scrolling 300px
                backToTopButton.classList.add('visible');
            } else {
                backToTopButton.classList.remove('visible');
            }
        });

        // Add smooth scroll to top on click
        backToTopButton.addEventListener('click', (e) => {
            e.preventDefault();
            window.scrollTo({
                top: 0,
                behavior: 'smooth'
            });
        });
    }

    /**
     * Simple Slider Functionality (If not using Bootstrap Carousel)
     * Kept for compatibility if original HTML structure is still used elsewhere.
     */
    function initializeSimpleSliders() {
        const sliders = document.querySelectorAll('.slider'); // Target original slider class

        sliders.forEach(slider => {
            let slideIndex = 0;
            const slidesContainer = slider.querySelector('.slides');
            // Check if essential elements exist before proceeding
            if (!slidesContainer) return;
            const slides = slider.querySelectorAll('.slide');
            if (!slides || slides.length === 0) return;

            const totalSlides = slides.length;
            const prevButton = slider.querySelector('.prev');
            const nextButton = slider.querySelector('.next');

            if (!prevButton || !nextButton) {
                 console.warn("Original '.slider' missing prev/next buttons, skipping control init.", slider);
                 // Slider might still display but won't be controllable
            }

            console.log(`Initializing original slider for:`, slider); // Debug log

            function showSlide(index) {
                // Boundary checks
                 let newIndex = index;
                 if (index >= totalSlides) {
                    newIndex = 0;
                 } else if (index < 0) {
                    newIndex = totalSlides - 1;
                 }
                 slideIndex = newIndex; // Update the global slideIndex for this slider instance
                 slidesContainer.style.transform = `translateX(${-slideIndex * 100}%)`;
            }

            function nextSlide() {
                showSlide(slideIndex + 1);
            }

            function prevSlide() {
                showSlide(slideIndex - 1);
            }

            if(prevButton && nextButton) {
                nextButton.addEventListener('click', nextSlide);
                prevButton.addEventListener('click', prevSlide);

                // Auto-slide (optional) - only if buttons exist
                let autoSlideInterval = setInterval(nextSlide, 5000);

                // Pause on hover (optional)
                slider.addEventListener('mouseenter', () => clearInterval(autoSlideInterval));
                slider.addEventListener('mouseleave', () => autoSlideInterval = setInterval(nextSlide, 5000));
            }

            // Initial display
            showSlide(slideIndex);
        });
    }


     /**
      * Bootstrap Form Validation Activation
      */
     function activateBootstrapValidation() {
         // Fetch all the forms we want to apply custom Bootstrap validation styles to
         var forms = document.querySelectorAll('.needs-validation');

         // Loop over them and prevent submission if invalid
         Array.prototype.slice.call(forms)
             .forEach(function (form) {
                 form.addEventListener('submit', function (event) {
                     if (!form.checkValidity()) {
                         event.preventDefault();
                         event.stopPropagation();
                     }
                     form.classList.add('was-validated');
                 }, false);
             });
     }

     /**
      * Login Form Handler (Simple Example)
      */
     function handleLoginForm() {
         const loginForm = document.getElementById('loginForm');
         if (loginForm) {
             loginForm.addEventListener('submit', function (event) {
                 // Prevent default regardless, handle submission via JS or let validation prevent
                 event.preventDefault();
                 if (!loginForm.checkValidity()) {
                     event.stopPropagation();
                     // Ensure validation styles are applied if submit is clicked
                     loginForm.classList.add('was-validated');
                     return;
                 }

                 const email = document.getElementById('email').value;
                 const password = document.getElementById('password').value;

                 // --- Replace with actual AJAX/backend validation ---
                 console.log("Attempting login with:", email); // Log attempt
                 // Example simple check:
                 if (email === "admin@example.com" && password === "password123") {
                     alert("Login successful! Redirecting...");
                     // Redirect to a logged-in area or homepage
                     window.location.href = "index.php"; // Redirect to PHP homepage
                 } else {
                     alert("Invalid email or password. Please try again.");
                     loginForm.classList.remove('was-validated'); // Reset validation state on failure
                     document.getElementById('password').value = ''; // Clear password
                     document.getElementById('email').focus(); // Focus email
                 }
                 // --- End Example Check ---
             });
         }
     }

     /**
      * Signup Form Handler (Simple Example with Password Match)
      */
    function handleSignupForm() {
        const signupForm = document.getElementById('signupForm');
        if (signupForm) {
            const passwordInput = document.getElementById('password');
            const confirmPasswordInput = document.getElementById('confirmPassword');
            const mismatchFeedback = document.getElementById('passwordMismatch'); // The specific feedback div for mismatch
            const confirmFeedback = document.getElementById('confirmPasswordFeedback'); // Generic feedback for confirm field

            const validatePasswordMatch = () => {
                 const pass1 = passwordInput.value;
                 const pass2 = confirmPasswordInput.value;
                 // Check if confirm field is non-empty and doesn't match
                 if (pass2 && pass1 !== pass2) {
                    confirmPasswordInput.setCustomValidity("Passwords do not match."); // Set validity message
                    mismatchFeedback.style.display = 'block'; // Show custom message
                    confirmFeedback.style.display = 'none'; // Hide default required message
                    confirmPasswordInput.classList.add('is-invalid'); // Force invalid state visually
                    return false;
                 } else {
                    confirmPasswordInput.setCustomValidity(""); // Clear custom validity
                    mismatchFeedback.style.display = 'none'; // Hide custom message
                    // Let standard required validation handle display of confirmFeedback if pass2 is empty
                    confirmPasswordInput.classList.remove('is-invalid'); // Remove invalid state if they match or confirm is empty
                    return true;
                 }
            };

            // Add event listeners for real-time validation
            confirmPasswordInput.addEventListener('input', validatePasswordMatch);
            passwordInput.addEventListener('input', validatePasswordMatch); // Check when main pass changes too

            signupForm.addEventListener('submit', function (event) {
                event.preventDefault(); // Prevent submission initially

                // Manually trigger password match validation first
                const passwordsMatch = validatePasswordMatch();

                 // Then check overall form validity (including password match via setCustomValidity)
                if (!signupForm.checkValidity() || !passwordsMatch) {
                     event.stopPropagation();
                     signupForm.classList.add('was-validated'); // Ensure styles apply
                     if (!passwordsMatch && confirmPasswordInput.value) { // Only focus if confirm has value and mismatch
                        confirmPasswordInput.focus();
                     }
                     return; // Stop if basic validation fails or passwords don't match
                 }

                // If all validation passes
                const name = document.getElementById('name').value;
                const email = document.getElementById('email').value;

                // --- Replace with actual backend registration ---
                console.log("Attempting signup for:", name, email);
                alert(`Signup successful! Welcome, ${name}! Redirecting to login...`);
                window.location.href = "login.php"; // Redirect to login page
                // --- End Example Action ---
            });
        }
    }


     /**
      * Order Form Handler (Simple Example)
      */
     function handleOrderForm() {
         const orderForm = document.getElementById('orderForm');
         if (orderForm) {
             orderForm.addEventListener('submit', function(event) {
                 // Let Bootstrap validation handle basic checks first
                 if (!orderForm.checkValidity()) {
                     // Prevent submission if basic validation fails
                     // Bootstrap's was-validated class handles feedback
                     event.preventDefault();
                     event.stopPropagation();
                     console.log("Order form client-side validation failed.");
                     // Find first invalid element and focus it? Optional.
                     const firstInvalid = orderForm.querySelector(':invalid');
                     if (firstInvalid) {
                         firstInvalid.focus();
                     }
                     return;
                 }
                  // If validation passes, allow the form to submit via standard POST
                  // to the PHP script specified in the form's action attribute.
                  console.log("Order form validated client-side. Submitting for server processing...");
             });
         }
     }


    /**
     * Simple Client-Side Shopping Cart using localStorage
     */
    const CART_STORAGE_KEY = 'sweetSliceCart';

    function getCart() {
        const cartJson = localStorage.getItem(CART_STORAGE_KEY);
        try {
            // Ensure we always return an array
            const parsed = cartJson ? JSON.parse(cartJson) : [];
            return Array.isArray(parsed) ? parsed : [];
        } catch (e) {
            console.error("Error parsing cart from localStorage", e);
            localStorage.removeItem(CART_STORAGE_KEY); // Clear corrupted data
            return []; // Return empty cart on error
        }
    }

    function saveCart(cart) {
        // Ensure cart is always an array before saving
        if (!Array.isArray(cart)) {
            console.error("Attempted to save non-array to cart storage.");
            cart = []; // Reset to empty array if corrupted
        }
        localStorage.setItem(CART_STORAGE_KEY, JSON.stringify(cart));
        renderCart(); // Re-render whenever cart is saved
    }

    // Function called by "Add Cart" buttons on index.php
    // Ensure the image path passed here includes '../images/' prefix from PHP
    // Make globally accessible for onclick handlers
    window.addToCart = function(id, name, price, imagePath) {
        // Basic type checking for arguments
        if (typeof id !== 'number' || typeof name !== 'string' || typeof price !== 'number' || typeof imagePath !== 'string') {
             console.error('addToCart called with invalid argument types:', {id, name, price, imagePath});
             alert('Could not add item to cart due to an error.');
             return;
         }
         if (isNaN(price) || price < 0) {
             console.error('addToCart called with invalid price:', price);
             alert('Could not add item with invalid price.');
             return;
         }

        let cart = getCart();
        const existingItemIndex = cart.findIndex(item => item.id === id);

        if (existingItemIndex > -1) {
            // Item exists, increase quantity
            cart[existingItemIndex].quantity += 1;
        } else {
            // Item doesn't exist, add new item
            cart.push({ id, name, price, quantity: 1, image: imagePath }); // Store the full path provided by PHP
        }
        saveCart(cart);
        alert(`${name} added to cart!`); // Simple feedback
        // updateCartIndicator(); // Optional: Update a visual indicator
    }

    function updateCartItemQuantity(index, change) {
        let cart = getCart();
        // Ensure index is valid
        if (cart[index]) {
            cart[index].quantity += change;
            if (cart[index].quantity < 1) {
                cart[index].quantity = 1; // Minimum quantity is 1
            }
            saveCart(cart);
        } else {
            console.error("Attempted to update quantity for invalid index:", index);
        }
    }

    function removeCartItem(index) {
        let cart = getCart();
         // Ensure index is valid
        if (cart[index]) {
            const removedItemName = cart[index].name;
            cart.splice(index, 1); // Remove item from array
            saveCart(cart);
            alert(`${removedItemName} removed from cart.`);
        } else {
             console.error("Attempted to remove item for invalid index:", index);
        }
    }

    function renderCart() {
        const cartItemsContainer = document.getElementById("cart-items-container");
        const cartTotalElement = document.getElementById("cart-total");
        const checkoutButton = document.getElementById("checkout-button");
        const emptyMessage = document.getElementById("cart-empty-message");
        const itemTemplate = document.getElementById("cart-item-template");
        const dividerTemplate = document.querySelector(".cart-item-divider"); // Get the template element

        // Only run if we are on the cart page
        if (!cartItemsContainer || !cartTotalElement || !checkoutButton || !emptyMessage || !itemTemplate || !dividerTemplate) {
            return;
        }

        const cart = getCart();
        // Clear only the dynamic items, not the templates or message
        cartItemsContainer.querySelectorAll('.cart-item:not(#cart-item-template), .cart-item-divider:not(.d-none)').forEach(el => el.remove());

        let total = 0;

        if (cart.length === 0) {
            emptyMessage.style.display = 'block';
            checkoutButton.disabled = true;
        } else {
            emptyMessage.style.display = 'none';
            checkoutButton.disabled = false;

            cart.forEach((item, index) => {
                // Basic validation for item structure
                if (!item || typeof item.id === 'undefined' || !item.name || typeof item.price !== 'number' || typeof item.quantity !== 'number' || !item.image) {
                    console.error("Invalid item found in cart at index", index, item);
                    return; // Skip rendering this invalid item
                }

                const itemTotal = item.price * item.quantity;
                total += itemTotal;

                const cartItemNode = itemTemplate.cloneNode(true);
                cartItemNode.classList.remove('d-none'); // Make visible
                cartItemNode.removeAttribute('id'); // Remove template ID

                // Safely query selectors within the cloned node
                const imgEl = cartItemNode.querySelector(".cart-item-image");
                const nameEl = cartItemNode.querySelector(".cart-item-name");
                const priceEl = cartItemNode.querySelector(".cart-item-price");
                const quantityInput = cartItemNode.querySelector(".quantity-input");
                const subtotalEl = cartItemNode.querySelector(".cart-item-subtotal p");
                const decreaseBtn = cartItemNode.querySelector(".quantity-decrease");
                const increaseBtn = cartItemNode.querySelector(".quantity-increase");
                const removeBtn = cartItemNode.querySelector(".remove-item-btn");

                if (imgEl) {
                     // Use the path directly from the cart data (e.g., '../images/c1.png')
                    imgEl.src = item.image;
                    imgEl.alt = item.name;
                }
                if (nameEl) nameEl.textContent = item.name;
                if (priceEl) priceEl.textContent = `Price: $${item.price.toFixed(2)}`;
                if (quantityInput) quantityInput.value = item.quantity;
                if (subtotalEl) subtotalEl.textContent = `$${itemTotal.toFixed(2)}`;

                // Add event listeners safely
                if (decreaseBtn) decreaseBtn.addEventListener('click', () => updateCartItemQuantity(index, -1));
                if (increaseBtn) increaseBtn.addEventListener('click', () => updateCartItemQuantity(index, 1));
                if (removeBtn) removeBtn.addEventListener('click', () => removeCartItem(index));

                cartItemsContainer.appendChild(cartItemNode);

                 // Add divider after each item except the last
                if (index < cart.length - 1 && dividerTemplate) {
                   const dividerNode = dividerTemplate.cloneNode(true);
                   dividerNode.classList.remove('d-none'); // Make divider visible
                    cartItemsContainer.appendChild(dividerNode);
                }
            });
        }

        if(cartTotalElement) cartTotalElement.textContent = total.toFixed(2);
    }

    function handleCheckout() {
        const checkoutButton = document.getElementById('checkout-button');
        if (checkoutButton) {
            checkoutButton.addEventListener('click', () => {
                const cart = getCart();
                if (cart.length === 0) {
                    alert("Your cart is empty!");
                    return;
                }

                // Simple checkout simulation
                const totalValue = document.getElementById('cart-total').textContent;
                alert(`Proceeding to checkout simulation for ${cart.length} item(s). Total: $${totalValue}\nThank you for your purchase!`);

                // Clear the cart after "checkout"
                localStorage.removeItem(CART_STORAGE_KEY);
                renderCart(); // Update display to show empty cart
            });
        }
    }

    /**
     * Initialize all components when the DOM is ready
     */
    document.addEventListener('DOMContentLoaded', () => {
        smoothScroll();
        handleScrollButton();
        initializeSimpleSliders(); // Run if you have non-Bootstrap sliders
        activateBootstrapValidation();
        handleLoginForm();
        handleSignupForm();
        handleOrderForm();

        // Cart specific initialization only if on cart page
        if (document.getElementById('cart-items-container')) {
           renderCart();
           handleCheckout();
        }

        console.log("SweetSlice JS Initialized");
    });

})(); // Immediately Invoked Function Expression (IIFE)
