
dbicdump -o dump_directory=./lib \
	-o components='["InflateColumn::DateTime", "Helper::Row::ToJSON"]'  \
	TearDrop::Model 'dbi:Pg:database=teardrop;host=jenkins' teardrop
