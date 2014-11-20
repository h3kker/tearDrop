# Project Structure

Generally speaking, there are two components: A server and a client. The server
takes analysis files, manipulates them and stuffs intermediate results into a
database as needed. It also provides an API to access the data, which is used
by the client to display and visualize results, and of course also to write
back corrected data (which is the whole point).

So far, so boringly straightforward! 

### Technologies

- Server: Implemented in Perl, using the [Dancer](http://perldancer.org/)
  framework and [DBIx::Class](http://www.dbix-class.org/) as ORM. Utility
  classes are implemented with [Mouse](https://metacpan.org/pod/Mouse). 

- Client: An [AngularJS](https://angularjs.org/) javascript app that runs in a web browser.

## TearDrop Server

The server part is written in Perl and controls various bioinformatics
utilities via shell scripts. For longer running tasks a work queue is provided
that is managed by a work dispatcher process. 

In case you are not familiar with Perl, but still want to snoop around in the
source code: I will refer to all the modules by the notation:
`Cat::Picture::Funny`, which means that you can find the source code for
funny cat pictures in the directory `lib/Cat/Picture/Funny.pm`.

### Work Queue

Ideally the work queue does not need to be run on the same machine as the web
service, but can be distributed, so that long running and resource intensive
tasks do not interfere with the webserver operation and the web server does not
need access to all the file systems where the (potentially huge) data rots
away.

Current task managers are derived from the common `TearDrop::Worker`
superclass. This provides the `start_working` method that spawns and daemonizes
the dispatcher and returns immediately (nice if you want to start the worker
together with the web app). It also provides access to a
`Parallel::ForkManager` instance that can be used by the dispatcher to run the
tasks (*XXX provide separate startup script*).

Current Subclasses implementing workqueues:

- TearDrop::Worker::DB submits jobs by inserting them into a database table (in
  the master database). A separate process (dispatcher) reads new entries from
  this table, runs the tasks and updates the table with the current task
  status. Of course there are some implementations of this around (like
  TheSchwartz), but for some reason I had to write this very simple and too
  naive module.

- TearDrop::Worker::Redis is an implementation of
  [Redis::JobQueue](https://metacpan.org/pod/Redis::JobQueue). 

### Cluster (SGE/PBS/...) integration

We could, of course, delegate all the work to a cluster management system like
Sun Grid Engine or PBS, since they do a good job at managing jobs themselves.

However we may:

- not want to run all tasks with the overhead of distributed computing. There
  are some tasks with intermediate runtimes (think minutes: way too long to run
  interactively if you're an impatient cat like me). Running them on the
  cluster means: Staging the source files, submitting the job to the queue,
  running, writing output data, unstage the result files and import them into
  TearDrop. Especially the staging and unstaging is a lot of overhead if you,
  say, just blast a few transcripts. It's however way too long to block
  the web server until it finishes.
- want to save money (the cluster people usually charge by CPU hours)
- not have a cluster at our hands 

So the decision was made (by me, after long discussions with me) to create a
separate workqueue that should be able to *optionally* submit tasks to a
cluster, if they run long enough. In addition it should be set up in a way that
you can configure at runtime if a task should be submitted or run directly.
**This part is not finished, well, not even started**

Well, true genius. Galaxy does it that way.

### Tasks

Tasks do the lifting. The task class describes what a job should be doing and is derived from the `TearDrop::Task` superclass. You can configure tasks with:

- task specific input parameters
- `project` [required]: the project database to use
- `post_processing` [optional]: code ref (subroutine) that is run upon completion
  in the context of the caller.

A task should be able to run synchronously (ie. the caller is very impatient
and wants to wait until it returns) or submitted to the queue (ie. the caller
has to run to the toilet like right now and please don't bother me, just run it
and I may take a look later when I've got the time). The `TearDrop::Task`
superclass defines necessary properties such as pid, status, id, etc, so you
don't need to worry about this.

To be not completely pointless, a task should be runnable and have some kind of
input and produce some results. So, it needs to implement a `run` method that
returns the results (currently in any old structure). The input is described as
attributes in the task class. Ideally these should be references to database
objects (by id) or files (by name), but can also be any arbitrary data. But
since tasks may be de/serialized to the queue, *do not put too much data in the
input*, like 100 MB of sequences.

Of course a task can directly update the database with the results and not
return them, but it'd be nice to do so anyways, or maybe let the caller deal
with this (via the `post_processing` sub).

Current Tasks:

- TearDrop::Task::BLAST
- TearDrop::Task::MAFFT 
- TearDrop::Task::Mpileup

*XXX write PODs for them*


