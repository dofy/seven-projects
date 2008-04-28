package cn.com.ultrapower.topology.view
{
    import flash.geom.Rectangle;
    
	public class DGroup implements IDraw
	{
	    private var ox:Number;
	    private var oy:Number;
	    private var r:Number;
	    
		public function DGroup()
		{
		}

		public function makeTreeForm(graph:Graph, treeArray:Array):void
		{
			trace("******* Draw Group *******");
			var node:Node;
			var len:int = graph.nodeLength;
			var lvl:int = treeArray.length;
			var rc:Rectangle = graph.getBounds(graph);
			ox = rc.width / 2 - 30;
			oy = rc.height / 2 - 30;
			r = Math.min(rc.width, rc.height) / lvl - 100;

            for (var i:uint = 0; i < treeArray.length; i++)
            {
                trace("*********************");
                switch (i)
                {
                    // 根节点
                    case 0:
                    {
                        node = treeArray[i][0];
                        node.moveTo(ox, oy);
                        break;
                    }
                    case 1:
                    {
                        roundPosition(treeArray[i]);
                        break;
                    }
                    default:
                    {
                        // 先整理数组
                        
                        // 执行排列
                        sectorPosition(treeArray[i], null, i);
                        break;
                    }
                }
            }
		}
		
		private function roundPosition(nodes:Array):void
		{
            var tnode:Node;
            var len:int = nodes.length;
            var ra:Number = 0;
            var pa:Number = 360 / len;
            
            for (var cind:uint = 0; cind < len; cind++)
            {
                tnode = nodes[cind];
                tnode.moveTo(ox + Math.cos(a2r(ra)) * r, oy + Math.sin(a2r(ra)) * r);
                ra += pa;
            }
		}
		
		private function sectorPosition(nodes:Array, pNode:Node, lv:int):void
		{
		    
		}
		
		private function a2r(a:Number):Number
		{
		    return Math.PI * a / 180;
		}
		
	}
}