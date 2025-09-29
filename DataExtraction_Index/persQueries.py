
#pip install SPARQLWrapper
import json
from SPARQLWrapper import SPARQLWrapper, JSON
#get json file contianing the data
persdata = {}
with open("data_json/wikiIds.json", "r") as indexData:
  persdata = json.load(indexData) 
# Preparing data for query
# Getting access keys 
files = persdata.keys()
pers = {}
noms = []
# Organize according to service : dbpedia or wikidata
for f in files:
  names = list(persdata[f]["persons"].keys())
  if names is not None:
    for n in names:
      pers[n] = persdata[f]["persons"][n]
      #if n not in noms and pers[n] != "#" and n != 'Jean Calvin': # n != 'Jean Calvin'  |  n != 'Juan Calvino' 
        #noms.append(n)
  
#print(noms)
urisdb = {}
uriswiki = {}
for key in pers.keys():
  if pers[key].__contains__("dbpedia"):
    urisdb[key] = pers[key]
  if pers[key].__contains__("wikidata"):
    spans = pers[key].split("/")
    uriswiki[key] = spans[-1]
print(uriswiki)
qdb = []
qwiki = []
dblist = list(urisdb.keys())
wikilist = list(uriswiki.keys())
print(len(wikilist))
query_db = ""
query_wiki = ""
for db in dblist:
  item = urisdb[db]
  q = "{<" + item + ">  dbo:abstract ?abstract; <http://dbpedia.org/ontology/thumbnail> ?img.}"
  qdb.append(q)
  query_db =  " UNION ".join(qdb)
# Seting limit of about 25
limit = 25
for w in wikilist: 
  if wikilist.index(w) <= limit: 
    item = uriswiki[w]
    q = "{BIND(wd:" + item + " AS ?item) Optional {?item wdt:P18 ?img; wdt:P570 ?deathDate; wdt:P569 ?birthDate.}}"
    qwiki.append(q)
    query_wiki =  " UNION ".join(qwiki)

# To execute query | Pass values for queries
urlDbpadia = "http://dbpedia.org/sparql"
urlWikidata = "https://query.wikidata.org/sparql"
sparql_wiki = SPARQLWrapper(urlWikidata)
sparql_db = SPARQLWrapper(urlDbpadia)
sparql_db.setQuery("\n"
"PREFIX dbo: <http://dbpedia.org/ontology/> \n"
"PREFIX dct: <http://purl.org/dc/terms/> \n"
"PREFIX foaf: <http://xmlns.com/foaf/0.1/> \n "
"SELECT DISTINCT ?abstract, ?img \n "
"WHERE { \n" + query_db + "\n FILTER ( LANG ( ?abstract ) = 'fr'  ) \n"
"} "  
)
sparql_wiki.setQuery("\n"
"PREFIX wdt: <http://www.wikidata.org/prop/direct/> \n"
"PREFIX wd: <http://www.wikidata.org/entity/> \n"
"PREFIX wikibase: <http://wikiba.se/ontology#> \n"
"SELECT DISTINCT ?item ?itemLabel ?itemDescription ?birthDate ?deathDate ?img \n "
"WHERE { \n " + query_wiki +  "\n SERVICE wikibase:label { bd:serviceParam wikibase:language 'fr' } \n"
"}"
)
sparql_wiki.setReturnFormat(JSON)
sparql_db.setReturnFormat(JSON)
results = sparql_wiki.query().convert()
results1 = sparql_db.query().convert()
#print(results)
persons = []

# Right one : wikidata results
for result in results["results"]["bindings"]:
    img = ""
    url = result["item"]["value"]
    name = result["itemLabel"]["value"]
    desc = result["itemDescription"]["value"]
    pers =  {"name":name, "desc" : desc, "url": url}
    if result.__contains__("deathDate") or result.__contains__("birthDate"):
        birth = result["birthDate"]["value"]
        death = result["deathDate"]["value"]
        b = birth.split("-")
        d = death.split("-")
        dates = f"({b[0]} - {d[0]})"
        pers["name"]= name + " " + dates
                
    if result.__contains__("img"):
        img = result["img"]["value"]
    if img is not None or  img != '':
        pers["img"]=img
            #print(pers)  
    persons.append(pers)


print(len(qwiki))

# Do the rest (same limit)
n = 2
if len(wikilist) >= limit:
  qwiki = []
  newlimit = 25 * n
  for w in wikilist: 
    if wikilist.index(w) > limit and wikilist.index(w) <= newlimit: 
      #print(wikilist.index(w) > limit and wikilist.index(w) <= newlimit)
      item = uriswiki[w]
      q = "{BIND(wd:" + item + " AS ?item) Optional {?item wdt:P18 ?img; wdt:P570 ?deathDate; wdt:P569 ?birthDate.}}"
      qwiki.append(q)
      query_wiki =  " UNION ".join(qwiki)
  sparql_wiki.setQuery("\n"
"PREFIX wdt: <http://www.wikidata.org/prop/direct/> \n"
"PREFIX wd: <http://www.wikidata.org/entity/> \n"
"PREFIX wikibase: <http://wikiba.se/ontology#> \n"
"SELECT DISTINCT ?item ?itemLabel ?itemDescription ?birthDate ?deathDate ?img \n "
"WHERE { \n " + query_wiki +  "\n SERVICE wikibase:label { bd:serviceParam wikibase:language 'fr' } \n"
"}"
)
  sparql_wiki.setReturnFormat(JSON)
  #sparql_db.setReturnFormat(JSON)
  resultsLoop = sparql_wiki.query().convert()
  #print(results)
  #results1 = sparql_db.query().convert()
  for result in resultsLoop["results"]["bindings"]:
      #print(result)
      img = ""
      url = result["item"]["value"]
      name = result["itemLabel"]["value"]
      if result.__contains__("itemDescription"):
        desc = result["itemDescription"]["value"]
      pers =  {"name":name, "desc" : desc, "url": url}
      if result.__contains__("deathDate") or result.__contains__("birthDate"):
          birth = result["birthDate"]["value"]
          death = result["deathDate"]["value"]
          b = birth.split("-")
          d = death.split("-")
          dates = f"({b[0]} - {d[0]})"
          pers["name"]= name + " " + dates
                  
      if result.__contains__("img"):
          img = result["img"]["value"]
      if img is not None or  img != '':
          pers["img"]=img
              #print(pers)  
      persons.append(pers)
  
  limit = newlimit
  n+=1
   
print(persons)

jsonfile = []
for pers in persons:
   if pers not in jsonfile:
      jsonfile.append(pers)

print(jsonfile)


json_obj = json.dumps(jsonfile, indent=7, ensure_ascii = False)
with open("data_json/persIndex.json", "w") as outfile:
    outfile.write(json_obj)
    print("Done!")


# Create files for query
jsonfile1 = query_wiki
#query_text = json.dumps(jsonfile1, indent=7, ensure_ascii = False)
with open("persQueryes.txt", "w") as outfile:
    outfile.write(jsonfile1)
    print("Done!")