from google import genai
from google.genai import types
import json
import os

client = genai.Client(api_key=os.environ.get('GEMINI_API_KEY'))
# Get list of tuned models
for model_info in client.tunings.list():
    print(model_info.tuned_model.model)
text = open("Translations_txt/1538_07_10_LuoisDuTillets.txt", "r").read()

# To use base model, uncomment | run following lines.

response = client.models.generate_content(
    model='gemini-2.0-flash', contents=f"Traduis le texte suivant vers l'espagnol.\nTexte : {text}")
with open("Translations_txt/1538_07_10-test.md", "w", encoding="utf8") as outfile:
    outfile.write(response.text)

file = open("output_finetuning.json", "r")
training_dataset = json.load(file)
# print(training_dataset)
#for i in training_dataset:
#    print(len(i["input"]))
#    print(len(i["output"]))

training_dataset=types.TuningDataset(
        examples=[
            types.TuningExample(
                text_input=i["input"],
                output=i["output"],
            )
            for i in training_dataset
        ],
    )
tuning_job = client.tunings.tune(
    base_model='models/gemini-1.5-flash-001-tuning',
    training_dataset=training_dataset,
    config=types.CreateTuningJobConfig(
        epoch_count= 5,
        batch_size=4,
        learning_rate=0.001,
        tuned_model_display_name="trad_Calvin_FR-ES"
    )
)
#for model_info in client.models.list():
#    print(model_info.name)

# text to translate
text = open("Translations_txt/1543_fin_MFalais.txt", "r").read()


# generate content with the tuned model
# Segmenting text to fit the token limit
limit = 4000
nloops = len(text)//limit
# output file
outfile = open("Translations_txt/sectioning_test.txt", "a", encoding="utf8")
for i in range(0,nloops):
    print(i)
    if i < nloops:
        substring = text[i:i+limit]

        response = client.models.generate_content(
            model="tunedModels/tradcalvinfres-zm83p0nr9sh1",
    #model=tuning_job.tuned_model.model,
    contents=f"Traduis le texte suivant vers l'espagnol.\nTexte : {substring}",
)
        outfile.write(response.text)

# Translating remaining text
laststr = text[limit * nloops - 10:len(text)]        
response = client.models.generate_content(
    model="tunedModels/tradcalvinfres-zm83p0nr9sh1",
    #model=tuning_job.tuned_model.model,
    contents=f"Traduis le texte suivant vers l'espagnol.\nTexte : {laststr}",
)
outfile.write(f"\n {response.text}")


# Segmenting text to fit the token limit
#limit = 4000
#nloops = len(text)//limit
# rest = len(text1) - (limit * nloops)
#for i in range(0,nloops):
    #if i < nloops:
        #substring = text[i:i+limit]
        # print(substring)
#        outfile = open("Translations_txt/sectioning_test.txt", "a", encoding="utf8")
        #outfile.write(substring)
#laststr = text[limit * nloops - 10:len(text)]
# print(laststr)
# outfile.write(f"\n {laststr}")


