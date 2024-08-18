SELECT table_name FROM user_tables;
-- 라이브러리 캐시
-- SQL 문 그 자체가 키 값이고, 대소문자를 구분한다 
SELECT * FROM V$SQL; 

select * from emp ;
select * from dept ;

select e.empno, e.ename, e.job, d.dname, d.loc
from emp e, dept d
where e.deptno = d.deptno
order by e.ename;

-- 테스트용 테이블
create table t
as
select d.no, e.*
from emp e, (select rownum no from dual connect by level <= 1000) d; 
-- 인덱스
create index t_x01 on t(deptno, no);
create index t_x02 on t(deptno, job, no);

-- T 테이블에 통계정보를 수집하는 명령어
exec dbms_stats.gather_table_stats(user, 't');

/*+ index(t t_x02) */

select 
/*+ full(t) */
* from t 
where deptno = 10
and no = 1;

-- 힌드 예제 테이블
CREATE TABLE 주문 (
    주문ID INT PRIMARY KEY,              -- 주문 ID (기본 키)
    고객ID INT NOT NULL,                 -- 고객 ID (필수 입력)
    주문날짜 DATE NOT NULL,              -- 주문 날짜
    배송주소 VARCHAR(255),              -- 배송 주소
    주문상태 VARCHAR(50),               -- 주문 상태 (예: '대기', '배송 중', '완료' 등)
    총금액 DECIMAL(10, 2) NOT NULL      -- 총 금액 (필수 입력)
);
create index 주문_x01 on 주문(주문날짜, 고객ID);
create index 고객_PK on 고객(고객ID);
commit;

select 
/*+ LEADING(A) USE_NL(B) INDEX(A (주문날짜)) INDEX(B 고객_PK) */
* 
from 주문 A, 고객 B
where a.주문날짜 = '20240818'
and a.고객ID = b.고객id;

