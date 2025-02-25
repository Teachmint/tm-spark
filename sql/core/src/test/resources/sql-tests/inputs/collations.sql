-- test cases for collation support

-- Create a test table with data
create table t1(utf8_binary string collate utf8_binary, utf8_binary_lcase string collate utf8_binary_lcase) using parquet;
insert into t1 values('aaa', 'aaa');
insert into t1 values('AAA', 'AAA');
insert into t1 values('bbb', 'bbb');
insert into t1 values('BBB', 'BBB');

-- describe
describe table t1;

-- group by and count utf8_binary
select count(*) from t1 group by utf8_binary;

-- group by and count utf8_binary_lcase
select count(*) from t1 group by utf8_binary_lcase;

-- filter equal utf8_binary
select * from t1 where utf8_binary = 'aaa';

-- filter equal utf8_binary_lcase
select * from t1 where utf8_binary_lcase = 'aaa' collate utf8_binary_lcase;

-- filter less then utf8_binary
select * from t1 where utf8_binary < 'bbb';

-- filter less then utf8_binary_lcase
select * from t1 where utf8_binary_lcase < 'bbb' collate utf8_binary_lcase;

-- inner join
select l.utf8_binary, r.utf8_binary_lcase from t1 l join t1 r on l.utf8_binary_lcase = r.utf8_binary_lcase;

-- create second table for anti-join
create table t2(utf8_binary string collate utf8_binary, utf8_binary_lcase string collate utf8_binary_lcase) using parquet;
insert into t2 values('aaa', 'aaa');
insert into t2 values('bbb', 'bbb');

-- anti-join on lcase
select * from t1 anti join t2 on t1.utf8_binary_lcase = t2.utf8_binary_lcase;

drop table t2;
drop table t1;

-- set operations
select col1 collate utf8_binary_lcase from values ('aaa'), ('AAA'), ('bbb'), ('BBB'), ('zzz'), ('ZZZ') except select col1 collate utf8_binary_lcase from values ('aaa'), ('bbb');
select col1 collate utf8_binary_lcase from values ('aaa'), ('AAA'), ('bbb'), ('BBB'), ('zzz'), ('ZZZ') except all select col1 collate utf8_binary_lcase from values ('aaa'), ('bbb');
select col1 collate utf8_binary_lcase from values ('aaa'), ('AAA'), ('bbb'), ('BBB'), ('zzz'), ('ZZZ') union select col1 collate utf8_binary_lcase from values ('aaa'), ('bbb');
select col1 collate utf8_binary_lcase from values ('aaa'), ('AAA'), ('bbb'), ('BBB'), ('zzz'), ('ZZZ') union all select col1 collate utf8_binary_lcase from values ('aaa'), ('bbb');
select col1 collate utf8_binary_lcase from values ('aaa'), ('bbb'), ('BBB'), ('zzz'), ('ZZZ') intersect select col1 collate utf8_binary_lcase from values ('aaa'), ('bbb');

-- create table with struct field
create table t1 (c1 struct<utf8_binary: string collate utf8_binary, utf8_binary_lcase: string collate utf8_binary_lcase>) USING PARQUET;

insert into t1 values (named_struct('utf8_binary', 'aaa', 'utf8_binary_lcase', 'aaa'));
insert into t1 values (named_struct('utf8_binary', 'AAA', 'utf8_binary_lcase', 'AAA'));

-- aggregate against nested field utf8_binary
select count(*) from t1 group by c1.utf8_binary;

-- aggregate against nested field utf8_binary_lcase
select count(*) from t1 group by c1.utf8_binary_lcase;

drop table t1;

-- array function tests
select array_contains(ARRAY('aaa' collate utf8_binary_lcase),'AAA' collate utf8_binary_lcase);
select array_position(ARRAY('aaa' collate utf8_binary_lcase, 'bbb' collate utf8_binary_lcase),'BBB' collate utf8_binary_lcase);

-- utility
select nullif('aaa' COLLATE utf8_binary_lcase, 'AAA' COLLATE utf8_binary_lcase);
select least('aaa' COLLATE utf8_binary_lcase, 'AAA' collate utf8_binary_lcase, 'a' collate utf8_binary_lcase);
