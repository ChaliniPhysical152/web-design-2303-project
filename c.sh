
!/bin/bash

echo "Setting up SweetSlice PHP Project (Standard Dirs)..."

# Define directories and files
PROJECT_ROOT=$(pwd)
PHP_DIR="php"
INCLUDES_DIR="$PHP_DIR/includes"
LIB_DIR="$PHP_DIR/lib"
CSS_DIR="css"        # Separate CSS dir
JS_DIR="js"          # Separate JS dir
IMAGES_DIR="images"  # Images Directory
DB_DIR="db"
DB_FILE="$DB_DIR/sweet_slice.sqlite"
CSS_FILE="$CSS_DIR/style.css" # CSS file in css/
JS_FILE="$JS_DIR/script.js"   # JS file in js/

# Create directories
echo "Creating directories..."
mkdir -p "$PHP_DIR" "$INCLUDES_DIR" "$LIB_DIR" "$CSS_DIR" "$JS_DIR" "$IMAGES_DIR" "$DB_DIR"

# --- Create Placeholder Image Files ---
echo "Creating placeholder image files in '$IMAGES_DIR/'..."
image_files=(
    "about.png" "starwars.webp" "princesscastle.jpg" "signup.jpg" "up-arrow.png"
    "o3.png" "g3.jpg" "order.jpg" "superhero.webp" "menu.png" "o6.png"
    "frozen.jpeg" "g1.jpg" "views.png" "contact3.jpg" "heart.png" "o2.png"
    "login.jpg" "contact2.jpeg" "c9.png" "c8.png" "user.png" "contact1.jpg"
    "c12.png" "cart.jpg" "logo.jpg" "o1.png" "o5.png" "princess tiara.webp"
    "o4.png" "mickey.jpeg" "c7.png" "c10.png" "c11.png" "g2.jpg" "c6.png"
    "c5.png" "c4.png" "c3.png" "c2.png" "c1.png" "box3.jpg"
    "box2.jpg" "box1.jpg" "banner-background.avif" "banner2.jpg"
    "background2.webp" "background.png" "add.png" "about3.webp" "about2.jpg"
    "about1.jpg"
)
for img_name in "${image_files[@]}"; do
    touch "$IMAGES_DIR/$img_name"
done
echo "Placeholder image files created. Replace them with your actual images."


# --- Create PHP Files ---

echo "Creating PHP files..."

# php/lib/database.php (Path logic is correct here)
cat << 'EOF' > "$LIB_DIR/database.php"
<?php
/**
 * Simple SQLite Database Connection Handler
 */
// Correctly calculate DB path relative to THIS file (php/lib/database.php)
define('DB_PATH', __DIR__ . '/../../db/sweet_slice.sqlite');

function get_db_connection() {
    // Check if the database file exists and is readable
    if (!file_exists(DB_PATH)) {
        $dbDir = dirname(DB_PATH);
         if (!is_dir($dbDir)) {
             @mkdir($dbDir, 0755, true); // Try to create directory recursively
         }
         error_log("Database file does not exist at: " . DB_PATH . ". Attempting creation by setup script.");
         // Don't die here, let the script attempt creation. If it fails later, that's the issue.
         // If the script *already* ran, then the file *should* exist.
         // A robust app might try to initialize the DB schema here if it's missing.
         // For this setup, we rely on the shell script creating it first.
         // A check *after* trying to connect might be more appropriate.
         // Return null or throw specific exception if file doesn't exist *after* script should have run.
         // return null; // Or throw new Exception("DB file not found after setup.");
    }

     if (file_exists(DB_PATH) && !is_readable(DB_PATH)) {
         error_log("Database file is not readable: " . DB_PATH);
         die("Database file is not readable. Please check file permissions for: " . DB_PATH);
     }

     $dbDir = dirname(DB_PATH);
     if (!is_writable($dbDir)) {
          error_log("Database directory is not writable: " . $dbDir);
          // Only die if the file *doesn't* exist AND the dir isn't writable.
          // If the file exists, we might still be able to read even if dir isn't writable.
          if (!file_exists(DB_PATH)) {
            die("Database setup error: Directory not writable ('" . $dbDir . "') and database file ('" . basename(DB_PATH) . "') does not exist.");
          }
     }


    try {
        // Use the absolute path determined by the constant
        $db = new PDO('sqlite:' . DB_PATH);
        $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION); // Throw exceptions on error
        $db->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC); // Fetch associative arrays
        return $db;
    } catch (PDOException $e) {
         // Check if the error is "unable to open database file" which might indicate existence/permission issues again
        if (strpos($e->getMessage(), 'unable to open database file') !== false && !file_exists(DB_PATH)) {
             error_log("PDOException: unable to open database file (File Missing) - " . $e->getMessage() . " | Path used: " . DB_PATH);
             die("Database connection failed: The database file specified does not seem to exist. Ensure the setup script ran correctly.");
        } elseif (strpos($e->getMessage(), 'unable to open database file') !== false) {
             error_log("PDOException: unable to open database file (Permissions?) - " . $e->getMessage() . " | Path used: " . DB_PATH);
             die("Database connection failed: Unable to open the database file. Please check web server permissions for the file and its directory ('" . $dbDir . "').");
        } else {
            // Log other PDO errors
            error_log("Database Connection Error: " . $e->getMessage() . " | Path used: " . DB_PATH);
            die("Database connection failed. Please check server logs or setup.");
        }
    }
}
?>
EOF

# php/includes/header.php (Update path for CSS)
cat << 'EOF' > "$INCLUDES_DIR/header.php"
<?php
// Determine the current page filename without the extension
$currentPage = basename($_SERVER['PHP_SELF'], '.php');
$pageTitle = isset($pageTitle) ? htmlspecialchars($pageTitle) : ucfirst($currentPage);
if ($pageTitle == 'Index') $pageTitle = 'Home'; // Nicer title for index
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title><?php echo $pageTitle; ?> - SweetSlice</title>
    <!-- Icon path relative to php/includes/ -> ../images/ -->
    <link rel="shortcut icon" type="image/jpeg" href="../images/logo.jpg">

    <!-- Bootstrap CSS (Only for specific pages) -->
    <?php if (in_array($currentPage, ['index', 'cart', 'login', 'signup', 'order'])): ?>
        <?php if ($currentPage == 'cart'): ?>
             <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
        <?php else: ?>
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
        <?php endif; ?>
    <?php endif; ?>

    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <!-- Boxicons (For index page) -->
     <?php if ($currentPage == 'index'): ?>
        <link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet'>
     <?php endif; ?>

    <!-- Main Stylesheet (Relative path from php/includes/ -> ../css/style.css) -->
    <link rel="stylesheet" href="../css/style.css">

</head>
<body>
<!-- Consistent Navbar across pages -->
<nav class="navbar navbar-expand-md sweet-navbar" id="navbar">
    <div class="container-fluid"> <!-- Use container-fluid for better responsiveness -->
        <!-- Brand -->
        <a class="navbar-brand" href="index.php" id="logo">
            <!-- Image path relative to php/includes/ -> ../images/ -->
            <img src="../images/logo.jpg" alt="Logo" class="logo-img"> SweetSlice
        </a>

        <!-- Toggler/collapsible Button -->
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#collapsibleNavbar" aria-controls="collapsibleNavbar" aria-expanded="false" aria-label="Toggle navigation">
             <span class="navbar-toggler-icon"><i class="fas fa-bars" style="color:white; font-size:28px;"></i></span>
             <!-- Fallback using menu.png if needed -->
             <!-- <span class="navbar-toggler-icon"><img src="../images/menu.png" alt="Menu" style="width: 30px; height: auto;"></span> -->
        </button>

        <!-- Navbar links -->
        <div class="collapse navbar-collapse justify-content-center" id="collapsibleNavbar"> <!-- Center links -->
            <ul class="navbar-nav">
                <li class="nav-item <?php echo ($currentPage == 'index') ? 'active' : ''; ?>">
                    <a class="nav-link" href="index.php">Home</a>
                </li>
                <li class="nav-item <?php echo ($currentPage == 'about') ? 'active' : ''; ?>">
                    <a class="nav-link" href="about.php">About</a>
                </li>
                 <li class="nav-item <?php echo ($currentPage == 'gallery') ? 'active' : ''; ?>">
                    <a class="nav-link" href="gallery.php">Gallery</a>
                </li>
                <!-- Dropdown Example (from index.html structure) -->
                <li class="nav-item dropdown">
                    <a href="#" class="nav-link dropdown-toggle" id="navbardrop" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                        Category
                    </a>
                    <div class="dropdown-menu" aria-labelledby="navbardrop">
                        <a href="index.php#product-cards" class="dropdown-item">Cakes</a>
                        <a href="index.php#birthday-cakes" class="dropdown-item">Birthday Cake</a>
                        <!-- Add more specific links if needed -->
                    </div>
                </li>
                <li class="nav-item <?php echo ($currentPage == 'contact') ? 'active' : ''; ?>">
                    <a class="nav-link" href="contact.php">Contact</a>
                </li>
                 <li class="nav-item <?php echo ($currentPage == 'order') ? 'active' : ''; ?>">
                    <a class="nav-link" href="order.php">Order</a>
                </li>
            </ul>
        </div>

        <!-- Icons on the right -->
        <div class="navbar-icons ml-auto"> <!-- Use ml-auto to push icons right -->
             <!-- Paths relative to php/includes/ -> ../images/ -->
            <a href="cart.php" title="Shopping Cart"><img src="../images/cart.jpg" alt="Cart"></a>
            <a href="login.php" title="Login/User"><img src="../images/user.png" alt="User"></a>
             <!-- Wishlist Icon -->
             <a href="#" title="Wishlist"><img src="../images/heart.png" alt="Wishlist"></a>
              <!-- Add Icon -->
              <a href="cart.php" title="Add to Cart Action"><img src="../images/add.png" alt="Add"></a>

        </div>
    </div><!-- /.container-fluid -->
