#!/usr/bin/python3.5
# -*- coding: UTF-8 -*-

import subprocess
import re
import os

dest_dir = 'copy-so-libs'
so_or_exectuable_path = 'SeyeAnalysis/SeyeAnalyApplication/bin/libSeyeAnalyApplication.so'
if not os.path.exists(dest_dir):
    os.makedirs(dest_dir)
    print('mkdir %s'%(dest_dir))

fh = subprocess.Popen("ldd -r " + so_or_exectuable_path, stdout=subprocess.PIPE, shell=True)
arr = fh.stdout.readlines()

patten = re.compile(r'.+=> (.+) \(.+\)$')
for line in arr:
    content = line.decode('ascii')
    content = content.replace('\t', '')
    res = patten.match(content)
    if res:
        so_name = res.group(1)
        if os.path.islink(so_name):
            target_file = os.path.realpath(so_name)
            os.system('cp ' + target_file + ' ' + dest_dir)
            os.system('cp -d ' + so_name + ' ' + dest_dir)
        else:
            os.system('cp ' + so_name + ' ' + dest_dir)
        