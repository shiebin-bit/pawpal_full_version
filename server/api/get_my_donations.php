<?php
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'GET') {
    http_response_code(405);
    sendJsonResponse(array('status' => 'failed', 'message' => 'Method Not Allowed'));
    exit();
}

$user_id = $_GET['user_id'];

$sql = "SELECT tbl_donations.*, tbl_pets.pet_name 
        FROM tbl_donations 
        JOIN tbl_pets ON tbl_donations.pet_id = tbl_pets.pet_id 
        WHERE tbl_donations.user_id = '$user_id' 
        ORDER BY donation_date DESC";

try {
    $result = $conn->query($sql);
    $donations = array();
    while ($row = $result->fetch_assoc()) {
        $donations[] = $row;
    }
    sendJsonResponse(array("status" => "success", "data" => $donations));
} catch (Exception $e) {
    sendJsonResponse(array("status" => "failed", "message" => $e->getMessage()));
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>