</nav>
<!-- Main Content Area Start -->
<main class="main-content">
EOF

# php/includes/footer.php (Update path for JS)
cat << 'EOF' > "$INCLUDES_DIR/footer.php"
</main> <!-- Main Content Area End -->

<!-- Footer -->
<footer id="footer" class="sweet-footer">
    <div class="container text-center"> <!-- Centered content -->
        <h1>SweetSlice</h1>
        <p>Bringing magic to your celebrations since 2023.</p>
        <div class="social-icons">
            <a href="#" title="Facebook"><i class="fab fa-facebook-f"></i></a>
            <a href="#" title="Instagram"><i class="fab fa-instagram"></i></a>
            <a href="#" title="Twitter"><i class="fab fa-twitter"></i></a>
             <!-- Boxicons examples (if needed, ensure boxicons CSS is linked) -->
            <!-- <i class="bx bxl-google"></i> -->
            <!-- <i class="bx bxl-skype"></i> -->
        </div>
        <p class="copyright">&copy; <?php echo date("Y"); ?> SweetSlice. All rights reserved.</p>
        <p class="credits">Designed By <a href="#">Chalini</a></p> <!-- Keep credit if required -->
    </div>
</footer>

<!-- Scroll to Top Button -->
<!-- Path relative to php/includes/ -> ../images/ -->
<a href="#" class="scroll-to-top-arrow" title="Scroll to Top"><i><img src="../images/up-arrow.png" alt="Up Arrow" style="width: 100%;"></i></a>


<!-- Bootstrap JS and Popper.js (Required for dropdowns, toggler, etc.) -->
<?php
$currentPage = basename($_SERVER['PHP_SELF'], '.php');
if (in_array($currentPage, ['index', 'cart', 'login', 'signup', 'order'])):
?>
    <script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.12.9/dist/umd/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous"></script>
    <?php if ($currentPage == 'cart'): ?>
         <!-- Stick with BS4 JS for consistency unless BS5 features are critical -->
         <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous"></script>
    <?php else: ?>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous"></script>
    <?php endif; ?>
<?php endif; ?>

<!-- Custom JavaScript (Path relative to php/includes/ -> ../js/script.js) -->
<script src="../js/script.js"></script>

</body>
</html>
EOF

# Create other PHP files (index, about, gallery, contact, cart, login, signup, order)
# These already have the correct include paths and relative paths to images (`../images/`)
# and assume the DB connection works or handles errors gracefully.
# Re-using the content from the previous correct version for these main files.

# php/index.php
cat << 'EOF' > "$PHP_DIR/index.php"
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
EOF

# php/about.php
cat << 'EOF' > "$PHP_DIR/about.php"
<?php
$pageTitle = "About Us";
include 'includes/header.php';
include_once 'lib/database.php';

$slider_images = [];
$db_error = null;

try {
    $pdo = get_db_connection();
    if($pdo) {
        $stmt = $pdo->prepare("SELECT image, alt_text FROM slider_images WHERE page = 'about' ORDER BY id");
        $stmt->execute();
        $slider_images = $stmt->fetchAll();
    } else {
        $db_error = "Database connection failed.";
    }
} catch (PDOException $e) {
    error_log("Database query error on about.php: " . $e->getMessage());
    $db_error = "Could not load slider images.";
}
?>

<!-- Display DB Error if any -->
<?php if ($db_error): ?>
    <div class="container mt-3">
        <p class="alert alert-warning text-center"><?php echo htmlspecialchars($db_error); ?></p>
    </div>
<?php endif; ?>


<!-- About Section -->
<section id="about-page" class="about-page-section py-5">
    <div class="container">
        <h1 class="page-main-title">About Us</h1>
        <div class="card about-card-content mt-4">
            <div class="card-body">
                <p>
                    Welcome to <strong>SweetSlice</strong>, where magic meets flavor! We specialize in creating enchanting cakes inspired by your favorite themes and stories.
                    Our team of talented bakers and decorators ensures every cake is a masterpiece, perfect for birthdays, weddings, anniversaries, and all your special occasions.
                </p>
                <p>
                    Our mission is to bring joy and wonder to your celebrations with our delicious and beautifully crafted cakes. From elegant wedding tiers to fun character themes, we pour our heart into every detail. We use only the finest, freshest ingredients because we believe quality you can taste makes all the difference.
                </p>
                 <p>
                    Whether you have a specific vision or need some creative inspiration, we're here to collaborate with you. Let us help make your sweet dreams a reality!
                </p>
            </div>
        </div>
    </div>
</section>

<!-- Slider Section -->
<?php if (!empty($slider_images)): ?>
<section class="slider-section my-5">
    <div class="container">
        <div id="aboutSlider" class="carousel slide" data-ride="carousel" data-interval="5000">
            <div class="carousel-inner">
                <?php foreach ($slider_images as $index => $slide): ?>
                <div class="carousel-item <?php echo ($index == 0) ? 'active' : ''; ?>">
                    <!-- Image path relative to php/ -> ../images/ -->
                    <img src="../images/<?php echo htmlspecialchars($slide['image'], ENT_QUOTES); ?>" class="d-block w-100" alt="<?php echo htmlspecialchars($slide['alt_text']); ?>">
                </div>
                <?php endforeach; ?>
            </div>
            <a class="carousel-control-prev" href="#aboutSlider" role="button" data-slide="prev">
                <span class="carousel-control-prev-icon" aria-hidden="true"></span>
                <span class="sr-only">Previous</span>
            </a>
            <a class="carousel-control-next" href="#aboutSlider" role="button" data-slide="next">
                <span class="carousel-control-next-icon" aria-hidden="true"></span>
                <span class="sr-only">Next</span>
            </a>
        </div>
    </div>
</section>
<?php elseif (!$db_error): ?>
    <!-- Optional: Show placeholder if slider images are specifically expected but not found (and no DB error) -->
     <!-- <p class="text-center my-5">Page images coming soon!</p> -->
<?php endif; ?>

<!-- Bottom Banner Section -->
<section class="bottom-banner-section text-white text-center py-5">
    <div class="bottom-banner-background"> <!-- Background handled by CSS -->
        <div class="container">
            <h2>Celebrate with SweetSlice Magic!</h2>
            <p>Order your dream cake today and make your celebration unforgettable.</p>
            <a href="order.php" class="btn btn-light btn-lg mt-3">Order Your Cake Now</a>
        </div>
    </div>
</section>

<?php include 'includes/footer.php'; ?>
EOF

# php/gallery.php
cat << 'EOF' > "$PHP_DIR/gallery.php"
<?php
$pageTitle = "Gallery";
include 'includes/header.php';
include_once 'lib/database.php';

$gallery_items = [];
$slider_images = [];
$db_error = null;

try {
    $pdo = get_db_connection();
    if($pdo) {
        // Fetch all gallery items
        $stmt_gallery = $pdo->prepare("SELECT * FROM gallery_items ORDER BY id");
        $stmt_gallery->execute();
        $gallery_items = $stmt_gallery->fetchAll();

        // Fetch slider images for the 'gallery' page
        $stmt_slider = $pdo->prepare("SELECT image, alt_text FROM slider_images WHERE page = 'gallery' ORDER BY id");
        $stmt_slider->execute();
        $slider_images = $stmt_slider->fetchAll();
    } else {
         $db_error = "Database connection failed.";
    }

} catch (PDOException $e) {
    error_log("Database query error on gallery.php: " . $e->getMessage());
    $db_error = "Could not load gallery data.";
}
?>

<!-- Display DB Error if any -->
<?php if ($db_error): ?>
    <div class="container mt-3">
        <p class="alert alert-warning text-center"><?php echo htmlspecialchars($db_error); ?></p>
    </div>
<?php endif; ?>

<!-- Gallery Section -->
<section id="gallery-page" class="gallery-page-section py-5">
    <div class="container">
        <h1 class="page-main-title">Our Gallery</h1>
        <?php if (!empty($gallery_items)): ?>
            <div class="gallery-grid mt-4">
                <?php foreach ($gallery_items as $item): ?>
                    <div class="card gallery-card">
                        <!-- Image path relative to php/ -> ../images/ -->
                        <img src="../images/<?php echo htmlspecialchars($item['image'], ENT_QUOTES); ?>" class="card-img-top gallery-image" alt="<?php echo htmlspecialchars($item['title']); ?>">
                        <div class="gallery-overlay">
                             <h5 class="text-center"><?php echo htmlspecialchars($item['title']); ?></h5>
                             <!-- Optional: Add zoom/link icon if needed -->
                             <!-- <a href="../images/<?php // echo htmlspecialchars($item['image'], ENT_QUOTES); ?>" data-lightbox="gallery" data-title="<?php // echo htmlspecialchars($item['title']); ?>"><i class="fas fa-search-plus"></i></a> -->
                        </div>
                    </div>
                <?php endforeach; ?>
            </div>
        <?php elseif (!$db_error): // Show message only if no DB error but empty results ?>
            <p class="text-center mt-4">Our gallery is currently empty. Check back soon!</p>
        <?php endif; ?>
    </div>
</section>

<!-- Slider Section -->
<?php if (!empty($slider_images)): ?>
<section class="slider-section my-5">
    <div class="container">
        <div id="gallerySlider" class="carousel slide" data-ride="carousel" data-interval="5500"> <!-- Slightly different interval -->
            <div class="carousel-inner">
                <?php foreach ($slider_images as $index => $slide): ?>
                <div class="carousel-item <?php echo ($index == 0) ? 'active' : ''; ?>">
                    <!-- Image path relative to php/ -> ../images/ -->
                    <img src="../images/<?php echo htmlspecialchars($slide['image'], ENT_QUOTES); ?>" class="d-block w-100" alt="<?php echo htmlspecialchars($slide['alt_text']); ?>">
                </div>
                <?php endforeach; ?>
            </div>
            <a class="carousel-control-prev" href="#gallerySlider" role="button" data-slide="prev">
                <span class="carousel-control-prev-icon" aria-hidden="true"></span>
                <span class="sr-only">Previous</span>
            </a>
            <a class="carousel-control-next" href="#gallerySlider" role="button" data-slide="next">
                <span class="carousel-control-next-icon" aria-hidden="true"></span>
                <span class="sr-only">Next</span>
            </a>
        </div>
    </div>
