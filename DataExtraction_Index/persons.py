import xml.etree.ElementTree as tree
import json
#from os import listdir # install the "listdir" package (pip install dirlist)
from os.path import isfile, join
persdata = {}
with open("data_json/persIndex.json", "r") as indexData:
  persdata = json.load(indexData)
perfile = {}
with open("data_json/wikiIds.json", "r") as data:
  perfile = json.load(data) 
# Preparing data for query
# Getting access keys 
files = perfile.keys()
#persons = {}
# Organize according to service : dbpedia or wikidata 

arr = []
obj = {}

for pers in persdata:
    obj = {}
    name = pers["name"]
    thumbnail = pers["img"]
    desc = pers["desc"]
    obj["name"] = name
    obj["thumbnail"] = thumbnail
    obj["desc"] = desc
    obj["letters"] = []
    url = pers["url"]
    prep = url.split("/")
    id = prep[-1]
    #check = []
    for f in files:
        names = list(perfile[f]["persons"].keys())
        if names is not None:
            for n in names:
                url_check = perfile[f]["persons"][n]
                prep0 = url_check.split("/")
                idcheck = prep0[-1]
                if name.__contains__(n):
                    root = tree.parse(f)
                    corresp = ""
                    for el in root.findall(".//{http://www.tei-c.org/ns/1.0}persName[@corresp]"):
                        if el.get("key") in n:
                            corresp = el.get("corresp")
                        if corresp is not None:
                            obj["id"] = corresp
                    letter = {}
                    #root = tree.parse(f)
                    file = f.split("/")
                    filename = file[-1]
                    slug = filename.replace(".xml", "")
                    letter["slug"] = slug
                    for el in root.findall(".//{http://www.tei-c.org/ns/1.0}correspAction[@type='sent']//{http://www.tei-c.org/ns/1.0}date"):
                        #date = el.get('when')
                        text = el.text
                        if text is not None:
                            letter["date"] = text
                    for el in root.findall(".//{http://www.tei-c.org/ns/1.0}correspAction[@type='received']//{http://www.tei-c.org/ns/1.0}name"):
                        addressee = el.text
                        #print(addressee)
                        letter["headline"] = addressee

                    obj["letters"].append(letter)
        #print(check)           


    #print(obj)
    if obj not in arr and obj["letters"] != [] and obj["id"] != "":
        arr.append(obj)
result = {}
result["persons"] = arr
print(result)
json_obj = json.dumps(result, indent=7, ensure_ascii = False)
with open("data_json/persons.json", "w") as outfile:
    outfile.write(json_obj)
    print("Done!")     
