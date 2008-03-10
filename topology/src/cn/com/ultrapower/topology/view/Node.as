package cn.com.ultrapower.topology.view
{   
    import cn.com.ultrapower.topology.assets.Icons;
    import cn.com.ultrapower.topology.event.TopoEvent;
    
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    import mx.containers.VBox;
    import mx.controls.Image;
    import mx.controls.Label;
    import mx.effects.Move; 
    
    public class Node extends VBox implements INode
    {
        private const CORNET_RADIUS:uint     = 5;
        private const BORDER_THICKNESS:uint  = 1;
        private const BG_COLOR:Number        = 0xcccccc;
        private const BG_COLOR_DOWN:Number   = 0x5cc0ff;
        private const BG_ALPHA_NORMAL:Number = 0;
        private const BG_ALPHA_OVER:Number   = 0.5;
        private const BG_ALPHA_SELECT:Number = 0.7;
        private const BG_ALPHA_SUPER:Number  = 0.9;
        
        private var icons:Icons;          // 图标资源
        private var nodeIcon:Image;       // 图标
        private var nodeTitle:Label;      // 标题
        private var effect:Move;          // 动效
        private var proxy:NodeProxy;      // 节点代理
        
        private var _editable:Boolean = false;  // 编辑模式
        
        private var _children:Array; // 子节点集合
        private var _parent:Array;   // 父节点集合
        
        private var _lines:Array;    // 关联连线
        
        private var _id:uint;       // 数字 id
        
        private var _data:XML;      // XML 数据
        
        private var _ox:Number;  // 原始 x 坐标信息
        private var _oy:Number;  // 原始 y 坐标信息
        
        private var _isSelected:Boolean; // 节点被选中
        private var _isDown:Boolean;     // 鼠标按下
        
        private var topoEvt:TopoEvent = TopoEvent.getEvent();
        
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
            proxy = new NodeProxy(Name);
            
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
        	
            toolTip = _data.@describe;
            setStyle("horizontalAlign","center");
            
            nodeIcon.source = icons.getIcon(_data.@type);
            addChild(nodeIcon);
            
            nodeTitle.text = _data.@title;
            nodeTitle.maxWidth = 70;
            addChild(nodeTitle);
         
            nodeIcon.addChild(proxy);
            proxy.visible = false;
            
            //effect.easingFunction = Elastic.easeOut;

            setStyle("borderStyle", "solid");
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
        
        public function set Name(s:String):void
        {
        	_data.@id = s;
        }
        
        public function get Name():String
        {
            return _data.@id;
        }
        
        public function set Title(s:String):void
        {
        	_data.@title = s;
        	nodeTitle.text = s;
        }
        
        public function get Title():String
        {
            return _data.@title;
        }
        
        public function set Type(s:String):void
        {
            _data.@type = s;
            nodeIcon.source = icons.getIcon(s);
        }
        
        public function get Type():String
        {
            return _data.@type;
        }
        
        public function set Describe(s:String):void
        {
            _data.@describe = s;
            toolTip = s;
        }
        
        public function get Describe():String
        {
            return _data.@describe;
        }
        
        public function get Data():XML
        {
        	_data.@x = x.toFixed(2);
        	_data.@y = y.toFixed(2);
        	return _data;
        }
        
        public function get ox():Number
        {
        	return _ox;
        }
        
        public function get oy():Number
        {
        	return _oy;
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
            return x + width/2;
        }
        
        /**
         * 连线连接点 y 坐标
         * */
        public function get cy():Number
        {
            return y + nodeIcon.height/2;
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
            setStyle("borderThickness", BORDER_THICKNESS);
            setStyle("backgroundColor", BG_COLOR);
            setStyle("backgroundAlpha", BG_ALPHA_OVER);
        }
        
        /**
         * 选中样式
         * */
        private function setSelectStyle():void
        {
            setStyle("borderThickness", BORDER_THICKNESS);
            setStyle("backgroundColor", BG_COLOR);
            setStyle("backgroundAlpha", BG_ALPHA_SELECT);
        }
        
        /**
         * Super 样式
         * */
        private function setSuperStyle():void
        {
            setStyle("borderThickness", BORDER_THICKNESS);
            setStyle("backgroundColor", BG_COLOR);
            setStyle("backgroundAlpha", BG_ALPHA_SUPER);
        }
        
        /**
         * Down 样式
         * */
        private function setDownStyle():void
        {
            setStyle("borderThickness", BORDER_THICKNESS);
            setStyle("backgroundColor", BG_COLOR_DOWN);
            setStyle("backgroundAlpha", BG_ALPHA_SELECT);
        }
        
        private function mouseDownHandler(evt:Event):void
        {
        	_isDown = true;
            setDownStyle();
        }
        
        private function mouseUpHandler(evt:Event):void
        {
            _isDown = false;
            setSuperStyle();
            topoEvt.curNode = this;
            topoEvt.dispatchEvent(new Event(TopoEvent.NODE_CLICK));
        }
        
        private function mouseOverHandler(evt:Event):void
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
        }
        
        private function mouseOutHandler(evt:Event):void
        {
            _editable && (proxy.visible = false);
            _isSelected? setSelectStyle(): setNormalStyle();
        }
        
        private function doubleClickHandler(evt:Event):void
        {
            topoEvt.dispatchEvent(new Event(TopoEvent.NODE_DOUBLE_CLICK));
        }
    }
}