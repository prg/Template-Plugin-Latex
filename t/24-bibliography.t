#!/usr/bin/perl --  ========================================== -*-perl-*-
#
# t/24-bibliography.t
#
# Test the Latex plugin's ability to generate bibliographies.
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
    unlink($file);
}

sub check_file {
    my $file = shift;
    my $path = File::Spec->catfile($dir, $file);
    return -f $path ? "PASS - $file exists" : "FAIL - $file does not exist";
}



__END__

# Check generation of bibliographies
# We use the 'alpha' bibliography style as that generates citation
# references that are easily distinguishable

-- test --
[% USE Latex;
   FILTER latex(file.dvi)
-%]
\documentclass{article}
\begin{document}
\section{Introduction}
This file has a bibliography that includes the Badger book\cite{wardley-ptt-2003}.
\bibliography{bibfiles/testbib}
\bibliographystyle{alpha}
\end{document}
[% END -%]
[% grep_dvi(file.dvi, 'Badger book\\[') %]
[% grep_dvi(file.dvi, '\\[WCC03]') %]
[% grep_dvi(file.dvi, 'Andy Wardley, Darren Chamberlain, and Dave Cross') %]
-- expect --
-- process --
PASS - found 'Badger book\['
PASS - found '\[WCC03]'
PASS - found 'Andy Wardley, Darren Chamberlain, and Dave Cross'
