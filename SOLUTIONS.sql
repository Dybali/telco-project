

/* 
1.1 List the customers who are subscribed to the 'Kobiye Destek' tariff.

I joined CUSTOMERS and TARIFFS because the tariff name is stored in the TARIFFS table.
Then I filtered the result by the tariff name 'Kobiye Destek'.
I selected the customer id, customer name, city, signup date, and tariff name to make the output readable.
*/

SELECT
    c.CUSTOMER_ID,
    c.NAME AS CUSTOMER_NAME,
    c.CITY,
    c.SIGNUP_DATE,
    t.NAME AS TARIFF_NAME
FROM CUSTOMERS c
JOIN TARIFFS t
    ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.NAME = 'Kobiye Destek'
ORDER BY c.CUSTOMER_ID;


/* 
1.2 Find the newest customer who subscribed to this tariff.

I used the same join with the TARIFFS table to find customers using the 'Kobiye Destek' tariff.
After that, I sorted the customers by SIGNUP_DATE from newest to oldest.
I used FETCH FIRST 1 ROW ONLY because only the newest customer is needed.
*/

SELECT
    c.CUSTOMER_ID,
    c.NAME AS CUSTOMER_NAME,
    c.CITY,
    c.SIGNUP_DATE,
    t.NAME AS TARIFF_NAME
FROM CUSTOMERS c
JOIN TARIFFS t
    ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.NAME = 'Kobiye Destek'
ORDER BY c.SIGNUP_DATE DESC, c.CUSTOMER_ID DESC
FETCH FIRST 1 ROW ONLY;


/* 
2.1 Find the distribution of tariffs among the customers.

For this question, I grouped customers according to their tariff.
I used COUNT to calculate how many customers are subscribed to each tariff.
I used LEFT JOIN so tariffs can still be shown even if they have no customers.
*/

SELECT
    t.TARIFF_ID,
    t.NAME AS TARIFF_NAME,
    COUNT(c.CUSTOMER_ID) AS CUSTOMER_COUNT
FROM TARIFFS t
LEFT JOIN CUSTOMERS c
    ON t.TARIFF_ID = c.TARIFF_ID
GROUP BY
    t.TARIFF_ID,
    t.NAME
ORDER BY CUSTOMER_COUNT DESC;


/* 
3.1 Identify the earliest customers to sign up.

The earliest signup date is found by using MIN(SIGNUP_DATE).
I did not use CUSTOMER_ID for this because the task says the earliest customers may not have the lowest IDs.
If more than one customer has the same earliest date, this query returns all of them.
*/

SELECT
    CUSTOMER_ID,
    NAME AS CUSTOMER_NAME,
    CITY,
    SIGNUP_DATE,
    TARIFF_ID
FROM CUSTOMERS
WHERE SIGNUP_DATE = (
    SELECT MIN(SIGNUP_DATE)
    FROM CUSTOMERS
)
ORDER BY CUSTOMER_ID;


/* 
3.2 Find the distribution of these earliest customers across different cities.

First, I selected only the customers who signed up on the earliest signup date.
Then I grouped these customers by city.
This shows how many of the first customers came from each city.
*/

SELECT
    CITY,
    COUNT(*) AS EARLIEST_CUSTOMER_COUNT
FROM CUSTOMERS
WHERE SIGNUP_DATE = (
    SELECT MIN(SIGNUP_DATE)
    FROM CUSTOMERS
)
GROUP BY CITY
ORDER BY EARLIEST_CUSTOMER_COUNT DESC, CITY;


/* 
4.1 Identify the IDs of customers whose monthly records are missing.

I used CUSTOMERS as the main table because every customer should have a monthly record.
Then I used LEFT JOIN with MONTHLY_STATS to find customers without a matching monthly row.
Rows where ms.CUSTOMER_ID is NULL are the missing monthly records.
*/

SELECT
    c.CUSTOMER_ID
FROM CUSTOMERS c
LEFT JOIN MONTHLY_STATS ms
    ON c.CUSTOMER_ID = ms.CUSTOMER_ID
WHERE ms.CUSTOMER_ID IS NULL
ORDER BY c.CUSTOMER_ID;


/* 
4.2 Find the distribution of these missing customers across different cities.

This query uses the same missing record logic from the previous question.
Instead of listing customer IDs, I grouped the missing customers by city.
This helps to see which cities have more missing monthly records.
*/

SELECT
    c.CITY,
    COUNT(*) AS MISSING_CUSTOMER_COUNT
