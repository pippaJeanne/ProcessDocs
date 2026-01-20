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

template = open("templateEncodage.xml", "r").read()
text = open("ToProcess.txt", "r").read()

response = client.models.generate_content(
    model='gemini-2.5-flash', contents=f"En prenant le modèle d'encodage TEI dans {template}, prends le texte océrisé dans {text} et fais l'encodage TEI du text océrisé en suivant le modèle fourni. Produis le contenu dans un fichier XML-TEI.")
with open("input/1545_08_05_MFallais.xml", "w", encoding="utf8") as outfile:
    outfile.write(response.text) #change name of file following the model => 1538_10_20_NomDestinataire.xml

#####
    # To help in the encoding of the structure of set of letters given the template with the editorial protocol 
for i in range(1,4): #number for last argument of range depends on number of letters in the 'text' doc plus 1 (no index 0).
    template = open("templateEncodage.xml", "r").read()
    text = open("ToProcess.txt", "r").read()

    response = client.models.generate_content(
        model='gemini-2.5-flash', contents=f"En prenant le modèle d'encodage TEI dans {template}, prends le texte océrisé dans {text} de la lettre correspondant au numéro {i} en ordre (les lettres ont été divisées par des lignes pointillées) et fais l'encodage TEI du text océrisé en suivant le modèle fourni. Produis le contenu dans un fichier XML-TEI.")
    with open(f"input/{i}.xml", "w", encoding="utf8") as outfile:
        outfile.write(response.text) #change name of file following the model => 1538_10_20_NomDestinataire.xml
