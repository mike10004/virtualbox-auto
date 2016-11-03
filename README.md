virtualbox-auto
===============

This is a **systemd** service that starts and stops VirtualBox VMs on
system boot and shutdown.

## Configuration

The VMs to be automatically started and stopped are specified by files 
in the configuration directory `/etc/virtualbox-auto`. See 
`CONFIG.md` for details, but as a quick tutorial, if you create a file
named `/etc/virtualbox-auto/quickstart.auto` and populate it with text

    {
        "id": "my_machine",
        "user": "vmowner",             
        "stop_action": "savestate"
    }

...then on system boot, the service will start the VM named 
`my_machine` that is owned by `vmowner`, and on system shutdown the
service will stop the VM with the `savestate` command.

## Building a package

You can build a `.deb` package for the service by running 

    $ ./make-package.sh

from the directory where the repository was cloned. Your mileage may 
vary with that script, but if it works it will create a file named 
`build/virtualbox-auto_${VERSION}_all.deb`. You can install this by 
executing 

    $ sudo dpkg --install build/virtualbox-auto_${VERSION}_all.deb