</section>
<?php endif; ?>


<!-- Bottom Banner Section -->
<section class="bottom-banner-section text-white text-center py-5">
     <div class="bottom-banner-background"> <!-- Background handled by CSS -->
        <div class="container">
            <h2>Inspired? Let's Create Your Cake!</h2>
            <p>Order your custom cake today and make your celebration unforgettable.</p>
            <a href="order.php" class="btn btn-light btn-lg mt-3">Get a Quote</a>
        </div>
    </div>
</section>

<?php include 'includes/footer.php'; ?>
EOF

# php/contact.php
cat << 'EOF' > "$PHP_DIR/contact.php"
<?php
$pageTitle = "Contact Us";
include 'includes/header.php';
include_once 'lib/database.php';

// --- Form Handling ---
$message_sent = false;
$error_message = '';
$form_values = ['name' => '', 'email' => '', 'subject' => '', 'message' => '']; // Store submitted values

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Store submitted values to repopulate form
    $form_values['name'] = trim(filter_input(INPUT_POST, 'name', FILTER_SANITIZE_STRING));
    $form_values['email'] = trim(filter_input(INPUT_POST, 'email', FILTER_SANITIZE_EMAIL)); // Use SANITIZE_EMAIL
    $form_values['subject'] = trim(filter_input(INPUT_POST, 'subject', FILTER_SANITIZE_STRING));
    $form_values['message'] = trim(filter_input(INPUT_POST, 'message', FILTER_SANITIZE_STRING));

    $email_validated = filter_var($form_values['email'], FILTER_VALIDATE_EMAIL);

    if (empty($form_values['name']) || empty($form_values['email']) || empty($form_values['message'])) {
        $error_message = "Please fill in all required fields (*).";
    } elseif (!$email_validated) {
         $error_message = "Please provide a valid email address.";
         $form_values['email'] = ''; // Clear invalid email
    } else {
        // --- Simple Success ---
        $message_sent = true;
        // In a real app, clear $form_values here after success

        // --- Example: Save to DB ---
        /*
        try {
            $pdo = get_db_connection(); // Assumes connection is possible
            if ($pdo) {
                $received_at = date('Y-m-d H:i:s'); // Server timestamp
                $sql = "INSERT INTO messages (name, email, subject, message, received_at)
                        VALUES (:name, :email, :subject, :message, :received_at)";
                $stmt = $pdo->prepare($sql);
                // Bind from the stored $form_values array
                $stmt->bindParam(':name', $form_values['name']);
                $stmt->bindParam(':email', $email_validated); // Use validated email
                $stmt->bindParam(':subject', $form_values['subject']);
                $stmt->bindParam(':message', $form_values['message']);
                $stmt->bindParam(':received_at', $received_at);
                $stmt->execute();
                $message_sent = true;
                // Optionally clear form values after successful save
                // $form_values = ['name' => '', 'email' => '', 'subject' => '', 'message' => ''];
            } else {
                 $error_message = "Database connection error. Could not save message.";
                 $message_sent = false;
            }
        } catch (PDOException $e) {
             error_log("Failed to save contact message: " . $e->getMessage());
             $error_message = "Sorry, there was an error sending your message. Please try again later.";
             $message_sent = false; // Ensure flag is false on error
        }
        */
    }
}
// --- End Form Handling ---

// Fetch slider images
$slider_images = [];
$db_error_slider = null;
try {
    $pdo_slider = get_db_connection(); // Use separate variable if needed
    if($pdo_slider) {
        $stmt_slider = $pdo_slider->prepare("SELECT image, alt_text FROM slider_images WHERE page = 'contact' ORDER BY id");
        $stmt_slider->execute();
        $slider_images = $stmt_slider->fetchAll();
    } else {
        $db_error_slider = "Database connection failed for slider images.";
    }
} catch (PDOException $e) {
    error_log("Database query error on contact.php (slider): " . $e->getMessage());
    $db_error_slider = "Could not load page images.";
}
?>

<!-- Contact Section -->
<section id="contact-page" class="contact-page-section py-5">
    <div class="container">
        <h1 class="page-main-title">Contact Us</h1>
        <p class="text-center lead mb-4">Have a question or want to discuss a custom order? Reach out!</p>

        <?php if ($message_sent): ?>
            <div class="alert alert-success text-center" role="alert">
                Thank you for your message! We'll get back to you soon.
            </div>
        <?php endif; ?>
        <?php if ($error_message): ?>
             <div class="alert alert-danger text-center" role="alert">
                <?php echo htmlspecialchars($error_message); ?>
            </div>
        <?php endif; ?>
        <?php if ($db_error_slider): // Display slider specific error ?>
             <div class="alert alert-warning text-center" role="alert">
                <?php echo htmlspecialchars($db_error_slider); ?>
            </div>
        <?php endif; ?>


        <?php if (!$message_sent): // Show form only if message not sent ?>
        <div class="contact-form-container mt-4">
            <form class="contact-form needs-validation" method="POST" action="contact.php" novalidate>
                <div class="form-row">
                    <div class="form-group col-md-6">
                        <label for="name">Your Name <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="name" name="name" placeholder="Enter your name" required value="<?php echo htmlspecialchars($form_values['name']); ?>">
                        <div class="invalid-feedback">Please enter your name.</div>
                    </div>
                    <div class="form-group col-md-6">
                        <label for="email">Your Email <span class="text-danger">*</span></label>
                        <input type="email" class="form-control" id="email" name="email" placeholder="Enter your email address" required value="<?php echo htmlspecialchars($form_values['email']); ?>">
                         <div class="invalid-feedback">Please enter a valid email address.</div>
                    </div>
                </div>
                <div class="form-group">
                     <label for="subject">Subject</label>
                    <input type="text" class="form-control" id="subject" name="subject" placeholder="e.g., Custom Cake Inquiry" value="<?php echo htmlspecialchars($form_values['subject']); ?>">
                </div>
                <div class="form-group">
                    <label for="message">Your Message <span class="text-danger">*</span></label>
                    <textarea class="form-control" id="message" name="message" rows="5" placeholder="Tell us about your cake needs or ask your question here..." required><?php echo htmlspecialchars($form_values['message']); ?></textarea>
                    <div class="invalid-feedback">Please enter your message.</div>
                </div>
                <div class="text-center" id="messagebtn">
                    <button type="submit" class="btn btn-primary btn-lg">Send Message</button>
                </div>
            </form>
        </div>
        <?php endif; // End if !$message_sent ?>

         <!-- Optional: Add Contact Info -->
         <div class="contact-info mt-5 text-center">
             <h4>Or Reach Us Directly</h4>
             <p><i class="fas fa-phone"></i> Phone: <a href="tel:+1234567890">+1 (234) 567-890</a></p>
             <p><i class="fas fa-envelope"></i> Email: <a href="mailto:info@sweetslice.com">info@sweetslice.com</a></p>
             <p><i class="fas fa-map-marker-alt"></i> Address: 123 Cake Lane, Pastryville, PV 45678</p>
         </div>

    </div>
</section>

<!-- Slider Section -->
<?php if (!empty($slider_images)): ?>
<section class="slider-section my-5">
    <div class="container">
        <div id="contactSlider" class="carousel slide" data-ride="carousel" data-interval="6000"> <!-- Slower interval -->
            <div class="carousel-inner">
                <?php foreach ($slider_images as $index => $slide): ?>
                <div class="carousel-item <?php echo ($index == 0) ? 'active' : ''; ?>">
                     <!-- Image path relative to php/ -> ../images/ -->
                    <img src="../images/<?php echo htmlspecialchars($slide['image'], ENT_QUOTES); ?>" class="d-block w-100" alt="<?php echo htmlspecialchars($slide['alt_text']); ?>">
                </div>
                <?php endforeach; ?>
            </div>
             <a class="carousel-control-prev" href="#contactSlider" role="button" data-slide="prev">
                <span class="carousel-control-prev-icon" aria-hidden="true"></span>
                <span class="sr-only">Previous</span>
            </a>
            <a class="carousel-control-next" href="#contactSlider" role="button" data-slide="next">
                <span class="carousel-control-next-icon" aria-hidden="true"></span>
                <span class="sr-only">Next</span>
            </a>
        </div>
    </div>
</section>
<?php endif; ?>

<!-- Bottom Banner Section -->
<section class="bottom-banner-section text-white text-center py-5">
     <div class="bottom-banner-background"> <!-- Background handled by CSS -->
        <div class="container">
            <h2>Ready for Sweetness?</h2>
            <p>Order your dream cake today and make your celebration unforgettable.</p>
             <a href="order.php" class="btn btn-light btn-lg mt-3">Place Your Order</a>
        </div>
    </div>
</section>

<?php include 'includes/footer.php'; ?>
EOF

# php/cart.php
cat << 'EOF' > "$PHP_DIR/cart.php"
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
EOF

