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
|   |-- * plusieurs fichiers css
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
