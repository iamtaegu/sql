-- Order by ���� ������� ������ Hash Group by 
-- Order by ���� ����ϸ� Sort Group by 
SELECT
    �μ��ڵ�, SUM(�޿�), MAX(�޿�), MIN(�޿�), AVG(�޿�)
FROM
    ���
GROUP BY
    �μ��ڵ�
order by �μ��ڵ� 
;

select distinct �μ��ڵ� from ��� order by �μ��ڵ�
;

-- Window Sort
select avg(�޿�) over (partition by �μ��ڵ�) from ���
;

-- 5.3 �ε����� �̿��� ��Ʈ ���� ����
CREATE TABLE ����ŷ� (
    �ŷ�ID NUMBER PRIMARY KEY, -- ���� �ĺ���
    �����ڵ� VARCHAR2(10) NOT NULL, -- ���� �ڵ�
    �ŷ��Ͻ� TIMESTAMP NOT NULL, -- �ŷ� �߻� �Ͻ�
    ü��Ǽ� NUMBER(10) NOT NULL, -- ü��� �ŷ� �Ǽ�
    ü����� NUMBER(15) NOT NULL, -- ü��� ����
    �ŷ���� NUMBER(20, 2) NOT NULL, -- �ŷ��� �� �ݾ�
    ����Ͻ� TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- ������ ��� �Ͻ�
    �����Ͻ� TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- ������ ���� �Ͻ�
);

-- �ε��� ���� �÷��� [�����ڵ�+�ŷ��Ͻ�] ������ �����ϸ� ��Ʈ ������ ������ �� ����
CREATE INDEX idx_�����ڵ�_�ŷ��Ͻ� ON ����ŷ�(�����ڵ�, �ŷ��Ͻ�);

select �ŷ��Ͻ�, ü��Ǽ�, ü�����, �ŷ����
from ����ŷ�
where �����ڵ� = 'KR123456'
order by �ŷ��Ͻ�
;

-- Top N ����
select * from (
    select �ŷ��Ͻ�, ü��Ǽ�, ü�����, �ŷ����
        from ����ŷ�
    where �����ڵ� = 'KR123456'
    order by �ŷ��Ͻ�
)
where ROWNUM <= 10 
;

-- ����¡ ó��
select * 
from (
    select rownum no, a.*
    from (
            select �ŷ��Ͻ�, ü��Ǽ�, ü�����, �ŷ����
                from ����ŷ�
            where �����ڵ� = 'KR123456'
            and �ŷ��Ͻ� >= '20240101'
            order by �ŷ��Ͻ�
        ) a
    where rownum <= (:page * 10)
)
where no >= (:page-1)*10 + 1;

