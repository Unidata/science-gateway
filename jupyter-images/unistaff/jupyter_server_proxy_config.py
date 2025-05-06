######
# Begin Jupyter Server Proxy Config
######

c.ServerProxy.servers = {
    "Virtual-Desktop": {
        "command": [],  # Unmanaged mode, since you're launching it elsewhere
        "port": 6080,
        "launcher_entry": {
            "title": "NSF Unidata Desktop for IDV and AWIPS CAVE",
            "path_info": "proxy/6080/vnc.html?resize=scale",
            "icon_path": "/usr/local/share/icons/unidata.svg"
        }
    }
}


######
# End Jupyter Server Proxy Config
######
