####### Adding only new data to translation traning set
# pip install saxonche
from saxonche import *
from saxonche import PySaxonProcessor
import json
import re
import os
import xml.etree.ElementTree as ET
inputpathFr = "output/VF/1542_05_M_le_cureX.xml"  # XML file in French
inputpathEs = "output/VF/es/1542_05_Al_senor_cura.xml" #XML file in Spanish
xsltfileFr = "Translations_txt/2txt.xslt" #path to xslt file
xsltfileEs = "Translations_txt/txtES.xslt"
outpath = "trainingdata_finetuning_expanded.json"

data_file = open("output_finetuning01.json", "r", encoding='utf8')
training_data = json.load(data_file)
#print(training_data)
setfr = []
setes = []
with PySaxonProcessor(license=False) as proc:
                    xsltproc = proc.new_xslt30_processor()
                    dom = proc.parse_xml(xml_file_name=inputpathFr)
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
                    xsltproc = proc.new_xslt30_processor()
                    doc = proc.parse_xml(xml_file_name=inputpathEs)
                    xslt = xsltproc.compile_stylesheet(stylesheet_file=xsltfileEs)
                    output = xslt.transform_to_string(xdm_node=doc)
                    #infile = str(newdom)
                    txtOk = re.sub("\s+\n+\s", "\n\n", output)
                    txtes = re.sub("\s{2,}", "\n", txtOk)
                    setes.append(txtes)

for i in range(len(setfr)):
    for o in range(len(setes)):
        #sets = {}
        limit = 5000
        inputs = []
        outputs = []
        if i == o: # and setfr[i] not in sets and setes[o] not in sets:
            nloopsfr = len(setfr[i])//limit
            textfr = setfr[i]
            nloopses = len(setes[o])//limit
            textEs = setes[o]
            
            for index in range(0,nloopsfr+1):
                milestone = index * limit
                if milestone < len(textfr):
                    substring = textfr[milestone:milestone+limit]
                    subtext = "".join(substring)
                    #print(subtext)
                    inputs.append(subtext)
                            
            #laststr = textfr[limit * nloopsfr - 10:len(textfr)]
            #lasttextfr = "".join(laststr)
            #inputs.append(lasttextfr)
            
            for index in range(0,nloopses+1):
                milestone = index * limit
                if milestone < len(textEs):
                    substring = textEs[milestone:milestone+limit]
                    subtext = "".join(substring)
                    outputs.append(subtext)
                    index = index + limit
            #lastses = textEs[limit * nloopses - 10:len(textEs)]
            #lasttextes = "".join(lastses)
            #outputs.append(lasttextes)
            
            if len(outputs) == len(inputs):
                for inps in range(len(inputs)):
                    for outs in range(len(outputs)):
                        if inps == outs:
                            print(inps, outs)
                            sets = {}
                            sets["input"] = inputs[inps]
                            sets["output"] = outputs[outs]
            #if sets != {}:
                            training_data.append(sets)

#print(training_data)
jsonfile = json.dumps(training_data, indent=3, ensure_ascii = False)
outfile = open(outpath, 'w', encoding='utf8') 
outfile.write(jsonfile)
print("Done!")
