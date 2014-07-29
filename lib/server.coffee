path = require 'path'
express = require 'express'
populateWikis = require './wikis'
pageHandler = require './pageHandler'

root = path.dirname __dirname

app = express()

# configure express
app.set 'port', process.env.PORT || 1111
app.set 'host', 'http://localhost:' + app.get('port')
app.set 'view engine', 'jade'
app.set 'views', root + '/views'

# config middleware
app.use(require('morgan')('dev', {}))
app.use(require('compression'))
app.use(require('method-override'))
app.use(require('cookie-parser'))
app.use(require('body-parser'))
# static content
app.use '/public', express.static root + '/public'

home = (req, res) ->
	res.render 'index', {wikis: populateWikis()}

# http handlers
app.get '/', home
app.get '/index.html', home

# wiki page handler
app.get /\/wiki\/.+/, (req, res) ->
	# remove prefix so need to handle it in page handler
	page = req.path.replace /\/wiki\//, ''
	pageHandler page, true, (err, html) ->
		return res.send 500, {error: err} if err
		res.send html

# wiki preview page handler
app.get /\/preview\/.+/, (req, res) ->
	# remove prefix so need to handle it in page handler
	page = req.path.replace /\/preview\//, ''
	pageHandler page, false, (err, html) ->
		return res.send 500, {error: err} if err
		res.send html

# error handler
app.use (req, res) ->
	res.send 404, 'Sorry, cant find that!'

# now run server
port = app.get 'port'
app.listen port
console.log "Listening on port #{port}"
