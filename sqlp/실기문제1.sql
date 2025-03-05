
SELECT parameter, value
FROM v$option
WHERE parameter = 'Partitioning';

CREATE TABLE 실기1_주문 (
    주문번호 NUMBER NOT NULL
    , 주문일시 DATE NOT NULL
    , 주문유형코드 VARCHAR2(10) NOT NULL
    , CONSTRAINT 실기1_주문_PK PRIMARY KEY (주문번호) USING INDEX LOCAL
)
PARTITION BY RANGE (주문번호) (
    PARTITION P_202201 VALUES LESS THAN ('20220201')
    , PARTITION P_MAXVALUE VALUES LESS THAN (MAXVALUE)
);

CREATE TABLE 실기1_주문상세 (
    주문번호 VARCHAR2(16) NOT NULL
    , 주문상품코드 VARCHAR2(10) NOT NULL
    , 주문수량 NUMBER NOT NULL 
    , CONSTRAINT 실기1_주문상세_PK PRIMARY KEY (주문번호, 주문상품코드) USING INDEX LOCAL
) 
PARTITION BY RANGE (주문번호) ( 
    PARTITION P_202201 VALUE LESS THAN ('20220201')
    , PARTITION P_MAXVALUE VALUE LESS THAN (MAXVALUE) 
);

CREATE TABLE 실기1_상품 ( 
    상품코드 VARCHAR2(10) NOT NULL
    , 상품명 VARCHAR2(100) NOT NULL
    , 상품유형코드 VARCHAR2(10) NOT NULL 
    , CONSTRAINT 실기1_상품_PK PRIMARY KEY (상품코드)
);

CREATE INDEX 실기1_주문_X1 ON 실기1_주문 (주문일시, 주문번호) LOCAL; 

/**문제**/
SELECT a.주문일시
    , b.상품명
    , a.주문수량_A01
    , a.주문수량_A02
FROM (SELECT TRUNC (a.주문일시) AS 주문일시
        , b.주문상품코드
        , SUM (DECODE (a.주문유형코드, 'A01', NVL (b.주문수량, 0))) AS 주문수량_A01
        , SUM (DECODE (a.주문유형코드, 'A02', NVL (b.주문수량, 0))) AS 주문수량_A02
        FROM 실기1_주문 a
            , 실기1_주문상세 b
        WHERE a.주문일시 >= TO_DATE ('2022-01-01', 'YYYY-MM-DD')
            AND a.주문일시 < TO_DATE ('2022-02-01', 'YYYY-MM-DD')
            AND b.주문번호 = a.주문번호
        GROUP BY TRUNC (a.주문일시), b.주문상품코드) a
        , 상품 b 
WHERE b.상품코드 = a.주문상품코드
    AND b.상품유형코드 = 'A01'
;

/**

1. 파티션 Pruning을 위해 주문일시 조건을 주문번호로 변경한다 
2. 그룹핑 전에 상품 테이블을 조인하여 그룹핑 대상을 감소시킨다
3. TRUNC (c.주문일시), c.주문유형코드, a.상품코드, a.상품명로 그룹핑을 먼저 수행하여 NVL, DECODE 함수의 수행 횟수를 감소시킨다 
4. SUM 함수 내부에 사용한 NVL 함수를 집계가 끝난 후 1번만 수행할 수 있게 사용 위치를 변경한다 

**/
SELECT 주문일자,
    , 상품코드
    , 상품명
    , NVL (SUM (DECODE (a.주문유형코드, 'A01', NVL (b.주문수량, 0))), 0) AS 주문수량_A01 -- 4.
    , NVL (SUM (DECODE (a.주문유형코드, 'A02', NVL (b.주문수량, 0))), 0) AS 주문수량_A02 -- 4. 
FROM (SELECT TRUNC (a.주문일시) AS 주문일자
        , c.주문유형코드
        , a.상품코드
        , a.상품명 
        , SUM (b.주문수량) AS 주문수량 
        FROM 실기1_상품 a -- 2. 
            , 실기1_주문상세 b
            , 실기1_주문 c 
        WHERE a.상품유형코드 = 'A01'
            AND  b.주문상품코드 = a.상품코드
            AND a.주문번호 >= TO_DATE ('2022-01-01', 'YYYY-MM-DD') -- 1.
            AND a.주문번호 < TO_DATE ('2022-02-01', 'YYYY-MM-DD') -- 1.
            AND b.주문번호 = a.주문번호
        GROUP BY TRUNC (c.주문일시), c.주문유형코드, a.상품코드, a.상품명) -- 3. 
GROUP BY 주문일자
    , 상품코드
    , 상품명 
;



