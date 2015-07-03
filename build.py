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
doc_file = path.join(dist_path,'docs','consort.json')

preprocessed_files = [
    'consort.cmake',
]

docs = []
def gen_docs(filename):
    import codecs
    from markdown import markdown

    file_docs = []
    cur_item = None

    input_file = codecs.open(filename, mode='r', encoding='utf-8')
    for line in input_file:
        if cur_item and line[0] == u'#':
            cur_item['content'] += line[1:]
        elif line[0:2] == u'##':
            path = line[2:].strip().split('/')
            cur_item = {
                'title': path[-1],
                'path': path,
                'content': u''
            }
        elif cur_item:
            file_docs.append(cur_item)
            cur_item = None

    if cur_item:
        file_docs.append(cur_item)
        cur_item = None

    for d in file_docs:
        d['content'] = markdown(d['content'], extensions=[
            'markdown.extensions.def_list',
        ])

    return file_docs

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

    docs += gen_docs(path.join(source_path,f))

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

for f in listdir(path.join(source_path,'consort')):
    if not path.isfile(path.join(source_path,'consort',f)):
        continue

    docs += gen_docs(path.join(source_path,'consort',f))

import json
if not path.isdir(path.dirname(doc_file)):
    makedirs(path.dirname(doc_file))
with open(doc_file, 'w') as output_file:
    output_file.write(json.dumps(docs, indent=4, separators=(',', ': ')))
