<?php
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {

    if (!isset($_GET['user_id'])) {
        sendJsonResponse(array("status" => "failed", "data" => null));
        exit();
    }

    $user_id = $_GET['user_id'];

    $sql = "SELECT 
                pet_id,
                user_id,
                pet_name,
                pet_type,
                pet_gender, 
                pet_age,
                pet_health,
                category,
                description,
                image_paths,
                lat,
                lng,
                status,
                created_at
            FROM tbl_pets
            WHERE user_id = '$user_id'
            ORDER BY created_at DESC";

    $result = $conn->query($sql);

    if ($result && $result->num_rows > 0) {
        $petdata = array();
        while ($row = $result->fetch_assoc()) {
            $petdata[] = $row;
        }
        sendJsonResponse(array("status" => "success", "data" => $petdata));
    } else {
        sendJsonResponse(array("status" => "success", "data" => null)); // Success but empty
    }

} else {
    sendJsonResponse(array("status" => "failed", "message" => "Method Not Allowed"));
    exit();
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>