FROM CUSTOMERS c
LEFT JOIN MONTHLY_STATS ms
    ON c.CUSTOMER_ID = ms.CUSTOMER_ID
WHERE ms.CUSTOMER_ID IS NULL
GROUP BY c.CITY
ORDER BY MISSING_CUSTOMER_COUNT DESC, c.CITY;


/* 
5.1 Find the customers who have used at least 75% of their data limit.

I joined all three tables because customer information, tariff limits, and usage values are in different tables.
The data usage percentage is calculated by dividing DATA_USAGE by DATA_LIMIT.
The WHERE condition keeps only customers who used at least 75 percent of their data package.
*/

SELECT
    c.CUSTOMER_ID,
    c.NAME AS CUSTOMER_NAME,
    c.CITY,
    t.NAME AS TARIFF_NAME,
    t.DATA_LIMIT,
    ms.DATA_USAGE,
    ROUND((ms.DATA_USAGE / t.DATA_LIMIT) * 100, 2) AS DATA_USAGE_PERCENTAGE
FROM CUSTOMERS c
JOIN TARIFFS t
    ON c.TARIFF_ID = t.TARIFF_ID
JOIN MONTHLY_STATS ms
    ON c.CUSTOMER_ID = ms.CUSTOMER_ID
WHERE t.DATA_LIMIT > 0
  AND ms.DATA_USAGE >= t.DATA_LIMIT * 0.75
ORDER BY DATA_USAGE_PERCENTAGE DESC;


/* 
5.2 Identify the customers who have completely exhausted all of their package limits.

For this question, I compared each usage value with its related package limit.
A customer is included only when data, minute, and SMS usage are all greater than or equal to the limits.
This means the customer has used all three package limits for the current month.
*/

SELECT
    c.CUSTOMER_ID,
    c.NAME AS CUSTOMER_NAME,
    c.CITY,
    t.NAME AS TARIFF_NAME,
    t.DATA_LIMIT,
    ms.DATA_USAGE,
    t.MINUTE_LIMIT,
    ms.MINUTE_USAGE,
    t.SMS_LIMIT,
    ms.SMS_USAGE
FROM CUSTOMERS c
JOIN TARIFFS t
    ON c.TARIFF_ID = t.TARIFF_ID
JOIN MONTHLY_STATS ms
    ON c.CUSTOMER_ID = ms.CUSTOMER_ID
WHERE ms.DATA_USAGE >= t.DATA_LIMIT
  AND ms.MINUTE_USAGE >= t.MINUTE_LIMIT
  AND ms.SMS_USAGE >= t.SMS_LIMIT
ORDER BY c.CUSTOMER_ID;


/* 
6.1 Find the customers who have unpaid fees.

The payment status is stored in the MONTHLY_STATS table.
I joined it with CUSTOMERS and TARIFFS to show customer and tariff details together.
Then I filtered the rows where PAYMENT_STATUS is equal to 'UNPAID'.
*/

SELECT
    c.CUSTOMER_ID,
    c.NAME AS CUSTOMER_NAME,
    c.CITY,
    t.NAME AS TARIFF_NAME,
    t.MONTHLY_FEE,
    ms.PAYMENT_STATUS
FROM CUSTOMERS c
JOIN TARIFFS t
    ON c.TARIFF_ID = t.TARIFF_ID
JOIN MONTHLY_STATS ms
    ON c.CUSTOMER_ID = ms.CUSTOMER_ID
WHERE ms.PAYMENT_STATUS = 'UNPAID'
ORDER BY c.CUSTOMER_ID;


/* 
6.2 Find the distribution of all payment statuses across the different tariffs.

I grouped the records by tariff and payment status.
COUNT is used to find how many customers are in each payment status group.
This result makes it easier to compare payment situations between different tariffs.
*/

SELECT
    t.TARIFF_ID,
    t.NAME AS TARIFF_NAME,
    ms.PAYMENT_STATUS,
    COUNT(*) AS CUSTOMER_COUNT
FROM TARIFFS t
JOIN CUSTOMERS c
    ON t.TARIFF_ID = c.TARIFF_ID
JOIN MONTHLY_STATS ms
    ON c.CUSTOMER_ID = ms.CUSTOMER_ID
GROUP BY
    t.TARIFF_ID,
    t.NAME,
    ms.PAYMENT_STATUS
ORDER BY
    t.TARIFF_ID,
    ms.PAYMENT_STATUS;