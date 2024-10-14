<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");

// Database credentials
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "istylist";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(["error" => "Connection failed: " . $conn->connect_error]);
    exit();
}

// Get product ID from the request
$productId = isset($_GET['id']) ? intval($_GET['id']) : 0;

// Prepare the SQL statement to prevent SQL injection
$sql = $conn->prepare("SELECT id, product_name, price, profile_image, detail FROM products WHERE id = ?");
$sql->bind_param("i", $productId);

// Execute the query
$sql->execute();
$result = $sql->get_result();

// Check if product exists
if ($result->num_rows > 0) {
    $product = $result->fetch_assoc();
    echo json_encode(["success" => true, "product" => $product]);
} else {
    http_response_code(404);
    echo json_encode(["success" => false, "message" => "Product not found"]);
}

// Close connection
$sql->close();
$conn->close();
?>
