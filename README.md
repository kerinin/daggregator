# daggregator

Aggregation for directed acyclic graph structures

* auto-gen TOC:
{:toc}

## Introduction

Daggregator uses two objects, `node` and `flow`.  Nodes represent
arbitrary sets of data and aggregated data. The data in nodes is aggregated 
on other nodes by defining flows between them.

Each node stores a set of key/value pairs.  
Daggregator uses dot syntax to namespace keys, so to store a hash 
like `{foo: {bar: 5, baz: 10}}` you would define the following keys:

```
foo.bar = 5
foo.baz = 10
```

Keys can be either `data` or `aggregates`.  Data keys can be set explicitly,
for instance `foo = 5` (if `foo` is a data key).  Aggregate keys can only be
incremented or decremented by flows, for instance `bar += 1` (if `bar` is an 
aggregate key).

Data keys must be numeric, but aggregate keys may be either
numeric or numeric sets. Declare numeric sets by appending `[]` to the end 
of their keys, for example:

```
# given foo = 1
foo += 1 # => 2

# given bar[] = {1}
bar[] += 1 # => {1,2}
```

Flows define both the source of aggregated values and a set of operations
used to aggregate data (ie increment/decrement, add/remove from set).

Flows define a `source` and a `target` node, as well as a set of operations.  
Operations map a key on the source to a key on the target.
The source key can be either a data or an aggregate key, but
the targe key must be an aggregate.

Nodes define a set of convenience functions over their aggregated data.
For instance, if a node aggregates `foo.bar` and `foo.baz`, you can 
request a histogram or the entropy of `foo`. Likewise if a node
aggregates a set named `baz[]` you can request the mean, median,
etc of the set.


## CRUD API

Daggregator provides a RESTful API with the following endpoints:

### GET `/node/<id>`

Returns the node whose id is `<id>`.

### GET `/node/<id>/<key>`

Returns the value of a data/aggregate key on node. Returns 404 if the
key isn't defined for the node.

### POST `/node` and PUT `/node/<id>`

Creates/updates a node.  Expects JSON in the body defining a (possibly empty) 
set of data key/values in the following form:

``` javascript
{
  'foo': 1,
  'bar[]': [3,4,5]
}
```

If the node already exists, the attributes specified will be updated, and all
other attributes will be left unmodified.  Returns 500 if a new key conflicts
with an existing aggregate key

### PUT `/node/<id>/<data key>/5.3` 

Sets a data key's value.  Returns 500 if the key is an aggregate.  The key will
be created if it doesn't exist already, otherwise the value will be set to the
passed value. Returns 400 if the node doesn't exist.

### DELETE `/node/<id>/<data key>`

Removes a node's data key.  Implicitly increments/decrements the key's value 
from target nodes.  The responsd will be 200 regardless of the existence of
the key.  Returns 400 if they node doesn't exist. Returns 500 if the key
is an aggregate key.

### DELETE `/node/<id>`

Removes a node.  Implicitly increments/decrements target nodes and removes all 
flows out of the node. Returns 400 if the node doesn't exist.

### GET `/flow/<id>` 

Returns a flow.

### POST `/flow` and PUT `/flow/<id>` 

Creates/updates a flow.  Expects JSON in the body defining a set of operations
in the following form:

``` javascript
{
  'source_id' : <id>,
  'target_id' : <id>,
  'operations' : {
    '':     'count'       // increment/decrement 'count' on target by 1 when source is created/deleted
    '-':    'count'       // same as before, but switched
    'foo':  'agr_pos'     // increment 'agr_pos' on the target with the value of 'foo' on the source
    '-foo': 'agr_neg'     // decrement 'agr_neg' on the target with the value of 'foo'
    'foo':  'set_1[]'     // add the value of 'foo' on the source to the set 'set_1[]' on the target
    '-foo': 'set_2[]'     // remove the value of 'foo' on the source to the set 'set_2[]' on the target
  }
}
```

No error will be raised if a request is made to remove a value from a set which doesn't contain the
value.  If a set contains multiple instances of a value and a request is made to remove 
the value, only one instance of the value will be removed: `{1,2,2,3} - 2 => {1,2,3}`.
Likewise, if a request is made to add a value to a set which already contains the value, another
instance of the value will be added: `{1,2,3} + 2 => {1,2,2,3}`

Returns 500 if any of the operations create an aggregation loop.

Implicitly increments/decrements target nodes.

### PUT `/flow/<id>/<source key>:<target key>`

Adds an operation using the syntax defined above.  Returns 200 even if the operation already
exists. Returns 400 if the flow doesn't exist. Implicitly increments/decrements target nodes.

Returns 500 if the operation creates an aggregation loop.

### DELETE `/flow/<id>/<source key>:<target key>`

Removes an operation. Implicitly increments/decrements the target node's value and removes
any aggregate keys on the target for which the target has no source operations.
Returns 200 even if the operation doesn't exist. Returns 400 if the flow doesn't exist.

### DELETE `/flow/<id>`

Removes a flow.  Implicitly increments/decrements target nodes and removes any
aggregate keys for which the target has no source operations.
Returns 400 if the flow doesn't exist.


## Query API

Nodes can be queried at the by GET-ting `/node` with a list of parameters.  All nodes
accept the following parameters:

* `limit=<n>` the maximum number of records to return
* `offset=<n>` the offset to start at

* `order=<key>:asc` order by key ascending
* `order=<key>:desc` order by key descending
* `order=[<key>:asc,<otherkey>:desc]` order by key in ascending order, and by otherkey in descending order if key has the same value

* `sources=<id1>,<id2>` limit to nodes with flows originating from any member of the set
* `sources=<id1>:<key1>,<id2>:<key2>` same as above, but restricts to flows with operations based on key1 or key2
* `sources=<id1>:<key1>:<agr1>,<id2>:-<key2>:<agr2>` same as above, but restricts to flows with operations from key1 -> agr1 etc

* `targets=<id1>,<id2>` limit to nodes with flows terminating in any member of the set
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

