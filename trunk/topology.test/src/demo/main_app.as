// ActionScript file
import cn.com.ultrapower.topology.assets.Icons;
import cn.com.ultrapower.topology.event.TopoEvent;
import cn.com.ultrapower.topology.view.DDefault;
import cn.com.ultrapower.topology.view.DRandom;
import cn.com.ultrapower.topology.view.DTree;
import cn.com.ultrapower.topology.view.Graph;
import cn.com.ultrapower.topology.view.Line;
import cn.com.ultrapower.topology.view.Node;

import flash.events.ContextMenuEvent;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.system.System;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;
import flash.utils.getQualifiedClassName;

import mx.containers.ControlBar;
import mx.containers.Form;
import mx.containers.TitleWindow;
import mx.containers.VDividedBox;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.TextArea;
import mx.core.DragSource;
import mx.core.IUIComponent;
import mx.core.UIComponent;
import mx.events.CloseEvent;
import mx.events.DividerEvent;
import mx.events.DragEvent;
import mx.events.ItemClickEvent;
import mx.managers.DragManager;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

import tools.GlobalPanel;
import tools.LineOptionsPanel;
import tools.NodeOptionPanel;

private var _curPanel:Form;
private var globalPanel:Form = new GlobalPanel();
private var nodePanel:Form = new NodeOptionPanel();
private var linePanel:Form = new LineOptionsPanel();

private const MENU_NODE_INFO:String = "节点信息(&W)";
private const MENU_NODE_RES_INFO:String = "节点资源信息(&R)";

private const MENU_LINE_INFO:String = "链路信息(&W)";
private const MENU_LINE_RES_INFO:String = "链路资源信息(&R)";

private var myContextMenu:ContextMenu;
private var showInfoMenu:ContextMenuItem;
private var showResMenu:ContextMenuItem;
private var watchingNode:Node;
private var watchingLine:Line;

private var helpInfo:String = 
                "1. <b>Ctrl + 拖拽</b>: 拖拽全部节点;<br />" + 
                "2. <b>Shift + 拖拽</b>: 拖拽背景图片;<br />" + 
                "3. <b>Ctrl + Shift + 拖拽</b>: 拖拽整个拓扑图;<br />" + 
                "4. <b>Space + 移动鼠标</b>: 漫游模式,方便观看大图;<br />" +
                "<i>注: 以上所有操作的前提是拓扑图处于激活状态(焦点在拓扑图上), 即如果没反应需先点击一下拓扑图.</i>"

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
    graphTest.addEventListener(TopoEvent.GRAPH_CHANGE, graphChangeHandler);
    graphTest.addEventListener(TopoEvent.NODE_DOUBLE_CLICK, showChildMapHandler);

    graphTest.addEventListener(DragEvent.DRAG_ENTER, dragEnterHandler);
    graphTest.addEventListener(DragEvent.DRAG_DROP, dragDropHandler);
    
    graphTest.addEventListener(KeyboardEvent.KEY_UP, deleteHandler);
    
    graphTest.addEventListener(TopoEvent.OVER_NODE, pushContextMenu);
    graphTest.addEventListener(TopoEvent.OUT_NODE, removeContextMenu);
    graphTest.addEventListener(TopoEvent.OVER_LINE, pushContextMenu);
    graphTest.addEventListener(TopoEvent.OUT_LINE, removeContextMenu);
    
    // 定义右键菜单
    myContextMenu = new ContextMenu();
    showInfoMenu = new ContextMenuItem("");
    showResMenu = new ContextMenuItem("");
    myContextMenu.customItems.push(showInfoMenu);
    myContextMenu.customItems.push(showResMenu);
    myContextMenu.hideBuiltInItems();
    showInfoMenu.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, subMenuHandler);
    showResMenu.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, subMenuHandler);
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
    optionsPanel.label = title;
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

//////////////////////////////
// handlers
//////////////////////////////

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

private function dividerReleaseHandler(event:DividerEvent):void
{
    var ctrlObj:UIComponent = event.target.getChildAt(0);
    trace(getQualifiedClassName(ctrlObj));
    if(event.target is VDividedBox)
    {
        // 设置工具栏
        ctrlObj.height = 0 == ctrlObj.height ? ctrlObj.maxHeight : 0;
    }
    else
    {
        // 设置属性面板
        ctrlObj.width = 0 == ctrlObj.width ? ctrlObj.maxWidth : 0;
    }
}

/////////////////////////////
// other functions
/////////////////////////////

/**
 * 设置右键菜单
 * */
private function pushContextMenu(event:TopoEvent):void
{
    if (event.target is Node)
    {
        showInfoMenu.caption = MENU_NODE_INFO;
        showResMenu.caption = event.target.ResId == "" ? "" : MENU_NODE_RES_INFO;
        
        watchingNode = event.node;
        graphTest.contextMenu = myContextMenu;
    }
    else if (event.target is Line)
    {
        showInfoMenu.caption = MENU_LINE_INFO;
        showResMenu.caption = event.target.ResId == "" ? "" : MENU_LINE_RES_INFO;
        watchingLine = event.line;
        graphTest.contextMenu = myContextMenu;
    } 
}

private function removeContextMenu(event:TopoEvent):void
{
    graphTest.contextMenu = null;
}

private function subMenuHandler(event:ContextMenuEvent):void
{
    switch (event.target.caption)
    {
        case MENU_NODE_INFO:
        {
            trace("node >", watchingNode);
            showMenuInfo("Node", watchingNode.toString());
            break;
        }
        case MENU_LINE_INFO:
        {
            trace("line >", watchingLine);
            showMenuInfo("Line", watchingLine.toString());
            break;
        }
    }
}

private function showMenuInfo(title:String, msg:String):void
{
    var popWin:TitleWindow = new TitleWindow();
    var infoArea:TextArea = new TextArea();
    var closeButton:Button = new Button();
    var ctrlBar:ControlBar = new ControlBar();
    
    popWin.title = title;
    popWin.showCloseButton = true;
    infoArea.text = msg;
    infoArea.width = 400;
    infoArea.height = 200;
    closeButton.label = '关闭';
    closeButton.addEventListener(MouseEvent.CLICK, function():void{PopUpManager.removePopUp(popWin)});
    ctrlBar.setStyle('horizontalAlign', 'right');
    
    ctrlBar.addChild(closeButton);
    popWin.addChild(infoArea);
    popWin.addChild(ctrlBar);
    
    PopUpManager.addPopUp(popWin, this);
    PopUpManager.centerPopUp(popWin);
    
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