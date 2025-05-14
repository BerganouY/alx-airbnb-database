# Query Optimization Process

## Initial Complex Query

The file starts with a complex query that joins multiple tables:

- `Booking` table (central table)
- `User` table (joined twice: once for guest, once for host)
- `Property` table
- `Payment` table
- `Review` table

### Performance Issues Identified:

- Too many joins creating a large result set
- Problematic `LEFT JOIN` to reviews causing booking duplication
- Unbounded result set with no `LIMIT` clause
- Inefficient sorting on the entire result set

---

## Performance Analysis

Detailed performance analysis includes identification of:

- Execution plan bottlenecks
- Potential table scan issues
- Join inefficiencies
- Missing or underutilized indexes

---

## Progressive Refactoring

The file contains multiple refactored versions of the query, each addressing different performance concerns.

### 1. **Basic Optimization**

- Added date range bounds
- Added `LIMIT` clause
- Removed review-related columns
- Reduced the number of returned columns

### 2. **Separate Review Lookup**

- Uses Common Table Expression (CTE) for main query
- Handles reviews in a separate query to prevent duplication
- Implements more efficient filtering

### 3. **Pagination Approach**

- Implements keyset pagination for large datasets
- Uses `EXISTS` subquery instead of `LEFT JOIN` for payment verification
- Further reduces the number of returned columns

### 4. **Materialized View Approach**

- Creates a materialized view for frequently accessed data
- Adds specific indexes to the materialized view
- Demonstrates how to refresh the data periodically

---

## Performance Testing

Includes techniques for measuring and comparing query execution times:

- Before and after optimization
- Using SQL execution plans and timing metrics

---

## Implementation Recommendations

Beyond SQL refactoring, the file includes a comprehensive set of recommendations:

### Query Structure Improvements

- Select only necessary columns
- Apply efficient filtering and pagination strategies
- Reduce or eliminate unnecessary joins

### Index Recommendations

- Use composite and covering indexes
- Add specific indexes to improve pagination performance

### Database Configuration

- Allocate memory for complex operations
- Consider using read replicas for load distribution

### Application-Level Changes

- Implement caching strategies
- Use lazy loading for related data
- Optimize API design for data retrieval

### Monitoring

- Track query performance over time
- Maintain accurate database statistics

---
