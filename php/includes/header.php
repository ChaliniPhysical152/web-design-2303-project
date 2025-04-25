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
