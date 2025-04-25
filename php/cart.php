<?php
$pageTitle = "Shopping Cart";
// Use Bootstrap 5 styles here if the original cart.html used them
include 'includes/header.php';
?>

<div class="container cart-page-container my-5">
  <h1 class="text-center cart-header mb-4">Your Shopping Cart</h1>

  <div id="cart-items-container">
    <!-- Cart items will be dynamically injected here by JS -->
    <p class="text-center" id="cart-empty-message">Your cart is currently empty.</p>
    <!-- Structure for items (will be cloned by JS) -->
    <div class="row cart-item align-items-center d-none" id="cart-item-template"> <!-- Added align-items-center -->
        <div class="col-md-2 col-4 text-center">
           <!-- JS will set src using path like ../images/c1.png -->
          <img src="" alt="Product Image" class="img-fluid cart-item-image">
        </div>
        <div class="col-md-3 col-8 cart-item-details">
          <h5 class="cart-item-name mb-1">Product Name</h5> <!-- Reduced margin -->
          <p class="cart-item-price mb-0">Price: $0.00</p> <!-- Reduced margin -->
        </div>
        <div class="col-md-3 col-6 mt-2 mt-md-0 cart-item-quantity">
          <div class="input-group quantity-group">
            <button class="btn btn-outline-secondary btn-sm quantity-decrease" type="button">-</button>
            <input type="text" class="form-control form-control-sm text-center quantity-input" value="1" readonly aria-label="Item quantity">
            <button class="btn btn-outline-secondary btn-sm quantity-increase" type="button">+</button>
          </div>
        </div>
        <div class="col-md-2 col-3 mt-2 mt-md-0 text-right cart-item-subtotal">
          <p class="mb-0">$0.00</p> <!-- Reduced margin -->
        </div>
        <div class="col-md-2 col-3 mt-2 mt-md-0 text-right cart-item-remove">
          <button class="btn btn-danger btn-sm remove-item-btn" aria-label="Remove item">Remove</button>
        </div>
    </div>
     <hr class="d-none cart-item-divider"> <!-- Divider template -->
  </div>

  <div class="total-section text-right mt-4">
    <h4>Total: $<span id="cart-total">0.00</span></h4>
    <button class="btn btn-primary btn-lg mt-2" id="checkout-button" disabled>Checkout</button>
    <a href="index.php" class="btn btn-secondary mt-2">Continue Shopping</a>
  </div>
</div>

<?php include 'includes/footer.php'; ?>
