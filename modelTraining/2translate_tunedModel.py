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

# Using the tuned model for translation

## Model enpoint name: change every time the model is retuned
tuned_model_endpoint = "projects/308230719741/locations/us-central1/endpoints/3209442555640938496"

### text to translate 
texts = ["Translations_txt/1540_07_28_DuTailly.txt"] #Change file path(s)

for textfile in texts:
    print(f"Processing file: {textfile}")
    with open(textfile, "r", encoding="utf8") as f:
        text = f.read()
    # generate content with the tuned model
    # Segmenting text to fit the token limit
        limit = 3700
        nloops = len(text)//limit
        # output file | change name of file following the model => 1538_10_20_NomDestinataireES.txt
        print(f"Total length of text: {len(text)} characters.")
        outfile = open(f"Translations_txt/{textfile.split('/')[-1].replace('.txt', '_ES.txt')}", "a", encoding="utf8")
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
                time.sleep(20)  # To avoid hitting rate limits
print("Translation with tuned model done!")
