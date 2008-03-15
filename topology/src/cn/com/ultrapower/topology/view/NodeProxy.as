package cn.com.ultrapower.topology.view
{
	import flash.events.MouseEvent;
	
	import mx.core.Container;

	public class NodeProxy extends Container implements INode
	{
		private var _name:Number;
		private var _lines:Array;
		
		public function NodeProxy(name:Number = 0) 
		{
			super();
			_lines = new Array();
			Name = name;
			
			bindListener();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			this.graphics.lineStyle(1, 0xcc0000);
            this.graphics.beginFill(0xffcc00, 0.5);
            this.graphics.drawCircle(0, 0, 5);
            this.graphics.endFill();
		}		
		
		public function pushLine(line:Line):void 
		{
			_lines.push(line);
		}
		
		public function getLines():Array {
			return _lines;
		}
        
        public function addSubNode(node:INode):Boolean
        {
            return false;
        }
        
        public function removeSubNode(node:INode):Boolean
        {
            return false;
        }
		
		public function addParentNode(node:INode):Boolean
		{
			return false;
		}
		
        public function removeParentNode(node:INode):Boolean
        {
            return false;
        } 
		
		public function set Name(name:Number):void 
		{
			_name = name;
		}
		
		public function get Name():Number 
		{
			return _name;
		}
		
		public function get cx():Number 
		{
			return x + width / 2;
		}
		
		public function get cy():Number 
		{
			return y + height / 2;
		}
		
		public function set isSelected(s:Boolean):void
		{
			
		}
		
		private function bindListener():void
		{
			this.addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			this.addEventListener(MouseEvent.MOUSE_OUT,  outHandler);
		}
		
		private function overHandler(evt:MouseEvent):void
		{
			this.scaleX = this.scaleY = 1.2;
		}
		
		private function outHandler(evt:MouseEvent):void
		{
			this.scaleX = this.scaleY = 1;
		}
	}
}