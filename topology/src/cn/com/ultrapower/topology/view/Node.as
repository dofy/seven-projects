package cn.com.ultrapower.topology.view
{   
    import cn.com.ultrapower.topology.assets.Icons;
    import cn.com.ultrapower.topology.event.TopoEvent;
    
    import flash.events.MouseEvent;
    
    import mx.containers.VBox;
    import mx.controls.Image;
    import mx.controls.Label;
    import mx.effects.Glow;
    import mx.effects.Move;
    import mx.effects.Zoom;
    import mx.events.EffectEvent; 
    
    public class Node extends VBox implements INode
    {
        private const CORNET_RADIUS:uint     = 5;
        private const BG_COLOR:Number        = 0xcccccc;
        private const BG_COLOR_DOWN:Number   = 0x5cc0ff;
        private const BG_ALPHA_NORMAL:Number = 0;
        private const BG_ALPHA_OVER:Number   = 0.5;
        private const BG_ALPHA_SELECT:Number = 0.7;
        private const BG_ALPHA_SUPER:Number  = 0.9;
        
        private const BLINK_ALPHA_FROM:Number  = 1;
        private const BLINK_ALPHA_TO:Number  = 1;
        private const BLINK_STRENGTH_FROM:Number  = 10;
        private const BLINK_STRENGTH_TO:Number  = 0;
        
        private var icons:Icons;          // 图标资源
        private var nodeIcon:Image;       // 图标
        private var nodeTitle:Label;      // 标题
        private var effect:Move;          // 动效
        private var zoom:Zoom;            // 缩放
        private var proxy:NodeProxy;      // 节点代理
        
        private var _editable:Boolean = false;  // 编辑模式
        
        private var _children:Array; // 子节点集合
        private var _parent:Array;   // 父节点集合
        
        private var _lines:Array;    // 关联连线
        
        private var _id:uint;        // 数字 id
        private var _blink:int;      // 闪烁颜色
        private var blinkBot:Glow;   // 闪烁特效
        
        private var _data:XML;       // XML 数据
        
        private var _ox:Number;          // 原始 x 坐标信息
        private var _oy:Number;          // 原始 y 坐标信息
        private var _scale:Number;       // 缩放比例
//        
//        private var _endX:Number;     // 移动最终横坐标
//        private var _endY:Number;     // 移动最终纵坐标
        
        private var _showTitle:Boolean = true;  // 显示标题
//        private var _hasTitle:Boolean = true;   // 存在标题
        
        private var _isSelected:Boolean; // 节点被选中
        private var _isDown:Boolean;     // 鼠标按下
        
        public function Node(id:uint, data:XML)
        {
            trace("节点", id, "创建成功!");
            super();
            
            _id = id;
            _data = data;
            _children = new Array();
            _parent   = new Array();
            icons = new Icons();
            
            _lines = new Array();
            
            _ox = _data.@x;
            _oy = _data.@y;
            
            nodeIcon = new Image();
            nodeTitle = new Label();
            effect = new Move(this);
            zoom = new Zoom(this);
            proxy = new NodeProxy(Name);
            blinkBot = new Glow(nodeIcon);
            blinkBot.alphaFrom = BLINK_ALPHA_FROM;
            blinkBot.alphaTo = BLINK_ALPHA_TO;
            blinkBot.blurXFrom = blinkBot.blurYFrom = BLINK_STRENGTH_FROM;
            blinkBot.blurXTo = blinkBot.blurYTo = BLINK_STRENGTH_TO;
            blinkBot.repeatCount = 2;
            blinkBot.repeatDelay = Math.random() * 1000 + 2000;
            _scale = 1;
            effect.addEventListener(EffectEvent.EFFECT_END, 
                                    function():void
                                    {
                                        dispatchEvent(new EffectEvent(EffectEvent.EFFECT_END, true));
                                    });
                                    
            effect.addEventListener(EffectEvent.EFFECT_START, 
                                    function():void
                                    {
                                        dispatchEvent(new EffectEvent(EffectEvent.EFFECT_START, true));
                                    });
            
            doubleClickEnabled = true;

            addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
            addEventListener(MouseEvent.MOUSE_UP,   mouseUpHandler);
            addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
            addEventListener(MouseEvent.MOUSE_OUT,  mouseOutHandler);
            addEventListener(MouseEvent.DOUBLE_CLICK, doubleClickHandler);
        }
        
        /////////////////////////////////////
        // super functions
        /////////////////////////////////////
        /**
         * 创建子元素
         * */
        override protected function createChildren():void{
        	super.createChildren();
        	
        	var tBlink:String = _data.@blink;
        	tBlink = tBlink.replace(/#|0x/ig, '');
            Blink = '' == tBlink ? -1 : parseInt(tBlink, 16) ;
        	
            toolTip = _data.@describe;
            setStyle("horizontalAlign","center");
            
            nodeIcon.source = icons.getIcon(_data.@type);
            addChild(nodeIcon);
            
            nodeTitle.minWidth = 60;
            nodeTitle.maxWidth = 70;
            nodeTitle.setStyle("textAlign", "center");
            nodeTitle.text = _data.@title;
            addChild(nodeTitle);
         
            nodeIcon.addChild(proxy);
            proxy.visible = false;
            
//            effect.easingFunction = Elastic.easeOut;
            
            checkChildMap();

            setStyle("borderStyle", "inside");
            setStyle("borderThickness", 0);
            setStyle("cornerRadius", CORNET_RADIUS);
            setStyle("backgroundAlpha", BG_ALPHA_NORMAL);
            
            setStyle("paddingTop", 3);
            setStyle("paddingRight", 3);
            setStyle("paddingBottom", 3);
            setStyle("paddingLeft", 3);
            
        }
        
        /**
         * 更新可视列表
         * */
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
        	super.updateDisplayList(unscaledWidth, unscaledHeight);
        	
            proxy.x = nodeIcon.contentWidth / 2;
            proxy.y = nodeIcon.contentHeight / 2;
        }
        
        //////////////////////////////////////
        // public functions
        //////////////////////////////////////
        /**
         * 添加子节点
         * */
        public function addSubNode(node:INode):Boolean
        {
            if(node is Node && _children.indexOf(node) === -1)
            {
                trace("成功:",Name,"->",node.Name);
                _children.push(node);
                return true;
            }
            else
            {
                return false;
            }
        }
        
        public function removeSubNode(node:INode):Boolean
        {
        	return (node is Node) && _children.splice(_children.indexOf(node), 1);
        }
        
        /**
         * 添加父节点
         * */
        public function addParentNode(node:INode):Boolean
        {
            if(node is Node && _parent.indexOf(node) === -1)
            {
                trace("成功:",Name,"<-",node.Name);
                _parent.push(node);
                return true;
            }
            else
            {
                return false;
            }
        }
        
        public function removeParentNode(node:INode):Boolean{
            return (node is Node) && _parent.splice(_parent.indexOf(node), 1);
        }
        
        /**
         * 判断是否拥有子节点
         * */
        public function hasChild():Boolean{
            return _children.length > 0;
        }
        
        /**
         * 判断是否拥有父节点
         * */
        public function hasParent():Boolean{
            return _parent.length > 0;
        }
        
        /**
         * 移动到指定位置
         * */
        public function moveTo(xv:Number, yv:Number):void{
            effect.end();
            effect.xTo = xv;
            effect.yTo = yv;
            effect.play();
//            _endX = xv;
//            _endY = yv;
            dispatchEvent(new TopoEvent(TopoEvent.NODE_CHANGE));
        }
        
        /**
         * 移动以指定偏移量
         * */
        public function moveBy(xv:Number, yv:Number):void{
            effect.xTo = x;
            effect.yTo = y;
            effect.end();
            effect.xTo += xv;
            effect.yTo += yv;
            effect.play();
//            _endX = x + xv;
//            _endY = y + yv;
            dispatchEvent(new TopoEvent(TopoEvent.NODE_CHANGE));
        }
        
        /**
         * 添加连线
         * */
        public function pushLine(line:Line):void{
        	if (_lines.indexOf(line) === -1)
        	{
        	   _lines.push(line);
        	}
        }
        
        /**
         * 取得连线数组
         * */
        public function getLines():Array{
        	return _lines;
        }
        
        /**
         * 检测节点与该节点关系(是否是节点自己或是否包含在子节点和父节点中)
         * */
        public function checkNode(node:Node):Boolean
        {
        	return this == node || _children.indexOf(node) >= 0 || _parent.indexOf(node) >= 0;
        }
        
        ////////////////////////////////////////
        // getter & setter
        ////////////////////////////////////////
        public function set editable(able:Boolean):void
        {
        	_editable = able;
        }
        
        public function get editable():Boolean
        {
        	return _editable;
        }
        
        public function get Id():uint
        {
            return _id;
        }
        
        public function set Name(s:Number):void
        {
        	_editable && (_data.@id = s) && dispatchEvent(new TopoEvent(TopoEvent.NODE_CHANGE));;
        }
        
        public function get Name():Number
        {
            return _data.@id;
        }
        
        public function set Title(s:String):void
        {
            if (_editable && (_data.@title != s))
            {
            	_data.@title = s;
            	nodeTitle.text = s;
                dispatchEvent(new TopoEvent(TopoEvent.NODE_CHANGE));
            }
        }
        
        public function get Title():String
        {
            return _data.@title;
        }
        
        public function set Type(s:String):void
        {
            if (_editable && (_data.@type != s))
            {
                _data.@type = s;
                nodeIcon.source = icons.getIcon(s);
                dispatchEvent(new TopoEvent(TopoEvent.NODE_CHANGE));
            }
        }
        
        public function get Type():String
        {
            return _data.@type;
        }
        
        public function set Describe(s:String):void
        {
            if (_editable && (_data.@describe != s))
            {
                _data.@describe = s;
                toolTip = s;
                dispatchEvent(new TopoEvent(TopoEvent.NODE_CHANGE));
            }
        }
        
        public function get Describe():String
        {
            return _data.@describe;
        }
        
        public function get endX():Number
        {
            return effect.xTo;
        }
        
        public function get endY():Number
        {
            return effect.yTo;
        }
        
        public function get Blink():int
        {
            return _blink;
        }
        
        public function set Blink(b:int):void
        {
            if (_blink != b)
            {
                _blink = b;
                if (-1 == b)
                {
                    // 取消闪烁
                    trace("clean blink");
                    blinkBot.removeEventListener(EffectEvent.EFFECT_END, blinkLoopHandler);
                }
                else
                {
                    // 闪烁处理
                    trace("flash");
                    blinkBot.color = b;
                    blinkBot.removeEventListener(EffectEvent.EFFECT_END, blinkLoopHandler);
                    blinkBot.addEventListener(EffectEvent.EFFECT_END, blinkLoopHandler);
                    blinkBot.end();
                    blinkBot.play();
                }
            }
        }
        
        public function set ChildMapId(mapId:String):void
        {
            if (_editable && (_data.@childMapId != mapId))
            {
                checkChildMap();
                _data.@childMapId = mapId;
                dispatchEvent(new TopoEvent(TopoEvent.NODE_CHANGE));
            }
        }
        
        public function get ChildMapId():String
        {
            return _data.@childMapId;
        }
        
        public function get ResId():String
        {
            return _data.@resId;
        }
        
        public function set ResId(resId:String):void
        {
            if (_editable && (_data.@resId != resId))
            {
                _data.@resId = resId;
                dispatchEvent(new TopoEvent(TopoEvent.NODE_CHANGE));
            }
        }
        
        public function get Data():XML
        {
        	_data.@x = x.toFixed(2);
        	_data.@y = y.toFixed(2);
        	_data.@blink = _blink.toString(16);
        	return _data;
        }
        
        public function get showTitle():Boolean
        {
            return _showTitle;
        }
        
        public function set showTitle(s:Boolean):void
        {
            if (s != _showTitle)
            {
                _showTitle = s;
                setNodeTitle(s);
            }
        }
        
        public function get ox():Number
        {
        	return _ox;
        }
        
        public function get oy():Number
        {
        	return _oy;
        }
        
        public function get oldWidth():Number
        {
            return unscaledWidth;
        }
        
        public function get oldHeight():Number
        {
            return unscaledHeight;
        }
        
        public function set realScale(s:Number):void
        {
            if (_editable && s != _scale)
            {
                _scale = s;
                setNodeTitle(s >= 1 && _showTitle);
                zoom.end();
                zoom.zoomWidthTo = s;
                zoom.zoomHeightTo = s;
                zoom.play();
            }
        }
        
        public function get realScale():Number
        {
            return _scale;
        }
        
        /**
         * 子节点集合
         * */
        public function get Children():Array
        {
            return _children;
        }
        
        /**
         * 父节点集合
         * */
        public function get Parent():Array
        {
            return _parent;
        }
        
        /**
         * 连线连接点 x 坐标
         * */
        public function get cx():Number
        {
            return x + width / 2;
        }
        
        /**
         * 连线连接点 y 坐标
         * */
        public function get cy():Number
        {
            return y + nodeIcon.contentHeight * scaleY / 2;
        }
        
        public function get isSelected():Boolean
        {
        	return _isSelected;
        }
        
        public function set isSelected(s:Boolean):void
        {
        	_isSelected = s;
        	s? setSelectStyle(): setNormalStyle();
        }
        
        /////////////////////////////////////////
        // private functions
        /////////////////////////////////////////
        /**
         * 普通样式
         * */
        private function setNormalStyle():void
        {
            setStyle("borderThickness", 0);
            setStyle("backgroundColor", BG_COLOR);
            setStyle("backgroundAlpha", BG_ALPHA_NORMAL);
        }
        
        /**
         * Over 样式
         * */
        private function setOverStyle():void
        {
            setStyle("borderThickness", 1);
            setStyle("backgroundColor", BG_COLOR);
            setStyle("backgroundAlpha", BG_ALPHA_OVER);
        }
        
        /**
         * 选中样式
         * */
        private function setSelectStyle():void
        {
            setStyle("borderThickness", 1);
            setStyle("backgroundColor", BG_COLOR);
            setStyle("backgroundAlpha", BG_ALPHA_SELECT);
        }
        
        /**
         * Super 样式
         * */
        private function setSuperStyle():void
        {
            setStyle("borderThickness", 1);
            setStyle("backgroundColor", BG_COLOR);
            setStyle("backgroundAlpha", BG_ALPHA_SUPER);
        }
        
        /**
         * Down 样式
         * */
        private function setDownStyle():void
        {
            setStyle("borderThickness", 1);
            setStyle("backgroundColor", BG_COLOR_DOWN);
            setStyle("backgroundAlpha", BG_ALPHA_SELECT);
        }
        
        private function setNodeTitle(s:Boolean):void
        {
            if (getChildren().indexOf(nodeTitle) === -1)
            {
                s && addChild(nodeTitle) && (toolTip = Describe);
            }
            else
            {
                !s && removeChild(nodeTitle) && (toolTip = "<" + Title + ">\n" + Describe);
            }
        }
        
        //////////////////////////////
        // handlers
        //////////////////////////////
        
        private function mouseDownHandler(evt:MouseEvent):void
        {
        	_isDown = true;
            setDownStyle();
        }
        
        private function mouseUpHandler(evt:MouseEvent):void
        {
            _isDown = false;
            setSuperStyle();
            _editable && dispatchEvent(new TopoEvent(TopoEvent.NODE_CLICK));
        }
        
        private function mouseOverHandler(evt:MouseEvent):void
        {
        	_editable && (proxy.visible = true);
            nodeIcon.setChildIndex(proxy, 1);
            _isDown? setDownStyle(): _isSelected? setSuperStyle(): setOverStyle();
            
            try
            {
                _editable && (parent as Graph).setNodeToTop(this);
            }
            catch(e:Error)
            {
            	// nothing
            }
            // 配合右键的事件
            var topoEvt:TopoEvent = new TopoEvent(TopoEvent.OVER_NODE);
            topoEvt.node = this;
            dispatchEvent(topoEvt);
        }
        
        private function mouseOutHandler(evt:MouseEvent):void
        {
            _editable && (proxy.visible = false);
            _isSelected? setSelectStyle(): setNormalStyle();
            // 配合右键的事件
            var topoEvt:TopoEvent = new TopoEvent(TopoEvent.OUT_NODE);
            topoEvt.node = null;
            dispatchEvent(topoEvt);
        }
        
        private function doubleClickHandler(evt:MouseEvent):void
        {
            dispatchEvent(new TopoEvent(TopoEvent.NODE_DOUBLE_CLICK));
        }
        
        /**
         * 闪烁循环
         * */
        private function blinkLoopHandler(event:EffectEvent):void{
            event.target.play();
        }
        
        /**
         * 检测 childMap, 改变样式
         * */
        private function checkChildMap():void
        {
            nodeTitle.setStyle("fontWeight", ChildMapId.length > 0 ? "bold" : "");
            nodeTitle.text = (ChildMapId.length > 0 ? "*" : "") + Title;
        }
    }
}