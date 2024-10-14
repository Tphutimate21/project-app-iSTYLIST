<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// เชื่อมต่อฐานข้อมูล
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "istylist";

$conn = new mysqli($servername, $username, $password, $dbname);

// ตรวจสอบการเชื่อมต่อฐานข้อมูล
if ($conn->connect_error) {
    http_response_code(500); // Internal Server Error
    echo json_encode(["success" => false, "message" => "Connection failed: " . $conn->connect_error]);
    exit();
}

// รับข้อมูล JSON จาก request body
$data = json_decode(file_get_contents('php://input'), true);

// ตรวจสอบว่ามีพารามิเตอร์ที่ต้องการครบถ้วนหรือไม่
if (!isset($data['user_id'])) {
    http_response_code(400); // Bad Request
    echo json_encode(["success" => false, "message" => "Missing user_id."]);
    exit();
}

$user_id = $data['user_id'];

// คำสั่ง SQL เพื่อดึงประวัติคำสั่งซื้อของผู้ใช้ที่ล็อกอิน
$sql = "SELECT id, name, order_date, grand_total, image_url FROM orders WHERE user_id = ?";
$stmt = $conn->prepare($sql);

if (!$stmt) {
    http_response_code(500); // Internal Server Error
    echo json_encode(["success" => false, "message" => "Failed to prepare SQL statement."]);
    exit();
}

$stmt->bind_param('i', $user_id);
$stmt->execute();
$result = $stmt->get_result();

// สร้าง array เพื่อเก็บประวัติคำสั่งซื้อ
$orderHistory = [];

if ($result && $result->num_rows > 0) {
    // นำข้อมูลจากแต่ละแถวมาเก็บใน array
    while ($row = $result->fetch_assoc()) {
        $orderHistory[] = [
            'id' => $row['id'], // รหัสคำสั่งซื้อ
            'name' => $row['name'],
            'date' => $row['order_date'],
            'price' => $row['grand_total'], // ราคารวม
            'image_url' => $row['image_url'] // URL รูปภาพสินค้า
        ];
    }
    // ส่งข้อมูลประวัติคำสั่งซื้อในรูปแบบ JSON
    echo json_encode(["success" => true, "orders" => $orderHistory]);
} else {
    // ถ้าไม่มีคำสั่งซื้อ ส่งข้อความแสดงว่าไม่มีคำสั่งซื้อ
    echo json_encode(["success" => true, "message" => "No orders found."]);
}

// ปิดการเชื่อมต่อฐานข้อมูล
$stmt->close();
$conn->close();
?>
