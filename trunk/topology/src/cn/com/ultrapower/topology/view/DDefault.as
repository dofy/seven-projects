package cn.com.ultrapower.topology.view
{
	public class DDefault implements IDraw
	{
		public function DDefault()
		{
			super();
		}

		public function makeTreeForm(graph:Graph, treeArray:Array):void
		{
			trace("******* Draw Default *******");
			var node:Node;
			for (var i:uint = 0; i < treeArray.length; i++)
			{
				for (var j:uint = 0; j < treeArray[i].length; j++)
				{
                    node = treeArray[i][j];
					node.moveTo(node.ox, node.oy);
				}
			}
		}
		
	}
}