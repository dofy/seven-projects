package cn.com.ultrapower.topology.tool
{
	import mx.containers.Canvas;

	public class SelectRect extends Canvas
	{
		private var _x:Number;
		private var _y:Number;
		
		public function SelectRect()
		{
			super();
			// style
            this.setStyle("borderStyle", "solid");
            this.setStyle("borderThickness", 1);
            this.setStyle("borderColor", "#cc99ff");
            this.setStyle("backgroundColor", "#cccccc");
            this.setStyle("backgroundAlpha", 0.3);
		}
		
		/**
		 * 设置起始点
		 * */
		public function setStartPoint(x:Number, y:Number):void{
            _x = x;
            _y = y;
            reDraw(_x, _y);
		}
		/**
		 * 重绘选取
		 * */
		public function reDraw(x:Number, y:Number):void{
            width = Math.abs(_x - x);
            height = Math.abs(_y - y);
            this.x = Math.min(_x, x);
            this.y = Math.min(_y, y);
		}
	}
}