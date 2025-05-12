-- AirBnB Database Schema
-- Database: MySQL/MariaDB Syntax

-- Disable foreign key checks for bulk creation
SET FOREIGN_KEY_CHECKS = 0;

-- Drop existing tables if they exist (for clean recreation)
DROP TABLE IF EXISTS message;
DROP TABLE IF EXISTS review;
DROP TABLE IF EXISTS payment;
DROP TABLE IF EXISTS booking;
DROP TABLE IF EXISTS property;
DROP TABLE IF EXISTS user;

-- Create User Table
CREATE TABLE user (
    user_id CHAR(36) PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    role ENUM('guest', 'host', 'admin') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Additional index for email
    INDEX idx_user_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create Property Table
CREATE TABLE property (
    property_id CHAR(36) PRIMARY KEY,
    host_id CHAR(36) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    street_address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL,
    pricepernight DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraint
    CONSTRAINT fk_property_host 
        FOREIGN KEY (host_id) 
        REFERENCES user(user_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    -- Indexes for performance
    INDEX idx_property_host (host_id),
    INDEX idx_property_location (city, state, country)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create Booking Table
CREATE TABLE booking (
    booking_id CHAR(36) PRIMARY KEY,
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    CONSTRAINT fk_booking_property 
        FOREIGN KEY (property_id) 
        REFERENCES property(property_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_booking_user 
        FOREIGN KEY (user_id) 
        REFERENCES user(user_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    -- Constraint to ensure end date is after start date
    CONSTRAINT chk_booking_dates 
        CHECK (end_date >= start_date),
    
    -- Indexes for performance
    INDEX idx_booking_property (property_id),
    INDEX idx_booking_user (user_id),
    INDEX idx_booking_dates (start_date, end_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create Payment Table
CREATE TABLE payment (
    payment_id CHAR(36) PRIMARY KEY,
    booking_id CHAR(36) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('credit_card', 'paypal', 'stripe') NOT NULL,
    
    -- Foreign Key Constraint
    CONSTRAINT fk_payment_booking 
        FOREIGN KEY (booking_id) 
        REFERENCES booking(booking_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    -- Indexes for performance
    INDEX idx_payment_booking (booking_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create Review Table
CREATE TABLE review (
    review_id CHAR(36) PRIMARY KEY,
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    CONSTRAINT fk_review_property 
        FOREIGN KEY (property_id) 
        REFERENCES property(property_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_review_user 
        FOREIGN KEY (user_id) 
        REFERENCES user(user_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    -- Indexes for performance
    INDEX idx_review_property (property_id),
    INDEX idx_review_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create Message Table
CREATE TABLE message (
    message_id CHAR(36) PRIMARY KEY,
    sender_id CHAR(36) NOT NULL,
    recipient_id CHAR(36) NOT NULL,
    message_body TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    CONSTRAINT fk_message_sender 
        FOREIGN KEY (sender_id) 
        REFERENCES user(user_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_message_recipient 
        FOREIGN KEY (recipient_id) 
        REFERENCES user(user_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    -- Indexes for performance
    INDEX idx_message_sender (sender_id),
    INDEX idx_message_recipient (recipient_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;