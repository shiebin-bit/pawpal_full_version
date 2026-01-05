<?php
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'GET') {
    http_response_code(405);
    sendJsonResponse(array('status' => 'failed', 'message' => 'Method Not Allowed'));
    exit();
}

$search = $_GET['search'] ?? "";
$type = $_GET['type'] ?? "All";

$sql = "SELECT * FROM tbl_pets WHERE 1=1";

if (!empty($search)) {
    $sql .= " AND pet_name LIKE '%$search%'";
}
if ($type != "All") {
    $sql .= " AND pet_type = '$type'";
}

$sql .= " ORDER BY created_at DESC";

try {
    $result = $conn->query($sql);
    if ($result && $result->num_rows > 0) {
        $pets = array();
        while ($row = $result->fetch_assoc()) {
            $pets[] = $row;
        }
        sendJsonResponse(array("status" => "success", "data" => $pets));
    } else {
        sendJsonResponse(array("status" => "failed", "data" => null));
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