package cn.com.ultrapower.topology.tool
{
    import cn.com.ultrapower.topology.event.TopoEvent;
    import cn.com.ultrapower.topology.view.Graph;
    
    import flash.display.BitmapData;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    
    import mx.containers.Canvas;

    public class Airscape extends Canvas
    {
        private var _graph:Graph = new Graph();
        private var _mapbar:SelectRect = new SelectRect();
        
        private var _oldX:Number;
        private var _oldY:Number;
        
        public function Airscape()
        {
            super();
            
            verticalScrollPolicy = "off";
            horizontalScrollPolicy = "off";
            
            setStyle("backgroundColor", "#ffffff");
            
            addEventListener(MouseEvent.MOUSE_DOWN, mapMouseDownHandler);
            addEventListener(MouseEvent.MOUSE_UP, mapMouseUpHandler);
        }
        
        override protected function createChildren():void
        {
            super.createChildren();
            _mapbar.setStartPoint(0, 0);
            _mapbar.reDraw(100, 70);
            addChild(_mapbar);
        }
        
        //////////////////////////////
        // public functions
        //////////////////////////////
        
        
        //////////////////////////////
        // getter & setter
        //////////////////////////////
        
        [Bindable]
        public function set graph(g:Graph):void
        {
            _graph = g;
            _graph.addEventListener(TopoEvent.GRAPH_CHANGE, graphChangeHandler);
            refreshBitmap();
        }
        
        public function get graph():Graph
        {
            return _graph;
        }
        
        //////////////////////////////
        // private functions
        //////////////////////////////
        
        private function refreshBitmap():void
        {
            var rt:Rectangle = _graph.getAllArea();
            trace(">>>>>>>>>>>>", rt);
        }
        
        //////////////////////////////
        // handler functions
        //////////////////////////////
        
        private function mapMouseDownHandler(event:MouseEvent):void
        {
            if (event.target is SelectRect)
            {
                _oldX = mouseX;
                _oldY = mouseY;
                addEventListener(MouseEvent.MOUSE_MOVE, mapMouseMoveHandler);
                //_mapbar.startDrag();
            }
        }
        
        private function mapMouseUpHandler(event:MouseEvent):void
        {
            removeEventListener(MouseEvent.MOUSE_MOVE, mapMouseMoveHandler);
            //_mapbar.stopDrag();
        }
        
        private function mapMouseMoveHandler(event:MouseEvent):void
        {
            _mapbar.x += mouseX - _oldX;
            _mapbar.y += mouseY - _oldY;
            _oldX = mouseX;
            _oldY = mouseY;
            
            (_mapbar.x < 0 && (_mapbar.x = 0)) || ((_mapbar.x > width - _mapbar.width) && (_mapbar.x = width - _mapbar.width));
            (_mapbar.y < 0 && (_mapbar.y = 0)) || ((_mapbar.y > height - _mapbar.height) && (_mapbar.y = height - _mapbar.height));
        }
        
        private function graphChangeHandler(event:TopoEvent):void
        {
            refreshBitmap();
        }
    }
}