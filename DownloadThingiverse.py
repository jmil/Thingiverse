##### NEED TO FIX DIVISION OPERATOR!!!!!
from __future__ import division
#http://docs.python.org/release/2.2.3/whatsnew/node7.html
#The most controversial change in Python 2.2 heralds the start of an effort to fix an old design flaw that's been in Python from the beginning. Currently Python's division operator, /, behaves like C's division operator when presented with two integer arguments: it returns an integer result that's truncated down when there would be a fractional part. For example, 3/2 is 1, not 1.5, and (-1)/2 is -1, not -0.5. This means that the results of divison can vary unexpectedly depending on the type of the two operands and because Python is dynamically typed, it can be difficult to determine the possible types of the operands.



import os
# import shutil
import time
from time import gmtime, strftime
import re


def done_at(file):
	print file + " done at " + strftime("%I:%M:%S %p", gmtime())
	return


# FROM http://stackoverflow.com/questions/1191374/subprocess-with-timeout
import subprocess, threading

class Command(object):
	def __init__(self, cmd):
		self.cmd = cmd
		self.process = None

	def run(self, timeout):
		def target():
			print 'Thread started'
			self.process = subprocess.Popen(self.cmd, shell=True)
			self.process.communicate()
			print 'Thread finished'

		thread = threading.Thread(target=target)
		thread.start()

		thread.join(timeout)
		if thread.is_alive():
			print 'Terminating process'
			self.process.terminate()
			thread.join()
		print "The Return code is: " + str(self.process.returncode)
		if (self.process.returncode != 0):
			print "ERROR: The return code was " + str(self.process.returncode)

command = Command("echo 'Process started'; sleep 2; echo 'Process finished'")
command.run(timeout=3)
command.run(timeout=1)


for number in range(1,10000):
	theText = "./thingget_OSX.pl " + str(number)
	print theText
	command = Command(theText)
	command.run(timeout=300)






print "\nProcessing Done on " + strftime("%a, %b %d, %Y @ %I:%M:%S %p", gmtime()) + ".\n"
