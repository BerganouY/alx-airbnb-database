-- Non-Correlated Subquery: Find Properties with Average Rating > 4.0
SELECT 
    p.property_id,
    p.name AS property_name,
    p.host_id,
    p.city,
    p.state,
    p.country,
    p.pricepernight,
    (SELECT AVG(r.rating) 
     FROM review r 
     WHERE r.property_id = p.property_id) AS average_rating
FROM 
    property p
WHERE 
    p.property_id IN (
        SELECT 
            r.property_id
        FROM 
            review r
        GROUP BY 
            r.property_id
        HAVING 
            AVG(r.rating) > 4.0
    )
ORDER BY 
    average_rating DESC;

-- Alternative Non-Correlated Approach with JOIN
SELECT 
    p.property_id,
    p.name AS property_name,
    p.host_id,
    p.city,
    p.state,
    p.country,
    p.pricepernight,
    avg_ratings.average_rating
FROM 
    property p
JOIN (
    SELECT 
        property_id, 
        AVG(rating) AS average_rating
    FROM 
        review
    GROUP BY 
        property_id
    HAVING 
        AVG(rating) > 4.0
) avg_ratings ON p.property_id = avg_ratings.property_id
ORDER BY 
    avg_ratings.average_rating DESC;

-- Correlated Subquery: Find Users with More Than 3 Bookings
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role,
    (SELECT 
        COUNT(*) 
     FROM 
        booking b 
     WHERE 
        b.user_id = u.user_id) AS booking_count
FROM 
    user u
WHERE 
    (SELECT 
        COUNT(*) 
     FROM 
        booking b 
     WHERE 
        b.user_id = u.user_id) > 3
ORDER BY 
    booking_count DESC;

-- Alternative Approach Using JOIN and GROUP BY
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role,
    COUNT(b.booking_id) AS booking_count
FROM 
    user u
JOIN 
    booking b ON u.user_id = b.user_id
GROUP BY 
    u.user_id, u.first_name, u.last_name, u.email, u.role
HAVING 
    COUNT(b.booking_id) > 3
ORDER BY 
    booking_count DESC;