# php/login.php
cat << 'EOF' > "$PHP_DIR/login.php"
<?php
$pageTitle = "Login";
// No header/footer needed for full page background login/signup
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo $pageTitle; ?> - SweetSlice</title>
    <!-- Icon path relative to php/ -> ../images/ -->
    <link rel="shortcut icon" type="image/jpeg" href="../images/logo.jpg">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
    <!-- CSS path relative to php/ -> ../css/ -->
    <link rel="stylesheet" href="../css/style.css"> <!-- Link custom styles -->
    <style>
        body {
             /* Image path relative to php/ -> ../images/ */
            background-image: url('../images/login.jpg');
            background-size: cover;
            background-repeat: no-repeat;
            background-position: center center;
            min-height: 100vh;
            margin: 0;
            display: flex;
            align-items: center; /* Vertically center */
            justify-content: center; /* Horizontally center */
            padding: 15px; /* Add padding for smaller screens */
        }
    </style>
</head>
<body>
    <div class="auth-card card p-4 shadow-lg">
        <h3 class="text-center mb-4">Login</h3>
        <form id="loginForm" class="needs-validation" novalidate>
            <div class="form-group">
                <label for="email">Email address</label>
                <input type="email" name="email" class="form-control" id="email" placeholder="Enter email" required>
                 <div class="invalid-feedback">Please enter a valid email address.</div>
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" name="password" class="form-control" id="password" placeholder="Password" required>
                <div class="invalid-feedback">Please enter your password.</div>
            </div>
            <button type="submit" class="btn btn-primary btn-block">Login</button>
        </form>
        <div class="text-center mt-3">
            <p class="small">
                Don't have an account? <a href="signup.php">Sign up</a>
            </p>
             <p class="small"><a href="index.php">Back to Home</a></p>
        </div>
    </div>

    <!-- Bootstrap JS and Popper.js -->
    <script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.12.9/dist/umd/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous"></script>
    <!-- Custom JS for form handling (Path relative to php/ -> ../js/) -->
    <script src="../js/script.js"></script>
</body>
</html>
EOF

# php/signup.php
cat << 'EOF' > "$PHP_DIR/signup.php"
<?php
$pageTitle = "Signup";
// No header/footer needed for full page background login/signup
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo $pageTitle; ?> - SweetSlice</title>
     <!-- Icon path relative to php/ -> ../images/ -->
     <link rel="shortcut icon" type="image/jpeg" href="../images/logo.jpg">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
     <!-- CSS path relative to php/ -> ../css/ -->
     <link rel="stylesheet" href="../css/style.css"> <!-- Link custom styles -->
    <style>
        body {
            /* Image path relative to php/ -> ../images/ */
            background-image: url('../images/signup.jpg');
            background-size: cover;
            background-repeat: no-repeat;
            background-position: center center;
             min-height: 100vh;
             margin: 0;
             display: flex;
             align-items: center; /* Vertically center */
             justify-content: center; /* Horizontally center */
             padding: 15px;
        }
    </style>
</head>
<body>
    <div class="auth-card card p-4 shadow-lg">
        <h3 class="text-center mb-4">Signup</h3>
        <form id="signupForm" class="needs-validation" novalidate>
            <div class="form-group">
                <label for="name">Full Name</label>
                <input type="text" name="name" class="form-control" id="name" placeholder="Enter your full name" required>
                 <div class="invalid-feedback">Please enter your name.</div>
            </div>
            <div class="form-group">
                <label for="email">Email Address</label>
                <input type="email" name="email" class="form-control" id="email" placeholder="Enter your email" required>
                <div class="invalid-feedback">Please enter a valid email address.</div>
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" name="password" class="form-control" id="password" placeholder="Create a password (min. 6 characters)" required minlength="6">
                 <div class="invalid-feedback">Password must be at least 6 characters.</div>
            </div>
            <div class="form-group">
                <label for="confirmPassword">Confirm Password</label>
                <input type="password" name="confirmPassword" class="form-control" id="confirmPassword" placeholder="Confirm your password" required>
                 <div class="invalid-feedback" id="confirmPasswordFeedback">Please confirm your password.</div>
                 <div class="invalid-feedback" id="passwordMismatch" style="display: none; color: red;">Passwords do not match.</div>
            </div>
            <button type="submit" class="btn btn-primary btn-block">Sign Up</button>
        </form>
        <div class="text-center mt-3">
            <p class="small">
                Already have an account? <a href="login.php">Login</a>
            </p>
             <p class="small"><a href="index.php">Back to Home</a></p>
        </div>
    </div>

    <!-- Bootstrap JS and Popper.js -->
    <script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.12.9/dist/umd/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous"></script>
     <!-- Custom JS for form handling (Path relative to php/ -> ../js/) -->
    <script src="../js/script.js"></script>
</body>
</html>
EOF

# php/order.php
cat << 'EOF' > "$PHP_DIR/order.php"
<?php
$pageTitle = "Order Cake";
include 'includes/header.php';

// --- Basic Form Handling ---
$order_placed = false;
$order_error = '';
$form_values = [ // Store submitted values to repopulate form
    'cake' => '', 'details' => '', 'quantity' => '1', 'name' => '',
    'email' => '', 'phone' => '', 'date_needed' => ''
];

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Store submitted values
    $form_values['cake'] = trim(filter_input(INPUT_POST, 'cake', FILTER_SANITIZE_STRING));
    $form_values['details'] = trim(filter_input(INPUT_POST, 'details', FILTER_SANITIZE_STRING));
    $form_values['quantity'] = filter_input(INPUT_POST, 'quantity', FILTER_VALIDATE_INT);
    $form_values['name'] = trim(filter_input(INPUT_POST, 'name', FILTER_SANITIZE_STRING));
    $form_values['email'] = trim(filter_input(INPUT_POST, 'email', FILTER_SANITIZE_EMAIL));
    $form_values['phone'] = trim(filter_input(INPUT_POST, 'phone', FILTER_SANITIZE_STRING)); // Basic sanitize
    $form_values['date_needed'] = trim(filter_input(INPUT_POST, 'date_needed', FILTER_SANITIZE_STRING)); // Treat as string

    $email_validated = filter_var($form_values['email'], FILTER_VALIDATE_EMAIL);

    // Validate required fields
    if (empty($form_values['cake']) || $form_values['quantity'] === false || $form_values['quantity'] <= 0 || empty($form_values['name']) || empty($form_values['email']) || empty($form_values['phone'])) {
        $order_error = "Please fill in all required fields (*).";
    } elseif (!$email_validated) {
        $order_error = "Please provide a valid email address.";
        $form_values['email'] = ''; // Clear invalid email for repopulation
    } else {
        // --- Simple Success ---
        $order_placed = true;
        $order_summary = "Cake: " . htmlspecialchars($form_values['cake']) .
                         (!empty($form_values['details']) ? "<br>Details: " . nl2br(htmlspecialchars($form_values['details'])) : "") . // Use nl2br for details
                         "<br>Quantity: " . htmlspecialchars($form_values['quantity']) .
                         "<br>Name: " . htmlspecialchars($form_values['name']) .
                         "<br>Email: " . htmlspecialchars($email_validated) . // Use validated email
                         "<br>Phone: " . htmlspecialchars($form_values['phone']) .
                         (!empty($form_values['date_needed']) ? "<br>Date Needed: " . htmlspecialchars($form_values['date_needed']) : "");

        // --- Example: Save to DB ---
        /*
        include_once 'lib/database.php';
        try {
             $pdo = get_db_connection();
             if($pdo) {
                $total_price = 0; // Placeholder - Calculate based on cake/quantity
                $order_date = date('Y-m-d H:i:s'); // Server timestamp
                $sql = "INSERT INTO orders (cake_type, details, quantity, customer_name, customer_email, customer_phone, date_needed, order_status, order_date, total_price)
                        VALUES (:cake, :details, :quantity, :name, :email, :phone, :date_needed, 'Pending', :order_date, :price)";
                $stmt = $pdo->prepare($sql);
                $stmt->bindParam(':cake', $form_values['cake']);
                $stmt->bindParam(':details', $form_values['details']);
                $stmt->bindParam(':quantity', $form_values['quantity'], PDO::PARAM_INT); // Specify type
                $stmt->bindParam(':name', $form_values['name']);
                $stmt->bindParam(':email', $email_validated);
                $stmt->bindParam(':phone', $form_values['phone']);
                $stmt->bindParam(':date_needed', $form_values['date_needed']);
                $stmt->bindParam(':order_date', $order_date);
                $stmt->bindParam(':price', $total_price); // Bind price
                $stmt->execute();
                $order_placed = true;
                // Optionally clear $form_values here
             } else {
                 $order_error = "Database connection error. Order not saved.";
                 $order_placed = false;
             }
        } catch (PDOException $e) {
             error_log("Failed to save order: " . $e->getMessage());
             $order_error = "Sorry, there was an error placing your order. Please try again later or contact us directly.";
             $order_placed = false; // Ensure flag is false on error
        }
        */
    }
}
// --- End Form Handling ---

?>
 <style> /* Specific styles for this page */
    .order-page-body {
         /* Image path relative to php/ -> ../images/ */
        background-image: url('../images/order.jpg');
        background-size: cover;
        background-repeat: no-repeat;
        background-position: center center;
        padding-top: 50px;
        padding-bottom: 50px;
        min-height: calc(100vh - 150px); /* Adjust based on header/footer height */
    }
    .order-form-container {
        background: rgba(255, 255, 255, 0.9); /* More opaque */
        border-radius: 10px;
        padding: 30px;
        box-shadow: 0 6px 12px rgba(0, 0, 0, 0.15);
        max-width: 700px; /* Limit width */
        margin: auto; /* Center container */
    }
</style>

