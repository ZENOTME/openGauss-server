------------------------------
--- test various query write
--- 1. const param eval
------------------------------
create schema query_rewrite;
set current_schema = query_rewrite;

create table t1 (a int, b int);
create table t2 (a int, b int);

create index i on t2(a);

--test const param eval: const param should be removed and convert to semi-join
explain (costs off) select * from t1 where ( '1' = '0' or ( '1' = '1' and exists ( select /*+ rows(t2 #9999999) */ a from t2 where t1.a=t2.a)));

--test const param eval: const param should be removed and convert to seqscan
explain (costs off) select * from t1 where ( '1' = '1' or ( '1' = '1' and exists ( select /*+ rows(t2 #9999999) */ a from t2 where t1.a=t2.a)));

--test const param eval: const param should be removed and convert to semi-join
explain (costs off) select * from t1 where ( '1' = '1' and ( '1' = '1' and exists ( select /*+ rows(t2 #9999999) */ a from t2 where t1.a=t2.a)));

--test const param eval: const param should be removed and convert to seqscan
explain (costs off) select * from t1 where ( '1' = '0' and ( '1' = '1' and exists ( select /*+ rows(t2 #9999999) */ a from t2 where t1.a=t2.a)));

--test const param eval: const param should be removed and convert to seqscan
explain (costs off) select * from t1 where ( '1' = '0' or ( '1' = '1' or exists ( select /*+ rows(t2 #9999999) */ a from t2 where t1.a=t2.a)));

--test const param eval: const param should be removed and convert to seqscan
explain (costs off) select * from t1 where ( '1' = '1' or ( '1' = '1' or exists ( select /*+ rows(t2 #9999999) */ a from t2 where t1.a=t2.a)));

--test const param eval: const param should be removed and convert to semi-join
explain (costs off) select * from t1 where ( '1' = '1' and ( '1' = '0' or exists ( select /*+ rows(t2 #9999999) */ a from t2 where t1.a=t2.a)));

--test const param eval: const param should be removed and convert to seqscan
explain (costs off) select * from t1 where ( '1' = '0' and ( '1' = '1' or exists ( select /*+ rows(t2 #9999999) */ a from t2 where t1.a=t2.a)));

-- test for optimized join rel as sub-query
set qrw_inlist2join_optmode = 'rule_base';

CREATE TABLE t3 (
slot integer NOT NULL,
cid bigint NOT NULL,
name character varying NOT NULL
)
WITH (orientation=row);

insert into t3 (slot, cid, name) values(generate_series(1, 10), generate_series(1, 10), 'records.storage.state');

analyze t3;

explain (costs off) 
select 
  * 
from 
  t3 
where 
  slot = '5' 
  and (name) in (
    select 
      name 
    from 
      t3 
    where 
      slot = '5' 
      and cid in (
        5, 1000, 1001, 1002, 1003, 1004, 1005, 
        1006, 1007, 2000, 4000, 10781986, 10880002
      ) 
    limit 
      50
  );

select 
  * 
from 
  t3 
where 
  slot = '5' 
  and (name) in (
    select 
      name 
    from 
      t3 
    where 
      slot = '5' 
      and cid in (
        5, 1000, 1001, 1002, 1003, 1004, 1005, 
        1006, 1007, 2000, 4000, 10781986, 10880002
      ) 
    limit 
      50
  );

explain (costs off) 
select 
  * 
from 
  t3 
where 
  cid in (
    select 
      cid 
    from 
      t3 
    where 
      slot = '5' 
      and (name) in (
        select 
          name 
        from 
          t3 
        where 
          slot = '5' 
          and cid in (
            5, 1000, 1001, 1002, 1003, 1004, 1005, 
            1006, 1007, 2000, 4000, 10781986, 10880002
          ) 
        limit 
          50
      )
  );

select 
  * 
from 
  t3 
where 
  cid in (
    select 
      cid 
    from 
      t3 
    where 
      slot = '5' 
      and (name) in (
        select 
          name 
        from 
          t3 
        where 
          slot = '5' 
          and cid in (
            5, 1000, 1001, 1002, 1003, 1004, 1005, 
            1006, 1007, 2000, 4000, 10781986, 10880002
          ) 
        limit 
          50
      )
  );
-- fix bug: ERROR: no relation entry for relid 1
-- Scenario:1
set enable_hashjoin=on;
set enable_material=off;
set enable_mergejoin=off;
set enable_nestloop=off;
create table k1(id int,id1 int);
create table k2(id int,id1 int);
create table k3(id int,id1 int);
explain (costs off)select   m.*,k3.id from (select tz.* from (select k1.id from k1 WHERE exists (select k2.id from k2 where k2.id = k1.id and k2.id1 in (1,2,3,4,5,6,7,8,9,10,11))) tz limit 10) m left join k3 on m.id = k3.id;
-- Scenario:2
create table customer(c_birth_month int);
 select 
      1
    from 
      customer t1 ,
      (with tmp2 as ( select 1 as c_birth_month,   2 as c_birth_day   from   now()) 
       select c_birth_month,  c_birth_day from ( select 1 as c_birth_month,   2 as c_birth_day   from   now()) tmp2 ) t2  
    where 
      t1.c_birth_month = t2.c_birth_day  and exists (select  1 ) ;
-- Scenario:3
select 1 from  customer where c_birth_month not in (with  tmp1 as (select 1  from now()) select * from tmp1);

drop schema query_rewrite cascade;
reset current_schema;
