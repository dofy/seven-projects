package cn.com.ultrapower.topology.tool
{
    import cn.com.ultrapower.topology.view.Line;
    
    public class LineData
    {
        private var _dat:XML = new XML();
        private var _arr:Array = new Array();
        
        public function LineData()
        {
        }
        
        ///////////////////////////
        // public functions
        ///////////////////////////
        
        public function pushLine(line:Line):void
        {
            var tmpXML:XML = line.Data;
            _arr.push(line);
            tmpXML.index = _arr.length - 1;
            _dat.appendChild(tmpXML);
        }
        
        public function removeLine(line:Line):void
        {
            var _index:int = _arr.indexOf(line);
            
        }
        
        ///////////////////////////
        // private functions
        ///////////////////////////
        
        private function linePositive(line:Line):Boolean
        {
            trace(_arr.indexOf(line));
            return true;
        }
    }
}