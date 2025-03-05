                            
CREATE TABLE 실기4_주문 (
    주문번호 NUMBER NOT NULL
    , 고객번호 NUMBER NOT NULL
    , 주문일시 DATE NOT NULL
    , 주문금액 NUMBER NOT NULL
    , 우편번호 VARCHAR2(6) NOT NULL
    , 배송지 VARCHAR2(100) NOT NULL
    , 연락처 VARCHAR2(14)
    , 메모 VARCHAR2(100)
    , CONSTRAINT 실기4_주문_PK PRIMARY KEY (주문번호)
)
;    

-- 기본답안
SELECT 주문고객번호, 주문일시, 주문금액, 우편번호, 배송지 FROM 주문 
WHERE 주문고객번호 = NVL(:cstmr_no, 고객번호) 
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
