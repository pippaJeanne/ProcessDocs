import re
import numpy as np
import pandas as pd
import seaborn as sns
import spacy
from sklearn.feature_extraction.text import TfidfVectorizer
from nltk.tokenize import sent_tokenize, word_tokenize
from collections import Counter
import gensim
import gensim.corpora as corpora
from gensim import models, corpora
from gensim.utils import simple_preprocess
from gensim.models import CoherenceModel
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
more_stopwords = ["tel", "telle", "tels", "telles", "tant", "d'un", "d'une", "c'est", "qu'il", "qu'elle", "afin", "est-ce", "qu'est-ce'", "auprès", "jusqu", "chez", "ci", "là", "quoiqu'", "puisque", "quand", "lorsque", "où", "or", "car", "ainsi", "moyen", "toutefois", "toutesfois", "plusieurs", "quelques", "peu", "moins", "plus", "beaucoup", "très", "autre", "autres", "chose", "choses", "fois", "quant", "quantes", "quante", "quantes", "entre", "parce", "parceque", "parce que", "falloir", "faut", "faudrait", "vouloir", "veux", "voudrais", "peux", "pourrais", "sembler", "semble", "sais", "savait", "savaient", "à", "de", "en", "du", "des", "la", "le", "les", "un", "une", "et", "ou", "au", "aux", "ce", "ces", "se", "sa", "son", "ses", "ne", "pas", "ni", "avoir", "être", "faire", "dit", "dire", "cela", "celui", "celle", "ceux", "celles", "lui", "leur", "leurs", "y", "là", "ici", "ci", "eusse", "eussent", "eût", "eûmes", "eûtes", "fusse", "fusses", "fût", "fûmes", "fûtes", "sois", "soit", "soyons", "soyez", "soient", "ayant", "été", "étée", "étées", "étés", "étant", "suis", "es", "est", "sommes", "êtes", "sont", "avais", "avait", "avions", "aviez", "avaient", "eus", "eut", "eûmes", "eûtes", "eurent", "ai", "as", "avons", "avez", "ont", "aurai", "auras", "aura", "aurons", "aurez", "auront", "aurais", "aurait", "aurions", "auriez", "auraient", "en", "n'en", "d'en", "n'en", "m'être", "t'être", "s'être", "se", "n'être"]
stopword.extend(more_stopwords)

file = open("Translations_txt/1540_07_28_DuTailly.txt", encoding="utf-8") #Change file path
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
tokens_segments = []
for i in range(len(segments)):
    doc = nlp(segments[i])
    token_row = []
    filtered_tokens = [token.text for token in doc if token.is_alpha and not token.is_stop and token.pos_ in ["NOUN", "VERB", "ADJ"]]
    filtered_tokens = [word for word in filtered_tokens if word.lower() not in stopword]
    for token in filtered_tokens:
        all_tokens.append(token)
        token_row.append(token)
    tokens_segments.append(token_row)
    processed_texts.append(" ".join(filtered_tokens))
print(tokens_segments)
dictionary = corpora.Dictionary(tokens_segments)
corpus = [dictionary.doc2bow(tokens) for tokens in tokens_segments]
#ldamodel = gensim.models.ldamodel.LdaModel(corpus, num_topics = 8, id2word=dictionary, random_state=100, update_every=1, passes=15, alpha='auto', per_word_topics=True)

ldamodel = gensim.models.ldamodel.LdaModel(corpus, num_topics = 2, id2word=dictionary, random_state=100, update_every=1, passes=15, alpha='auto', per_word_topics=True)
topics = ldamodel.print_topics(num_words=10)
print(topics)

# TF-IDF keywords
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

output = "TextAna_output/1540_07_28_DuTailly.txt" #Change file path
with open(output, "w", encoding="utf-8") as newfile:
   newfile.write(f"Thématiques par LDA : {topics} \n\n Mots clés par TF-IDF : \n {keywords}")

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
file = open("Translations_txt/1540_07_28_DuTailly.txt", encoding="utf-8") #Change file path
text = file.read()
#print(text)
words = list(set(re.findall(r'\b\w+\b', text.lower())))
print(words)
similar_pairs = []

# Load pre-trained Sentence Transformer model and scaler for normalization (StandardScaler to be used preferably for PCA)
model0 = SentenceTransformer('paraphrase-multilingual-MiniLM-L12-v2')
to_normalize = StandardScaler()

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
#to_normalize = StandardScaler()
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
# Normalize embeddings before PCA

# For words
normalized_w_embeddings = to_normalize.fit_transform(embeddings0)
pca_w = PCA(n_components=2)
print(normalized_w_embeddings.shape)
coords_w = pca_w.fit_transform(normalized_w_embeddings)
print(coords_w.shape)
plt.figure(figsize=(8, 6))
for i, label in enumerate(words):
    x, y = coords_w[i]
    plt.scatter(x, y)
    plt.text(x + 0.05, y, label , fontsize=9)
plt.title("PCA (Pricipal Component Analysis) of Word Embeddings")
plt.xlabel("PC1")
plt.ylabel("PC2")
plt.grid(True)
plt.show()


### For paragraphs
# Compute embeddings for each paragraph
pca = PCA(n_components=3)
para_embeddings = model0.encode(list_of_text)
coords = pca.fit_transform(para_embeddings)
print(coords.shape)
fig = plt.figure(figsize=(8, 6))
ax = fig.add_subplot(projection='3d')
for i, label in enumerate(list_of_text):
    x, y, z = coords[i]
    ax.scatter(x, y, z)
    ax.text(x + 0.05, y, z, f"{i}: {label[:20]}", fontsize=9)
ax.set_title("PCA (Pricipal Component Analysis) of Paragraph Embeddings")
ax.set_xlabel("PC1")
ax.set_ylabel("PC2")
ax.set_label("PC3")
ax.grid(True)
plt.show()

# Test correlation (not helpful for small text, but interesting for larger corpora)

vectorizer = CountVectorizer(binary=True)
X = vectorizer.fit_transform(segments)
print(X.toarray())
dframe = pd.DataFrame(X.toarray(), columns=vectorizer.get_feature_names_out())
print(dframe)
corr = dframe.corr('pearson')

m = np.triu(np.ones(corr.shape), k=1).astype(bool)
filtered = corr.where(m)
filtered_corr = filtered.unstack().dropna().sort_values(ascending=False)[:20]
axes = ["<—>".join(axis) for axis in filtered_corr.axes[0]]
print(len(axes))

vals = filtered_corr.values
print(vals[:10], filtered_corr[:10])
