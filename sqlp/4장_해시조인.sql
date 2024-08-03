select 
/*+ use_hash(e c) index(e idx_사원_X1) index(c idx_고객_X1) */
*
from 사원 e, 고객 c
where c.관리자사원번호 = e.사원번호
and e.입사일자 >= '19960101'
and e.부서코드 = '123'
and c.최종주문금액 >= 20000;