//
//  ACWrapper.m
//  Aurical
//
//  Created by Brian Ault on 10/9/14.
//  Copyright (c) 2014 XPR. All rights reserved.
//

#import "ACWrapper.h"

@implementation ACWrapper

@end


from common import DEBUG
from common import VERBOSE
from common import log
from common import AUDIOBOOK_KNOWN_GENRE

###############################################################################
#
#   a convenience class to wrap a file type and fetch its meta data related
#   informtion. And allow easy requests for information fields, whether they
#   exist or not.
#
#   if derived class defines __init__ at all:
#       then _MUST_ call base class like so:
#
#       def _init_(self, afile):
#           baseWrapper.__init__(self, afile)
#           # baseWrapper calls: self._parse_file(afile)
#           # whatever else you want to do
#
#   derived class _MUST_:
#       def _parse_file(self, afile):
#           if isinstance(afile, basestring):
#               # parse given filename
#           elif isinstance(afile,file):
#               # parse given open file object
#           else:
#               throw or not,  your choice.
#
#   usage:
#       import baseWrapper
#       class someWrapper(baseWrapper)
#           def __init__(self,afile):
#               baseWrapper.__init__(self, afile)
#               # whatever else, but _parse_file already called.
#           def _parse_file(self, afile):
#               if isinstance(afile, basestring):
#                   # parse given filename
#               elif isinstance(afile,file):
#                   # parse given open file object
#               else:
#                   throw or not,  your choice.
#
#      my = someWrapper("pathtofile")
#      title = my.get('title')                  # None returned if not available
#      author = my.get('author', _('Unknown'))  # specify a default value
#
class baseWrapper(object):
# @param:afile - the open file object, or the path to a file
#
# calls self._parse_file(afile), so the derived class can better define it.
#
def __init__(self, afile):
self.tags = {}
try:
self.filename = afile.name
except:
try:
self.filename = afile.geturl()
except:
self.filename = str(afile)
if self.filename.startswith("file:///"):
self.filename = self.filename[8:]
self._parse_file(afile)     # defined in derived class

# bw.get('parent_title')
#   explicit fetch of tag value
def get(self, name, dflt=None):
if VERBOSE:
log.debug(".get('%s') = '%s'" % (name, name in self.tags and self.tags[name] or None))
if name in self.tags:
return self.tags[name]
return dflt
# bw.has('parent_title')
#   explicit test of tag presence
def has(self, name):
if VERBOSE:
log.debug(".has('%s') = '%s'" % (name, name in self.tags and True or None))
if name in self.tags:
return True
return False
# bw.set('parent_title', 'dad')
#   explicit set of tag value
def set(self, name, value):
if VERBOSE:
log.debug(".set('%s') = '%s'" % (name, value))
self.tags[name] = value
# bw.rem('parent_title')
#   explicit removal of tag
def rem(self, name):
if VERBOSE:
log.debug(".rem('%s')" % (name))
if name in self.tags:
del self.tags[name]

# bw.parent_title
#   implicit fetch of tag value
#   only called if object.getattr didn't find anything
#   throws AttributeError if not available
#
def __getattr__(self, name):
if VERBOSE:
log.debug(".__getattr__('%s') = '%s'" % (name, self.get(name,"AttributeError")))
if name in self.tags:
return self.tags[name]
# standard behavior on no such attribute
raise AttributeError("%r object has no attribute %r" %
                     (type(self).__name__, name))
def __len__(self): return len(self.tags)
def __getitem__(self, key): return self.tags[key]
def __repr__(self): return repr(self.tags)

# debugging dump to console of what information we have
#
def dump(self,w=0):
(dir, name) = os.path.split(self.filename);
print "File:",name
print " Dir:",dir
for t in self.tags: w = w<len(t) and len(t) or w
for t in self.tags:
if t == 'cover_art':
ca = self.tags[t]
ca = ca and ca[:16] or None
print "   [%s] = '%s' ..." % (t.ljust(w),ca)
else:
print "   [%s] = '%s'" % (t.ljust(w),self.tags[t])

# debugging dump to log of what information we have
#
def log(self,w=0):
log.info("File: %s" % self.filename)
for t in self.tags: w = w<len(t) and len(t) or w
for t in self.tags:
if t == 'cover_art':
ca = self.tags[t]
ca = ca and ca[:16] or None
log.info("   [%s] = '%s' ..." % (t.ljust(w),ca))
else:
log.info("   [%s] = '%s'" % (t.ljust(w),self.tags[t]))

def _copy_file(self, source, dest, buffer_size=1024*1024):
"""
Copy a file from source to dest. source and dest
can either be path strings or any object with a read or
write method, like StringIO for example.
"""
log.debug(".source: %s" % (str(source)))
if not hasattr(source, 'read'):
if -1 != source.find('://'):
import urllib2
source = urllib2.urlopen(source)
else:
source = open(source, 'rb')
log.debug(".dest  : %s" % (str(dest)))
if not hasattr(dest, 'write'):
dest = open(dest, 'wb')

total = 0
while 1:
copy_buffer = source.read(buffer_size)
if copy_buffer:
total += len(copy_buffer)
dest.write(copy_buffer)
else:
break

source.close()
dest.close()
log.debug(".total : %d" % (total))