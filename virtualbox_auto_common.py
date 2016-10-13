# -*- coding: utf-8 -*-
#
#  virtualbox_auto_start.py
#  
#  Copyright 2016 Mike Chaberski
#  
#  MIT License

import subprocess
import os
import os.path
from glob import glob
import json 
import subprocess
import sys

def load_machines(conf_dir, verbose=False):
    """Loads VM configurations from a configuration directory.
    """
    if not os.path.isdir(conf_dir):
        print >> sys.stderr, "configuration directory not found:", conf_dir
        return tuple(), tuple()
    conf_files = glob(os.path.join(conf_dir, '*.auto'))
    machines = []
    if verbose: 
        print "reading from %d files:" % len(conf_files), str(conf_files)
    errors = []
    for conf_file in conf_files:
        with open(conf_file, 'r') as ifile:
            try:
                machine = json.loads(ifile.read() or '{}')
            except ValueError as e:
                print >> sys.stderr, conf_file + ':', e
                errors.append((conf_file, e))
                continue
            if 'id' not in machine:
                machine_name = os.path.splitext(os.path.basename(conf_file))[0]
                machine['id'] = machine_name  # todo: check not empty
            machines.append(machine)
    return machines, errors

def print_command(cmd):
    print ' '.join(cmd)

class FirstTimeFailer:

    def __init__(self):
        self.failed = False

    def go(self, cmd):
        if self.failed: 
            return 0
        else: 
            self.failed = True
            return 1

    def as_single_arg_function(self):
        def fn(cmd):
            return self.go(cmd)
        return fn

def create_dry_run_function(dry_run_arg):
    if dry_run_arg is False:
        return False
    if dry_run_arg is None:  # means --dry-run with no argument was specified
        return create_dry_run_function('succeed')
    spec = dry_run_arg
    if spec == 'fail':
        return lambda x: 1
    elif spec == 'succeed':
        return lambda x: 0
    elif spec == 'fail_first':
        return FirstTimeFailer().as_single_arg_function()
    else:
        raise ValueError("invalid --dry-run value; choices are 'fail', 'succeed', or 'fail_first'")

class MachineActor:

    def __init__(self, dry_run=False, verbose=False):
        self.verbose = verbose
        if dry_run:
            if verbose: 
                print "operating in dry run mode"
            if not callable(dry_run): 
                raise ValueError("dry_run argument must be False or a function")
        self._execute = dry_run or subprocess.call

def add_arguments(parser):
    parser.add_argument("--conf-dir", help="directory from which *.auto files are read", 
                        default=(os.getenv("VIRTUALBOX_AUTO_CONF_DIR") or "/etc/virtualbox-auto"), metavar="DIRNAME")
    parser.add_argument("--dry-run", nargs="?", help="dry run mode", default=False)
    parser.add_argument("--verbose", action="store_true", default="False", help="print more messages about processing")
    return parser

_VM_ID_ALLOWED_CHARS = "{-_ abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

def escape_vm_id(vmid):
    # TODO: actually escape the id instead of failing
    for ch in vmid:
        if ch not in _VM_ID_ALLOWED_CHARS:
            raise ValueError("vm id contains invalid characters: " + vmid)
    return vmid
