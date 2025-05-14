-- SECTION 1: INITIAL COMPLEX QUERY
-- This query retrieves all bookings with user, property, and payment details

-- Initial complex query with multiple joins
EXPLAIN ANALYZE
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    
    -- User details
    u.user_id AS guest_id,
    u.first_name AS guest_first_name,
    u.last_name AS guest_last_name,
    u.email AS guest_email,
    
    -- Property details
    p.property_id,
    p.name AS property_name,
    p.street_address,
    p.city,
    p.state,
    p.country,
    p.pricepernight,
    
    -- Host details
    host.user_id AS host_id,
    host.first_name AS host_first_name,
    host.last_name AS host_last_name,
    host.email AS host_email,
    
    -- Payment details
    pay.payment_id,
    pay.amount AS payment_amount,
    pay.payment_date,
    pay.payment_method,
    
    -- Review details (if any)
    r.review_id,
    r.rating,
    r.comment,
    r.created_at AS review_date
FROM 
    booking b
JOIN 
    user u ON b.user_id = u.user_id
JOIN 
    property p ON b.property_id = p.property_id
JOIN 
    user host ON p.host_id = host.user_id
LEFT JOIN 
    payment pay ON b.booking_id = pay.booking_id
LEFT JOIN 
    review r ON (r.property_id = p.property_id AND r.user_id = u.user_id)
WHERE 
    b.start_date >= '2025-01-01'
ORDER BY 
    b.start_date DESC;

-- SECTION 2: PERFORMANCE ANALYSIS
/*
Performance Analysis of Initial Query:

1. Inefficiencies identified:
   - Too many joins (5 tables) creating a large result set
   - The LEFT JOIN to reviews is problematic - it might match multiple reviews per booking
   - Ordering by start_date requires scanning/sorting the entire result set
   - No limiting of results (potentially returning thousands of rows)
   - The WHERE filter on start_date may not be using the index effectively

2. Execution plan issues:
   - Large table scans likely occurring
   - Multiple join operations causing high memory usage
   - Potentially creating a Cartesian product with the reviews table
   - Each booking might be duplicated for each review the guest made

3. Index usage concerns:
   - We need to ensure the query uses indexes on start_date, user_id, property_id
   - The ORDER BY should leverage an index
*/

-- SECTION 3: REFACTORED QUERY 1 - BASIC OPTIMIZATION
-- This optimized version separates concerns and uses better filtering

EXPLAIN ANALYZE
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    
    -- User details
    u.user_id AS guest_id,
    u.first_name AS guest_first_name,
    u.last_name AS guest_last_name,
    u.email AS guest_email,
    
    -- Property details
    p.property_id,
    p.name AS property_name,
    p.street_address,
    p.city,
    p.state,
    p.country,
    p.pricepernight,
    
    -- Host details
    host.user_id AS host_id,
    host.first_name AS host_first_name,
    host.last_name AS host_last_name,
    
    -- Payment details
    pay.payment_id,
    pay.amount AS payment_amount,
    pay.payment_method
FROM 
    booking b
JOIN 
    user u ON b.user_id = u.user_id
JOIN 
    property p ON b.property_id = p.property_id
JOIN 
    user host ON p.host_id = host.user_id
LEFT JOIN 
    payment pay ON b.booking_id = pay.booking_id
WHERE 
    b.start_date >= '2025-01-01'
    AND b.start_date < '2025-07-01'  -- Added date range upper bound
ORDER BY 
    b.start_date DESC
LIMIT 100;  -- Added limit to prevent excessive data return

-- SECTION 4: REFACTORED QUERY 2 - SEPARATE REVIEW LOOKUP
-- This retrieves the same data but handles reviews separately to avoid duplication

-- Main booking query
EXPLAIN ANALYZE
WITH BookingData AS (
    SELECT 
        b.booking_id,
        b.start_date,
        b.end_date,
        b.total_price,
        b.status,
        b.user_id AS guest_id,
        b.property_id,
        u.first_name AS guest_first_name,
        u.last_name AS guest_last_name,
        u.email AS guest_email,
        p.name AS property_name,
        p.street_address,
        p.city,
        p.state,
        p.country,
        p.pricepernight,
        p.host_id,
        host.first_name AS host_first_name,
        host.last_name AS host_last_name,
        pay.payment_id,
        pay.amount AS payment_amount,
        pay.payment_method
    FROM 
        booking b
    JOIN 
        user u ON b.user_id = u.user_id
    JOIN 
        property p ON b.property_id = p.property_id
    JOIN 
        user host ON p.host_id = host.user_id
    LEFT JOIN 
        payment pay ON b.booking_id = pay.booking_id
    WHERE 
        b.start_date >= '2025-01-01'
        AND b.start_date < '2025-07-01'
    ORDER BY 
        b.start_date DESC
    LIMIT 100
)
SELECT * FROM BookingData;

