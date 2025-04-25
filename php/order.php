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
