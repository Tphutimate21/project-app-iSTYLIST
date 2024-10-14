<?php
session_start();
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// เชื่อมต่อกับฐานข้อมูล
$db = mysqli_connect('localhost', 'root', '', 'istylist');

if (!$db) {
    http_response_code(500);
    echo json_encode(["error" => "Error connecting to the database"]);
    exit();
}

// ตรวจสอบว่าได้รับ user_id หรือไม่ และเป็นค่าที่ไม่ว่างเปล่า
if (!isset($_GET['user_id']) || empty(trim($_GET['user_id']))) {
    http_response_code(400);
    echo json_encode(["error" => "Missing or empty user_id"]);
    exit();
}

$user_id = mysqli_real_escape_string($db, trim($_GET['user_id']));

// ดึงข้อมูลโปรไฟล์ผู้ใช้จากฐานข้อมูล
$stmt = $db->prepare("SELECT username, email FROM users WHERE id = ?");
if (!$stmt) {
    http_response_code(500);
    echo json_encode(["error" => "Error preparing statement: " . $db->error]);
    $db->close();
    exit();
}

$stmt->bind_param("i", $user_id);

if (!$stmt->execute()) {
    http_response_code(500);
    echo json_encode(["error" => "Error executing statement: " . $stmt->error]);
    $stmt->close();
    $db->close();
    exit();
}

$result = $stmt->get_result();
$user = $result->fetch_assoc();

if ($user) {
    // ส่งสถานะ 200 OK ในกรณีที่พบผู้ใช้
    http_response_code(200);
    echo json_encode([
        "success" => true,
        "username" => $user['username'],
        "email" => $user['email']
    ]);
} else {
    http_response_code(404);
    echo json_encode(["error" => "User not found"]);
}

// ปิด statement และการเชื่อมต่อฐานข้อมูล
$stmt->close();
$db->close();
?>
