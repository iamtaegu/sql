CREATE TABLE 실기6_고객 (
    고객번호 NUMBER NOT NULL
    , 고객명 VARCHAR2(100) NOT NULL
    , 고객연락처 VARCHAR2(10) NOT NULL
    , 등록일시 DATE NOT NULL 
    , CONSTRAINT 실기6_고객_PK PRIMARY KEY (고객번호)
);

CREATE TABLE 실기6_주문 (
    주문번호 NUMBER NOT NULL
    , 주문일자 DATE NOT NULL
    , 주문고객번호 NUMBER NOT NULL
    , 주문상품수 NUMBER NOT NULL
    , 주문금액 NUMBER NOT NULL
    , 주문상태코드 CHAR NOT NULL
    , 할인금액 NUMBER 
    , 배송지주소코드 NUMBER
    , 배송지주소상세 VARCHAR2(1000)
    , CONSTRAINT 실기5_주문_PK PRIMARY KEY (주문번호)
);

CREATE TABLE 실기6_배송 (
    배송번호 NUMBER NOT NULL
    , 주문번호 NUMBER NOT NULL
    , 배송일자 DATE NOT NULL
    , 배송상태코드 CHAR NOT NULL
    , 배송업체번호 VARCHAR2(10)
    , 배송기사연락처 VARCHAR2(10)
    , CONSTRAINT 실기5_배송_PK PRIMARY KEY (배송번호)
);
COMMIT;

/*
[문제] 

*/

insert into 주문배송 t
select /*+ leading(o) use_nl(d) index(d) full(o) parallel(o 4) */
    o.주문번호, o.주문일자, o.주문상품수, o.주문상태코드, o.주문고객번호
    , (select 고객명 from 실기5_고객 where 고객번호 = o.주문고객번호) 고객명
    , d.배송번호, d.배송일자, d.배송상태코드, d.배송업체번호, d.배송기사연락처
from 실기5_주문 o, 실기5_배송 d
where o.주문일자 between '20160601' and '20160831'
and o.주문번호 = d.주문번호
;

1. 세션 병렬 DML 활성화 
2. OLAP 환경에서 테이블 풀스캔, 해시 조인을 활용한다 
 ㅇ index full scan 보다 index fast full scan 처리한다
3. 결과값이 많으면 조인으로 처리한다 
 ㅇ 스칼라 서브 쿼리는 레코드가 적을 때 사용한다

/**정답*
* 다른 트랜잭션에 의한 동시 DML이 없는 야간 배치용 SQL이므로 병렬 DML 활용이 가능하다 -- 1. Direct Path Load (?) 
* 병렬로 Insert 하려면 아래와 같이 parallel DML을 활성화해야 한다 -- 2. 
    - alter session enable parallel dml; 

* 인덱스를 이용한 NL 조인은 소량 데이터를 조인하는 데 적합하다
* 3, 000만 건에 이르는 데이터를 조인하면서 캐시히트율이 좋기를 기대할 수 없기 때문에 
    - 주문, 배송을 Full Scan과 해시 조인으로 유도한다 -- 3. 
        ㅇ 주문 테이블은 주문일자 기준으로 월단위 Range 파티션된 상태다
        ㅇ 다른 조건절 없이 주문일자(파티션키) 조건만으로 3개월치를 조회하는 데 인덱스를 이용할 이유가 없다 
        
        ㅇ 배송 테이블은 배송일자 기준으로 Range 파티션된 상태인데, 배송일자가 조건절에 없다
        ㅇ 따라서 full sacn으로 처리한다면 전체 파티션을 읽어야 한다
        ㅇ 3,000만건 조인하기 위해 수십억 건을 읽어야 할 수도 있고, 실행계획 10번 라인 PARTITION RANGE ALL을 통해 확인할 수 있다
        -> 배송은 주문이 완료된 후에 시작되기 때문에 배송일자도 20160601보다 크다 (PARTITION RANGE ALL 조치)

* 스칼라 서브쿼리는 NL 조인과 같은 방식으로 작동한다
* 스칼라 서브쿼리는 입력 값과 결과 값을 PGA에 캐싱한다는 점이 다르다 
* 따라서 입력 값 종류가 적을 때 실제 조인 횟수를 줄여줌으로써 빠른 성능을 기대할 수 있다
    - 여기서 고객 수가 500만 명이라고 명시했기 때문에 스칼라 서브쿼리 캐싱효과가 도움이 되지 않는 상황이다
    - 고객에 대한 스칼라 서브쿼리를 일반 조인문으로 변경한 후 해시 조인으로 유도한다 
    - 고객 테이블에서 고객명과 고객번호만 읽으면 되는 상황이므로 고객_N1 인덱스를 Fast Full Scan 방식으로 처리한다 -- 4.
    
* 온라인 트랜잭션이 없는 야간 배치용 SQL이고, 3,000만건에 이르는 대용량 데이터를 조인해야 하므로 병렬처리를 활용한다 -- 5.  

* 고객 테이블은 인덱스만 읽도록 유도했으므로 병렬 처리를 위해 parallel_index 힌트를 사용한다 -- 6. 

*/
insert /*+ parallel(t 4) */ into 주문배송 t 
select /*+ leading(d) 
            use_hash(o) use_hash(c) -- 3. 
            full(o) full(d) index_ffs(c) -- 4.
            parallel(o 4) parallel(d 4) parallel_index(c 4) */ -- 5, 6 
    o.주문번호, o.주문일자, o.주문상품수, o.주문상태코드, o.주문고객번호, c.고객명
    , d.배송번호, d.배송일자, d.배송상태코드, d.배송업체번호, d.배송기사연락처
from 실기5_주문 o, 실기5_배송 d, 실기5_고객 c 
where o.주문일자 between '20160601' and '20160831'
and o.주문번호 = d.주문번호
and c.고객번호 = o.주문고객번호
and d.배송일자 >= '20160601' -- PARTITION RANGE ALL 조치 

