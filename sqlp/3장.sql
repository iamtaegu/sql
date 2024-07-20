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
                    