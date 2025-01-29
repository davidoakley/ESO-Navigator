import subprocess
import re
import shutil
import os
import glob

def copy(wildcard, dest):
  for file in glob.glob(wildcard):
    print(file)
    shutil.copy(file, dest)


result = subprocess.run(['git', 'tag', '-l', '--contains', 'HEAD'], stdout=subprocess.PIPE)

version = result.stdout[1:].decode('utf-8').strip()
if version == "":
  exit(1)

print(f"Version {version}")

versionMatch = re.search(r"^(\d+)\.(\d+)\.(\d+)", version)
addOnVersion = int(versionMatch.group(1))*10000 + int(versionMatch.group(2))*100 + int(versionMatch.group(3))

print(f"AddOnVersion {addOnVersion}")

if os.path.exists("_build/Navigator"):
  shutil.rmtree('_build/Navigator')

os.mkdir('_build/Navigator')

copy(r'*.lua', '_build/Navigator')
copy(r'*.txt', '_build/Navigator')
copy(r'*.xml', '_build/Navigator')

shutil.copytree('media', '_build/Navigator/media')
shutil.copytree('lang', '_build/Navigator/lang')

with open('Navigator.txt', 'r') as inFile:
  txt = inFile.read()
  txt = re.sub(r'## Version: \w+', f"## Version: {version}", txt)
  txt = re.sub(r'## AddOnVersion: \w+', f"## AddOnVersion: {addOnVersion}", txt)
  with open('_build/Navigator/Navigator.txt', 'w') as outFile:
    outFile.write(txt)

with open('Navigator.lua', 'r') as inFile:
  lua = inFile.read()
  lua = re.sub(r'appVersion = "[^"]*"', f'appVersion = "{version}"', lua)
  with open('_build/Navigator/Navigator.lua', 'w') as outFile:
    outFile.write(lua)

shutil.make_archive(f"_build/Navigator-v{version}", 'zip', root_dir='_build', base_dir='Navigator')
