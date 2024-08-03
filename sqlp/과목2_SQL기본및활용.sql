

CREATE TABLE ��� (
    ���ID INT PRIMARY KEY,
    �μ�ID INT,
    ���� DECIMAL(10, 2)
);

INSERT INTO ��� (���ID, �μ�ID, ����) VALUES (1, 1, 2500);
INSERT INTO ��� (���ID, �μ�ID, ����) VALUES (2, 1, 3000);
INSERT INTO ��� (���ID, �μ�ID, ����) VALUES (3, 2, 4500);
INSERT INTO ��� (���ID, �μ�ID, ����) VALUES (4, 2, 3000);
INSERT INTO ��� (���ID, �μ�ID, ����) VALUES (5, 2, 2500);
INSERT INTO ��� (���ID, �μ�ID, ����) VALUES (6, 3, 4500);
INSERT INTO ��� (���ID, �μ�ID, ����) VALUES (7, 3, 3000);

-- 77�� 
select ���id, col2, col3 
from (select ���id, ����
    ,row_number() over(partition by �μ�id order by ���� desc) as col1
    ,sum(����) over(partition by �μ�id order by ���id rows between unbounded preceding and current row) as col2
    ,max(����) over(order by ���� desc rows current row) as col3 
        from ���)
where col1 = 2
order by 1;

-- 001:350, 002:550, 003:350, 004:700, 005:700 