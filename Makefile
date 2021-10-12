package:
	shards build --production --release --without-development
	zip -q -X -r elastic.alfredworkflow icon.png bin/alfred-workflow info.plist logos