<div class="order-page-body"> <!-- Apply background to this container -->
    <div class="container">
        <div class="order-form-container">
            <h2 class="text-center mb-4">Order Your Cake</h2>

            <?php if ($order_placed): ?>
                <div class="alert alert-success text-center">
                    <h4>Order Request Sent!</h4>
                    <p>Thank you, <?php echo htmlspecialchars($form_values['name']); ?>! We have received your request:</p>
                    <div class="text-left mb-3" style="display: inline-block; max-width: 100%; overflow-wrap: break-word;"><?php echo $order_summary; ?></div>
                    <p>We will contact you shortly via email or phone to confirm details and provide a quote.</p>
                    <a href="index.php" class="btn btn-secondary">Back to Home</a>
                </div>
            <?php endif; ?>
            <?php if ($order_error): ?>
                 <div class="alert alert-danger text-center">
                    <?php echo htmlspecialchars($order_error); ?>
                </div>
            <?php endif; ?>

            <?php if (!$order_placed): // Show form only if order not placed ?>
                <form id="orderForm" class="needs-validation" method="POST" action="order.php" novalidate>
                    <!-- Cake Selection -->
                    <div class="form-group">
                        <label for="cake">Choose Your Cake Type <span class="text-danger">*</span></label>
                        <select class="form-control" id="cake" name="cake" required>
                            <option value="" disabled <?php echo empty($form_values['cake']) ? 'selected' : '';?>>-- Select a Cake --</option>
                            <option value="birthday-cake" <?php echo ($form_values['cake'] == 'birthday-cake') ? 'selected' : '';?>>Birthday Cake</option>
                            <option value="chocolate-cake" <?php echo ($form_values['cake'] == 'chocolate-cake') ? 'selected' : '';?>>Chocolate Cake</option>
                            <option value="party-cake" <?php echo ($form_values['cake'] == 'party-cake') ? 'selected' : '';?>>Party Cake</option>
                            <option value="slice-cake" <?php echo ($form_values['cake'] == 'slice-cake') ? 'selected' : '';?>>Slice Cake</option>
                            <option value="cup-cake" <?php echo ($form_values['cake'] == 'cup-cake') ? 'selected' : '';?>>Cup Cake</option>
                            <option value="custom-cake" <?php echo ($form_values['cake'] == 'custom-cake') ? 'selected' : '';?>>Custom Cake (Describe below)</option>
                        </select>
                         <div class="invalid-feedback">Please choose a cake type.</div>
                    </div>

                     <!-- Custom Request Details -->
                    <div class="form-group">
                        <label for="details">Custom Details / Special Instructions</label>
                        <textarea class="form-control" id="details" name="details" rows="3" placeholder="e.g., Specific flavor, design ideas, allergies..."><?php echo htmlspecialchars($form_values['details']); ?></textarea>
                    </div>


                    <!-- Quantity -->
                    <div class="form-group">
                        <label for="quantity">Quantity <span class="text-danger">*</span></label>
                        <input type="number" class="form-control" id="quantity" name="quantity" min="1" required value="<?php echo htmlspecialchars($form_values['quantity']); ?>">
                         <div class="invalid-feedback">Please enter a valid quantity (1 or more).</div>
                    </div>

                    <!-- Contact Info -->
                    <div class="form-group">
                        <label for="name">Your Name <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="name" name="name" placeholder="Enter your full name" required value="<?php echo htmlspecialchars($form_values['name']); ?>">
                        <div class="invalid-feedback">Please enter your name.</div>
                    </div>

                    <div class="form-group">
                        <label for="email">Email Address <span class="text-danger">*</span></label>
                        <input type="email" class="form-control" id="email" name="email" placeholder="Enter your email address" required value="<?php echo htmlspecialchars($form_values['email']); ?>">
                         <div class="invalid-feedback">Please enter a valid email address.</div>
                    </div>

                    <div class="form-group">
                        <label for="phone">Phone Number <span class="text-danger">*</span></label>
                        <input type="tel" class="form-control" id="phone" name="phone" placeholder="Enter your phone number" required value="<?php echo htmlspecialchars($form_values['phone']); ?>">
                         <div class="invalid-feedback">Please enter your phone number.</div>
                    </div>

                     <!-- Date Needed (Optional) -->
                     <div class="form-group">
                        <label for="date_needed">Date Needed By</label>
                        <input type="date" class="form-control" id="date_needed" name="date_needed" value="<?php echo htmlspecialchars($form_values['date_needed']); ?>" min="<?php echo date('Y-m-d'); // Set min date to today ?>">
                         <small class="form-text text-muted">Please allow sufficient notice, especially for custom orders.</small>
                    </div>


                    <!-- Submit Button -->
                    <div class="text-center">
                        <button type="submit" class="btn btn-primary btn-lg">Send Order Request</button>
                    </div>
                </form>
             <?php endif; // End if !$order_placed ?>
        </div>
    </div>
</div>

<?php include 'includes/footer.php'; ?>
EOF


# --- Create CSS File (In css/ directory) ---
echo "Creating CSS file: $CSS_FILE ..."

# css/style.css
cat << 'EOF' > "$CSS_FILE"
/* --- General Styles & Resets --- */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Poppins', sans-serif, Arial, sans-serif; /* Added fallback fonts */
    background: linear-gradient(135deg, #fff0f5, #ffefd5); /* Lighter, elegant gradient */
    color: #333; /* Darker text for better readability */
    line-height: 1.6;
    overflow-x: hidden; /* Prevent horizontal scroll */
}

h1, h2, h3, h4, h5, h6 {
    font-family: 'Poppins', sans-serif; /* Consistent heading font */
    color: #D5006D; /* Primary pink color for headings */
    font-weight: 600; /* Slightly bolder */
}

p {
    margin-bottom: 1rem;
    color: #555; /* Slightly lighter text color */
}

a {
    color: #D5006D;
    transition: color 0.3s ease;
}

a:hover {
    color: #FF69B4; /* Lighter pink on hover */
    text-decoration: none;
}

.container {
    max-width: 1200px;
    margin-left: auto;
    margin-right: auto;
    padding-left: 15px;
    padding-right: 15px;
}
/* Ensure fluid images */
.img-fluid {
    max-width: 100%;
    height: auto;
}

.section-title {
    text-align: center;
    font-weight: bold;
    margin-top: 30px; /* Reduced top margin */
    margin-bottom: 40px; /* Added bottom margin */
    color: #D5006D; /* Use primary color */
    text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.1);
    position: relative;
    padding-bottom: 10px;
    font-size: 2.2rem; /* Adjusted size */
}

.section-title::after { /* Simple underline effect */
    content: '';
    display: block;
    width: 80px;
    height: 3px;
    background-color: #FF69B4; /* Lighter pink */
    margin: 8px auto 0;
    border-radius: 2px;
}

.page-main-title { /* For About, Contact, Gallery Pages */
     text-align: center;
    font-weight: bold;
    margin-top: 20px;
    margin-bottom: 30px;
    color: #D5006D;
    text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.1);
    font-size: 2.8rem;
}


.card {
    border: none; /* Remove default card border */
    border-radius: 10px; /* Consistent rounded corners */
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1); /* Softer shadow */
    transition: transform 0.3s ease, box-shadow 0.3s ease;
    background-color: rgba(255, 255, 255, 0.9); /* Slightly transparent white */
    overflow: hidden; /* Ensure content respects border-radius */
}

.card:hover {
    transform: translateY(-5px);
    box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.btn-primary {
    background-color: #D5006D;
    border-color: #D5006D;
    font-weight: bold;
    padding: 10px 25px; /* More padding */
    border-radius: 50px; /* Pill shape */
    transition: background-color 0.3s ease, transform 0.2s ease;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    font-size: 0.9rem;
}

.btn-primary:hover {
    background-color: #FF69B4;
    border-color: #FF69B4;
    transform: translateY(-2px);
}

.btn-outline-primary {
     color: #D5006D;
     border-color: #D5006D;
     font-weight: bold;
     border-radius: 50px;
     transition: background-color 0.3s ease, color 0.3s ease;
}

.btn-outline-primary:hover {
    background-color: #D5006D;
    color: white;
}

.btn-secondary { /* For overlay buttons, etc. */
    background-color: rgba(0, 0, 0, 0.5);
    border: none;
    color: white;
    border-radius: 50%; /* Circle */
    width: 40px;
    height: 40px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    margin: 5px;
    transition: background-color 0.3s ease, transform 0.2s ease;
    padding: 0; /* Remove default padding */
}

.btn-secondary:hover {
    background-color: rgba(213, 0, 109, 0.8); /* Primary color semi-transparent */
    color: white;
    transform: scale(1.1);
}
.btn-secondary i { font-size: 1rem; line-height: 1; } /* Adjust icon size and ensure centered */
.btn-secondary img { max-width: 60%; height: auto; } /* Size overlay icons */


/* --- Navbar Styles --- */
.sweet-navbar {
    background-color: rgba(213, 0, 109, 0.9); /* Slightly more opaque */
    backdrop-filter: blur(8px);
    padding: 10px 0; /* Adjusted padding */
    position: sticky;
    top: 0;
    z-index: 1030; /* Ensure it's above other content */
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.15);
    font-weight: 500; /* Normal weight */
}

.sweet-navbar .navbar-brand {
    font-size: 1.8rem; /* Larger logo text */
    font-weight: bold;
    color: white;
    display: flex;
    align-items: center;
}

.sweet-navbar .logo-img {
    height: 45px; /* Slightly larger logo */
    width: auto;
    margin-right: 12px;
    border-radius: 50%; /* Make logo image circular */
    vertical-align: middle;
}

.sweet-navbar .navbar-nav .nav-link {
    color: rgba(255, 255, 255, 0.9); /* Slightly transparent white */
    margin: 0 15px; /* Spacing between links */
    font-weight: 500; /* Normal weight */
    transition: color 0.3s ease, transform 0.2s ease;
    padding: 8px 0; /* Vertical padding */
    position: relative;
    text-transform: uppercase;
    font-size: 0.9rem;
}

.sweet-navbar .navbar-nav .nav-link::after { /* Underline effect */
    content: '';
    position: absolute;
    bottom: 0;
    left: 0;
    width: 0;
    height: 2px;
    background-color: #FFC0CB; /* Light pink */
    transition: width 0.3s ease;
}

