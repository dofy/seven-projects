package cn.com.ultrapower.topology.view
{
    public class DLPolyline implements IDrawLine
    {
        private const NAME:String = "DLPolyline";
        public function DLPolyline()
        {
        }

        public function refresh(bgAlpha:Number=0):void
        {
        }
        
        public function redrawArrow():void
        {
        }
        
        ////////////////////////////////
        // getter & setter
        ////////////////////////////////
        
        public function set index(ind:int):void{}
        
        public function get index():int
        {
            return 0;
        }
        
        public function set count(c:int):void{}
        
        public function set positive(pos:Boolean):void{}
        
        public function get name():String
        {
            return NAME;
        }
        
    }
}