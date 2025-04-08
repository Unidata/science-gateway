######
# Begin Jupyter Server Proxy Config
######

c.ServerProxy.servers = {
    "Virtual-Desktop": {
        "port": 6080,  # Port exposed by the sidecar container
        "launcher_entry": {
            "title": "Virtual Desktop",
            "path_info": "Virtual-Desktop/vnc.html"
            # Optional: add an icon if desired
            # "icon_path": "/usr/local/share/icons/xfce.png"
        }
    }
}

######
# End Jupyter Server Proxy Config
######
