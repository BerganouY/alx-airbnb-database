-- Sample Data Insertion for AirBnB Database
-- Note: I use UUIDv4 for generating unique identifiers

-- Disable foreign key checks for bulk insertion
SET FOREIGN_KEY_CHECKS = 0;

-- Clear existing data (optional, use with caution)
-- TRUNCATE TABLE message;
-- TRUNCATE TABLE review;
-- TRUNCATE TABLE payment;
-- TRUNCATE TABLE booking;
-- TRUNCATE TABLE property;
-- TRUNCATE TABLE user;

-- Insert Users
INSERT INTO user (user_id, first_name, last_name, email, password_hash, phone_number, role, created_at) VALUES
-- Hosts
(UUID(), 'Emily', 'Chen', 'emily.chen@example.com', '$2a$12$aBcDeFgHiJkLmNoPqRsTuVwXyZ1234567890', '+1-555-123-4567', 'host', NOW()),
(UUID(), 'Michael', 'Rodriguez', 'michael.r@example.com', '$2a$12$aBcDeFgHiJkLmNoPqRsTuVwXyZ0987654321', '+1-555-987-6543', 'host', NOW()),
(UUID(), 'Sophie', 'Müller', 'sophie.m@example.com', '$2a$12$aBcDeFgHiJkLmNoPqRsTuVwXyZ1122334455', '+49-30-1234-5678', 'host', NOW()),

-- Guests
(UUID(), 'David', 'Johnson', 'david.j@example.com', '$2a$12$aBcDeFgHiJkLmNoPqRsTuVwXyZ5566778899', '+1-555-246-8135', 'guest', NOW()),
(UUID(), 'Maria', 'Garcia', 'maria.g@example.com', '$2a$12$aBcDeFgHiJkLmNoPqRsTuVwXyZ1357924680', '+1-555-135-7924', 'guest', NOW()),
(UUID(), 'Alex', 'Wong', 'alex.w@example.com', '$2a$12$aBcDeFgHiJkLmNoPqRsTuVwXyZ2468013579', '+1-555-864-2097', 'guest', NOW());

-- Store the generated user IDs for later use
SET @host1_id = (SELECT user_id FROM user WHERE email = 'emily.chen@example.com');
SET @host2_id = (SELECT user_id FROM user WHERE email = 'michael.r@example.com');
SET @host3_id = (SELECT user_id FROM user WHERE email = 'sophie.m@example.com');
SET @guest1_id = (SELECT user_id FROM user WHERE email = 'david.j@example.com');
SET @guest2_id = (SELECT user_id FROM user WHERE email = 'maria.g@example.com');
SET @guest3_id = (SELECT user_id FROM user WHERE email = 'alex.w@example.com');

-- Insert Properties
INSERT INTO property (property_id, host_id, name, description, street_address, city, state, postal_code, country, pricepernight, created_at, updated_at) VALUES
(UUID(), @host1_id, 'Cozy Downtown Loft', 'Modern loft in the heart of the city with stunning views', '123 Main St', 'San Francisco', 'CA', '94105', 'United States', 250.00, NOW(), NOW()),
(UUID(), @host2_id, 'Beachfront Paradise', 'Luxurious beach house with private access to the shore', '456 Ocean Drive', 'Miami', 'FL', '33139', 'United States', 450.00, NOW(), NOW()),
(UUID(), @host3_id, 'Alpine Chalet', 'Rustic mountain retreat with panoramic alpine views', 'Bergstraße 12', 'Zermatt', 'Valais', '3920', 'Switzerland', 350.00, NOW(), NOW());

-- Store the generated property IDs
SET @property1_id = (SELECT property_id FROM property WHERE name = 'Cozy Downtown Loft');
SET @property2_id = (SELECT property_id FROM property WHERE name = 'Beachfront Paradise');
SET @property3_id = (SELECT property_id FROM property WHERE name = 'Alpine Chalet');

-- Insert Bookings
INSERT INTO booking (booking_id, property_id, user_id, start_date, end_date, total_price, status, created_at) VALUES
(UUID(), @property1_id, @guest1_id, '2024-07-15', '2024-07-20', 1250.00, 'confirmed', NOW()),
(UUID(), @property2_id, @guest2_id, '2024-08-01', '2024-08-07', 2800.00, 'pending', NOW()),
(UUID(), @property3_id, @guest3_id, '2024-09-10', '2024-09-15', 1750.00, 'confirmed', NOW());

-- Store the generated booking IDs
SET @booking1_id = (SELECT booking_id FROM booking WHERE property_id = @property1_id AND user_id = @guest1_id);
SET @booking2_id = (SELECT booking_id FROM booking WHERE property_id = @property2_id AND user_id = @guest2_id);
SET @booking3_id = (SELECT booking_id FROM booking WHERE property_id = @property3_id AND user_id = @guest3_id);

-- Insert Payments
INSERT INTO payment (payment_id, booking_id, amount, payment_date, payment_method) VALUES
(UUID(), @booking1_id, 1250.00, NOW(), 'credit_card'),
(UUID(), @booking2_id, 2800.00, NOW(), 'paypal'),
(UUID(), @booking3_id, 1750.00, NOW(), 'stripe');

-- Insert Reviews
INSERT INTO review (review_id, property_id, user_id, rating, comment, created_at) VALUES
(UUID(), @property1_id, @guest1_id, 5, 'Amazing location and incredibly comfortable stay!', NOW()),
(UUID(), @property2_id, @guest2_id, 4, 'Beautiful beachfront property, minor issues with cleanliness', NOW()),
(UUID(), @property3_id, @guest3_id, 5, 'Breathtaking views and perfect mountain retreat', NOW());

-- Insert Messages
INSERT INTO message (message_id, sender_id, recipient_id, message_body, sent_at) VALUES
(UUID(), @guest1_id, @host1_id, 'What are the check-in and check-out times?', NOW()),
(UUID(), @host1_id, @guest1_id, 'Check-in is at 3 PM and check-out is at 11 AM.', NOW()),
(UUID(), @guest2_id, @host2_id, 'Is parking available at the property?', NOW()),
(UUID(), @host2_id, @guest2_id, 'Yes, we offer free private parking for guests.', NOW());

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- Verify Inserted Data
SELECT 'Users inserted' AS result, COUNT(*) AS count FROM user;
SELECT 'Properties inserted' AS result, COUNT(*) AS count FROM property;
SELECT 'Bookings inserted' AS result, COUNT(*) AS count FROM booking;
SELECT 'Payments inserted' AS result, COUNT(*) AS count FROM payment;
SELECT 'Reviews inserted' AS result, COUNT(*) AS count FROM review;
SELECT 'Messages inserted' AS result, COUNT(*) AS count FROM message;