#!/usr/bin/perl
package MyParser;
use base qw(HTML::Parser);
use LWP::Simple;

my ($thing) = $ARGV[$0] =~ m/([0123456789]+)$/si;
my $url = 'http://www.thingiverse.com/thing:' . $thing;
my $page = get $url;
my $oddcount = 0;
my $isdl = 0;
my @downloads;
my @dlnames;

my ($title) = $page =~ m/<title>(.+)<\/title>/si;
my ($name) = $title =~ m/(.+) by/si;
my ($author) = $title =~ m/by (.+) - Thingiverse/si;
# print $name."\n";
# print $author;

if ($title eq 'Error - Thingiverse') {
	print "ERROR, NO THING HERE at Thing:$thing. Moving on to the next one...\n";
} else {

	print "Attempting to download $name by $author, Thing:$thing";

	sub start { 
	    my ($self, $tagname, $attr, $attrseq, $origtext) = @_;
	    if ($tagname eq 'a') {
	        if($attr->{ href } =~ 'download') {
	            if($oddcount == 0) {
	                push(@downloads, $attr->{ href });
	                $oddcount = 1;
	            } else {
	                $oddcount = 0;
	            }
	        }
	    }
	    elsif ($tagname eq 'h3') {
	        if($attr->{class} =~ 'file_info') {
	            $isdl = 1;
	        }
	    }
	    elsif ($tagname eq 'h2') {
	        $ish = 1;
	    }
	    elsif ($tagname eq 'p' && $ish) {
	        $isp = 1;
	    }
	}

	sub text {
	    my ($self, $text) = @_;

	    if ($isdl) {
	         push(@dlnames, $text); 
	         $isdl = 0;
	    }
	}

	package main;

	my $parser = MyParser->new;
	$parser->parse($page);

	my $numdl = @downloads;

	$thingDir = "Thingiverse/Thing $thing, $name by $author";
	system("mkdir -p \"$thingDir\"");

	print "\n"."$numdl"." downloads found, downloading..."."\n";

	open(OUTDATA, ">.\/$thingDir\/$title.webloc");
	print OUTDATA <<"ENDFILE";
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>URL</key>
	<string>http:\/\/www.thingiverse.com\/thing:$thing</string>
</dict>
</plist>
ENDFILE

	close(OUTDATA);

	for ($i = 0; $i < @downloads; $i++) {
	    $dlnames[$i] =~ s/^\s+//; #remove leading spaces
	    $dlnames[$i] =~ s/\s+$//; #remove trailing spaces
	    print "$dlnames[$i]\n";
	    system("curl -L http://www.thingiverse.com/"."$downloads[$i]"." -o "."\"$thingDir\"\/\"$dlnames[$i]\"");
	}
	print "Got all the files, now let's also grab the html source so we have the instructions too.\n";
	system("curl -L http://www.thingiverse.com/thing:$thing -o \"./$thingDir/Thing_$thing.html\"");
	
}
