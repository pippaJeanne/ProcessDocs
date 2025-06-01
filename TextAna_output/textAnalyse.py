# First it is necessary to install the packages: spacy and xml.etree.ElementTree (collections and pprint are optional)
# for installing spacy : https://spacy.io/usage 
# Import of modules and language models for NER
import spacy
nlp = spacy.load('fr_core_news_lg') #French model
#nlp = spacy.load('en_core_web_trf') #EN model 
#nlp = spacy.load('xx_ent_wiki_sm') # multilingual model 
import pandas as pd 
import numpy as num 
#import scipy.stats.stats
import matplotlib.pyplot as plt
from collections import Counter
from collections import defaultdict
#import re
# This module will help us manage the xml structure and use xpath for retreiving the text 
#import xml.etree.ElementTree as ET
# path for the file
file = "Translations_txt/1542_05_M_le_curéX.txt"
# parsing the file
result = open(file).read()
#print(result)

doc = nlp(result)
# Remove stop words and punctuation symbols and count
lemma = [token.lemma_ for token in doc if not token.is_stop and not token.is_punct and token.is_alpha and "\n" not in token.lemma_ ]
words = [token.text for token in doc if not token.is_stop and not token.is_punct]
w_list = nlp(" ".join(lemma))
word_freq = Counter(lemma)
#print(lemma)
# return 5 commonly occurring words with their frequencies
common_words = word_freq.most_common(12)
print(common_words)
# corr list (word frequency and word embeddings)
simil = {}
simil1 = {}
terms = []
freq = []
vectors = []
for common in common_words:
    for token in w_list:
        if token.text == common[0] and token.text not in terms:
            terms.append(token.text)
            freq.append(common[1])
            vectors.append(token.vector_norm)
for common in common_words:
    for token in w_list:
        if token.text == common[0]:
            simil1[token.text] = [common[1], token.vector_norm]
simil["terms"] = terms
simil["freq"] = freq
simil["vector_val"] =vectors
print(simil1)
            
output = "TextAna_output/1542_05_M_le_curéX.txt"
with open(output, "w", encoding="utf-8") as newfile:
    newfile.write(f"Liste de lemmas : {word_freq} \n\n Mots les plus fréquents : \n {common_words}")

#Create dataframe of simil (contains the vector values)
df1 = pd.DataFrame(simil1) 
plotCheck = df1.plot.bar()
#plt.show()

# Semantic Similitud of lemmas
simils = {}
for i in range(len(lemma)):
        w1 = lemma[i]
        w2 = ''
        if not i+1 > len(lemma) :
            w2 = lemma[i+1]
        for token1 in doc:
            if token1.lemma_ == w1: 
                for token2 in doc:
                    if token2.lemma_ == w2:
                        val = [token1.text, token2.text, token1.similarity(token2)]
                        if val[2] > 0.7:
                            pair = [val[0],val[1]]
                            simils[val[2]] = pair
df = pd.DataFrame(simils)
df.to_csv("TextAna_output/1542_05_M_le_curéX_simils.csv")

# Matrix of co-occurrence
def co_occurrence(tokens, window_size):
    d = defaultdict(int)
    for i in range(len(tokens)):
        token = tokens[i]
        next_token = tokens[i+1 : i+1+window_size]
        for t in next_token:
            key = tuple( sorted([t, token]) )
            d[key] += 1
    
    # formulate the dictionary into dataframe
    # Keep only the co-occurrences > 1
    meaningful = {} 
    for key, value in d.items():
        if value > 0:
            meaningful[value] = key
    df = pd.DataFrame(meaningful)
    return df.to_csv("TextAna_output/1542_05_M_le_curéX_coOccur.csv")
co_occ = co_occurrence(lemma, 2)

plt.show()
#print(co_occ)
print("Done!")

# Reference : Karajgikar, Jajwalya. s. d. « Guides: Text Analysis: SpaCy Package ». Consulté le 29 janvier 2025. https://guides.library.upenn.edu/penntdm/python/spacy.
