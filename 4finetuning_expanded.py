####### Adding only new data to translation traning set
# pip install saxonche
from saxonche import *
from saxonche import PySaxonProcessor
import json
import re
import os
import xml.etree.ElementTree as ET
inputpathFr = "Translations_txt/1551_01_19_Richard_Le_Fevre.txt"  # txt file used for translation in French or XML file in French 
inputpathEs = "Translations_txt/1551_01_19_Richard_Le_Fevre_ES.txt" # txt file in Spanish used for translation or XML file in Spanish 

# Use (uncomment) if the XML files are used instead of the txt ones
# xsltfileFr = "Translations_txt/2txt.xslt" #path to xslt file
# xsltfileEs = "Translations_txt/txtES.xslt"


#outpath = "trainingdata_finetuning_expanded.json"
output_jsonl = "trainingdata_finetuning_expanded.jsonl"
out_f = open(output_jsonl, "a", encoding="utf8")

#data_file = open("output_finetuning01.json", "r", encoding='utf8')
#training_data = json.load(data_file)
#print(training_data)
setfr = []
setes = []

# Use / Uncomment if using XML files and not the txt files
#with PySaxonProcessor(license=False) as proc:
#                    xsltproc = proc.new_xslt30_processor()
#                    dom = proc.parse_xml(xml_file_name=inputpathFr)
#                    xslt = xsltproc.compile_stylesheet(stylesheet_file=xsltfileFr)
#                    output = xslt.transform_to_string(xdm_node=dom)
                   
#                    txtOk = re.sub("\s+\n+\s", "\n\n", output)
#                    txtOk1 = re.sub("\s{2,}", "\n", txtOk)
#                    txtOK2 = re.sub("\n\n", "\n\n", txtOk1)
#                    setfr = txtOk2.split("\n\n")
                    

#with PySaxonProcessor(license=False) as proc:
#                    xsltproc = proc.new_xslt30_processor()
#                    doc = proc.parse_xml(xml_file_name=inputpathEs)
#                    xslt = xsltproc.compile_stylesheet(stylesheet_file=xsltfileEs)
#                    output = xslt.transform_to_string(xdm_node=doc)
                   
#                    txtOk = re.sub("\s+\n+\s", "\n\n", output)
#                    txtOkes1 = re.sub("\s{2,}", "\n", txtOk)
#                    txtOKes2 = re.sub("\n\n", "\n\n", txtOkes1)
#                    setes = txtOKes2.split("\n\n")

# Use if using the txt files
doc_fr = open(inputpathFr, "r").read()
txtOK = re.sub("\n\n", "\n\n", doc_fr)
setfr = txtOK.split("\n\n")
print(setfr)
doc_es = open(inputpathEs, "r").read()
txtOKes = re.sub("\n\n", "\n\n", doc_es)
setes = txtOKes.split("\n\n")

# Segmenting by paragraphs, still check to fit API token limits (4000)
print(len(setfr), len(setes))
for i in range(len(setfr)):
    for o in range(len(setes)):
        #sets = {}
        limit = 4000
        inputs = []
        outputs = []
        if i == o: # and setfr[i] not in sets and setes[o] not in sets:
            nloopsfr = len(setfr[i])//limit
            print(f"n loops fr => {nloopsfr}")
            textfr = setfr[i]
            nloopses = len(setes[o])//limit
            print(f"n loops es => {nloopses}")
            textEs = setes[o]
            
            for index in range(0,nloopsfr+1):
                milestone = index * limit
                print(f"index: {index}, milestone: {milestone}")
                if milestone < len(textfr):
                    print(f"[{milestone} : {milestone+limit}]")
                    substring = textfr[milestone:milestone+limit]
                    subtext = "".join(substring)
                    #print(subtext)
                    inputs.append(subtext)
                    #print(inputs)        
            #laststr = textfr[limit * nloopsfr - 10:len(textfr)]
            #print(f"[{limit * nloopsfr - 10} : {len(textfr)}]")
            #lasttextfr = "".join(laststr)
            #inputs.append(lasttextfr)
            
            for index in range(0,nloopses+1):
                milestone = index * limit
                print(f"index: {index}, milestone: {milestone}")
                if milestone < len(textEs):
                    print(f"[{milestone} : {milestone+limit}]")
                    substring = textEs[milestone:milestone+limit]
                    subtext = "".join(substring)
                    outputs.append(subtext)
                    #print(outputs)
            #lastses = textEs[limit * nloopses - 10:len(textEs)]
            #print(f"[{limit * nloopses - 10} : {len(textEs)}]")
            #lasttextes = "".join(lastses)
            #outputs.append(lasttextes)

            print(len(outputs), len(inputs))
            if len(outputs) == len(inputs):
                print(len(outputs), len(inputs))
                for inps in range(len(inputs)):
                    for outs in range(len(outputs)):
                        if inps == outs:
                            #print(inps, outs)
                            #sets = {}
                            #sets["input"] = inputs[inps]
                            #sets["output"] = outputs[outs]
            #if sets != {}:
                            #training_data.append(sets)

#print(training_data)
                            user_msg = {"role": "user","parts": [{"text": inputs[inps] }]}
                            print(f"input => {user_msg}")
                            model_msg = {"role": "model","parts": [{"text": outputs[outs]}]}
                            print(f"output => {model_msg}")
                            out_f.write(json.dumps({"contents": [user_msg, model_msg]}, ensure_ascii=False) + "\n")
print(f"Saved as jsonl.")
                           

#jsonfile = json.dumps(training_data, indent=3, ensure_ascii = False)
#outfile = open(outpath, 'w', encoding='utf8') 
#outfile.write(jsonfile)
#print("Done!")
