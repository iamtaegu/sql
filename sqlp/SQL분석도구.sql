select owner, synonym_name, table_owner, table_name
from all_synonyms
where synonym_name = 'PLAN_TABLE';