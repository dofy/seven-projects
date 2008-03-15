package cn.com.ultrapower.topology.view
{
	public interface INode
	{
		function pushLine(line:Line):void;
		function getLines():Array;
		
		function addSubNode(node:INode):Boolean;
		function removeSubNode(node:INode):Boolean;
		function addParentNode(node:INode):Boolean;
		function removeParentNode(node:INode):Boolean;
		
		function get Name():Number;
		function get cx():Number;
		function get cy():Number;
	}
}