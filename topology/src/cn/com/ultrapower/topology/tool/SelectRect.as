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
            setStyle("borderStyle", "solid");
            setStyle("borderThickness", 1);
            setStyle("borderColor", "#cc99ff");
            setStyle("backgroundColor", "#cccccc");
            setStyle("backgroundAlpha", 0.3);
		}
		
		/**
		 * 设置起始点
		 * */
		public function setStartPoint(tx:Number, ty:Number):void{
            _x = tx;
            _y = ty;
            reDraw(_x, _y);
		}
		/**
		 * 重绘选取
		 * */
		public function reDraw(tx:Number, ty:Number):void{
            width = Math.abs(_x - tx);
            height = Math.abs(_y - ty);
            x = Math.min(_x, tx);
            y = Math.min(_y, ty);
		}
	}
}