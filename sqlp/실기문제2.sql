CREATE TABLE �Ǳ�2_�ֹ� (
    �ֹ���ȣ NUMBER NOT NULL
    , �ֹ��Ͻ� DATE NOT NULL
    , �ֹ�����ȣ NUMBER NOT NULL
    , CONSTRAINT �Ǳ�2_�ֹ�_PK PRIMARY KEY (�ֹ���ȣ)
);

CREATE TABLE �Ǳ�2_�ֹ��� (
    �ֹ���ȣ NUMBER NOT NULL
    , �ֹ���ǰ�ڵ� VARCHAR2(10) NOT NULL
    , �ֹ����� NUMBER NOT NULL
    , CONSTRAINT �Ǳ�2_�ֹ���_PK PRIMARY KEY (�ֹ���ȣ, �ֹ���ǰ�ڵ�)
);

CREATE TABLE �Ǳ�2_�� (
    ����ȣ NUMBER NOT NULL
    , ���� VARCHAR2(100) NOT NULL
    , CONSTRAINT �Ǳ�2_��_PK PRIMARY KEY (����ȣ)
);

CREATE INDEX �Ǳ�2_�ֹ�_X1 ON �Ǳ�2_�ֹ� (�ֹ��Ͻ�, �ֹ���ȣ); 

-- ����
SELECT 
    *
FROM (SELECT a.*,
            ROWNUM AS rn
        FROM (SELECT
                    to_char(a.�ֹ��Ͻ�, 'YYYY-MM-DD HH24:MI:SS') AS �ֹ��Ͻ�,
                    a.�ֹ���ȣ,
                    b.�ֹ�����,
                    c.����
                FROM
                    �Ǳ�2_�ֹ�   a,
                    �Ǳ�2_�ֹ��� b,
                    �Ǳ�2_��   c
                WHERE
                        a.�ֹ��Ͻ� >= TO_DATE('2022-01-01', 'YYYY-MM-DD')
                    AND a.�ֹ��Ͻ� < TO_DATE('2022-01-02', 'YYYY-MM-DD')
                    AND b.�ֹ���ȣ = a.�ֹ���ȣ
                    AND b.�ֹ���ǰ�ڵ� = 'A01'
                    AND c.����ȣ = a.�ֹ�����ȣ
                ORDER BY 1) a)
WHERE rn BETWEEN 101 AND 200;

-- �ؼ�
SELECT /*+ LEADING(a b) use_nl(a b) */ -- 4.
    a.*
    ,b.�ֹ�����
    ,c.����
    FROM (SELECT a.*
            , ROWNUM as rn
        FROM (SELECT /*+ LEADING(a b) use_nl(a b) */ -- 4.
                    TO_CHAR (a.�ֹ��Ͻ�, 'YYYY-MM-DD HH24:MI:SS') AS �ֹ��Ͻ�
                    , a.�ֹ�����ȣ
                    , b.ROWID as rid -- 5. 
            FROM �Ǳ�2_�ֹ� a
                , �Ǳ�2_�ֹ��� b                
            WHERE a.�ֹ��Ͻ� >= TO_DATE ('2022-01-01', 'YYYY-MM-DD')
            AND a.�ֹ��Ͻ� < TO_DATE ('2022-01-02', 'YYYY-MM-DD')
            AND b.�ֹ���ȣ = a.�ֹ���ȣ
            AND b.�ֹ���ǰ�ڵ� = 'A01'
        ORDER BY a.�ֹ��Ͻ�) a  -- 1. 
    WHERE ROWNUM <= 200) a -- 2, 3
    , �Ǳ�2_�ֹ��� b 
    , �Ǳ�2_�� c
WHERE rn >= 101
AND b.ROWID = a.rid -- 5.
AND c.����ȣ = a.�ֹ�����ȣ -- 3. 
ORDER BY a.�ֹ��Ͻ�
;
