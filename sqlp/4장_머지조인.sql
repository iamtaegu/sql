-- 사원 테이블 생성
CREATE TABLE 사원 (
    사원번호 NUMBER ,
    이름 VARCHAR2(50),
    성 VARCHAR2(50),
    직책 VARCHAR2(100),
    관리자ID NUMBER,
    입사일자 DATE,
    급여 NUMBER(10, 2),
    부서코드 NUMBER
);

drop table 고객;

-- 고객 테이블 생성
CREATE TABLE 고객 (
    고객ID NUMBER ,
    이름 VARCHAR2(50),
    성 VARCHAR2(50),
    이메일 VARCHAR2(100),
    전화번호 VARCHAR2(20),
    주소 VARCHAR2(200),
    도시 VARCHAR2(50),
    주 VARCHAR2(50),
    우편번호 VARCHAR2(10),
    관리자사원번호 NUMBER,
    최종주문금액 NUMBER
);

-- 인덱스 생성
CREATE INDEX idx_고객_X1 ON 고객(관리자사원번호);
CREATE INDEX idx_사원_X1 ON 사원(사원번호);

-- 양쪽 테이블을 각각 소트한 후, 위쪽 사원 테이블 기준으로 아래쪽 고객 테이블과 머지 조인한다 
-- ordered와 use_merge(c) 힌트는 양쪽 테이블을 조인 컬럼 순으로 정렬한 후 정렬된 사원 기준으로 정렬된 고객과 조인하라 
select 
/*+ ordered use_merge(c) index(c idx_고객_X1) */
*
from 사원 e, 고객 c
where c.관리자사원번호 = e.사원번호
and e.입사일자 >= '19960101'
and e.부서코드 = '123'
and c.최종주문금액 >= 20000;
