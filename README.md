
<div align="center">
    <img width="312px" alt="libvis logo" src="http://libvis.dev/libvis-sm.png"/>
</div>

This is a graph [libvis](http://libvis.dev) module.

![](demo.png)

# Installation

```
libvis-mods download gh:libvis/graph
cd graph
libvis-mods install
```

# Usage 

```python
from libvis import Vis
from libvis.modules import Graph

vis = Vis()
vis.start()

vis.vars.test = Graph.test_object()
```

The state of `vis.vars.test` will be visualised live at `localhost:7000/`. 
