package cn.com.ultrapower.topology.view
{
    import cn.com.ultrapower.topology.event.TopoEvent;
    
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    import mx.binding.utils.BindingUtils;
    import mx.binding.utils.ChangeWatcher;
    import mx.core.UIComponent;
    import mx.effects.Glow;
    import mx.events.EffectEvent;
    
    public class Line extends UIComponent
    {
        public const BG_ALPHA_NORMAL:Number = 0;
        public const BG_ALPHA_OVER:Number   = 0.15;
        public const BG_ALPHA_SELECT:Number = 0.3;
        public const BG_ALPHA_SUPER:Number  = 0.5;
        
        public const BG_WIDTH_OFFSET:uint = 7;
        
        private const BLINK_ALPHA_FROM:Number  = 1;
        private const BLINK_ALPHA_TO:Number  = 1;
        private const BLINK_STRENGTH_FROM:Number  = 15;
        private const BLINK_STRENGTH_TO:Number  = 0;
        
        private var _id:uint;
        // 节点坐标点
        private var _x1:Number;
        private var _y1:Number;
        private var _x2:Number;
        private var _y2:Number;
        
        private var _x1w:ChangeWatcher;
        private var _y1w:ChangeWatcher;
        private var _x2w:ChangeWatcher;
        private var _y2w:ChangeWatcher;
        
        private var _width:uint;
        private var _color:uint;
        private var _type:uint;
        private var _mode:uint;
        
        private var _blink:int;      // 闪烁颜色
        private var blinkBot:Glow;   // 闪烁特效
        
        // 起始节点
        private var _fromNode:INode = null;
        private var _toNode:INode   = null;
        
        private var _data:XML;
        
        private var _editable:Boolean = false;  // 编辑模式
        private var _canRefresh:Boolean = false;
        
        private var _isSelected:Boolean; // 被选中
        private var _isDown:Boolean;     // 鼠标按下
        
        private var _arrow1:Arrow;     // from 端箭头
        private var _arrow2:Arrow;     // to   端箭头
        private var _ra1:uint;        // _arrow1 增补角度
        private var _ra2:uint;        // _arrow2 增补角度
        
        private var drawBot:IDrawLine;
        
        public function Line(id:uint, data:XML)
        {
            trace("连线", id, "创建成功!");
            _id = id;
            _data = data? data: <line fromId="" toId="" color="000000" width="1" arrowType="0" arrowMode="0"/>;
            
            blinkBot = new Glow(this);
            blinkBot.alphaFrom = BLINK_ALPHA_FROM;
            blinkBot.alphaTo = BLINK_ALPHA_TO;
            blinkBot.blurXFrom = blinkBot.blurYFrom = BLINK_STRENGTH_FROM;
            blinkBot.blurXTo = blinkBot.blurYTo = BLINK_STRENGTH_TO;
            blinkBot.repeatCount = 2;
            blinkBot.repeatDelay = Math.random() * 1000 + 2000;
                    
            drawBot = new DLLine(this);
            
            addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
            addEventListener(MouseEvent.MOUSE_UP,   mouseUpHandler);
            addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
            addEventListener(MouseEvent.MOUSE_OUT,  mouseOutHandler);
        }
        
        override protected function createChildren():void
        {
            super.createChildren();
            
            toolTip = _data.@describe;
            _arrow1 = new Arrow(_color, _width);
            _arrow2 = new Arrow(_color, _width);
            
            addChild(_arrow1);
            addChild(_arrow2);
            
            var tBlink:String = _data.@blink;
            tBlink = tBlink.replace(/#|0x/ig, '');
            Blink = '' == tBlink ? -1 : parseInt(tBlink, 16) ;
            
            var tColor:String = _data.@color;
            color = parseInt(tColor.replace(/#|0x/ig, ''), 16) ;
            
            lineWidth = parseInt(_data.@width);
            arrowType = parseInt(_data.@arrowType);
            arrowMode = parseInt(_data.@arrowMode);
        }
        
        override protected function childrenCreated():void
        {
            super.childrenCreated();
            _canRefresh = true;
        }
        
        //////////////////////////////////
        // public functions
        //////////////////////////////////
        
        /**
         * 绑定节点
         * */
        public function bindNodes(fromNode:INode, toNode:INode):Boolean
        {
            return bindFromNode(fromNode) && bindToNode(toNode);
        }
        
        /**
         * 绑定始节点
         * */
        public function bindFromNode(node:INode):Boolean
        {
            if(node)
            {
                _fromNode = node;
                _x1w && _x1w.unwatch();
                _y1w && _y1w.unwatch();
                _x1w = BindingUtils.bindProperty(this, "x1", node, {name: "x", getter: function():Number{return node.cx;}});
                _y1w = BindingUtils.bindProperty(this, "y1", node, {name: "y", getter: function():Number{return node.cy;}});
                trace("始节点绑定成功:");
                return true;
            }
            else
            {
                trace("始节点绑定失败!");
                return false;
            }
        }
        
        /**
         * 绑定终节点
         * */
        public function bindToNode(node:INode):Boolean
        {
            if(node)
            {
                _toNode = node;
                _x2w && _x2w.unwatch();
                _y2w && _y2w.unwatch();
                _x2w = BindingUtils.bindProperty(this, "x2", node, {name: "x", getter: function():Number{return node.cx;}});
                _y2w = BindingUtils.bindProperty(this, "y2", node, {name: "y", getter: function():Number{return node.cy;}});
                trace("终节点绑定成功:", node.Name);
                return true;
            }
            else
            {
                trace("终节点绑定失败!");
                return false;
            }
        }
        
        public function setDrawBot(db:IDrawLine):void
        {
            drawBot = db;
            drawBot.refresh();
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
        
        public function set x1(n:Number):void
        {
            //trace(_id, "x1:", n);
            _x1 = n;
            refresh();
        }
        
        public function get x1():Number
        {
            return _x1;
        }
        
        public function set y1(n:Number):void
        {
            //trace(_id, "y1:", n);
            _y1 = n;
            refresh();
        }
        
        public function get y1():Number
        {
            return _y1;
        }
        
        public function set x2(n:Number):void
        {
            //trace(_id, "x2:", n);
            _x2 = n;
            refresh();
        }
        
        public function get x2():Number
        {
            return _x2;
        }
        
        public function set y2(n:Number):void
        {
            //trace(_id, "y2:", n);
            _y2 = n;
            refresh();
        }
        
        public function get y2():Number
        {
            return _y2;
        }
        
        public function set Describe(s:String):void
        {
            if (_editable && (_data.@describe != s))
            {
                _data.@describe = s;
                toolTip = s;
                dispatchEvent(new TopoEvent(TopoEvent.LINE_CHANGE));
            }
        }
        
        public function get Describe():String
        {
            return _data.@describe;
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
        
        public function get ResId():String
        {
            return _data.@resId;
        }
        
        public function set ResId(resId:String):void
        {
            if (_editable && (_data.@resId != resId))
            {
                _data.@resId = resId;
                dispatchEvent(new TopoEvent(TopoEvent.LINE_CHANGE));
            }
        }
        
        public function set color(c:uint):void
        {
            if (_color != c)
            {
            	_color = c;
            	_arrow1.color = c;
            	_arrow2.color = c;
            	refresh();
                dispatchEvent(new TopoEvent(TopoEvent.LINE_CHANGE));
            }
        }
        
        public function get color():uint
        {
            return _color;
        }
        
        public function set lineWidth(w:uint):void
        {
            if (_width != w)
            {
                _width = w <= 0? 1 : w;
                _arrow1.lineWidth = _width;
                _arrow2.lineWidth = _width;
                refresh();
                dispatchEvent(new TopoEvent(TopoEvent.LINE_CHANGE));
            }
        }
        
        public function get lineWidth():uint
        {
            return _width;
        }
        
        public function get arrow1():Arrow
        {
            return _arrow1;
        }
        
        public function get arrow2():Arrow
        {
            return _arrow2;
        }
        
        public function get ra1():uint
        {
            return _ra1;
        }
        
        public function get ra2():uint
        {
            return _ra2;
        }
        
        public function set arrowType(t:uint):void
        {
            if (_type != t)
            {
                _type = t;
                _arrow1.type = t;
                _arrow2.type = t;
                redrawArrow();
                dispatchEvent(new TopoEvent(TopoEvent.LINE_CHANGE));
            }
        }
        
        public function get arrowType():uint
        {
            return _type;
        }
        
        public function set arrowMode(m:uint):void
        {
            if (_mode != m)
            {
                _mode = m;
                switch (m)
                {
                    case 1:
                    {
                        _ra1 = 0;
                        _ra2 = 180;
                        break;
                    }
                    case 2:
                    {
                        _ra1 = 180;
                        _ra2 = 0;
                        break;
                    }
                    default:
                    {
                        _mode = 0
                        _ra1 = _ra2 = 0;
                        break;
                    }
                }
                redrawArrow();
                dispatchEvent(new TopoEvent(TopoEvent.LINE_CHANGE));
            }
        }
        
        public function get arrowMode():uint
        {
            return _mode;
        }
        
        public function get Data():XML
        {
            _data.@fromId = _fromNode.Name;
            _data.@toId = _toNode.Name;
            _data.@color = _color.toString(16);
            _data.@width = _width;
            _data.@arrowType = _type;
            _data.@arrowMode = _mode;
            _data.@blink = _blink.toString(16);
        	return _data;
        }
        
        public function get fromNode():INode
        {
        	return _fromNode;
        }
        
        public function get toNode():INode
        {
        	return _toNode;
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
        
        public function set index(ind:int):void
        {
            drawBot.index = ind;
        }
        
        public function set count(len:int):void
        {
            drawBot.count = len;
        }
        
        public function set positive(pos:Boolean):void
        {
            drawBot.positive = pos;
        }
        
        /////////////////////////////////////////
        // protected functions
        /////////////////////////////////////////
        
        protected function refresh(bgAlpha:Number = 0):void
        {
            if (_canRefresh)
            {
                drawBot.refresh(bgAlpha);
                //trace("重绘连线", _id);
                /*
                graphics.clear();
                graphics.lineStyle(_width, _color);
                graphics.moveTo(_x1, _y1);
                graphics.lineTo(_x2, _y2);
                graphics.lineStyle(BG_WIDTH_OFFSET + _width, _color, _isSelected && bgAlpha == 0 ? BG_ALPHA_SELECT : bgAlpha);
                graphics.lineTo(_x1, _y1);
                redrawArrow();
                */
            }
        }
        
        /**
         * 重绘 arrow
         * */
        protected function redrawArrow():void
        {
            drawBot.redrawArrow();
            /*
            var baseRotation:Number;
            _arrow1.draw();
            _arrow2.draw();
            _arrow1.move(_x1 + (_x2 - _x1) * .4, _y1 + (_y2 - _y1) * .4);
            _arrow2.move(_x1 + (_x2 - _x1) * .6, _y1 + (_y2 - _y1) * .6);
            baseRotation = Math.atan2(_y2 - _y1 , _x2 - _x1);
            _arrow1.rotation = baseRotation * 180 / Math.PI + _ra1;
            _arrow2.rotation = baseRotation * 180 / Math.PI + _ra2;
            */
        }
        
        /////////////////////////////////////////
        // private functions
        /////////////////////////////////////////
        
        /**
         * 普通样式
         * */
        private function setNormalStyle():void
        {
            refresh(BG_ALPHA_NORMAL);
        }
        
        /**
         * Over 样式
         * */
        private function setOverStyle():void
        {
        	refresh(BG_ALPHA_OVER);
        }
        
        /**
         * 选中样式
         * */
        private function setSelectStyle():void
        {
        	refresh(BG_ALPHA_SELECT);
        }
        
        /**
         * Super 样式
         * */
        private function setSuperStyle():void
        {
        	refresh(BG_ALPHA_SUPER);
        }
        
        /**
         * Down 样式
         * */
        private function setDownStyle():void
        {
        	refresh(BG_ALPHA_SELECT);
        }
        
        private function mouseDownHandler(evt:Event):void
        {
            _isDown = true;
            _editable && setDownStyle();
        }
        
        private function mouseUpHandler(evt:Event):void
        {
            _isDown = false;
            _editable && setSuperStyle();
            
            dispatchEvent(new TopoEvent(TopoEvent.LINE_CLICK));
        }
        
        private function mouseOverHandler(evt:Event):void
        {
            _editable && (_isDown? setDownStyle(): _isSelected? setSuperStyle(): setOverStyle());
            // 配合右键的事件
            var topoEvt:TopoEvent = new TopoEvent(TopoEvent.OVER_LINE);
            topoEvt.line = this;
            dispatchEvent(topoEvt);
        }
        
        private function mouseOutHandler(evt:Event):void
        {
            _editable && (_isSelected? setSelectStyle(): setNormalStyle());
            // 配合右键的事件
            var topoEvt:TopoEvent = new TopoEvent(TopoEvent.OUT_LINE);
            topoEvt.line = null;
            dispatchEvent(topoEvt);
        }
        
        /**
         * 闪烁循环
         * */
        private function blinkLoopHandler(event:EffectEvent):void{
            event.target.play();
        }
    }
}