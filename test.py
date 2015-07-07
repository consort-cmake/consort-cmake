#!/bin/python

from __future__ import print_function

import sys
import shutil
from os import path, makedirs, listdir, remove
from subprocess import call

root_path = path.dirname(path.abspath(__file__))

def error(*objs):
    print("ERROR: ", *objs, file=sys.stderr)

dirs = sys.argv[1:]
if len(dirs) == 0:
    dirs = [d for d in listdir(path.join(root_path,'examples')) if path.isdir(path.join(root_path,'examples',d))]

passed=[]
failed=[]

for f in dirs:
    dir = path.join(root_path,'examples',f)
    if path.isdir(dir):
        print(
            '------------------------------------------------------------------------\n'
            'Running test "{}"...\n'
            '------------------------------------------------------------------------'.format(f)
        )
        if path.isdir(path.join(dir,'build')):
            if path.isdir(path.join(dir,'build','CMakeFiles')):
                shutil.rmtree(path.join(dir,'build','CMakeFiles'))
            if path.isfile(path.join(dir,'build','CMakeCache.txt')):
                remove(path.join(dir,'build','CMakeCache.txt'))
        else:
            makedirs(path.join(dir,'build'))

        rv = call(['cmake','..'], cwd=path.join(dir,'build'))
        if rv != 0:
            error('example {} failed configure: {}'.format(f,rv))
            failed.append(f)
        else:
            rv = call(['cmake','--build','.'], cwd=path.join(dir,'build'))
            if rv != 0:
                error('example {} failed build: {}'.format(f,rv))
                failed.append(f)
            else:
                rv = call(['ctest'], cwd=path.join(dir,'build'))
                if rv != 0:
                    error('example {} failed test: {}'.format(f,rv))
                    failed.append(f)
                else:
                    print('Test "{}" PASSED'.format(f))
                    passed.append(f)
    else:
        error('invalid test: {}'.format(f))

print(
    '------------------------------------------------------------------------\n'
    '{} test cases\n'
    '{} PASSED ({})\n'
    '{} FAILED ({})\n'
    '------------------------------------------------------------------------'.format(
        len(passed)+len(failed),
        len(passed),', '.join(passed),
        len(failed),', '.join(failed)
    )
)

if len(failed) > 0:
    sys.exit(1)

