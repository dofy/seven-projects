package cn.com.ultrapower.topology.tool
{
    import cn.com.ultrapower.topology.view.DLLine;
    import cn.com.ultrapower.topology.view.DLMultiLine;
    import cn.com.ultrapower.topology.view.Line;
    
    public class LineData
    {
        private var _dat:XML;
        private var _arr:Array;
        
        public function LineData()
        {
            clean();
        }
        
        ///////////////////////////
        // public functions
        ///////////////////////////
        
        public function pushLine(line:Line):void
        {
            var tmpXML:XML = line.Data.copy();
            if (tmpXML.@toId == '0')
                return;
            tmpXML.@arrIndex = _arr.length;
            _arr.push(line);
            _dat.appendChild(tmpXML);
            chgLineOptions(tmpXML);
        }
        
        public function removeLine(line:Line):void
        {
            var _index:int = _arr.indexOf(line);
            var tmpXML:XML = _dat.line.(@arrIndex == _index)[0].copy();
            delete _dat.line.(@arrIndex == _index)[0];
            _arr.splice(_index, 1);
            
            var dat:XMLList = _dat.line.(@arrIndex > _index);
            for (var i:int = 0; i < dat.length(); i++)
                dat[i].@arrIndex = String(dat[i].@arrIndex - 1);
            chgLineOptions(tmpXML, true);
        }
        
        public function clean():void
        {
            _arr = new Array();
            _dat = <dat></dat>;
        }
        
        ///////////////////////////
        // private functions
        ///////////////////////////
        
        private function chgLineOptions(dat:XML, remove:Boolean = false):void
        {
            var tLine:Line;
            var fromId:String = dat.@fromId;
            var toId:String = dat.@toId;
            var list:XMLList = _dat.line.((@fromId == fromId && @toId == toId) ||  
                                          (@fromId == toId && @toId == fromId));
            if (!remove && list.length() == 2)
            {
                // 单线转多线
                // 设置第一条线的画线算法
                tLine = _arr[list[0].@arrIndex];
                tLine.setDrawBot(new DLMultiLine(tLine));
            }
            if (list.length() > 1)
            {
                if (!remove)
                {
                    // 设置随后一条线(新加线)的画线算法
                    tLine = _arr[_arr.length - 1];
                    tLine.setDrawBot(new DLMultiLine(tLine));
                    tLine.positive = linePositive(list[0], list[list.length() - 1]);
                }
                // 循环设置序列参数
                for (var i:int = 0; i < list.length(); i++)
                {
                    tLine = _arr[list[i].@arrIndex];
                    tLine.index = i;
                    tLine.count = list.length();
                }
            }
            else if (remove && list.length() == 1)
            {
                tLine = _arr[list[0].@arrIndex];
                tLine.setDrawBot(new DLLine(tLine));
            }
            else
            {
                // nothing
            }
        }
        
        private function linePositive(dat1:XML, dat2:XML):Boolean
        {
            return dat1.@fromId == dat2.@fromId;
        }
    }
}