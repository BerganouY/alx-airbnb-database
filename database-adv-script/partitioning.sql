-- This script implements RANGE partitioning based on start_date column

-- Step 1: Create a backup of the original table
CREATE TABLE booking_backup LIKE booking;
INSERT INTO booking_backup SELECT * FROM booking;

-- Step 2: Drop foreign key constraints that reference the booking table
-- We need to identify and drop constraints from child tables before modifying the booking table
ALTER TABLE payment DROP FOREIGN KEY fk_payment_booking;

-- Step 3: Drop the original booking table
DROP TABLE booking;

-- Step 4: Create a new partitioned booking table with the same structure
CREATE TABLE booking (
    booking_id CHAR(36) PRIMARY KEY,
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraint to ensure end date is after start date
    CONSTRAINT chk_booking_dates 
        CHECK (end_date >= start_date),
    
    -- Indexes for performance
    INDEX idx_booking_property (property_id),
    INDEX idx_booking_user (user_id),
    INDEX idx_booking_dates (start_date, end_date)
)
PARTITION BY RANGE (YEAR(start_date)) (
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION p2026 VALUES LESS THAN (2027),
    PARTITION p2027 VALUES LESS THAN (2028),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- Step 5: Copy data from backup to the new partitioned table
INSERT INTO booking SELECT * FROM booking_backup;

-- Step 6: Recreate foreign key constraints that reference the booking table
ALTER TABLE payment ADD CONSTRAINT fk_payment_booking 
    FOREIGN KEY (booking_id) 
    REFERENCES booking(booking_id) 
    ON DELETE CASCADE 
    ON UPDATE CASCADE;

-- Step 7: Add foreign key constraints back to the booking table
ALTER TABLE booking ADD CONSTRAINT fk_booking_property 
    FOREIGN KEY (property_id) 
    REFERENCES property(property_id) 
    ON DELETE CASCADE 
    ON UPDATE CASCADE;
    
ALTER TABLE booking ADD CONSTRAINT fk_booking_user 
    FOREIGN KEY (user_id) 
    REFERENCES user(user_id) 
    ON DELETE CASCADE 
    ON UPDATE CASCADE;

-- Step 8: Verify the partitioning has been set up correctly
-- This query shows the partitions and the number of rows in each
EXPLAIN SELECT * FROM booking WHERE start_date BETWEEN '2024-01-01' AND '2024-12-31';

-- When no longer needed, you can drop the backup table
-- DROP TABLE booking_backup;

-- Query Examples for Testing Partitioning Performance
-- These queries would benefit from the partitioning

-- Example 1: Retrieve bookings for a specific year
-- Query will only scan the relevant partition
SELECT * FROM booking 
WHERE start_date BETWEEN '2024-01-01' AND '2024-12-31';

-- Example 2: Count bookings by year
SELECT YEAR(start_date) AS booking_year, COUNT(*) AS total_bookings
FROM booking
GROUP BY booking_year;

-- Example 3: Find active bookings in current date range
SELECT b.booking_id, p.name AS property_name, u.first_name, u.last_name, 
       b.start_date, b.end_date, b.total_price
FROM booking b
JOIN property p ON b.property_id = p.property_id
JOIN user u ON b.user_id = u.user_id
WHERE b.start_date <= CURDATE() AND b.end_date >= CURDATE()
ORDER BY b.end_date;