<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "istylist"; 

// สร้างการเชื่อมต่อกับฐานข้อมูล
$conn = new mysqli($servername, $username, $password, $dbname);

// ตรวจสอบการเชื่อมต่อ
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// ดึงข้อมูลการสั่งซื้อทั้งหมดจากตาราง orders
$sql = "SELECT order_date, email, grand_total FROM orders ORDER BY order_date DESC";
$result = $conn->query($sql);

$orderHistory = [];

if ($result && $result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $orderHistory[] = [
            'order_date' => $row['order_date'],
            'email' => $row['email'],
            'grand_total' => $row['grand_total']
        ];
    }
}

// ส่งข้อมูลเป็น JSON
header('Content-Type: application/json');
echo json_encode($orderHistory);

// ปิดการเชื่อมต่อฐานข้อมูล
$conn->close();
?>
