<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

// เชื่อมต่อฐานข้อมูล
$db = mysqli_connect('localhost', 'root', '', 'istylist');

if (!$db) {
    http_response_code(500);
    echo json_encode(["error" => "Error: Unable to connect to the database"]);
    exit();
}

// ตรวจสอบว่ามีข้อมูล username และ password หรือไม่
if (!isset($_POST['username']) || !isset($_POST['password'])) {
    http_response_code(400);
    echo json_encode(["error" => "Error: Missing username or password"]);
    exit();
}

$username = $_POST['username'];
$password = $_POST['password'];

// ตรวจสอบว่าข้อมูล username และ password ว่างหรือไม่
if (empty($username) || empty($password)) {
    http_response_code(400);
    echo json_encode(["error" => "Error: Username or password cannot be empty"]);
    exit();
}

// ตรวจสอบว่ามีการใช้ชื่อผู้ใช้ซ้ำหรือไม่
$stmt = $db->prepare("SELECT username FROM users WHERE username = ?");
if (!$stmt) {
    http_response_code(500);
    echo json_encode(["error" => "Error preparing statement: " . $db->error]);
    exit();
}
$stmt->bind_param("s", $username);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    http_response_code(409); // Conflict
    echo json_encode(["error" => "Error: Username already exists"]);
} else {
    // เข้ารหัสรหัสผ่านก่อนเก็บลงฐานข้อมูล
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);
    
    $insert_stmt = $db->prepare("INSERT INTO users (username, password) VALUES (?, ?)");
    if (!$insert_stmt) {
        http_response_code(500);
        echo json_encode(["error" => "Error preparing insert statement: " . $db->error]);
        exit();
    }
    $insert_stmt->bind_param("ss", $username, $hashed_password);
    
    if ($insert_stmt->execute()) {
        http_response_code(201); // Created
        echo json_encode(["success" => true, "message" => "User registered successfully"]);
    } else {
        http_response_code(500);
        echo json_encode(["error" => "Error: Unable to register user"]);
    }
    $insert_stmt->close();
}

$stmt->close();
$db->close();
?>
