select 
/*+ use_hash(e c) index(e idx_���_X1) index(c idx_��_X1) */
*
from ��� e, �� c
where c.�����ڻ����ȣ = e.�����ȣ
and e.�Ի����� >= '19960101'
and e.�μ��ڵ� = '123'
and c.�����ֹ��ݾ� >= 20000;