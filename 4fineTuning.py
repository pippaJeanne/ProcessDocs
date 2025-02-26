# pip install saxonche
from saxonche import *
from saxonche import PySaxonProcessor
import json
import re
import os
import xml.etree.ElementTree as ET
inputpathFr = "output/VF/"
inputpathEs = "output/VF/es/"
xsltfileFr = "Translations_txt/2txt.xslt" #path to xslt file
xsltfileEs = "Translations_txt/txtES.xslt"
outpath = "output_finetuning.json"
#doc = "input/0M-Falais24_06_44.xml" #path to input xml file
#slices = doc.split("/")
#name = slices[-1]

#outfile = open(f"{outpath}modernisation/{name}", 'w', encoding='utf8') 
#outfile.write(output)
training_data = []
setfr = []
setes = []
with PySaxonProcessor(license=False) as proc:
    for dirpath, dirnames, filenames in os.walk(inputpathFr):
        filenames.sort()
        for filename in filenames:
               if filename.endswith('.xml'):
                    xsltproc = proc.new_xslt30_processor()
                    dom = proc.parse_xml(xml_file_name=inputpathFr + filename)
                    xslt = xsltproc.compile_stylesheet(stylesheet_file=xsltfileFr)
                    output = xslt.transform_to_string(xdm_node=dom)
                    #infile = str(newdom)
                    txtOk = re.sub("\s+\n+\s", "\n\n", output)
                    txtOk1 = re.sub("\s{2,}", "\n", txtOk)
                    setfr.append(txtOk1)
                    #outName = filename.replace(".xml", ".txt")
                    #outfile = open(outpath , 'w')
                    #outfile.write(txtOk1)

with PySaxonProcessor(license=False) as proc:
    for dirpath, dirnames, filenames in os.walk(inputpathEs):
        filenames.sort()
        for filename in filenames:
               if filename.endswith('.xml'):
                    xsltproc = proc.new_xslt30_processor()
                    doc = proc.parse_xml(xml_file_name=inputpathEs + filename)
                    xslt = xsltproc.compile_stylesheet(stylesheet_file=xsltfileEs)
                    output = xslt.transform_to_string(xdm_node=doc)
                    #infile = str(newdom)
                    txtOk = re.sub("\s+\n+\s", "\n\n", output)
                    txtes = re.sub("\s{2,}", "\n", txtOk)
                    setes.append(txtes)

for i in range(len(setfr)):
     for o in range(len(setes)):
        sets = []
        if i == o and setfr[i] not in sets and setes[o] not in sets:
             sets.append(setfr[i])
             sets.append(setes[o])
        if sets != []:
            training_data.append(sets) 
#print(train_set)
jsonfile = json.dumps(training_data, indent=3, ensure_ascii = False)
outfile = open(outpath, 'w', encoding='utf8') 
outfile.write(jsonfile)
print("Done!")