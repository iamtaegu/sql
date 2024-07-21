select * from emp ;

select deptno from emp where deptno='123';

select * from table(dbms_xplan.display_cursor(sql_id=>'6h5f6d4gwkmar', format=>'ALLSTATS LAST'));

select sum(null+50+10) + sum(20+10+null) from dual;
select sum(null+10) + sum(20) from dual;

insert into emp(EMPNO, deptno) values(1, '');

select 1/24/(60/10), 24/(60/10), 1/4 from dual;

select round(4.875, 2) from dual;

-- 3�� (3.3.7)
CREATE TABLE ���������Ǹ�����
    AS
        SELECT
            ROWNUM      ����ȣ,
            '2018' || lpad(ceil(ROWNUM / 10000), 2, '0') �Ǹſ�,
            decode(mod(ROWNUM, 12), 1, 'A', 'B') �Ǹű���,
            round(dbms_random.value(1000, 10000), - 2)  �Ǹűݾ�
        FROM
            dual
        CONNECT BY
            level <= 120000;
            
commit;

select 
/*+ index(t �����Ǹ�����_IDX1) */ 
count(*) 
from ���������Ǹ����� t
where �Ǹű��� = 'A' 
and �Ǹſ� between '201801' and '201812';

-- BETWEEN > IN-List
SELECT 
/*+ index(t �����Ǹ�����_IDX2) */
    COUNT(*)
FROM
    ���������Ǹ����� t
WHERE �Ǹű��� = 'A'
AND �Ǹſ� IN ( '201801', '201802', '201803', '201804', '201805',
             '201806', '201807', '201808', '201809', '201810',
             '201811', '201812' );

-- Index Skip Scan
select 
/*+ INDEX_SS(t �����Ǹ�����_IDX2) */ 
count(*) 
from ���������Ǹ����� t
where �Ǹű��� = 'A' 
and �Ǹſ� between '201801' and '201812';

create index �����Ǹ�����_IDX1 on ���������Ǹ�����(�Ǹű���, �Ǹſ�);
create index �����Ǹ�����_IDX2 on ���������Ǹ�����(�Ǹſ�, �Ǹű���);
                    
-- 3.3.9 BETWEEN�� LIKE ��ĵ ���� �� 

-- 2018.01 ~ 2018.12 �����͸� ��ȸ�Ѵ�
select distinct �Ǹű��� from ���������Ǹ�����;

select * from ���������Ǹ�����
where �Ǹſ� like '2018%';
-- LIKE �����ں��� BETWEEN�� �� ��Ȯ�� ǥ�����̴� 
select * from ���������Ǹ�����
where �Ǹſ� between '201801' and '201812';
-- //3.3.9 BETWEEN�� LIKE ��ĵ ���� �� 

-- 3.3.11 �پ��� �ɼ� ���� ó�� ����� ����� ��
    
    -- LIKE/BETWEEN ���� Ȱ�� > NULL ��� �÷� 
    -- �񱳿��� ��ü�� �Ұ����ϱ� ������ NULL�� ����� �־ false ó�� �Ǳ� �����̴�
select * from dual where null like :var || '%';

    -- UNION ALL Ȱ��
select * from ���������Ǹ�����
where :����ȣ is null
and �Ǹſ� between '201801' and '201812'
union all 
select * from ���������Ǹ�����
where :����ȣ is not null
and ����ȣ = :����ȣ
and �Ǹſ� between '201801' and '201812';

    -- NVL/DECODE �Լ� Ȱ��
select * from ���������Ǹ�����
where ����ȣ = nvl(:����ȣ, ����ȣ) 
and �Ǹſ� between '201801' and '201812';

select * from ���������Ǹ�����
where ����ȣ = DECODE(:����ȣ, null, ����ȣ, :����ȣ) 
and �Ǹſ� between '201801' and '201812';

-- //3.3.11 �پ��� �ɼ� ���� ó�� ����� ����� ��




