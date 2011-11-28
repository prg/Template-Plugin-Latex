#!/usr/bin/perl --  ========================================== -*-perl-*-
#
# t/22-tableofcontents.t
#
# Test the Latex plugin's ability to process files with tables of contents.
#
# Written by Andrew Ford <a.ford@ford-mason.co.uk>
#
# This is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.
#
#========================================================================

use strict;
use warnings;
use FindBin qw($Bin);
use Cwd qw(abs_path);
use lib ( abs_path("$Bin/../lib"), "$Bin/lib" );
use Template;
use Template::Test;
use Template::Test::Latex;
use File::Spec;

require_dvitype();

my $out = 'output';
my $dir = -d 't' ? File::Spec->catfile('t', $out) : $out;

my $files = {
    pdf => 'test1.pdf',
    ps  => 'test1.ps',
    dvi => 'test1.dvi',
};
clean_file($_) for values %$files;

    
my $ttcfg = {
    OUTPUT_PATH => $dir,
    VARIABLES => {
        dir   => $dir,
        file  => $files,
        check => \&check_file,
	grep_dvi => sub { grep_dvi($dir, @_) },
    },
};

test_expect(\*DATA, $ttcfg);

sub clean_file {
    my $file = shift;
    my $path = File::Spec->catfile($dir, $file);
    unlink($file);
}

sub check_file {
    my $file = shift;
    my $path = File::Spec->catfile($dir, $file);
    return -f $path ? "PASS - $file exists" : "FAIL - $file does not exist";
}



__END__

# Check that table of contents work
# We specify an optional TOC entry for the first section - this is not
# included in the text of the document but just in the table of
# contents, so if we find it in the dvi file then the TOC must have
# bneen formatted.
-- test --
[% USE Latex;
   FILTER latex(file.dvi)
-%]
\documentclass{article}
\begin{document}
\tableofcontents
\section[First Section TOC Entry]{First Section}
\end{document}
[% END -%]
[% grep_dvi(file.dvi, 'Contents') %]
[% grep_dvi(file.dvi, 'First Section TOC Entry') %]
-- expect --
-- process --
PASS - found 'Contents'
PASS - found 'First Section TOC Entry'
