<?php
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    http_response_code(405);
    sendJsonResponse(array('status' => 'failed', 'message' => 'Method Not Allowed'));
    exit();
}

if (!isset($_POST['user_id']) || !isset($_POST['pet_id'])) {
    http_response_code(400);
    sendJsonResponse(array("status" => "failed", "message" => "Missing data"));
    exit();
}

$user_id = $_POST['user_id'];
$pet_id = $_POST['pet_id'];
$message = addslashes($_POST['message']);

$sql = "INSERT INTO tbl_adoptions (pet_id, user_id, message) VALUES ('$pet_id', '$user_id', '$message')";

try {
    if ($conn->query($sql) === TRUE) {
        sendJsonResponse(array("status" => "success", "message" => "Request submitted"));
    } else {
        sendJsonResponse(array("status" => "failed", "message" => "Error submitting request"));
    }
} catch (Exception $e) {
    sendJsonResponse(array("status" => "failed", "message" => $e->getMessage()));
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>