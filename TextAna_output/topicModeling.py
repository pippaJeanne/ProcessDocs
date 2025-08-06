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

file = open("Translations_txt/1538_10_20_LouisTillet.txt", encoding="utf-8")
text = file.read()
list_of_text = text.split("\n")

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
vectorizer = CountVectorizer()
X = vectorizer.fit_transform(processed_texts)
dframe = pd.DataFrame(X.toarray(), columns=vectorizer.get_feature_names_out())
corr = dframe.corr('pearson')

m = np.triu(np.ones(corr.shape), k=1).astype(bool)
filtered = corr.where(m)
filtered_corr = filtered.unstack().dropna().sort_values(ascending=False)[:10]
axes = ["<—>".join(axis) for axis in filtered_corr.axes[0]]
print(len(axes))

vals = filtered_corr.values
print(vals)




###############
###  Test similarity of last paragraphs of letters to Edward VI of England

data_json = {}
with open("final_p_orig_roiAngleterre.json", "r") as file_paras:
  data_json = json.load(file_paras)
data_paras = data_json["roiAngleterre"]

paras = [p for p in data_paras.values()]
#print(paras)

model = SentenceTransformer('all-MiniLM-L6-v2')
emb1 = model.encode(paras[0], convert_to_tensor=True)
emb2 = model.encode(paras[1], convert_to_tensor=True)
# Comparison of copy "emb2" against original "emb1" 
similarity = util.cos_sim(emb1, emb2)
print(similarity)

# Comparison of all three: two copies and one original 
similarites = []
labels = []
for key in data_paras.keys():
    p = data_paras[key]
    emb1 = model.encode(p)
    labels.append(key)
    row = []
    for k, para in data_paras.items():
        emb2 = model.encode(para)
        #print(k, para)
        simils = util.cos_sim(emb1,emb2)
        score = simils.item()
        row.append(score)
    similarites.append(row)
df =pd.DataFrame(similarites, index=labels, columns=labels)

def viz_simils_matrix():
    plt.figure(figsize=(10, 8))
    sns.heatmap(df, annot=True, fmt=".2f", cmap="coolwarm", square=True)
    plt.title("Matrice de similarités")
    plt.xticks(rotation=25, ha='right')
    plt.yticks(rotation=0)
    plt.tight_layout()
    plt.show()
viz_simils_matrix()
print(similarites)


#### Clustering of embeddings (three paragraphs)
from sklearn.preprocessing import normalize

# Clean + tokenize function
def preprocess(text):
    tokens = [re.sub(r"[^\w\s']", '', w.lower()) for w in text.split()]
    return [t for t in tokens if t]

# Prepare data
results = {}
for label, paragraph in data_paras.items():
    tokens = preprocess(paragraph)
    embeddings = model.encode(tokens, normalize_embeddings=True)
    mean_emb = normalize(embeddings).mean(axis=0, keepdims=True)
    similarities = cosine_similarity(embeddings, mean_emb).flatten()
    results[label] = (tokens, similarities)
#print(results)
# Plot
def plot_scatter():
    fig, axs = plt.subplots(len(results), 1, figsize=(12, 4 * len(results)), sharex=False)

    if len(results) == 1:
        axs = [axs]  # ensure iterable if only one subplot

    for ax, (label, (tokens, similarities)) in zip(axs, results.items()):
        ax.plot(range(len(tokens)), similarities, marker='d')
        ax.set_xticks(range(len(tokens)))
        ax.set_xticklabels(tokens, rotation=90)
        ax.set_title(f"Lexical similarity to mean: {label}")
        ax.set_ylabel("Cosine Similarity")
        ax.set_ylim(0, 1)
        ax.grid(True)

        lowest_indices = np.argsort(similarities)[:3]
        for idx in lowest_indices:
            ax.annotate(
                tokens[idx],
                (idx, similarities[idx]),
                textcoords="offset points",
                xytext=(0, -15),
                ha='center',
                fontsize=10,
                color='red',
                arrowprops=dict(arrowstyle='->', lw=0.5, color='red')
            )

    plt.tight_layout()
    plt.show()
