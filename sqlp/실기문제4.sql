ALTER TABLE �ֹ� 
ADD �ֹ��ݾ� NUMBER NOT NULL 
ADD �����ȣ VARCHAR2(6) NOT NULL 
ADD ����� VARCHAR2(100) NOT NULL
ADD ����ó VARCHAR2(14)
ADD �޸� VARCHAR2(100);

-- �⺻���
SELECT �ֹ�����ȣ, �ֹ��Ͻ�, �ֹ��ݾ�, �����ȣ, ����� FROM �ֹ� 
WHERE �ֹ�����ȣ = NVL(:cstmr_no, 0) 
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

-- 2�� ���
CREATE INDEX �ֹ�_X1 ON �ֹ� (�ֹ�����ȣ, �ֹ��Ͻ�);
CREATE INDEX �ֹ�_X2 ON �ֹ� (�ֹ��Ͻ�);
