#! /usr/bin/python

"""
Recursively find .ipynb files and edit their metadata to use a specifc kernel

Takes two positional arguments:
argv[1] -- name of the kernel to set
argv[2] -- directory to recursively search through (optional)
           defaults to the directory from which this script is ran
"""

from sys import argv
from glob import glob
from os import rename
import json

kernel = argv[1]
directory = argv[2] if len(argv) > 2 else "./"

for filename in glob('**/*.ipynb', root_dir=directory, recursive=True):
    filename = directory+filename
    tmpfile = filename+'.tmp'
    print(filename)
    # Load notebook and edit metadata
    with open(filename, 'r') as f:
        data = json.load(f)
        data['metadata']["kernelspec"]["display_name"] = "Python [conda env:{}]".format(kernel)
        data['metadata']["kernelspec"]["name"] = "conda-env-{}-py".format(kernel)
    # Do not dump to original file, bugs may occur if the new values are shorter
    # than the original values. See VadimBelov's answer here:
    # https://stackoverflow.com/questions/21035762/python-read-json-file-and-modify
    with open(tmpfile, 'w') as f:
        json.dump(data, f, indent=1)
    rename(tmpfile, filename)

