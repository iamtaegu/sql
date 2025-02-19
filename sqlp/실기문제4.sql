ALTER TABLE 주문 
ADD 주문금액 NUMBER NOT NULL 
ADD 우편번호 VARCHAR2(6) NOT NULL 
ADD 배송지 VARCHAR2(100) NOT NULL
ADD 연락처 VARCHAR2(14)
ADD 메모 VARCHAR2(100);

-- 기본답안
SELECT 주문고객번호, 주문일시, 주문금액, 우편번호, 배송지 FROM 주문 
WHERE 주문고객번호 = NVL(:cstmr_no, 0) 
-- >= 조건으로 처리하면, 자정(00:00)부터 포함 
AND 주문일시 >= to_date(:start_date, 'yyyymmdd') 
-- <= 조건으로 처리하면, 자정을 포함시키지 않음
AND 주문일시 < to_date(:end_date, 'yyyymmdd') + 1 
ORDER BY 주문일시 DESC
;
-- 모범답안
SELECT 주문고객번호, 주문일시, 주문금액, 우편번호, 배송지 FROM 주문 
WHERE 주문고객번호 = :cstmr_no
AND 주문일시 >= to_date(:start_date, 'yyyymmdd') 
AND 주문일시 < to_date(:end_date, 'yyyymmdd') + 1 
UNION ALL
SELECT 주문고객번호, 주문일시, 주문금액, 우편번호, 배송지 FROM 주문 
WHERE 주문고객번호 IS NULL 
AND 주문일시 >= to_date(:start_date, 'yyyymmdd') 
AND 주문일시 < to_date(:end_date, 'yyyymmdd') + 1 
ORDER BY 2 DESC;

-- 2번 답안
CREATE INDEX 주문_X1 ON 주문 (주문고객번호, 주문일시);
CREATE INDEX 주문_X2 ON 주문 (주문일시);
