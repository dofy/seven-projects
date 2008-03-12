// ActionScript file
import cn.com.ultrapower.topology.event.TopoEvent;
import cn.com.ultrapower.topology.view.DDefault;
import cn.com.ultrapower.topology.view.DRandom;
import cn.com.ultrapower.topology.view.DTree;
import cn.com.ultrapower.topology.view.Graph;
import cn.com.ultrapower.topology.view.Node;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.system.System;

import mx.containers.Form;
import mx.controls.Alert;
import mx.core.DragSource;
import mx.core.IUIComponent;
import mx.events.DragEvent;
import mx.events.DynamicEvent;
import mx.events.ItemClickEvent;
import mx.managers.CursorManager;
import mx.managers.DragManager;

import tools.GlobalPanel;
import tools.LineOptionsPanel;
import tools.NodeOptionPanel;

private var topoEvt:TopoEvent = TopoEvent.getEvent();

private var _curPanel:Form;
private var globalPanel:Form = new GlobalPanel();
private var nodePanel:Form = new NodeOptionPanel();
private var linePanel:Form = new LineOptionsPanel();

private var nodesData:XML = 
    <r>
        <node id="" title="workgroup" type="workgroup" describe="" />
        <node id="" title="server" type="server" describe="" />
        <node id="" title="client" type="client" describe="" />
        <node id="" title="computer" type="computer" describe="" />
        <node id="" title="power" type="power" describe="" />
        <node id="" title="hardware" type="hardware" describe="" />
        <node id="" title="storage" type="storage" describe="" />
        <node id="" title="printer" type="printer" describe="" />
        <node id="" title="audio" type="audio" describe="" />
        <node id="" title="video" type="video" describe="" />
        <node id="" title="wifi" type="wifi" describe="" />
    </r>

///////////////////////////////////////
// public functions
///////////////////////////////////////

public function setRootNode(rn:Node):void
{
    graphTest.rootNode = rn.Name;
}

public function getData():XML
{
    return graphTest.XMLData;
}

public function setData(data:XML):void
{
    graphTest.display(data);
}

///////////////////////////////////////
// private functions
///////////////////////////////////////

private function initApp():void
{
    addNodes();
    changePanel("Global Panel", globalPanel);
    topoEvt.addEventListener(TopoEvent.NODE_CLICK, clickNodeHandler);
    topoEvt.addEventListener(TopoEvent.LINE_CLICK, clickLineHandler);
    topoEvt.addEventListener(TopoEvent.GRAPH_CLICK, selectNoneHandler);
    topoEvt.addEventListener(TopoEvent.GRAPH_CHANGED, graphChangeHandler);
    topoEvt.addEventListener(TopoEvent.NODE_DOUBLE_CLICK, nodeDoubleClickHandler);
    
    graphTest.addEventListener(KeyboardEvent.KEY_UP, deleteHandler);
    graphTest.addEventListener(DragEvent.DRAG_ENTER, dragEnterHandler);
    graphTest.addEventListener(DragEvent.DRAG_DROP, dragDropHandler);
}

private function addNodes():void
{
    var tmpNode:Node;
    var arrNodes:XMLList = nodesData.node;
    for (var i:uint = 0; i < arrNodes.length(); i++)
    {
        tmpNode = new Node(i, arrNodes[i]);
        tmpNode.addEventListener(MouseEvent.MOUSE_DOWN, nodeDragHandler);
        nodesBar.addChild(tmpNode);
    }
}

private function changePanel(title:String, cat:Form):Form{
    optionsPanel.title = title;
    if (_curPanel != cat)
    {
        _curPanel = cat;
        try
        {
            optionsPanel.removeChildAt(0);
        }
        catch (e:Error)
        {
            // nothing
        }
        return optionsPanel.addChild(cat) as Form;
    }
    else
    {
        return _curPanel;
    }
}

/////////////////////////////////
// handlers
/////////////////////////////////