.sweet-navbar .navbar-nav .nav-item.active .nav-link,
.sweet-navbar .navbar-nav .nav-link:hover {
    color: white; /* Full white on hover/active */
}

.sweet-navbar .navbar-nav .nav-item.active .nav-link::after,
.sweet-navbar .navbar-nav .nav-link:hover::after {
    width: 100%; /* Expand underline */
}

.sweet-navbar .navbar-toggler {
    border: none;
    padding: 0; /* Remove padding */
}
.sweet-navbar .navbar-toggler:focus {
    outline: none;
    box-shadow: none;
}
.sweet-navbar .navbar-toggler-icon i {
    color: white;
    font-size: 1.8rem;
}
.sweet-navbar .navbar-toggler-icon img { /* Style for image toggler */
     width: 30px;
     height: auto;
     filter: brightness(0) invert(1); /* Make it white */
}


.sweet-navbar .navbar-icons img {
    height: 28px; /* Adjust icon size */
    width: auto; /* Maintain aspect ratio */
    margin-left: 20px;
    cursor: pointer;
    transition: transform 0.3s ease;
    filter: brightness(0) invert(1); /* Make icons white */
    vertical-align: middle; /* Align icons nicely */
}

.sweet-navbar .navbar-icons img:hover {
    transform: scale(1.15);
}

.sweet-navbar .dropdown-menu {
    background-color: rgba(213, 0, 109, 0.95);
    border: none;
    box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
    border-radius: 5px;
}

.sweet-navbar .dropdown-item {
    color: rgba(255, 255, 255, 0.9);
    padding: 10px 20px;
    transition: background-color 0.3s ease, color 0.3s ease;
}

.sweet-navbar .dropdown-item:hover,
.sweet-navbar .dropdown-item:focus {
    background-color: #FF69B4;
    color: white;
}


@media (max-width: 768px) {
    .sweet-navbar .navbar-nav {
        margin-top: 15px;
        text-align: center; /* Center links in collapsed menu */
    }
     .sweet-navbar .navbar-nav .nav-link {
         margin: 10px 0; /* Vertical spacing */
     }
     .sweet-navbar .navbar-icons {
         margin-left: 0; /* Reset margin */
         margin-top: 10px;
         display: flex;
         justify-content: center; /* Center icons */
         padding-bottom: 10px;
     }
      .sweet-navbar .navbar-icons img {
          margin: 0 10px; /* Reduced spacing between icons */
      }
}

/* --- Home Section --- */
.home-section {
    position: relative;
    color: white;
    text-shadow: 1px 1px 3px rgba(0, 0, 0, 0.5); /* Add text shadow for readability */
}

.home-background {
    padding: 120px 0; /* Adjust vertical padding */
    min-height: 80vh; /* Minimum height */
    display: flex;
    align-items: center;
    /* Image path relative to CSS file (in css/) -> ../images/ */
    background-image: linear-gradient(rgba(0, 0, 0, 0.4), rgba(0, 0, 0, 0.4)), url('../images/background2.webp');
    background-size: cover;
    background-position: center center;
    background-attachment: fixed; /* Parallax effect */
}

.home-content h3 {
    font-size: 2.5rem; /* Responsive font size */
    font-weight: 300; /* Lighter weight for 'Hi' part */
    color: #fff;
    margin-bottom: 0.5rem;
}

.home-content h2 {
    font-size: 3.5rem; /* Larger font size */
    font-weight: bold;
    color: #fff; /* White text */
    margin-bottom: 1.5rem;
}

.home-content .changecontent { /* Style the changing part */
    color: #FFC0CB; /* Light pink for emphasis */
    font-weight: bold;
}
/* Keyframes for text change (JS will handle the logic) */
@keyframes changetext {
    0%, 100% { content: "Birthday cake"; }
    20% { content: "Chocolate cake"; }
    40% { content: "Party cake"; }
    60% { content: "Slice cake"; }
    80% { content: "Cup cake"; }
}
.changecontent::after {
    content: 'Birthday cake'; /* Default */
    animation: changetext 10s infinite linear;
}

.home-image img {
    max-width: 100%;
    height: auto;
    animation: float 3s ease-in-out infinite; /* Subtle floating animation */
}

@keyframes float {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(-15px); }
}

.btn-order-now {
    margin-top: 1rem;
}

@media (max-width: 768px) {
    .home-background {
        padding: 80px 0;
        min-height: 60vh;
        text-align: center;
        background-attachment: scroll; /* Disable parallax on mobile */
    }
    .home-content h3 {
        font-size: 2rem;
    }
    .home-content h2 {
        font-size: 2.8rem;
    }
     .home-image {
         margin-top: 30px;
     }
}

/* --- Top Cards --- */
.top-cards-section .card {
    border: none;
    overflow: hidden; /* Ensure image fits card radius */
}
.top-cards-section .card img {
    display: block;
    width: 100%;
    height: auto;
}

/* --- Banner Section --- */
.banner-section {
    position: relative;
    color: white;
    text-shadow: 1px 1px 3px rgba(0, 0, 0, 0.6);
}
.banner-background {
    padding: 100px 0;
    /* Image path relative to CSS file (in css/) -> ../images/ */
    background-image: linear-gradient(rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0.5)), url('../images/banner2.jpg');
    background-size: cover;
    background-position: center center;
    background-attachment: fixed; /* Optional parallax */
}
.banner-content h3 {
    font-size: 2rem;
    font-weight: 500;
    color: #eee; /* Slightly off-white */
}
.banner-content h2 {
    font-size: 3.5rem;
    font-weight: bold;
    color: white;
    margin-bottom: 1.5rem;
}
.btn-order-banner {
     margin-top: 1rem;
}

@media (max-width: 768px) {
    .banner-background {
        padding: 60px 0;
        text-align: center;
         background-attachment: scroll;
    }
     .banner-content h2 {
        font-size: 2.5rem;
    }
    .banner-image { display: none; } /* Hide image column on small screens if needed */
}


/* --- Product Card Styles --- */
.product-section {
    background-color: #fdfbfb; /* Very light background */
}
.product-section.bg-light { /* For Birthday cakes section */
     background-color: #fff0f5; /* Lavender blush */
}

.product-card {
    position: relative; /* Needed for overlay */
    text-align: center;
}

.product-card .product-image {
    width: 100%;
    height: 200px; /* Fixed height */
    object-fit: contain; /* Fit image within bounds */
    padding: 15px; /* Padding around image */
    background-color: #fff; /* White background for image area */
}

.product-card .card-body {
    padding: 15px;
}

.product-card .product-name {
    font-size: 1.1rem;
    font-weight: 600;
    margin-bottom: 8px;
    color: #555;
    min-height: 40px; /* Prevent layout shifts */
}

.product-card .star-rating {
    margin-bottom: 10px;
    color: #f8d64e; /* Gold color for stars */
}
.star-rating .bx { /* Boxicons star */
    font-size: 1rem;
    margin: 0 1px;
}
.star-rating .checked {
    color: #f8d64e;
}
.star-rating .bxs-star:not(.checked) { /* Style for empty stars */
     color: #ddd;
}


.product-card .product-price {
    font-size: 1.2rem;
    font-weight: bold;
    color: #D5006D; /* Primary pink */
    margin-bottom: 10px;
}

.product-card .product-price span {
    margin-left: 15px;
}

.btn-add-cart-alt {
    font-size: 0.8rem;
    padding: 5px 15px;
}

/* Product Overlay */
.product-overlay {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(255, 255, 255, 0.8); /* Semi-transparent white overlay */
    display: flex;
    flex-direction: column; /* Stack buttons vertically */
    align-items: center;
    justify-content: center;
    opacity: 0;
    transition: opacity 0.4s ease;
}

.product-card:hover .product-overlay {
    opacity: 1;
}

.product-overlay .btn-secondary {
    margin: 8px 0; /* Vertical spacing */
}


/* --- Gallery Styles --- */
.gallery-page-section {
    background-color: #fffaf0; /* Floral white background */
}

.gallery-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); /* Responsive grid */
    gap: 25px; /* Gap between items */
}

.gallery-card {
    position: relative;
    overflow: hidden; /* Ensure overlay stays within bounds */
}

.gallery-image {
    display: block;
    width: 100%;
    height: 250px; /* Fixed height for gallery images */
    object-fit: cover; /* Cover the area */
    transition: transform 0.4s ease;
}

.gallery-card:hover .gallery-image {
    transform: scale(1.08); /* Zoom effect on hover */
}

.gallery-overlay {
    position: absolute;
    bottom: 0; /* Position at the bottom */
    left: 0;
    width: 100%;
    background: linear-gradient(transparent, rgba(0, 0, 0, 0.7)); /* Gradient background */
    color: white;
    padding: 20px 15px;
    opacity: 0;
    transform: translateY(100%); /* Start hidden below */
    transition: opacity 0.4s ease, transform 0.4s ease;
    text-align: center;
}

.gallery-card:hover .gallery-overlay {
    opacity: 1;
    transform: translateY(0); /* Slide in from bottom */
}

.gallery-overlay h5 {
    margin: 0;
    font-size: 1.2rem;
    font-weight: bold;
    color: white;
}

/* --- About Page Styles --- */
.about-page-section {
    background-color: #f8f8ff; /* Ghost white background */
}

.about-card-content {
    background-color: white;
    padding: 30px;
    border-radius: 10px;
}
.about-card-content p {
    font-size: 1.1rem;
    line-height: 1.7;
    color: #444;
}
.about-card-content strong {
    color: #D5006D;
}

