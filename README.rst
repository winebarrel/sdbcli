sdbcli
======

Description
-----------

sdbcli is an interactive command-line client of Amazon SimpleDB.

Source Code
-----------

https://bitbucket.org/winebarrel/sdbcli

Install
-------
::

  shell> gem install sdbcli
  shell> sdbcli -h
  Usage: sdbcli [options]
      -k, --access-key=ACCESS_KEY
      -s, --secret-key=SECRET_KEY
      -r, --region=REGION
      -e, --eval=COMMAND
      -f, --format=YAML_OR_JSON
      -c, --consistent
      -t, --timeout=SECOND
          --import=DOMAIN,FILE
          --import-replace=DOMAIN,FILE
          --export=DOMAIN,FILE
          --retry=NUM
          --retry-interval=SECOND
          --require=FILE_LIST
          --iteratable
  shell> export AWS_ACCESS_KEY_ID='...'
  shell> export AWS_SECRET_ACCESS_KEY='...'
  shell> export SDB_ENDPOINT='sdb.ap-northeast-1.amazonaws.com' # or SDB_REGION=ap-northeast-1
  shell> sdbcli -e 'show domains'
  ---
  - test
  - test-2
  shell> sdbcli -f json -e 'show domains'
  [
    "test",
    "test-2"
  ]
  shell> sdbcli # show prompt

Example
-------
::

  ap-northeast-1> .help
  # Explanatory notes of a query
  
  SHOW DOMAINS
    displays a domain list
  
  SHOW REGIONS
    displays a region list
  
  CREATE domain domain_name
    creates a domain
  
  DROP DOMAIN domain_name
    deletes a domain
  
  GET [attr_list] FROM domain_name WHERE itemName = '...'
    gets the attribute of an item
  
  INSERT INTO domain_name (itemName, attr1, ...) VALUES ('name1', 'val1', ...), ('name2', 'val2', ...), ...
    creates an item
  
  UPDATE domain_name {SET|ADD} attr1 = 'val1', ... WHERE itemName = '...'
  UPDATE domain_name {SET|ADD} attr1 = 'val1', ... [WHERE expression] [sort_instructions] [LIMIT limit]
    updates an item
  
  DELETE [attr1, ...] FROM domain_name WHERE itemName = '...'
  DELETE [attr1, ...] FROM domain_name WHERE [WHERE expression] [sort_instructions] [LIMIT limit]
    deletes the attribute of an item or an item
  
  SELECT output_list FROM domain_name [WHERE expression] [sort_instructions] [LIMIT limit] [ | ruby script ]
    queries using the SELECT statement
    see http://docs.aws.amazon.com/AmazonSimpleDB/latest/DeveloperGuide/UsingSelect.html
  
  N[EXT]
    displays a continuation of a result
    (NEXT statement is published after SELECT statement)
  
  C[URRENT]
    displays a present result
    (CURRENT statement is published after SELECT statement)
  
  P[REV]
    displays a previous result
    (PREV statement is published after SELECT statement)
  
  PAGE [number]
    displays a present page number or displays a result of the specified page
    (PAGE statement is published after SELECT statement)
  
  DESC[RIBE] domain_name
    displays information about the domain
  
  USE region_or_endpoint
    changes an endpoint
  
  
  # List of commands
  
  .help                      displays this message
  .quit | .exit              exits sdbcli
  .format     (yaml|json)?   displays a format or changes it
  .consistent (true|false)?  displays ConsistentRead parameter or changes it
  .iteratable (true|false)?  displays iteratable option or changes it
                             all results are displayed if true
  .timeout    SECOND         displays a timeout second or changes it
  .version                   displays a version
  
  ap-northeast-1> select * from test;
  ---
  - [itemname1, {attr1: val1, attr2: val2}]
  - [itemname2, {attr1: val1, attr2: val2}]
  # 2 rows in set

  ap-northeast-1> select count(*) from `test-2`;
  ---
  - [Domain, {Count: "100"}]
  # 1 row in set

