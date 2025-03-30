import re
import json
import subprocess
import glob

def convert(lang):
    print(f"Importing {lang}...")
    with open(f'{lang}.json', 'r', errors='ignore', encoding='utf-8') as json_file:
        data = json.load(json_file)

        with open(f'../../lang/{lang}.lua', 'r', errors='ignore', encoding='utf-8') as lua_file:
            lua_lines = lua_file.readlines()

        with open(f'../../lang/{lang}.lua', 'w', errors='ignore', encoding='utf-8') as lua_file:
            for line in lua_lines:
                match = re.search(r'^-?-?(\s*mkstr\(")(.*?)(",\s*")(.*?[^\\])(".*)', line)
                if match:
                    key = match.group(2)
                    if key in data:
                        value = data[key]
                        del data[key]
                        value = re.sub(r'"', r'\\"', value)
                        comment_prefix = ""
                    else:
                        value = match.group(4)
                        comment_prefix = "--"

                    line = f"{comment_prefix}{match.group(1)}{key}{match.group(3)}{value}{match.group(5)}\n"

                lua_file.write(line)

        for key, value in data.items():
            print(f"{lang}: Missing Lua line for '{key}")

try:
    result = subprocess.run("tolgee pull", shell=True, check=True, text=True, capture_output=True)
    # Print the output of the command
    print("Output:\n", result.stdout)
    if result.stderr:
        print("Error:\n", result.stderr)
except subprocess.CalledProcessError as e:
    print(f"An error occurred: {e}")

for file in glob.glob(r'??.json'):
    file_lang = file[:2]
    convert(file_lang)