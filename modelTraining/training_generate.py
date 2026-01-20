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

# Get list of tuned models
for model_info in client.tunings.list():
    print(model_info.tuned_model.model)

# Use base model
### To help in the encoding of the structure of the letter given the template with the editorial protocol
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

#####    
# text to translate
text = open("Translations_txt/1545_04_28_ReineNavarre.txt", "r").read()

# generate content with the tuned model
# Segmenting text to fit the token limit
limit = 4000
nloops = len(text)//limit

# output file | change name of file following the model => 1538_10_20_NomDestinataireES.txt
outfile = open("Translations_txt/1545_04_28_ReineNavarreES.txt", "a", encoding="utf8")
for i in range(nloops+1):
    milestone = i * limit
    if milestone < len(text):
        substring = text[milestone:milestone+limit]
        #i = i + limit
    #if i < nloops:
    #    substring = text[i:i+limit]
        
        response = client.models.generate_content(
            model="gemini-2.5-flash",
    #model=tuning_job.tuned_model.model,
    contents=f"Traduis le texte suivant vers l'espagnol.\nTexte : {substring}",
)
        outfile.write(response.text)


###########
# Translating a short text with the base model
translate = open("2translateFR.txt", "r").read()
response = client.models.generate_content(
            model="gemini-2.5-flash",
    #model=tuning_job.tuned_model.model,
    contents=f"Traduis le texte suivant vers français.\nTexte : {translate}",
)
outputfile = open("0utputTrans.txt", "w", encoding="utf8")
outputfile.write(response.text)


######### For finetuning the model

#file = open("trainingdata_finetuning_expanded.jsonl", "r") #dataset
#training_dataset = json.load(file)
#print(training_dataset)
#To check length of strings (has to be < 4000)
#for i in range(len(training_dataset)):
 #   print(f"{i} {len(training_dataset[i]['input'])}")
  #  print(f"{i} {len(training_dataset[i]['output'])}")
    
PROJECT_ID = os.environ.get('GOOGLE_CLOUD_PROJECT')  # Replace with your Google Cloud project ID

vertexai.init(project=PROJECT_ID, location="us-central1")

sft_tuning_job = sft.train(
  source_model="translation-llm-002",
    train_dataset="gs://training-data-calvin/trainingdata_finetuning_expanded.jsonl",
    # The following parameters are optional
    #validation_dataset="gs://cloud-samples-data/ai-platform/generative_ai/gemini-2_0/text/sft_validation_data.jsonl",
    tuned_model_display_name="CalvinFrenchSpanish_v2",
)

# Polling for job completion
while not sft_tuning_job.has_ended:
  time.sleep(60)
  sft_tuning_job.refresh()

print(sft_tuning_job.tuned_model_name)
print(sft_tuning_job.tuned_model_endpoint_name)
#print(sft_tuning_job.experiment)

#sft_tuning_job = sft.SupervisedTuningJob("projects/<PROJECT_ID>/locations/us-central1/tuningJobs/<TUNING_JOB_ID>")

######################
# Using the tuned model for translation
### text to translate 
text = open("Translations_txt/1544_06_24_MFallais.txt", "r").read()

## Model enpoint name: to use if value not stored above
tuned_model_endpoint = "projects/308230719741/locations/us-central1/endpoints/3209442555640938496"

# generate content with the tuned model
# Segmenting text to fit the token limit
limit = 3700
nloops = len(text)//limit
# output file | change name of file following the model => 1538_10_20_NomDestinataireES.txt
print(f"Total length of text: {len(text)} characters.")
outfile = open("Translations_txt/1544_06_24_MFallais_ES.txt", "a", encoding="utf8")
for i in range(nloops+1):
    milestone = i * limit
    if milestone < len(text):
        substring = text[milestone:milestone+limit]
        contents= substring
        print(f"Processing chunk {i+1} with {len(contents)} characters.")
        # 'tuned_model_endpoint' if not stored above | 'sft_tuning_job.tuned_model_endpoint_name' if model has just been tuned
        tuned_model = GenerativeModel(tuned_model_endpoint)
        response = tuned_model.generate_content(contents)
        #print(response.text)
        outfile.write(response.text)
print("Translation with tuned model done!")

# Check models list
for model_info in client.models.list():
    print(model_info.name)


 # To help in the encoding of the structure of set of letters (Spanish translation) given the template with the editorial protocol 

# List of translated texts to process
traslations = ["Translations_txt/1545_04_28_ReineNavarre_ES.txt"]
reference = ["output/VF/1545_04_28_ReineNavarre.xml"] #List of references in French already encoded in TEI

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
                model='gemini-2.5-flash', contents=f"En prenant le modèle d'encodage TEI dans {template} et la référence dans {reference_content}, prends la traduction dans {text} de la lettre et fais l'encodage TEI de la traduction en suivant le modèle fourni. Produis le contenu dans un fichier XML-TEI.")
            with open(f"output/VF/es/{name}", "w", encoding="utf8") as outfile:
                outfile.write(response.text)
            print("Done!")
            time.sleep(20) #to avoid sending requests too quickly
