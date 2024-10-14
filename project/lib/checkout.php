<?php
session_start(); // เริ่มต้นเซสชัน

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Cookie');
header('Content-Type: application/json');

$db = mysqli_connect('localhost', 'root', '', 'istylist');

if (!$db) {
    http_response_code(500);
    echo json_encode(["error" => "Error connecting to the database: " . mysqli_connect_error()]);
    exit();
}

if (!isset($_SESSION['user_id'])) {
    http_response_code(401);
    echo json_encode(["error" => "Error: User not logged in."]);
    exit();
}

$user_id = $_SESSION['user_id'];

// ตรวจสอบว่าได้ข้อมูลครบหรือไม่
if (!isset($_POST['name'], $_POST['email'], $_POST['address'], $_POST['items'])) {
    echo json_encode(["success" => false, "message" => "Error: Missing required parameters."]);
    exit();
}

$name = $conn->real_escape_string($_POST['name']);
$email = $conn->real_escape_string($_POST['email']);
$address = $conn->real_escape_string($_POST['address']);
$items = json_decode($_POST['items'], true);

// ตรวจสอบว่าการแปลง JSON สำเร็จหรือไม่
if (json_last_error() !== JSON_ERROR_NONE) {
    echo json_encode(["success" => false, "message" => "Error: Failed to decode items."]);
    exit();
}

// คำนวณราคาสินค้าทั้งหมด
$grand_total = 0;
foreach ($items as $item) {
    $grand_total += $item['price'] * $item['quantity'];
}

// เตรียมคำสั่ง SQL และใช้ prepared statement เพื่อเพิ่มความปลอดภัย
$stmt = $conn->prepare("INSERT INTO orders (user_id, name, email, address, grand_total) VALUES (?, ?, ?, ?, ?)");
if ($stmt === false) {
    echo json_encode(["success" => false, "message" => "Error: " . $conn->error]);
    exit();
}

$stmt->bind_param("isssd", $user_id, $name, $email, $address, $grand_total);

// ตรวจสอบการทำงานของ statement
if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Order placed successfully"]);
} else {
    echo json_encode(["success" => false, "message" => "Error: " . $stmt->error]);
}

// ปิด statement และการเชื่อมต่อฐานข้อมูล
$stmt->close();
$conn->close();
?>
