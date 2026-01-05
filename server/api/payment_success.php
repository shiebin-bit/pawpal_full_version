<?php
error_reporting(0);
include_once("dbconnect.php");

$userid = $_GET['userid'];
$petid = $_GET['petid'];
$amount = $_GET['amount'];
$email = $_GET['email'];
$name = $_GET['name'];
$phone = $_GET['phone'];
$type = $_GET['type'] ?? 'Money';
$status = $_GET['status'] ?? '';

if ((empty($name) || empty($email)) && !empty($userid)) {
    $sqlUser = "SELECT * FROM tbl_users WHERE user_id = '$userid'";
    $resultUser = $conn->query($sqlUser);
    if ($resultUser->num_rows > 0) {
        $rowUser = $resultUser->fetch_assoc();

        if (empty($name)) {
            $name = $rowUser['user_name'];
        }
        if (empty($email)) {
            $email = $rowUser['user_email'];
        }
        if (empty($phone)) {
            $phone = $rowUser['user_phone'];
        }
    }
}

$paidstatus = "Failed";
$receiptid = "Error";

if (isset($_GET['billplz']['paid'])) {
    $paidstatus_raw = $_GET['billplz']['paid'];
    $receiptid = $_GET['billplz']['id'];

    if ($paidstatus_raw == "true") {
        $paidstatus = "Success";

        $sqlCheck = "SELECT * FROM tbl_donations WHERE description LIKE '%$receiptid%'";
        $resultCheck = $conn->query($sqlCheck);

        if ($resultCheck->num_rows == 0) {
            $sql = "INSERT INTO tbl_donations (pet_id, user_id, donation_type, amount, description, donation_date) 
                    VALUES ('$petid', '$userid', '$type', '$amount', 'Payment Successful (Bill: $receiptid)', NOW())";
            $conn->query($sql);
        }
    }
} else {
    if ($status == "success") {
        $paidstatus = "Success";
        $receiptid = "Manual-" . time();
    }
}

$status_color = ($paidstatus == "Success") ? "green" : "red";

?>

<!DOCTYPE html>
<html>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">

<body>
    <center>
        <br><br>
        <div class="w3-card-4" style="width:90%; max-width:400px;">
            <header class="w3-container w3-<?php echo $status_color; ?>">
                <h3>Payment <?php echo $paidstatus; ?></h3>
            </header>
            <div class="w3-container">
                <br>
                <table class='w3-table w3-striped'>
                    <tr>
                        <td>Receipt</td>
                        <td><?php echo $receiptid; ?></td>
                    </tr>
                    <tr>
                        <td>Paid By</td>
                        <td><?php echo $name; ?></td>
                    </tr>
                    <tr>
                        <td>Email</td>
                        <td><?php echo $email; ?></td>
                    </tr>
                    <tr>
                        <td>Phone</td>
                        <td><?php echo $phone; ?></td>
                    </tr>
                    <tr>
                        <td>Amount</td>
                        <td>RM <?php echo number_format((float) $amount, 2, '.', ''); ?></td>
                    </tr>
                    <tr>
                        <td>Status</td>
                        <td class='w3-text-<?php echo $status_color; ?>'><b><?php echo $paidstatus; ?></b></td>
                    </tr>
                </table>
                <br>

                <a href="pawpal://return" class="w3-btn w3-block w3-dark-grey">Return to App</a>
                <br><br>
            </div>
        </div>
    </center>
</body>

</html>