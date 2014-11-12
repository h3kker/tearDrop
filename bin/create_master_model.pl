
dbicdump -o dump_directory=./lib \
	-o components='["InflateColumn::DateTime", "Helper::Row::ToJSON", "InflateColumn::Serializer"]'  \
	TearDrop::Master::Model 'dbi:Pg:database=teardrop_master;host=jenkins' teardrop
