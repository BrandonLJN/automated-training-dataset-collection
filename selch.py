#import wsapi python wrapper
import os
import sys
from wsapi import *

wsp_file = str(sys.argv[1])

print 'using wsp file: ', wsp_file
#create waveshaper instance and name it "ws1"
rc = ws_create_waveshaper("ws1", "wsconfig/SN078080.wsconfig")
print "ws_create_waveshaper rc="+ws_get_result_description(rc)
#read profile from WSP file
WSPfile = open(wsp_file, 'r')
profiletext = WSPfile.read()
#compute filter profile from profile text, then load to Waveshaper device
rc = ws_load_profile("ws1", profiletext)
print "ws_load_profile rc="+ws_get_result_description(rc)
#delete the waveshaper instance
rc = ws_delete_waveshaper("ws1")
print "ws_delete_waveshaper rc="+ws_get_result_description(rc)