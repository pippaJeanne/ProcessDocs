# Slide Notes

## Slide 1

Hello, Today I’ll be presenting the semi-automatic editorial pipeline I
developed for my thesis project: a bilingual critical digital edition of
John Calvin’s French Correspondence. Bilingual, FR-ES

## Slide 2

First I’ll talk about the edition, its main objective and features. Then
I’ll talk about the editing process for Calvin’s correspondence we’ll
then go into the editorial pipeline perse and its two main stages
Pre-processing and Publishing

Finally I’ll talk about the main challenges and Advantages.  I will not
be able to go into detail for some aspects due to time, but feel free to
ask questions at the end of the presentation

## Slide 3

The edition is called “Lettres de Calvin”, Calvin’s Letters in English.
Bilingual digital critical edition of John Calvin’s French
correspondence

For those who may not be familiar with John Calvin, John Calvin was a
French reformer, known for founding the Calvinist community in Geneva in
the mid-16th century. Calvinism is a branch of Protestantism based on
Calvin’s doctrine and therefore named after him. The most famous aspect
of his doctrine is the matter of predestination which has been quite
polemic as many consider it to challenge the existence of free will. So
The edition is meant to function as a dynamic research platform focused
on John Calvin’s French correspondence as a way of gaining insight into
the man, his socio-political context, his doctrine and the impact his
context had on his doctrine and vice-versa, the impact his doctrine had
on his time and contemporaries.

## Slide 4

The Main features of the edition include : Transversal multilayered
indexing (chronological, thematic, by categories, by people, by places
as you can see in the images)

## Slide 5

A Side-by-side version and manuscript comparison as you can see here.
You can also change the order of the sections to compare the manuscript
directly with the modernized version for example. You will find many
options there, including direct access to the XML, toggle between
versions and a full screen view to read more comfortably and print.

## Slide 6

A Spanish translation that you can also read independently in the
Spanish interface, not only in the critical apparatus in the French
interface.

## Slide 7

A Diplomatic transcription of a selection of autograph manuscripts (in
Calvin’s handwriting), especially the ones with text on the margins.
This is also a comparative view, so you can also compare the original
with Jules Bonnet’s edition to directly see his level of intervention on
the text.

## Slide 8

I am also developing a feature for Generating PDF versions based on the
indexes of the edition. It’s not finished yet. I need to edit more
letters so I can test for performance with larger amounts of data.

## Slide 9

Now … When it comes to editing Calvin’s correspondence, there are
several main things to consider: First of all, The search for manuscript
sources, the census and organization of the corpus, especially when I
found out many of them where available and already digitized. I always
wanted to show them in the edition. Most of them are preserved at the
Library of Geneva, gathered in different codices, but there are also a
few from printed editions or from other collections and libraries. The
index of categories includes that dimension under ”nature/type of
primary sources” on the home page.

Sencondly, Finding the structure of the letters (commonalities,
differences): this step is quite important when it comes to refining the
encoding protocol and finding the salient features for indexing and for
setting up the publishing algorithm

Then we have setting up the Editorial and XML encoding protocol : it
entailed a lot of editorial choices, always taking into account the
layout and content of the critical apparatus, access to the manuscript
sources, annotations, indexes, variations, links to external sources and
databases such as Wikidata, translation of fragments in Latin, etc.

Regarding Further research, contextualization and dealing with
information gaps : it involved adding information to Wikidata on some of
Calvin’s correspondents who are less widely known (e.g. Monsieur de
Fallais and his wife with whom he corresponded for about a decade),
researching the addressee and the context of the letter (Jules Bonnet’s
annotations helped in many cases! Especially to provide a starting
point) particularly in order to try and pinpoint the place of
destination of the letter or probable date when that information is
missing or unclear (especially important for the index of places). Also
essential in order to add contextual and editorial annotations.

And last but not least : Doing some paleography: mostly to study the
manuscript sources to add editorial annotations regarding the comparison
with the manuscript sources and early versions, sort of like tracing the
editorial history of the letters.

## Slide 10

Now we get the thick of the matter = \> The editorial pipeline

The editorial pipeline consists of two main stages:

Pre-processing stage (which is mainly editing end encoding) Publishing
stage (the online publishing part), which is mostly automatic (we’ll get
into details later)

We’re going to go one by one and cover the main characteristics and main
steps. And of course what is automated and how it works. I have to point
out that the automation of certain processes, especially in the editing
stage is a semi-automation since human supervision, correction and
completion of the task is key.

Let’s start with the pre-processing or editing phase

## Slide 11

