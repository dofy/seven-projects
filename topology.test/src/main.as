// ActionScript file
import cn.com.ultrapower.topology.event.TopoEvent;
import cn.com.ultrapower.topology.view.DDefault;
import cn.com.ultrapower.topology.view.DRandom;
import cn.com.ultrapower.topology.view.DTree;
import cn.com.ultrapower.topology.view.Node;

import flash.system.System;

import mx.containers.Form;
import mx.controls.Alert;
import mx.events.ItemClickEvent;
import mx.events.SliderEvent;
import mx.managers.CursorManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

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
        <node id="node1" title="workgroup" type="workgroup" describe="" />
        <node id="node2" title="server" type="server" describe="" />
        <node id="node3" title="client" type="client" describe="" />
        <node id="node4" title="computer" type="computer" describe="" />
        <node id="node5" title="power" type="power" describe="" />
        <node id="node6" title="hardware" type="hardware" describe="" />
    </r>

private function initApp():void
{
    myData.send();
    changePanel("Global Panel", globalPanel);
    topoEvt.addEventListener(TopoEvent.NODE_CLICK, clickNodeHandler);
    topoEvt.addEventListener(TopoEvent.LINE_CLICK, clickLineHandler);
    topoEvt.addEventListener(TopoEvent.GRAPH_CLICK, selectNoneHandler);
    topoEvt.addEventListener(TopoEvent.GRAPH_CHANGED, graphChangeHandler);
    topoEvt.addEventListener(TopoEvent.NODE_DOUBLE_CLICK, nodeDoubleClickHandler);
    graphTest.addEventListener(KeyboardEvent.KEY_UP, deleteHandler);
}

private function xmlResultHandler(event:ResultEvent):void
{
    graphTest.display(event.result as XML);
    //graphTest.rootNode = "node1";
}

public function setRootNode(rn:Node):void
{
    graphTest.rootNode = rn.Name;
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

private function commandButtonHandler(evt:ItemClickEvent):void
{
     switch (evt.item.data)
    {
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
        case 'test':
        {
            // load new xml file
            myData.url = "data/testData.bak.xml";
            myData.send();
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

private function xmlLoadFaildHandler(evt:FaultEvent):void
{
    trace("加载失败");
}

private function clickNodeHandler(evt:Event):void
{
    trace("Click Node:", topoEvt.curNode, topoEvt.curNode.Name);
    var tmpForm:NodeOptionPanel = changePanel("Node Option", nodePanel) as NodeOptionPanel;
    tmpForm.setNode(topoEvt.curNode);
}

private function clickLineHandler(evt:Event):void
{
    trace("Click Line:", topoEvt.curLine);
    var tmpForm:LineOptionsPanel = changePanel("Line Option", linePanel) as LineOptionsPanel;
    tmpForm.setLine(topoEvt.curLine);
}

private function selectNoneHandler(evt:Event):void
{
    trace("Nothing is selected!");
    changePanel("Global Option", globalPanel);
}

private function graphChangeHandler(evt:Event):void
{
    trace ("Graph changed~~~");
    var tmpForm:GlobalPanel = changePanel("Global Option", globalPanel) as GlobalPanel;
    tmpForm.setGraph();
}

private function nodeDoubleClickHandler(evt:Event):void
{
    myData.url = "data/testData.xml";
    myData.send();
    changePanel("Global Option", globalPanel);
}

private function deleteHandler(event:KeyboardEvent):void
{
    event.keyCode == 46 && graphTest.deleteSelectedObjects();
}
    
private function setGraphWidthScale(event:SliderEvent):void
{
    graphTest.widthScale = event.value / 100;
}

private function setGraphHeightScale(event:SliderEvent):void
{
    graphTest.heightScale = event.value / 100;
}

private function setGraphScale(event:ItemClickEvent):void
{
    var tmpValue:Number = event.index == 0? -1: 1;
    graphTest.scaleBy(0.05 * tmpValue, 0.05 * tmpValue);
}