import glob
import subprocess
import shutil
import os
import sys
import re

def copy(wildcard, dest):
    for file in glob.glob(wildcard):
        shutil.copy(file, dest)


def push(dest_dir):
    if os.path.exists(dest_dir):
        shutil.rmtree(dest_dir)

    os.mkdir(dest_dir)

    copy(r'*.lua', dest_dir)
    copy(r'*.txt', dest_dir)
    copy(r'*.xml', dest_dir)

    shutil.copytree('media', f'{dest_dir}/media')
    shutil.copytree('lang', f'{dest_dir}/lang')


def get_tag():
    result = subprocess.run(['git', 'tag', '-l', '--contains', 'HEAD'], stdout=subprocess.PIPE)
    version = result.stdout[1:].decode('utf-8').strip()
    return version


def convert_to_addon_version(version):
    version_match = re.search(r"^(\d+)\.(\d+)\.(\d+)", version)
    addon_version = int(version_match.group(1))*10000 + int(version_match.group(2))*100 + int(version_match.group(3))
    return addon_version


def get_line(file_string, prefix):
    lines = file_string.splitlines()
    for line in lines:
        if line.startswith(prefix):
            return line[len(prefix):].strip()
    return None


def get_other_addon_version(addon_name):
    home_dir = os.path.expanduser("~")
    with open(f"{home_dir}/Documents/Elder Scrolls Online/live/AddOns/{addon_name}/{addon_name}.txt", 'r') as file:
        txt = file.read()
        ver_line = get_line(txt, "## AddOnVersion:")
        return ver_line


def check_dependencies(depends_prefix):
    with open('Navigator.txt', 'r') as file:
        txt = file.read()
        depends_on_line = get_line(txt, depends_prefix)
        if not depends_on_line:
            print("🛑 No OptionalDependsOn line found", file=sys.stderr)
            exit(1)
        components = depends_on_line.split()
        split_items = [item.split(">=") for item in components]
        for name, version in split_items:
            current_version = get_other_addon_version(name)
            if version != current_version:
                print(f"⚠️ Addon {name} version mis-match: ours: {version}, theirs: {current_version}", file=sys.stderr)