The First step is the Basic structural encoding of the letter in XML
(The base text for this is Jules Bonnet’s edition of 1854) The OCR text
is provided by Gallica (the digital platform of the BNF (Bibliothèque
Nationale de France)) where this edition can be found The OCR text of
the letter being edited is extracted from the overall document and
corrected for any possible OCR mistakes. The text usually has the
footnotes sort of scrambled into the text itself, so you have to
organize that a bit and differentiate them from the core of the text.

Then, the curated OCR text and the XML encoding template (which is
created after the editorial protocol and customized to the edition
specific needs, especially to accommodate the references to the
manuscript and printed sources as well as certain indexing elements such
as thematic keywords and a summary/short description of the letter, the
rest follows the TEI recommendations for encoding letters) are passed in
a prompt using the Gemini API to generate a basic structurally encoded
letter.

\*I used to do this by hand but then I tested the AI and it did a decent
job so I began to use it as part of my workflow. The result includes
some of the metadata in the TEI Header that doesn’t change substantially
from one letter to the next, empty elements but at the right place
structurally speaking like an “opener” tag, a “salute” tag and a
“closer” tag, and the paragraphs correctly encoded inside “p” tags.

Then it’s up to the human to correct any mistakes and encode the notes
that are usually left inside the paragraph without proper encoding,
adding the rest of the relevant metadata and the call numbers and
references (IIIF or ARK link) to the specific pages/facsimiles of the
manuscript and printed sources. If the preservation institution of that
letter changes, that has to be changed too. I say this because the best
part of my corpus’s sources are preserved at the Library of Geneva, but
some are found at the BNF and even a couple were relayed to us in early
printed editions.

## Slide 12

This is An overview of the sources inventory You see here that most
primary sources are preserved at the Library of Geneva. And there are
about 7 letters whose primary sources are printed editions.

## Slide 13

Once we have a basic structural XML encoding of the letter, there comes
time for encoding the named entities.

A first sweep is done using a python script that relies on SpaCy, the
open-source library for NLP I’m sure some of you know. The algorithm
takes what SpaCy returns and uses it to add the corresponding XML tags
depending on the labels returned by SpaCy. Only persons, places, dates,
organizations and works of arts are used; the rest is left out. I have
to say that Spacy doesn’t work for French and Spanish as it does for
English unfortunately, but it’s still good enough to streamline part of
the work.  
Of course correcting and enriching the content is the next step. It
involves adding the links to the external references, mostly Wikidata
identifiers that will be used for extracting information and indexing,
and editing attributes, especially the ”key” for the complete name of
the person or place or book title if the are referenced in the text in
any other way.

Some annotations might be added as well at this time.

## Slide 14

Now we start adding the choice tags for the modernisation. The language
in Bonnet’s edition is still quite archaic. In his edition he mainly
formalizes the punctuation, develops the abbreviations and divides the
text into paragraphs, but that’s as far as his intervention in the text
itself goes. A modernisation makes the text easier to read for today’s
French speakers and makes it easier for the translation as well,
especially for this little Cuban. The intervention for the modernisation
is mostly at the lexical level. The interventions at the syntactical
level are limited to short phrases in the form of collocations such as:
avoir/être métier = avoir besoin toutes fois et quantes (cf. glossaire)
: aussi souvent que…, chaque fois que…

The reason for this, besides the difficulty for a non-native French
speaker, is the fact that doing this could change or veil Calvin’s
style, which is also a reflection of his time. A series of middle French
dictionaries and glossaries are consulted for this. Of course

Some of it is integrated in the XSLT transformation, which is an adapted
version (adapted to my corpus that is) of an XSLT file create by the BVH
program (BVH stands for Bibliothèques Virtuelles Humanistes). We use
regular expressions for this so we use version 2.0 of XSLT.

Example of adaptation : a rule for accounting for the  ”l” in ceulx that
becomes « ceux » without the « l », the way we use it nowadays.
Generalization of a rule to take into account all possible variations of
the imperfect tense. Which helps since it tends to be used a lot.

## Slide 15

Then we continue with All kinds of relevant annotations, including -
textual annotations on the differences between the manuscript and
Bonnet’s version (that’s where paleography comes in and models for
handwritten text recognition), - annotations on missing information in
the sources such as letters missing the last folium with the closing
paragraph and the signature - some basic textual analysis will be done
for some aspects in order to see if something interesting comes out
(word frequency, similarity and co-occurrence mainly) For example: a
similarity analysis to verify that last missing paragraph that we find
in a manuscript copy is consistent with the content and style of other
letters sent to that same person whose complete originals we do have -
translation into French of texts in Latin that most modern readers do
not understand

## Slide 16

