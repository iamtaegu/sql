ALTER TABLE 고객 
ADD 등록일시 DATE NOT NULL 
ADD 고객상태코드 VARCHAR2(1) NOT NULL 
ADD 연락처 VARCHAR2(14)
ADD 주소 VARCHAR2(100);

ALTER TABLE 고객
MODIFY 고객상태코드 VARCHAR2(2);

CREATE TABLE 고객접속이력 (
    접속일시 DATE NOT NULL,
    고객번호 NUMBER NOT NULL,
    접속경로 VARCHAR2(100),
    CONSTRAINT 고객접속이력_FK FOREIGN KEY (고객번호)
        REFERENCES 고객(고객번호)
)
;

-- 조회/다음
SELECT
    고객번호, 고객명, 등록일시, 연락처, 주소,
    (
        SELECT MAX(접속일시) FROM 고객접속이력 -- 3.
        WHERE 고객번호 = a.고객번호
        AND 접속일시 >= trunc(add_months(sysdate, - 1)) -- 2. 
    ) 최종접속일시
FROM (
        SELECT
            ROWNUM AS no, a.*
        FROM (
                SELECT
                    고객번호, 고객명, 등록일시, 연락처, 주소
                FROM 고객
                WHERE 고객상태코드 = 'AC' -- 1.
                ORDER BY 등록일시, 고객번호 -- 1. 
            ) a
        WHERE ROWNUM <= :page * 20 -- 4.
    ) a
WHERE a.no >= ( :page - 1 ) * 20 + 1 -- 4.
;
-- 파일로 출력
SELECT
    a.고객번호, a.고객명, a.등록일시, a.연락처, a.주소, b.최종접속일시 
FROM 고객 a, (
        SELECT 고객번호, MAX(접속일시) 최종접속일시 FROM 고객접속이력 -- 3.
        WHERE 접속일시 >= trunc(add_months(sysdate, - 1)) -- 2.
        GROUP BY 고객번호
    ) b
WHERE a.고객상태코드 = 'AC' -- 1.
and a.고객번호 = b.고객번호
ORDER BY a.등록일시, a.고객번호 -- 1. 
;

CREATE INDEX 고객_X1 ON 고객 (고객상태코드, 등록일시, 고객번호);
CREATE INDEX 고객접속이력_X1 ON 고객접속이력 (고객번호, 접속일시);
