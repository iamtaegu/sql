
SELECT parameter, value
FROM v$option
WHERE parameter = 'Partitioning';

CREATE TABLE �Ǳ�1_�ֹ� (
    �ֹ���ȣ NUMBER NOT NULL
    , �ֹ��Ͻ� DATE NOT NULL
    , �ֹ������ڵ� VARCHAR2(10) NOT NULL
    , CONSTRAINT �Ǳ�1_�ֹ�_PK PRIMARY KEY (�ֹ���ȣ) USING INDEX LOCAL
)
PARTITION BY RANGE (�ֹ���ȣ) (
    PARTITION P_202201 VALUES LESS THAN ('20220201')
    , PARTITION P_MAXVALUE VALUES LESS THAN (MAXVALUE)
);

CREATE TABLE �Ǳ�1_�ֹ��� (
    �ֹ���ȣ VARCHAR2(16) NOT NULL
    , �ֹ���ǰ�ڵ� VARCHAR2(10) NOT NULL
    , �ֹ����� NUMBER NOT NULL 
    , CONSTRAINT �Ǳ�1_�ֹ���_PK PRIMARY KEY (�ֹ���ȣ, �ֹ���ǰ�ڵ�) USING INDEX LOCAL
) 
PARTITION BY RANGE (�ֹ���ȣ) ( 
    PARTITION P_202201 VALUE LESS THAN ('20220201')
    , PARTITION P_MAXVALUE VALUE LESS THAN (MAXVALUE) 
);

CREATE TABLE �Ǳ�1_��ǰ ( 
    ��ǰ�ڵ� VARCHAR2(10) NOT NULL
    , ��ǰ�� VARCHAR2(100) NOT NULL
    , ��ǰ�����ڵ� VARCHAR2(10) NOT NULL 
    , CONSTRAINT �Ǳ�1_��ǰ_PK PRIMARY KEY (��ǰ�ڵ�)
);

CREATE INDEX �Ǳ�1_�ֹ�_X1 ON �Ǳ�1_�ֹ� (�ֹ��Ͻ�, �ֹ���ȣ) LOCAL; 

/**����**/
SELECT a.�ֹ��Ͻ�
    , b.��ǰ��
    , a.�ֹ�����_A01
    , a.�ֹ�����_A02
FROM (SELECT TRUNC (a.�ֹ��Ͻ�) AS �ֹ��Ͻ�
        , b.�ֹ���ǰ�ڵ�
        , SUM (DECODE (a.�ֹ������ڵ�, 'A01', NVL (b.�ֹ�����, 0))) AS �ֹ�����_A01
        , SUM (DECODE (a.�ֹ������ڵ�, 'A02', NVL (b.�ֹ�����, 0))) AS �ֹ�����_A02
        FROM �Ǳ�1_�ֹ� a
            , �Ǳ�1_�ֹ��� b
        WHERE a.�ֹ��Ͻ� >= TO_DATE ('2022-01-01', 'YYYY-MM-DD')
            AND a.�ֹ��Ͻ� < TO_DATE ('2022-02-01', 'YYYY-MM-DD')
            AND b.�ֹ���ȣ = a.�ֹ���ȣ
        GROUP BY TRUNC (a.�ֹ��Ͻ�), b.�ֹ���ǰ�ڵ�) a
        , ��ǰ b 
WHERE b.��ǰ�ڵ� = a.�ֹ���ǰ�ڵ�
    AND b.��ǰ�����ڵ� = 'A01'
;

/**

1. ��Ƽ�� Pruning�� ���� �ֹ��Ͻ� ������ �ֹ���ȣ�� �����Ѵ� 
2. �׷��� ���� ��ǰ ���̺��� �����Ͽ� �׷��� ����� ���ҽ�Ų��
3. TRUNC (c.�ֹ��Ͻ�), c.�ֹ������ڵ�, a.��ǰ�ڵ�, a.��ǰ��� �׷����� ���� �����Ͽ� NVL, DECODE �Լ��� ���� Ƚ���� ���ҽ�Ų�� 
4. SUM �Լ� ���ο� ����� NVL �Լ��� ���谡 ���� �� 1���� ������ �� �ְ� ��� ��ġ�� �����Ѵ� 

**/
SELECT �ֹ�����,
    , ��ǰ�ڵ�
    , ��ǰ��
    , NVL (SUM (DECODE (a.�ֹ������ڵ�, 'A01', NVL (b.�ֹ�����, 0))), 0) AS �ֹ�����_A01 -- 4.
    , NVL (SUM (DECODE (a.�ֹ������ڵ�, 'A02', NVL (b.�ֹ�����, 0))), 0) AS �ֹ�����_A02 -- 4. 
FROM (SELECT TRUNC (a.�ֹ��Ͻ�) AS �ֹ�����
        , c.�ֹ������ڵ�
        , a.��ǰ�ڵ�
        , a.��ǰ�� 
        , SUM (b.�ֹ�����) AS �ֹ����� 
        FROM �Ǳ�1_��ǰ a -- 2. 
            , �Ǳ�1_�ֹ��� b
            , �Ǳ�1_�ֹ� c 
        WHERE a.��ǰ�����ڵ� = 'A01'
            AND  b.�ֹ���ǰ�ڵ� = a.��ǰ�ڵ�
            AND a.�ֹ���ȣ >= TO_DATE ('2022-01-01', 'YYYY-MM-DD') -- 1.
            AND a.�ֹ���ȣ < TO_DATE ('2022-02-01', 'YYYY-MM-DD') -- 1.
            AND b.�ֹ���ȣ = a.�ֹ���ȣ
        GROUP BY TRUNC (c.�ֹ��Ͻ�), c.�ֹ������ڵ�, a.��ǰ�ڵ�, a.��ǰ��) -- 3. 
GROUP BY �ֹ�����
    , ��ǰ�ڵ�
    , ��ǰ�� 
;



