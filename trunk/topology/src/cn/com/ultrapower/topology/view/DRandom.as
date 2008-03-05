package cn.com.ultrapower.topology.view
{
	public class DRandom implements IDraw
	{
		public function DRandom()
		{
			super();
		}

		public function makeTreeForm(graph:Graph, treeArray:Array):void
		{
			trace("******* Draw Random *******");
			var node:Node;
			for (var i:uint = 0; i < treeArray.length; i++)
			{
				for (var j:uint = 0; j < treeArray[i].length; j++)
				{
                    node = treeArray[i][j];
					node.moveTo(Math.random() * graph.width, Math.random() * graph.height);
				}
			}
		}
		
	}
}