#!/bin/python

import re
import sys
from os import path, makedirs, listdir

# fairly simply python script to concatenate the cmake files that make up
# consort into a single file that can be easily distributed or included in other
# projects

master_name = 'consort.cmake'
licence_name = 'LICENSE'

root_path = path.dirname(path.abspath(__file__))

source_path = path.join(root_path,'cmake')
dist_path = path.join(root_path,'dist')

preprocessed_files = [
    'consort.cmake',
]

def preprocess(filename):
    output = ''
    with open(filename, "r") as file:
        # this regular expression is pretty dumb, but ought to be good enough
        expr = re.compile(r'include\(\s*"(.*)"\s*\)')

        for line in file:
            m = expr.search(line)
            if m:
                p = m.group(1)
                p = p.replace('${CMAKE_CURRENT_LIST_DIR}',path.dirname(filename));
                with open(p, 'r') as include_file:
                    output += include_file.read()
            else:
                output += line
    return output

if not path.isdir(dist_path):
    makedirs(dist_path)

for f in listdir(source_path):
    if not path.isfile(path.join(source_path,f)):
        continue

    output = ''
    with open(path.join(root_path,licence_name)) as licence_file:
        for line in licence_file:
            output += '# ' + line;

    if f in preprocessed_files:
        output += preprocess(path.join(source_path,f))
    else:
        with open(path.join(source_path,f)) as file:
            output += file.read()

    with open(path.join(dist_path,f), 'w') as output_file:
        output_file.write(output)
