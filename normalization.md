# AirBnB Database Normalization Analysis

## Current Schema Review

For a database to be in 3NF, it must satisfy all the following conditions:
1. It must be in 2NF (Second Normal Form)
2. It must not have transitive dependencies (no non-prime attribute depends on another non-prime attribute)

To be in 2NF:
1. It must be in 1NF (First Normal Form)
2. No partial dependencies (no non-prime attribute depends on just a part of the primary key)

To be in 1NF:
1. All attributes must be atomic (indivisible)
2. Each table must have a primary key
3. No repeating groups

## Normalization Analysis

### User Table
```
user_id: Primary Key, UUID
first_name: VARCHAR
last_name: VARCHAR
email: VARCHAR
password_hash: VARCHAR
phone_number: VARCHAR
role: ENUM
created_at: TIMESTAMP
```

**1NF Analysis:**
- All attributes are atomic ✓
- Has a primary key (user_id) ✓
- No repeating groups ✓

**2NF Analysis:**
- Primary key is not composite, so no partial dependencies possible ✓

**3NF Analysis:**
- No non-key attributes depend on other non-key attributes ✓

**Verdict: The User table is in 3NF**

### Property Table
```
property_id: Primary Key, UUID
host_id: Foreign Key to User
name: VARCHAR
description: TEXT
location: VARCHAR
pricepernight: DECIMAL
created_at: TIMESTAMP
updated_at: TIMESTAMP
```

**1NF Analysis:**
- All attributes are atomic ✓
- Has a primary key (property_id) ✓
- No repeating groups ✓

**2NF Analysis:**
- Primary key is not composite, so no partial dependencies possible ✓

**3NF Analysis:**
- Location field might contain multiple pieces of information (street, city, state, zip) that could be separated
- No other non-key attributes depend on other non-key attributes ✓

**Potential Issue: Location field might violate atomicity**

### Booking Table
```
booking_id: Primary Key, UUID
property_id: Foreign Key to Property
user_id: Foreign Key to User
start_date: DATE
end_date: DATE
total_price: DECIMAL
status: ENUM
created_at: TIMESTAMP
```

**1NF Analysis:**
- All attributes are atomic ✓
- Has a primary key (booking_id) ✓
- No repeating groups ✓

**2NF Analysis:**
- Primary key is not composite, so no partial dependencies possible ✓

**3NF Analysis:**
- `total_price` might be calculable from `start_date`, `end_date`, and Property's `pricepernight`, suggesting a potential transitive dependency
- No other non-key attributes depend on other non-key attributes ✓

**Potential Issue: total_price may have a transitive dependency**

### Payment Table, Review Table, Message Table
(Similar analysis shows these tables are in 3NF)

## Recommended Changes for 3NF Compliance

### 1. Normalize the Property Table's Location
Split the potentially composite `location` field into atomic components:

```
Property Table (Modified):
property_id: Primary Key, UUID
host_id: Foreign Key to User
name: VARCHAR
description: TEXT
street_address: VARCHAR
city: VARCHAR
state: VARCHAR
postal_code: VARCHAR
country: VARCHAR
pricepernight: DECIMAL
created_at: TIMESTAMP
updated_at: TIMESTAMP
```

### 2. Address the Transitive Dependency in Booking Table
The `total_price` in the Booking table could be considered a calculated field based on the booking duration and the property's price per night. There are two approaches:

**Option A:** Keep `total_price` but document that it's maintained by application logic
- This recognizes that prices might change or special discounts might apply
- The value is a "snapshot" of the calculation at booking time

**Option B:** Make it a calculated field or view
- Remove from table and calculate when needed
- This ensures always up-to-date pricing but loses historical record

**Recommendation:** Keep the `total_price` field as it represents the agreed price at booking time, which may differ from a current calculation if property prices change.

## Final 3NF Schema

After applying these normalization principles, here's the revised schema:

### User Table (Unchanged, already in 3NF)
- user_id: Primary Key, UUID
- first_name: VARCHAR
- last_name: VARCHAR
- email: VARCHAR
- password_hash: VARCHAR
- phone_number: VARCHAR
- role: ENUM
- created_at: TIMESTAMP

### Property Table (Modified for 3NF)
- property_id: Primary Key, UUID
- host_id: Foreign Key to User
- name: VARCHAR
- description: TEXT
- street_address: VARCHAR
- city: VARCHAR
- state: VARCHAR
- postal_code: VARCHAR
- country: VARCHAR
- pricepernight: DECIMAL
- created_at: TIMESTAMP
- updated_at: TIMESTAMP

### Booking Table (Unchanged, with note about total_price)
- booking_id: Primary Key, UUID
- property_id: Foreign Key to Property
- user_id: Foreign Key to User
- start_date: DATE
- end_date: DATE
- total_price: DECIMAL (preserved as a historical record of agreed price)
- status: ENUM
- created_at: TIMESTAMP

