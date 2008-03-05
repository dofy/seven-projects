package cn.com.ultrapower.topology.view
{
	public class DTree implements IDraw
	{
		private var _padding:Number;
		
		public function DTree()
		{
			super();
			_padding = 50;
		}

		public function makeTreeForm(graph:Graph, treeArray:Array):void
		{
			trace("******* Draw Tree *******");
            var node:Node;
            
            var aWidth:Number = graph.width - _padding * 2;
            var aHeight:Number = graph.height - _padding *2;
            var wOffset:Number;
            var hOffset:Number = aHeight / (treeArray.length - 1);
            
            var tCount:Number;
            var tOffset:Number;
            
			for (var i:uint = 0; i < treeArray.length; i++)
			{
				wOffset = aWidth / (treeArray[i].length + 1);
				tCount = 0;
				tOffset = hOffset / treeArray[i].length;
				for (var j:uint = 0; j < treeArray[i].length; j++)
				{
                    node = treeArray[i][j];
                    node.moveTo((j + 1) * wOffset + _padding - node.width / 2, (i + 0) * hOffset + _padding - node.height / 2 - tCount);
                    tCount += Math.min(15, tOffset);
				}
			}
		}
        
        public function get padding():Number
        {
            return _padding;
        }
        
        public function set padding(p:Number):void
        {
            _padding = p;
        }
	}
}