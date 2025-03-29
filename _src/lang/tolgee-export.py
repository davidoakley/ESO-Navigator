import re
import json
import subprocess
import glob

def convert(lang):
    with open(f'../../lang/{lang}.lua', 'r', errors='ignore', encoding='utf-8') as inFile:
        lines = inFile.readlines()
        dict = {}
        for line in lines:
            match = re.search(r'^\s*mkstr\("(.*?)",\s*"(.*?[^\\])"', line)
            if match:
                s = match.group(2)
                # s = re.sub(r'<<([^>]+)>>', r'<\1>', s)
                s = re.sub(r'\\"', r'"', s)
                # print(match.group(1) + ': "' + match.group(2) + '"')
                dict[match.group(1)] = s

        with open(f"{lang}.json", 'w', encoding='utf-8') as json_file:
            json_file.write('\ufeff')
            json.dump(dict, json_file, indent=4, ensure_ascii=False)

for file in glob.glob(r'../../lang/*.lua'):
    file_lang = file[11:13]
    convert(file_lang)

try:
    result = subprocess.run("tolgee push", shell=True, check=True, text=True, capture_output=True)
    # Print the output of the command
    print("Output:\n", result.stdout)
    if result.stderr:
        print("Error:\n", result.stderr)
except subprocess.CalledProcessError as e:
    print(f"An error occurred: {e}")