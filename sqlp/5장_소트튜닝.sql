-- Order by 절을 명시하지 않으면 Hash Group by 
-- Order by 절을 명시하면 Sort Group by 
SELECT
    부서코드, SUM(급여), MAX(급여), MIN(급여), AVG(급여)
FROM
    사원
GROUP BY
    부서코드
order by 부서코드 
;

select distinct 부서코드 from 사원 order by 부서코드
;

-- Window Sort
select avg(급여) over (partition by 부서코드) from 사원
;

-- 5.3 인덱스를 이용한 소트 연산 생략
CREATE TABLE 종목거래 (
    거래ID NUMBER PRIMARY KEY, -- 고유 식별자
    종목코드 VARCHAR2(10) NOT NULL, -- 종목 코드
    거래일시 TIMESTAMP NOT NULL, -- 거래 발생 일시
    체결건수 NUMBER(10) NOT NULL, -- 체결된 거래 건수
    체결수량 NUMBER(15) NOT NULL, -- 체결된 수량
    거래대금 NUMBER(20, 2) NOT NULL, -- 거래된 총 금액
    등록일시 TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 데이터 등록 일시
    수정일시 TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- 데이터 수정 일시
);

-- 인덱스 선두 컬럼을 [종목코도+거래일시] 순으로 구성하면 소트 연산을 생략할 수 있음
CREATE INDEX idx_종목코드_거래일시 ON 종목거래(종목코드, 거래일시);

select 거래일시, 체결건수, 체결수량, 거래대금
from 종목거래
where 종목코드 = 'KR123456'
order by 거래일시
;

-- Top N 쿼리
select * from (
    select 거래일시, 체결건수, 체결수량, 거래대금
        from 종목거래
    where 종목코드 = 'KR123456'
    order by 거래일시
)
where ROWNUM <= 10 
;

-- 페이징 처리
select * 
from (
    select rownum no, a.*
    from (
            select 거래일시, 체결건수, 체결수량, 거래대금
                from 종목거래
            where 종목코드 = 'KR123456'
            and 거래일시 >= '20240101'
            order by 거래일시
        ) a
    where rownum <= (:page * 10)
)
where no >= (:page-1)*10 + 1;

-- 5.3.3 최소값/최대값 구하기

create index emp_x1 on 사원(급여);

select max(급여) from 사원;

drop index emp_x1;
create index emp_x1 on 사원(부서코드, 관리자ID, 급여);

select max(급여) from 사원 where 부서코드 = 30 and 관리자id = 7698;

-- 5.3.5 Sort Group By 생략

desc 고객;

select 관리자사원번호, avg(최종주문금액), count(*) from 고객
group by 관리자사원번호;
