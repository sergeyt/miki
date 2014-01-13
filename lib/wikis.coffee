fs = require 'fs'
path = require 'path'
iswin = require 'iswin'

hrefPrefix = '/wiki/'

# todo configure root dir
# todo config file with any wiki dirs
homeDir = ->
	if iswin() then process.env.USERPROFILE else process.env.HOME

# populates list of available wikis
module.exports = ->
	root = path.join homeDir(), 'wikis'
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
