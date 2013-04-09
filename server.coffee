#!/usr/bin/env ./node_modules/.bin/coffee
path = require 'path'
fs = require 'fs'
_ = require 'lodash'

connect = require 'connect'
send = require 'send'
cheerio = require 'cheerio'

middlewares = require './middlewares'
iss = require './is'

app = connect()
  .use(middlewares.touchIcon 'public/images')
  .use(connect.favicon())
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
  .use (request, response, next) ->
      throw "Headers already sent! Can't set X-UA-Compatible." if response.headersSent
      response.setHeader 'X-UA-Compatible', "IE=edge,chrome=1"
      next()
   
  .use(connect.static path.join(__dirname, 'public'), {maxAge: 86400 *1000})
  .use (request, response, next) ->
      if request.url == '/public/less.js'
         return send(request, require.resolve 'less/dist/less-1.4.0-beta')
                  .maxage(15 *86400 *1000)
                  .pipe(response)
         
      if request.url == '/is.js'
         return send(request, './is.js')
                  .pipe(response)
      
      next()
   
  .use (request, response, next) ->
      fs.readFile path.join(__dirname, 'document.html'), {encoding: 'UTF-8'}, (err, document) ->
         builder = cheerio.load document
         renderRoute request.url, builder
         response.end builder.html()

renderRoute = (path, builder) ->
   iss.configure builder
   iss.fragments['header']()

require('http').createServer(app).listen 1337
