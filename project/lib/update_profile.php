<?php
session_start();
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Connect to the database
$db = mysqli_connect('localhost', 'root', '', 'istylist');

if (!$db) {
    http_response_code(500);
    echo json_encode(["error" => "Error connecting to the database"]);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(["error" => "Method not allowed"]);
    exit();
}

if (!isset($_POST['user_id'])) {
    http_response_code(401);
    echo json_encode(["error" => "User not logged in"]);
    exit();
}

$user_id = mysqli_real_escape_string($db, $_POST['user_id']);
$new_username = isset($_POST['new_username']) ? mysqli_real_escape_string($db, $_POST['new_username']) : null;
$current_password = isset($_POST['current_password']) ? $_POST['current_password'] : null;
$new_password = isset($_POST['new_password']) ? $_POST['new_password'] : null;
$email = isset($_POST['email']) ? mysqli_real_escape_string($db, $_POST['email']) : null;

$update_count = 0; // ตัวแปรเพื่อเก็บจำนวนการอัปเดต

// Update username only if new username is provided
if (!empty($new_username)) {
    $check_stmt = $db->prepare("SELECT id FROM users WHERE username = ? AND id != ?");
    $check_stmt->bind_param("si", $new_username, $user_id);
    $check_stmt->execute();
    $check_result = $check_stmt->get_result();
    
    if ($check_result->num_rows > 0) {
        echo json_encode(["error" => "The username already exists. Please choose a different one."]);
        $check_stmt->close();
        $db->close();
        exit();
    }
    $check_stmt->close();

    $stmt = $db->prepare("UPDATE users SET username = ? WHERE id = ?");
    $stmt->bind_param("si", $new_username, $user_id);
    $stmt->execute();
    if ($stmt->affected_rows > 0) {
        $update_count++;
    }
    $stmt->close();
}

// Update password only if both current and new passwords are provided
if (!empty($current_password) && !empty($new_password)) {
    $stmt = $db->prepare("SELECT password FROM users WHERE id = ?");
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();
    $user = $result->fetch_assoc();
    $stmt->close();

    if ($user && password_verify($current_password, $user['password'])) {
        $hashed_password = password_hash($new_password, PASSWORD_BCRYPT);
        $stmt = $db->prepare("UPDATE users SET password = ? WHERE id = ?");
        $stmt->bind_param("si", $hashed_password, $user_id);
        $stmt->execute();
        if ($stmt->affected_rows > 0) {
            $update_count++;
        }
        $stmt->close();
    } else {
        echo json_encode(["error" => "Current password is incorrect"]);
        exit();
    }
}

// Update email only if a new email is provided
if (!empty($email)) {
    $check_stmt = $db->prepare("SELECT id FROM users WHERE email = ? AND id != ?");
    $check_stmt->bind_param("si", $email, $user_id);
    $check_stmt->execute();
    $check_result = $check_stmt->get_result();
    
    if ($check_result->num_rows > 0) {
        echo json_encode(["error" => "The email already exists. Please choose a different one."]);
        $check_stmt->close();
        $db->close();
        exit();
    }
    $check_stmt->close();

    $stmt = $db->prepare("UPDATE users SET email = ? WHERE id = ?");
    $stmt->bind_param("si", $email, $user_id);
    $stmt->execute();
    if ($stmt->affected_rows > 0) {
        $update_count++;
    }
    $stmt->close();
}

$db->close();

// ตรวจสอบว่ามีการอัปเดตข้อมูลหรือไม่
if ($update_count > 0) {
    echo json_encode(["success" => "Profile updated successfully"]);
} else {
    echo json_encode(["success" => "No changes made to the profile"]);
}
?>
