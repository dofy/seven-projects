package cn.com.ultrapower.topology.view
{
    import flash.geom.Rectangle;
    
	public class DTile implements IDraw
	{
		public function DTile()
		{
		}

		public function makeTreeForm(graph:Graph, treeArray:Array):void
		{
			trace("******* Draw Tile *******");
			var node:Node;
			
            var rc:Rectangle = graph.getBounds(graph);
			var len:int = graph.nodeLength;
			var ind:int = 0;
            var xc:int = Math.round(Math.pow(rc.width * len / rc.height, 0.5));
            var yc:int = Math.round(Math.pow(rc.height * len / rc.width, 0.5));
            var xStep:Number = rc.width / (xc + 2);
            var yStep:Number = rc.height / (yc + 2);
            for (var i:uint = 0; i < treeArray.length; i++)
            {
                for (var j:uint = 0; j < treeArray[i].length; j++)
                {
                    node = treeArray[i][j];
                    node.moveTo(xStep * (ind % xc + 1), yStep * (Math.floor(ind / xc) + 1));
                    ind++;
                }
            }
		}
		
	}
}