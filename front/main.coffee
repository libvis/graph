import React from 'react'
import * as Gv from './graph.coffee'
import './style.css'
import DOM from 'react-dom-factories'
L = DOM

export default class Presenter extends React.Component
  constructor:(props)->
    super(props)
    console.log 'constructor', props

  componentDidMount:()->
    console.log 'componentDidMount', @props

    @sim = Gv.start
        data:{links:[], nodes:[]}
        style:
          nodeColor: 'blue'
          lineColor: 'red'
        center:
          x: @container.offsetWidth/2
          y: @container.offsetHeight/2
        

  componentDidUpdate:()=>
    console.log 'componentDidUpdate', @props

    graph = JSON.parse @props.data?.graph
    Gv.update data: graph, sim:@sim, style:nodeColor:'blue'




  shouldComponentUpdate:()->
    console.log 'shouldComponentUpdate'
    true

  render: ()->
    L.div
      ref: (el)=> @container = el
      className:'module-container'
      id:'graph-c'
      L.svg
        id:'graph-vis'
        className:'graph-vis'
        width:'100%'
        height:'100%'
        preserveAspectRatio='none'


