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

app.configure ->
	# config middleware
	app.use(express.logger({ format: 'dev' }))
	app.use(express.compress())
	app.use(express.methodOverride())
	app.use(express.cookieParser())
	app.use(express.bodyParser())
	# static content
	app.use '/public', express.static root + '/public'

# http handlers
app.get '/', (req, res) ->
	res.render 'index', {wikis: populateWikis()}

# wiki page handler
app.get /\/wiki\/.+/, (req, res, next) ->
	# remove prefix so need to handle it in page handler
	page = req.path.replace /\/wiki\//, ''
	pageHandler page, (err, html) ->
		# todo send error
		return next() if err or not html
		res.send html

# error handler
app.use (req, res) ->
	res.send 404, 'Sorry, cant find that!'

# now run server
port = app.get 'port'
app.listen port
console.log "Listening on port #{port}"
