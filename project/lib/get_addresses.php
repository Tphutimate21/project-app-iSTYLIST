<?php
session_start();

// เพิ่ม CORS headers
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST'); // อนุญาตทั้ง GET และ POST
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// เชื่อมต่อกับฐานข้อมูล
$db = mysqli_connect('localhost', 'root', '', 'istylist');

if (!$db) {
    http_response_code(500);
    echo json_encode(["error" => "Error connecting to the database: " . mysqli_connect_error()]);
    exit();
}

// ตรวจสอบว่ามีการส่ง user_id มาจาก GET หรือไม่ (หากคุณใช้ GET request)
if (isset($_GET['user_id'])) {
    $user_id = $_GET['user_id'];
} elseif (isset($_SESSION['user_id'])) {
    $user_id = $_SESSION['user_id']; // ตรวจสอบจาก $_SESSION หากไม่มีใน $_GET
} else {
    http_response_code(401); // Unauthorized
    echo json_encode(["error" => "User not logged in or no user ID provided."]);
    exit();
}

// เตรียม statement เพื่อดึงข้อมูลที่อยู่ของผู้ใช้
$stmt = $db->prepare("SELECT id, address, city, state, postal_code, country FROM addresses WHERE user_id = ?");
if (!$stmt) {
    http_response_code(500);
    echo json_encode(["error" => "Error preparing statement: " . $db->error]);
    exit();
}

$stmt->bind_param("i", $user_id);

if (!$stmt->execute()) {
    http_response_code(500);
    echo json_encode(["error" => "Error executing statement: " . $stmt->error]);
    $stmt->close();
    exit();
}

$result = $stmt->get_result();
$addresses = [];

while ($row = $result->fetch_assoc()) {
    $addresses[] = $row;
}

// ปิด statement และการเชื่อมต่อฐานข้อมูล
$stmt->close();
$db->close();

// ตอบกลับข้อมูลเป็น JSON
echo json_encode(["success" => true, "addresses" => $addresses]);
?>
