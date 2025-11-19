<?php
// Logout handler
session_destroy();
header('Location: home');
exit;
?>
