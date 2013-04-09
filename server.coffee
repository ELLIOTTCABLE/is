#!/usr/bin/env ./node_modules/.bin/coffee
path = require 'path'
_ = require 'lodash'

connect = require 'connect'
send = require 'send'
cheerio = require 'cheerio'

middlewares = require './middlewares'

app = connect()
  .use(middlewares.touchIcon 'public/images')
  .use(connect.logger {immediate: true, format: 'short'})
  .use(connect.logger 'dev')
  .use(connect.responseTime())
  
 #.use connect.bodyParser()
 #.use connect.cookieParser()
 #.use connect.query()
 #.use connect.subdomains()
  .use(connect.errorHandler())
  .use(connect.methodOverride())
  
  .use(connect.compress())
  .use (i, o, next) ->
      throw "Headers already sent! Can't set X-UA-Compatible." if o.headersSent
      o.setHeader 'X-UA-Compatible', "IE=edge,chrome=1"
      next()
   
  .use(connect.static path.join(__dirname, 'public'), {maxAge: 86400 *1000})
  .use (i, o, next) ->
      if i.url == '/public/less.js'
         return send(i, require.resolve 'less/dist/less-1.4.0-beta')
                  .maxage(15 *86400 *1000)
                  .pipe(o)
         
      if i.url == '/is.js'
         return send(i, './is.js')
                  .pipe(o)
      
      next()

require('http').createServer(app).listen 1337
