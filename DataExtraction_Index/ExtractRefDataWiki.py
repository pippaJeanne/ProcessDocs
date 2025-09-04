import xml.etree.ElementTree as tree
import json
from os import listdir # install the "listdir" package (pip install dirlist)
from os.path import isfile, join
files =[]
dir = "output/VF/es"
for file in listdir(dir): 
    if isfile(join(dir, file)):
        files.append(dir + "/" + file)
for f in files:
    if ".xml" not in f:
        files.remove(f)
files.sort()


result = {}

def compile():
    for file in files:
        result[file] = {}
        root = tree.parse(file)
        string = ""
        result[file]["persons"] = {}
        #result[file]["persons"]["sender"] = {}
        #result[file]["persons"]["other"] = {}
        result[file]["places"] = {}
        #result[file]["org"] = {}
        #no = ""
        #bibtitle = ""

        for el in root.findall(".//{http://www.tei-c.org/ns/1.0}addrLine/{http://www.tei-c.org/ns/1.0}persName[@key]"):
            key = el.get('key')
            ref = el.get('ref')
            if key is not None and ref is not None:
                result[file]["persons"][key] = ref

        for el in root.findall(".//{http://www.tei-c.org/ns/1.0}body/{http://www.tei-c.org/ns/1.0}p/{http://www.tei-c.org/ns/1.0}persName[@key]"):
            key = el.get('key')
            ref = el.get('ref')
            if key is not None and ref is not None:
                result[file]["persons"][key] = ref

        for el in root.findall(".//{http://www.tei-c.org/ns/1.0}signed/{http://www.tei-c.org/ns/1.0}persName[@key]"):
            key = el.get('key')
            ref = el.get('ref')
            if key is not None and ref is not None:
                result[file]["persons"][key] = ref
        
        for el in root.findall(".//{http://www.tei-c.org/ns/1.0}correspAction//{http://www.tei-c.org/ns/1.0}settlement"):
            string = el.get('key')
            ref = el.get('ref')
            #type = el.get('type')
            #country = el.get('corresp')
            if key is not None and ref is not None:
                result[file]["places"][string] = ref
            #result[file]["places"][string]["type"] = type
            #result[file]["places"][string]["country"] = country
        for el in root.findall(".//{http://www.tei-c.org/ns/1.0}placeName[@key]"):
            string = el.get('key')
            ref = el.get('ref')
            #type = el.get('type')
            #country = el.get('corresp')
            if key is not None and ref is not None:
                result[file]["places"][string] = ref

        #for el in root.findall(".//{http://www.tei-c.org/ns/1.0}div2//{http://www.tei-c.org/ns/1.0}orgName"):
            #key = el.get('key')
            #string = el.get('ref')
            #if key is not None and string is not None:
                #result[file]["org"][key] = string
           # else:
              #  string = el.text
              #  result[file]["org"][string] = string
          
    return result


jsonfile = compile()
print(jsonfile)
json_obj = json.dumps(jsonfile, indent=7, ensure_ascii = False)
with open("data_json/wikiIds_es.json", "w") as outfile:
    outfile.write(json_obj)
    print("Done!")