### Payment Table (Unchanged, already in 3NF)
- payment_id: Primary Key, UUID
- booking_id: Foreign Key to Booking
- amount: DECIMAL
- payment_date: TIMESTAMP
- payment_method: ENUM

### Review Table (Unchanged, already in 3NF)
- review_id: Primary Key, UUID
- property_id: Foreign Key to Property
- user_id: Foreign Key to User
- rating: INTEGER
- comment: TEXT
- created_at: TIMESTAMP

### Message Table (Unchanged, already in 3NF)
- message_id: Primary Key, UUID
- sender_id: Foreign Key to User
- recipient_id: Foreign Key to User
- message_body: TEXT
- sent_at: TIMESTAMP

## Conclusion

The AirBnB database schema was already well-designed and close to 3NF. The main improvements involved:

1. Breaking down the potentially non-atomic `location` field into specific components
2. Acknowledging the design decision regarding `total_price` in the Booking table

# AirBnB Database Schema (3NF Normalized)

## Entities and Attributes

### User
- **user_id**: Primary Key, UUID, Indexed
- **first_name**: VARCHAR, NOT NULL
- **last_name**: VARCHAR, NOT NULL
- **email**: VARCHAR, UNIQUE, NOT NULL
- **password_hash**: VARCHAR, NOT NULL
- **phone_number**: VARCHAR, NULL
- **role**: ENUM (`guest`, `host`, `admin`), NOT NULL
- **created_at**: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP

### Property
- **property_id**: Primary Key, UUID, Indexed
- **host_id**: Foreign Key, references `User(user_id)`
- **name**: VARCHAR, NOT NULL
- **description**: TEXT, NOT NULL
- **street_address**: VARCHAR, NOT NULL
- **city**: VARCHAR, NOT NULL
- **state**: VARCHAR, NOT NULL
- **postal_code**: VARCHAR, NOT NULL
- **country**: VARCHAR, NOT NULL
- **pricepernight**: DECIMAL, NOT NULL
- **created_at**: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
- **updated_at**: TIMESTAMP, ON UPDATE CURRENT_TIMESTAMP

### Booking
- **booking_id**: Primary Key, UUID, Indexed
- **property_id**: Foreign Key, references `Property(property_id)`
- **user_id**: Foreign Key, references `User(user_id)`
- **start_date**: DATE, NOT NULL
- **end_date**: DATE, NOT NULL
- **total_price**: DECIMAL, NOT NULL
- **status**: ENUM (`pending`, `confirmed`, `canceled`), NOT NULL
- **created_at**: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP

### Payment
- **payment_id**: Primary Key, UUID, Indexed
- **booking_id**: Foreign Key, references `Booking(booking_id)`
- **amount**: DECIMAL, NOT NULL
- **payment_date**: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
- **payment_method**: ENUM (`credit_card`, `paypal`, `stripe`), NOT NULL

### Review
- **review_id**: Primary Key, UUID, Indexed
- **property_id**: Foreign Key, references `Property(property_id)`
- **user_id**: Foreign Key, references `User(user_id)`
- **rating**: INTEGER, CHECK: `rating >= 1 AND rating <= 5`, NOT NULL
- **comment**: TEXT, NOT NULL
- **created_at**: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP

### Message
- **message_id**: Primary Key, UUID, Indexed
- **sender_id**: Foreign Key, references `User(user_id)`
- **recipient_id**: Foreign Key, references `User(user_id)`
- **message_body**: TEXT, NOT NULL
- **sent_at**: TIMESTAMP, DEFAULT CURRENT_TIMESTAMP

## Constraints

### User Table
- Unique constraint on `email`.
- Non-null constraints on required fields.

### Property Table
- Foreign key constraint on `host_id`.
- Non-null constraints on essential attributes.

### Booking Table
- Foreign key constraints on `property_id` and `user_id`.
- `status` must be one of `pending`, `confirmed`, or `canceled`.
- Note: `total_price` is maintained as a historical record of the agreed price at booking time.

### Payment Table
- Foreign key constraint on `booking_id`, ensuring payment is linked to valid bookings.

### Review Table
- Constraints on `rating` values (1-5).
- Foreign key constraints on `property_id` and `user_id`.

### Message Table
- Foreign key constraints on `sender_id` and `recipient_id`.

## Indexing
- **Primary Keys**: Indexed automatically.
- **Additional Indexes**:
  - `email` in the **User** table.
  - `property_id` in the **Property** and **Booking** tables.
  - `booking_id` in the **Booking** and **Payment** tables.
  - `city`, `state`, and `country` in the **Property** table for location-based searches.

## Key Changes for 3NF Compliance
1. Split the `location` field in the Property table into atomic components:
   - `street_address`
   - `city` 
   - `state`
   - `postal_code`
   - `country`