Attribute and domain names may appear without quotes if they contain only letters, numbers, underscores (_), 
or dollar symbols ($) and do not start with a number.
You must quote all other attribute and domain names with the backtick (`).
see http://docs.amazonwebservices.com/AmazonSimpleDB/latest/DeveloperGuide/QuotingRulesSelect.html
::

  ap-northeast-1> select * from test \G
  ---
  - - itemname1
    - attr1: val1
      attr2: val2
    - itemname2
    - attr1: val1
      attr2: val2
  # 2 rows in set
  
  shell> echo 'select * from test' | sdbcli
  ---
  - [itemname1, {attr1: val1, attr2: val2}]
  - [itemname2, {attr1: val1, attr2: val2}]

Import/Export
-------------
::

  shell> sdbcli -f json  --export=employees,employees.json
  // 2500 rows was outputted...
  // 5000 rows was outputted...
  // 7500 rows was outputted...
  ...
  shell> sdbcli -f json --import=employees,employees.json
  // 2500 rows was inputted...
  // 5000 rows was inputted...
  // 7500 rows was inputted...

If '-' is specified as a file name, the input/output of data will become a standard input/output.

Pipe to ruby
------------
::

  ap-northeast-1> select * from employees limit 3;
  ---
  - ["100000", {first_name: Hiroyasu, hire_date: "1991-07-02", birth_date: "1956-01-11", last_name: Emden}]
  - ["100001", {first_name: Jasminko, hire_date: "1994-12-25", birth_date: "1953-02-07", last_name: Antonakopoulos}]
  - ["100002", {first_name: Claudi, hire_date: "1988-02-20", birth_date: "1957-03-04", last_name: Kolinko}]
  # 3 rows in set
  
  ap-northeast-1> select * from employees limit 3 | hire_date.max;
  --- "1994-12-25"
  
  ap-northeast-1> select * from employees limit 3 | hire_date.to_i;
  ---
  - 1991
  - 1994
  - 1988
  # 3 rows in set
  
  ap-northeast-1> select * from employees limit 3 | hire_date.to_f.avg;
  --- 1991.0
  
  ap-northeast-1> select * from employees | select {|i| i.first_name =~ /^C/ }.map {|i| Time.parse(i.birth_date).mon }.inject({}) {|r, i| r[i] ||= 0 \; r[i] += 1\; r }.sort_by {|k,v| k };
  ---
  - [1, 1]
  - [3, 1]
  - [5, 1]
  - [8, 2]
  - [10, 1]
  - [12, 3]
  # 6 rows in set

'sum' method and 'avg' method are added to Array class.

Pipe to shell
-------------
::

  ap-northeast-1> select * from employees limit 3 ! awk '{print $1}' ;
  --- |
  ["100000",
  ["100001",
  ["100002",

Save to file
------------
::

  ap-northeast-1> select * from employees limit 3 | _('data.txt');
  ap-northeast-1> ! cat data.txt;
  --- |
  [["100000", {"first_name"=>"Hiroyasu", "hire_date"=>"1991-07-02", "birth_date"=>"1956-01-11", "last_name"=>"Emden"}], ["100001", {"first_name"=>"Jasminko", "hire_date"=>"1994-12-25", "birth_date"=>"1953-02-07", "last_name"=>"Antonakopoulos"}], ["100002", {"first_name"=>"Claudi", "hire_date"=>"1988-02-20", "birth_date"=>"1957-03-04", "last_name"=>"Kolinko"}]]
  
  ap-northeast-1> select * from employees limit 3 | hire_date.to_i.__('data.txt');
  ap-northeast-1> ! cat data.txt;
  --- |
  [["100000", {"first_name"=>"Hiroyasu", "hire_date"=>"1991-07-02", "birth_date"=>"1956-01-11", "last_name"=>"Emden"}], ["100001", {"first_name"=>"Jasminko", "hire_date"=>"1994-12-25", "birth_date"=>"1953-02-07", "last_name"=>"Antonakopoulos"}], ["100002", {"first_name"=>"Claudi", "hire_date"=>"1988-02-20", "birth_date"=>"1957-03-04", "last_name"=>"Kolinko"}]]
  [1991, 1994, 1988]

Group By (Aggregate)
--------------------
::

  ap-northeast-1> select * from access_logs limit 30;
  --- 
  - [20130205/host1, {host: host1, response_time: "298.37"}]
  - [20130205/host2, {host: host2, response_time: "294.65"}]
  - [20130205/host3, {host: host3, response_time: "293.42"}]
  - [20130205/host4, {host: host4, response_time: "294.08"}]
  - [20130205/host5, {host: host5, response_time: "294.3"}]
  ...
  # 30 rows in set
  
  ap-northeast-1> select * from access_logs limit 30 | group_by(:host) {|i| i.response_time.to_f.avg };
  --- 
  host1: 303.6425
  host2: 301.8875
  host3: 300.9525
  host4: 302.1675
  host5: 301.62

Exec ruby or shell command
--------------------------
::

  ap-northeast-1> | (1 + 1).to_f;
  --- 2.0
  
  ap-northeast-1> ! ls;
  --- |
  README
  bin
  lib
  sdbcli.gemspec