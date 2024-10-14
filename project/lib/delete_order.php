<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "istylist";

// Establish database connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check the connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Ensure the request method is POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Check if the order ID is provided
    if (isset($_POST['order_id']) && !empty($_POST['order_id'])) {
        $order_id = intval($_POST['order_id']);

        // Log the received order ID (for debugging purposes)
        error_log("Received order ID: " . $order_id);

        // Delete the order based on the order ID
        $sql = "DELETE FROM orders WHERE id = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("i", $order_id);

        if ($stmt->execute()) {
            echo json_encode(['success' => true]);
        } else {
            echo json_encode(['success' => false, 'message' => 'Failed to delete order']);
        }

        $stmt->close();
    } else {
        echo json_encode(['success' => false, 'message' => 'Order ID not provided']);
    }
} else {
    error_log("Invalid request method: " . $_SERVER['REQUEST_METHOD']);
    echo json_encode(['success' => false, 'message' => 'Invalid request method']);
}

// Close the database connection
$conn->close();
?>
