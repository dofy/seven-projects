package cn.com.ultrapower.topology.view
{
    import flash.geom.Rectangle;
    
	public class DRound implements IDraw
	{
		public function DRound()
		{
		}

		public function makeTreeForm(graph:Graph, treeArray:Array):void
		{
			trace("******* Draw Round *******");
			var node:Node;
			var len:int = graph.nodeLength;
			var ra:Number = 0;
			var pa:Number = 360 / len;
			var rc:Rectangle = graph.getBounds(graph);
			var ox:Number = rc.width / 2 - 30;
			var oy:Number = rc.height / 2 - 30;
			var r:Number = Math.min(rc.width, rc.height) / 2 - 100;
            for (var i:uint = 0; i < treeArray.length; i++)
            {
                for (var j:uint = 0; j < treeArray[i].length; j++)
                {
                    node = treeArray[i][j];
                    node.moveTo(ox + Math.cos(a2r(ra)) * r, oy + Math.sin(a2r(ra)) * r);
                    ra += pa;
                }
            }
		}
		
		private function a2r(a:Number):Number
		{
		    return Math.PI * a / 180;
		}
		
	}
}