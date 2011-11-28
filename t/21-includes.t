#!/usr/bin/perl --  ========================================== -*-perl-*-
#
# t/21-includes.t
#
# Test the Latex plugin's ability to cope with included files.
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
    INCLUDE_PATH => [ "$FindBin::Bin/input" ],
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
    unlink($path);
}

sub check_file {
    my $file = shift;
    my $path = File::Spec->catfile($dir, $file);
    return -f $path ? "PASS - $file exists" : "FAIL - $file does not exist";
}



__END__

# Check that included files work
# ==============================
#
# 1. process inline LaTeX source
-- test --
[% USE Latex;
   FILTER latex(file.dvi)
-%]
\documentclass{article}
\begin{document}
\section{Introduction}
Including a file.

\include{testinc}
\input{deeply/nested/directory/testinc2}
\end{document}
[% END -%]
[% grep_dvi(file.dvi, 'This is included text') %]
[% grep_dvi(file.dvi, 'This is more included text.') %]
-- expect --
-- process --
PASS - found 'This is included text'
PASS - found 'This is more included text.'


# 2. include a LaTeX file and filter it
-- test --
[% INCLUDE 'testrefs.tex' FILTER latex(file.dvi)
-%]
[% grep_dvi(file.dvi, 'This is included text.') %]
[% grep_dvi(file.dvi, 'This is more included text.') %]
-- expect --
-- process --
PASS - found 'This is included text.'
PASS - found 'This is more included text.'

# 3. process a TT2 file that includes and filters a LaTeX file
-- test --
[% PROCESS 'testrefs.dvi'
-%]
[% grep_dvi(file.dvi, 'This is included text.') %]
[% grep_dvi(file.dvi, 'This is more included text.') %]
-- expect --
-- process --
PASS - found 'This is included text.'
PASS - found 'This is more included text.'



