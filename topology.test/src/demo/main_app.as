// ActionScript file
import cn.com.ultrapower.topology.assets.Icons;
import cn.com.ultrapower.topology.event.TopoEvent;
import cn.com.ultrapower.topology.view.DDefault;
import cn.com.ultrapower.topology.view.DRandom;
import cn.com.ultrapower.topology.view.DTree;
import cn.com.ultrapower.topology.view.Graph;
import cn.com.ultrapower.topology.view.Line;
import cn.com.ultrapower.topology.view.Node;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.system.System;

import mx.containers.Form;
import mx.controls.Alert;
import mx.core.DragSource;
import mx.core.IUIComponent;
import mx.events.CloseEvent;
import mx.events.DragEvent;
import mx.events.ItemClickEvent;
import mx.managers.DragManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

import tools.GlobalPanel;
import tools.LineOptionsPanel;
import tools.NodeOptionPanel;

private var _curPanel:Form;
private var globalPanel:Form = new GlobalPanel();
private var nodePanel:Form = new NodeOptionPanel();
private var linePanel:Form = new LineOptionsPanel();

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
    var tmpPanel:GlobalPanel = changePanel("全局属性", globalPanel) as GlobalPanel;
    tmpPanel.setObject(graphTest);
//    graphTest.display(new XML());
    
    graphTest.addEventListener(TopoEvent.NODE_CLICK, clickNodeHandler);
    graphTest.addEventListener(TopoEvent.LINE_CLICK, clickLineHandler);
    graphTest.addEventListener(TopoEvent.GRAPH_CLICK, selectNoneHandler);
    graphTest.addEventListener(TopoEvent.GRAPH_CHANGED, graphChangeHandler);
    graphTest.addEventListener(TopoEvent.NODE_DOUBLE_CLICK, showChildMapHandler);

    graphTest.addEventListener(DragEvent.DRAG_ENTER, dragEnterHandler);
    graphTest.addEventListener(DragEvent.DRAG_DROP, dragDropHandler);
    
    graphTest.addEventListener(KeyboardEvent.KEY_UP, deleteHandler);
    
}

private function addNodes():void
{
    var tmpNode:Node;
    var nodeXML:XML = <node />;
    var arrNodes:Array = new Icons().getIconList();
    for (var i:uint = 0; i < arrNodes.length; i++)
    {
        nodeXML.@title = nodeXML.@type = arrNodes[i];
        tmpNode = new Node(i, nodeXML.copy());
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
    var topoXML:XML;
    var mapId:String;
    var mapData:String;
    switch (evt.item.data)
    {
        case 'new':
        {
            graphTest.isChanged
                ? Alert.show("拓扑图已被修改, 确定放弃修改吗?",
                           "确认",
                           Alert.YES | Alert.NO,
                           null,
                           function(event:CloseEvent):void
                           {
                                Alert.YES == event.detail &&
                                graphTest.display(new XML()); 
                           })
                : graphTest.display(new XML());
            break;
        }
        case 'save':
        {	
        	//错误提示
        	
		    topoXML = graphTest.XMLData;
		    mapId = topoXML.id;
		    mapData = topoXML.toString();
		    /*
        	topoService.addEventListener(FaultEvent.FAULT,gotError);
            topoService.editTopology.addEventListener(ResultEvent.RESULT,saveTopoData);
            topoService.editTopology(mapId,mapData);
            listdata.init();
        	*/
            break;
        }
        case 'del':
        {
            Alert.show("确定要删除该拓扑图吗?",
                       "确认",
                       Alert.YES | Alert.NO,
                       null,
                       function(event:CloseEvent):void
                       {
                            if (Alert.YES == event.detail)
                            {
							    topoXML = graphTest.XMLData;
							    mapId = topoXML.id;
							    /*
                            	topoService.removeTopology.addEventListener(ResultEvent.RESULT,delTopoData);
					            topoService.removeTopology(mapId);
					            listdata.init();
					            */
                            } 
                       });
            break;
        }
        case 'center':
        {
            graphTest.center();
            break;
        }
        case 'centerObject':
        {
            graphTest.center(graphTest.currentNode);
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
        case 'copyXML':
        {
            System.setClipboard(graphTest.XMLData);
            Alert.show("XML 数据已复制到剪贴板", "提醒");
            break;
        }
    }
}
/**
*错误提示
**/
private function gotError( fault:FaultEvent ):void
{
	Alert.show( "Server reported an error - " + fault.fault.faultString );
} 

private function saveTopoData(result:ResultEvent):void{
	trace(result.result);
}

private function delTopoData(result:ResultEvent):void
{
	trace(result.result);
    // 描述一个新的 空拓扑图
    graphTest.display(new XML());
}
private function getTopoData(result:ResultEvent):void{
	trace(result.result);
	var xmlStr:XML = new XML(result.result);
	setData(xmlStr);

}
private function clickNodeHandler(evt:Event):void
{
    trace("Click Node:", evt.target);
    var tmpForm:NodeOptionPanel = changePanel("节点属性", nodePanel) as NodeOptionPanel;
    tmpForm.setObject(graphTest, evt.target as Node);
}

private function clickLineHandler(evt:Event):void
{
    trace("Click Line:", evt.target);
    var tmpForm:LineOptionsPanel = changePanel("连线属性", linePanel) as LineOptionsPanel;
    tmpForm.setObject(graphTest, evt.target as Line);
}

private function selectNoneHandler(evt:Event):void
{
    trace("Nothing is selected!");
    var tmpForm:GlobalPanel = changePanel("全局属性", globalPanel) as GlobalPanel;
    tmpForm.setObject(graphTest);
}

private function graphChangeHandler(evt:Event):void
{
    trace ("Graph changed~~~");
    var tmpForm:GlobalPanel = changePanel("全局属性", globalPanel) as GlobalPanel;
    tmpForm.setObject(graphTest);
}

private function showChildMapHandler(evt:TopoEvent):void
{
	var topoId:String = evt.target.ChildMapId;
	if (topoId != '')
	{
		//getTopo(topoId);
	}
}

private function deleteHandler(event:KeyboardEvent):void
{
    event.keyCode == 46 && graphTest.deleteSelectedObjects();
}

//////////////////////////////////
// service functions
//////////////////////////////////
/*
private function getTopo(id:String):void{
	topoService.getTopologyStr.addEventListener(ResultEvent.RESULT,getTopoFun);
	topoService.getTopologyStr(id);			
}
private function getTopoFun(result:ResultEvent):void{
	var xmlStr:XML = new XML(result.result);
	setData(xmlStr);
}
*/