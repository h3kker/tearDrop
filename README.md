# TearDrop - Transcriptome Expression Analysis Result Drop

Please do not use yet, it's very alpha. But when it's finished all your
transcriptome analysis problems will be solved.

## Roadmap

[doc/todo.md](doc/todo.md) contains the master plan. In case you're interested
in helping out, there's also [doc/treasure_map.md](doc/treasure_map.md) to show
you around the code and provide weak rationalizations for why I did stuff they
way I did it.

## Installation

Requires a sheepload of Perl modules, most prominently Mojolicious and DBIx::Class.
The latter will install half of CPAN on your computer to satisfy their needs. That is
not enough, however, so dependencies like Mouse, Moose and Moo (don't ask)
account for the other half. I should remember to replace this with a real
dependency list and possibly also fill some of the nice files that help to
automagically install everything.

Whatever you think you're doing, consider using
[PerlBrew](http://perlbrew.pl/). You can install your favorite current Perl
version and all modules without admin rights or interfering with the system
perl.

After that, you can install the necessary modules like this:

    > perlbrew use stable
    > perlbrew install-cpanm # in case you haven't done so already
    > cpanm -i Mojolicious DBIx::Class

If you don't like PerlBrew, skip steps 1 and 2 (I would still recommend using [cpanm](http://search.cpan.org/~miyagawa/App-cpanminus-1.7016/lib/App/cpanminus.pm))


### Database Setup

**currently only tested with PostgreSQL, but DBIx::Class promises to work with anything**

1. Create teardrop database user and master database

     > psql -U postgres
     postgres=# create user teardrop createdb;
     postgres=# create database teardrop_master owner teardrop;

2. Set up master schema

Should maybe provide a script.

    > psql -U teardrop teardrop_master < db/master_schema.sql

### Configuration

Create skeleton config

Edit `config.yml` in the base directory. At the very least it needs to have the configuration for the master database

    plugins:
      DBIC:
       default:
         dsn: dbi:Pg:dbname=teardrop_master;host=gecko
         schema_class: TearDrop::Master::Model
         user: teardrop
         options:
           RaiseError: 1
           PrintError: 1
           auto_savepoint: 1

Project databases will be configured on the fly from a table in the master schema.

### Your First Project

There is a command line script to help you get started with new projects. Try

    > perl bin/deploy_project.pl --help_deploy

to get a short usage message. To set up a new project, do this:

    > perl bin/deploy_project.pl --create --project [shortname] --title "[display name]" -g [group]

This sets up a new project database and creates the structure and lookup tables as copies from
the master schema. 

Ignore the `group` value for now, it must be set, but is not used. 

## Startup

Start development instance:

    > morbo -v scripts/tear_drop

Point your browser to [http://localhost:3000/teardrop](http://localhost:3000/teardrop)

You might want to create a wrapper shell script to set up paths and start
TearDrop using Hypnotoad or any PSGI server (e.g. Starman). Refer to the
[Mojolicious Cookbook](http://mojolicio.us/perldoc/Mojolicious/Guides/Cookbook#DEPLOYMENT)
for details.

## Importing Data

Please have a look at [doc/importing data.md](doc/importing_data.md).

## What now?

Annotate away!
