# daggregator

Aggregation for directed acyclic graph structures

## Introduction

Daggregator uses two objects, `node` and `flow`.  Nodes represent
arbitrary sets of data and aggregated data. The data in nodes is aggregated 
on other nodes by defining flows between them.

Each node stores a set of key/value pairs; values must be numeric.  
Daggregator uses dot syntax to namespace keys, so to store a hash 
like `{foo: {bar: 5, baz: 10}}` you would define the following keys:

```
foo.bar = 5
foo.baz = 10
```

Flows are defined between a source and target node. Flows are created
by defining a target node for a given source node.  Data defined on
source nodes is aggregated on target nodes (as well as targets of targets,
etc). 


## CRUD API

Daggregator provides a RESTful API with the following endpoints:

### GET `/node/<id>`

Returns the data defined for node `<id>` a list of properties which
can be aggregated (data defined on source nodes), the list of source
nodes identifiers and the list of target node identifiers in the 
following form:

``` javascript
// GET /node/foo
{
  'node': {
    'identifier': 'foo',
    'data': {
      'foo': 4,
      'bar': 5
    },
    'aggregates': [
      'baz',
      'qux'
    ],
    'targets': [
      'identifier_1',
      'identifier_2'
    ],
    'sources': [
      'identifier_3',
      'identifier_4'
    ]
  }
}
```

Returns 404 if the node isn't defined.

### GET `/node/<id>/aggregate/<key>/[SUM|AVG|MAX|MIN|COUNT]`

Returns an aggregate value of `<key>` using one of the functions
`SUM`, `AVG`, `MAX`, `MIN` or `COUNT`. `COUNT` returns the number
of source nodes for which `<key>` is defined. Multiple results
can be returnd by concatenating (ie `/node/foo/aggregate/bar/SUM+AVG`).

JSON returned in the following format:

``` javascript
// GET /node/foo/aggregate/bar/SUM+AVG
{
  'node': {
    'identifier': 'foo',
    'aggregates': {
      'bar': {
        'SUM': 3.42,
        'AVG': 1.1
      }
    }
  }
}
``` 

Returns 404 if the key isn't defined for any of the node's sources,
unless the function is `COUNT`, in which case 0 is returned.

### PUT `/node/<id>`

Creates/updates a node. Nodes are created with a user-defined `<id>` 
value, which must be unique across all nodes.  The id parameter will be
converted to a string, and can contain any character excluding `:`, `/`.

Expects JSON in the body defining a (possibly empty) 
set of data key/values in the following form:

``` javascript
// POST /node/foo
{
  'node': {
    'data': {
      'foo': 1,
      'bar[]': [3,4,5]
    }
  }
}
```

If the node already exists, the attributes specified will be updated, and all
other attributes will be left unmodified.  

Returns 500 if a new key conflicts with a key defined on one of the node's sources.

### PUT `/node/<id>/key/<key>/5.3` 

Sets a key's value. If the key is already defined, it updates the value,
otherwise it adds the key. 

Returns 500 if the key is defined on one of the node's sources.

Returns 400 if the node doesn't exist.

### PUT `/node/<source id>/flow_to/<target id>` 

Creates a flow from node `<source id>` to node `<target id>`.  

Returns 200 if the flow already exists or was successfully created.

Returns 404 if either of the nodes don't exist.

Returns 500 if the flow would create a loop.


### DELETE `/node/<id>/key/<key>`

Removes a node's key.  The responsd will be 200 regardless of the existence of
the key.  

Returns 400 if they node doesn't exist.

### DELETE `/node/<source id>/flow_to/<target id>`

Removes the flow from node `<source id>` to node `<target id>`.  Returns 200 regardless
of the existence of the flow.

Returns 404 if either of the nodes don't exist.

### DELETE `/node/<id>`

Removes a node.  Implicitly removes all flows through the node. 

Returns 400 if the node doesn't exist.


## Query API

Nodes can be queried at the by GET-ting `/node` with a list of parameters.  All nodes
accept the following parameters:

* `limit=<n>` the maximum number of records to return
* `offset=<n>` the offset to start at

* `order=<key>:asc` order by key ascending
* `order=<key>:desc` order by key descending
* `order=[<key>:asc,<otherkey>:desc]` order by key in ascending order, and by otherkey in descending order if key has the same value

* `sources=<id1>,<id2>` limit to nodes with flows originating from any member of the set (recursive via flows)
* `sources=<id1>:<key1>,<id2>:<key2>` same as above, but restricts to flows with operations based on key1 or key2
* `sources=<id1>:<key1>:<agr1>,<id2>:-<key2>:<agr2>` same as above, but restricts to flows with operations from key1 -> agr1 etc

* `targets=<id1>,<id2>` limit to nodes with flows terminating in any member of the set (recursive via flows)
* `targets=<id1>:<key1>,<id2>:<key2>` same as above, but restricts to flows with operations targeting key1 or key2
* `targets=<id1>:<key1>:<agr1>,<id2>:-<key2>:<agr2>` same as above, but restricts to flows with operations from key1 -> agr1 etc

In addition, queries can specify constraints on the value of keys:

* `<key>=<n>` nodes for which the value of `<key>` equals `<n>`
* `<key>.ne=<n>` nodes for which the value of `<key>` is not equal to `<n>`
* `<key>.gt=<n>` nodes for which the value of `<key>` is greater than `<n>`
* `<key>.lt=<n>` nodes for which the value of `<key>` is less than `<n>`

These can be combined with the keywords `target` and `source` to reestrict the results 
to nodes whose sources or targets meet certain criteria:

* `targets:<key>=<n>` nodes with flows terminating in targets for which the value of `<key>` is `<n>`
* `sources:<key>.ne=<n>` nodes with flows originating from sources for which the value of `<key>` is `<n>`

When specifying constraints on related nodes, the constraints are treated as AND operations,
so for example `targets:foo=1&sources:bar=5` would return nodes with flows terminating in
targets with `foo=1` _and_ flows originating in sources with `bar=5`.

