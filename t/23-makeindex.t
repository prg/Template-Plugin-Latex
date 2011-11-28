#!/usr/bin/perl --  ========================================== -*-perl-*-
#
# t/23-makeindex.t
#
# Test the Latex plugin's ability to generate output files.
#
# Written by Andy Wardley <abw@wardley.org>
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

# Check index file generation
-- test --
[% USE Latex;
   FILTER latex(file.dvi)
-%]
\documentclass{article}
\usepackage{makeidx}
\makeindex
\begin{document}
\tableofcontents
\section{Introduction}
Concept
\index{xyzzy}
\printindex
\end{document}
[% END -%]
[% grep_dvi(file.dvi, 'xyzzy, 1') %]
-- expect --
-- process --
PASS - found 'xyzzy, 1'

