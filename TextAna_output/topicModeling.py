import re
import numpy as np
import pandas as pd
import seaborn as sns
import spacy
from sklearn.feature_extraction.text import TfidfVectorizer
from nltk.tokenize import sent_tokenize, word_tokenize
from collections import Counter
#import gensim
#import gensim.corpora as corpora
#from gensim import models, corpora
#from gensim.utils import simple_preprocess
#from gensim.models import CoherenceModel
import matplotlib.pyplot as plt
import nltk as nltk 
from nltk.util import ngrams
#import xml.etree.ElementTree as tree
nltk.download('stopwords')
stopword = nltk.corpus.stopwords.words('French')
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
from sentence_transformers import SentenceTransformer, util
from sklearn.feature_extraction.text import CountVectorizer
#from bertopic import BERTopic
import json
#from urllib3.util import Retry
#from itertools import permutations
more_stopwords = ["tel", "telle", "tels", "telles", "tant", "d'un", "d'une", "c'est", "qu'il", "qu'elle", "afin", "est-ce", "qu'est-ce'"]
stopword.extend(more_stopwords)

file = open("Translations_txt/1545_04_28_ReineNavarre.txt", encoding="utf-8")
text = file.read()
list_of_text = text.split("\n")
print(text)

def _pre_clean(list_of_text):
        cleaned_list = []
        for text in list_of_text:
            # print("original:", text)
            text = text.replace('\\n', ' ')
            text = text.replace('\\r', ' ')
            text = text.replace('\\t', ' ')
            text = text.replace('\\d', '')
            text = text.replace('\\W', '')
            pattern = re.compile(r'\s+')
            text = re.sub(pattern, ' ', text)
            text = text.strip()
            text = text.lower()
            # check for empty strings
            if text != '' and text is not None:
                cleaned_list.append(text)

        return cleaned_list
        
def tokenize(text):
        tokens = word_tokenize(text)
        tokens = _pre_clean(tokens)
        tokens = [token for token in tokens if len(token) > 3]
        tokens = [token for token in tokens if token not in stopword]
        return tokens

text_data = []
for text in list_of_text:
    txt = tokenize(text)
    if txt != []:
        text_data.append(txt)
print(text_data)

# Sample segments of the document : paragraphs
segments = [(" ").join(p) for p in text_data]
print(segments)

# Topics = td-idf

nlp = spacy.load('fr_core_news_lg')
n = 2  # Example for bi-grams
m = 3  # Example for tri-grams
keyword_data = []
bigram_data = []
trigram_data = []
processed_texts = []
all_tokens = []
for i in range(len(segments)):
    doc = nlp(segments[i])
    filtered_tokens = [token.text for token in doc if token.is_alpha and not token.is_stop and token.pos_ in ["NOUN", "VERB", "ADJ"]]
    filtered_tokens = [word for word in filtered_tokens if word.lower() not in stopword]
    for token in filtered_tokens:
         all_tokens.append(token)
    processed_texts.append(" ".join(filtered_tokens))

tfidf_vectorizer = TfidfVectorizer()
tfidf_matrix = tfidf_vectorizer.fit_transform(processed_texts)
feature_names = tfidf_vectorizer.get_feature_names_out()
keywords_matrix= tfidf_matrix.sum(axis=0).A1
keywords_indices = np.argsort(keywords_matrix)[::-1][:10]
keywords = [[feature_names[i],keywords_matrix[i]] for i in keywords_indices]
print(keywords)
def plot_keyw():
    data = {"keywords": [keyword[0] for keyword in keywords], "tf-idf scores": [keyword[1] for keyword in keywords]}
    df = pd.DataFrame(data)
    sns.boxplot(x="keywords", y="tf-idf scores", data = df)
    plt.title("Les 7 mots-clés les plus importants d'après leur score TF-IDF")
    plt.xlabel("Mots-clés")
    plt.ylabel("Score TF-IDF")
    plt.show()
plot_keyw()

        # Bi-grams ^^Interesting to check^^
bigrams = Counter(ngrams(all_tokens, n)).most_common(5)
bigram_data = bigrams
print(bigram_data) 
def viz_bigram():
    plt.figure(figsize=(15, 7))
    plt.subplot(3, 1, 2)
    sns.set_theme(style="whitegrid")
    bigrams, counts = zip(*bigram_data)
    plt.barh([str(bigram) for bigram in bigrams], counts)
    plt.xlabel("Frequency")
    plt.title("Top 5 Bi-grams")
    #plt.legend()
    plt.show()