plot_scatter()


########
# Stylistic analysis of three last paragraphs of letters to Edward VI of England
# ** Have to add whole letters and others to other people to compare against for the stylistic clustering
larger_dataset= {}
compare = open("letters_comparison.json", "r")
r = json.load(compare)
larger_dataset = r["lettres"]
#print(larger_dataset)

simil_ltres = []
ltr_labels = list(larger_dataset.keys())
ltr_texts = list(larger_dataset.values())
embeds = model.encode(ltr_texts)
ltrs_similarity = cosine_similarity(embeds)
df1 = pd.DataFrame(ltrs_similarity, columns=ltr_labels, index=ltr_labels)
print(df1)

# Clusters
from sklearn.manifold import MDS
mds = MDS(dissimilarity='precomputed', random_state=42)
coords = mds.fit_transform(1 - df1)  # 1 - cosine sim = distance
def mds_heatmap():
    sns.heatmap(df1, annot=True)
    plt.title("Similarity of Selection of Letters")
    plt.tight_layout()
    plt.show()
mds_heatmap()

def mds_plot():
    plt.scatter(coords[:,0], coords[:,1])
    for i, label in enumerate(ltr_labels):
        plt.annotate(label, (coords[i,0], coords[i,1]), ha='center',)
    plt.xlim(-1,1.5)
    plt.ylim(-1,1.5)
    plt.title("MDS Plot of Farewell Paragraphs")
    plt.tight_layout()
    plt.show()
mds_plot()


# 1. Embeddings sémantiques avec SentenceTransformers
model1 = SentenceTransformer("distiluse-base-multilingual-cased-v1")  # ou un modèle plus fin
embeddings = model1.encode(ltr_texts)
norm_embeddings = model1.encode(ltr_texts, normalize_embeddings=True)
mean_embeds = norm_embeddings.mean(axis=1)
#print()
# 2. Extraction de caractéristiques stylométriques avec spaCy

def stylometric_features(text):
    doc = nlp(text)
    tokens = [t for t in doc if t.is_alpha]
    num_tokens = len(tokens)
    avg_word_len = sum(len(t.text) for t in tokens) / num_tokens if num_tokens else 0

    pos_counts = doc.count_by(spacy.attrs.POS)
    total_pos = sum(pos_counts.values())

    def pos_ratio(pos_name):
        return pos_counts.get(nlp.vocab.strings[pos_name], 0) / total_pos if total_pos else 0

    return [
        num_tokens,
        avg_word_len,
        pos_ratio("NOUN"),
        pos_ratio("VERB"),
        pos_ratio("ADJ"),
        pos_ratio("ADV")
    ]

stylometric_vectors = [stylometric_features(t) for t in ltr_texts]
#print(stylometric_vectors)
# 3. Combinaison des vecteurs
X = np.hstack([embeddings, stylometric_vectors])
    
    ## Similarity comparison
simils_ltres = cosine_similarity(X)#.flatten()
df_style = pd.DataFrame(simils_ltres, index=ltr_labels, columns=ltr_labels)
def simils_heatmap():
    plt.figure(figsize=(12,8))
    sns.heatmap(df_style, annot=True)
    plt.title("Similarity of Selection of Letters (taking into account stylistic features)")
    plt.tight_layout()
    plt.show()
simils_heatmap()

# Compare letters by stylistic features
style_v0 = []
for vector in stylometric_vectors:
    row = []
    for v in vector[:2]:
        row.append(v)
    style_v0.append(row)
style_v1 = []
for vector in stylometric_vectors:
    row = []
    for v in vector[2:len(vector)]:
        row.append(v)
    style_v1.append(row)

