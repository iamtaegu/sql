
-- 세그먼트에 할당된 익스텐트 목록 조회
select segment_type, tablespace_name, extent_id, file_id, block_id, blocks
from dba_extents
where owner = USER
and segment_name = 'MY_SEGMENT'
order by extent_id;

-- 블록 사이즈 확인
-- 오라클은 기본적으로 8KB 크기의 블록을 사용
select value from v$parameter where name = 'db_block_size';
