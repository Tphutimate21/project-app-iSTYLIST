<?php
$host = 'localhost';
$db = 'istylist';
$user = 'root';
$pass = '';

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Add Order
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $userId = $_POST['user_id'];
    $cartItems = json_decode($_POST['cart_items'], true);  // Decode cart items JSON

    // Create order
    $stmt = $conn->prepare("INSERT INTO orders (user_id) VALUES (?)");
    $stmt->bind_param("s", $userId);
    $stmt->execute();
    $orderId = $stmt->insert_id;  // Get the ID of the new order

    // Add order details
    foreach ($cartItems as $item) {
        $productId = $item['id'];
        $quantity = $item['quantity'];
        $price = $item['price'];

        $stmt = $conn->prepare("INSERT INTO order_details (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)");
        $stmt->bind_param("iiid", $orderId, $productId, $quantity, $price);
        $stmt->execute();
    }

    echo json_encode(['message' => 'Order placed successfully']);
}

$conn->close();
?>
