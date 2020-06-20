import React from 'react'
import * as Gv from './graph.coffee'
import './style.css'
import DOM from 'react-dom-factories'
L = DOM

export default class Presenter extends React.Component
  constructor:(props)->
    super(props)
    console.log 'constructor', props
    @svg_id = 'A' + Math.random().toString().substring(7)

  componentDidMount:()->
    console.log 'componentDidMount', @props

    @sim = Gv.start
        svg_id: '#'+@svg_id
        data:{links:[], nodes:[]}
        style:
          nodeColor: 'blue'
          lineColor: 'red'
        center:
          x: @container.offsetWidth/2
          y: @container.offsetHeight/2
        

  componentDidUpdate:()=>
    console.log 'componentDidUpdate', @props

    if @props.data?.graph
      graph = JSON.parse @props.data.graph
      Gv.update
        svg_id: '#'+@svg_id
        data: graph
        sim:@sim,
        style:nodeColor:'blue'

  shouldComponentUpdate:()->
    console.log 'shouldComponentUpdate'
    true

  render: ()->
    L.div
      ref: (el)=> @container = el
      className:'module-container'
      id:'graph-c'
      if not @props.data?.graph
        L.div '', 'No data. Required `graph` property'
      L.svg
        id: @svg_id
        className:'graph-vis'
        width:'100%'
        height:'100%'
        preserveAspectRatio='none'
