CREATE TABLE 실기2_주문 (
    주문번호 NUMBER NOT NULL
    , 주문일시 DATE NOT NULL
    , 주문고객번호 NUMBER NOT NULL
    , CONSTRAINT 실기2_주문_PK PRIMARY KEY (주문번호)
);

CREATE TABLE 실기2_주문상세 (
    주문번호 NUMBER NOT NULL
    , 주문상품코드 VARCHAR2(10) NOT NULL
    , 주문수량 NUMBER NOT NULL
    , CONSTRAINT 실기2_주문상세_PK PRIMARY KEY (주문번호, 주문상품코드)
);

CREATE TABLE 실기2_고객 (
    고객번호 NUMBER NOT NULL
    , 고객명 VARCHAR2(100) NOT NULL
    , CONSTRAINT 실기2_고객_PK PRIMARY KEY (고객번호)
);

CREATE INDEX 실기2_주문_X1 ON 실기2_주문 (주문일시, 주문번호); 

commit; 

/*
 문제
  1. 지문의 SQL을 변경하고 힌트를 기술하라. (단, 힌트는 조인방식과 조인순서에 대한 힌트만 기술)
*/
SELECT 
    *
FROM (SELECT a.*,
            ROWNUM AS rn
        FROM (SELECT
                    to_char(a.주문일시, 'YYYY-MM-DD HH24:MI:SS') AS 주문일시,
                    a.주문번호,
                    b.주문수량,
                    c.고객명
                FROM
                    실기2_주문   a,
                    실기2_주문상세 b,
                    실기2_고객   c
                WHERE
                        a.주문일시 >= TO_DATE('2022-01-01', 'YYYY-MM-DD')
                    AND a.주문일시 < TO_DATE('2022-01-02', 'YYYY-MM-DD')
                    AND b.주문번호 = a.주문번호
                    AND b.주문상품코드 = 'A01'
                    AND c.고객번호 = a.주문고객번호
                ORDER BY 1) a)
WHERE rn BETWEEN 101 AND 200;

/*

    1. ORDER BY A.주문일시로 변경  
     ㅇ ORDER BY 1에 의해 to_char(a.주문일시, 'YYYY-MM-DD HH24:MI:SS') 표현식으로 데이터를 정렬하여 소트에 인덱스를 활용할 수 없으므로
    2. ROWNUM <= 200 조건절 추가 
     ㅇ ROWNUM 슈도 컬럼을 직접 기술하지 않아 부분 범위 처리가 불가능
    3. 고객 테이블의 조인 횟수를 감소시키기 위해 Top-N 처리 후 고객 테이블을 조인
    4. 주문상세 테이블은 Top-N 처리에서는 인덱스만 액세스하고 Top-N 처리 후 셀프 조인을 통해 나머지 컬럼 조회

1. 가공된 인덱스 컬럼 제거
    ㅇ ORDER BY 1에 의한 표현식을 ORDER BY A.주문일시로 명시
2. ROWNUM 슈도 컬럼 명시
    ㅇ 부분 범위 처리를 위해 서브쿼리에 슈도 컬럼을 넣는다
3. Top-N 처리 후 외부 테이블에서 조인한다
    ㅇ 서브쿼리에서 고객 테이블 외부로 빼고 조인한다
4. Top-N 처리에서 인덱스만 접근한다
    ㅇ 외부에서 ROWID를 통해 셀프 조인으로 나머지 컬럼 조회

*/
SELECT /*+ LEADING(A B) USE_NL(A B) */ 
    a.*
    ,b.주문수량
    ,c.고객명
    FROM (SELECT a.*
            , ROWNUM as rn
        FROM (SELECT /*+ LEADING(A B) USE_NL(A B) */ 
                    TO_CHAR (a.주문일시, 'YYYY-MM-DD HH24:MI:SS') AS 주문일시
                    , a.주문고객번호
                    , b.ROWID as rid -- 4
            FROM 실기2_주문 a
                , 실기2_주문상세 b                
            WHERE a.주문일시 >= TO_DATE ('2022-01-01', 'YYYY-MM-DD')
            AND a.주문일시 < TO_DATE ('2022-01-02', 'YYYY-MM-DD')
            AND b.주문번호 = a.주문번호
            AND b.주문상품코드 = 'A01'
        ORDER BY a.주문일시) a  -- 1. 
    WHERE ROWNUM <= 200) a -- 2, 3
    , 실기2_주문상세 b 
    , 실기2_고객 c
WHERE rn >= 101
AND b.ROWID = a.rid -- 4
AND c.고객번호 = a.주문고객번호 -- 3
ORDER BY a.주문일시 -- 1. 
;
