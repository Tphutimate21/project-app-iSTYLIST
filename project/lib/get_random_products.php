<?php
header('Content-Type: application/json');

// Database credentials
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "istylist";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection with more detailed error message
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode([
        "error" => "Connection failed",
        "details" => $conn->connect_error
    ]);
    exit();
}

// SQL query to fetch 4 random products
$sql = "SELECT id, product_name, price, profile_image, detail FROM products ORDER BY RAND() LIMIT 4";
$result = $conn->query($sql);

// Check if the query executed successfully
if (!$result) {
    http_response_code(500);
    echo json_encode([
        "error" => "Failed to execute query",
        "details" => $conn->error
    ]);
    $conn->close();
    exit();
}

$products = [];

// If products are found, loop through the results and add them to the array
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $products[] = [
            "id" => $row['id'],
            "product_name" => $row['product_name'],
            "price" => (float)$row['price'],
            "profile_image" => $row['profile_image'],
            "detail" => $row['detail']
        ];
    }
}

// Return the products or an empty array if none are found
echo json_encode($products);

$conn->close();
?>
