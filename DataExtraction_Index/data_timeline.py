import xml.etree.ElementTree as tree
import json
from os import listdir # install the "listdir" package (pip install dirlist)
from os.path import isfile, join
with open("data_json/placeData_MapIndex.json", "r") as indexData:
  placedata = json.load(indexData)
files =[]
dir = "output/VF"
for file in listdir(dir): 
    if isfile(join(dir, file)):
        files.append(dir + "/" + file)
for f in files:
    if ".xml" not in f:
        files.remove(f)
files.sort()

result = {}
arr = []
#result["events"] = arr
#print(files)
def compile():
    for file in files:
        #result["events"] = {}
        root = tree.parse(file)
        obj = {}
        f = file.split("/")
        filename = f[-1]
        slug = filename.replace(".xml", "")
        #obj["slug"] = slug

        for el in root.findall(".//{http://www.tei-c.org/ns/1.0}facsimile[1]/{http://www.tei-c.org/ns/1.0}graphic[1]"):
            url = el.get('url')
            img = url.replace("/info.json", ".jpeg").replace("iiif/", "")
            if url is not None and img is not None:
                obj["media"] = {}
                obj["media"]["url"] = img
                obj["media"]["thumbnail"] = img
        for el in root.findall(".//{http://www.tei-c.org/ns/1.0}correspAction[@type='sent']//{http://www.tei-c.org/ns/1.0}date"):
            date = el.get('when')
            text = el.text
            if date is not None:
                obj["start_date"] = {}
                prep = date.split("-")
                if (len(prep) == 3):
                    year = prep[0]
                    month = prep[1]
                    day = prep[2]
                    obj["start_date"]["year"] = year
                    obj["start_date"]["month"] = month
                    obj["start_date"]["day"] = day
                if (len(prep) == 2):
                    year = prep[0]
                    month = prep[1]
                    obj["start_date"]["year"] = year
                    obj["start_date"]["month"] = month 
                    obj["start_date"]["day"] = "01"
                elif (len(prep) == 1):
                    year = prep[0]
                    obj["start_date"]["year"] = year
                    obj["start_date"]["month"] = "01"  # default value
                    obj["start_date"]["day"] = "01" # default value
                obj["display_date"] = text
        for el in root.findall(".//{http://www.tei-c.org/ns/1.0}correspAction[@type='received']//{http://www.tei-c.org/ns/1.0}name"):
            obj["text"] = {}
            addressee = el.text
            #print(addressee)
            obj["text"]["headline"] = addressee
        for el in root.findall(".//{http://www.tei-c.org/ns/1.0}desc"):
            desc = el.text
            obj["text"]["text"] = f"<div><p>{desc}</p><p style='text-align:right !important; font-size:1.5rem'><a href='/fr/lettres/{slug}' style='color: #2b2b28 !important;'>Accès à la lettre</a></p></div>" 
        for el in root.findall(".//{http://www.tei-c.org/ns/1.0}facsimile[1]/{http://www.tei-c.org/ns/1.0}graphic[1]"):
            url = el.get('url')
            img = url.replace("/info.json", ".jpeg").replace("iiif/", "")
            if url is not None and img is not None:
                obj["background"] = {}
                obj["background"]["url"] = img
                obj["background"]["color"] = "#5e5e52"

        print(obj)
        arr.append(obj)
    result["events"] = arr
    result["era"] = {
        "start_date" : {
            year : 1538,
            month : 1,
            day : 1
        },
        "end_date" : {
            year : 1554,
            month : 1,
            day : 1
        },
        "text" : "<h2>Lettres par ordre chronologique</h2>"
    }
    return result

jsonfile = compile()
print(jsonfile)
json_obj = json.dumps(jsonfile, indent=7, ensure_ascii = False)
with open("data_json/data_timeline.json", "w") as outfile:
    outfile.write(json_obj)
    print("Done!")
