#!/bin/python

from __future__ import print_function

import argparse
import sys
import shutil
from os import path, makedirs, listdir, remove
from subprocess import call

root_path = path.dirname(path.abspath(__file__))

parser = argparse.ArgumentParser(description='Run Consort tests.')
parser.add_argument('test_cases', metavar='TEST', nargs='*', help='a test case to run')
parser.add_argument('--work_dir', dest='work_dir', nargs=1,
    default=[root_path],
    help='specify directory to use for builds')
parser.add_argument('-D', dest='defs', nargs=1,
    action='append',
    help='add a CMake define')

args = parser.parse_args()
args.defs = ['-D'+d[0] for d in args.defs] if args.defs else []

def error(*objs):
    print("ERROR: ", *objs, file=sys.stderr)

dirs = args.test_cases
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

        build_dir = path.join(args.work_dir[0],'examples',f,'build')

        if path.isdir(build_dir):
            if path.isdir(path.join(build_dir,'CMakeFiles')):
                shutil.rmtree(path.join(build_dir,'CMakeFiles'))
            if path.isfile(path.join(build_dir,'CMakeCache.txt')):
                remove(path.join(build_dir,'CMakeCache.txt'))
        else:
            makedirs(build_dir)

        rv = call(['cmake',dir]+args.defs, cwd=build_dir)
        if rv != 0:
            error('example {} failed configure: {}'.format(f,rv))
            failed.append(f)
        else:
            rv = call(['cmake','--build','.','--','VERBOSE=1'], cwd=build_dir)
            if rv != 0:
                error('example {} failed build: {}'.format(f,rv))
                failed.append(f)
            else:
                rv = call(['ctest'], cwd=build_dir)
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

