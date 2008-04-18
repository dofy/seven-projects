package cn.com.ultrapower.topology.tool
{
    public dynamic class TopoHistory extends Array
    {
        // 当前历史指针
        private var _index:int = -1;
        
        public function TopoHistory(numElements:int=0)
        {
            super(numElements);
        }
        
        /**
         * 插入历史记录, 清除指针之后的记录
         * */
        public function insert(data:XML):void
        {
            splice(_index + 1);
            push(data);
            _index = length - 1;
        }
        
        /**
         * 清楚历史记录
         * */
        public function clear():void
        {
            splice(0);
            _index = -1;
        }
        
        /**
         * 当前记录
         * */
        public function get curTopo():XML
        {
            return this.length > 0 ? this[_index] : null;
        }
        
        /**
         * 上一条
         * */
        public function get prevTopo():XML
        {
            index--;
            return curTopo;
        }
        
        /**
         * 下一条
         * */
        public function get nextTopo():XML
        {
            index++;
            return curTopo;
        }
        
        /**
         * 获取指针位置
         * */
        public function get index():int
        {
            return _index;
        }
        
        /**
         * 设置指针
         * */
        public function set index(ind:int):void
        {
            _index = (ind >= length ? length - 1 : (ind < 0 ? 0 : ind));
        }
    }
}