from libvis.modules import BaseModule
import random
random.seed(123)
import networkx as nx
from networkx.readwrite import json_graph
import json


def graph_to_d3json(graph):
    """
    Converts a graph to json node-link file
    res: string
            converted json string
    """
    data = json_graph.node_link_data(graph)
    res = json.dumps(data)
    return res

class Graph(BaseModule):
    name="graph"
    def __init__(self, graph):
        super().__init__(graph=graph)

    def vis_get(self, key):
        value = self[key]
        value = graph_to_d3json(value)
        return value

    @classmethod
    def test_object(cls):
        n = cls(None)
        n.graph = nx.barabasi_albert_graph(23, 1)
        n.graph.node[0]['color']='red'
        n.graph.node[1]['color']='blue'
        n.graph.node[1]['name']='node 1'
        n.graph.edges[1,0]['stroke-width']='5'
        n.graph.edges[1,0]['stroke']='black'

        return n
