--- Asher Macdonald ---

--- Q1 ---
SELECT a.username, min(b.rating )
from userbase a
left join reviews b on a.userid = b.userid
group by a.username;

--- Q2 ---
SELECT a.EMAIL, b.QUESTION, b.ANSWER
FROM userbase a
JOIN securityquestion b on a.userid = b.userid;

--- Q3 ---
SELECT a.FIRSTNAME, a.EMAIL, a.WALLETFUNDS
FROM userbase a
where not exists (select 1
                    from wishlist b
                    where a.userid = b.userid);

--- Q4 ---
SELECT a.username, count(b.orderid)
FROM userbase a
JOIN orders b on a.userid = b.userid
GROUP BY a.username;

--- Q5 ---
SELECT a.userid, to_char(sysdate, 'yyyy') - to_char(a.birthday, 'yyyy'), b.purchasedate
FROM userbase a
LEFT OUTER JOIN orders b on a.userid = b.userid
WHERE b.purchasedate >= add_months(sysdate,-6)
ORDER BY b.purchasedate desc;

--- Q6 ---
SELECT a.username,
       a.birthday
FROM userbase a
JOIN (
        SELECT userid
        FROM friendslist
        GROUP BY userid
        HAVING COUNT(*) = (
            SELECT MAX(COUNT(*))
            FROM friendslist
            GROUP BY userid
        )
     ) b
ON a.userid = b.userid;

--- Q7 ---
SELECT a.productname,
       a.releasedate,
       a.price,
       a.description
FROM productlist a
JOIN wishlist b
    ON a.productcode = b.productcode;

--- Q8 ---
SELECT a.productname,
       MAX(b.rating) AS highest_rating,
       COUNT(*) AS review_count
FROM productlist a
JOIN reviews b
    ON a.productcode = b.productcode
GROUP BY a.productname
ORDER BY highest_rating DESC;

--- Q9 ---
CREATE VIEW vw_extreme_ratings AS
SELECT p.productname,
       p.genre,
       r.rating
FROM productlist p
JOIN reviews r
    ON p.productcode = r.productcode
WHERE r.rating IN (1, 5);

--- Q10 ---
SELECT p.genre,
       COUNT(*) AS product_count
FROM productlist p
JOIN orders o
    ON p.productcode = o.productcode
GROUP BY p.genre
ORDER BY p.genre ASC;

--- Q11 ---
CREATE OR REPLACE VIEW AS
SELECT A a.publisher_name, avg(a.price)
FROM productlist a
GROUP BY a.publisher_name;

--- Q12 ---
SELECT p.productcode, p.publisher, sum(o.price) v_price
FROM orders o
INNER JOIN productlist p on o.productcode = p.productcode
GROUP BY p.productcode, p.publisher;

--- Q13 ---
SELECT s.ticketid,
       u.username,
       u.email,
       s.issue
FROM usersupport s
JOIN userbase u
    ON s.email = u.email
WHERE s.status IN ('NEW', 'IN PROGRESS')
ORDER BY s.dateupdated;

--- Q14 ---
SELECT u.username,
       COUNT(s.ticketid) AS ticket_count
FROM usersupport s 
JOIN userbase u ON u.email = s.email
GROUP BY u.username;

--- Q15 ---
SELECT u.userid,
       u.email
FROM userbase u
JOIN usersupport s
    ON u.email = s.email
WHERE LOWER(s.email) LIKE '%' || LOWER(u.firstname) || '%'
   OR LOWER(s.email) LIKE '%' || LOWER(u.lastname) || '%'
   OR LOWER(s.email) LIKE '%' || LOWER(u.firstname || u.lastname) || '%';

--- Q16 ---
SELECT DISTINCT s.email, s.status
FROM usersupport s
WHERE s.status IN ('NEW', 'IN PROGRESS')
AND NOT EXISTS (
    SELECT 1
    FROM userbase u
    WHERE LOWER(u.email) = LOWER(s.email));

--- Q17 ---
SELECT s.ticketid,
       u.firstname,
       u.lastname,
       u.username
FROM usersupport s
JOIN userbase u
    ON LOWER(s.issue) LIKE '%' || LOWER(u.username) || '%';

--- Q18 ---
SELECT u.username,
       u.password
FROM userbase u
JOIN usersupport s
    ON LOWER(u.email) = LOWER(s.email);

--- Q19 ---
CREATE VIEW vw_recent_penalties AS
SELECT u.username,
       i.dateassigned,
       i.penalty
FROM userbase u
JOIN infractions i
    ON u.userid = i.userid
WHERE i.penalty IS NOT NULL
  AND i.dateassigned >= ADD_MONTHS(SYSDATE, -1);

--- Q20 ---
SELECT u.username,
       u.email
FROM userbase u
WHERE (MONTHS_BETWEEN(SYSDATE, u.birthday) / 12) >= 18
AND NOT EXISTS (
    SELECT 1
    FROM infractions i
    WHERE i.userid = u.userid
      AND i.dateassigned >= ADD_MONTHS(SYSDATE, -4));

--- Q21 ---
SELECT u.username,
       i.dateassigned,
       i.rulenum || ' ' || i.penalty AS full_guideline
FROM userbase u
JOIN infractions i
    ON u.userid = i.userid
ORDER BY i.dateassigned DESC;

--- Q22 ---
SELECT u.userid,
       u.username,
       u.email,
       SUM(c.severitypoint) AS total_severitypoints
FROM userbase u
JOIN infractions i
    ON u.userid = i.userid
JOIN communityrules c
    ON i.rulenum = c.rulenum
GROUP BY u.userid, u.username, u.email
ORDER BY total_severitypoints DESC;

--- Q23 ---
SELECT c.title,
       c.description,
       i.penalty
FROM infractions i
JOIN communityrules c
    ON i.rulenum = c.rulenum
ORDER BY i.dateassigned DESC;

--- Q24 ---
SELECT u.username,
       COUNT(i.infractionid) AS infraction_count
FROM userbase u
JOIN infractions i
    ON u.userid = i.userid
GROUP BY u.username
HAVING COUNT(i.infractionid) >= 15
ORDER BY infraction_count DESC;
