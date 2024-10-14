<?php
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

// รับข้อมูล JSON จาก request body
$data = json_decode(file_get_contents('php://input'), true);

// ตรวจสอบว่าได้รับข้อมูล `user_id` มาหรือไม่
if (!isset($data['user_id']) || empty(trim($data['user_id']))) {
    http_response_code(400);
    echo json_encode(["error" => "Error: Missing or empty user ID."]);
    exit();
}

$user_id = $data['user_id'];

// ตรวจสอบว่าได้รับข้อมูลที่อยู่ครบถ้วนหรือไม่
$required_fields = ['address', 'city', 'state', 'postal_code', 'country'];
foreach ($required_fields as $field) {
    if (!isset($data[$field]) || empty(trim($data[$field]))) {
        http_response_code(400);
        echo json_encode(["error" => "Error: Missing or empty field: $field"]);
        exit();
    }
}

$address = $data['address'];
$city = $data['city'];
$state = $data['state'];
$postal_code = $data['postal_code'];
$country = $data['country'];

// เตรียม statement เพื่อเพิ่มที่อยู่ใหม่
$stmt = $db->prepare("INSERT INTO addresses (user_id, address, city, state, postal_code, country) VALUES (?, ?, ?, ?, ?, ?)");
if (!$stmt) {
    http_response_code(500);
    echo json_encode(["error" => "Error preparing statement: " . $db->error]);
    exit();
}

$stmt->bind_param("isssss", $user_id, $address, $city, $state, $postal_code, $country);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Address added successfully."]);
} else {
    http_response_code(500);
    echo json_encode(["error" => "Error adding address: " . $stmt->error]);
}

// ปิด statement และการเชื่อมต่อฐานข้อมูล
$stmt->close();
$db->close();
?>
