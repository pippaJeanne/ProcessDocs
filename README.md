Ce sont les fichiers et les scripts pour la plupart de la chaîne éditoriale de l'[édition critique numérique de la correspondance française de Jean Calvin](https://lettres-calvin.netlify.app).

These are the files and scripts for part of the pipeline processing of the [critical digital edition of John Calvin's French correspondence](https://lettres-calvin.netlify.app/).

------------------

## Table of Contents / Table des matières

- [Version française](#version-française)
- [English version](#english-version)

---

# Version française

## Chaîne éditoriale semi-automatique pour Lettres de Calvin

Ce dépôt contient l'ensemble du pipeline de traitement et de prépublication des **Lettres de Calvin**, une édition critique numérique bilingue (français-espagnol) de la correspondance française de Jean Calvin. La pipeline automatise une grande partie du workflow éditorial tout en maintenant la supervision humaine et le contrôle à des étapes critiques.

### Présentation de l'édition

*Lettres de Calvin* est une plateforme de recherche dynamique proposant :
- **Un appareil critique bilingue** avec des versions française et espagnole
- **Un indexage transversal bilingue** (chronologique, thématique, par catégories, par personnes et par lieux)
- **Une comparaison des manuscrits** avec transcriptions diplomatiques côte à côte
- **Un texte français modernisé** avec annotations critiques et variantes de lecture
- **Des visualisations interactives** incluant une carte d'index des lieux et une chronologie
- **Des références externes** liées à Wikidata pour les personnes, les lieux et les œuvres

### Architecture de la pipeline

La pipeline se compose de deux étapes principales :

#### 1. Étape de pré-traitement : édition et encodage

C'est la phase semi-automatique où le travail éditorial humain est primordial :

1. **Encodage structurel de base** - Le texte OCR de l'édition originale (plateforme BNF Gallica) est extrait, corrigé des erreurs OCR, puis transmis via une requête à l'API Gemini pour générer le balisage TEI XML initial avec les éléments structurels de base (ouverture, salutation, fermeture, paragraphes) d'après [le modèle/protocole d'encodage établi](templateEncodage.xml). Le fichier est placé dans `input` et renommé en suivant le modèle **année_mois_jour_NomDestinataire**.

2. **Correction et enrichissement manuels** - L'éditeur révise et corrige l'encodage généré par l'IA, ajoute des métadonnées (informations d'approvisionnement, numéros d'appel, liens IIIF/ARK) et encode les notes textuelles et les références.

3. **Reconnaissance des entités nommées (NER)** - Un script Python utilisant SpaCy identifie et étiquette les personnes, les lieux, les dates, les organisations et les œuvres. L'éditeur enrichit ensuite les balises d'entités avec des identifiants Wikidata et les attributs de nom complet. —Cette étape a été enrichie : une [liste d'entités nommées récurrentes avec leurs identifiants Wikidata](WikiLinksPCalvin.md), mise à jour au fur et à mesure, est passée dans le prompt pour l'encodage de base en plus du modèle d'encodage, permettant une NER plus efficace et précise que celle fournie par SpaCy.

4. **Modernisation** - À l'aide de transformations XSLT, les variantes lexicales archaïques du français sont remplacées par des équivalents modernes en utilisant XSLT 2.0 et des expressions régulières, tout en préservant le style de Calvin. Les interventions suivent un glossaire du français médiéval et restent limitées au niveau lexical. Après le passage de la transformation, l'éditeur révise et corrige des erreurs et/ou modernise des mots manqués par la transformation. 

5. **Annotations et analyse** - L'éditeur ajoute des annotations textuelles comparant les manuscrits avec l'édition Bonnet, identifie les informations manquantes, fournit des notes paléographiques et traduit les passages latins en français.

6. **Analyse thématique pour l'identification des thèmes** - Une analyse textuelle approfondie est réalisée pour identifier et valider les thèmes sous-jacents qui pourraient ne pas être évidents. Utilisant des techniques de traitement du langage naturel (fréquence des mots, analyse de co-occurrence, similarité sémantique, extraction de termes clés avec TF-IDF, et analyse stylométrique), le script génère des visualisations et des matrices de similarité. Ces analyses incluent l'étude des bigrammes/trigrammes, l'identification des patterns de co-occurrence dans une fenêtre contextuelle, et la comparaison de paragraphes similaires pour vérifier la cohérence. Les résultats (matrices de similarité, listes de co-occurrence, graphes PCA) servent de validation ou de complément aux décisions thématiques de l'éditeur, qui conserve l'autorité finale dans l'attribution des thèmes—particulièrement important pour les lettres courtes où les thèmes peuvent être implicites ou nuancés.

7. **Traduction espagnole** - Le texte français modernisé est traduit à l'aide d'un modèle Gemini affiné entraîné sur les traductions des premières 15-18 lettres éditées et traduites. L'éditeur/traducteur révise et corrige le résultat. Les fragments de traduction sont alignés avec le français (ciblant ~5000 tokens par fragment) pour créer des données d'entraînement pour ré-affiner le modèle dans une forme de système de mémoire de traduction.

8. **Encodage TEI de la version espagnole** - La traduction espagnole est encodée en TEI en utilisant une requête à l'API Gemini qui passe [le protocole d'encodage en espagnol](templateXMLes.xml) et le fichier TEI de référence en français. Le résultat est révisé et corrigé par l'éditeur, notamment les attributs de nom complet des entités nommées, la bibliographie, l'encodage et les annotations.
   **Note de validation** - Vérifier la correspondance FR-ES avant publication. Par exemple, si l'interface bilingue affiche la version française à la place de la traduction espagnole, cela indique généralement que la valeur de l'attribut `corresp` dans `sourceDesc` du fichier XML espagnol ne correspond pas à la valeur de l'attribut `xml:id` de l'élément `TEI` du fichier XML français de référence.

#### 2. Étape de publication : affichage et indexation automatisés

Une fois l'édition terminée, les scripts Python extraient les données structurées :

- **Intégration Wikidata** - Les données (noms, résumés, coordonnées, images) sont interrogées via Wikidata en utilisant les *endpoints* SPARQL et organisées en fichiers JSON pour les différents indexes
- **Génération d'index** - L'index des noms, l'index des lieux (carte interactive) et la chronologie sont générés à partir des données structurées extraites (de Wikidata)
- **Déploiement du système** - Les fichiers XML et les données JSON sont ajoutés à la plateforme de publication basée sur SvelteKit ; l'API intègre automatiquement le nouveau contenu et le publie en direct
- **XSLT côté client** - La bibliothèque SaxonJS permet les transformations XSLT (modernisation, variantes) côté client pour des options d'affichage de texte flexibles (plusieurs versions à partir d'un seul fichier source)
- **Génération PDF** - Fonction expérimentale permettant aux utilisateurs de générer des versions PDF avec filtrage transversal par catégories, dates, personnes, lieux et terme de recherche ; elle enregistre les choix des utilisateurs pour l'étude des intérêts des lecteurs modernes de la correspondance de Calvin.
- **Transcriptions diplomatiques** - Interface de recherche pour les transcriptions de manuscrits de l'écriture originale de Calvin (sélection)

### Structure du projet

**Scripts de la pipeline éditoriale :**

- `Py_scripts_autoencoding_modeltraining/` - Scripts Python pour encodage TEI de base, NER, affinement du modèle de traduction et alignement des données d'entraînement
- `DataExtraction_Index/` - Scripts pour extraire et organiser les données structurées des fichiers XML pour les indexes (personnes, lieux, données chronologiques)
- `output/` - Résultats générés incluant le XML modernisé, les résultats du traitement NER et les versions finales (XML) pour la publication
- `data_json/` - Fichiers JSON utilisés pour les visualisations interactives et les indexes
- Plateforme pour la création de la carte interactive : [fr](https://observablehq.com/d/1956978c14deb22b), [es](https://observablehq.com/d/de8c36a8a2970791) ; pour mettre à jour la carte interactive, il ne faut que remplacer le fichier JSON pour [la nouvelle version](data_json/data_carte.json) et intégrer avec *Runtime JavaScript* (instructions plus détaillées sur [le dépôt de publication](https://github.com/pippaJeanne/lettres-calvin?tab=readme-ov-file#2-adapter-la-carte-interactive))


**Système de publication (SvelteKit) :**

La plateforme de publication est organisée en deux répertoires principaux :

**`src/lib/` - Fichiers internes :**
- `biblRep/` - Fichiers JSON pour les informations bibliothécaires et les visualisations
- `components/` - Composants Svelte réutilisables
- `data/` - Contenu Markdown (français `md/` et espagnol `mdes/`)
- `odd/` - Personnalisation du schéma XML
- `xml/` - Fichiers XML en français
- `xmles/` - Fichiers XML des traductions espagnoles
- `fr_es.js` - Configuration d'internationalisation (i18n)
- `search.ts` - Définitions des fonctions de recherche en texte intégral
- `*.css` - Feuilles de style : `blog.css` (pages de lettres), `error.css`, `style.css` (général), `toc-css.css` et `pagedjs_css.css` (génération PDF)

**`src/routes/` - Logique de routage :**
- `[lang = lang]/` - Structure de routage basée sur la langue contenant :
  - `lettres/` - Affichage des lettres en français
  - `cartas/` - Affichage des traductions espagnoles
  - `carte/` - Carte interactive d'index des lieux
  - `categories/` - Filtrage par catégories thématiques
  - `index_noms/` - Index des noms
  - `tags/` - Index thématique
  - `pdf_generator/` - Export PDF avec options de filtrage
  - `transcription/` - Transcriptions diplomatiques de l'écriture de Calvin
  - `search/` - Fonctionnalité de recherche en texte intégral
- `api/` - Récupération des données depuis les fichiers XML ; expose le XML via l'API pour la transformation XSLT côté client et le téléchargement
- `hooks.server.js` - Logique de redirection basée sur la langue

**`static/` - Assets côté client :**
- `pics_protocole/` - Images de la page du protocole de transcription
- `saxonjs3/` - Bibliothèque SaxonJS pour la transformation XSLT côté client
- `xslt/` - Feuilles de transformation XSLT et exécutables SaxonJS compilés (fichiers SEF.json)
- Fichiers `.js` et images pour le fonctionnement global du site, incluant des fac-similés de manuscrits et sources imprimées

**`EditorialPipeline_ppt/`** - Documentation technique de l'architecture

**Aperçu des scripts :**

- `NER.py`, `NERcopie.py`, `NERforDirFiles.py` - Reconnaissance des entités nommées utilisant SpaCy
- `4trainingmodel.py`, `2translate_*.py` - Affinement du modèle de traduction et inférence
- `Adapt_trainingdata_structure_json2jsonl.py` - Alignement et formatage des données d'entraînement
- `transfomXSLTpy.py` - Transformations XSLT avec [`modernisation.xslt`](Modernisation/modernisation.xslt) pour la modernisation (balises `choice`)
- `ExtractRefDataWiki.py`, `persQueries.py`, `placeQueries.py` - Scripts d'extraction Wikidata

### Caractéristiques principales

✓ **Semi-automatisation avec contrôle humain** - L'apprentissage automatique assiste mais l'éditeur conserve l'autorité finale  
✓ **Détection d'erreurs** - La validation automatisée signale les incohérences d'encodage et les informations manquantes  
✓ **Réutilisation flexible des données** - Le XML et JSON structurés permettent plusieurs approches de visualisation et d'indexation  
✓ **Apparatus critique bilingue** - Édition critique français-espagnol intégrée avec alignement linguistique soigné  
✓ **Fidélité aux manuscrits** - Transcriptions diplomatiques et annotations paléographiques aux côtés des versions modernisées  
✓ **Linked Open Data** - L'intégration avec Wikidata permet une information contextuelle riche et des liens externes  
✓ **Pipeline évolutive** - Les envois mensuels de 7-8 lettres maintiennent l'édition à jour avec une complexité gérable

---

# English version

## Semi-Automatic Editorial Pipeline for Lettres de Calvin

This repository contains the complete pipeline for processing and pre-publishing the **Lettres de Calvin** (*Calvin's Letters*), a bilingual critical digital edition (French-Spanish) of John Calvin's French correspondence. The pipeline automates much of the editorial workflow while maintaining human oversight and control at critical stages.

### Edition Overview

*Lettres de Calvin* is a dynamic research platform featuring:
- **Bilingual scholarly apparatus** with French and Spanish versions
- **Multilayered transversal indexing** (chronological, thematic, by people and places)
- **Manuscript comparison** with side-by-side diplomatic transcriptions 
- **Modernized French text** with critical annotations and variant readings
- **Interactive visualizations** including a place index map and timeline
- **External references** linked to Wikidata for persons, places, and works

### Pipeline Architecture

The pipeline consists of two main stages:

#### 1. Pre-Processing Stage: Editing & Encoding

This is the semi-automatic phase where human editorial work is paramount:

1. **Basic Structural Encoding** - OCR text from the original edition (BNF Gallica platform) is extracted, corrected for OCR errors, and passed through a prompt using the Gemini API to generate initial TEI XML markup with basic structural elements (opener, salute, closer, paragraphs) based on [the established encoding template/protocol](templateEncodage.xml). The file is placed in `input` and renamed following the pattern **year_month_day_RecipientName**.

2. **Manual Correction & Enrichment** - The editor reviews and corrects AI-generated encoding, adds metadata (sourcing information, call numbers, IIIF/ARK links), and encodes textual notes and references.

3. **Named Entity Recognition (NER)** - A Python script using SpaCy identifies and tags persons, places, dates, organizations, and works. The editor then enriches entity tags with Wikidata identifiers and complete name attributes. —This step has been enhanced: a [list of recurring named entities with their Wikidata identifiers](WikiLinksPCalvin.md) is passed into the prompt for basic encoding along with the encoding template, enabling more efficient and accurate NER than SpaCy alone provides.

4. **Modernization** - Using XSLT transformations, archaic French lexical variants are replaced with modern equivalents using XSLT 2.0 and regular expressions, while preserving Calvin's style. Interventions follow a medieval French glossary and remain limited to lexical level. After the transformation runs, the editor reviews and corrects errors and/or modernizes words missed by the transformation.

5. **Annotations & Analysis** - The editor adds textual annotations comparing manuscripts with the Bonnet edition, identifies missing information, provides paleographic notes, and translates Latin passages into French.

6. **Thematic Analysis for Theme Identification** - An in-depth textual analysis is performed to identify and validate underlying themes that may not be immediately evident. Using natural language processing techniques (word frequency, co-occurrence analysis, semantic similarity, key term extraction via TF-IDF, and stylometric analysis), the script generates visualizations and similarity matrices. These analyses include bigram/trigram studies, identification of co-occurrence patterns within contextual windows, and comparison of similar paragraphs to verify coherence. The results (similarity matrices, co-occurrence lists, PCA graphs) serve as validation or complement to the editor's thematic decisions, who retains final authority in theme assignment—particularly important for shorter letters where themes may be implicit or nuanced.

7. **Spanish Translation** - The modernized French text is translated using a fine-tuned Gemini model trained on the first 15-18 edited and translated letters. The editor/translator revises the result and encodes it alongside French content. Translation fragments are aligned with the French (targeting ~5000 tokens per fragment) to create training data for the translation memory system.

8. **TEI Encoding of Spanish Version** - The Spanish translation is encoded in TEI using a Gemini API prompt that passes [the Spanish encoding protocol](templateXMLes.xml) and the French TEI reference file. The result is reviewed and corrected by the editor, particularly for complete name attributes of named entities, bibliography, encoding, and annotations.
   **Validation note** - Check FR-ES correspondence before publication. For example, if the bilingual interface displays the French version where the Spanish translation should appear, this usually means that the value of the `corresp` attribute in `sourceDesc` in the Spanish XML file does not match the value of the `xml:id` attribute on the `TEI` element in the corresponding French XML file.

#### 2. Publishing Stage: Automated Display & Indexing

Once editing is complete, Python scripts extract structured data:

- **Wikidata Integration** - Data (names, abstracts, coordinates, images) is queried from Wikidata using SPARQL *endpoints* and organized into JSON files for different indexes
- **Index Generation** - Name index, place index (interactive map), and timeline are generated from extracted structured data (from Wikidata)
- **System Deployment** - XML files and JSON data are added to the SvelteKit-based publishing platform; the API automatically integrates new content and serves it live
- **Client-Side XSLT** - SaxonJS library enables XSLT transformations (modernization, variants) on the client side for flexible text display options (multiple versions from a single source file)
- **PDF Generation** - Experimental feature allowing users to generate PDF versions with cross-index filtering by categories, dates, people, places, and search term; it records user preferences to study interests of modern readers of Calvin's correspondence
- **Diplomatic Transcriptions** - Research interface for manuscript transcriptions of Calvin's original handwriting (selection)

### Project Structure

**Editorial Pipeline Scripts:**

- `Py_scripts_autoencoding_modeltraining/` - Python scripts for basic TEI encoding, NER, translation model fine-tuning, and training data alignment
- `DataExtraction_Index/` - Scripts to extract and organize structured data from XML for indexes (persons, places, timeline data)
- `output/` - Generated outputs including modernized XML, NER processing results, and final versions (XML) for publishing
- `data_json/` - JSON files used for interactive visualizations and indexes
- Interactive map creation platform: [French](https://observablehq.com/d/1956978c14deb22b), [Spanish](https://observablehq.com/d/de8c36a8a2970791); to update the interactive map, simply replace the json file with [the new version](data_json/data_carte.json) and embed with JavaScript Runtime (more detailed instructions on [the publishing repository](https://github.com/pippaJeanne/lettres-calvin?tab=readme-ov-file#2-adapt-the-interactive-map))

**Publishing System (SvelteKit):**

The publishing platform is organized into two main directories:

**`src/lib/` - Internal Files:**
- `biblRep/` - JSON files for library information and visualizations
- `components/` - Reusable Svelte components
- `data/` - Markdown content (French `md/` and Spanish `mdes/`)
- `odd/` - XML schema customization
- `xml/` - XML files in French
- `xmles/` - Spanish translation XML files
- `fr_es.js` - Internationalization (i18n) configuration
- `search.ts` - Full-text search function definitions
- `*.css` - Stylesheets: `blog.css` (letter pages), `error.css`, `style.css` (general), `toc-css.css` and `pagedjs_css.css` (PDF generation)

**`src/routes/` - Routing Logic:**
- `[lang = lang]/` - Language-based routing structure containing:
  - `lettres/` - French letters display
  - `cartas/` - Spanish translations display
  - `carte/` - Interactive place index map
  - `categories/` - Thematic category filtering
  - `index_noms/` - Name index
  - `tags/` - Thematic tags index
  - `pdf_generator/` - PDF generation page with filtering options
  - `transcription/` - Diplomatic transcriptions of Calvin's handwriting
  - `search/` - Full-text search functionality
- `api/` - Data retrieval from XML files; exposes XML via API for client-side XSLT transformation and download
- `hooks.server.js` - Language-based redirection logic

**`static/` - Client-Facing Assets:**
- `pics_protocole/` - Transcription protocol page images
- `saxonjs3/` - SaxonJS library for client-side XSLT transformation
- `xslt/` - XSLT transformation sheets and compiled SaxonJS executables (SEF.json files)
- `.js` files and images for site functionality, including manuscript and printed source facsimiles

**`EditorialPipeline_ppt/`** - Technical documentation of the architecture

**Scripts Overview:**

- `NER.py`, `NERcopie.py`, `NERforDirFiles.py` - Named entity recognition using SpaCy
- `4trainingmodel.py`, `2translate_*.py` - Translation model fine-tuning and inference
- `Adapt_trainingdata_structure_json2jsonl.py` - Training data alignment and formatting
- `transfomXSLTpy.py` - XSLT transformations for modernization
- `ExtractRefDataWiki.py`, `persQueries.py`, `placeQueries.py` - Wikidata extraction scripts

### Key Features

✓ **Semi-automation with human control** - Machine learning assists but the editor maintains final authority  
✓ **Error detection** - Automated validation flags encoding inconsistencies and missing information  
✓ **Flexible data reuse** - Structured XML and JSON enable multiple visualization and indexing approaches  
✓ **Bilingual apparatus** - Integrated French-Spanish critical edition with careful language alignment  
✓ **Manuscript fidelity** - Diplomatic transcriptions and paleographic annotations alongside modernized versions  
✓ **Linked Open Data** - Integration with Wikidata enables rich contextual information and external linking  
✓ **Scalable workflow** - Monthly batches of 7-8 letters keep the edition current with manageable complexity



