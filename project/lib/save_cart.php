<?php
session_start();
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "istylist";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

// ตรวจสอบว่าผู้ใช้ล็อกอินแล้วหรือยัง
if (!isset($_SESSION['user_id'])) {
    echo json_encode(["error" => "User not logged in."]);
    exit();
}

$user_id = $_SESSION['user_id'];
$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['cartItems'])) {
    echo json_encode(["error" => "No cart items provided."]);
    exit();
}

$cartItems = $data['cartItems'];

// ลบข้อมูล cart เก่าของผู้ใช้ในฐานข้อมูลก่อน
$sql = "DELETE FROM cart WHERE user_id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $user_id);
$stmt->execute();
$stmt->close();

// บันทึกข้อมูล cart ใหม่ลงในฐานข้อมูล
$sql = "INSERT INTO cart (user_id, product_id, title, image, price, quantity) VALUES (?, ?, ?, ?, ?, ?)";
$stmt = $conn->prepare($sql);

foreach ($cartItems as $item) {
    $product_id = $item['product_id'];
    $title = $item['title'];
    $image = $item['image'];
    $price = $item['price'];
    $quantity = $item['quantity'];
    $stmt->bind_param("iissdi", $user_id, $product_id, $title, $image, $price, $quantity);
    $stmt->execute();
}

$stmt->close();
$conn->close();

echo json_encode(["success" => true]);
?>
