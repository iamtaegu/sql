CREATE TABLE PRACTICE_T1 (C1 NUMBER NOT NULL, C2 VARCHAR2(1) NOT NULL);
CREATE TABLE PRACTICE_T2 (C1 NUMBER NOT NULL, C2 VARCHAR2(1) NOT NULL);

CREATE INDEX PRACTICE_T1_x1 on PRACTICE_T1 (c1);
CREATE INDEX PRACTICE_T2_x1 on PRACTICE_T2 (c2);

/* 
[����]
    �Ʒ� UPDATE ���� ������ �����϶�.
        1. ������ �����ϱ� ���� ������ UPDATE ���� �����ϰ� ���μ���, ���ι��, ���������� ���õ� ��Ʈ�� ����϶�
        2. t1.c1, t2.c2 Į���� ī��θ�Ƽ�� �����ȹ�� �����ϴٰ� ����
        3. ���Ľ����� ������� ���� 
*/

UPDATE PRACTICE_T1
    SET c2 = 'Y'
WHERE ( c1 = :v1
    OR c1 IN (SELECT c1 
                FROM PRACTICE_T2
              WHERE c2 = :v2));            

/*
[�ؼ�]
    1. OR ���ǿ� ���������� ����ϸ� �������� UNNEST�� �Ұ����ϹǷ� UNION ALL �����ڸ� ����� ���������� OR ������ �����Ѵ�
    2. ���μ���, ���ι���� �����ϱ� ���� UPDATE ���� ORDERED USE_NL(T1) ��Ʈ, �������� UNNEST ��Ʈ�� ����Ѵ�
    (T1 ���̺� ���� NL�� ����϶�)
    3. t2 ���̺��� c2 Į���� �Ͻ��� ������ ��ȯ���� ���� �ε����� ������� ���ϹǷ� �������� �����Ѵ�
    4. ���ǿ� �ش��ϴ� �ο��� c2�� 'Y'�� �����ϹǷ� c2 != 'Y' ������ �߰��Ͽ� ���ʿ��� ������ ���ҽ�Ų��
*/

UPDATE /*+ ORDERED USE_NL(PRACTICE_T1) */ -- 2.
    PRACTICE_T1
    SET c2 = 'Y'
WHERE ( c1 IN (SELECT /*+ UNNEST */ -- 2.
                :v1
            FROM DUAL
            UNION ALL -- 1. 
            SELECT c1 
                FROM PRACTICE_T2
              WHERE c2 = TO_CHAR(:v2))) -- 3. 
AND c2 != 'Y' -- 4. 
