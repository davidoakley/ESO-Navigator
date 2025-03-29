import re
import json
import subprocess
import glob

def convert(lang):
    with open(f'{lang}.json', 'r', errors='ignore', encoding='utf-8') as json_file:
        data = json.load(json_file)

        with open(f'../../lang/{lang}.lua', 'r', errors='ignore', encoding='utf-8') as lua_file:
            lua_lines = lua_file.readlines()

        with open(f'../../lang/{lang}.lua', 'w', errors='ignore', encoding='utf-8') as lua_file:
            for line in lua_lines:
                match = re.search(r'^(\s*mkstr\(")(.*?)(",\s*")(.*?[^\\])(".*)', line)
                if match:
                    key = match.group(2)
                    value = data[key]
                    value = re.sub(r'"', r'\\"', value)
                    line = f"{match.group(1)}{key}{match.group(3)}{value}{match.group(5)}\n" #re.sub(r'^(\s*mkstr\(".*?",\s*"(.*?[^\\])', data[key], line)
                    del data[key]

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