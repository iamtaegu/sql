SELECT table_name FROM user_tables;
-- ���̺귯�� ĳ��
-- SQL �� �� ��ü�� Ű ���̰�, ��ҹ��ڸ� �����Ѵ� 
SELECT * FROM V$SQL; 

select * from emp ;
select * from dept ;

select e.empno, e.ename, e.job, d.dname, d.loc
from emp e, dept d
where e.deptno = d.deptno
order by e.ename;

-- �׽�Ʈ�� ���̺�
create table t
as
select d.no, e.*
from emp e, (select rownum no from dual connect by level <= 1000) d; 
-- �ε���
create index t_x01 on t(deptno, no);
create index t_x02 on t(deptno, job, no);

-- T ���̺� ��������� �����ϴ� ��ɾ�
exec dbms_stats.gather_table_stats(user, 't');

/*+ index(t t_x02) */

select 
/*+ full(t) */
* from t 
where deptno = 10
and no = 1;

-- ���� ���� ���̺�
CREATE TABLE �ֹ� (
    �ֹ�ID INT PRIMARY KEY,              -- �ֹ� ID (�⺻ Ű)
    ��ID INT NOT NULL,                 -- �� ID (�ʼ� �Է�)
    �ֹ���¥ DATE NOT NULL,              -- �ֹ� ��¥
    ����ּ� VARCHAR(255),              -- ��� �ּ�
    �ֹ����� VARCHAR(50),               -- �ֹ� ���� (��: '���', '��� ��', '�Ϸ�' ��)
    �ѱݾ� DECIMAL(10, 2) NOT NULL      -- �� �ݾ� (�ʼ� �Է�)
);
create index �ֹ�_x01 on �ֹ�(�ֹ���¥, ��ID);
create index ��_PK on ��(��ID);
commit;

select 
/*+ LEADING(A) USE_NL(B) INDEX(A (�ֹ���¥)) INDEX(B ��_PK) */
* 
from �ֹ� A, �� B
where a.�ֹ���¥ = '20240818'
and a.��ID = b.��id;

