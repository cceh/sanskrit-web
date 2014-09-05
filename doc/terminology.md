Technical terminology in use in sanskrit-web
============================================

**NOTE: the current code does not yet fully respect the technical
terminology described here.**

The following list of terms describes the words used in the sanskrit-web
project.

The sanskrit-web project combines together several semi-independent
efforts each of which developed its own terminology to fulfil its tasks.
It is hard to reason about different pieces of information coming from
different projects without having a single reference to stick to.

The aim of this list is, thus, to clarify the meaning of these terms, but
also to provide a guideline useful to future developers.

## term

The _term_ is the string being searched by the user. It may contains
letters from any script, including non alphabetical characters (spaces,
punctuation, etc.).

Examples:

* `a`
* `aMS`
* `a-ka`
* `*nso`

## match

A _match_ is an entry returned by a query. There are various types
of matches:

* lemma matches (exact, partial, similar),
* definition matches (exact, partial, similar).

### match in the web application

In the web application code, each match is a raw XML [entry](#entry) returned
by a query made via the xpathquery library and fulfilled by eXist-DB.

TEI entries are extracted from matches and then turned into plain Ruby
entry objects.

## lemma

A _lemma_ is the canonical form of a set of words, used in a dictionary to
represent all the [other forms](#form) (inflected, hyphenated, etc.).

Examples:

* `aMSa`
* `laNkA`
* `kf`

## definition

The _definition_ is the part of an [entry](#entry) that explains the meaning
of its associated [lemma](#lemma). The meaning is conveyed describing one or
more of the lemma's [senses](#sense).

## sense

A _sense_ describes one of the meaning of a [lemma](#lemma) using other words.

## entry

An _entry_ combines together a [lemma](#lemma) with a [definition](#definition).

A dictionary can be seen as a long list of entries.

Beware: it is common to refer to an entry using only its lemma, as in the
sentence "The entry `aMSu` contains 10 senses". This means that there is
an entry, whose canonical form (lemma) is `aMSu` and whose definition
consists of 10 senses.

However, **referring to entries using their lemmas is a problem** because of the
existence of [homographs](#homographs): separated entries that happen to have
the same lemma. For example, the lemma `aMh` is both the lemma for

1. the entry with the meaning "to go, to set out" and
2. for the entry with the meaning "to press together".

Entries should be referred to using their IDs, not their lemmas.

### entry in the TEI dictionaries

Entries are stored in the TEI databases in `tei:entry` elements.

Each entry in the CDSL TEI dictionaries has a dictionary-wide unique ID in
its `xml:id` attribute.

### entry in the web application

**NOTE: the URI path for single entries is currently
`/dictionary/DICT/lemma/ENTRY-ID`, instaed of the more precise
`/dictionary/DICT/entry/ENTRY-ID`**

## subentry (or related entry)

A _subentry_ is an [entry](#entry) that appears as part of another entry
because of their strong relation.

Subentries can be nested inside other subentries.

Examples:

* the entry `aMSu` (a filament) contains 18 subentries: `aMSujAla` (a blaze
of light), `aMSuDara` (bearer of rays, the sun), `aMSuDAraya` (a lamp), etc.

Even if they are related entries, subentries are treated most of the times
as normal top-level entries.

## subentry in the TEI dictionaries

Subentries are stored in the TEI dictionaries as `tei:re` (related entry).

All the code that deals with TEI entries should also be ready to deal with
subentries.

## form

A _form_ is a one of the many ways in which a word can be expressed. Words
have a _canonical form_, a _hyphenated form_ and many other forms.

### form in the TEI dictionaries

In the CDSL TEI dictionaries all the forms are inside the element
`tei:form`.

The canonical form is the [lemma](#lemma) and is in the `tei:orth` element.

The hyphenated form is in the `tei:hyph` element.

## homographs

_Homographs_ are [entries](#entry) that have the same lemma but different
meanings. In other words, they are words that are spelled the same but mean
different things.

Examples:

* `akza` is the lemma to 5 homograph entries, each of which has various
  senses:
  1. an axle, a car, a chariot
  2. a die for gambling, a cube, a weight
  3. an organ of sense
  4. a synonym to `akzacaraRa`
  5. the eye
