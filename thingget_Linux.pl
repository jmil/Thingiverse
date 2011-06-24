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
print $name."\n";
print $author;


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

system("mkdir -p \"$name\"");

print "\n"."$numdl"." downloads found, downloading..."."\n";

open(OUTDATA, ">.\/$name\/$title.desktop");
print OUTDATA <<"ENDFILE";
[Desktop Entry]
Encoding=UTF-8
Name=$title
Type=Link
URL=http:\/\/www.thingiverse.com\/thing:$thing
Icon=gnome-fs-bookmark
ENDFILE
 
close(OUTDATA);

for ($i = 0; $i < @downloads; $i++) {
    $dlnames[$i] =~ s/^\s+//; #remove leading spaces
    $dlnames[$i] =~ s/\s+$//; #remove trailing spaces
    print "$dlnames[$i]\n";
    system("wget -q http://www.thingiverse.com/"."$downloads[$i]"." -O "."\"$name\"\/\"$dlnames[$i]\"");
}
