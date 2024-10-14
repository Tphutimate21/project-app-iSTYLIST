<?php
session_start(); // เริ่มต้นเซสชัน

// เพิ่ม CORS headers
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// เชื่อมต่อกับฐานข้อมูล
$db = mysqli_connect('localhost', 'root', '', 'istylist');

if (!$db) {
    http_response_code(500);
    echo json_encode(["error" => "Error connecting to the database: " . mysqli_connect_error()]);
    exit();
}

// Debugging: ตรวจสอบว่ามีข้อมูลอะไรอยู่ใน $_POST หรือไม่
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    echo json_encode(["debug_post" => $_POST]);
}

// ตรวจสอบว่ามีข้อมูล username และ password ถูกส่งมาใน request หรือไม่
if (empty($_POST['username']) || empty($_POST['password'])) {
    http_response_code(400);
    echo json_encode(["error" => "Error: Missing username or password"]);
    exit();
}

$username = $_POST['username'];
$password = $_POST['password'];

// เตรียม statement สำหรับเลือกข้อมูลจากฐานข้อมูล
$stmt = $db->prepare("SELECT id, password FROM users WHERE username = ?");
if (!$stmt) {
    http_response_code(500);
    echo json_encode(["error" => "Error preparing statement: " . $db->error]);
    $db->close();
    exit();
}

// Bind และ execute statement
$stmt->bind_param("s", $username);
if (!$stmt->execute()) {
    http_response_code(500);
    echo json_encode(["error" => "Error executing statement: " . $stmt->error]);
    $stmt->close();
    $db->close();
    exit();
}

// Get result
$result = $stmt->get_result();

// ตรวจสอบผลลัพธ์
if ($result && $result->num_rows === 1) {
    $row = $result->fetch_assoc();
    $hashed_password = $row['password'];

    // ตรวจสอบรหัสผ่านที่ใส่เข้ามาว่าตรงกับรหัสผ่านที่ถูกเข้ารหัสในฐานข้อมูลหรือไม่
    if (password_verify($password, $hashed_password)) {
        // เซสชัน user_id และ username จะถูกตั้งค่าหากการตรวจสอบสำเร็จ
        $_SESSION['user_id'] = $row['id'];
        $_SESSION['username'] = $username;
        session_write_close();
        echo json_encode(["success" => true, "user_id" => $row['id']]);
    } else {
        http_response_code(401);
        echo json_encode(["error" => "Error: Invalid username or password"]);
    }
} else {
    http_response_code(401);
    echo json_encode(["error" => "Error: Invalid username or password"]);
}

// ปิด statement และการเชื่อมต่อฐานข้อมูล
$stmt->close();
$db->close();
?>
