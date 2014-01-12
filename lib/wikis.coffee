fs = require 'fs'
path = require 'path'

hrefPrefix = '/wiki/'

# todo configure root dir
# todo config file with any wiki dirs
# todo windows support
root = '/home/tsv/wikis'

# populates list of available wikis
module.exports = ->
	files = fs.readdirSync root
	files
		.filter (name) ->
				dir = path.join root, name
				fs.lstatSync(dir).isDirectory()
		.map (name) ->
			dir = path.join root, name
			wiki =
				name: name
				dir: dir
				href: hrefPrefix + name
			wiki
