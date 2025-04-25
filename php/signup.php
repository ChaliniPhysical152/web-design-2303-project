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
