

CREATE TABLE 사원 (
    사원ID INT PRIMARY KEY,
    부서ID INT,
    연봉 DECIMAL(10, 2)
);

INSERT INTO 사원 (사원ID, 부서ID, 연봉) VALUES (1, 1, 2500);
INSERT INTO 사원 (사원ID, 부서ID, 연봉) VALUES (2, 1, 3000);
INSERT INTO 사원 (사원ID, 부서ID, 연봉) VALUES (3, 2, 4500);
INSERT INTO 사원 (사원ID, 부서ID, 연봉) VALUES (4, 2, 3000);
INSERT INTO 사원 (사원ID, 부서ID, 연봉) VALUES (5, 2, 2500);
INSERT INTO 사원 (사원ID, 부서ID, 연봉) VALUES (6, 3, 4500);
INSERT INTO 사원 (사원ID, 부서ID, 연봉) VALUES (7, 3, 3000);

-- 77번 
select 사원id, col2, col3 
from (select 사원id, 연봉
    ,row_number() over(partition by 부서id order by 연봉 desc) as col1
    ,sum(연봉) over(partition by 부서id order by 사원id rows between unbounded preceding and current row) as col2
    ,max(연봉) over(order by 연봉 desc rows current row) as col3 
        from 사원)
where col1 = 2
order by 1;

-- 001:350, 002:550, 003:350, 004:700, 005:700 