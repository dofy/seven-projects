package cn.com.ultrapower.topology.view
{
    import cn.com.ultrapower.topology.event.TopoEvent;
    import cn.com.ultrapower.topology.tool.LineData;
    import cn.com.ultrapower.topology.tool.SelectRect;
    
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    
    import mx.containers.Canvas;
    import mx.controls.Image;
    import mx.events.EffectEvent;
    import mx.managers.CursorManager;

    [Event(name="nodeClick", type="cn.com.ultrapower.topology.event.TopoEvent")]
    [Event(name="lineClick", type="cn.com.ultrapower.topology.event.TopoEvent")]
    [Event(name="graphClick", type="cn.com.ultrapower.topology.event.TopoEvent")]
    [Event(name="graphChange", type="cn.com.ultrapower.topology.event.TopoEvent")]
    [Event(name="nodeDoubleClick", type="cn.com.ultrapower.topology.event.TopoEvent")]
    
    public class Graph extends Canvas
    {
        // consts
        private const NODE_ID_BEGIN:uint = 0; // 节点开始层级
        private const LINE_ID_BEGIN:uint = 0; // 线 开始层级
        
        private const STATE_NOTHING:uint = 0;
        private const STATE_MOVE_ALL:uint = 1;
        private const STATE_MOVE_NODE:uint = 2;
        private const STATE_MOVE_PROXY:uint = 3;
        private const STATE_MOVE_BACKGROUND:uint = 5;
        private const STATE_MOVE_ALL_PREVIEW:uint = 7;
        private const STATE_SELECT_LINE:uint = 10;
        private const STATE_DRAG_RECT:uint = 100;
        private const STATE_FREE_MODE:uint = 200;
        
        public const MIN_SCALE:Number = .5;
        public const MAX_SCALE:Number = 3;
        
        private const MOVE_SPEED:Number = 10;
        
        // cursor
        [Embed(source="../assets/mouse/m_c.png")]
        private var mC:Class;
        [Embed(source="../assets/mouse/m_l.png")]
        private var mL:Class;
        [Embed(source="../assets/mouse/m_r.png")]
        private var mR:Class;
        [Embed(source="../assets/mouse/m_u.png")]
        private var mU:Class;
        [Embed(source="../assets/mouse/m_d.png")]
        private var mD:Class;
        [Embed(source="../assets/mouse/m_lu.png")]
        private var mLU:Class;
        [Embed(source="../assets/mouse/m_ld.png")]
        private var mLD:Class;
        [Embed(source="../assets/mouse/m_ru.png")]
        private var mRU:Class;
        [Embed(source="../assets/mouse/m_rd.png")]
        private var mRD:Class;
        
        private var cursorArray:Array = [mC, mL, mR, mU, mLU, mRU, mD, mLD, mRD];
        
        // vars
        private var _nodeId:uint; // 节点开始 Id
        private var _lineId:uint; // 线  开始 Id
        
        private var _editable:Boolean = true;      // 模式(是否可编辑)
        private var _hasDragRect:Boolean = false;  // 选框存在变量
        private var dragRect:SelectRect;           // 选框对象
        private var proxy:NodeProxy;               // 节点代理
        
        private var _state:uint = STATE_NOTHING;   // 初始化状态
        private var _isChanged:Boolean;            // 拓扑图被修改
        
        private var _curNode:Node;
        private var _curLine:Line;
        
        private var _id:String;                // 拓扑图 id
        private var _name:String;              // 拓扑图 名称
        private var _background:String;        // 拓扑图 背景
        private var _serverTime:Number;        // 服务器时间
        private var _timeOffset:Number         // 时间差
        
        private var _bgImage:Image;  // 背景
        private var _bgX:Number;
        private var _bgY:Number;
        private var _bgScaleX:Number;
        private var _bgScaleY:Number;
        
        private var _nodes:Array;    // 节点数组
        private var _lines:Array;    // 线 数组
        
        private var _rootNode:Node;   // 根节点
        
        private var _selectedNodes:Array;  // 选中的节点
        private var _selectedLines:Array;  // 选中的连线
        private var _oldMouseX:Number;     // 原 鼠标 x 坐标
        private var _oldMouseY:Number;     // 原 鼠标 y 坐标
        
        private var xStep:Number = 0;
        private var yStep:Number = 0;
        
        private var mouseFlag:int;
        private var oldMouseFlag:int = -1;
        
        private var _scale:Number;         // 缩放比
        
        private var _nodeMoved:Boolean = false;  // 节点被移动
        private var _bgMoved:Boolean = false;    // 背景被移动
        
        // ** 绘制用变量 **
        private var _existentNodes:Array; // 已经存在的节点
        private var _aloneNodes:Array;    // 无关系节点
        private var _midpoint:Point;      // 中心点
        
        private var drawBot:IDraw;        // 绘制树形算法
        private var isInit:Boolean;       // 是否初始化中
        
        private var lineData:LineData = new LineData();
        
        private var selectNone:Boolean;
        
        private var effectCount:int = 0;
        private var _actions:Array = new Array();
        
        // 快捷键控制
        private var _kMoveNode:Boolean;   // 移动节点控制键 被按下
        private var _kMoveBack:Boolean;   // 移动背景控制键 被按下
        private var _kMoveTopo:Boolean;   // 移动拓扑控制键 被按下
        
        private const KCODE_MOVE_NODE:int = 65;
        private const KCODE_MOVE_BACK:int = 83;
        private const KCODE_MOVE_TOPO:int = 68;
        private const KCODE_FREE_MODE:int = 70;
        
        public function Graph()
        {
            super();
            // 隐藏滚动条
			verticalScrollPolicy = "off";
			horizontalScrollPolicy = "off";
            
            init();
        }
        
        override protected function createChildren():void
        {
            super.createChildren();
            
            bindListener();
        }
        
        ////////////////////////////////////////
        // public functions
        ///////////////////////////////////////
        
        /**
         * 初始化一些变量
         * */
        public function init():void
        {
            isInit = true;
            
            _scale = 1;
            
            _bgImage = new Image();
            _bgImage.addEventListener(Event.COMPLETE, bgImageCompleteHandler);
            
            _nodes = new Array();
            _lines = new Array();
            _midpoint = new Point();
            
            _selectedNodes = new Array();
            _selectedLines = new Array();
            dragRect = new SelectRect();
            proxy = new NodeProxy();
            
            _kMoveNode = _kMoveBack = _kMoveTopo = false;
            
            drawBot = new DDefault();
            
            _nodeId = NODE_ID_BEGIN; // 节点开始 Id
            _lineId = LINE_ID_BEGIN; // 线  开始 Id
            
            _isChanged = false;
            _rootNode = null;
            lineData.clean();
        }
        
        /**
         * 绑定数据, 绘制拓扑图
         * */
        public function display(xml:XML):Boolean
        {
            init();
            removeAllChildren();
            var fromNode:Node;
            var toNode:Node;
            
            var mp_x:Number = midpoint.x;
            var mp_y:Number = midpoint.y;
            
            _id = xml.id;
            _name = xml.name;
            _serverTime = Number(xml.systime);
            
            addChild(_bgImage);
            
            background = xml.background;
            _bgX = xml.background.@x;
            _bgY = xml.background.@y;
            _bgScaleX = xml.background.@scalex;
            _bgScaleY = xml.background.@scaley;
            
            if (0 == _serverTime)
            {
                _serverTime = new Date().getTime();
            }
            
            // 计算服务器与客户端时间差
            _timeOffset = _serverTime - new Date().getTime();
            
            
            for each (var nodex:XML in xml.node)
            {
            	addNode(mp_x, mp_y, nodex);
            }
            
            for each (var linex:XML in xml.line)
            {
                fromNode = getNodeByName(linex.@fromId) as Node;
                toNode   = getNodeByName(linex.@toId) as Node;
                if (fromNode && toNode)
                {
                	addLine(fromNode, toNode, linex);
                }
            }
            
            if(!_rootNode)
            {
                trace("自动指派根节点.");
                try
                {
                    rootNode = getNodeById(NODE_ID_BEGIN).Name;
                }
                catch (e:Error)
                {
                    trace(e.message);
                }
                
            }
            // 未找到根节点
            if(!_rootNode)
            {
                trace("根节点不存在!");
                dispatchEvent(new TopoEvent(TopoEvent.GRAPH_CHANGE));
                return false;
            }
            
            draw();
            _isChanged = false;
            isInit = false;
            return true;
        }
        
        public function draw(model:IDraw = null):void
        {
        	if (_editable || isInit)
        	{
        	    model && (drawBot = model);
                drawBot.makeTreeForm(this, getTreeArray());
                dispatchEvent(new TopoEvent(TopoEvent.GRAPH_CHANGE));
        	}
        }
        
        /**
         * 内容居中
         * */
        public function center(obj:DisplayObject = null):void
        {
        	var tr:Rectangle;
        	var xOffset:Number;
        	var yOffset:Number
        	if (obj)
        	{
        	   tr = obj.getRect(this);
            }
            else
            {
        	   tr = getContentArea();
        	}
        	xOffset = midpoint.x-tr.x-tr.width/2;
        	yOffset = midpoint.y-tr.y-tr.height/2;
        	dMoveNodes(xOffset, yOffset);
        	_bgImage.x += xOffset;
        	_bgImage.y += yOffset;
        }
        
        /**
         * 添加节点
         * */
        public function addNode(_x:Number, _y:Number, data:XML):Node{
            var numId:String = data.@id;
        	var newNode:Node = new Node(_nodeId++, data);
            newNode.editable = _editable;
            newNode.Name = getNewNodeId(data.@id);
            newNode.x = _x;
            newNode.y = _y;
            _nodes.push(newNode);
            addChild(newNode);
            newNode.realScale = _scale;
            dispatchEvent(new TopoEvent(TopoEvent.GRAPH_CHANGE));
            return newNode;
        }
        
        /**
         * 删除选中对象
         * */
        public function deleteSelectedObjects():void
        {
            deleteNodes();
            deleteLines();
        }
        
        /**
         * 删除节点
         * */
        public function deleteNodes():void
        {
        	if (_editable)
        	{
	        	while (_selectedNodes.length > 0)
	        	{
	        		removeNode(_selectedNodes.pop());
	        	}
	        	_nodes.indexOf(_rootNode) === -1 && _nodes.length > 0 && (_rootNode = _nodes[0]);
                dispatchEvent(new TopoEvent(TopoEvent.GRAPH_CHANGE));
        	}
        }
        
        /**
         * 删除连线
         * */
        public function deleteLines():void
        {
            if (_editable)
            {
                while (_selectedLines.length > 0)
                {
                    removeLine(_selectedLines.pop());
                }
                dispatchEvent(new TopoEvent(TopoEvent.GRAPH_CHANGE));
            }
        }
        
        /**
         * 生成层级数组
         * */
        public function getTreeArray():Array
        {
            var treeArray:Array = new Array();
            _aloneNodes = new Array();
            _existentNodes = new Array();
            _aloneNodes = _nodes.concat();
            // 入口
            pushNode(treeArray, _rootNode);
            // 处理剩余节点
            _aloneNodes.length > 0 && treeArray.push(_aloneNodes);
            return treeArray;
        }
        
        /**
         * 设置排列模式
         * */
        public function setDrawMode(dMode:IDraw):void
        {
            drawBot = dMode;
        }
        
        public function scaleTo(ws:Number, hs:Number):void
        {
            doScale(ws, hs);
        }
        
        public function scaleBy(ws:Number, hs:Number):void
        {
            doScale(widthScale + ws, heightScale + hs);
        }
        
        /**
         * 从 Id 获取节点
         * */
        public function getNodeById(id:uint):Node
        {
            var nodeById:Node = null;
            for (var i:uint = 0; i < _nodes.length; i++)
            {
                if((_nodes[i] as Node).Id == id)
                {
                    nodeById = _nodes[i];
                    break;
                }
            }
            return nodeById;
        }
        
        /**
         * 从 Name 获取节点
         * */
        public function getNodeByName(name:Number):Node
        {
            var nodeByName:Node = null;
            for (var i:uint = 0; i < _nodes.length; i++)
            {
                if((_nodes[i] as Node).Name == name)
                {
                    nodeByName = _nodes[i];
                    break;
                }
            }
            return nodeByName;
        }
        
        /**
         * 从 Id 获取连线
         * */
        public function getLineById(id:uint):Line
        {
            var tmpLine:Line = null;
            for (var i:uint = 0; i < _lines.length; i++)
            {
                if((_lines[i] as Line).Id == id)
                {
                    tmpLine = _lines[i];
                    break;
                }
            }
            return tmpLine;
        }
        
        /**
         * 设置节点到顶端
         * */
        public function setNodeToTop(node:Node):void
        {
            var newIndex:uint = getChildren().length - 1;
            setChildIndex(node, newIndex);
        }
        
        /**
         * 返回可用唯一id
         * */
        public function getNewNodeId(id:Number):Number
        {
            (0 >= id || isNaN(id) || getNodeByName(id)) && (id = getNewNodeId(new Date().getTime() + _timeOffset)); 
            return id;
        }
        
        /**
         * 添加 action 到动作列表
         * */
        public function appendActions(f:Function, goon:Boolean = false, runNow:Boolean = false):void
        {
            _actions.push({fun:f, go:goon});
            runNow && runActionsList();
        }
        
        /**
         * 清空动作列表
         * */
        public function cleanActions():void
        {
            _actions = [];
            effectCount = 0;
        }
        
        ///////////////////////////////////////////
        // getter & setter
        ///////////////////////////////////////////
        
        /**
         * 获取属性
         * */
        public function get mapId():String
        {
            return _id;
        }
        
        public function set mapId(id:String):void
        {
            _id = id;
        }
        
        public function get mapName():String
        {
            return _name;
        }
        
        public function set mapName(n:String):void
        {
            _editable && (_name = n);
        }
        
        public function get background():String
        {
            return _background;
        }
        
        public function set background(url:String):void
        {
            if (isInit || (_editable && _background != url))
            {
                _background = url;
                _bgImage.source = url;
            }
        }
        
        public function get bgX():Number
        {
            return _bgImage.x;
        }
        
        public function set bgX(xx:Number):void
        {
            _bgImage.x = xx;
        }
        
        public function get bgY():Number
        {
            return _bgImage.y;
        }
        
        public function set bgY(yy:Number):void
        {
            _bgImage.y = yy;
        }
        
        public function get bgScaleX():Number
        {
            return _bgImage.scaleX;
        }
        
        public function set bgScaleX(ww:Number):void
        {
            if (ww > 0)
            {
                _bgImage.scaleX = ww;
            }
            
        }
        
        public function get bgScaleY():Number
        {
            return _bgImage.scaleY;
        }
        
        public function set bgScaleY(hh:Number):void
        {
            if (hh > 0)
            {
                _bgImage.scaleY = hh;
            }
            
        }
        
        public function get isChanged():Boolean
        {
            return _isChanged;
        }
        
        /**
         * 模式转换
         * */
        public function set editable(can:Boolean):void
        {
        	if (_editable != can)
        	{
        		var i:uint;
	        	_editable = can;
                for (i = 0; i < _nodes.length; i++)
                {
                    _nodes[i].editable = can;
                }
                for (i = 0; i < _lines.length; i++)
                {
                    _lines[i].editable = can;
                }
                emptySelectedNodes();
                emptySelectedLines();
	        }
        }
        
        public function get editable():Boolean
        {
        	return _editable;
        }
        
        /**
         * 手动设置根节点
         * */
        public function set rootNode(nodeName:Number):void
        {
            var tmpNode:Node = getNodeByName(nodeName);
            if(tmpNode)
            {
                _rootNode = tmpNode;
                trace("根节点:", nodeName);
            }
            else
            {
                trace("节点", nodeName, "不存在");
            }
        }
        
        /**
         * 当前选中节点
         * */
        public function get currentNode():Node
        {
            return _curNode;
        }
        
        /**
         * 中心点
         * */
        public function get midpoint():Point
        {
        	_midpoint.x = width/2;
        	_midpoint.y = height/2;
        	return _midpoint;
        }
        
        /**
         * 缩放控制
         * */
        [Bindable]
        public function get widthScale():Number
        {
        	var tr:Rectangle = getContentArea();
            return tr.width / width;
        }
        
        public function set widthScale(ws:Number):void
        {
        	doScale(ws, 0);
            //center();
        }
        
        [Bindable]
        public function get heightScale():Number
        {
            var tr:Rectangle = getContentArea();
            return tr.height / height;
        }
        
        public function set heightScale(hs:Number):void
        {
        	doScale(0, hs);
        	//center();
        }
        
        [Bindable]
        public function get realScale():Number
        {
            return _scale;
        }
        
        public function set realScale(s:Number):void
        {
            if (s != _scale)
            {
                if (MIN_SCALE > s)
                {
                    s = MIN_SCALE;
                }
                else if (MAX_SCALE < s)
                {
                    s = MAX_SCALE;
                }
                _scale = s;
                for (var i:uint = 0; i < _nodes.length; i++)
                {
                    _nodes[i].realScale = s;
                }
            }
        }
        
        /**
         * 获取 xml 数据
         * */
        public function get XMLData():XML
        {
            var xmlData:XML = new XML("<topology />");
            var i:uint;
            // 拓扑图熟悉
            xmlData.id = _id;
            xmlData.name = _name;
            xmlData.background = _background;
            xmlData.background.@x = _bgImage.x.toFixed(2);
            xmlData.background.@y = _bgImage.y.toFixed(2);
            xmlData.background.@scalex = _bgImage.scaleX.toFixed(2);
            xmlData.background.@scaley = _bgImage.scaleY.toFixed(2);
            // 节点数据
            for (i = 0; i < _nodes.length; i++)
            {
                xmlData.node[i] = _nodes[i].Data;
            }
            // 连线数据
            for (i = 0; i < _lines.length; i++)
            {
                xmlData.line[i] = _lines[i].Data;
            }
            _isChanged = false;
            return xmlData;
        }
        
        /**
         * 获取所有内容区域
         * */
        public function getAllArea():Rectangle
        {
            var rt:Rectangle = getContentArea();
            rt.width = Math.max(rt.x + rt.width, _bgImage.x + _bgImage.contentWidth);
            rt.height = Math.max(rt.y + rt.height, _bgImage.y + _bgImage.contentHeight);
            rt.x = Math.min(rt.x, _bgImage.x);
            rt.y = Math.min(rt.y, _bgImage.y);
            rt.width -= rt.x;
            rt.height -= rt.y;
            return rt;
        }

        ///////////////////////////////////////
        // private functions
        ///////////////////////////////////////
        
        /**
         * 绘制节点
         * */
        private function drawNodes():void
        {
            for (var i:uint = 0; i < _nodes.length; i++)
            {
                addChild(_nodes[i]);
            }
        }
        
        /**
         * 绘制连线
         * */
        private function drawLines():void
        {
            for (var i:uint = 0; i < _lines.length; i++)
            {
                addChild(_lines[i]);
            }
        }
        
        /**
         * 绑定事件
         * */
        private function bindListener():void{
            addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
            addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
            addEventListener(TopoEvent.GRAPH_CHANGE, anyChangeHandler);
            addEventListener(TopoEvent.NODE_CHANGE, anyChangeHandler);
            addEventListener(TopoEvent.LINE_CHANGE, anyChangeHandler);
            
            addEventListener(KeyboardEvent.KEY_DOWN, kbDownHandler);
            addEventListener(KeyboardEvent.KEY_UP, kbUpHandler);
            
            addEventListener(EffectEvent.EFFECT_START, effectStartHandler);
            addEventListener(EffectEvent.EFFECT_END, effectEndHandler);
        }
        
        /**
         * 获取内容区域
         * */
        private function getContentArea():Rectangle{
        	var xMin:Number = 0;
        	var yMin:Number = 0;
        	var xMax:Number = 0;
        	var yMax:Number = 0;
        	if (_nodes.length > 0)
        	{
                xMin = _nodes[0].x;
                yMin = _nodes[0].y;
                xMax = _nodes[0].x + _nodes[0].width;
                yMax = _nodes[0].y + _nodes[0].height;
	            
	            if (_nodes.length > 1)
	            {
		        	for (var i:uint = 0; i<_nodes.length; i++)
		        	{
		                xMin = Math.min(xMin, _nodes[i].x);
		                yMin = Math.min(yMin, _nodes[i].y);
		                xMax = Math.max(xMax, _nodes[i].x + _nodes[i].width);
		                yMax = Math.max(yMax, _nodes[i].y + _nodes[i].height);
		        	}	
	        	}
        	}
        	
        	return new Rectangle(xMin, yMin, xMax-xMin, yMax-yMin);
        }
        
        /**
         * 加载背景图
         * */
        private function loadBG(url:String):void
        {
            var imgLoader:URLLoader = new URLLoader();
            var imgURL:URLRequest = new URLRequest(url);
            
            imgLoader.addEventListener(Event.COMPLETE, 
                                        function():void
                                        {
                                            trace("OK~~~");
                                            background = imgLoader.data;
                                            imgLoader = null;
                                            imgURL = null;
                                        });
            imgLoader.addEventListener(IOErrorEvent.IO_ERROR, 
                                        function():void
                                        {
                                            trace("IO Error!");
                                            imgLoader = null;
                                            imgURL = null;
                                        });
            
            imgLoader.load(imgURL);
            
        }
        
        /**
         * 执行缩放
         * */
        private function doScale(ws:Number = 0, hs:Number = 0):void
        {
        	var i:uint;
        	var cr:Rectangle = getContentArea(); // 内容区域
        	
        	var cx:Number = cr.x;          // 区域 x 坐标
        	var cy:Number = cr.y;          // 区域 y 坐标
        	var cw:Number = widthScale;    // 当前横向缩放比
        	var ch:Number = heightScale;   // 当前纵向缩放比
        	
        	var nl:uint   = _nodes.length;
        	var tn:Node;
        	
        	if (ws <= 0)
        	{
        	   ws = cw;
        	}
        	if (hs <= 0)
        	{
        	   hs = ch;
        	}
        	
    		for (i = 0; i < nl; i++)
    		{
    			tn = _nodes[i];
    			tn.moveTo(cx + (tn.x - cx) * ws / cw, cy + (tn.y - cy) * hs / ch);
    		}
            var oldsx:Number = _bgImage.scaleX;
            var oldsy:Number = _bgImage.scaleY;
            _bgImage.scaleX *= ws / cw;
            _bgImage.scaleY *= hs / ch;
            _bgImage.x = cx + (_bgImage.x - cx) * ws / cw;
            _bgImage.y = cy + (_bgImage.y - cy) * hs / ch;
            dispatchEvent(new TopoEvent(TopoEvent.GRAPH_CHANGE));
        }
        
        /**
         * 向树形数组中添加节点
         * */
        private function pushNode(treeArray:Array, node:Node, level:uint = 0):void
        {
            var i:uint;
            if(node && _existentNodes.indexOf(node.Id) === -1)
            {
                _existentNodes.push(node.Id);
                removeAloneNode(node);
                if (!treeArray[level])
                {
                    treeArray[level] = new Array();
                }
                treeArray[level].push(node);

                // 绘制所有节点的子节点
                if(node.hasChild())
                {
                    for (i = 0; i < node.Children.length; i++)
                    {
                        pushNode(treeArray, node.Children[i], level+1);
                    }
                }
                // 绘制所有节点的父节点
                if(node.hasParent())
                {
                    for (i = 0; i < node.Parent.length; i++)
                    {
                        pushNode(treeArray, node.Parent[i], level+1);
                    }
                }
            }
        }
        
        /**
         * 从预备数组中移除有关系节点
         * */
        private function removeAloneNode(node:Node):void
        {
            _aloneNodes.splice(_aloneNodes.indexOf(node), 1);
        }
        
        /**
         * 绑定连线第二节点
         * */
        private function checkProxy():Node
        {
        	var nlen:uint = _nodes.length;
        	var chkNode:Node = null;
        	for (var i:uint = 0; i < nlen; i++)
        	{
        		if (proxy.hitTestObject(_nodes[i]))
        		{
        			chkNode = _nodes[i];
        			break;
        		}
        	}
        	/*
        	// 多线了, 不用判断了
        	if (chkNode && (_curLine.fromNode as Node).checkNode(chkNode))
        	{
        		chkNode = null;
        	}
        	*/
        	return chkNode;
        }
        
        /**
         * 检测选中区域对象
         * */
        private function checkObjects():void
        {
            var i:uint;
            var len:uint;
            emptySelectedNodes();
            emptySelectedLines();
            
            len = _nodes.length;
            for (i = 0; i < len; i++)
            {
                if(dragRect.hitTestObject(_nodes[i]))
                {
                   _selectedNodes.push(_nodes[i]);
                   _nodes[i].isSelected = true;
                }
            }
            /*
            // do not delete
            len = _lines.length;
            for (i = 0; i < len; i++)
            {
                if(dragRect.hitTestObject(_lines[i]))
                {
                   _selectedLines.push(_lines[i]);
                   _lines[i].isSelected = true;
                }
            }
            */
        }
        
        private function emptySelectedNodes():void
        {
            while (_selectedNodes.length > 0)
            {
                _selectedNodes.pop().isSelected = false;
            }
            _curNode = null;
        }
        
        private function emptySelectedLines():void
        {
            while (_selectedLines.length > 0)
            {
                _selectedLines.pop().isSelected = false;
            }
        }
        
        private function addLine(fromNode:INode, toNode:INode, data:XML = null):Line
        {
            var tmpLine:Line = new Line(_lineId++, data);
            node2node(fromNode, toNode);
            if(tmpLine.bindNodes(fromNode, toNode))
            {
            	_lines.push(tmpLine);
            	fromNode.pushLine(tmpLine);
            	toNode.pushLine(tmpLine);
            	tmpLine.editable = _editable;
            	addChildAt(tmpLine, 1);
            	lineData.pushLine(tmpLine);
            	return tmpLine;
            }
            else
            {
            	return null;
            }
        }
        
        private function removeLine(line:Line):Boolean
        {
        	if (getChildren().indexOf(line) >= 0)
        	{
        	    lineData.removeLine(line);
        		removeChild(line as DisplayObject);
        		_lines.splice(_lines.indexOf(line), 1);
        		line.fromNode.removeSubNode(line.toNode);
        		line.toNode.removeParentNode(line.fromNode);
        		return true;
        	}
        	else
        	{
        		return false;
        	}
        }
        
        private function removeNode(node:Node):Boolean{
            if (getChildren().indexOf(node) >= 0)
            {
            	var tmpLines:Array = node.getLines();
            	var llen:uint = tmpLines.length;
                removeChild(node);
                _nodes.splice(_nodes.indexOf(node), 1);
                for (var i:uint = 0; i < llen; i++)
                {
                	removeLine(tmpLines[i]);
                }
                return true;
            }
            else
            {
                return false;
            }
        }
        
        private function node2node(fromNode:INode, toNode:INode):Boolean{
        	return fromNode.addSubNode(toNode) && toNode.addParentNode(fromNode);
        }
        
        /**
         * 移动节点 (静态, 用于拖拽)
         * */
        private function moveNodes(offsetX:Number, offsetY:Number):void
        {
            for (var i:uint; i < _selectedNodes.length; i++)
            {
                _selectedNodes[i].x += offsetX;
                _selectedNodes[i].y += offsetY;
            }
        }
        
        /**
         * 移动节点 (动态, 用于重绘)
         * */
        private function dMoveNodes(offsetX:Number, offsetY:Number):void
        {
        	if (offsetX != 0 || offsetY != 0)
        	{
	            for (var i:uint; i < _nodes.length; i++)
	            {
	                _nodes[i].moveBy(offsetX, offsetY);
	            }
            }
        }
        /**
         * 返回可用的对象 <del>, Graph 本身或</del>一个 Node
         * */
        private function getUsableObject(obj:Object, notSelf:Boolean = false):Object
        {
            if (notSelf)
            {
                return getUsableObject(obj.parent);
            }
            if (obj is NodeProxy || obj is Node || obj is Line || obj is Graph)
            {
                return obj;
            } 
            else 
            {
                return getUsableObject(obj.parent);
            }
        }
        
        /**
         * actions
         * */
        private function runActionsList():void
        {
            var obj:Object = _actions.shift();
            if (obj)
            {
                var f:Function = obj.fun;
                var g:Boolean = obj.go;
                f.call(f);
                g && runActionsList();
            }
        }
        
        ///////////////////////////////////
        // handler
        ///////////////////////////////////
        
        /**
         * 相应鼠标事件方法
         * */
        private function mouseDownHandler(event:MouseEvent):void
        {
            setFocus();
            if ( _state != STATE_NOTHING)
            {
                return;
            }
            var targetObj:Object;
            if (_editable)
            {
                emptySelectedLines()
                // 拖拽节点
                targetObj = getUsableObject(event.target as Object);
                if (_kMoveNode)
                {
                    // 拖拽全图
                    _state = STATE_MOVE_ALL;
                    emptySelectedNodes();
                    _selectedNodes = _nodes.concat();
                    _oldMouseX = mouseX;
                    _oldMouseY = mouseY;
                    addEventListener(MouseEvent.MOUSE_MOVE, moveNodesHandler);
                }
                else if (_kMoveBack)
                {
                    // 拖拽背景
                    _state = STATE_MOVE_BACKGROUND
                    _oldMouseX = mouseX;
                    _oldMouseY = mouseY;
                    addEventListener(MouseEvent.MOUSE_MOVE, moveBackgroundHandler);
                }
                else if (_kMoveTopo)
                {
                    // 拖拽整个拓扑图
                    _state = STATE_MOVE_ALL_PREVIEW;
                    _selectedNodes = _nodes.concat();
                    _oldMouseX = mouseX;
                    _oldMouseY = mouseY;
                    addEventListener(MouseEvent.MOUSE_MOVE, moveAllHandler);
                }
                else if (targetObj is Node)
                {
                    // 拖拽选中节点
                    _state = STATE_MOVE_NODE;
                    // 点击的节点不在选中范围内, 清除选中节点, 将当前阶段作为拖拽列表
                    if (_selectedNodes.indexOf(targetObj) === -1)
                    {
                        emptySelectedNodes();
                        _selectedNodes.push(targetObj);
                        targetObj.isSelected = true;
                    }
                    _curNode = targetObj as Node;
                    _oldMouseX = mouseX;
                    _oldMouseY = mouseY;
                    addEventListener(MouseEvent.MOUSE_MOVE, moveNodesHandler);
                }
                else if (targetObj is NodeProxy)
                {
                    // 创建节点代理用于创建连线
                    _state = STATE_MOVE_PROXY;
                    var cNode:Node = getUsableObject(targetObj, true) as Node;
                    _curNode = cNode;
                    addChild(proxy);
                    proxy.x = mouseX;
                    proxy.y = mouseY;
                    _curLine = addLine(cNode, proxy);
                    _curLine.editable = false;
                    setNodeToTop(cNode);
                    emptySelectedNodes();
                    _selectedNodes.push(proxy);
                    _oldMouseX = mouseX;
                    _oldMouseY = mouseY;
                    addEventListener(MouseEvent.MOUSE_MOVE, moveNodesHandler);
                }
                else if (targetObj is Line)
                {
                    // 点击连线
                    _state = STATE_SELECT_LINE;
                    _curLine = targetObj as Line;
                    _selectedLines.push(targetObj);
                    targetObj.isSelected = true;
                }
                else
                {
                    // 绘制选区
                    if (_state != STATE_DRAG_RECT)
                    {
                        _state = STATE_DRAG_RECT;
                        dragRect.setStartPoint(mouseX, mouseY);
                        
                        addChild(dragRect);
                        addEventListener(MouseEvent.MOUSE_MOVE, drawRectHandler);
                    }
                }
            }
            else
            {
                // 拖拽整个拓扑图
                _state = STATE_MOVE_ALL_PREVIEW;
                _selectedNodes = _nodes.concat();
                _oldMouseX = mouseX;
                _oldMouseY = mouseY;
                addEventListener(MouseEvent.MOUSE_MOVE, moveAllHandler);
            }
        }
        
        /**
         * mouse handler
         * */
        private function moveNodesHandler(event:MouseEvent):void
        {
            // 移动整个拓扑图
            _nodeMoved = true;
            moveNodes(mouseX - _oldMouseX, mouseY - _oldMouseY);
            _oldMouseX = mouseX;
            _oldMouseY = mouseY;
        }
        
        /**
         * 移动背景
         * */
        private function moveBackgroundHandler(event:MouseEvent):void
        {
            // 移动背景
            _bgMoved = true;
            _bgImage.move(_bgImage.x + mouseX - _oldMouseX, _bgImage.y + mouseY - _oldMouseY);
            _oldMouseX = mouseX;
            _oldMouseY = mouseY;
        }
        
        /**
         * 移动背景和全部节点
         * */
        private function moveAllHandler(event:MouseEvent):void
        {
            _nodeMoved = true;
            _bgMoved = true;
            moveNodes(mouseX - _oldMouseX, mouseY - _oldMouseY);
            _bgImage.move(_bgImage.x + mouseX - _oldMouseX, _bgImage.y + mouseY - _oldMouseY);
            _oldMouseX = mouseX;
            _oldMouseY = mouseY;
        }
        
        /**
         * 绘制选取框
         * */
        private function drawRectHandler(event:MouseEvent):void
        {
            dragRect.reDraw(mouseX, mouseY);
        }
        
        /**
         * 处理鼠标事件
         * */
        private function mouseUpHandler(event:Event):void
        {
            /*
            if (event.target is Line)
            {
                trace(9);
                if (Math.random() < .5)
                {
                    trace(8);
                    (event.target as Line).setDrawBot(new DLLine(event.target as Line));
                }
                else
                {
                    trace(7);
                    (event.target as Line).setDrawBot(new DLMultiLine(event.target as Line));
                }
            }
            */
            //this.setFocus();
            switch (_state)
            {
                case STATE_DRAG_RECT:
                {
                    checkObjects();
                    removeChild(dragRect);
                    removeEventListener(MouseEvent.MOUSE_MOVE, drawRectHandler);
                    dispatchEvent(new TopoEvent(TopoEvent.GRAPH_CLICK));
                    break;
                }
                case STATE_MOVE_PROXY:
                {
                    var tmpToNode:Node = checkProxy();
                    if (tmpToNode)
                    {
                        // 检测到合法节点
                        _curLine.bindToNode(tmpToNode);
                        node2node(_curLine.fromNode, _curLine.toNode);
                        tmpToNode.pushLine(_curLine);
                        _curLine.editable = true;
                        lineData.pushLine(_curLine);
                        dispatchEvent(new TopoEvent(TopoEvent.GRAPH_CHANGE))
                    }
                    else
                    {
                        // 无节点可绑定, 移除连线
                        removeLine(_curLine);
                        _curLine = null;
                    }
                    removeChild(proxy);
                    emptySelectedNodes();
                }
                case STATE_MOVE_ALL:
                {
                    emptySelectedNodes();
                }
                case STATE_MOVE_NODE:
                {
                    removeEventListener(MouseEvent.MOUSE_MOVE, moveNodesHandler);
                    _nodeMoved && dispatchEvent(new TopoEvent(TopoEvent.GRAPH_CHANGE));
                    _nodeMoved = false;
                    break;
                }
                case STATE_MOVE_BACKGROUND:
                {
                    removeEventListener(MouseEvent.MOUSE_MOVE, moveBackgroundHandler);
                    _bgMoved && dispatchEvent(new TopoEvent(TopoEvent.GRAPH_CHANGE));
                    _bgMoved = false;
                    break;
                }
                case STATE_MOVE_ALL_PREVIEW:
                {
                    emptySelectedNodes();
                    removeEventListener(MouseEvent.MOUSE_MOVE, moveAllHandler);
                    break;
                }
                case STATE_SELECT_LINE:
                {
                    emptySelectedNodes();
                }
            }
            _state = STATE_NOTHING;
        }
        
        private function anyChangeHandler(event:TopoEvent):void
        {
            _isChanged = true;
        }
        
        private function kbDownHandler(event:KeyboardEvent):void
        {
            if (KCODE_FREE_MODE == event.keyCode)
            {
                if (STATE_NOTHING == _state)
                {
                    _state = STATE_FREE_MODE;
                    _selectedNodes = _nodes.concat();
                    addEventListener(MouseEvent.MOUSE_MOVE, freeModeHandler);
                    addEventListener(Event.ENTER_FRAME, freeModeEFHandler);
                }
            }
            else
            {
                _kMoveNode = KCODE_MOVE_NODE == event.keyCode;
                _kMoveBack = KCODE_MOVE_BACK == event.keyCode;
                _kMoveTopo = KCODE_MOVE_TOPO == event.keyCode;
            }
        }
        
        private function kbUpHandler(event:KeyboardEvent):void
        {
            if (KCODE_FREE_MODE == event.keyCode || _kMoveNode || _kMoveBack || _kMoveTopo)
            {
                CursorManager.removeAllCursors();
                emptySelectedNodes();
                _state = STATE_NOTHING;
                removeEventListener(MouseEvent.MOUSE_MOVE, freeModeHandler);
                removeEventListener(Event.ENTER_FRAME, freeModeEFHandler);
                _nodeMoved || _bgMoved && dispatchEvent(new TopoEvent(TopoEvent.GRAPH_CHANGE));
                
                oldMouseFlag = -1;
                xStep = yStep = 0;
                
                _kMoveNode = _kMoveBack = _kMoveTopo = false;
                _nodeMoved = _bgMoved = false;
            }
        }
        
        private function effectStartHandler(event:EffectEvent):void
        {
            effectCount++;
        }
        
        private function effectEndHandler(event:EffectEvent):void
        {
            effectCount--;
            if (effectCount <= 0)
            {
                trace(">>>> effect end!!!!!");
                dispatchEvent(new TopoEvent(TopoEvent.GRAPH_CHANGE));
                runActionsList();
            }
        }
        
        private function bgImageCompleteHandler(event:Event):void
        {
            // 背景图片加载完成
            dispatchEvent(new TopoEvent(TopoEvent.GRAPH_CHANGE));
            
            // 背景 移动/缩放
            bgX = _bgX;
            bgY = _bgY;
            bgScaleX = _bgScaleX;
            bgScaleY = _bgScaleY;
        }
        
        /**
         * 漫游模式
         * */
        private function freeModeHandler(event:MouseEvent):void
        {
            var ar:Rectangle = getAllArea();
            var gr:Rectangle = getRect(this);
            var xSpaceL1:Number = gr.width / 3;
            var xSpaceL2:Number = xSpaceL1 * 2;
            var ySpaceL1:Number = gr.height / 3;
            var ySpaceL2:Number = ySpaceL1 * 2;
            
            _nodeMoved = true;
            _bgMoved = true;
            
            var mouseXFlag:uint;
            var mouseYFlag:uint;
            
            if (mouseX < xSpaceL1)
            {
                xStep = 1 * MOVE_SPEED;
                mouseXFlag = 1;
            }
            else if (mouseX > xSpaceL2)
            {
                xStep = -1 * MOVE_SPEED;
                mouseXFlag = 2;
            }
            else
            {
                xStep = 0;
                mouseXFlag = 0;
            }
            
            if (mouseY < ySpaceL1)
            {
                yStep = 1 * MOVE_SPEED;
                mouseYFlag = 3;
            }
            else if (mouseY > ySpaceL2)
            {
                yStep = -1 * MOVE_SPEED;
                mouseYFlag = 6;
            }
            else
            {
                yStep = 0;
                mouseYFlag = 0;
            }
            mouseFlag = mouseXFlag + mouseYFlag;
            if (mouseFlag != oldMouseFlag)
            {
                oldMouseFlag = mouseFlag;
                CursorManager.removeAllCursors();
                CursorManager.setCursor(cursorArray[mouseXFlag + mouseYFlag]);
            }
        }
        
        private function freeModeEFHandler(event:Event):void
        {
            moveNodes(xStep, yStep);
            _bgImage.x += xStep;
            _bgImage.y += yStep;
        }
    }
}