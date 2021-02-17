DROP TABLE IF EXISTS Users, tasks, project;
DROP TABLE IF EXISTS  tasks;
--------------------------1
CREATE table Users(
uname varchar(30),
ulogin varchar(30),
uemail varchar(30),
udepartment varchar(30) CHECK (udepartment in ('Production', 'Support', 'bookkeeping', 'Administration')),
primary key (ulogin)
);

CREATE table project(
pname varchar(30),
pcommit text,
pstart DATE ,
pend DATE,
primary key (pname)
);

CREATE table tasks(
ttitle varchar(30),
tpriority int,
tcommit text,
tstate varchar(30),
tspent int,
trealtime int,
tproject varchar(30),
tcreator varchar(30),
tstart DATE,
tresponsible varchar(30),
ID int,
primary key (ttitle),
FOREIGN KEY (tproject) REFERENCES project (pname),
FOREIGN KEY (tcreator) REFERENCES Users (ulogin),
FOREIGN KEY (tresponsible) REFERENCES Users (ulogin)
);



------------------------------------2
INSERT INTO Users(uname, ulogin, uemail, udepartment)
VALUES ('Касаткин Артем', 'a.kasatkin', 'a.kasatkin@ya.ru', 'Administration'),
       ('Петрова София', 's.petrova', 's.petrova@ya.ru', 'bookkeeping'),
       ('Дроздов Федр', 'f.drozdov', 'f.drozdov@ya.ru', 'Support'),
       ('Иванова Василина', 'v.ivanova', 'v.ivanova@ya.ru', 'bookkeeping'),
       ('Беркут Алексей', 'a.berkut', 'a.berkut@ya.ru', 'Support'),
       ('Белова Вера', 'v.belova', 'v.belova@ya.ru', 'Support'),
       ('Макенрой Алексей', 'a.makenroy', 'a.makenroy@ya.ru', 'Production'),
       ('Сидоров Иван', 'i.sidorov','i.sidorov@ya.ru','Administration');

INSERT INTO project(pname, pstart, pend)
VALUES ('РТК', '2016/01/31', NULL),
       ('СС.Контент', '2015/02/23', '2016/12/31'),
       ('Демо-Сибирь', '2015/05/11', '2015/01/31'),
       ('МВД-Онлайн', '2015/05/22', '2016/01/31'),
       ('Поддержка', '2016/06/07', NULL);

INSERT INTO tasks(ID,tproject, ttitle, tpriority, tstate, tcreator, tresponsible, tstart, tspent, trealtime)
VALUES (1,'Поддержка', 'Task1', 20, 'new', 'a.berkut', 'i.sidorov', NULL, 10, 15),
		(2,'Поддержка', 'Task2', 100, 'new', 'a.makenroy', 'i.sidorov', NULL, 12, 12),
       (3,'Демо-Сибирь', 'Task3', 200, 'new', 's.petrova', 's.petrova', NULL, 52, 22),
       (4,'РТК', 'Task4', 300, 'new', 'a.makenroy', 's.petrova', NULL, 12, 12),
       (5,'Демо-Сибирь', 'Task5', 10, 'new', 'v.ivanova', 'a.makenroy', NULL, 1, 100),
       (6,'МВД-Онлайн', 'Task6', 400, 'new', 'a.berkut', 'f.drozdov', NULL, 12, 22),
       (7,'РТК', 'Task7', 500, 'new', 'a.makenroy', 'v.belova', NULL, 22, 35),
       (8,'Демо-Сибирь', 'Task8', 100, 'new', 'a.makenroy', 's.petrova', NULL, 94, 12),
       (9,'МВД-Онлайн', 'Task9', 900, 'new', 'v.ivanova', 'f.drozdov', NULL, 88, 24),
       (10,'Демо-Сибирь', 'Task10', 30, 'new', 'a.makenroy', NULL, '2015/1/1', 99, 2),
       (11,'РТК', 'Task11', 1000, 'new', 'v.ivanova', 'a.berkut', '2016/4/1', NULL, NULL),
       (12,'Демо-Сибирь', 'Task12', 50, 'new', 'a.makenroy', NULL, '2015/8/1', 66, 32),
       (13,'СС.Контент', 'Task13', 1, 'new', 'a.makenroy', 'a.kasatkin', '2016/1/3', 99, 2),
       (14,'СС.Контент', 'Task14', 20, 'new', 'a.makenroy', 'a.kasatkin', '2016/1/1', 22, 3),
       (15,'СС.Контент', 'Task15', 20, 'new', 'a.makenroy', 'a.kasatkin', '2016/1/2', NULL, NULL);
      
      
------------------------------------------------------
--------------------------------1-3
SELECT *
FROM tasks;

select ID,tproject, ttitle, tpriority, tstate, tcreator, tresponsible, tstart, tspent, trealtime 
from tasks;

SELECT uname,udepartment
FROM Users;

SELECT ulogin,uemail
FROM Users;


SELECT *
FROM tasks
where tpriority > 50;


select distinct tresponsible
FROM tasks
where tresponsible is not null ;


SELECT distinct tcreator
FROM tasks
UNION
SELECT distinct tresponsible
FROM tasks;

SELECT  ttitle
FROM tasks
WHERE tcreator != 's.petrova'
  AND (tresponsible IN ('v.ivanova', 'i.sidorov', 'a.berkut'));
 
 ---------------------------------------------------4
SELECT * 
FROM tasks
WHERE tresponsible LIKE '%kasatkin%'
AND tstart BETWEEN '2016/1/1%' AND '2016/1/3%';
---------------------------------------------5
SELECT t.ID, t.ttitle, u.udepartment
FROM tasks t,
    Users u
WHERE t.tresponsible LIKE '%petrov%'
  AND t.tcreator = u.ulogin
  AND u.udepartment IN ('Production', 'bookkeeping', 'Administration');
---------------------------------------------6
SELECT *
FROM tasks
WHERE tresponsible IS NULL;

UPDATE tasks
SET tresponsible = 's.petrova'
WHERE tresponsible IS NULL;

-------------------------------------7
DROP TABLE IF exists  tasks2;
CREATE TABLE tasks2 AS
SELECT *
FROM tasks;

------------------------------------8
SELECT *
FROM users
WHERE uname not like '%a'
	and ulogin like '%p%'
	and ulogin like '%r%';










 
 
