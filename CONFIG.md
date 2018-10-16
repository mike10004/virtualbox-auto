virtualbox-auto configuration files
===================================

This service is used to automatically start and stop VirtualBox VMs. 
For each VM that you want to be started and stopped by the service, 
create a file named `<vm_name>.auto` in the `/etc/virtualbox-auto` 
directory. You can leave the file empty or use it to specify start/stop 
options in JSON.

Specifying options with JSON
----------------------------

A fully populated configuration object would look like 

    {
        "id": "virtual-machine-name-or-uuid",
        "user": "vmowner",             
        "stop_action": "savestate",
        "startup_delay": 5
    }

All fields are optional, and their meanings are as follows:

* **id** the VM name or UUID; by default, this is taken from the 
  filename, e.g. `my-machine` if the configuration file is 
  `my-machine.auto`
* **user** the user that owns the VM; default is "root"
* **stop_action** the `controlvm` parameter that stops the VM; valid 
  values are `savestate`, `poweroff`, and `acpipowerbutton`
* **startup_delay** duration in seconds to pause before starting the VM

Note that the VMs are started consecutively, so the actual start times
of VMs processed later are affected by the startup delays of VMs processed 
earlier.

Empty file (default options)
----------------------------

If a file named `/etc/virtualbox-auto/my_virtual_machine.auto` is 
empty, then the service will automatically start the VM named 
`my_virtual_machine` that is owned by root and automatically stop the
VM in `savestate` mode (see VirtualBox docs for an explanation).
