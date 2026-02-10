
#pip install SPARQLWrapper
import json
from SPARQLWrapper import SPARQLWrapper, JSON
#get json file contianing the data
placedata = {}
with open("data_json/wikiIds_es.json", "r") as indexData:
  placedata = json.load(indexData) 
# Preparing data for query
# Getting access keys 
files = placedata.keys()
place = {}
# Organize according to service :@ wikidata
for f in files:
  places = list(placedata[f]["places"].keys())
  if places is not None:
    for n in places:
      place[n] = placedata[f]["places"][n] 
#print(place)

# Getting wikidata ids
uriswiki = {}
for key in place.keys():
  if place[key] is not None and place[key].__contains__("wikidata"):
    spans = place[key].split("/")
    uriswiki[key] = spans[-1]

qwiki = []

wikilist = list(uriswiki.keys())
print(len(wikilist))


query_wiki = ""
queryfile = ""
# To execute query | Pass values for queries
urlWikidata = "https://query.wikidata.org/sparql"
sparql_wiki = SPARQLWrapper(urlWikidata)

places = []

# Seting limit of about 25 to avoir overloading the query and getting timeout error
limit = 25
n = len(wikilist)//limit
for i in range(n+1):
  newlimit = (i+1) * limit
  if newlimit > len(wikilist):
    newlimit = len(wikilist)
  print("Executing query for items from " + str(i*limit) + " to " + str(newlimit))
  for w in wikilist[i*limit : newlimit]: 
    item = uriswiki[w]
    q = "{BIND(wd:" + item + " AS ?item) \n  OPTIONAL{?item wdt:P625  ?coord; wdt:P18 ?img. \n BIND(geof:longitude(?coord) AS   ?lon) \n BIND(geof:latitude(?coord) AS   ?lat) \n}}"
    qwiki.append(q)
    query_wiki =  " UNION ".join(qwiki)
    queryfile += query_wiki + "\n"
    query = "\n PREFIX wdt: <http://www.wikidata.org/prop/direct/> \n PREFIX wd: <http://www.wikidata.org/entity/> \n PREFIX wikibase: <http://wikiba.se/ontology#> \n PREFIX geof: <http://www.opengis.net/def/geosparql/function/> \n SELECT DISTINCT ?item ?itemLabel ?itemDescription ?coord ?lon ?lat ?img \n  WHERE { \n " + query_wiki +  "\n SERVICE wikibase:label { bd:serviceParam wikibase:language 'es' } \n }"
    #print(query)
    sparql_wiki.setQuery(query)
    sparql_wiki.setReturnFormat(JSON)
    results = sparql_wiki.query().convert()
    #print(len(results['results']['bindings']))

    #Organize results in a list of dicts  
    for result in results["results"]["bindings"]:
      img = ""
      url = result["item"]["value"]
      name = result["itemLabel"]["value"]
      desc = result["itemDescription"]["value"] if result.__contains__("itemDescription") else ""
      place =  {"name": name,"desc" : desc, "url": url}
      if result.__contains__("lat") or result.__contains__("lon"):
        lat = result["lat"]["value"]
        lon = result["lon"]["value"]
        place["coord"]={"lat" : lat, "lon": lon}
      if result.__contains__("img"):
        img = result["img"]["value"]
      if img is not None or  img != '':
        place["img"]=img
      places.append(place)
    #print(len(results['results']['bindings']), len(places))
    qwiki = []

# Create file for with results
jsonfile = places
print(len(jsonfile))
json_obj = json.dumps(jsonfile, indent=7, ensure_ascii = False)
with open("data_json/placeData_MapIndex_es.json", "w") as outfile:
    outfile.write(json_obj)
    print("Done!")

# Create files for query
jsonfile1 = "\n PREFIX wdt: <http://www.wikidata.org/prop/direct/> \n PREFIX wd: <http://www.wikidata.org/entity/> \n PREFIX wikibase: <http://wikiba.se/ontology#> \n PREFIX geof: <http://www.opengis.net/def/geosparql/function/> \n SELECT DISTINCT ?item ?itemLabel ?itemDescription ?coord ?lon ?lat ?img \n  WHERE { \n " + queryfile +  "\n SERVICE wikibase:label { bd:serviceParam wikibase:language 'es' } \n }"
json_obj1 = json.dumps(jsonfile1, indent=7, ensure_ascii = False)
with open("placesQueryes.txt", "a") as outfile:
    outfile.write(json_obj1)
    print("Done!")