/* --- Slider Styles (Generic for About, Contact, Gallery) --- */
.slider-section {
    background-color: #fff; /* White background for slider section */
    padding: 40px 0; /* Padding around slider */
}
.carousel {
    border-radius: 10px;
    overflow: hidden; /* Ensure images respect radius */
    box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
}
.carousel-inner img {
    max-height: 500px; /* Limit slider image height */
    object-fit: cover; /* Cover the area */
    width: 100%; /* Ensure full width */
}
.carousel-control-prev-icon,
.carousel-control-next-icon {
    background-color: rgba(0, 0, 0, 0.5); /* Darker control background */
    border-radius: 50%;
    padding: 15px; /* Make controls larger */
    background-size: 50% 50%; /* Adjust icon size */
}
.carousel-control-prev, .carousel-control-next {
     width: 5%; /* Adjust width */
}


/* --- Bottom Banner --- */
.bottom-banner-section {
    position: relative;
    color: white;
    text-shadow: 1px 1px 3px rgba(0, 0, 0, 0.6);
}
.bottom-banner-background {
    padding: 80px 0;
    /* Image path relative to CSS file (in css/) -> ../images/ */
    background-image: linear-gradient(rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0.5)), url('../images/background2.webp'); /* Re-use home background */
    background-size: cover;
    background-position: center center;
    background-attachment: fixed; /* Optional parallax */
}
.bottom-banner-section h2 {
    font-size: 2.8rem;
    font-weight: bold;
    color: white;
    margin-bottom: 1rem;
}
.bottom-banner-section p {
    font-size: 1.2rem;
    color: #eee;
    margin-bottom: 1.5rem;
}
.bottom-banner-section .btn-light { /* Style the light button */
    font-weight: bold;
    color: #D5006D;
    padding: 12px 30px;
    border-radius: 50px;
}

@media (max-width: 768px) {
    .bottom-banner-background {
        padding: 50px 0;
        text-align: center;
        background-attachment: scroll;
    }
    .bottom-banner-section h2 {
        font-size: 2rem;
    }
     .bottom-banner-section p {
        font-size: 1rem;
    }
}


/* --- Contact Page Styles --- */
.contact-page-section {
    background-color: #fffaf0; /* Floral white */
}
.contact-form-container {
     background-color: white;
     padding: 30px;
     border-radius: 10px;
     box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
     max-width: 800px; /* Limit form width */
     margin: auto; /* Center form */
}
.contact-form label {
    font-weight: bold;
    color: #555;
}
.contact-form .form-control {
    border-radius: 5px;
    border: 1px solid #ddd;
    padding: 12px; /* More padding */
    transition: border-color 0.3s ease, box-shadow 0.3s ease;
}
.contact-form .form-control:focus {
    border-color: #FF69B4;
    box-shadow: 0 0 0 0.2rem rgba(255, 105, 180, 0.25); /* Pink focus */
}
.contact-form textarea {
    resize: vertical; /* Allow vertical resize only */
}
.contact-form button[type="submit"] {
     padding: 12px 40px; /* Larger button */
}
.contact-info {
    background-color: #f8f8ff; /* Light background for info */
    padding: 20px;
    border-radius: 10px;
}
.contact-info h4 {
    color: #D5006D;
    margin-bottom: 15px;
}
.contact-info p {
    color: #555;
    margin-bottom: 8px;
}
.contact-info i {
    margin-right: 10px;
    color: #D5006D;
    width: 20px; /* Align icons */
    text-align: center;
}


/* --- Footer Styles --- */
.sweet-footer {
    background-color: rgba(213, 0, 109, 0.9); /* Same as navbar */
    backdrop-filter: blur(8px);
    padding: 40px 0 20px;
    color: rgba(255, 255, 255, 0.8);
    box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.15);
    margin-top: 60px; /* Space above footer */
}

.sweet-footer h1 {
    font-size: 2.5rem;
    font-weight: bold;
    color: white;
    margin-bottom: 10px;
    text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.2);
}

.sweet-footer p {
    color: rgba(255, 255, 255, 0.8);
    font-size: 0.95rem;
}

.sweet-footer .social-icons {
    margin: 25px 0;
}

.sweet-footer .social-icons a {
    color: #D5006D;
    background-color: white;
    border-radius: 50%;
    width: 40px;
    height: 40px;
    display: inline-flex; /* Use flexbox for centering */
    align-items: center;
    justify-content: center;
    margin: 0 10px;
    font-size: 1.1rem;
    transition: background-color 0.3s ease, color 0.3s ease, transform 0.3s ease;
}

.sweet-footer .social-icons a:hover {
    background-color: #FF69B4;
    color: white;
    transform: translateY(-3px);
}

.sweet-footer .copyright {
    font-size: 0.85rem;
    margin-top: 20px;
     color: rgba(255, 255, 255, 0.7);
}

.sweet-footer .credits {
    font-size: 0.8rem;
     color: rgba(255, 255, 255, 0.7);
}
.sweet-footer .credits a {
    color: white;
    font-weight: bold;
}
.sweet-footer .credits a:hover {
    color: #FFC0CB;
}


/* --- Scroll to Top Button --- */
.scroll-to-top-arrow {
    position: fixed;
    background-color: #D5006D;
    border-radius: 50%;
    height: 50px;
    width: 50px;
    bottom: 30px;
    right: 30px;
    text-decoration: none;
    text-align: center;
    color: white;
    transition: background-color 0.3s ease, transform 0.3s ease, opacity 0.3s ease;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
    z-index: 1000;
    opacity: 0; /* Hidden by default */
    visibility: hidden;
    display: flex; /* Center image */
    align-items: center;
    justify-content: center;
    padding: 5px; /* Padding around image */
}
.scroll-to-top-arrow img {
    max-width: 60%; /* Control image size */
    height: auto;
    display: block;
    filter: brightness(0) invert(1); /* Make image white */
}

.scroll-to-top-arrow.visible {
     opacity: 1;
     visibility: visible;
}

.scroll-to-top-arrow:hover {
    background-color: #FF69B4;
    color: white;
    transform: translateY(-5px);
}


/* --- Login/Signup Page Specific Styles --- */
.auth-card {
    background: rgba(255, 255, 255, 0.9); /* Slightly transparent white background */
    border-radius: 1rem;
    width: 100%;
    max-width: 420px; /* Slightly wider */
}
.auth-card label {
    font-weight: bold;
    color: #555;
}
.auth-card .form-control {
     border-radius: 0.5rem;
     padding: 12px;
}
.auth-card .btn-primary {
    padding: 12px; /* Standard padding */
    font-size: 1rem;
}
.auth-card .small a {
    font-weight: bold;
}


/* --- Cart Page Styles --- */
.cart-page-container {
     background-color: #fff;
     padding: 30px;
     border-radius: 10px;
     box-shadow: 0 5px 20px rgba(0, 0, 0, 0.08);
}
.cart-header {
    color: #D5006D;
    font-weight: bold;
}
.cart-item {
    border-bottom: 1px solid #eee;
    padding: 20px 0;
    align-items: center; /* Vertically align items */
}
.cart-item:last-child {
    border-bottom: none;
}
.cart-item-image {
    max-width: 80px;
    height: auto;
    border-radius: 5px;
    object-fit: contain; /* Ensure full image is visible */
}
.cart-item-name {
    font-size: 1.1rem;
    font-weight: 600;
    color: #444;
    margin-bottom: 5px;
}
.cart-item-price {
    color: #666;
    font-size: 0.95rem;
    margin-bottom: 0;
}
.quantity-group .form-control {
    max-width: 60px; /* Limit width */
    text-align: center;
    border-left: none;
    border-right: none;
    border-radius: 0;
    box-shadow: none;
    padding-left: 0.5rem; /* Adjust padding if needed */
    padding-right: 0.5rem;
}
.quantity-group .btn {
     border-radius: 0;
     padding: 0.375rem 0.6rem; /* Adjust padding */
     line-height: 1.5; /* Ensure proper button height */
}
.quantity-group .btn:first-child {
    border-top-left-radius: 0.25rem;
    border-bottom-left-radius: 0.25rem;
}
.quantity-group .btn:last-child {
    border-top-right-radius: 0.25rem;
    border-bottom-right-radius: 0.25rem;
}
.cart-item-subtotal p {
    font-weight: bold;
    color: #333;
    margin-bottom: 0;
    font-size: 1.1rem;
}
.remove-item-btn {
     padding: 5px 10px;
     font-size: 0.8rem;
}
.total-section h4 {
    color: #D5006D;
    font-weight: bold;
    margin-bottom: 15px;
}
#checkout-button:disabled {
    background-color: #ccc;
    border-color: #ccc;
    cursor: not-allowed;
}


/* --- Utility Classes --- */
.bg-light {
    background-color: #f8f9fa !important;
}
.py-5 { padding-top: 3rem !important; padding-bottom: 3rem !important; }
.my-5 { margin-top: 3rem !important; margin-bottom: 3rem !important; }
.mb-4 { margin-bottom: 1.5rem !important; }
.mt-4 { margin-top: 1.5rem !important; }
.mt-3 { margin-top: 1rem !important; }
.mt-5 { margin-top: 3rem !important; }
.mb-3 { margin-bottom: 1rem !important; }
.text-center { text-align: center !important; }
.text-right { text-align: right !important; }
.text-left { text-align: left !important; }
.d-none { display: none !important; }
/* Add more Bootstrap utility classes if needed */

/* Ensure form validation feedback is visible */
.needs-validation .invalid-feedback {
    display: none; /* Hide by default */
    width: 100%;
    margin-top: .25rem;
    font-size: .875em; /* Adjust size */
    color: #dc3545; /* Bootstrap's danger color */
}

/* Style invalid fields */
.needs-validation .form-control:invalid,
.needs-validation .was-validated .form-control:invalid {
  border-color: #dc3545;
}
.needs-validation .form-control:invalid:focus,
.needs-validation .was-validated .form-control:invalid:focus {
  box-shadow: 0 0 0 .25rem rgba(220, 53, 69, .25);
}

