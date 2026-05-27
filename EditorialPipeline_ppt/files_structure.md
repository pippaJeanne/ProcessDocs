src/
|-- lib/ -> internal files
|   |-- biblRep/ -> JSON files (library info and visualizations)
|   |-- components/
|   |-- data/
|   |   |-- md -> blog posts in French in Markdown
|   |   |-- mdes -> blog posts in Spanish in Markdown
|   |-- odd/ -> customization of the XML schema
|   |-- xml/ -> XML files in French
|   |-- xmles/ -> XML files of the Spanish translations
|   |-- fr_es.js -> internationalization (i18n) file
|   |-- search.ts -> definition file for 'flexsearch' functions
|   |-- blog.css -> css for letter pages
|   |-- error.css -> css for error page
|   |-- style.css  -> general styles
|   |-- toc-css.css -> css for toc for PDF generation
|   |-- pagedjs_css.css -> Pagedjs styles for PDF generation
|-- routes/
|   |-- [lang = lang]/
|   |   |-- +layout.server.js
|   |   |-- +layout.svelte
|   |   |-- +page.server.js
|   |   |-- +page.svelte
|   |   |-- +error.svelte
|   |   |-- [slug]/ -> route for Markdown pages
|   |   |   |-- +page.js
|   |   |   |-- +page.svelte
|   |   |-- cartas/ -> route for letters in Spanish
|   |   |   |-- [id]
|   |   |   |   |-- +page.js
|   |   |   |   |-- +page.svelte
|   |   |-- carte/ -> index of places
|   |   |   |-- +page.svelte
|   |   |-- categories/ -> index of categories
|   |   |   |-- [category]
|   |   |   |   |-- +page.js
|   |   |   |   |-- +page.svelte
|   |   |-- index_noms/ -> index of names
|   |   |   |-- +page.svelte
|   |   |-- lettres/ -> route for letters in French
|   |   |   |-- [id]
|   |   |   |   |-- +page.js
|   |   |   |   |-- +page.svelte
|   |   |-- pdf_genrator/ -> route for PDF generator page with the filters
|   |   |   |-- +page.js
|   |   |   |-- +page.svelte
|   |   |-- search/
|   |   |   |-- +server.js
|   |   |-- tags/ -> thematic index
|   |   |   |-- [tag]
|   |   |   |   |-- +page.js
|   |   |   |   |-- +page.svelte
|   |-- api/ 
|   |   |-- +server.js  -> collects data from XML files
|   |   |-- xml/  
|   |   |   |--[filename]/ -> exposes XML files for
|   |   |   |   |-- +server.js   XSLT transformation and download
|   |-- transcription/ -> route for transcriptions of Calvin's writing (selection)
|   |   |-- [id]/
|   |   |   |-- +page.js
|   |   |   |-- +page.svelte
|   |-- +error.svelte
|   |-- +page.server.js
|   |-- hooks.server.js