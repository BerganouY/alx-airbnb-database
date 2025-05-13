-- INNER JOIN: Retrieve All Bookings with User Information
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role
FROM 
    booking b
INNER JOIN 
    user u ON b.user_id = u.user_id
ORDER BY 
    b.start_date DESC;

-- LEFT JOIN: Retrieve All Properties with Their Reviews
SELECT 
    p.property_id,
    p.name AS property_name,
    p.city,
    p.state,
    p.country,
    p.pricepernight,
    r.review_id,
    r.rating,
    r.comment,
    r.created_at AS review_date,
    u.first_name AS reviewer_first_name,
    u.last_name AS reviewer_last_name
FROM 
    property p
LEFT JOIN 
    review r ON p.property_id = r.property_id
LEFT JOIN
    user u ON r.user_id = u.user_id
ORDER BY 
    p.property_id,
    r.created_at DESC;

-- FULL OUTER JOIN: Retrieve All Users and All Bookings
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role,
    b.booking_id,
    b.property_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status
FROM 
    user u
LEFT JOIN 
    booking b ON u.user_id = b.user_id

UNION

SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role,
    b.booking_id,
    b.property_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status
FROM 
    booking b
LEFT JOIN 
    user u ON b.user_id = u.user_id
WHERE 
    u.user_id IS NULL

ORDER BY 
    user_id,
    start_date DESC;