#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  virtualbox_auto_start.py
#  
#  Copyright 2016 Mike Chaberski
#  
#  MIT License

import os
import os.path
import sys
import virtualbox_auto_common

class MachineStarter(virtualbox_auto_common.MachineActor):

    def __init__(self, dry_run=False, verbose=False):
        virtualbox_auto_common.MachineActor.__init__(self, dry_run, verbose)

    def start(self, vm):
        vmuser = vm['user'] or os.getenv('USER')
        vmid = virtualbox_auto_common.escape_vm_id(vm['id'])
        cmd = ['su', vmuser, "-c", "/usr/bin/vboxmanage startvm \"%s\" --type headless" % (vmid,)]
        virtualbox_auto_common.print_command(cmd)
        return self._execute(cmd)

    def start_all(self, machines):
        return [self.start(vm) for vm in machines]

def main(args):
    machines, errors = virtualbox_auto_common.load_machines(args.conf_dir, verbose=args.verbose)
    args.dry_run = virtualbox_auto_common.create_dry_run_function(args.dry_run)
    starter = MachineStarter(args.dry_run, args.verbose)
    returncodes = starter.start_all(machines)
    if args.verbose: 
        print len(errors), 'configuration errors; return codes:', returncodes
    if len(errors) > 0: 
        return 1
    if sum(returncodes) > 0: 
        return 2
    return 0

if __name__ == '__main__':
    from argparse import ArgumentParser
    parser = ArgumentParser()
    virtualbox_auto_common.add_arguments(parser)
    args = parser.parse_args()
    sys.exit(main(args))
