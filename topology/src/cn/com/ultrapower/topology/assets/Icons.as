package cn.com.ultrapower.topology.assets
{
	public class Icons {
        [Embed(source="icons.swf", symbol="workgroup")]
        private var workgroup:Class;
        [Embed(source="icons.swf", symbol="server")]
        private var server:Class;
        [Embed(source="icons.swf", symbol="client")]
        private var client:Class;
        [Embed(source="icons.swf", symbol="computer")]
        private var computer:Class;
        
        [Embed(source="icons.swf", symbol="power")]
        private var power:Class;
        [Embed(source="icons.swf", symbol="hardware")]
        private var hardware:Class;
        [Embed(source="icons.swf", symbol="storage")]
        private var storage:Class;
        [Embed(source="icons.swf", symbol="printer")]
        private var printer:Class;
        
        [Embed(source="icons.swf", symbol="audio")]
        private var audio:Class;
        [Embed(source="icons.swf", symbol="video")]
        private var video:Class;
        [Embed(source="icons.swf", symbol="wifi")]
        private var wifi:Class;
        
        [Embed(source="icons.swf", symbol="dot")]
        private var dot:Class;
        
		public function Icons(){
			// nothing
		}

        /**
         * 获取图标类型
         * */
        public function getIcon(type:String):Class{
            switch (type){
                case 'workgroup':
                    return workgroup;
                case 'server':
                    return server;
                case 'client':
                    return client;
                case 'computer':
                    return computer;
                    
                case 'power':
                    return power;
                case 'hardware':
                    return hardware;
                case 'storage':
                    return storage;
                case 'printer':
                    return printer;
                    
                case 'audio':
                    return audio;
                case 'video':
                    return video;
                case 'wifi':
                    return wifi;
                    
                default:{
                    return dot;
                }
            }
        }
	}
}