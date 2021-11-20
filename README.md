# Docker Apache AGE for Postgres


This is an image to build the [Apache AGE](https://github.com/apache/incubator-age/) on the official PostgreSQL 11 Docker image. It can be run by executing 

## Running the container

It can be run by executing:

`docker run -it -e POSTGRES_PASSWORD=mypassword -p {HostPort}:5432 sorrell/apache-age`

In the above command, replace `{HostPort}` with a port you'd like to forward to, or remove the `-p` flag altogether if you want to run `psql` from inside the container.

## Loading AGE

Connect to your containerized Postgres instance, for example:

```sh
psql -h 0.0.0.0 -p {HostPort} -U postgres
```

Then run the following commands:

```sql
CREATE EXTENSION age;
LOAD 'age';
SET search_path = ag_catalog, "$user", public;
```

## Using AGE

First you will need to create a graph:

```sql
SELECT create_graph('my_graph_name');
```

To execute Cypher queries, you will need to wrap them in the following syntax:

```sql
SELECT * from cypher('my_graph_name', $$
  CypherQuery
$$) as (a agtype);
```

For example, if we wanted to create a graph with 4 nodes, we could do something as shown below:

```sql
SELECT * from cypher('my_graph_name', $$
  CREATE (a:Part {part_num: '123'}), 
         (b:Part {part_num: '345'}), 
         (c:Part {part_num: '456'}), 
         (d:Part {part_num: '789'})
$$) as (a agtype);

--- RESULTS
 a
---
(0 rows)
```

Then we could query the graph with the following:

```sql
SELECT * from cypher('my_graph_name', $$
  MATCH (a)
  RETURN a
$$) as (a agtype);

--- RESULTS
                                          a
-------------------------------------------------------------------------------------
 {"id": 844424930131969, "label": "Part", "properties": {"part_num": "123"}}::vertex
 {"id": 844424930131970, "label": "Part", "properties": {"part_num": "345"}}::vertex
 {"id": 844424930131971, "label": "Part", "properties": {"part_num": "456"}}::vertex
 {"id": 844424930131972, "label": "Part", "properties": {"part_num": "789"}}::vertex
(4 rows)
```

Next, we could create a relationship between a couple of nodes:

```sql
SELECT * from cypher('my_graph_name', $$
  MATCH (a:Part {part_num: '123'}), (b:Part {part_num: '345'})
  CREATE (a)-[u:used_by { quantity: 1 }]->(b)
$$) as (a agtype);

--- RESULTS
 a
---
(0 rows)
```

Next we can return the path we just created (results have been formatted for readability):

```sql
SELECT * from cypher('my_graph_name', $$
  MATCH p=(a)-[]-(b)
  RETURN p
$$) as (a agtype);
```
```javascript
// RESULTS
// ROW 1
[
   {
      "id":844424930131969,
      "label":"Part",
      "properties":{
         "part_num":"123"
      }
   }::"vertex",
   {
      "id":1125899906842625,
      "label":"used_by",
      "end_id":844424930131970,
      "start_id":844424930131969,
      "properties":{
         "quantity":1
      }
   }::"edge",
   {
      "id":844424930131970,
      "label":"Part",
      "properties":{
         "part_num":"345"
      }
   }::"vertex"
]::"path"
// ROW 2
[
   {
      "id":844424930131970,
      "label":"Part",
      "properties":{
         "part_num":"345"
      }
   }::"vertex",
   {
      "id":1125899906842625,
      "label":"used_by",
      "end_id":844424930131970,
      "start_id":844424930131969,
      "properties":{
         "quantity":1
      }
   }::"edge",
   {
      "id":844424930131969,
      "label":"Part",
      "properties":{
         "part_num":"123"
      }
   }::"vertex"
]::"path"
(2 rows)
```