private function nodeDragHandler(event:MouseEvent):void
{
    var dragNode:Node = event.currentTarget as Node;
    var dragSrc:DragSource = new DragSource();
    dragSrc.addData(dragNode.Data.copy(), "data");
    dragSrc.addData(dragNode.mouseX, "x");
    dragSrc.addData(dragNode.mouseY, "y");
    DragManager.doDrag(dragNode, dragSrc, event);
}

private function dragEnterHandler(event:DragEvent):void
{
    if (event.dragSource.formats.indexOf('data') !== -1)
    {
        DragManager.acceptDragDrop(event.currentTarget as IUIComponent);
    } 
}

private function dragDropHandler(event:DragEvent):void
{
    var nodeData:XML = event.dragSource.dataForFormat('data') as XML;
    var xOffset:Number = event.dragSource.dataForFormat('x') as Number;
    var yOffset:Number = event.dragSource.dataForFormat('y') as Number;
    var tmpGraph:Graph = event.currentTarget as Graph;
    tmpGraph.addNode(tmpGraph.mouseX - xOffset, tmpGraph.mouseY - yOffset, nodeData);
}

private function commandButtonHandler(evt:ItemClickEvent):void
{
     switch (evt.item.data)
    {
        case 'save':
        {
            var saveEvent:DynamicEvent = new DynamicEvent("saveTopo");
            saveEvent.data = graphTest.XMLData;
            dispatchEvent(saveEvent);
            break;
        }
        case 'edit':
        {
            graphTest.editable = true;
            CursorManager.removeAllCursors();
            break;
        }
        case 'move':
        {
            graphTest.editable = false;
            graphTest.cursorManager.setCursor(evt.item.icon);
            break;
        }
        case 'center':
        {
            graphTest.center();
            break;
        }
        case 'centerObject':
        {
            graphTest.center(topoEvt.curNode);
            break;
        }
        case 'd_random':
        {
            graphTest.draw(new DRandom());
            break;
        }
        case 'd_tree':
        {
            graphTest.draw(new DTree());
            break;
        }
        case 'd_default':
        {
            graphTest.draw(new DDefault());
            break;
        }
        case 'xml':
        {
            System.setClipboard(graphTest.XMLData);
            Alert.show("xml 数据已复制到剪贴板.", "提醒");
            break;
        }
    }
}

private function clickNodeHandler(evt:Event):void
{
    trace("Click Node:", topoEvt.curNode, topoEvt.curNode.Name);
    var tmpForm:NodeOptionPanel = changePanel("Node Option", nodePanel) as NodeOptionPanel;
    tmpForm.setObject(graphTest, topoEvt.curNode);
}

private function clickLineHandler(evt:Event):void
{
    trace("Click Line:", topoEvt.curLine);
    var tmpForm:LineOptionsPanel = changePanel("Line Option", linePanel) as LineOptionsPanel;
    tmpForm.setObject(graphTest, topoEvt.curLine);
}

private function selectNoneHandler(evt:Event):void
{
    trace("Nothing is selected!");
    var tmpForm:GlobalPanel = changePanel("Global Option", globalPanel) as GlobalPanel;
    tmpForm.setObject(graphTest);
}

private function graphChangeHandler(evt:Event):void
{
    trace ("Graph changed~~~");
    var tmpForm:GlobalPanel = changePanel("Global Option", globalPanel) as GlobalPanel;
    tmpForm.setObject(graphTest);
}

private function nodeDoubleClickHandler(evt:Event):void
{
    var dbClickEvent:DynamicEvent = new DynamicEvent("dbClick");
    dbClickEvent.node = evt.currentTarget.curNode;
    dispatchEvent(dbClickEvent);
    var tmpForm:GlobalPanel = changePanel("Global Option", globalPanel) as GlobalPanel;
    tmpForm.setObject(graphTest);
}

private function deleteHandler(event:KeyboardEvent):void
{
    event.keyCode == 46 && graphTest.deleteSelectedObjects();
}
