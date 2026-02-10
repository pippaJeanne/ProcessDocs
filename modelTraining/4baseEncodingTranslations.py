from google import genai
from google.genai import types
import time
from google import genai
#from google.genai.types import HttpOptions, CreateTuningJobConfig, TuningDataset, TuningExample
import vertexai
from vertexai.generative_models import GenerativeModel
from vertexai.tuning import sft
from dotenv import load_dotenv
load_dotenv()
import json
import os
client = genai.Client(api_key=os.environ.get('GEMINI_API_KEY'))

 # To help in the encoding of the structure of set of letters (Spanish translation) given the template with the editorial protocol 

# List of translated texts to process
traslations = ["Translations_txt/1538_10_01_EgliseGeneve_ES.txt", "Translations_txt/1540_07_28_DuTailly_ES.txt"] #List of translated texts in Spanish
reference = ["output/VF/1538_10_01_EgliseGeneve.xml","output/VF/1540_07_28_DuTailly.xml"] #List of references in French already encoded in TEI

for doc in traslations:
    for ref in reference:
        if doc.split("/")[-1].split("_ES.")[0] in ref:
            print("doc and ref match")            
            slices = doc.split("/")
            name = slices[-1].replace(".txt",".xml") #Change format txt | xml
            print(name)
            
            text = open(doc, "r").read()

            template = open("templateXMLes.xml", "r").read()
            reference_content = open(ref, "r").read()

            response = client.models.generate_content(
                model='gemini-2.5-flash', contents=f"En prenant le modèle d'encodage TEI dans {template} et la version original en français dans {reference_content}, prends la traduction dans {text} de la lettre et fais l'encodage TEI de la traduction en suivant strictement le modèle fourni en {template}. Produis le contenu dans un fichier XML-TEI.")
            with open(f"output/VF/es/{name}", "w", encoding="utf8") as outfile:
                outfile.write(response.text)
            print("Done!")
            time.sleep(20) #to avoid sending requests too quickly
