# First it is necessary to install the packages: spacy and xml.etree.ElementTree (collections and pprint are optional)
# for installing spacy : https://spacy.io/usage 
# Import of modules and language models for NER
import spacy
nlp = spacy.load('fr_core_news_lg') #French model
#nlp = spacy.load('en_core_web_trf') #EN model 
#nlp = spacy.load('xx_ent_wiki_sm') # multilingual model 
import pandas as pd 
import numpy as num 
import matplotlib.pyplot as plt
from collections import Counter
#import re
# This module will help us manage the xml structure and use xpath for retreiving the text 
#import xml.etree.ElementTree as ET
# path for the file
file = "Translations_txt/1543_fin_MFalais.txt"
# parsing the file
result = open(file).read()
#print(result)

doc = nlp(result)
# Remove stop words and punctuation symbols and count
lemma = [token.lemma_ for token in doc if not token.is_stop and not token.is_punct]
words = [token.text for token in doc if not token.is_stop and not token.is_punct]
w_list = nlp(" ".join(lemma))
word_freq = Counter(lemma)
#print(word_freq)
# return 5 commonly occurring words with their frequencies
common_words = word_freq.most_common(15)
# corr list (word frequency and word embeddings)
simil = {}
for common in common_words:
    for token in w_list:
        if token.text == common[0]:
            simil[token.text] = [common[1] , token.vector_norm]
#print(word_freq[0])

#Create dataframe of simil (contains the vector values)
df = pd.DataFrame(simil, index=["freq", "vector_n"])
corr = df.corr(method="pearson")
df.to_csv("TextAna_output/1543_fin_MFalaisDF.csv")
print(df)
plot = df.plot.line()
plt.show()


output = "TextAna_output/1543_fin_MFalais.txt"
with open(output, "w", encoding="utf-8") as newfile:
    newfile.write(f"Liste de lemmas : {word_freq} \n\n Mots les plus fréquents : \n {common_words}")


print("Done!")

# Reference : Karajgikar, Jajwalya. s. d. « Guides: Text Analysis: SpaCy Package ». Consulté le 29 janvier 2025. https://guides.library.upenn.edu/penntdm/python/spacy.
