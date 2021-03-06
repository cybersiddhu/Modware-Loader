# NAME

Modware::Loader

# VERSION

version v1.6.1

# DESCRIPTION

[Chado](http://gmod.org/wiki/Introduction\_to\_Chado) is an open-source modular database
schema for biological data. This distribution provides [MooseX::App::Cmd](http://search.cpan.org/perldoc?MooseX::App::Cmd) based command
line applications to import and export biological data from Chado database.

# NAME

Modware::Loader -  Command line apps for Chado relational database 

# INSTALLATION

You need to install 2/3 dependencies from __github__, rest of them would be pulled from __CPAN__ as needed.
Install using __cpanm__ is highly recommended.
Use a latest version of [cpanm](https://metacpan.org/module/cpanm), at least 1.6 is needed.

## Latest release 

        cpanm -n  git://github.com/dictyBase/Modware-Loader.git

If you install without (-n/notest flag) then install __Test::Chado__ before you install __BioPortal-Webservice__.

        cpanm git://github.com/dictyBase/Test-Chado.git

## Any particular release

Download the respective tarballs from their release pages in github and invoke __cpanm__ on them locally.

- BioPortal-WebService [release page](https://github.com/dictyBase/BioPortal-WebService/releases)
- Test-Chado [release page](https://github.com/dictyBase/Test-Chado/releases)
- Modware-Loader [release pages](https://github.com/dictyBase/Modware:Loader/releases)

### Using Build.PL,  cpan and friends

Just follow the instuctions in the __INSTALL__ file.

# Build Status

<a href='https://travis-ci.org/dictyBase/Modware-Loader'>
  	<img src='https://travis-ci.org/dictyBase/Modware-Loader.png?branch=develop' alt='Travis CI status'/>
</a>

<a href='https://coveralls.io/r/dictyBase/Modware-Loader'>
	<img src='https://coveralls.io/repos/dictyBase/Modware-Loader/badge.png?branch=develop' alt='Coverage Status' />
</a>

# Documentation

Run any one of the following command

- modware-export
- modware-load
- modware-transform
- modware-update

Then follow the instructions to run any of the subcommand. Invoking the subcommand will display further help which is more or less self-explanatory.

## Quick example

Run one of the command

      $_> modware-load 

        Available commands:

            commands: list the application's commands
                help: display a command's help screen

           adhocobo2chado:  Load an adhoc ontology in chado database 
                obo2chado:  Load ontology from obo flat file to chado database
         oboclosure2chado:  Populate cvtermpath in chado database
       bioportalobo2chado:  Load ontology from NCBO bioportal to chado database
           dictygaf2chado:  Load GO annotations from GAF file to chado database
        dropontofromchado:  Drop ontology from chado database (use sparingly)
                 gb2chado:  Populate oracle chado database from genbank file
         gbassembly2chado:  Load genome assembly from genbank to oracle chado database

Run one subcommand

      $_> modware-load obo2chado

        modware-load obo2chado [-?chilpu] [long options...]
           -i --input             Name of the obo file
           --dry_run              Dry run do not save anything in database
           -h -? --usage --help   Prints this usage information.
           --pg_schema            Name of postgresql schema where the ontology
                                  will be loaded, default is public, obviously
                                  ignored for other backend
           --sqllib               Path to sql library in INI format, by default
                                  picked up from the shared lib folder. Mostly a
                                  developer option.
           --attr --attribute     Additional database attribute
           --pass -p --password   database password

Execute the subcommand

      $_> modware-load obo2chado --dsn 'dbi:Pg:database=mychado'  -u tucker -p tucker -i go.obo

__Done.__

## Tutorials/Blog posts

- [Exporting annotations](http://dictybase.github.io/blog/2013/03/06/exporting-discoideum-annotations/)
- [Converting tblastn alignments to GFF3 format](http://dictybase.github.io/refining-tblastn-protein-alignments/index.html)
- [Design pattern of chado loader](http://dictybase.github.io/blog/2013/09/18/chado-loader-design)

# AUTHOR

Siddhartha Basu <biosidd@gmail.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Siddhartha Basu.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
