-- Aggregation: Total Bookings per User
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_price) AS total_spent,
    AVG(b.total_price) AS average_booking_price,
    MIN(b.start_date) AS first_booking_date,
    MAX(b.start_date) AS most_recent_booking_date
FROM 
    user u
LEFT JOIN 
    booking b ON u.user_id = b.user_id
GROUP BY 
    u.user_id, u.first_name, u.last_name, u.email, u.role
ORDER BY 
    total_bookings DESC, total_spent DESC;

-- Advanced Aggregation: Bookings per User with Booking Status Breakdown
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    COUNT(b.booking_id) AS total_bookings,
    SUM(CASE WHEN b.status = 'confirmed' THEN 1 ELSE 0 END) AS confirmed_bookings,
    SUM(CASE WHEN b.status = 'pending' THEN 1 ELSE 0 END) AS pending_bookings,
    SUM(CASE WHEN b.status = 'canceled' THEN 1 ELSE 0 END) AS canceled_bookings,
    SUM(b.total_price) AS total_spent
FROM 
    user u
LEFT JOIN 
    booking b ON u.user_id = b.user_id
GROUP BY 
    u.user_id, u.first_name, u.last_name
ORDER BY 
    total_bookings DESC;

-- Window Function: Ranking Properties by Booking Count
SELECT 
    ranked_properties.*,
    CONCAT(u.first_name, ' ', u.last_name) AS host_name
FROM (
    SELECT 
        p.property_id,
        p.name AS property_name,
        p.host_id,
        p.city,
        p.state,
        p.country,
        COUNT(b.booking_id) AS booking_count,
        SUM(b.total_price) AS total_revenue,
        ROW_NUMBER() OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_rank,
        RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_rank_with_ties,
        DENSE_RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS dense_booking_rank,
        ROW_NUMBER() OVER (PARTITION BY p.city ORDER BY COUNT(b.booking_id) DESC) AS city_booking_rank
    FROM 
        property p
    LEFT JOIN 
        booking b ON p.property_id = b.property_id
    GROUP BY 
        p.property_id, p.name, p.host_id, p.city, p.state, p.country
) AS ranked_properties
JOIN 
    user u ON ranked_properties.host_id = u.user_id
ORDER BY 
    booking_rank;

-- Window Function: Property Performance Analysis
SELECT 
    p.property_id,
    p.name AS property_name,
    p.city,
    p.state,
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    SUM(b.total_price) OVER (PARTITION BY p.property_id) AS property_total_revenue,
    AVG(b.total_price) OVER (PARTITION BY p.property_id) AS property_avg_booking_price,
    COUNT(b.booking_id) OVER (PARTITION BY p.property_id) AS property_booking_count,
    SUM(b.total_price) OVER (PARTITION BY p.city) AS city_total_revenue,
    AVG(b.total_price) OVER (PARTITION BY p.city) AS city_avg_booking_price,
    RANK() OVER (PARTITION BY p.city ORDER BY b.total_price DESC) AS price_rank_in_city,
    b.total_price / NULLIF(AVG(b.total_price) OVER (PARTITION BY p.city), 0) AS price_to_city_avg_ratio
FROM 
    property p
JOIN 
    booking b ON p.property_id = b.property_id
WHERE 
    b.status = 'confirmed'
ORDER BY 
    p.property_id, b.start_date;

-- Window Function: Running Totals and Moving Averages
SELECT 
    b.booking_id,
    b.property_id,
    p.name AS property_name,
    b.start_date,
    b.total_price,
    SUM(b.total_price) OVER (
        PARTITION BY b.property_id 
        ORDER BY b.start_date
    ) AS running_total_revenue,
    AVG(b.total_price) OVER (
        PARTITION BY b.property_id 
        ORDER BY b.start_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_price_3_bookings,
    FIRST_VALUE(b.total_price) OVER (
        PARTITION BY b.property_id 
        ORDER BY b.start_date
    ) AS first_booking_price,
    LAST_VALUE(b.total_price) OVER (
        PARTITION BY b.property_id 
        ORDER BY b.start_date
        RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_booking_price
FROM 
    booking b
JOIN 
    property p ON b.property_id = p.property_id
WHERE 
    b.status = 'confirmed'
ORDER BY 
    b.property_id, b.start_date;