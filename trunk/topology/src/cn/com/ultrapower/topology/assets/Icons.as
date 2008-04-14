package cn.com.ultrapower.topology.assets
{
    import mx.controls.Image;
       
	public class Icons {

	    private var iconsList:Array;
	    private var classList:Array;

        [Embed(source="icons/abr.png")]
        private var abr:Class;
        [Embed(source="icons/adapter.png")]
        private var adapter:Class;
        [Embed(source="icons/asbr.png")]
        private var asbr:Class;
        [Embed(source="icons/backbonearea.png")]
        private var backbonearea:Class;
        [Embed(source="icons/basestation.png")]
        private var basestation:Class;
        [Embed(source="icons/fax.png")]
        private var fax:Class;
        [Embed(source="icons/fcport.png")]
        private var fcport:Class;
        [Embed(source="icons/filesystem.png")]
        private var filesystem:Class;
        [Embed(source="icons/firewall.png")]
        private var firewall:Class;
        [Embed(source="icons/firewall1.png")]
        private var firewall1:Class;
        [Embed(source="icons/get_in_database.png")]
        private var get_in_database:Class;
        [Embed(source="icons/hba.png")]
        private var hba:Class;
        [Embed(source="icons/l1l2router.png")]
        private var l1l2router:Class;
        [Embed(source="icons/l1router.png")]
        private var l1router:Class;
        [Embed(source="icons/l2router.png")]
        private var l2router:Class;
        [Embed(source="icons/layer3switch.png")]
        private var layer3switch:Class;
        [Embed(source="icons/layer3switch1.png")]
        private var layer3switch1:Class;
        [Embed(source="icons/model.png")]
        private var model:Class;
        [Embed(source="icons/monitor.png")]
        private var monitor:Class;
        [Embed(source="icons/network.png")]
        private var network:Class;
        [Embed(source="icons/node.png")]
        private var node:Class;
        [Embed(source="icons/node_hp.png")]
        private var node_hp:Class;
        [Embed(source="icons/node_ibm.png")]
        private var node_ibm:Class;
        [Embed(source="icons/node_linux.png")]
        private var node_linux:Class;
        [Embed(source="icons/node_microsoft.png")]
        private var node_microsoft:Class;
        [Embed(source="icons/node_netscreen.png")]
        private var node_netscreen:Class;
        [Embed(source="icons/node_sun.png")]
        private var node_sun:Class;
        [Embed(source="icons/node_unix.png")]
        private var node_unix:Class;
        [Embed(source="icons/normalarea.png")]
        private var normalarea:Class;
        [Embed(source="icons/pdsn.png")]
        private var pdsn:Class;
        [Embed(source="icons/perouter.png")]
        private var perouter:Class;
        [Embed(source="icons/power.png")]
        private var power:Class;
        [Embed(source="icons/price.png")]
        private var price:Class;
        [Embed(source="icons/prouter.png")]
        private var prouter:Class;
        [Embed(source="icons/router.png")]
        private var router:Class;
        [Embed(source="icons/router1.png")]
        private var router1:Class;
        [Embed(source="icons/router2.png")]
        private var router2:Class;
        [Embed(source="icons/router3.png")]
        private var router3:Class;
        [Embed(source="icons/router4.png")]
        private var router4:Class;
        [Embed(source="icons/sanswitch.png")]
        private var sanswitch:Class;
        [Embed(source="icons/satellite.png")]
        private var satellite:Class;
        [Embed(source="icons/snmpnode.png")]
        private var snmpnode:Class;
        [Embed(source="icons/snmpnode_hp.png")]
        private var snmpnode_hp:Class;
        [Embed(source="icons/snmpnode_ibm.png")]
        private var snmpnode_ibm:Class;
        [Embed(source="icons/snmpnode_linux.png")]
        private var snmpnode_linux:Class;
        [Embed(source="icons/snmpnode_microsoft.png")]
        private var snmpnode_microsoft:Class;
        [Embed(source="icons/snmpnode_sun.png")]
        private var snmpnode_sun:Class;
        [Embed(source="icons/snmpnode_unix.png")]
        private var snmpnode_unix:Class;
        [Embed(source="icons/speaker.png")]
        private var speaker:Class;
        [Embed(source="icons/storageport.png")]
        private var storageport:Class;
        [Embed(source="icons/stubarea.png")]
        private var stubarea:Class;
        [Embed(source="icons/switch0.png")]
        private var switch0:Class;
        [Embed(source="icons/switch1.png")]
        private var switch1:Class;
        [Embed(source="icons/switch2.png")]
        private var switch2:Class;
        [Embed(source="icons/thread.png")]
        private var thread:Class;
        [Embed(source="icons/transport.png")]
        private var transport:Class;
        [Embed(source="icons/unknowrouter.png")]
        private var unknowrouter:Class;
        
        
        [Embed(source="swf/lang.swf")]
        private var lang:Class;
        [Embed(source="swf/users.swf")]
        private var users:Class;

	    
		public function Icons(){
			iconsList = new Array(
                                "abr",
                                "adapter",
                                "asbr",
                                "backbonearea",
                                "basestation",
                                "fax",
                                "fcport",
                                "filesystem",
                                "firewall",
                                "firewall1",
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
                                "node_netscreen",
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
                                "speaker",
                                "storageport",
                                "stubarea",
                                "switch0",
                                "switch1",
                                "switch2",
                                "thread",
                                "transport",
                                "unknowrouter",
                                "lang",
                                "users");
                                
            classList = new Array(
                                abr,
                                adapter,
                                asbr,
                                backbonearea,
                                basestation,
                                fax,
                                fcport,
                                filesystem,
                                firewall,
                                firewall1,
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
                                node_netscreen,
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
                                speaker,
                                storageport,
                                stubarea,
                                switch0,
                                switch1,
                                switch2,
                                thread,
                                transport,
                                unknowrouter,
                                lang,
                                users);
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