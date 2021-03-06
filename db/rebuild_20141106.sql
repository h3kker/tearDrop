alter table genes add name text;
update genes set name=description;
alter table genes drop flagged;
alter table transcripts add description text;
alter table transcripts drop flagged;
 alter table blast_runs add run_date timestamp default current_timestamp;
 alter table blast_results add qseq text;
 alter table blast_results add sseq text;
 alter table blast_results add qstart integer;
 alter table blast_results add qend integer;
 alter table blast_results add sstart integer;
 alter table blast_results add send integer;
 alter table blast_results add gaps integer;
alter table samples add name text unique;
update samples set name=description;
alter table samples alter name set not null;
alter table de_runs add name text unique;
update de_runs set name=description;
alter table de_runs alter name set not null;
alter table de_runs alter description drop not null;
alter table de_runs drop constraint de_runs_description_key;
