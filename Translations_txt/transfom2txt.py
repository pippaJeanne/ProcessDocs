# pip install saxonche
from saxonche import *
from saxonche import PySaxonProcessor
import re
#path to input xml file
doc = "output/VF/1538_07_10_LuoisDuTillets.xml" #Change file path
slices = doc.split("/")
name = slices[-1].replace(".xml",".txt") #Change format txt | md
print(name)
xsltfile = "Translations_txt/2txt.xslt" #path to xslt file
outpath = "Translations_txt/"

# Create a Saxon processor instance
with PySaxonProcessor(license=False) as proc:
   xsltproc = proc.new_xslt30_processor()
   document = proc.parse_xml(xml_file_name=doc)
   executable = xsltproc.compile_stylesheet(stylesheet_file=xsltfile)
   output = executable.transform_to_string(xdm_node=document)
   #write name of output file
   txtOk = re.sub("\s+\n+\s", "\n\n", output)
   txtOk1 = re.sub("\s{2,}", "\n", txtOk)
   outfile = open(f"{outpath}{name}", 'w', encoding='utf8')
   outfile.write(txtOk1)
   
print("Done!")