package cn.com.ultrapower.topology.event
{
    import flash.events.Event;
    
    public class TopoEvent extends Event
    {
        public static const NODE_CLICK:String = "nodeClick";
        public static const LINE_CLICK:String = "lineClick";
        public static const GRAPH_CLICK:String = "graphClick";
        public static const GRAPH_CHANGED:String = "graphChanged";
        public static const NODE_DOUBLE_CLICK:String = "nodeDoubleClick";
        
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