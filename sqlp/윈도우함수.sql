-- sales 테이블 생성
CREATE TABLE sales (
    sale_id NUMBER PRIMARY KEY,
    region VARCHAR2(50),
    product VARCHAR2(50),
    amount NUMBER
);

-- 데이터 삽입
INSERT INTO sales (sale_id, region, product, amount) VALUES (1, 'North', 'ProductA', 100);
INSERT INTO sales (sale_id, region, product, amount) VALUES (2, 'North', 'ProductB', 150);
INSERT INTO sales (sale_id, region, product, amount) VALUES (3, 'South', 'ProductA', 200);
INSERT INTO sales (sale_id, region, product, amount) VALUES (4, 'South', 'ProductB', 250);
INSERT INTO sales (sale_id, region, product, amount) VALUES (5, 'East', 'ProductA', 300);
INSERT INTO sales (sale_id, region, product, amount) VALUES (6, 'East', 'ProductB', 350);

commit;

SELECT region, product, SUM(amount) AS total_amount
FROM sales
GROUP BY GROUPING SETS (
    (region, product),
    (region),
    (product),
    ()
)
;

select region, product, SUM(amount) AS total_amount
FROM sales
group by rollup (region, product) 
;

select region, product, SUM(amount) AS total_amount 
from sales
group by cube (region, product) 
;