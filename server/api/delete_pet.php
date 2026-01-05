<?php
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    http_response_code(405);
    sendJsonResponse(array('status' => 'failed', 'message' => 'Method Not Allowed'));
    exit();
}

if (!isset($_POST['pet_id']) || !isset($_POST['user_id'])) {
    http_response_code(400);
    sendJsonResponse(array("status" => "failed", "message" => "Missing IDs"));
    exit();
}

$pet_id = $_POST['pet_id'];
$user_id = $_POST['user_id'];

try {
    $sqlSelect = "SELECT image_paths FROM tbl_pets WHERE pet_id = '$pet_id' AND user_id = '$user_id'";
    $result = $conn->query($sqlSelect);

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $imagesString = $row['image_paths'];

        if (!empty($imagesString)) {
            $images = explode(",", $imagesString);
            foreach ($images as $image) {
                $filePath = "../" . $image;

                if (file_exists($filePath)) {
                    unlink($filePath);
                }
            }
        }

        $sqlDelete = "DELETE FROM tbl_pets WHERE pet_id = '$pet_id' AND user_id = '$user_id'";

        if ($conn->query($sqlDelete) === TRUE) {
            sendJsonResponse(array("status" => "success", "message" => "Pet deleted successfully"));
        } else {
            sendJsonResponse(array("status" => "failed", "message" => "Failed to delete record"));
        }

    } else {
        sendJsonResponse(array("status" => "failed", "message" => "Pet not found or unauthorized"));
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