-- ��� ���̺� ����
CREATE TABLE ��� (
    �����ȣ NUMBER ,
    �̸� VARCHAR2(50),
    �� VARCHAR2(50),
    ��å VARCHAR2(100),
    ������ID NUMBER,
    �Ի����� DATE,
    �޿� NUMBER(10, 2),
    �μ��ڵ� NUMBER
);

drop table ��;

-- �� ���̺� ����
CREATE TABLE �� (
    ��ID NUMBER ,
    �̸� VARCHAR2(50),
    �� VARCHAR2(50),
    �̸��� VARCHAR2(100),
    ��ȭ��ȣ VARCHAR2(20),
    �ּ� VARCHAR2(200),
    ���� VARCHAR2(50),
    �� VARCHAR2(50),
    �����ȣ VARCHAR2(10),
    �����ڻ����ȣ NUMBER,
    �����ֹ��ݾ� NUMBER
);

-- �ε��� ����
CREATE INDEX idx_��_X1 ON ��(�����ڻ����ȣ);
CREATE INDEX idx_���_X1 ON ���(�����ȣ);

-- ���� ���̺��� ���� ��Ʈ�� ��, ���� ��� ���̺� �������� �Ʒ��� �� ���̺�� ���� �����Ѵ� 
-- ordered�� use_merge(c) ��Ʈ�� ���� ���̺��� ���� �÷� ������ ������ �� ���ĵ� ��� �������� ���ĵ� ���� �����϶� 
select 
/*+ ordered use_merge(c) index(c idx_��_X1) */
*
from ��� e, �� c
where c.�����ڻ����ȣ = e.�����ȣ
and e.�Ի����� >= '19960101'
and e.�μ��ڵ� = '123'
and c.�����ֹ��ݾ� >= 20000;
