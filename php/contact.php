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
