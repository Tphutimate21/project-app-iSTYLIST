<?php
// เปิดการแสดงผลข้อผิดพลาดสำหรับการดีบัก
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// ตั้งค่า Headers เพื่อให้สามารถเรียกใช้ API ได้จากที่อื่น
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// เชื่อมต่อฐานข้อมูล
$db = mysqli_connect('localhost', 'root', '', 'istylist');

if (!$db) {
    error_log("Database connection failed: " . mysqli_connect_error());
    http_response_code(500); // Internal Server Error
    echo json_encode(["success" => false, "message" => "Failed to connect to database."]);
    exit();
}

// ตรวจสอบว่าเป็นการร้องขอแบบ POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405); // Method Not Allowed
    echo json_encode(["success" => false, "message" => "Only POST method is allowed."]);
    exit();
}

// รับข้อมูล JSON ที่ส่งมา
$data = json_decode(file_get_contents('php://input'), true);

// ตรวจสอบการแปลง JSON
if ($data === null && json_last_error() !== JSON_ERROR_NONE) {
    http_response_code(400); // Bad Request
    echo json_encode(["success" => false, "message" => "Invalid JSON data. Error: " . json_last_error_msg()]);
    exit();
}

// ตรวจสอบว่าพารามิเตอร์ครบถ้วน
if (!isset($data['user_id'], $data['address'], $data['payment_method'], $data['items'], $data['total_price'])) {
    http_response_code(400); // Bad Request
    echo json_encode(["success" => false, "message" => "Missing required fields."]);
    exit();
}

// เริ่ม transaction
mysqli_begin_transaction($db);

try {
    // บันทึกคำสั่งซื้อในตาราง orders
    $stmt = $db->prepare("INSERT INTO orders (user_id, address, payment_method, grand_total) VALUES (?, ?, ?, ?)");
    if (!$stmt) {
        throw new Exception("Failed to prepare statement: " . $db->error);
    }

    $stmt->bind_param("issd", $data['user_id'], $data['address'], $data['payment_method'], $data['total_price']);
    if (!$stmt->execute()) {
        throw new Exception("Failed to execute order: " . $stmt->error);
    }

    // รับ order_id ที่เพิ่งสร้าง
    $order_id = $stmt->insert_id;
    $stmt->close();

    // บันทึกสินค้าที่สั่งซื้อในตาราง order_details
    $stmt_items = $db->prepare("INSERT INTO order_details (order_id, product_id, product_name, price, quantity, total) VALUES (?, ?, ?, ?, ?, ?)");
    if (!$stmt_items) {
        throw new Exception("Failed to prepare order items statement: " . $db->error);
    }

    foreach ($data['items'] as $item) {
        $total = $item['price'] * $item['quantity'];
        $stmt_items->bind_param("iisddi", $order_id, $item['product_id'], $item['product_name'], $item['price'], $item['quantity'], $total);
        if (!$stmt_items->execute()) {
            throw new Exception("Failed to insert order items: " . $stmt_items->error);
        }
    }
    $stmt_items->close();

    // Commit transaction
    mysqli_commit($db);

    // ส่งผลลัพธ์ความสำเร็จกลับไป
    echo json_encode(["success" => true, "message" => "Order placed successfully", "order_id" => $order_id]);

} catch (Exception $e) {
    // Rollback ถ้ามีข้อผิดพลาด
    mysqli_rollback($db);
    http_response_code(500); // Internal Server Error
    error_log("Error in order processing: " . $e->getMessage());
    echo json_encode(["success" => false, "message" => "Error: " . $e->getMessage()]);
}

// ปิดการเชื่อมต่อฐานข้อมูล
$db->close();
?>
