# virtualbox-auto

systemd service to automatically start and stop VirtualBox VMs

This repository contains a *systemd* service file that causes Python programs
that start and stop VirtualBox VMs to be executed on boot and shutdown.

The VMs to be automatically started and stopped are specified by files in 
the configuration directory `/etc/virtualbox-auto`. Configuration files in 
this directory must have suffix `.auto`, and each configuration file must  
be empty or contain text encoding a JSON object containing fields that specify
parameters for `vboxmanage` execution. All fields are optional, but a fully 
populated object would look like this:

    {
        "id": "virtual-machine-name-or-uuid",  # name taken from filename
        "user": "vmowner",                     # default is "root"
        "stop_action": "savestate"             # or "poweroff" or "acpipowerbutton"
    }

