package cn.com.ultrapower.topology.event
{
    import cn.com.ultrapower.topology.view.Line;
    import cn.com.ultrapower.topology.view.Node;
    
    import flash.events.EventDispatcher;

    public class TopoEvent extends EventDispatcher
    {
        public static const NODE_CLICK:String = "nodeClick";
        public static const LINE_CLICK:String = "lineClick";
        public static const GRAPH_CLICK:String = "graphClick";
        public static const GRAPH_CHANGED:String = "graphChanged";
        public static const NODE_DOUBLE_CLICK:String = "nodeDoubleClick";
        
        private static var _object:TopoEvent;
        
        private var _curNode:Node;
        private var _curLine:Line;
        
        /**
         * 保持 TopoEvent 唯一实例
         * */
        public static function getEvent():TopoEvent{
        	if (!_object){
        		_object = new TopoEvent();
        	}
        	return _object;
        }
        
        public function get curNode():Node{
            return _curNode;
        }
        
        public function set curNode(node:Node):void{
            _curNode = node;
        }
        
        public function get curLine():Line{
            return _curLine;
        }
        
        public function set curLine(line:Line):void{
            _curLine = line;
        }
    }
}