###########################################

# Adapt trainingdata_finetuning_expanded.json to new structure and save as jsonl
# Previous tuning model depricated and new model requires jsonl format and different structure
####### Adding only new data to translation traning set
# pip install saxonche
from saxonche import *
from saxonche import PySaxonProcessor
import json
import re
import os
import xml.etree.ElementTree as ET

input_json = "trainingdata_finetuning_expanded.json"
output_jsonl = "trainingdata_finetuning_expanded.jsonl"
limit = 4000

with open(input_json, "r", encoding="utf8") as f:
    data = json.load(f)

with open(output_jsonl, "a", encoding="utf8") as out_f:
    for item in data:
        input_text = item["input"][:limit]
        output_text = item["output"][:limit]
        user_msg = {
            "role": "user",
            "parts": [{"text": input_text }]
        }
        model_msg = {
            "role": "model",
            "parts": [{"text": output_text}]
        }
        out_f.write(json.dumps({"contents": [user_msg, model_msg]}, ensure_ascii=False) + "\n")
print("Saved as jsonl.")
