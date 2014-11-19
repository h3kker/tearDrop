# TearDrop - Transcriptome Expression Analysis Result Drop

Please do not use yet, it's very alpha. But when it's finished all your
transcriptome analysis problems will be solved.

## Roadmap

Make sure to read [doc/todo.md](doc/todo.md)

## Installation

Requires a sheepload of Perl modules, most prominently Dancer and DBIx::Class.
These will clone half of CPAN on your computer to satisfy their needs. That is
not enough, however, so dependencies like Mouse, Moose and Moo (don't ask)
account for the other half. I should remember to replace this with a real dependency list.

### Database Setup

**currently only tested with PostgreSQL, but DBIx::Class promises to work with anything**

1. Create teardrop database user and master database

  > psql -U postgres
  postgres=# create user teardrop createdb;
  postgres=# create database teardrop_master owner teardrop;

2. Set up master schema

Should maybe provide a script.

> > psql -U teardrop teardrop_master < db/master_schema.sql

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

... must be set up in the database now. Once it's in the table `projects`, you can do:

  > perl bin/deploy_project.pl -p [projectname]

This will create all the tables, constraints and indices.

## Startup

Start development instance:

  > perl bin/app.pl 

Point your browser to [http://localhost:3000/teardrop](http://localhost:3000/teardrop)

You might want to create a wrapper shell script to set up paths and start TearDrop using any kind of PSGI server (e.g. Starman).

## Importing Data

Currently: Create a bunch of CSV files. Maybe the term bunch needs some expanded clarification. Set up base data:

  > perl bin/import_metadata.pl -p [project] -b [basedir] 

To import all your nice big data files referenced in the tables, use option `--files`.

## What now?

Annotate away!
