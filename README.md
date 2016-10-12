# virtualbox-auto

systemd service to automatically start and stop VirtualBox VMs

This repository contains a **systemd** service file that causes Python programs
that start and stop VirtualBox VMs to be executed on boot and shutdown.

The VMs to be automatically started and stopped are specified by files in 
the configuration directory `/etc/virtualbox-auto`. Configuration files in 
this directory must have suffix `.auto`, and each configuration file must  
be empty or contain text encoding a JSON object containing fields that specify
parameters for `vboxmanage` execution. All fields are optional, but a fully 
populated object would look like this:

    {
        "id": "virtual-machine-name-or-uuid",
        "user": "vmowner",             
        "stop_action": "savestate"
    }

The fields you can specify are:

* **id** the VM name or UUID; by default, this is taken from the filename, 
  e.g. `my-machine` if the configuration file is `my-machine.auto`
* **user** the user that owns the VM; default is "root"
* **stop_action** the `controlvm` parameter that stops the VM; valid values 
  are `savestate`, `poweroff`, and `acpipowerbutton`


