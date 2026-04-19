
/*
TELCO PROJECT 
*/


/*
1.1 List the customers who are subscribed to the 'Kobiye Destek' tariff.

For this question I needed the tariff name, so I joined CUSTOMERS with TARIFFS.
The CUSTOMERS table only has TARIFF_ID, but the real tariff name is in the TARIFFS table.
After joining the tables, I filtered the rows where the tariff name is 'Kobiye Destek'.
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
Result:
This query returns the customers who use the Kobiye Destek tariff.
I did not paste all rows here because the result has many customers.
The output shows customer id, name, city, signup date, and tariff name.
*/


/*
1.2 Find the newest customer who subscribed to this tariff.

I used the same join again because I still need to filter by tariff name.
Then I ordered the result by SIGNUP_DATE descending to put the newest customer at the top.
I used FETCH FIRST 1 ROW ONLY because the question asks for only the newest customer.
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
Result:
This query returns one customer.
That customer is the newest one among the customers using Kobiye Destek.
I also ordered by CUSTOMER_ID after date just to make the result more stable if dates are same.
*/


/*
2.1 Find the distribution of tariffs among the customers.

In this query I counted how many customers are using each tariff.
I grouped the result by tariff id and tariff name.
I used LEFT JOIN because I wanted to keep all tariffs in the result even if a tariff had no customer.
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
Result:
TARIFF_ID | TARIFF_NAME    | CUSTOMER_COUNT
2         | Kurumsal SMS   | 2577
1         | Genç Dinamik   | 2527
4         | Kobiye Destek  | 2483
3         | Çalışan GB     | 2413

Kurumsal SMS has the highest customer count.
Çalışan GB has the lowest customer count.
The numbers are still close to each other, so the tariffs are not extremely unbalanced.
*/


/*
3.1 Identify the earliest customers to sign up.

For this question I first found the minimum SIGNUP_DATE from the CUSTOMERS table.
Then I selected the customers whose SIGNUP_DATE is equal to that minimum date.
I did not use CUSTOMER_ID for this because the earliest customer does not always have the smallest id.
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
Result:
This query returns the first customers according to signup date.
There can be more than one customer because more than one person may have signed up on the same earliest day.
I ordered them by CUSTOMER_ID to make the result easier to check.
*/


/*
3.2 Find the distribution of these earliest customers across different cities.

I used the same earliest signup date condition from the previous question.
After filtering only those earliest customers, I grouped them by CITY.
Then I counted how many earliest customers came from each city.
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
Result:
This query returned 24 rows.

CITY            | EARLIEST_CUSTOMER_COUNT
BATMAN          | 2
HAKKARİ         | 2
ŞIRNAK          | 2
AFYONKARAHİSAR  | 1
ARDAHAN         | 1
ARTVİN          | 1
AĞRI            | 1
BARTIN          | 1
BAYBURT         | 1
BOLU            | 1
BİNGÖL          | 1
DÜZCE           | 1
EDİRNE          | 1
ELAZIĞ          | 1
ERZURUM         | 1
ESKİŞEHİR       | 1
GİRESUN         | 1
HATAY           | 1
KAHRAMANMARAŞ   | 1
KIRKLARELİ      | 1
KOCAELİ         | 1
KONYA           | 1
MERSİN          | 1
YOZGAT          | 1

Batman, Hakkari, and Şırnak have 2 earliest customers.
The other cities in this result have 1 earliest customer.
This shows that the earliest signup customers are spread across different cities.
*/


/*
4.1 Identify the IDs of customers whose monthly records are missing.

Every customer should normally have a row in MONTHLY_STATS.
So I used CUSTOMERS as the main table and used LEFT JOIN with MONTHLY_STATS.
If the joined MONTHLY_STATS value is NULL, it means that customer does not have a monthly record.
*/

SELECT
    c.CUSTOMER_ID
FROM CUSTOMERS c
LEFT JOIN MONTHLY_STATS ms
    ON c.CUSTOMER_ID = ms.CUSTOMER_ID
WHERE ms.CUSTOMER_ID IS NULL
ORDER BY c.CUSTOMER_ID;

/*
Result:
This query returned 50 rows.

Missing CUSTOMER_ID values:
6, 10, 31, 39, 45, 81, 116, 136, 140, 156,
205, 211, 218, 221, 229, 233, 301, 326, 329, 343,
413, 449, 458, 463, 467, 507, 526, 533, 534, 543,
577, 583, 596, 604, 616, 617, 678, 783, 788, 819,
842, 869, 885, 889, 903, 905, 930, 935, 953, 988

These customers are in CUSTOMERS but not in MONTHLY_STATS.
So their monthly usage and payment information is missing.
The total missing record count is 50.
*/