-- Separate query for reviews when needed
EXPLAIN ANALYZE
SELECT 
    r.property_id,
    r.user_id,
    r.review_id,
    r.rating,
    r.comment,
    r.created_at AS review_date
FROM 
    review r
WHERE 
    r.property_id IN (
        SELECT property_id FROM BookingData
    )
    AND r.user_id IN (
        SELECT guest_id FROM BookingData
    );

-- SECTION 5: REFACTORED QUERY 3 - PAGINATION APPROACH
-- This implements proper pagination for browsing through booking results

EXPLAIN ANALYZE
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    u.user_id AS guest_id,
    u.first_name AS guest_first_name,
    u.last_name AS guest_last_name,
    p.property_id,
    p.name AS property_name,
    p.city,
    p.country,
    host.user_id AS host_id,
    host.first_name AS host_first_name,
    host.last_name AS host_last_name,
    EXISTS (
        SELECT 1 
        FROM payment pay 
        WHERE pay.booking_id = b.booking_id
    ) AS has_payment
FROM 
    booking b
JOIN 
    user u ON b.user_id = u.user_id
JOIN 
    property p ON b.property_id = p.property_id
JOIN 
    user host ON p.host_id = host.user_id
WHERE 
    b.start_date >= '2025-01-01'
    AND b.start_date < '2025-07-01'
    -- For continuation from previous page:
    -- AND (b.start_date, b.booking_id) < (@last_date, @last_id)
ORDER BY 
    b.start_date DESC, b.booking_id DESC
LIMIT 20;

-- SECTION 6: REFACTORED QUERY 4 - MATERIALIZED VIEW APPROACH
-- For frequently accessed data, create a materialized view (syntax varies by database)

-- Create materialized view for recent bookings
CREATE MATERIALIZED VIEW mv_recent_bookings AS
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    b.user_id AS guest_id,
    u.first_name AS guest_first_name,
    u.last_name AS guest_last_name,
    b.property_id,
    p.name AS property_name,
    p.city,
    p.country,
    p.host_id,
    host.first_name AS host_first_name,
    host.last_name AS host_last_name,
    (SELECT COUNT(*) FROM payment pay WHERE pay.booking_id = b.booking_id) AS payment_count
FROM 
    booking b
JOIN 
    user u ON b.user_id = u.user_id
JOIN 
    property p ON b.property_id = p.property_id
JOIN 
    user host ON p.host_id = host.user_id
WHERE 
    b.start_date >= CURRENT_DATE - INTERVAL '30 days'
    AND b.start_date <= CURRENT_DATE + INTERVAL '90 days';

-- Index the materialized view
CREATE INDEX idx_mv_bookings_dates ON mv_recent_bookings(start_date, end_date);
CREATE INDEX idx_mv_bookings_property ON mv_recent_bookings(property_id);
CREATE INDEX idx_mv_bookings_guest ON mv_recent_bookings(guest_id);

-- Query the materialized view (much faster)
EXPLAIN ANALYZE
SELECT * FROM mv_recent_bookings
WHERE start_date >= '2025-05-01'
ORDER BY start_date DESC
LIMIT 20;

-- Refresh materialized view (schedule this to run periodically)
REFRESH MATERIALIZED VIEW mv_recent_bookings;

-- SECTION 7: RECOMMENDATIONS FOR PERFORMANCE IMPROVEMENT

/*
Performance Optimization Recommendations:

1. Query Structure Improvements:
   - Limit returned columns to only what's needed
   - Use date range bounds on both sides (not just >=)
   - Implement proper pagination with keyset pagination
   - Remove unnecessary JOINs when possible
   - Split complex queries into simpler ones
   - Use EXISTS instead of JOINs for checking existence

2. Index Recommendations:
   - Ensure composite index on booking(start_date, booking_id) for pagination
   - Create covering indexes that include frequently queried columns
   - Add index on payment(booking_id) if not already present

3. Database Configuration:
   - Adjust work_mem parameter for complex sorts and joins
   - Consider read replicas for reporting queries
   - Implement connection pooling

4. Application-Level Changes:
   - Implement caching for frequent queries
   - Lazy-load related data only when needed
   - Consider GraphQL or multiple endpoints instead of one large query
   - Implement proper pagination in API and UI

5. Monitoring:
   - Set up query performance monitoring
   - Log slow queries for further optimization
   - Periodically review and update statistics
*/

-- SECTION 8: TESTING PERFORMANCE IMPROVEMENTS
-- Compare execution times of original and optimized queries

-- Original query baseline - save execution time
SET @original_query_time = NOW();
-- [Run original complex query here]
SELECT TIMEDIFF(NOW(), @original_query_time) AS original_execution_time;

-- Optimized query measurement
SET @optimized_query_time = NOW();
-- [Run optimized query here]
SELECT TIMEDIFF(NOW(), @optimized_query_time) AS optimized_execution_time;