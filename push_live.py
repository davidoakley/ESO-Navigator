import subprocess
import re
import shutil
import os
import glob

def copy(wildcard, dest):
    for file in glob.glob(wildcard):
        print(file)
        shutil.copy(file, dest)

homeDir = os.path.expanduser("~")
destDir = f"{homeDir}/Documents/Elder Scrolls Online/live/AddOns/Navigator"

if os.path.exists(destDir):
    shutil.rmtree(destDir)

os.mkdir(destDir)

copy(r'*.lua', destDir)
copy(r'*.txt', destDir)
copy(r'*.xml', destDir)

shutil.copytree('media', f'{destDir}/media')
shutil.copytree('lang', f'{destDir}/lang')
