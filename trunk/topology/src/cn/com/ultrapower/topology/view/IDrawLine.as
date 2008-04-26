package cn.com.ultrapower.topology.view
{
    public interface IDrawLine
    {
        function refresh(bgAlpha:Number = 0):void
        function redrawArrow():void;
        
        function set index(ind:int):void;
        function get index():int;
        function set count(c:int):void;
        function set positive(pos:Boolean):void;
        
        function get name():String;
    }
}