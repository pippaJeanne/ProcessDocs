src/
|-- lib/ -> fichiers internes
|   |-- biblRep/ -> fichiers JSON (info bibliothèques et visualisations)
|   |-- components/ -> composants
|   |-- data/
|   |   |-- md -> billets en français en Markdown
|   |   |-- mdes -> billets en espagnol en Markdown
|   |-- odd/ -> personalisation du schéma XML
|   |-- xml/ -> fichiers XML en français
|   |-- xmles/ -> fichiers XML des traductions espagnoles
|   |-- fr_es.js -> fichier d'internationalisation (i18n)
|   |-- search.ts -> fichier de définition des fonctions 'flexsearch'
|   |-- blog.css -> css pour les pages de lettres
|   |-- error.css -> css pour la page d'erreur
|   |-- style.css  -> styles généraux
|   |-- toc-css.css -> css pour la table des matières pour la génération des PDF
|   |-- pagedjs_css.css -> styles de Pagedjs pour la génération des PDF
|-- routes/
|   |-- [lang = lang]/
|   |   |-- +layout.server.js
|   |   |-- +layout.svelte
|   |   |-- +page.server.js
|   |   |-- +page.svelte
|   |   |-- +error.svelte
|   |   |-- [slug]/ -> route des pages en Markdown
|   |   |   |-- +page.js
|   |   |   |-- +page.svelte
|   |   |-- cartas/ -> route des lettres en espagnol
|   |   |   |-- [id]
|   |   |   |   |-- +page.js
|   |   |   |   |-- +page.svelte
|   |   |-- carte/ -> index de lieux
|   |   |   |-- +page.svelte
|   |   |-- categories/ -> index de catégories
|   |   |   |-- [category]
|   |   |   |   |-- +page.js
|   |   |   |   |-- +page.svelte
|   |   |-- index_noms/ -> index de noms
|   |   |   |-- +page.svelte
|   |   |-- lettres/ -> route des lettres en français
|   |   |   |-- [id]
|   |   |   |   |-- +page.js
|   |   |   |   |-- +page.svelte
|   |   |-- pdf_genrator/ -> route pour la page du générateur PDF avec les filtres
|   |   |   |-- +page.js
|   |   |   |-- +page.svelte
|   |   |-- search/
|   |   |   |-- +server.js
|   |   |-- tags/ -> index thématique
|   |   |   |-- [tag]
|   |   |   |   |-- +page.js
|   |   |   |   |-- +page.svelte
|   |-- api/ 
|   |   |-- +server.js  -> recueille les données depuis les fichiers XML
|   |   |-- xml/  
|   |   |   |--[filename]/ -> expose les fichiers XML pour
|   |   |   |   |-- +server.js   la transformation XSLT et leur téléchargement
|   |-- transcription/ -> route des transcriptions de l'écriture de Calvin (sélection)
|   |   |-- [id]/
|   |   |   |-- +page.js
|   |   |   |-- +page.svelte
|   |-- +error.svelte
|   |-- +page.server.js
|   |-- hooks.server.js -> logique de redirection basée sur la langue

static/ -> fichiers exposés au client
|-- pics_protocole/
|   |-- plusieurs fichiers png pour la page du protocole de transcription
|-- saxonjs3/
|   |-- fichiers js de la bibliothèque saxonjs pour appliquer la transformation xslt côté client
|-- xlst/
|   |-- feuilles de transformation xslt et leurs fichiers sef.json compilés (compilés avec xslt3-he de saxonjs)
|-- une série de fichiers js pour le fonctionnement global du site et des images, y compris quelques images de manuscrits/sources imprimées dont les institutions de conservation n'offrent pas de liens ARK ou d'images compatibles avec le protocole IIIF
