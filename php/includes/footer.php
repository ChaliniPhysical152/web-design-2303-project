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
