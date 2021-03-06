# Daggregator: Aggregation for Directed Acyclic Graphs

Daggregator is a free-standing server for analyzing large sets of connected
data over a REST API.  Daggregator provides a set of aggregation functions
(sum and count currently) for arbitrary key/value pairs.

To use daggregator, simply tell it what objects you want to investigate and
how they're connected; each object can include any number of named numeric
values and any number of connections to other targets.

Once you've defined the objects (nodes) in your graph aggregate data can 
be queried for any node, for example the sum of the key `foo` for any upstream
nodes.


## Concepts

Daggregator uses two objects, `node` and `flow`.  Nodes represent
arbitrary sets of data. The data in nodes is aggregated on other 
nodes by defining flows between them.  Each node stores a set 
of key/value pairs.

Flows are defined between a source and target node.  Data defined on
'upstream' nodes is aggregated on 'downstream' nodes ('upstream'
refers to source nodes)


## CRUD API

Daggregator provides a RESTful API with the following endpoints:

### GET `/node/<id>`

Returns the data defined for node `<id>` the list of source
nodes identifiers and the list of target node identifiers in the 
following form:

``` javascript
// GET /node/foo
{
  'node': {
    'identifier': 'foo',
    'data': {
      'numeric_foo': 4,
      'numeric_bar': 5,
      'text_foo': 'four',
      'text_bar': 'five'
    },
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

### GET `/node/<id>/[sum|count]/<key1>+<key2>`

Returns an aggregate value of `<key>` using one of the functions
`sum` or `count`. `count` returns the number
of source nodes for which `<key>` is defined. Results for multiple keys
can be returnd by concatenating with `+` (ie `/node/foo/sum/bar+baz`).

JSON returned in the following format:

``` javascript
// GET /node/foo/sum/bar+baz
{
  'node': {
    'identifier': 'foo',
    'aggregates': {
      'numeric_bar': { 'SUM': 3.42 },
      'numeric_baz': { 'SUM': 3.24 },
      'text_foo': { 'SUM': null}
    }
  }
}
``` 

`sum` returns `null` if the key isn't defined for any sources (text 
strings are considered null).  `count` returns 0 if the key isn't 
defined.

### GET `/node/<id>/distribution/<key1>+<key2>`

Returns a hash of the number of occurrances of each unique for of `key` in 
the node's upstream graph.  For numeric keys, consider using the `bin_count`
function.

``` javascript
// GET /node/foo/distribution/bar+baz
{
  'node': {
    'identifier': 'foo',
    'aggregates': {
      'bar': {
        'lorem': 10,
        'ipsum': 2,
        'dolor': 35
      },
      'baz': {
        'ipsum': 20,
        'dolor': 2
      }
    }
  }
}
```


### GET `/node/<id>/bin_count/<key1>+<key2>?bins=10&`

Divides the range of `key` into `bins` equal-sized regions and
returns the number of upstream nodes whose value lies within each
region.  Expects numeric values.

``` javascript
// GET /node/foo/distribution/bar+baz?bins=3
{
  'node': {
    'identifier': 'foo',
    'aggregates': {
      'bar': {
        '[0,5)': 2,
        '[5,10)': 5,
        '[10,15]': 3
      },
      'baz': {
        '[20,21.5)': 34,
        '[21.5,23)': 3,
        '[23,24.5]': 23
      }
    }
  }
}
```

If no values are defined or all the values are the same, returns
null (ie `'bar': null`).


### PUT `/node/<id>`

Creates/updates a node. Nodes are created with a user-defined `<id>` 
value, which should be unique across all nodes.  The id parameter will be
converted to a string, and can contain any character excluding `:`, `/`.

Expects JSON in the body defining a (possibly empty) 
set of data key/values in the following form:

``` javascript
// POST /node/foo
{
  'node': {
    'data': {
      'numeric_foo': 1,
      'numeric_bar': 2,
      'text_foo': 'one'
    }
  }
}
```

If the node already exists, the attributes specified will be updated, and all
other attributes will be left unmodified.  


### PUT `/node/<id>/key/<key>/5.3` 

Sets a key's value. If the key is already defined, it updates the value,
otherwise it adds the key. 

Returns 404 if the node doesn't exist.

### PUT `/node/<source id>/flow_to/<target1 id>+<target2 id>` 

Creates a flow from node `<source id>` to nodes `<target1 id>` and
`<target2 id>`.  

Implicitly creates the nodes if they don't exist.


### PUT `/node/<target id>/flow_from/<source id>+<source id>` 

Opposite of `flow_to`


### DELETE `/node/<id>/key/<key>`

Removes a node's key.  The responsd will be 200 regardless of the existence of
the key.  

Returns 404 if they node doesn't exist.

### DELETE `/node/<source id>/flow_to/<target id>`

Removes the flow from node `<source id>` to node `<target id>`.  Returns 200 regardless
of the existence of the flow.

Returns 404 if either of the nodes don't exist.

### DELETE `/node/<id>`

Removes a node.  Implicitly removes all flows through the node. 

Returns 404 if the node doesn't exist.


## Query API (Very preliminary, not implemented)

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

## Install

Clone the repo, `bundle install`.  You'll need to install neo4j, and there's a rake task for it:

    rake neo4j:install[community,1.8.M01]
    rake neo4j:start

If you're using Heroku you can install the addon with

    heroku addons:add neo4j --neo4j-version 1.8.M01
