import re
import shutil
import os
import sys

from _src import utils

utils.check_dependencies("## DependsOn:")
utils.check_dependencies("## OptionalDependsOn:")

VERSION = utils.get_tag()
if VERSION == "":
  print("🛑 No version tag found", file=sys.stderr)
  exit(1)

print(f"Version {VERSION}")

ADDON_VERSION = utils.convert_to_addon_version(VERSION)

print(f"AddOnVersion {ADDON_VERSION}")

if os.path.exists("_build/Navigator"):
  shutil.rmtree('_build/Navigator')

os.mkdir('_build/Navigator')

utils.copy(r'*.lua', '_build/Navigator')
utils.copy(r'*.txt', '_build/Navigator')
utils.copy(r'*.xml', '_build/Navigator')

shutil.copytree('media', '_build/Navigator/media')
shutil.copytree('lang', '_build/Navigator/lang')

with open('Navigator.txt', 'r') as inFile:
  NAVIGATOR_TXT = inFile.read()
  NAVIGATOR_TXT = re.sub(r'## Version: \w+', f"## Version: {VERSION}", NAVIGATOR_TXT)
  NAVIGATOR_TXT = re.sub(r'## AddOnVersion: \w+', f"## AddOnVersion: {ADDON_VERSION}", NAVIGATOR_TXT)
  with open('_build/Navigator/Navigator.txt', 'w') as outFile:
    outFile.write(NAVIGATOR_TXT)

with open('Navigator.lua', 'r') as inFile:
  lua = inFile.read()
  lua = re.sub(r'appVersion = "[^"]*"', f'appVersion = "{VERSION}"', lua)
  with open('_build/Navigator/Navigator.lua', 'w') as outFile:
    outFile.write(lua)

shutil.make_archive(f"_build/Navigator-v{VERSION}", 'zip', root_dir='_build', base_dir='Navigator')
