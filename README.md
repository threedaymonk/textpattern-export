Textpattern export
==================

This script will export posts and comments from Textpattern into a simple
flat-file format that can easily be parsed and imported into another system.

It only covers the set of functionality I use, and excludes anything concerning
multiple-author blogs.

For reproducibility, only the rendered HTML version of a post is exported.

A few tweaks are applied:

* HTML is tidied to XHTML with `tidy`
* Multiple BRs in comments are converted to proper paragraphs

Usage
-----

* Put your database configuration in `config.yaml`
* Install gems with `bundle install`
* Run `bundle exec ./export`
* Comments are written under `content/`

Encoding
--------

Make sure that any database dump is imported into a table created with

    CREATE DATABASE textpattern CHARACTER SET utf8

and imported using

    mysql -u $USER -p --default-character-set=utf8 textpattern < $DUMP

or MySQL's pathological love of Latin1 may take over and give you mojibake.
