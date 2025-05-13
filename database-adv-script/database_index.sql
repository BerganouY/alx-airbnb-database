-- database_index.sql
-- SQL script to create optimized indexes for AirBnB database

-- Analyzing existing indexes
-- Looking at your schema, you already have some indexes defined:
-- user: PRIMARY KEY (user_id), INDEX idx_user_email (email)
-- property: PRIMARY KEY (property_id), INDEX idx_property_host (host_id), INDEX idx_property_location (city, state, country)
-- booking: PRIMARY KEY (booking_id), INDEX idx_booking_property (property_id), INDEX idx_booking_user (user_id), INDEX idx_booking_dates (start_date, end_date)
-- payment: PRIMARY KEY (payment_id), INDEX idx_payment_booking (booking_id)
-- review: PRIMARY KEY (review_id), INDEX idx_review_property (property_id), INDEX idx_review_user (user_id)
-- message: PRIMARY KEY (message_id), INDEX idx_message_sender (sender_id), INDEX idx_message_recipient (recipient_id)

-- 1. Additional User Table Indexes
-- Add index on role to improve filtering by user type 
-- (commonly used in WHERE clauses to filter hosts vs guests)
CREATE INDEX idx_user_role ON user(role);

-- 2. Additional Property Table Indexes
-- Add index on price to improve sorting and range queries
-- (commonly used in ORDER BY and WHERE price BETWEEN x AND y)
CREATE INDEX idx_property_price ON property(pricepernight);

-- Add functional index for case-insensitive name searches
CREATE INDEX idx_property_name_lower ON property((LOWER(name)));

-- Composite index for location + price filtering (common search pattern)
CREATE INDEX idx_property_location_price ON property(country, state, city, pricepernight);

-- 3. Additional Booking Table Indexes
-- Add index on status to improve filtering by booking status
-- (commonly used in WHERE clauses)
CREATE INDEX idx_booking_status ON booking(status);

-- Add composite index on user_id + status for "my bookings" filtering
CREATE INDEX idx_booking_user_status ON booking(user_id, status);

-- Add index for revenue reports (date ranges + price)
CREATE INDEX idx_booking_date_price ON booking(start_date, end_date, total_price);

-- 4. Additional Review Table Indexes
-- Add index on rating for filtering high/low rated properties
CREATE INDEX idx_review_rating ON review(rating);

-- Add index on created_at for recent reviews filtering
CREATE INDEX idx_review_date ON review(created_at);

-- 5. Specialized Application-Specific Indexes
-- For "properties with recent bookings" queries
CREATE INDEX idx_booking_property_date ON booking(property_id, start_date DESC);

-- For "most reviewed properties" queries
CREATE INDEX idx_review_property_count ON review(property_id, review_id);

-- For search by availability (finding properties NOT booked during specific dates)
-- Note: This is a functional/filtered index - syntax may vary by database system
CREATE INDEX idx_property_available 
ON booking(property_id, start_date, end_date)
WHERE status != 'canceled';

-- Performance Testing Commands
-- Use these to compare performance before and after adding indexes

-- Example 1: Testing user role filtering performance
EXPLAIN ANALYZE
SELECT user_id, first_name, last_name, email 
FROM user 
WHERE role = 'host';

-- Example 2: Testing property search by price and location
EXPLAIN ANALYZE
SELECT property_id, name, pricepernight 
FROM property 
WHERE city = 'Miami' AND pricepernight BETWEEN 100 AND 200
ORDER BY pricepernight;

-- Example 3: Testing booking status filtering
EXPLAIN ANALYZE
SELECT b.booking_id, p.name, b.start_date, b.end_date 
FROM booking b
JOIN property p ON b.property_id = p.property_id
WHERE b.user_id = 'some-user-id' AND b.status = 'confirmed';

-- Example 4: Testing availability search
EXPLAIN ANALYZE
SELECT p.property_id, p.name, p.pricepernight
FROM property p
WHERE p.city = 'New York'
AND NOT EXISTS (
    SELECT 1 FROM booking b
    WHERE b.property_id = p.property_id
    AND b.status != 'canceled'
    AND (b.start_date <= '2025-07-15' AND b.end_date >= '2025-07-10')
);

-- Example 5: Testing top-rated properties query
EXPLAIN ANALYZE
SELECT p.property_id, p.name, AVG(r.rating) as avg_rating
FROM property p
JOIN review r ON p.property_id = r.property_id
WHERE p.city = 'San Francisco'
GROUP BY p.property_id, p.name
HAVING AVG(r.rating) > 4
ORDER BY avg_rating DESC;

-- Notes on Index Usage and Performance Testing:
-- 1. Before adding new indexes, test the queries to establish baseline performance
-- 2. After adding indexes, run the same queries to measure improvement
-- 3. Not all indexes will provide the same level of benefit
-- 4. Monitor production database to identify true high-usage patterns
-- 5. Consider dropping unused indexes as they can slow down INSERT/UPDATE operations
-- 6. Remember to run ANALYZE or equivalent to update statistics after creating indexes

-- Index Maintenance
-- Run this periodically to update index statistics for query optimizer
ANALYZE TABLE user, property, booking, review;

-- Optional: Index cleanup - use if performance deteriorates or storage is a concern
-- DROP INDEX idx_unused_index ON some_table;