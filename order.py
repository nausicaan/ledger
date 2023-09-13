#!/usr/bin/env python
import os

home_dir = os.path.expanduser( '~' )

mixed = open(home_dir + "/sources/urls.txt", "r")
ordered = mixed.readlines()
ordered.sort()

desired = open(home_dir + "/sources/urls.txt", "w")
desired.writelines(ordered)
desired.close()