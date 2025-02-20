# pip install saxonche
from saxonche import *
from saxonche import PySaxonProcessor
inputpath = "input/"
xsltfile = "Modernisation/modernisation.xslt" #path to xslt file
outpath = "output/"
doc = "input/0M-Falais24_06_44.xml" #path to input xml file
slices = doc.split("/")
name = slices[-1]
# Create a Saxon processor instance
with PySaxonProcessor(license=False) as proc:
   xsltproc = proc.new_xslt30_processor()
   document = proc.parse_xml(xml_file_name=doc)
   executable = xsltproc.compile_stylesheet(stylesheet_file=xsltfile)
   output = executable.transform_to_string(xdm_node=document)
   #write name of output file
   outfile = open(f"{outpath}modernisation/{name}", 'w', encoding='utf8') 
   outfile.write(output)
print("Done!")
#for dirpath, dirnames, filenames in os.walk(inputpath):
#         for filename in filenames:
#               if filename.endswith('.xml'):
#                    dom = ET.parse(inputpath + filename)
#                    xslt = ET.parse(xsltfile)
#                    transform = ET.XSLT(xslt)
#                   newdom = transform(dom)
#                    infile = str(newdom)
#                    outfile = open(f"{outpath} + {filename}", 'a')
#                    outfile.write(infile)
#print("Done!")