import xml.etree.ElementTree as tree
import json
from os import listdir # install the "listdir" package (pip install dirlist)
from os.path import isfile, join
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
        obj["slug"] = slug

        for el in root.findall(".//{http://www.tei-c.org/ns/1.0}facsimile[1]/{http://www.tei-c.org/ns/1.0}graphic[1]"):
            url = el.get('url')
            img = url.replace("/info.json", ".jpeg")
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
                elif (len(prep) == 2):
                    year = prep[0]
                    month = prep[1]
                    obj["start_date"]["year"] = year
                    obj["start_date"]["month"] = month 
                    obj["start_date"]["day"] = "01"
                obj["display_date"] = text
        for el in root.findall(".//{http://www.tei-c.org/ns/1.0}correspAction[@type='received']//{http://www.tei-c.org/ns/1.0}name"):
            obj["text"] = {}
            addressee = el.text
            #print(addressee)
            obj["text"]["headline"] = addressee
        for el in root.findall(".//{http://www.tei-c.org/ns/1.0}desc"):
            desc = el.text
            obj["text"]["text"] = desc
        for el in root.findall(".//{http://www.tei-c.org/ns/1.0}correspAction[@type='sent']//{http://www.tei-c.org/ns/1.0}settlement"):
            obj["scr_location"] = {}
            placeSrc = el.text
            #print(placeSrc)
            obj["scr_location"]["name"] = placeSrc
            obj["scr_location"]["lat"] = ""
            obj["scr_location"]["lon"] = ""

        for el in root.findall(".//{http://www.tei-c.org/ns/1.0}correspAction[@type='received']//{http://www.tei-c.org/ns/1.0}settlement"):
            obj["dest_location"] = {}
            placeD = el.text
            #print(placeD)
            obj["dest_location"]["name"] = placeD
            obj["dest_location"]["lat"] = ""
            obj["dest_location"]["lon"] = ""

        print(obj)
        arr.append(obj)
    result["events"] = arr
    return result

jsonfile = compile()
print(jsonfile)
json_obj = json.dumps(jsonfile, indent=7, ensure_ascii = False)
with open("data_json/data_carte.json", "w") as outfile:
    outfile.write(json_obj)
    print("Done!")