def plot_style_feats():
    for vector in style_v0:
            plt.subplot(1, 2, 1)
            plt.plot(["Total Tokens", "Avg Word Length"], vector, marker='d', label=label)
            plt.xlabel("Stylistic Features", rotation=0)
            plt.title("Comparison of Letters by Stylistic Features", loc="center")
            plt.ylabel("Measurements")
    for vector in style_v1:
            plt.subplot(1, 2, 2)
            plt.plot(["Noun Ratio", "Verb Ratio", "Adj Ratio", "Adv Ratio"], vector, marker='d', label=label)
            plt.xlabel("Stylistic Features", rotation=0)
            plt.title("Comparison of Letters by Stylistic Features", loc="center")
            plt.ylabel("Measurements")
            plt.legend(ltr_labels)   
    #plt.ylim(0, 1)
    plt.grid(True)
    plt.tight_layout()
    plt.show()
plot_style_feats()


## Compare by similarity of paragraphs for each sample letter
simil_paras = {}
for label, letter in larger_dataset.items():
    ps = letter.split("\n ")
    embeddings = model1.encode(ps, normalize_embeddings=True)
    mean_emb = normalize(embeddings).mean(axis=0, keepdims=True)
    similarities = cosine_similarity(embeddings, mean_emb).flatten()
    simil_paras[label] = (ps, similarities)
#print(simil_paras)
# Plot
def plot_scatter_p():
    fig, axs = plt.subplots(len(simil_paras), 1, figsize=(12, 2 * len(simil_paras)), sharex=False)

    if len(simil_paras) == 1:
        axs = [axs]  # ensure iterable if only one subplot

    for ax, (label, (ps, similarities)) in zip(axs, simil_paras.items()):
        ax.plot(range(len(ps)), similarities, marker='d')
        ax.set_xticks(range(len(ps)))
        ax.set_xticklabels(range(len(ps)), rotation=0)
        ax.set_title(f"Similarity of paragraphs in {label}")
        ax.set_ylabel("Cosine Similarity")
        ax.set_ylim(0, 1)
        ax.grid(True)
        ax.annotate(
                similarities[-1],
                (len(ps)-1, similarities[-1]),
                textcoords="offset points",
                xytext=(0, -15),
                ha='center',
                fontsize=10,
                color='red',
                arrowprops=dict(arrowstyle='->', lw=0.5, color='green')
            )

    plt.tight_layout()
    plt.show()
plot_scatter_p()

# 4. Standardisation et PCA (ou autre méthode de réduction ou clustering)
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

pca = PCA(n_components=2)
coords1 = pca.fit_transform(X_scaled)

# 5. Visualisation
def plot_pca():
    plt.figure(figsize=(8, 6))
    for i, label in enumerate(ltr_labels):
        x, y = coords1[i]
        plt.scatter(x, y)
        plt.text(x + 0.05, y, label, fontsize=9)
    plt.title("Clustering (Sentence-BERT + Stylometric Features)")
    plt.xlabel("PC1")
    plt.ylabel("PC2")
    plt.grid(True)
    plt.show()
plot_pca()

from sklearn.cluster import KMeans

# 1. On garde tout ce qui précède (embeddings + stylometry + fusion + standardisation)
# ... même bloc que précédemment jusqu'à X_scaled ...

# 2. Clustering avec KMeans
k = 2  # ou 3, selon ce que tu veux tester
kmeans = KMeans(n_clusters=k, random_state=42, n_init="auto")
clusters = kmeans.fit_predict(X_scaled)

# 3. Visualisation avec les clusters
def plot_kmean():
    plt.figure(figsize=(8, 6))
    colors = ['red', 'green', 'blue']
    for i, label in enumerate(ltr_labels):
        x, y = coords1[i]
        plt.scatter(x, y, color=colors[clusters[i]])
        plt.text(x + 0.05, y, label, fontsize=9)
    plt.title(f"Clustering KMeans (k={k})")
    plt.xlabel("PC1")
    plt.ylabel("PC2")
    plt.grid(True)
    plt.show()
plot_kmean()

# 4. Optionnel : impression des clusters
for i, label in enumerate(labels):
    print(f"{label} → Cluster {clusters[i]}")