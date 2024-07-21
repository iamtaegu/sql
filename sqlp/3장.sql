select * from emp ;

select deptno from emp where deptno='123';

select * from table(dbms_xplan.display_cursor(sql_id=>'6h5f6d4gwkmar', format=>'ALLSTATS LAST'));

select sum(null+50+10) + sum(20+10+null) from dual;
select sum(null+10) + sum(20) from dual;

insert into emp(EMPNO, deptno) values(1, '');

select 1/24/(60/10), 24/(60/10), 1/4 from dual;

select round(4.875, 2) from dual;

-- 3장 (3.3.7)
CREATE TABLE 월별고객별판매집계
    AS
        SELECT
            ROWNUM      고객번호,
            '2018' || lpad(ceil(ROWNUM / 10000), 2, '0') 판매월,
            decode(mod(ROWNUM, 12), 1, 'A', 'B') 판매구분,
            round(dbms_random.value(1000, 10000), - 2)  판매금액
        FROM
            dual
        CONNECT BY
            level <= 120000;
            
commit;

select 
/*+ index(t 월별판매집계_IDX1) */ 
count(*) 
from 월별고객별판매집계 t
where 판매구분 = 'A' 
and 판매월 between '201801' and '201812';

-- BETWEEN > IN-List
SELECT 
/*+ index(t 월별판매집계_IDX2) */
    COUNT(*)
FROM
    월별고객별판매집계 t
WHERE 판매구분 = 'A'
AND 판매월 IN ( '201801', '201802', '201803', '201804', '201805',
             '201806', '201807', '201808', '201809', '201810',
             '201811', '201812' );

-- Index Skip Scan
select 
/*+ INDEX_SS(t 월별판매집계_IDX2) */ 
count(*) 
from 월별고객별판매집계 t
where 판매구분 = 'A' 
and 판매월 between '201801' and '201812';

create index 월별판매집계_IDX1 on 월별고객별판매집계(판매구분, 판매월);
create index 월별판매집계_IDX2 on 월별고객별판매집계(판매월, 판매구분);
                    
-- 3.3.9 BETWEEN과 LIKE 스캔 범위 비교 

-- 2018.01 ~ 2018.12 데이터를 조회한다
select distinct 판매구분 from 월별고객별판매집계;

select * from 월별고객별판매집계
where 판매월 like '2018%';
-- LIKE 연산자보다 BETWEEN이 더 정확한 표현식이다 
select * from 월별고객별판매집계
where 판매월 between '201801' and '201812';
-- //3.3.9 BETWEEN과 LIKE 스캔 범위 비교 

-- 3.3.11 다양한 옵션 조건 처리 방식의 장단점 비교
    
    -- LIKE/BETWEEN 조건 활용 > NULL 허용 컬럼 
    -- 비교연산 자체가 불가능하기 때문에 NULL이 저장돼 있어도 false 처리 되기 때문이다
select * from dual where null like :var || '%';

    -- UNION ALL 활용
select * from 월별고객별판매집계
where :고객번호 is null
and 판매월 between '201801' and '201812'
union all 
select * from 월별고객별판매집계
where :고객번호 is not null
and 고객번호 = :고객번호
and 판매월 between '201801' and '201812';

    -- NVL/DECODE 함수 활용
select * from 월별고객별판매집계
where 고객번호 = nvl(:고객번호, 고객번호) 
and 판매월 between '201801' and '201812';

select * from 월별고객별판매집계
where 고객번호 = DECODE(:고객번호, null, 고객번호, :고객번호) 
and 판매월 between '201801' and '201812';

-- //3.3.11 다양한 옵션 조건 처리 방식의 장단점 비교




