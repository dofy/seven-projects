package cn.com.ultrapower.topology.view
{
    import flash.display.Shape;

    public class Arrow extends Shape
    {
        private const A_BASE:uint = 9;
        
        private var _width:uint;
        private var _color:uint;
        private var _type:uint; // 类型: 0 1
        private var _area:uint;
        
        private var _isChanged:Boolean = true;
        
        public function Arrow(color:uint, width:uint = 1, type:uint = 0)
        {
            super();
            
            _color = color;
            _width = width;
            _type = type;
            
            _area = A_BASE + _width;
            
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
                this.graphics.clear();
                this.graphics.lineStyle(_width, _color, 1);
                if (_type == 0)
                {
                    // 线型
                    drawArrowLines();
                }
                else
                {
                    // 实心
                    this.graphics.beginFill(_color);
                    drawArrowLines();
                    this.graphics.endFill();
                }
                _isChanged = false;
            }
        }
        
        public function move(_x:Number, _y:Number):void
        {
            this.x = _x;
            this.y = _y;
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
        
        public function set lineWidth(w:uint):void
        {
            if (_width != w)
            {
                _width = w <= 0? 1 : w;
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