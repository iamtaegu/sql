ALTER TABLE �� 
ADD ����Ͻ� DATE NOT NULL 
ADD �������ڵ� VARCHAR2(1) NOT NULL 
ADD ����ó VARCHAR2(14)
ADD �ּ� VARCHAR2(100);

ALTER TABLE ��
MODIFY �������ڵ� VARCHAR2(2);

CREATE TABLE �������̷� (
    �����Ͻ� DATE NOT NULL,
    ����ȣ NUMBER NOT NULL,
    ���Ӱ�� VARCHAR2(100),
    CONSTRAINT �������̷�_FK FOREIGN KEY (����ȣ)
        REFERENCES ��(����ȣ)
)
;

-- ��ȸ/����
SELECT
    ����ȣ, ����, ����Ͻ�, ����ó, �ּ�,
    (
        SELECT MAX(�����Ͻ�) FROM �������̷� -- 3.
        WHERE ����ȣ = a.����ȣ
        AND �����Ͻ� >= trunc(add_months(sysdate, - 1)) -- 2. 
    ) ���������Ͻ�
FROM (
        SELECT
            ROWNUM AS no, a.*
        FROM (
                SELECT
                    ����ȣ, ����, ����Ͻ�, ����ó, �ּ�
                FROM ��
                WHERE �������ڵ� = 'AC' -- 1.
                ORDER BY ����Ͻ�, ����ȣ -- 1. 
            ) a
        WHERE ROWNUM <= :page * 20 -- 4.
    ) a
WHERE a.no >= ( :page - 1 ) * 20 + 1 -- 4.
;
-- ���Ϸ� ���
SELECT
    a.����ȣ, a.����, a.����Ͻ�, a.����ó, a.�ּ�, b.���������Ͻ� 
FROM �� a, (
        SELECT ����ȣ, MAX(�����Ͻ�) ���������Ͻ� FROM �������̷� -- 3.
        WHERE �����Ͻ� >= trunc(add_months(sysdate, - 1)) -- 2.
        GROUP BY ����ȣ
    ) b
WHERE a.�������ڵ� = 'AC' -- 1.
and a.����ȣ = b.����ȣ
ORDER BY a.����Ͻ�, a.����ȣ -- 1. 
;

CREATE INDEX ��_X1 ON �� (�������ڵ�, ����Ͻ�, ����ȣ);
CREATE INDEX �������̷�_X1 ON �������̷� (����ȣ, �����Ͻ�);
