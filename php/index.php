<?php
$pageTitle = "Home";
include 'includes/header.php';
include_once 'lib/database.php'; // Use include_once for db connection

// Fetch data from database
$cake_products = [];
$birthday_products = [];
$gallery_items_index = [];
$db_error = null; // Variable to store potential DB error messages

try {
    $pdo = get_db_connection(); // This will die() if connection fails catastrophically

    if ($pdo) { // Proceed only if connection is successful
        // Fetch 'Cakes' category products
        $stmt_cakes = $pdo->prepare("SELECT * FROM products WHERE category = 'Cakes' ORDER BY id LIMIT 8");
        $stmt_cakes->execute();
        $cake_products = $stmt_cakes->fetchAll();

        // Fetch 'Birthday' category products
        $stmt_birthday = $pdo->prepare("SELECT * FROM products WHERE category = 'Birthday' ORDER BY id LIMIT 4");
        $stmt_birthday->execute();
        $birthday_products = $stmt_birthday->fetchAll();

        // Fetch Gallery items for the 'OUR GALLERY' section (limit 6 for index page)
        $stmt_gallery = $pdo->prepare("SELECT * FROM gallery_items ORDER BY id DESC LIMIT 6"); // Get newest first
        $stmt_gallery->execute();
        $gallery_items_index = $stmt_gallery->fetchAll();
    } else {
        // This case might not be reached if get_db_connection dies on critical failure
         $db_error = "Database connection could not be established.";
    }

} catch (PDOException $e) {
    // Log the error, but don't die. Allow the page to render with empty data.
    error_log("Database query error on index.php: " . $e->getMessage());
    $db_error = "Could not load some page data. Please try again later."; // User-friendly message
}

?>

<!-- Display DB Error if any occurred during fetch -->
<?php if ($db_error): ?>
    <div class="container mt-3">
        <p class="alert alert-warning text-center"><?php echo htmlspecialchars($db_error); ?></p>
    </div>
<?php endif; ?>

<!-- Home Section -->
<section class="home-section">
    <div class="home-background"> <!-- Separate div for background image -->
        <div class="container content-container">
            <div class="row align-items-center">
                <div class="col-md-6 home-content">
                    <h3>Hi<br>Find Your Best Cake<br>With Best Price</h3>
                    <h2>Category <span class="changecontent"></span></h2> <!-- JS will handle changing text -->
                    <a href="order.php" class="btn btn-primary btn-order-now">Order Now</a>
                </div>
                <div class="col-md-6 home-image">
                    <!-- Image path relative to php/ -> ../images/ -->
                    <img src="../images/background.png" alt="Delicious Cake Showcase" class="img-fluid">
                </div>
            </div>
        </div>
    </div>
</section>
<!-- Home Section End -->

<!-- Top Cards -->
<section class="top-cards-section py-5">
    <div class="container" id="box">
        <div class="row">
            <div class="col-md-4 py-3 py-md-0">
                <div class="card top-card">
                    <!-- Image path relative to php/ -> ../images/ -->
                    <img src="../images/box1.jpg" alt="Special Offer 1" class="card-img-top">
                </div>
            </div>
            <div class="col-md-4 py-3 py-md-0">
                <div class="card top-card">
                     <!-- Image path relative to php/ -> ../images/ -->
                    <img src="../images/box2.jpg" alt="Special Offer 2" class="card-img-top">
                </div>
            </div>
            <div class="col-md-4 py-3 py-md-0">
                <div class="card top-card">
                     <!-- Image path relative to php/ -> ../images/ -->
                    <img src="../images/box3.jpg" alt="Special Offer 3" class="card-img-top">
                </div>
            </div>
        </div>
    </div>
</section>
<!-- Top Cards End -->

<!-- Banner -->
<section class="banner-section">
    <div class="banner-background"> <!-- Separate div for background -->
        <div class="container">
             <div class="row align-items-center">
                 <div class="col-md-6 banner-content">
                     <h3>Delicious Cake</h3>
                     <h2>UPTO 50% OFF</h2>
                     <div id="btnorder"><a href="order.php" class="btn btn-primary btn-order-banner">Order Now</a></div>
                 </div>
                 <div class="col-md-6 banner-image">
                     <!-- Optional: Add an image here if needed -->
                     <!-- Image path relative to php/ -> ../images/ -->
                     <!-- <img src="../images/banner-background.avif" alt="" class="img-fluid"> -->
                 </div>
            </div>
        </div>
    </div>
</section>
<!-- Banner End -->

