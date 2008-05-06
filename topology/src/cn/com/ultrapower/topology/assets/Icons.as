package cn.com.ultrapower.topology.assets
{
    import mx.controls.Image;
       
	public class Icons {

	    private var iconsList:Array;
	    private var classList:Array;

        [Embed(source="swficons/abr.swf")]
        private var abr:Class;
        [Embed(source="swficons/adapter.swf")]
        private var adapter:Class;
        [Embed(source="swficons/asbr.swf")]
        private var asbr:Class;
        [Embed(source="swficons/backbonearea.swf")]
        private var backbonearea:Class;
        [Embed(source="swficons/basestation.swf")]
        private var basestation:Class;
        [Embed(source="swficons/fcport.swf")]
        private var fcport:Class;
        [Embed(source="swficons/filesystem.swf")]
        private var filesystem:Class;
        [Embed(source="swficons/firewall.swf")]
        private var firewall:Class;
        [Embed(source="swficons/get_in_database.swf")]
        private var get_in_database:Class;
        [Embed(source="swficons/hba.swf")]
        private var hba:Class;
        [Embed(source="swficons/l1l2router.swf")]
        private var l1l2router:Class;
        [Embed(source="swficons/l1router.swf")]
        private var l1router:Class;
        [Embed(source="swficons/l2router.swf")]
        private var l2router:Class;
        [Embed(source="swficons/layer3switch.swf")]
        private var layer3switch:Class;
        [Embed(source="swficons/layer3switch1.swf")]
        private var layer3switch1:Class;
        [Embed(source="swficons/model.swf")]
        private var model:Class;
        [Embed(source="swficons/monitor.swf")]
        private var monitor:Class;
        [Embed(source="swficons/network.swf")]
        private var network:Class;
        [Embed(source="swficons/node.swf")]
        private var node:Class;
        [Embed(source="swficons/node_hp.swf")]
        private var node_hp:Class;
        [Embed(source="swficons/node_ibm.swf")]
        private var node_ibm:Class;
        [Embed(source="swficons/node_linux.swf")]
        private var node_linux:Class;
        [Embed(source="swficons/node_microsoft.swf")]
        private var node_microsoft:Class;
        [Embed(source="swficons/node_sun.swf")]
        private var node_sun:Class;
        [Embed(source="swficons/node_unix.swf")]
        private var node_unix:Class;
        [Embed(source="swficons/normalarea.swf")]
        private var normalarea:Class;
        [Embed(source="swficons/pdsn.swf")]
        private var pdsn:Class;
        [Embed(source="swficons/perouter.swf")]
        private var perouter:Class;
        [Embed(source="swficons/power.swf")]
        private var power:Class;
        [Embed(source="swficons/price.swf")]
        private var price:Class;
        [Embed(source="swficons/prouter.swf")]
        private var prouter:Class;
        [Embed(source="swficons/router.swf")]
        private var router:Class;
        [Embed(source="swficons/router1.swf")]
        private var router1:Class;
        [Embed(source="swficons/router2.swf")]
        private var router2:Class;
        [Embed(source="swficons/router3.swf")]
        private var router3:Class;
        [Embed(source="swficons/router4.swf")]
        private var router4:Class;
        [Embed(source="swficons/sanswitch.swf")]
        private var sanswitch:Class;
        [Embed(source="swficons/satellite.swf")]
        private var satellite:Class;
        [Embed(source="swficons/snmpnode.swf")]
        private var snmpnode:Class;
        [Embed(source="swficons/snmpnode_hp.swf")]
        private var snmpnode_hp:Class;
        [Embed(source="swficons/snmpnode_ibm.swf")]
        private var snmpnode_ibm:Class;
        [Embed(source="swficons/snmpnode_linux.swf")]
        private var snmpnode_linux:Class;
        [Embed(source="swficons/snmpnode_microsoft.swf")]
        private var snmpnode_microsoft:Class;
        [Embed(source="swficons/snmpnode_sun.swf")]
        private var snmpnode_sun:Class;
        [Embed(source="swficons/snmpnode_unix.swf")]
        private var snmpnode_unix:Class;
        [Embed(source="swficons/storageport.swf")]
        private var storageport:Class;
        [Embed(source="swficons/stubarea.swf")]
        private var stubarea:Class;
        [Embed(source="swficons/switch0.swf")]
        private var switch0:Class;
        [Embed(source="swficons/switch1.swf")]
        private var switch1:Class;
        [Embed(source="swficons/switch2.swf")]
        private var switch2:Class;
        [Embed(source="swficons/thread.swf")]
        private var thread:Class;
        [Embed(source="swficons/unknowrouter.swf")]
        private var unknowrouter:Class;

    
		public function Icons(){
			iconsList = new Array(
                                "abr",
                                "adapter",
                                "asbr",
                                "backbonearea",
                                "basestation",
                                "fcport",
                                "filesystem",
                                "firewall",
                                "get_in_database",
                                "hba",
                                "l1l2router",
                                "l1router",
                                "l2router",
                                "layer3switch",
                                "layer3switch1",
                                "model",
                                "monitor",
                                "network",
                                "node",
                                "node_hp",
                                "node_ibm",
                                "node_linux",
                                "node_microsoft",
                                "node_sun",
                                "node_unix",
                                "normalarea",
                                "pdsn",
                                "perouter",
                                "power",
                                "price",
                                "prouter",
                                "router",
                                "router1",
                                "router2",
                                "router3",
                                "router4",
                                "sanswitch",
                                "satellite",
                                "snmpnode",
                                "snmpnode_hp",
                                "snmpnode_ibm",
                                "snmpnode_linux",
                                "snmpnode_microsoft",
                                "snmpnode_sun",
                                "snmpnode_unix",
                                "storageport",
                                "stubarea",
                                "switch0",
                                "switch1",
                                "switch2",
                                "thread",
                                "unknowrouter");
                                
            classList = new Array(
                                abr,
                                adapter,
                                asbr,
                                backbonearea,
                                basestation,
                                fcport,
                                filesystem,
                                firewall,
                                get_in_database,
                                hba,
                                l1l2router,
                                l1router,
                                l2router,
                                layer3switch,
                                layer3switch1,
                                model,
                                monitor,
                                network,
                                node,
                                node_hp,
                                node_ibm,
                                node_linux,
                                node_microsoft,
                                node_sun,
                                node_unix,
                                normalarea,
                                pdsn,
                                perouter,
                                power,
                                price,
                                prouter,
                                router,
                                router1,
                                router2,
                                router3,
                                router4,
                                sanswitch,
                                satellite,
                                snmpnode,
                                snmpnode_hp,
                                snmpnode_ibm,
                                snmpnode_linux,
                                snmpnode_microsoft,
                                snmpnode_sun,
                                snmpnode_unix,
                                storageport,
                                stubarea,
                                switch0,
                                switch1,
                                switch2,
                                thread,
                                unknowrouter);
		}

        /**
         * 获取图标类型
         * */
        public function getIcon(type:String):Class
        {
            var index:int = iconsList.indexOf(type.toLowerCase());
            if (index != -1)
            {
                return classList[index];
            }
            
            return unknowrouter;
        }
        
        public function getIconList():Array
        {
            return iconsList;
        }
	}
}