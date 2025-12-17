<?php
// Logout handler

session_start();
session_destroy();
header('Location: /vulnerable-app/home');
exit;
?>