viz_bigram()
        # Tri-grams
trigrams = Counter(ngrams(all_tokens, m)).most_common(5)
trigram_data = trigrams
print(trigram_data)

########
# Similarity analysis of tokens in letter

#from difflib import SequenceMatcher
from itertools import combinations
from sklearn.metrics.pairwise import cosine_similarity
file = open("Translations_txt/1545_04_28_ReineNavarre.txt", encoding="utf-8") #Change file path
text = file.read()
#print(text)
words = list(set(re.findall(r'\b\w+\b', text.lower())))
print(words)
similar_pairs = []
model0 = SentenceTransformer('paraphrase-multilingual-MiniLM-L12-v2')

# Compute embeddings for each word
embeddings0 = model0.encode(words)

common_tokens = Counter(all_tokens).most_common(10)
relevant = [term[0] for term in common_tokens]
print(relevant)
# Compute pairwise cosine similarity
similarities = cosine_similarity(embeddings0)

# Find the top N most similar pairs
N = 10
pairs = []
for i, j in combinations(range(len(words)), 2):
    sim = similarities[i, j]
    if sim > 0.7:
        for t in relevant:
            if t == words[i] or t == words[j]:
                pairs.append([words[i], words[j], sim])
print(len(pairs))
# Sort and print
top_pairs = sorted(pairs, key=lambda x: -x[2])[:N]
#print(top_pairs)
frame = {}
arr_frame = []
pairs = []
for w1, w2, score in top_pairs:
    pair = f"{w1} <—> {w2}"
    pairs.append(pair)
    frame[pair] = score
    arr_frame.append([pair, score])
#print(arr_frame)
df0 = pd.DataFrame(frame, index=pairs)
simple_df = pd.DataFrame(arr_frame)
print(simple_df)

# Scatterplot of embeddings with mean normalized embeddings
ind = []
mean = []
to_normalize = StandardScaler()
normed = to_normalize.fit_transform(embeddings0)
for i in range(len(normed)):
    ind.append(i)
    mean.append(np.mean(normed[i]))
print(ind[:2], mean[:2])
#print(len(ind), len(mean))
def viz_embs():
    plt.figure(figsize=(10, 8))
    #sns.heatmap(corr)
    plt.figure(figsize=(8, 6))
    for i, label in enumerate(words):
        x, y = ind[i], mean[i]
        plt.scatter(x, y)
        plt.text(x + 0.05, y, label, fontsize=9)
    #plt.scatter(x=ind, y=mean)#, cmap="Purples", marker="d")
    plt.title("Scatterplot of Embeddings with Mean Normalized Embeddings")
    plt.xticks(rotation=0)
    plt.yticks(rotation=0)
    plt.xlabel("Indices of Words (the order in which they appear in the text)")
    plt.ylabel("Mean Normalized Embeddings")
    #plt.legend()
    plt.tight_layout()
    plt.show()
viz_embs()

# Scatterplot of embeddings with PCA (Pricipal Component Analysis) ^^Better in some ways^^ : Clearer and cleaner clusters
pca = PCA(n_components=2)
coords = pca.fit_transform(embeddings0)

plt.figure(figsize=(8, 6))
for i, label in enumerate(words):
    x, y = coords[i]
    plt.scatter(x, y)
    plt.text(x + 0.05, y, label, fontsize=9)
plt.title("Clustering of embeddings")
plt.xlabel("PC1")
plt.ylabel("PC2")
plt.grid(True)
plt.show()


# Test correlation (false results)

vectorizer = CountVectorizer(binary=True)
X = vectorizer.fit_transform(processed_texts)
dframe = pd.DataFrame(X.toarray(), columns=vectorizer.get_feature_names_out())
corr = dframe.corr('pearson')

m = np.triu(np.ones(corr.shape), k=1).astype(bool)
filtered = corr.where(m)
filtered_corr = filtered.unstack().dropna().sort_values(ascending=False)[:20]
axes = ["<—>".join(axis) for axis in filtered_corr.axes[0]]
print(len(axes))

vals = filtered_corr.values
print(vals[:10], filtered_corr[:10])
