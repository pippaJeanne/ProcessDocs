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

######### For finetuning the model
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
