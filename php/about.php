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
