<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    http_response_code(405);
    sendJsonResponse(array('status' => 'failed', 'message' => 'Method Not Allowed'));
    exit();
}

$userid = $_POST['user_id'];
$name = addslashes($_POST['name']);
$phone = addslashes($_POST['phone']);
$image = $_POST['image'] ?? "";

$sqlupdateprofile = "UPDATE tbl_users SET user_name = '$name', user_phone = '$phone' WHERE user_id = '$userid'";

try {
    if ($conn->query($sqlupdateprofile) === TRUE) {
        if (!empty($image)) {
            $folder = "../assets/profiles/";

            if (!file_exists($folder)) {
                mkdir($folder, 0777, true);
            }

            $decoded = base64_decode($image);
            $filename = "user_$userid.png";
            $path = $folder . $filename;

            file_put_contents($path, $decoded);

            $dbpath = "assets/profiles/$filename";
            $conn->query("UPDATE tbl_users SET user_image = '$dbpath' WHERE user_id = '$userid'");
        }

        sendJsonResponse([
            'status' => 'success',
            'message' => 'Profile updated successfully'
        ]);
    } else {
        sendJsonResponse([
            'status' => 'failed',
            'message' => 'Profile update failed'
        ]);
    }
} catch (Exception $e) {
    sendJsonResponse([
        'status' => 'failed',
        'message' => $e->getMessage()
    ]);
}

function sendJsonResponse($sentArray)
{
    echo json_encode($sentArray);
}
?>