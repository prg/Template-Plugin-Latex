#!/usr/bin/perl -w                                         # -*- perl -*-

use strict;

use lib qw( ./lib );
use Config;
use File::Spec::Functions qw( catfile );
use ExtUtils::MakeMaker;
use Cwd;

select STDERR;
$| = 1;
select STDOUT;

our $QUIET  = 0;
our $ACCEPT = 0;
our $WIN32  = ($^O eq 'MSWin32');
our $MODVERSION = get_module_version();

#------------------------------------------------------------------------

message(<<EOF);

Template-Plugin-Latex v$MODVERSION
------------------------------

The Template-Latex modules add LaTeX support for the Template Toolkit.

They allow you to create LaTeX documents using the full power of the
Template Toolkit.  The generated output can then be processed with
either 'pdflatex' or 'latex'.  If unresolved cross references,
bibliographic references or index definitions are found then 'bibtex'
or 'makeindex' will be run as appropriate and 'latex' or 'pdflatex'
re-run as necessary.  The output will be postprocessed with the
'dvips' and 'ps2pdf' programs if necessary to create PDF, DVI or
PostScript documents.

To use the Template-Latex module you will first need to install LaTeX on
your system and make sure the above programs are available.  

EOF

#------------------------------------------------------------------------

if (! find_program($ENV{PATH}, "latex") and ! find_program($ENV{PATH}, "pdflatex")) {
    my $continue = ttprompt('You don\'t seem to have LaTeX installed.  Continue anyway?', 'N');
    die("Aborting as LaTeX is not installed\n") unless uc($continue) =~ /^Y/;
}


#------------------------------------------------------------------------

my %opts = (
    'NAME'	       => 'Template-Plugin-Latex',
    'VERSION_FROM' => 'lib/Template/Plugin/Latex.pm',
    'PMLIBDIRS'    => [ 'lib' ], 
    'PREREQ_PM'    => { 
        'Template'      => 2.16,
	'LaTeX::Driver' => 0.07,
	'LaTeX::Encode' => 0.02,
	'LaTeX::Table'  => 0,
    },
    'dist'         => {
        'COMPRESS' => 'gzip',
        'SUFFIX'   => 'gz',
    },
    'clean'        => {
        'FILES'    => join(' ', qw( t/output/test1.pdf 
                                    t/output/test1.ps 
                                    t/output/test1.dvi
                                    t/output/test2 
                                    t/output/test2.pdf 
                                    t/output/test2.ps 
                                    t/output/test2.dvi )),
    },
);

if ($ExtUtils::MakeMaker::VERSION >= 5.43) {
    $opts{ AUTHOR   } = 'Andrew Ford <a.ford@ford-mason.co.uk>';
    $opts{ ABSTRACT } = 'Latex support for the Template Toolkit',
}

WriteMakefile(%opts);



#------------------------------------------------------------------------
# find_program($path, $prog)
#
# Find a program, $prog, by traversing the given directory path, $path.
# Returns full path if the program is found.
#
# Written by Craig Barratt, Richard Tietjen add fixes for Win32.
#
# abw changed name from studly caps findProgram() to find_program() :-)
#------------------------------------------------------------------------

sub find_program {
    my($path, $prog) = @_;

    foreach my $dir ( split($Config{path_sep}, $path) ) {
        my $file = File::Spec->catfile($dir, $prog);
        if ( !$WIN32 ) {
            return $file if ( -x $file );
        } else {
            # Windows executables end in .xxx, exe precedes .bat and .cmd
            foreach my $dx ( qw/exe bat cmd/ ) {
                return "$file.$dx" if ( -x "$file.$dx" );
            }
        }
    }
}


#------------------------------------------------------------------------
# message($text)
#
# Print message unless quiet mode.
#------------------------------------------------------------------------

sub message {
    return if $QUIET;
    print @_;
}


#------------------------------------------------------------------------
# ttprompt($message, $default)
#------------------------------------------------------------------------

sub ttprompt {
    my ($msg, $def)=@_;
    my $ISA_TTY = -t STDIN && (-t STDOUT || !(-f STDOUT || -c STDOUT)) ; # Pipe?
    my $dispdef = defined $def ? "[$def] " : " ";
    $def = defined $def ? $def : "";
    my $ans = '';
    local $|=1;
    print "$msg $dispdef" unless $QUIET;
    if ($ACCEPT || ! $ISA_TTY) {
        print "$def\n" unless $QUIET;
    }
    else {
        chomp($ans = <STDIN>);
    }
    return ($ans ne '') ? $ans : $def;
}


#------------------------------------------------------------------------
# get_module_version()
#
# Reads the module version from the Template::Plugin::Latex module file
#------------------------------------------------------------------------

sub get_module_version {
    if (open(MODULE, catfile('lib','Template','Plugin','Latex.pm'))) {
	while (<MODULE>) {
	    return $1 if /VERSION = "?(\d+\.[\d_]+)/;
	}
    }
    return "<unkown version>";
}
