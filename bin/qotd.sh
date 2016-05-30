#!/bin/sh

fmt -s `find  ~/Dropbox/AppData/quotes  -type f | perl -MList::Util -e 'print List::Util::shuffle <>' `

