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

###########
# Translating a short text with the base model
translate = open("2translateFR.txt", "r").read()
response = client.models.generate_content(
            model="gemini-2.5-flash",
    #model=tuning_job.tuned_model.model,
    contents=f"Traduis le texte suivant vers l'espagnol.\nTexte : {translate}",
)
outputfile = open("0utputTrans.txt", "w", encoding="utf8")
outputfile.write(response.text)
print("Done!")