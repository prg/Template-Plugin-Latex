#!/usr/bin/perl --  ========================================== -*-perl-*-
#
# t/13-latex_encode.t
#
# Test the Latex plugin's latex_encode filter
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


my $out = 'output';
my $dir = -d 't' ? File::Spec->catfile('t', $out) : $out;

    
my $ttcfg = {
    OUTPUT_PATH => $dir,
};

test_expect(\*DATA, $ttcfg);


__END__

# Latex_Encodeify string with no special characters
-- test --
[% USE Latex; "abc"  | latex_encode; %]
-- expect --
abc

# Latex_Encodeify string with a "&"
-- test --
[% USE Latex; "AT&T" | latex_encode; %]
-- expect --
AT\&T

# Latex_Encodeify string with a "%"
-- test --
[% USE Latex; "42%"  | latex_encode; %]
-- expect --
42\%

# Latex_Encodeify string with a "_"
-- test --
[% USE Latex; "mod_perl"  | latex_encode; %]
-- expect --
mod\_perl

# Latex_Encodeify string with a "{" and "}"
-- test --
[% USE Latex; "{..}"  | latex_encode; %]
-- expect --
\{..\}

# Latex_Encodeify string with a "\"
-- test --
[% USE Latex; "\\LaTeX"  | latex_encode; %]
-- expect --
\textbackslash LaTeX

# Latex_Encodeify string with a "#"
-- test --
[% USE Latex; "#"  | latex_encode; %]
-- expect --
\#

# Latex_Encodeify string with a "$"
-- test --
[% USE Latex; '$0.01'  | latex_encode; %]
-- expect --
\$0.01

# Latex_Encodeify a string with multiple special characters
-- test --
[% USE Latex; "\\&#_^{}\\&#_^{}"  | latex_encode; %]
-- expect --
\textbackslash\&\#\_\^{ }\{\}\textbackslash\&\#\_\^{ }\{\}

# Latex_Encodeify string with intelligent double quotes
-- test --
[% USE Latex; 'blah "double-quoted-string" blah'  | latex_encode(iquotes = 1); %]
-- expect --
blah ``double-quoted-string'' blah

# Latex_Encodeify string with intelligent single quotes
-- test --
[% USE Latex; "blah 'single-quoted-string' blah"  | latex_encode(iquotes = 1); %]
-- expect --
blah `single-quoted-string' blah

# Latex_Encodeify string with 
-- test --
[% USE Latex; 'blah \textbf{%^&*} blah'  | latex_encode(except = "\\{}"); %]
-- expect --
blah \textbf{\%\^{ }\&*} blah



