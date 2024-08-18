select owner, synonym_name, table_owner, table_name
from all_synonyms
where synonym_name = 'PLAN_TABLE';

select * from table(dbms_xplan.display_cursor(sql_id=>'3q3spntmmqznn', format=>'ALLSTATS LAST'));

select * from table(dbms_xplan.display(null, null, 'advanced'));
