package cn.com.ultrapower.topology.view
{
    import flash.display.CapsStyle;
    import flash.display.JointStyle;
    import flash.display.LineScaleMode;
    import flash.display.Shape;

    public class Arrow extends Shape
    {
        private const A_BASE:Number = 7;
        
        private var _width:uint = 1;
        private var _color:uint;
        private var _type:uint; // 类型: 0 1
        private var _area:uint;
        
        private var _isChanged:Boolean = true;
        
        public function Arrow(color:uint, width:uint = 1, type:uint = 0)
        {
            super();
            
            lineWidth = width;
            _color = color;
            _type = type;
            
            draw();
        }

        ////////////////////////////////
        // public functions
        ////////////////////////////////
        
        /**
         * 绘制
         * */
        public function draw():void
        {
            if (_isChanged)
            {
                graphics.clear();
                graphics.lineStyle(_width, _color, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.MITER);
                if (_type == 0)
                {
                    // 线型
                    drawArrowLines();
                }
                else
                {
                    // 实心
                    graphics.beginFill(_color);
                    drawArrowLines();
                    graphics.endFill();
                }
                _isChanged = false;
            }
        }
        
        public function move(_x:Number, _y:Number):void
        {
            x = _x;
            y = _y;
        }
        
        //////////////////////////////////
        // getter & setter
        //////////////////////////////////
        
        public function set color(c:uint):void
        {
            if (_color != c)
            {
                _color = c;
                _isChanged = true;
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
                _width = w <= 0 ? 1 : w;
                _area = A_BASE + _width * (1 + Math.pow(_width, 1/5));
                _isChanged = true;
            }
        }
        
        public function set type(t:uint):void
        {
            if (_type != t)
            {
                _type = t;
                _isChanged = true;
            }
        }
        //////////////////////////////////
        // private functions
        //////////////////////////////////
        
        private function drawArrowLines():void
        {
            this.graphics.moveTo(-_area / 2, _area / 2);
            this.graphics.lineTo(_area / 2, 0);
            this.graphics.lineTo(-_area / 2, -_area / 2);
        }
    }
}