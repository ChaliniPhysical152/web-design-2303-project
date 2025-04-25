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
