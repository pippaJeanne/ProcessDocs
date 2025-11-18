###############
###  Test similarity of last paragraphs of letters to Edward VI of England

import re
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import json
import spacy
from sentence_transformers import SentenceTransformer, util
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler

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