/*
4.2 Find the distribution of these missing customers across different cities.

I used the same LEFT JOIN method from question 4.1.
This time I grouped the missing customers by city instead of listing only their ids.
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
Result:
This query returned 39 rows.

CITY        | MISSING_CUSTOMER_COUNT
OSMANİYE    | 3
BİTLİS      | 2
DENİZLİ     | 2
KAYSERİ     | 2
KIRIKKALE   | 2
MUŞ         | 2
NEVŞEHİR    | 2
ORDU        | 2
SİVAS       | 2
İZMİR       | 2
ADANA       | 1
ANTALYA     | 1
ARDAHAN     | 1
AĞRI        | 1
BURDUR      | 1
BURSA       | 1
DÜZCE       | 1
ERZURUM     | 1
ESKİŞEHİR   | 1
GAZİANTEP   | 1
GÜMÜŞHANE   | 1
GİRESUN     | 1
HATAY       | 1
KARABÜK     | 1
KARAMAN     | 1
KIRKLARELİ  | 1
KIRŞEHİR    | 1
KOCAELİ     | 1
KONYA       | 1
MANİSA      | 1
MARDİN      | 1
NİĞDE       | 1
SAKARYA     | 1
SAMSUN      | 1
SİİRT       | 1
TEKİRDAĞ    | 1
YALOVA      | 1
ÇANKIRI     | 1
ŞIRNAK      | 1

Osmaniye has the highest missing count with 3 customers.
Some cities have 2 missing customers.
Most cities in this output have only 1 missing customer.
*/


/*
5.1 Find the customers who have used at least 75% of their data limit.

To solve this, I needed both usage data and package limit data.
The usage values are in MONTHLY_STATS and the limits are in TARIFFS.
I calculated the percentage by dividing DATA_USAGE by DATA_LIMIT and filtered the customers who reached at least 75%.
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
Result:
This query returns customers who used at least 75 percent of their data package.
I also added DATA_USAGE_PERCENTAGE to see the usage ratio more clearly.
The result can have many rows, so I ordered it from highest percentage to lowest.
*/


/*
5.2 Identify the customers who have completely exhausted all of their package limits.

Here I compared data usage, minute usage, and SMS usage with their package limits.
A customer must pass all three conditions to be included in the result.
So this query only returns customers who used all data, minute, and SMS limits.
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
Result:
This query returns customers who completely used all package limits.
The customer must reach the data limit, minute limit, and SMS limit together.
If one of these values is still below the limit, that customer is not included.
*/


/*
6.1 Find the customers who have unpaid fees.

The payment information is in the MONTHLY_STATS table.
I joined it with CUSTOMERS and TARIFFS because I wanted to show customer and tariff details too.
Then I filtered only the rows where PAYMENT_STATUS is 'UNPAID'.
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
Result:
This query lists the customers whose payment status is UNPAID.
The output also shows the tariff name and monthly fee.
There are many unpaid rows, so I ordered the result by customer id.
*/


/*
6.2 Find the distribution of all payment statuses across the different tariffs.

For this question I grouped the data by tariff and payment status.
Then I used COUNT to find how many customers are in each group.
This makes it easier to compare PAID, LATE, and UNPAID counts for every tariff.
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

/*
Result:
This query returned 12 rows.

TARIFF_ID | TARIFF_NAME   | PAYMENT_STATUS | CUSTOMER_COUNT
1         | Genç Dinamik  | LATE           | 372
1         | Genç Dinamik  | PAID           | 1792
1         | Genç Dinamik  | UNPAID         | 352
2         | Kurumsal SMS  | LATE           | 368
2         | Kurumsal SMS  | PAID           | 1796
2         | Kurumsal SMS  | UNPAID         | 403
3         | Çalışan GB    | LATE           | 365
3         | Çalışan GB    | PAID           | 1692
3         | Çalışan GB    | UNPAID         | 339
4         | Kobiye Destek | LATE           | 392
4         | Kobiye Destek | PAID           | 1719
4         | Kobiye Destek | UNPAID         | 360

For every tariff, PAID has the highest count.
Kurumsal SMS has the highest unpaid customer count with 403.
All tariffs have three payment status groups: LATE, PAID, and UNPAID.
*/