<!-- Product Cards: Cakes -->
<section id="product-cards" class="product-section py-5">
    <div class="container">
        <h1 class="section-title">CAKES</h1>
        <div class="row mt-4">
            <?php if (!empty($cake_products)): ?>
                <?php foreach ($cake_products as $product): ?>
                <div class="col-lg-3 col-md-4 col-sm-6 mb-4">
                    <div class="card product-card h-100">
                        <div class="product-overlay">
                            <!-- Image paths relative to php/ -> ../images/ -->
                           <button type="button" class="btn btn-secondary btn-quick-view" title="Quick View"><i><img src="../images/views.png" alt="" style="width:20px;"></i></button>
                           <button type="button" class="btn btn-secondary btn-wishlist" title="Add to Wishlist"><i><img src="../images/heart.png" alt="" style="width:20px;"></i></button>
                           <!-- Pass correct image path to JS, ensure JS handles ../ -->
                           <button type="button" class="btn btn-secondary btn-add-to-cart" title="Add to Cart" onclick="addToCart(<?php echo $product['id']; ?>, '<?php echo htmlspecialchars(addslashes($product['name']), ENT_QUOTES); ?>', <?php echo $product['price']; ?>, '../images/<?php echo htmlspecialchars($product['image'], ENT_QUOTES); ?>')"><i><img src="../images/add.png" alt="" style="width:20px;"></i></button>
                        </div>
                        <!-- Image path relative to php/ -> ../images/ -->
                        <img src="../images/<?php echo htmlspecialchars($product['image'], ENT_QUOTES); ?>" class="card-img-top product-image" alt="<?php echo htmlspecialchars($product['name']); ?>">
                        <div class="card-body text-center">
                            <h5 class="card-title product-name"><?php echo htmlspecialchars($product['name']); ?></h5>
                            <div class="star-rating">
                                <?php for ($i = 0; $i < 5; $i++): ?>
                                    <i class="bx bxs-star <?php echo ($product['rating'] > $i) ? 'checked' : ''; ?>"></i>
                                <?php endfor; ?>
                            </div>
                            <h6 class="product-price">$<?php echo number_format($product['price'], 2); ?>
                                <!-- Pass correct image path to JS -->
                                <span><button class="btn btn-outline-primary btn-sm btn-add-cart-alt" onclick="addToCart(<?php echo $product['id']; ?>, '<?php echo htmlspecialchars(addslashes($product['name']), ENT_QUOTES); ?>', <?php echo $product['price']; ?>, '../images/<?php echo htmlspecialchars($product['image'], ENT_QUOTES); ?>')">Add Cart</button></span>
                            </h6>
                        </div>
                    </div>
                </div>
                <?php endforeach; ?>
             <?php elseif(!$db_error): // Show only if no DB error but array is empty ?>
                <p class="col-12 text-center">No cakes available at the moment.</p>
            <?php endif; ?>
        </div>
    </div>
</section>
<!-- Product Cards: Cakes End -->

<!-- Product Cards: Birthday Cakes -->
<section id="birthday-cakes" class="product-section py-5 bg-light">
    <div class="container">
        <h1 class="section-title">BIRTHDAY CAKES</h1>
        <div class="row mt-4">
             <?php if (!empty($birthday_products)): ?>
                <?php foreach ($birthday_products as $product): ?>
                <div class="col-lg-3 col-md-4 col-sm-6 mb-4">
                    <div class="card product-card h-100">
                         <div class="product-overlay">
                            <!-- Image paths relative to php/ -> ../images/ -->
                            <button type="button" class="btn btn-secondary btn-quick-view" title="Quick View"><i><img src="../images/views.png" alt="" style="width:20px;"></i></button>
                           <button type="button" class="btn btn-secondary btn-wishlist" title="Add to Wishlist"><i><img src="../images/heart.png" alt="" style="width:20px;"></i></button>
                           <!-- Pass correct image path to JS -->
                           <button type="button" class="btn btn-secondary btn-add-to-cart" title="Add to Cart" onclick="addToCart(<?php echo $product['id']; ?>, '<?php echo htmlspecialchars(addslashes($product['name']), ENT_QUOTES); ?>', <?php echo $product['price']; ?>, '../images/<?php echo htmlspecialchars($product['image'], ENT_QUOTES); ?>')"><i><img src="../images/add.png" alt="" style="width:20px;"></i></button>
                        </div>
                         <!-- Image path relative to php/ -> ../images/ -->
                        <img src="../images/<?php echo htmlspecialchars($product['image'], ENT_QUOTES); ?>" class="card-img-top product-image" alt="<?php echo htmlspecialchars($product['name']); ?>">
                        <div class="card-body text-center">
                            <h5 class="card-title product-name"><?php echo htmlspecialchars($product['name']); ?></h5>
                            <div class="star-rating">
                                <?php for ($i = 0; $i < 5; $i++): ?>
                                    <i class="bx bxs-star <?php echo ($product['rating'] > $i) ? 'checked' : ''; ?>"></i>
                                <?php endfor; ?>
                            </div>
                            <h6 class="product-price">$<?php echo number_format($product['price'], 2); ?>
                                <!-- Pass correct image path to JS -->
                                <span><button class="btn btn-outline-primary btn-sm btn-add-cart-alt" onclick="addToCart(<?php echo $product['id']; ?>, '<?php echo htmlspecialchars(addslashes($product['name']), ENT_QUOTES); ?>', <?php echo $product['price']; ?>, '../images/<?php echo htmlspecialchars($product['image'], ENT_QUOTES); ?>')">Add Cart</button></span>
                            </h6>
                        </div>
                    </div>
                </div>
                <?php endforeach; ?>
            <?php elseif(!$db_error): // Show only if no DB error but array is empty ?>
                 <p class="col-12 text-center">No birthday cakes available at the moment.</p>
             <?php endif; ?>
        </div>
    </div>
