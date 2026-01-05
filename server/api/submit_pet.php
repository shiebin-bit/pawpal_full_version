<?php
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    http_response_code(405);
    sendJsonResponse(array('status' => 'failed', 'message' => 'Method Not Allowed'));
    exit();
}

if (!isset($_POST['userid']) || !isset($_POST['pet_name'])) {
    http_response_code(400);
    sendJsonResponse(array("status" => "failed", "message" => "Bad Request"));
    exit();
}

$user_id = $_POST['userid'];
$pet_name = addslashes($_POST['pet_name']);
$pet_type = $_POST['pet_type'];
$pet_gender = $_POST['pet_gender'];
$pet_age = $_POST['pet_age'];
$pet_health = $_POST['pet_health'];
$category = $_POST['category'];
$description = addslashes($_POST['description']);
$lat = $_POST['latitude'] ?? "0";
$lng = $_POST['longitude'] ?? "0";
$status = "Available";

$image1 = $_POST['image1'] ?? "";
$image2 = $_POST['image2'] ?? "";
$image3 = $_POST['image3'] ?? "";

$sqlinsert = "INSERT INTO `tbl_pets` 
(`user_id`, `pet_name`, `pet_type`, `pet_gender`, `pet_age`, `pet_health`, `category`, `description`, `image_paths`, `lat`, `lng`, `status`, `created_at`) 
VALUES ('$user_id', '$pet_name', '$pet_type', '$pet_gender', '$pet_age', '$pet_health', '$category', '$description', '', '$lat', '$lng', '$status', NOW())";

try {
    if ($conn->query($sqlinsert) === TRUE) {
        $last_id = $conn->insert_id;

        $imageFolder = "../assets/pets/";

        if (!file_exists($imageFolder)) {
            mkdir($imageFolder, 0777, true);
        }

        $savedImages = array();

        function saveImage($base64, $petId, $index, $folder)
        {
            if (!empty($base64)) {
                $decoded = base64_decode($base64);
                $filename = "pet_" . $petId . "_" . $index . ".png";
                file_put_contents($folder . $filename, $decoded);
                return "assets/pets/" . $filename; // Path stored in DB
            }
            return null;
        }

        $path1 = saveImage($image1, $last_id, 1, $imageFolder);
        if ($path1)
            $savedImages[] = $path1;

        $path2 = saveImage($image2, $last_id, 2, $imageFolder);
        if ($path2)
            $savedImages[] = $path2;

        $path3 = saveImage($image3, $last_id, 3, $imageFolder);
        if ($path3)
            $savedImages[] = $path3;

        $paths = implode(",", $savedImages);
        $conn->query("UPDATE `tbl_pets` SET `image_paths`='$paths' WHERE `pet_id`='$last_id'");

        sendJsonResponse(array("status" => "success", "message" => "Pet submitted successfully"));
    } else {
        sendJsonResponse(array("status" => "failed", "message" => "Database Error"));
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