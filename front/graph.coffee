import * as d3 from 'd3'
import * as actions from './actions.coffee'

import DOM from 'react-dom-factories'
L = DOM
hslColor= (d,i)->d.color||'hsl('+(50+d.id)+',60%,50%)'

add_nodes=(root,nodes,style)->
  nods = root.selectAll("g")
  console.log 'root', root, nods
  ng = nods.data(nodes)
    .enter().append("g")
    .attr('class','node')
    .attr("id",(d)->  d.id)
    .merge(nods)
  console.log 'ng',ng, nodes, nods

  c = ng.append('circle')
    .attr('r', (d,i)->style.radius)
    .attr 'fill', hslColor
  l = ng.append('text')
    .text((d, i) -> d.id)
    .text((d, i) -> d.name)
    .attr('x', (d, i) -> 5)
    .attr('y', (d, i) -> 0)
    .attr('font-family', 'Sans Serif')
    .attr('fill','#333')
    .attr('font-size', (d, i) -> '0.6em')
  ng
add_links=(root,links,style)->
  link = root.selectAll("line")
    .data(links ,(d)->d.id)
  link = link.enter().append('line')
      .attr("class", "link")
      .attr("stroke", (d) -> d.stroke or style.color or 'black')
      .attr("stroke-width", (d)-> d['stroke-width'] or 1)
      .attr("fill", "none")
  link

remove_nodes=(nodes,fun)->
  trm = nodes.filter(fun)
  console.log 'removed',trm
  trm.remove()

export updNodes=(svg, data)->
  console.log 'updating nodes',data
  new_ids = data.map (n)->n.id

  #svg = d3.select('#graph-vis')
  nodes = svg.selectAll('g.nodes .node')
  old_data = nodes.data()
  old_ids = old_data.map (n)->n.id
  console.log 'oldids newids',old_ids,new_ids
  add_ids = new_ids.filter (i)-> i not in old_ids
  new_nodes = data.filter (n)-> n.id not in old_ids
  del_ids = old_ids.filter (i)-> i not in new_ids

  console.log 'add del nodes', add_ids,del_ids
  remove_nodes svg.selectAll('g.nodes .node'), (d)-> d.id in del_ids
  # vis is container for everyitng
  node = add_nodes svg.select('g.nodes'), data,
    color:'teal'
    radius:6
    
  console.log 'newnodes', node
  node

export updLinks=(svg, data)->
  console.log 'updlinks', data
  console.log 'updlinks', data
  new_ids = data.map (n)->n.id

  links = svg.selectAll('g.links .link')
  old_data = links.data()
  old_ids = old_data.map (n)->n.id
  console.log 'oldids newidslink',old_ids,new_ids
  add_ids = new_ids.filter (i)-> i not in old_ids
  new_links = data.filter (l)-> l.id not in old_ids
  del_ids = old_ids.filter (i)-> i not in new_ids

  console.log 'add del links', add_ids,del_ids
  link = svg.selectAll('g.links .link')
  remove_nodes link, (d)-> d.id in del_ids

  link = add_links svg.selectAll('g.links'), data,
    color:'#e1a3b8'
  console.log 'added links',link.data()
    
  link

export update=({svg_id, data,style,onClick,sim,onMouseOver})->
  #data = JSON.parse(JSON.stringify(data))
  {links,nodes}=data
  svg = d3.select(svg_id)
  # vis is container for everyitng
  links = links.map (n)-> if n.id then n else {n..., id:n.source+'.'+n.target}

  vis = svg.select("g")

  #d3.select('#graph-vis').call(zoom)
  circleWidth = 5
  sim.stop()
  console.log 'updating with',data
  sim_nodes = sim.nodes()
  sim_nodes_dict = {}
  for n in sim_nodes
    sim_nodes_dict[n.id] = n
  console.log 'sim_nodes_dict', sim_nodes_dict

  nodes = nodes.map (n)-> if sim_nodes_dict[n.id] then {sim_nodes_dict[n.id]..., n...} else n

  sim_links = sim.nodes()
  sim_links_dict = {}
  for n in sim_links
    sim_links_dict[n.id] = n
  links = links.map (n)-> if sim_links_dict[n.id] then {sim_links_dict[n.id]..., n...} else n

  node = updNodes svg, nodes
  node = svg.selectAll('g.nodes .node')
  console.log 'all nodes', node
  link = updLinks svg, links
  link = svg.selectAll('g.links .link')
  console.log 'link', link
  node = svg.selectAll('g.nodes .node')
  drag_handler = d3.drag()
    .on("start", actions.drag_start sim)
    .on("drag", actions.drag_drag)
    .on("end", actions.drag_end sim)
  drag_handler(node)
  node.on 'click',(node)->onClick(node.id)
  highlight=(id)->
    node.filter (d)-> d.id==id
      .select 'circle'
      .attr 'fill','red'
  highlightoff=(id)->
    node.filter (d)-> d.id==id
      .select 'circle'
      .attr 'fill',hslColor
  node.on "mouseover",(node)->
    highlight(node.id)
    onMouseOver(node.id)
  node.on "mouseout",(node)->
    highlightoff(node.id)
  console.log 'New Data:',node.data()

  sim.nodes node.data()
  sim.force("link").links(link.data()).strength(1).distance(9)

  sim.on( 'tick',actions.tick node,link)
  f=()->sim.alpha(0.01).restart()
  setTimeout f, 200

export start=({svg_id, data,style,onClick,onMouseOver, center})->
  if not center
    center = x:250, y: 150
  data = JSON.parse(JSON.stringify(data))
  {links,nodes}=data
  svg = d3.select(svg_id)
  svg.selectAll("*").remove()
  # vis is container for everyitng
  g = svg.append("g")
  console.log 'nodes', nodes, JSON.stringify nodes

  #d3.select('#graph-vis').call(zoom)
  circleWidth = 5
  sim = d3.forceSimulation().alphaTarget(0.1)
  sim.nodes data.nodes

  sim.force("charge", d3.forceManyBody().strength(-200))
    .force("link", d3.forceLink().id (d)->d.id)
    .force("center", d3.forceCenter(center.x,center.y))
  sim.force("link").links(data.links).strength(1).distance(9)

  link= g.append('g').attr('class','links')
  link = add_links link,data.links,color:style.lineColor

  node = g.append('g').attr("class", "nodes")
  node =add_nodes node,data.nodes,
    color:style.nodeColor
    radius:6

  #add drag capabilities  
  drag_handler = d3.drag()
    .on("start", actions.drag_start sim)
    .on("drag", actions.drag_drag)
    .on("end", actions.drag_end sim)
  drag_handler(node)

  node.on 'click',(node)->onClick(node.id)
  highlight=(id)->
    node.filter (d)-> d.id==id
      .select 'circle'
      .attr 'fill','red'
  highlightoff=(id)->
    node.filter (d)-> d.id==id
      .select 'circle'
      .attr 'fill',hslColor
  node.on "mouseover",(node)->
    highlight(node.id)
    onMouseOver(node.id)
  node.on "mouseout",(node)->
    highlightoff(node.id)
  console.log sim,svg

  sim.on( 'tick',actions.tick node,link)
  #add zoom capabilities 
  zoom_handler = d3.zoom().on("zoom",actions.zoom g)
  zoom_handler svg
  sim

export Ui = ({w,h}) ->
  L.div
    className:'module-container'
    id:'graph-c'
    L.svg
      id:'graph-vis'
      className:'graph-vis'
      width:w
      height:h
      preserveAspectRatio='none'

