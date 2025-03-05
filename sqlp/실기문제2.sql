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

-- 문제
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

-- 해설
SELECT /*+ LEADING(a b) use_nl(a b) */ -- 4.
    a.*
    ,b.주문수량
    ,c.고객명
    FROM (SELECT a.*
            , ROWNUM as rn
        FROM (SELECT /*+ LEADING(a b) use_nl(a b) */ -- 4.
                    TO_CHAR (a.주문일시, 'YYYY-MM-DD HH24:MI:SS') AS 주문일시
                    , a.주문고객번호
                    , b.ROWID as rid -- 5. 
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
AND b.ROWID = a.rid -- 5.
AND c.고객번호 = a.주문고객번호 -- 3. 
ORDER BY a.주문일시
;
