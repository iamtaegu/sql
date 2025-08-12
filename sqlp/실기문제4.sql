                            
CREATE TABLE �Ǳ�4_�ֹ� (
    �ֹ���ȣ NUMBER NOT NULL
    , ����ȣ NUMBER NOT NULL
    , �ֹ��Ͻ� DATE NOT NULL
    , �ֹ��ݾ� NUMBER NOT NULL
    , �����ȣ VARCHAR2(6) NOT NULL
    , ����� VARCHAR2(100) NOT NULL
    , ����ó VARCHAR2(14)
    , �޸� VARCHAR2(100)
    , CONSTRAINT �Ǳ�4_�ֹ�_PK PRIMARY KEY (�ֹ���ȣ)
)
;    

/*
[����]

�Ϸ� �ֹ� �Ǽ��� ��� 2�� ���̸�, 10��ġ �����Ͱ� ����� �ִ�
����ȣ�� �Է����� ���� �� ������, �ֹ����ڴ� �׻� �Է��ؾ� �Ѵ�
�ֹ����ڷδ� ���� 3���� �Է��ϸ�, �ִ� 1���ϱ��� �Է��� �� �ִ� 

    1. ��ȸ ��ư�� ���� �� ������ ������ SQL�� �ۼ��Ͻÿ�
       ���� ��å ��, Dynamic SQL�� ����� �� ����. �ֹ��Ͻ� ���� �������� �����ؾ� �ϸ�, �κй���ó���� ������ �ʴ´�.
       ��, ��ȸ�� ��� ���� ��ü�� �׸��忡 ����ؾ� �Ѵ�
    2. ������ �ε��� �������� �����Ͻÿ� 

*/

-- �⺻���
SELECT �ֹ�����ȣ, �ֹ��Ͻ�, �ֹ��ݾ�, �����ȣ, ����� FROM �ֹ� 
WHERE �ֹ�����ȣ = NVL(:cstmr_no, ����ȣ) 
-- >= �������� ó���ϸ�, ����(00:00)���� ���� 
AND �ֹ��Ͻ� >= to_date(:start_date, 'yyyymmdd') 
-- <= �������� ó���ϸ�, ������ ���Խ�Ű�� ����
AND �ֹ��Ͻ� < to_date(:end_date, 'yyyymmdd') + 1 
ORDER BY �ֹ��Ͻ� DESC
;

-- ������
SELECT �ֹ�����ȣ, �ֹ��Ͻ�, �ֹ��ݾ�, �����ȣ, ����� FROM �ֹ� 
WHERE �ֹ�����ȣ = :cstmr_no
AND �ֹ��Ͻ� >= to_date(:start_date, 'yyyymmdd') 
AND �ֹ��Ͻ� < to_date(:end_date, 'yyyymmdd') + 1 
UNION ALL
SELECT �ֹ�����ȣ, �ֹ��Ͻ�, �ֹ��ݾ�, �����ȣ, ����� FROM �ֹ� 
WHERE �ֹ�����ȣ IS NULL 
AND �ֹ��Ͻ� >= to_date(:start_date, 'yyyymmdd') 
AND �ֹ��Ͻ� < to_date(:end_date, 'yyyymmdd') + 1 
ORDER BY 2 DESC; 
/*

����ȣ�� �Է��� �� ���� �������� �����ϱ� ���� �ε��� �ֹ�_X1
����ȣ�� �Է����� ���� �� ����� �ε��� �ֹ�_X2

[�ε��� ������] 
X01 : ����ȣ + �ֹ��Ͻ�
X02 : �ֹ��Ͻ�
*/
CREATE INDEX �ֹ�_X1 ON �ֹ� (�ֹ�����ȣ, �ֹ��Ͻ�);
CREATE INDEX �ֹ�_X2 ON �ֹ� (�ֹ��Ͻ�);
