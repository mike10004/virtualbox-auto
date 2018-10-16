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

## Background

Everyone knows that if you want to start VMs automatically on host boot, all 
you need to do is read https://www.virtualbox.org/manual/ch09.html#autostart
and *voila*, they start. However, if you actually go and do that, at least
on Linux, you find that nothing happens. If you dig deeper, you learn that
there's an `init` service called `vboxautostart-service`, but then if you dig
just a little bit deeper, you find that the service is not present in 
VirtualBox versions 5.0 and above. Plus, it was an `init` service, and your
PID 1 is probably *systemd* now, so you can't even just downgrade. 

The **virtualbox-auto.service** *systemd* unit simplifies some configuration 
aspects of automatically starting VMs on host boot, and for better or worse 
it avoids using the stock mechanism at all. Some features that the stock 
mechanism supports are not available here, so it may not fit your needs as 
well. On the upside, it's pretty simple to understand how it works.

On boot, the *systemd* unit executes `virtualbox_auto_start.py`, which reads
your configuration files and uses `VBoxManage` to start machines in headless 
mode. On shutdown, the unit executes `virtualbox_auto_stop.py`, which stops 
those machines.

## Building the installer

You can build a `.deb` package for the service by running 

    $ ./make-package.sh

from the directory where the repository was cloned. Your mileage may 
vary with that script, but if it works it will create a file named 
`build/virtualbox-auto_${VERSION}_all.deb`. You can install this by 
executing 

    $ sudo dpkg --install build/virtualbox-auto_${VERSION}_all.deb

