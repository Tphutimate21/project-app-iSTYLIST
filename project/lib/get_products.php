<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");

$db = mysqli_connect('localhost', 'root', '', 'istylist');

if (!$db) {
    http_response_code(500);
    echo json_encode(["error" => "Failed to connect to the database"]);
    exit();
}

// Prepare SQL query to get product data
$query = "SELECT id, product_name, price, profile_image, detail FROM products LIMIT 40";
$stmt = $db->prepare($query);

if (!$stmt) {
    http_response_code(500);
    echo json_encode(["error" => "Failed to prepare statement: " . $db->error]);
    exit();
}

if (!$stmt->execute()) {
    http_response_code(500);
    echo json_encode(["error" => "Failed to execute query"]);
    $stmt->close();
    $db->close();
    exit();
}

// Fetch the result
$result = $stmt->get_result();
$products = [];

while ($row = $result->fetch_assoc()) {
    $products[] = $row;
}

if (empty($products)) {
    echo json_encode(["success" => false, "message" => "No products found"]);
} else {
    echo json_encode(["success" => true, "products" => $products]);
}

// Close connections
$stmt->close();
$db->close();
?>
