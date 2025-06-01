routes/
|-- [lang = lang]/
|   |-- +layout.server.js
|   |-- +layout.svelte
|   |-- +page.server.js
|   |-- +page.svelte
|   |-- +error.svelte
|   |-- [slug]/ -> route for Markdown pages
|   |   |-- +page.js
|   |   |-- +page.svelte
|   |-- cartas/ -> route for letters in Spanish
|   |   |-- [id]
|   |   |   |-- +page.js
|   |   |   |-- +page.svelte
|   |-- carte/ -> index of places
|   |   |-- +page.svelte
|   |-- categories/ -> index of categories
|   |   |-- [category]
|   |   |   |-- +page.js
|   |   |   |-- +page.svelte
|   |-- index_noms/ -> index of names
|   |   |-- +page.svelte
|   |-- lettres/ -> route for letters in French
|   |   |-- [id]
|   |   |   |-- +page.js
|   |   |   |-- +page.svelte
|   |-- search/
|   |   |-- +server.js
|   |-- tags/ -> thematic index
|   |   |-- [tag]
|   |   |   |-- +page.js
|   |   |   |-- +page.svelte
|-- api/ 
|   |-- +server.js  -> collects data from XML files
|   |-- xml/  
|   |   |--[filename]/ -> exposes XML files for
|   |   |   |-- +server.js   XSLT transformation and download
|-- transcription/ -> route for transcriptions of Calvin's writing (selection)
|   |-- [id]/
|   |   |-- +page.js
|   |   |-- +page.svelte
|-- +error.svelte
|-- +page.server.js
|-- hooks.server.js -> redirection logic based on language