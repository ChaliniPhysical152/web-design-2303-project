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