</section>
<!-- Product Cards: Birthday Cakes End -->

<!-- Gallery Section (Index Page) -->
<section id="gallery-index" class="gallery-section py-5">
    <div class="container">
        <h1 class="section-title">OUR GALLERY</h1>
        <div class="row mt-4">
             <?php if (!empty($gallery_items_index)): ?>
                <?php foreach ($gallery_items_index as $item): ?>
                    <div class="col-md-4 col-sm-6 mb-4">
                        <div class="card gallery-card h-100">
                            <!-- Image path relative to php/ -> ../images/ -->
                            <img src="../images/<?php echo htmlspecialchars($item['image'], ENT_QUOTES); ?>" class="card-img-top gallery-image" alt="<?php echo htmlspecialchars($item['title']); ?>">
                            <div class="gallery-overlay">
                                <h5 class="text-center"><?php echo htmlspecialchars($item['title']); ?></h5>
                            </div>
                        </div>
                    </div>
                <?php endforeach; ?>
                <div class="col-12 text-center mt-3">
                    <a href="gallery.php" class="btn btn-primary">View Full Gallery</a>
                </div>
            <?php elseif(!$db_error): // Show only if no DB error but array is empty ?>
                <p class="col-12 text-center">Gallery is currently empty.</p>
             <?php endif; ?>
        </div>
    </div>
</section>
<!-- Gallery Section (Index Page) End -->


<!-- About Section Snippet (Index Page) -->
<section id="about-index" class="about-section-index py-5 bg-light"> <!-- Added background -->
    <div class="container">
        <h1 class="section-title">ABOUT US</h1>
        <div class="row align-items-center mt-4">
            <div class="col-md-6 py-3 py-md-0">
                <div class="card about-card-image">
                    <!-- Image path relative to php/ -> ../images/ -->
                    <img src="../images/about.png" alt="About SweetSlice" class="img-fluid">
                </div>
            </div>
            <div class="col-md-6 py-3 py-md-0 about-content-index">
                <p>Welcome to SweetSlice, where every slice tells a story! We believe that every occasion deserves a touch of sweetness. From birthdays to weddings, anniversaries to celebrations, we specialize in creating custom cakes that not only look stunning but taste divine...</p>
                <div class="text-center text-md-left mt-3" id="bt"> <!-- Adjusted alignment -->
                    <a href="about.php" class="btn btn-primary">Read More</a>
                </div>
            </div>
        </div>
    </div>
</section>
<!-- About Section Snippet End -->

<!-- Contact Section Snippet (Index Page) -->
<section id="contact-index" class="contact-section-index py-5">
    <div class="container">
        <h1 class="section-title">CONTACT US</h1>
        <!-- Modified form to submit to contact.php via POST -->
        <form class="contact-form-index mt-4 needs-validation" novalidate method="POST" action="contact.php">
            <div class="form-row">
                <div class="col-md-4 mb-3">
                     <label for="user_index" class="sr-only">Name</label> <!-- Screen reader label -->
                    <input type="text" class="form-control" id="user_index" name="name" placeholder="Name" required>
                     <div class="invalid-feedback">Please enter your name.</div>
                </div>
                <div class="col-md-4 mb-3">
                     <label for="eml_index" class="sr-only">Email</label> <!-- Screen reader label -->
                    <input type="email" class="form-control" id="eml_index" name="email" placeholder="Email" required>
                     <div class="invalid-feedback">Please enter a valid email.</div>
                </div>
                <div class="col-md-4 mb-3">
                     <label for="phn_index" class="sr-only">Phone</label> <!-- Screen reader label -->
                    <input type="tel" class="form-control" id="phn_index" name="phone" placeholder="Phone (Optional)">
                </div>
            </div>
            <div class="form-group">
                 <label for="comment_index" class="sr-only">Message</label> <!-- Screen reader label -->
                <textarea class="form-control" rows="4" id="comment_index" name="message" placeholder="Message" required></textarea>
                 <div class="invalid-feedback">Please enter your message.</div>
            </div>
            <div class="text-center" id="messagebtn-index">
                <!-- Changed button type to submit -->
                <button class="btn btn-primary" type="submit">Send Message</button>
            </div>
        </form>
    </div>
</section>
<!-- Contact Section Snippet End -->

<?php include 'includes/footer.php'; ?>
