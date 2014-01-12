path = require 'path'
express = require 'express'

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

# handlers
app.get '/', (req, res) ->
	res.render 'index', {wikis: [{name: 'test', href: '/wiki/test'}] }

# wiki page handler
app.get /\/wiki\/.+/, (req, res) ->

# now run server
port = app.get 'port'
app.listen port
console.log "Listening on port #{port}"
