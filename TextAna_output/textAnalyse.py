# First it is necessary to install the packages: spacy and xml.etree.ElementTree (collections and pprint are optional)
# for installing spacy : https://spacy.io/usage 
# Import of modules and language models for NER
import spacy
nlp = spacy.load('fr_core_news_lg') #French model
#nlp = spacy.load('en_core_web_trf') #EN model 
#nlp = spacy.load('xx_ent_wiki_sm') # multilingual model 
import pandas as pd 
import numpy as num 
import seaborn as sns
#import scipy.stats.stats
import matplotlib.pyplot as plt
from collections import Counter
from collections import defaultdict
#import re
# This module will help us manage the xml structure and use xpath for retreiving the text 
#import xml.etree.ElementTree as ET
# path for the file
file = "Translations_txt/1545_08_05_MFallais.txt" #Change file path
# Open and read the file
# parsing the file
result = open(file).read()
#print(result)

doc = nlp(result)
# Remove stop words and punctuation symbols and count
lemma = [token.lemma_ for token in doc if not token.is_stop and not token.is_punct and token.is_alpha and "\n" not in token.lemma_ ]
words = [token.text for token in doc if not token.is_stop and not token.is_punct and token.is_alpha and "\n" not in token.text]
all_words = [token.text for token in doc if not token.is_punct and token.is_alpha and "\n" not in token.text]
w_list = nlp(" ".join(lemma))
word_freq = Counter(lemma)
w_freq = Counter(words)

lemma_word = []
for i in range(len(lemma)):
    for j in range(len(words)):
        if i == j:
            lemma_word.append({lemma[i]: words[j]})
#print(lemma_word)
# return 5 commonly occurring words with their frequencies
common_words = word_freq.most_common(12)
commons = w_freq.most_common(12)
print(commons)
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
print(terms)
            
output = "TextAna_output/1545_08_05_MFallais.txt" #Change file path
#with open(output, "w", encoding="utf-8") as newfile:
 #   newfile.write(f"Liste de lemmas : {word_freq} \n\n Mots les plus fréquents : \n {common_words}")

#Create dataframe of simil (contains the vector values)
df1 = pd.DataFrame(simil1) 
plotCheck = df1.plot.bar()
#plt.show()

# Semantic Similitud of lemmas
simils = {}
print(len(lemma))
for i in range(len(lemma)):
        w1 = lemma[i]
        if i+1 <= len(lemma)-1:
            w2 = lemma[i+1]
            for token1 in doc:
                if token1.lemma_ == w1: 
                    for token2 in doc:
                        if token2.lemma_ == w2:
                            val0 = [token1.lemma_, token2.lemma_, token1.similarity(token2)]
                            if val0[2] > 0.5 and val0[2] != 1:
                                pair = [val0[0],val0[1]]
                                simils[tuple(pair)] = val0[2]

sorted_simils=[[" <—> ".join(k), val] for k, val in simils.items()]
sorted_simils = sorted(sorted_simils, key= lambda x:x[1], reverse=True)
print(sorted_simils)
mots = [key[0] for key in sorted_simils]
simil_val = [value for value in sorted_simils[1]]

# Most similar common words
print([m for m in mots for freq_w in terms if freq_w.lower() in m])

# Visualize most similar lemmas
df = pd.DataFrame(sorted_simils)#, index=simils.keys())
#df.to_csv("TextAna_output/1542_05_M_le_curéX_simils.csv")

def plot_simils():
    plt.figure(figsize=(8, 6))
    sns.scatterplot(y=df[0], x=df[1], data=df, marker="d")#, label='Lemmes similaires', marker='d')
    plt.title('Les paires de mots les plus similaires dans la lettre (avec SpaCy)') # Pairs of Most Similar Words (using SpaCy)
    plt.ylabel('Lemmes') #Mots
    plt.xlabel('Similarité cosinus') #Similarité cosinus
    plt.xticks(rotation=65)
    #plt.legend()
    plt.grid(True)
    plt.tight_layout()
    plt.show()
plot_simils()

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
    return df.to_csv("TextAna_output/1545_08_05_MFallais.csv") #Change file path
#window size = number of words to consider for co-ocurrence
co_occ = co_occurrence(words, 5) # Use lemmas (lemma) or words (words)


#Another way to see co-ocurrence of most common words: context of 5 previous words and 7 next words
common_lemmas = [common_word[0] for common_word in common_words]
common_6 = common_lemmas[0:6]
common_words_text = [common_word[0] for common_word in commons]
common_6_text = common_words_text[0:6]
def co_occurrences_context(doc, word_list, common):
    with open(output, "a", encoding="utf-8") as newfile:
        title = "\n Co-ocurrence of most common words\n\n"
        newfile.write(title)
        for token in doc:
            for i in range(len(word_list)):
                for c in common:
                    if c == token.lemma_ and word_list[i] == token.text:
                        # Collect co-occurrences with 'care' (3 words before and 7 words after)
                        start_index = max(0, i - 3)
                        end_index = min(len(word_list), i + 5)
                        context_words = word_list[start_index:end_index]
                        context_str = f"… {' '.join(context_words)} … \n"
                        co_occur = f"{word_list[i]}:\n {context_str}"
                        newfile.write(co_occur)
        
    print("Done!")
co_occ1 = co_occurrences_context(doc, all_words, common_6_text) #Use lemmas (common_6) or words (common_6_text)


##plt.show()
#print(co_occ)
print("Done!")

# Reference : Karajgikar, Jajwalya. s. d. « Guides: Text Analysis: SpaCy Package ». Consulté le 29 janvier 2025. https://guides.library.upenn.edu/penntdm/python/spacy.
