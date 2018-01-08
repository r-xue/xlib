import os
import inspect
from os.path import expanduser
home = expanduser("~")
print ""
print "+"*70
print 'load startup file: '+os.path.realpath(inspect.stack()[0][1])
print "+"*70
print "home: "+home

import sys
sys.path.append(home+'/Dropbox/Worklib/python/')
sys.path.append(home+'/Dropbox/Worklib/projects/highz/cats/')
sys.path.append(home+'/Dropbox/Worklib/projects/zlib/iraf/')
sys.path.append(home+'/Dropbox/Worklib/projects/highz/uvlfs/')
sys.path.append(home+'/Dropbox/Worklib/projects/highz/hxmm01/')
sys.path.append(home+'/Dropbox/Worklib/projects/xlib/stats/')

