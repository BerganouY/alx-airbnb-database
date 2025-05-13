
# AirBnB Database Index Optimization Script

**File:** `database_index.sql`  
**Purpose:** Create optimized indexes for the AirBnB clone database  
**Date Created:** May 13, 2025

---

## Overview of Existing Indexes

### `user` Table
- `PRIMARY KEY (user_id)`
- `INDEX idx_user_email (email)`

### `property` Table
- `PRIMARY KEY (property_id)`
- `INDEX idx_property_host (host_id)`
- `INDEX idx_property_location (city, state, country)`

### `booking` Table
- `PRIMARY KEY (booking_id)`
- `INDEX idx_booking_property (property_id)`
- `INDEX idx_booking_user (user_id)`
- `INDEX idx_booking_dates (start_date, end_date)`

### `payment` Table
- `PRIMARY KEY (payment_id)`
- `INDEX idx_payment_booking (booking_id)`

### `review` Table
- `PRIMARY KEY (review_id)`
- `INDEX idx_review_property (property_id)`
- `INDEX idx_review_user (user_id)`

### `message` Table
- `PRIMARY KEY (message_id)`
- `INDEX idx_message_sender (sender_id)`
- `INDEX idx_message_recipient (recipient_id)`

---

## 1. Additional Indexes for `user` Table

```sql
-- Improve filtering by user type
CREATE INDEX idx_user_role ON user(role);
```

---

## 2. Additional Indexes for `property` Table

```sql
-- Improve sorting and range queries on price
CREATE INDEX idx_property_price ON property(pricepernight);

-- Functional index for case-insensitive search
CREATE INDEX idx_property_name_lower ON property((LOWER(name)));

-- Composite index for location + price search
CREATE INDEX idx_property_location_price 
ON property(country, state, city, pricepernight);
```

---

## 3. Additional Indexes for `booking` Table

```sql
-- Improve filtering by booking status
CREATE INDEX idx_booking_status ON booking(status);

-- Composite index for user bookings by status
CREATE INDEX idx_booking_user_status ON booking(user_id, status);

-- Support for revenue reports by date + price
CREATE INDEX idx_booking_date_price 
ON booking(start_date, end_date, total_price);
```

---

## 4. Additional Indexes for `review` Table

```sql
-- Filter by rating
CREATE INDEX idx_review_rating ON review(rating);

-- Filter by review date
CREATE INDEX idx_review_date ON review(created_at);
```

---

## 5. Specialized Indexes

```sql
-- Properties with recent bookings
CREATE INDEX idx_booking_property_date 
ON booking(property_id, start_date DESC);

-- Most reviewed properties
CREATE INDEX idx_review_property_count 
ON review(property_id, review_id);

-- Availability search (excluding canceled)
CREATE INDEX idx_property_available 
ON booking(property_id, start_date, end_date)
WHERE status != 'canceled';
```

---

## Performance Testing Examples

### 1. Filtering Users by Role

```sql
EXPLAIN ANALYZE
SELECT user_id, first_name, last_name, email 
FROM user 
WHERE role = 'host';
```

### 2. Search Properties by Location and Price

```sql
EXPLAIN ANALYZE
SELECT property_id, name, pricepernight 
FROM property 
WHERE city = 'Miami' 
  AND pricepernight BETWEEN 100 AND 200
ORDER BY pricepernight;
```

### 3. Get Confirmed Bookings for User

```sql
EXPLAIN ANALYZE
SELECT b.booking_id, p.name, b.start_date, b.end_date 
FROM booking b
JOIN property p ON b.property_id = p.property_id
WHERE b.user_id = 'some-user-id' AND b.status = 'confirmed';
```

### 4. Property Availability Search

```sql
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
```

### 5. Top-Rated Properties

```sql
EXPLAIN ANALYZE
SELECT p.property_id, p.name, AVG(r.rating) as avg_rating
FROM property p
JOIN review r ON p.property_id = r.property_id
WHERE p.city = 'San Francisco'
GROUP BY p.property_id, p.name
HAVING AVG(r.rating) > 4
ORDER BY avg_rating DESC;
```

---

## Index Usage Notes

1. Test performance before and after index creation.
2. Use `EXPLAIN ANALYZE` to measure improvements.
3. Drop unused indexes to reduce write overhead.
4. Monitor query patterns in production.
5. Use `ANALYZE` to refresh database statistics after index changes.

---

## Maintenance

```sql
-- Refresh optimizer statistics
ANALYZE TABLE user, property, booking, review;

-- Optional: Drop unused indexes
-- DROP INDEX idx_unused_index ON some_table;
```
