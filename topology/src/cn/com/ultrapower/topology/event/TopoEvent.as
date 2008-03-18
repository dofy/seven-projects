package cn.com.ultrapower.topology.event
{
    import cn.com.ultrapower.topology.view.Line;
    import cn.com.ultrapower.topology.view.Node;
    
    import flash.events.Event;
    
    public class TopoEvent extends Event
    {
        public static const NODE_CLICK:String = "nodeClick";
        public static const LINE_CLICK:String = "lineClick";
        public static const GRAPH_CLICK:String = "graphClick";
        
        public static const OVER_NODE:String = "overNode";
        public static const OUT_NODE:String = "outNode";
        public static const OVER_LINE:String = "overLine";
        public static const OUT_LINE:String = "outLine";
        
        public static const NODE_DOUBLE_CLICK:String = "nodeDoubleClick";
        
        public static const GRAPH_CHANGED:String = "graphChanged";
        public static const NODE_CHANGED:String = "nodeChanged";
        public static const LINE_CHANGED:String = "lineChanged";
        
        public var node:Node;
        public var line:Line;
        
        public function TopoEvent(type:String, bubbles:Boolean = true, 
                                    cancelable:Boolean = false)
        {
            super(type, bubbles, cancelable);
        }

        /**
         *  @private
         */
        override public function clone():Event
        {
            return new TopoEvent(type, bubbles, cancelable);
        }
    
    }
}