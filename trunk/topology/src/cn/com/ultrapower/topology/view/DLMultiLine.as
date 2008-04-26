package cn.com.ultrapower.topology.view
{
    import flash.geom.Point;
    
    public class DLMultiLine implements IDrawLine
    {
        private const NAME:String = "DLMultiLine";
        // 弯曲点百分比
        private const PRE_LENGTH:Number = .2;
        // 弯曲点偏移量
        private const PRE_STEP:Number = 15;
        // 弯曲点
        private var _p1:Point = new Point();
        private var _p2:Point = new Point();
        // 
        private var _index:int = 0;
        private var _count:int = 2;
        
        // 决定弯曲方向
        private var _positive:int = 1;
        
        private var _line:Line;
        
        public function DLMultiLine(line:Line)
        {
            _line = line;
        }
        
        public function refresh(bgAlpha:Number=0):void
        {
            var offset:Number = PRE_STEP * Math.ceil(_index / 2);
            (0 == _index % 2) && (offset *= -1);
            (0 == _count % 2) && (offset -= PRE_STEP / 2);
            _p1 = getPointInfo(_line.x1, _line.y1, _line.x2, _line.y2, offset, 1);
            _p2 = getPointInfo(_line.x2, _line.y2, _line.x1, _line.y1, offset, -1);
            _line.graphics.clear();
            _line.graphics.lineStyle(_line.lineWidth, _line.color);
            _line.graphics.moveTo(_line.x1, _line.y1);
            _line.graphics.lineTo(_p1.x, _p1.y);
            _line.graphics.lineTo(_p2.x, _p2.y);
            _line.graphics.lineTo(_line.x2, _line.y2);
            _line.graphics.lineStyle(_line.BG_WIDTH_OFFSET + _line.lineWidth, _line.color, _line.isSelected && bgAlpha == 0 ? _line.BG_ALPHA_SELECT : bgAlpha);
            _line.graphics.lineTo(_p2.x, _p2.y);
            _line.graphics.lineTo(_p1.x, _p1.y);
            _line.graphics.lineTo(_line.x1, _line.y1);
            
            redrawArrow();
        }
        
        
        /**
         * 重绘 arrow
         * */
        public function redrawArrow():void
        {
            var baseRotation:Number;
            _line.arrow1.draw();
            _line.arrow2.draw();
            _line.arrow1.move(_p1.x + (_p2.x - _p1.x) * .2, _p1.y + (_p2.y - _p1.y) * .2);
            _line.arrow2.move(_p1.x + (_p2.x - _p1.x) * .8, _p1.y + (_p2.y - _p1.y) * .8);
            baseRotation = Math.atan2(_p2.y - _p1.y , _p2.x - _p1.x);
            _line.arrow1.rotation = baseRotation * 180 / Math.PI + _line.ra1;
            _line.arrow2.rotation = baseRotation * 180 / Math.PI + _line.ra2;
        }
        
        private function getPointInfo(x1:Number, y1:Number, 
                                      x2:Number, y2:Number, 
                                      o:Number, s:int):Point
        {
            var _x:Number = x2 - x1;
            var _y:Number = y2 - y1;
            var _l:Number = Math.pow(_x * _x + _y * _y, 0.5) * PRE_LENGTH;
            var _r:Number = Math.pow(_l * _l + o * o, 0.5);
            var ra:Number = Math.atan2(_x, _y);
            var rb:Number = Math.atan2(o, _l);
            
            var tp:Point = new Point(x1 + _r * Math.sin(ra + rb * s * _positive), y1 + _r * Math.cos(ra + rb * s * _positive));
            return tp;
        }
        
        ////////////////////////////////
        // getter & setter
        ////////////////////////////////
        
        public function set index(ind:int):void
        {
            _index = ind;
            refresh();
        }
        
        public function get index():int
        {
            return _index;
        }
        
        public function set count(c:int):void
        {
            _count = c;
            refresh();
        }
        
        public function set positive(pos:Boolean):void
        {
            _positive = pos ? 1 : -1;
            refresh();
        }
        
        public function get name():String
        {
            return NAME;
        }
    }
}