# Apache AGE Docker Quick Start

Apache AGE a PostgreSQL extension that provides graph database functionality. AGE is an acronym for A Graph Extension. This is an image to build the [AgensGraph-Extension](https://github.com/bitnine-oss/AgensGraph-Extension) on the official PostgreSQL 11 Docker image. It can be run by executing to following from the command line:


## Running the container 

To run psql from inside the container:
```
docker run -it -e POSTGRES_PASSWORD=mypassword sorrell/agensgraph-extension
```

To forward psql to a port outside your container (your local psql):
```
docker run -it -e POSTGRES_PASSWORD=mypassword -p 5432 sorrell/agensgraph-extension
```


## Loading AGE

Connect to your containerized Postgres instance:
```sql
psql postgres postgres
``` 
Create the extension:
```sql
CREATE EXTENSION age;
```

Then run the following commands each time you connect:
```sql
LOAD 'age';
SET search_path = ag_catalog, "$user", public;
```

## Using AGE

First you will need to create a graph:
```sql
SELECT create_graph('test_graph');
```

To execute Cypher queries, you will need to wrap them in the following syntax:
```sql
SELECT * from cypher('test_graph', $$ CypherQuery $$) as (a agtype);
```

For example, if we wanted to create a graph with 4 nodes, we could do something as shown below:

```sql
SELECT * from cypher('test_graph', $$
  CREATE (a:Part {part_num: '123'}), 
         (b:Part {part_num: '345'}), 
         (c:Part {part_num: '456'}), 
         (d:Part {part_num: '789'})
$$) as (a agtype);
```

RESULT:
```
 a
---
(0 rows)
```

Then we could query the graph with the following:

```sql
SELECT * from cypher('test_graph', $$ MATCH (a) RETURN a $$) as (a agtype);
```

RESULT:
```
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
SELECT * from cypher('test_graph', $$
  MATCH (a:Part {part_num: '123'}), (b:Part {part_num: '345'})
  CREATE (a)-[u:used_by { quantity: 1 }]->(b)
$$) as (a agtype);
```

RESULT:
```
 a
---
(0 rows)

```


Next we can return the path we just created (results have been formatted for readability):

```sql
SELECT * from cypher('test_graph', $$
  MATCH p=(a)-[]-(b)
  RETURN p
$$) as (a agtype);
```

RESULT:
```javascript
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
```