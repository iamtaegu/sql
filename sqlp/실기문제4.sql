                            
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

/*
[문제]

하루 주문 건수는 평균 2만 건이며, 10년치 데이터가 저장돼 있다
고객번호는 입력하지 않을 수 있지만, 주문일자는 항상 입력해야 한다
주문일자로는 보통 3일을 입력하며, 최대 1주일까지 입력할 수 있다 

    1. 조회 버튼을 누를 때 수행할 최적의 SQL을 작성하시오
       개발 정책 상, Dynamic SQL은 사용할 수 없다. 주문일시 기준 역순으로 정렬해야 하며, 부분범위처리는 허용되지 않는다.
       즉, 조회된 결과 집합 전체를 그리드에 출력해야 한다
    2. 최적의 인덱스 구성안을 제시하시오 


1. 옵션 값은 UNION ALL로 처리한다
2. 주문일자는 정시를 고려해서 처리한다
3. 인덱스는 등치 조건으로 사용되거나, 자주 사용되거나, 정렬에 사용될 때 포함시킨다

*/

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
/*

고객번호를 입력할 때 가장 최적으로 수행하기 위한 인덱스 주문_X1
고객번호를 입력하지 않을 때 사용할 인덱스 주문_X2

[인덱스 구성안] 
X01 : 고객번호 + 주문일시
X02 : 주문일시
*/
CREATE INDEX 주문_X1 ON 주문 (주문고객번호, 주문일시);
CREATE INDEX 주문_X2 ON 주문 (주문일시);