The translation is done using a mixed approach: automatic translation
and computer assisted translation. The modernized text in French is
translated using a model I already trained on previous translations of
letters via the Gemini API. The resulting translation is then revised
and edited. And then encoded following the same steps used for the
French version, leaving out of course the modernization step. Some of
the annotations concerning specific aspects of the French language are
left out of the Spanish translation. The encoding of the Spanish
translation usually goes faster (less details to encode).  \*\*
Important thing to check here: making sure the value of the[^1] of the
SourceDesc element in the Spanish translation matches the[^2] of the
French letter

Once the translation is done, it is added to the training data for the
translation model. This is done with a python script and the resulting
alignment is corrected manually since the automatic alignment is not
perfect (it’s roughly a character count to keep under 5000 tokens per
fragment for the training to work). The training data consist of aligned
fragments Fr-ES for the translation memory, which helps keeping specific
terms, turns of phrases and style consistent. This mimics a basic
computer assisted translation system.

## Slide 17

We finally get to the publishing stage :  The publishing system is
already set up using the SvelteKit framework. I will briefly explain how
it works next. Every time a new letter is edited, we need to update the
indexes to account for the new information. With a series of Python
scripts, data (names, abstracts, thumbnails and coordinates) are
extracted from Wikidata using the Wikidata ids encoded in the XMLs. This
is done via the Wikidata Sparql Endpoint. The data is then organized in
different ways for the different indexes. These JSON files are then used
for the visualizations functioning as indexes (namely the index of
names, the index of places in the form of an interactive map, and the
timeline)

The XML files and the JSON files are added to the system. And voilà,
it’s live! All the algorithms in place integrate the new data into the
API and serve the information. The idea is to Update with 7-8 letters at
a time once a month.

## Slide 18

This is an overview of the file architecture of the publishing system

This is the main folder

The lib directory is for the internal files (files, data, components,
CSS files)

The routes directory deals with the routing logic and contains templates
to which the data will be passed to be served

## Slide 19

This a more detailed view of the lib directory.

Here we have the XML files in French and Spanish

And the folder for the JSON files that we mentioned earlier

## Slide 20

This is the simplified view of the routes directory

Here we have the API logicWe have the template for the pages displaying
a side-by-side interface to study a selection of transcriptions of
Calvin’s writing

The redirection logic for the bilingual interface and the error page

## Slide 21

This a more detailed view of the routes directory.

I can only show you part of it here. But you can go see it on my GitHub
repository.

I don’t have time to go into the details here. But feel free to ask me
later.

## Slide 22

Finally Challenges and Advantages of a Semi-Automatic Editorial Pipeline

One of the challenges was of course developing the algorithms.
Especially when they start getting complex, although they are mainly
divided into logical parts. As you have seen, the automation kicks in to
deal with very specific tasks and they are always supervised by the
human. So you tend to have a sequence that goes machine =\> human or a
combination of machine-human =\> human

The human always has the final say.

\*\* For the API, I counted on salient aspects of the correspondence to
build it around so I could bring them out and exploit them in different
ways (I’m talking about particular characteristics of the letters: type
of sources, dates, places, addressees, signature, themes)Articulating
all of it wasn’t the easiest of tasks, though.

There’s also the scripts for extracting the information from Wikidata
and then organize it. There are limits for the amount of data to be
passed so you have to do it in batches, which has to be integrate it
into the script

The Language alignment for the critical apparatus and for the routes was
another challenging part The logic is spread out over several files and
demands attention to detail.I had to establish a series of filters and
checks to avoid errors and to point them out in case there were any.

Which leads me to the advantages.

## Slide 23

One of the greatest advantages was the flagging of errors, especially
encoding errors, allowing for the correction of mistakes overlooked in
previous stages. Like: - inconsistencies, errors in the content, missing
information…(especially missing or wrong “id” of “corresp” values) for
the FR-ES alignment This same mechanism also suggested better data
structuring methods based on what worked best in terms of reuse and easy
access to the data. An object of key values instead of arrays for
example

The process can also point out gaps in the information: - missing
closing paragraph, no signature, unclear name of recipient - places of
destination and sometimes origin of the letter that are not expressly
written. Further research may help us establish a plausible hypothesis.
For example we can establish that the letters to the king of England
were sent to London. And that the last letter to Monsieur de Fallais was
sent to Veigy-Foncenex as historical records indicate he was there at
the time.

It reveals new indexing possibilities : for example the possibility to
use the missing signature in some letters as one of the criteria for
indexing.

Also the index of names can be generated in a couple minutes and the
intertextual hyperlinks are integrated into the publishing system with
the XSLT transformations.

\*\* All of this allows for flexible content reorganization by enabling
the data to be reused easily and allowing the reader to choose how to
examine the letters and in what level of detail.

## Slide 24

Thank you for your attention! Here you have the QR codes again if you
wanna go take a look.

Time for questions now.

[^1]: **Corresp?**

[^2]: **Xml:id?**
