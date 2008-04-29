package cn.com.ultrapower.topology.view
{
    import flash.geom.Rectangle;
    
	public class DGroup implements IDraw
	{
	    private var ox:Number;
	    private var oy:Number;
	    private var r:Number;
	    private var lvl:int;
	    
		public function DGroup()
		{
		}

		public function makeTreeForm(graph:Graph, treeArray:Array):void
		{
			trace("******* Draw Group *******");
			var node:Node;
			var len:int = graph.nodeLength;
			
			var parentNodes:Array = new Array();
            var currentNodes:Array = new Array();
            var drawNodes:Array = new Array();
            
            lvl = treeArray.length;
			
			ox = graph.width / 2 - 30;
			oy = graph.height / 2 - 30;
			r = (Math.min(graph.width, graph.height) / 2 - 70) / (lvl - 1);

            for (var i:uint = 0; i < treeArray.length; i++)
            {
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
                        /** TODO: 先整理数组 */
                        parentNodes = ([]).concat(treeArray[i-1]);
                        currentNodes = ([]).concat(treeArray[i]);
                        // 先寻父节点
                        for (var j:int = 0; j < parentNodes.length; j++)
                        {
                            // 临时描述数组
                            drawNodes = [];
                            
                            for (var k:int = 0; k < currentNodes.length; k++)
                            {
                                if (currentNodes[k].Parent.indexOf(parentNodes[j]) !== -1 ||
                                    currentNodes[k].Children.indexOf(parentNodes[j]) !== -1)
                                {
                                    drawNodes.push(currentNodes[k]);
                                    currentNodes.splice(k, 1);
                                    k--;
                                }
                            }
                            if (drawNodes.length == 0)
                            {
                                drawNodes = ([]).concat(currentNodes);
                                sectorPosition(drawNodes, null);
                            }
                            else
                            {
                                sectorPosition(drawNodes, parentNodes[j]);
                            }
                            
                        }
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
		
		private function sectorPosition(nodes:Array, pNode:Node):void
		{
            var tnode:Node;
            var len:int = nodes.length;
            var ra:Number;
            var pa:Number;
            
            var tr:Number;
            var tox:Number;
            var toy:Number;
            
            if (null == pNode)
            {
                ra = 0;
                pa = 360 / len;
                tr = r * lvl - r;
                tox = ox;
                toy = oy;
            }
            else
            {
                ra = r2a(Math.atan2(pNode.endY - oy, pNode.endX - ox));
                len > 1 && (ra -= 80);
                pa = 160 / (len - 1);
                
                tr = r;
                tox = pNode.endX;
                toy = pNode.endY;
            }
            
            for (var cind:uint = 0; cind < len; cind++)
            {
                tnode = nodes[cind];
                tnode.moveTo(tox + Math.cos(a2r(ra)) * tr, toy + Math.sin(a2r(ra)) * tr);
                ra += pa;
            }
		}
		
		private function a2r(a:Number):Number
		{
		    return Math.PI * a / 180;
		}
		
		private function r2a(a:Number):Number
		{
		    return 180 * a / Math.PI;
		}
		
	}
}