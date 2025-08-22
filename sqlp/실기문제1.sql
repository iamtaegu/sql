SELECT parameter, value
FROM v$option
WHERE parameter = 'Partitioning';

/*

 * Enterprise 버전이 아니라서 파티셔닝 부분은 제외 

*/

CREATE TABLE 실기1_주문 (
    주문번호 NUMBER NOT NULL
    , 주문일시 DATE NOT NULL
    , 주문유형코드 VARCHAR2(10) NOT NULL
    , CONSTRAINT 실기1_주문_PK PRIMARY KEY (주문번호) -- USING INDEX LOCAL
) ;

PARTITION BY RANGE (주문번호) (
    PARTITION P_202201 VALUES LESS THAN ('20220201')
    , PARTITION P_MAXVALUE VALUES LESS THAN (MAXVALUE)
);

CREATE TABLE 실기1_주문상세 (
    주문번호 VARCHAR2(16) NOT NULL
    , 주문상품코드 VARCHAR2(10) NOT NULL
    , 주문수량 NUMBER NOT NULL 
    , CONSTRAINT 실기1_주문상세_PK PRIMARY KEY (주문번호, 주문상품코드) -- USING INDEX LOCAL
) ;

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

CREATE INDEX 실기1_주문_X1 ON 실기1_주문 (주문일시, 주문번호); -- LOCAL; 

commit;

/*
 문제
  1. 지문의 SQL을 변경하고 힌트를 기술하라. (단, 힌트는 조인방식과 조인순서에 대한 힌트만 기술)
  2. 병렬실행은 고려하지 않음 
*/
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
        , 실기1_상품 b 
WHERE b.상품코드 = a.주문상품코드
    AND b.상품유형코드 = 'A01'
;

/**

1. 파티션 Pruning을 위해 주문일시 조건을 주문번호로 변경한다
 ㅇ 파티션 프루닝은 쿼리를 실행할 때 필요한 파티션만 읽고, 나머지 파티션은 건너뛰는 최적화 기법 
2. 그룹핑 전에 상품 테이블을 조인하여 그룹핑 대상을 감소시킨다
3. TRUNC (c.주문일시), c.주문유형코드, a.상품코드, a.상품명로 그룹핑을 먼저 수행하여, NVL, DECODE 함수의 수행 횟수를 감소시킨다 
4. SUM 함수 내부에 사용한 NVL 함수를 집계가 끝난 후 1번만 수행할 수 있게 사용 위치를 변경한다 

1. Partition Pruning
    ㅇ 주문일시 조건을 파티션 키 주문번호로 변경한다
    ㅇ 주문번호 컬럼 유형에 맞춰 TO_DATE는 제거한다
2. 그룹핑 전에 상품 테이블을 조인하여 그룹핑 대상을 감소시킨다
    ㅇ 주문상세, 상품 테이블의 조인 조건을 서브쿼리에 넣는다
    ㅇ 상품 테이블 조건을 서브쿼리에 넣는다
3. 그룹핑을 먼저 수행하여 함수 수행 회수 감소시킨다   
    ㅇ 집계, 조회에 주문유형코드, 상품명 추가한다
    ㅇ 집계된 주문유형코드의 주문수량을 합한다
    ㅇ 외부 테이블에서 주문유형코드에 따라 합한다

**/
SELECT 주문일자
    , 상품코드
    , 상품명
    , NVL (SUM (DECODE (주문유형코드, 'A01', 주문수량)), 0) AS 주문수량_A01 -- 4.
    , NVL (SUM (DECODE (주문유형코드, 'A02', 주문수량)), 0) AS 주문수량_A02 -- 4. 
FROM (SELECT /*+ LEADING(A B C) USE_HASH(A B C) */ 
         TRUNC (c.주문일시) AS 주문일자
        , c.주문유형코드
        , a.상품코드
        , a.상품명 
        , SUM (b.주문수량) AS 주문수량 
        FROM 실기1_상품 a -- 2. 
            , 실기1_주문상세 b
            , 실기1_주문 c 
        WHERE a.상품유형코드 = 'A01'
            AND b.주문상품코드 = a.상품코드
            AND b.주문번호 >= '20220101' -- 1.
            AND b.주문번호 < '20220201' -- 1.
            AND c.주문번호 = b.주문번호
        GROUP BY TRUNC (c.주문일시), c.주문유형코드, a.상품코드, a.상품명) -- 3. 
GROUP BY 주문일자
    , 상품코드
    , 상품명 
;


