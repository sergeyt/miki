fs = require 'fs'
path = require 'path'
glob = require 'glob'
marked = require 'marked'
hljs = require 'highlight.js'
jade = require 'jade'
_ = require 'underscore'
_.str = require 'underscore.string'
wikis = require './wikis'

highlight = (code, lang) ->
	if lang then hljs.highlight(lang, code).value else code

# highlighting with highlight.js
marked.setOptions
	langPrefix: 'hljs code '
	highlight: highlight

isAbsoluteUri = (uri) ->
	(/^https?:\/\//i).test uri

# custom renderer to handle link.href, image.src
class Renderer extends marked.Renderer
	constructor: (@opts) ->
	link: (href, title, text) ->
		super.link @fixhref href, title, text
	image: (href, title, text) ->
		super.image @fixhref href, title, text
	fixhref: (href) ->
		return href if isAbsoluteUri href
		slash = if _.str.endsWith href, '/' then '' else '/'
		"#{@opts.wiki.href}#{@opts.prefix}#{slash}#{href}"

makePattern = (wiki, page) ->
	dir = wiki.dir.replace /\\/g, '/'
	page = '{index,readme}' if not page
	hasExt = (/\.(md|mkd|markdown)$/i).test(page)
	suffix = if hasExt then '' else '.{md,mkd,markdown}'
	"#{dir}/#{page}#{suffix}"

# renders page template
renderTemplate = (content, cb) ->
	# todo cache template
	pageTemplate = path.join __dirname, '../views/page.jade'
	jade.renderFile pageTemplate, {content: content}, (err, html) ->
		return cb err, null if err
		cb null, html

# renders given markdown file
renderFile = (file, opts, cb) ->
	fs.readFile file, {encoding: 'utf8'}, (err, md) ->
		return cb err, null if err
		dir = path.dirname file
		opts.prefix = dir.substr opts.wiki.dir.length + 1
		opts.prefix = '/' + opts.prefix if opts.prefix
		marked md, {renderer: new Renderer(opts)}, (err, html) ->
			return cb err, null if err
			return renderTemplate html, cb if opts.wrap
			# unwrapped markdown html
			cb null, html

# resolved and renders given wiki page
renderPage = (wiki, page, opts, cb) ->
	page.substr 1 if _.str.startsWith page, '/'
	pattern = makePattern wiki, page
	glob pattern, (err, files) ->
		return cb err, null if err
		renderFile files[0], opts, cb

# wiki page handler
module.exports = (page, wrap, cb) ->
	return cb "wiki page is not specified", null if not page

	# resolve wiki
	parts = page.split '/'
	name = parts[0]
	wiki = _.find wikis(), (it) -> it.name == name
	return cb "unable to resolve wiki #{name}", null if not wiki

	# render page
	page = page.substr name.length
	renderPage wiki, page, {wrap:wrap, wiki: wiki}, (err, html) ->
		return cb err, null if err or not html
		cb null, html
