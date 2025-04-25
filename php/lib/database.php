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
