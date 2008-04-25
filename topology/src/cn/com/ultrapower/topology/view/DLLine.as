package cn.com.ultrapower.topology.view
{
    import flash.geom.Point;
    
    public class DLLine implements IDrawLine
    {
        private var _line:Line;
        public function DLLine(line:Line)
        {
            _line = line;
        }
        
        public function refresh(bgAlpha:Number=0):void
        {
            _line.graphics.clear();
            _line.graphics.lineStyle(_line.lineWidth, _line.color);
            _line.graphics.moveTo(_line.x1, _line.y1);
            _line.graphics.lineTo(_line.x2, _line.y2);
            _line.graphics.lineStyle(_line.BG_WIDTH_OFFSET + _line.lineWidth, _line.color, _line.isSelected && bgAlpha == 0 ? _line.BG_ALPHA_SELECT : bgAlpha);
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
            _line.arrow1.move(_line.x1 + (_line.x2 - _line.x1) * .4, _line.y1 + (_line.y2 - _line.y1) * .4);
            _line.arrow2.move(_line.x1 + (_line.x2 - _line.x1) * .6, _line.y1 + (_line.y2 - _line.y1) * .6);
            baseRotation = Math.atan2(_line.y2 - _line.y1 , _line.x2 - _line.x1);
            _line.arrow1.rotation = baseRotation * 180 / Math.PI + _line.ra1;
            _line.arrow2.rotation = baseRotation * 180 / Math.PI + _line.ra2;
        }
        
    }
}