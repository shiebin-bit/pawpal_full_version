<?php
$servername = "localhost";
$username = "canortxw_pawpal_shiebin";
$password = "Bmz=ewJ{7F#G";
$dbname = "canortxw_pawpal_shiebin_db";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>