/* Show feedback message only when invalid AND after validation attempt */
.needs-validation.was-validated .form-control:invalid ~ .invalid-feedback,
.needs-validation .form-control.is-invalid ~ .invalid-feedback {
    display: block;
}

/* Custom feedback display for password mismatch */
#passwordMismatch {
    color: red; /* Make sure it's red */
    display: none; /* Hide by default */
}
/* Show passwordMismatch only when confirm field is specifically marked as invalid */
#confirmPassword.is-invalid ~ #passwordMismatch {
    display: block;
}
/* Hide default 'confirm password' feedback when mismatch is shown */
#confirmPassword.is-invalid ~ #confirmPasswordFeedback {
    display: none;
}


EOF

# --- Create JavaScript File (In js/ directory) ---
echo "Creating JavaScript file: $JS_FILE ..."

# js/script.js (Content remains the same, no internal path changes needed)
cat << 'EOF' > "$JS_FILE"
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
EOF

# --- Create SQLite Database and Tables ---
DB_ABS_PATH="$PROJECT_ROOT/$DB_FILE" # Use absolute path for sqlite3 command

# Check if DB file exists before attempting to create
if [ ! -f "$DB_ABS_PATH" ]; then
    echo "Creating SQLite database and tables..."
    # Ensure the db directory exists
    mkdir -p "$DB_DIR"
    sqlite3 "$DB_ABS_PATH" <<EOF
-- Enable foreign key support if needed later
-- PRAGMA foreign_keys = ON;

-- Products Table
CREATE TABLE IF NOT EXISTS products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    price REAL NOT NULL,
    image TEXT NOT NULL, -- Store just the filename
    category TEXT,
    rating INTEGER DEFAULT 3 CHECK(rating >= 0 AND rating <= 5) -- Added constraint
);

-- Gallery Items Table
CREATE TABLE IF NOT EXISTS gallery_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    image TEXT NOT NULL UNIQUE, -- Filename only, should be unique?
    title TEXT NOT NULL
);

-- Slider Images Table
CREATE TABLE IF NOT EXISTS slider_images (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    page TEXT NOT NULL, -- 'about', 'contact', 'gallery', 'home' etc.
    image TEXT NOT NULL, -- Filename only
    alt_text TEXT
);

-- Contact Messages Table
CREATE TABLE IF NOT EXISTS messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    subject TEXT,
    message TEXT NOT NULL,
    received_at TEXT NOT NULL -- Store as ISO8601 string (e.g., using PHP date('c'))
);

-- Orders Table
CREATE TABLE IF NOT EXISTS orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cake_type TEXT,
    details TEXT,
    quantity INTEGER NOT NULL CHECK(quantity > 0), -- Ensure positive quantity
    customer_name TEXT NOT NULL,
    customer_email TEXT NOT NULL,
    customer_phone TEXT NOT NULL,
    date_needed TEXT, -- Store as YYYY-MM-DD string or similar
    order_status TEXT DEFAULT 'Pending', -- e.g., Pending, Confirmed, Processing, Shipped, Complete, Cancelled
    order_date TEXT NOT NULL, -- Store as ISO8601 string
    total_price REAL -- Might be calculated later
);

-- Indexes for potentially queried columns
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_slider_images_page ON slider_images(page);
CREATE INDEX IF NOT EXISTS idx_messages_received_at ON messages(received_at);
CREATE INDEX IF NOT EXISTS idx_orders_order_date ON orders(order_date);
CREATE INDEX IF NOT EXISTS idx_orders_customer_email ON orders(customer_email);


-- Insert Sample Product Data (using only filenames for images)
INSERT OR IGNORE INTO products (name, price, image, category, rating) VALUES
('Cream Cake', 50.10, 'c1.png', 'Cakes', 3),
('Chocolate Cake', 60.50, 'c2.png', 'Cakes', 3),
('Slice Cake', 15.50, 'c3.png', 'Cakes', 3),
('Fruit Cake', 30.10, 'c4.png', 'Cakes', 5),
('Brown Cake', 10.50, 'c5.png', 'Cakes', 3),
('Slice Cake Special', 15.50, 'c6.png', 'Cakes', 3),
('Fruit Cake Large', 200.10, 'c7.png', 'Cakes', 3),
('Choco Cake', 30.10, 'c8.png', 'Cakes', 5),
('Birthday Cake Fancy', 500.10, 'c9.png', 'Birthday', 5),
('Bir Cup Cake', 300.20, 'c10.png', 'Birthday', 5),
('Birthday Cake Simple', 100.50, 'c11.png', 'Birthday', 5),
('Cup Cake', 50.10, 'c12.png', 'Birthday', 5);

-- Insert Sample Gallery Data (using only filenames)
INSERT OR IGNORE INTO gallery_items (image, title) VALUES
('princesscastle.jpg', 'Princess Castle Cake'),
('superhero.webp', 'Superhero Theme Cake'),
('frozen.jpeg', 'Frozen Inspired Cake'),
('mickey.jpeg', 'Mickey Mouse Cake'),
('princess tiara.webp', 'Princess Tiara Cake'),
('starwars.webp', 'Star Wars Cake'),
('o1.png', 'Donuts'),
('o2.png', 'Ice Cream'),
('o3.png', 'Cup Cake'),
('o4.png', 'Delicious Cake'),
('o5.png', 'Chocolate Cream Cake'),
('o6.png', 'Slice Cake');

-- Insert Sample Slider Data (using only filenames)
INSERT OR IGNORE INTO slider_images (page, image, alt_text) VALUES
('about', 'about1.jpg', 'Beautiful Cake Display'),
('about', 'about2.jpg', 'Wedding Cake Example'),
('about', 'about3.webp', 'Close-up Cake Decoration'),
('contact', 'contact1.jpg', 'Contact Us Banner'),
('contact', 'contact2.jpeg', 'Cake Shop Interior'),
('contact', 'contact3.jpg', 'Happy Customer with Cake'),
('gallery', 'g1.jpg', 'Gallery Showcase 1'),
('gallery', 'g2.jpg', 'Gallery Showcase 2'),
('gallery', 'g3.jpg', 'Gallery Showcase 3');

EOF
    # Set permissions - Allow web server to read/write db file and read/write/execute directory
    chmod 664 "$DB_ABS_PATH" || echo "Warning: Could not set permissions on DB file. Manual check needed."
    chmod 775 "$DB_DIR" || echo "Warning: Could not set permissions on DB directory. Manual check needed."
    # Optional: Set group ownership if needed (replace 'www-data' with your web server group)
    # chown "$(whoami):www-data" "$DB_DIR" "$DB_ABS_PATH" || echo "Warning: Could not set group ownership. Manual check may be needed."

    echo "Database created and populated successfully at '$DB_ABS_PATH'."
else
    echo "Database file '$DB_ABS_PATH' already exists. Skipping creation and population."
    # Still ensure permissions are correct on existing file/dir
    chmod 664 "$DB_ABS_PATH" || echo "Warning: Could not set permissions on existing DB file. Manual check needed."
    chmod 775 "$DB_DIR" || echo "Warning: Could not set permissions on existing DB directory. Manual check needed."
fi

# --- Final Instructions ---
echo "-----------------------------------------------------"
echo "Setup Complete!"
echo "Created directories: $PHP_DIR, $CSS_DIR, $JS_DIR, $IMAGES_DIR, $DB_DIR"
echo "Generated PHP files."
echo "Generated $CSS_FILE and $JS_FILE."
echo "Created placeholder files in '$IMAGES_DIR/'."
echo "Initialized/Checked SQLite database: $DB_FILE"
echo ""
echo ">>> IMPORTANT NEXT STEPS <<<"
echo "1. Replace the empty placeholder files in the '$IMAGES_DIR/' directory with your ACTUAL image files. Ensure the filenames match exactly."
echo "2. Make sure you have a web server (like Apache or Nginx) running with PHP and the 'php-sqlite3' (or 'php-pdo_sqlite') extension enabled."
echo "3. Configure your web server's document root to point to this directory ($PROJECT_ROOT)."
echo "4. VERY IMPORTANT: Ensure the web server process (e.g., www-data, apache, nginx) has READ access to ALL files ($CSS_FILE, $JS_FILE, all PHP files, all images) and READ/WRITE access to the '$DB_DIR' directory AND the '$DB_FILE' file itself. Permissions were attempted, but manual verification might be needed (e.g., using 'chmod' and potentially 'chown')."
echo "5. Access the website through your web server (e.g., http://localhost/php/index.php or your configured virtual host like http://sweetslice.test/php/index.php)."
echo "-----------------------------------------------------"

exit 0


#**Summary of Changes from Previous Version:**
#
#1.  **Directory Creation:** `mkdir -p` now includes `$CSS_DIR` and `$JS_DIR`.
#2.  **CSS File Location:** `style.css` is now created inside the `css/` directory (`$CSS_FILE="$CSS_DIR/style.css"`).
#3.  **JS File Location:** `script.js` is now created inside the `js/` directory (`$JS_FILE="$JS_DIR/script.js"`).
#4.  **Path in `header.php`:**
#    *   The CSS link is corrected to `../css/style.css`.
#5.  **Path in `footer.php`:**
#    *   The JS link is corrected to `../js/script.js`.
#6.  **Path in `login.php`/`signup.php`:**
#    *   CSS link is `../css/style.css`.
#    *   JS link is `../js/script.js`.
#7.  **Paths in `css/style.css`:**
#    *   `url()` paths for background images are now `url('../images/...')` because the CSS file is in `css/` and needs to go up one level to the root, then into `images/`.
#8.  **Database Logic:** The `database.php` connection logic and error handling have been made more robust to better report path or permission issues.
#9.  **PHP Data Fetching:** Added checks after `get_db_connection()` in page files to ensure a valid PDO object was returned before attempting queries. Improved error reporting for the user if data fetching fails.
#10. **Final Instructions:** Updated to reflect the correct directory structure and emphasize permission checks.