CREATE TABLE PRACTICE_T1 (C1 NUMBER NOT NULL, C2 VARCHAR2(1) NOT NULL);
CREATE TABLE PRACTICE_T2 (C1 NUMBER NOT NULL, C2 VARCHAR2(1) NOT NULL);

CREATE INDEX PRACTICE_T1_x1 on PRACTICE_T1 (c1);
CREATE INDEX PRACTICE_T2_x1 on PRACTICE_T2 (c2);

/* 
[문제]
    아래 UPDATE 문의 성능을 개선하라.
        1. 성능을 개선하기 위해 지문의 UPDATE 문을 변경하고 조인순서, 조인방식, 서브쿼리와 관련된 힌트를 기술하라
        2. t1.c1, t2.c2 칼럼의 카디널리티는 실행계획과 유사하다고 가정
        3. 병렬실행은 고려하지 않음 
*/

UPDATE PRACTICE_T1
    SET c2 = 'Y'
WHERE ( c1 = :v1
    OR c1 IN (SELECT c1 
                FROM PRACTICE_T2
              WHERE c2 = :v2));            

/*
[해설]
    1. OR 조건에 서브쿼리를 사용하면 서브쿼리 UNNEST가 불가능하므로 UNION ALL 연산자를 사용한 서브쿼리로 OR 조건을 제거한다
    2. 조인순서, 조인방식을 지시하기 위해 UPDATE 절은 ORDERED USE_NL(T1) 힌트, 서브쿼리 UNNEST 힌트를 기술한다
    (T1 테이블에 대해 NL을 사용하라)
    3. t2 테이블의 c2 칼럼은 암시적 데이터 변환으로 인해 인덱스를 사용하지 못하므로 조건절을 변경한다
    4. 조건에 해당하는 로우의 c2를 'Y'로 갱신하므로 c2 != 'Y' 조건을 추가하여 불필요한 갱신을 감소시킨다

1. OLTP 환경에서 서브쿼리는 UNNEST 처리한다
    ㅇ OR 조건에 서브쿼리를 사용하면 UNNEST가 불가능하므로 UNION ALL 처리한다
2. 조인순서, 조인방식을 지시한다
3. 가공된 인덱스 컬럼 제거
    ㅇ 바인딩 컬럼을 문자열로 명시한다
4. 갱신 내용은 대상에서 제외한다

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
