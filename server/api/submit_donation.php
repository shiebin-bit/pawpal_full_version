<?php
error_reporting(0);
include 'dbconnect.php';

$userid = $_GET['userid'];
$petid = $_GET['petid'];
$amount = $_GET['amount'];
$email = $_GET['email'];
$phone = $_GET['phone'];
$name = $_GET['name'];
$type = $_GET['type'] ?? 'Money';
$description = $_GET['description'];

if (empty($description)) {
    $description = "Donation: " . $type;
}

if (empty($email) || empty($name)) {
    $sqlUser = "SELECT * FROM tbl_users WHERE user_id = '$userid'";
    $resultUser = $conn->query($sqlUser);
    if ($resultUser->num_rows > 0) {
        $rowUser = $resultUser->fetch_assoc();
        $email = $rowUser['user_email'];
        $name = $rowUser['user_name'];
        $phone = $rowUser['user_phone'];
    }
}

if ($amount <= 0) {
    $sqlinsert = "INSERT INTO `tbl_donations` (`pet_id`, `user_id`, `donation_type`, `amount`, `description`, `donation_date`) 
                  VALUES ('$petid', '$userid', '$type', '$amount', '$description', NOW())";

    if ($conn->query($sqlinsert) === TRUE) {
        echo "<script>window.location.href='https://canorcannot.com/ShieBin/pawpal/server/api/payment_success.php?status=success&msg=DonationRecorded&name=$name&amount=$amount'</script>";
    } else {
        echo "Database Error: " . $conn->error;
    }
    exit();
}

$api_key = '3db83dd2-f605-4279-8ed2-7b1cea64fbe0';
$collection_id = 'ftwclll3';
$host = 'https://www.billplz-sandbox.com/api/v3/bills';

$data = array(
    'collection_id' => $collection_id,
    'email' => $email,
    'mobile' => $phone,
    'name' => $name,
    'amount' => $amount * 100,
    'description' => 'Donation for Pet ID: ' . $petid,
    'callback_url' => "https://canorcannot.com/ShieBin/pawpal/server/api/payment_success.php",
    'redirect_url' => "https://canorcannot.com/ShieBin/pawpal/server/api/payment_success.php?userid=$userid&petid=$petid&amount=$amount&type=$type&name=$enc_name&email=$enc_email"
);

$process = curl_init($host);
curl_setopt($process, CURLOPT_HEADER, 0);
curl_setopt($process, CURLOPT_USERPWD, $api_key . ":");
curl_setopt($process, CURLOPT_TIMEOUT, 30);
curl_setopt($process, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($process, CURLOPT_SSL_VERIFYHOST, 0);
curl_setopt($process, CURLOPT_SSL_VERIFYPEER, 0);
curl_setopt($process, CURLOPT_POSTFIELDS, http_build_query($data));

$return = curl_exec($process);
curl_close($process);

$bill = json_decode($return, true);

if (isset($bill['url'])) {
    header("Location: {$bill['url']}");
} else {
    echo "<h3>Payment Gateway Error</h3>";
    echo "<p>Please ensure amount is at least RM 1.00</p>";
    echo "<pre>";
    print_r($bill);
    echo "</pre>";
}
?>