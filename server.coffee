#!/usr/bin/env ./node_modules/.bin/coffee
path = require 'path'
fs = require 'fs'
_ = require 'lodash'

connect = require 'connect'
send = require 'send'
cheerio = require 'cheerio'
coffeeScript = require 'coffee-script'

middlewares = require './middlewares'
iss = require './public/source/is'

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
   
  .use (request, response, next) ->
      if _(['/robots.txt', '/humans.txt']).contains request.url
         return send(request, path.join './public', request.url)
                  .maxage(15 *86400 *1000)
                  .pipe(response)
      
      if request.url == '/source/vendor/less.js'
         return send(request, require.resolve 'less/dist/less-1.4.0-beta')
                  .maxage(15 *86400 *1000)
                  .pipe(response)
         
      if _(['/source/is.js', '/source/is.map']).contains request.url
         js     = path.resolve path.join './public/source', 'is.js'
         coffee = path.resolve path.join './public/source', 'is.coffee'
         return fs.stat js, (err, exists) ->
            if request.url == '/is.js'
               unless err? or not exists.isFile()
                  return send(request, js)
                           .pipe(response)
            
            return fs.readFile coffee, {encoding: 'UTF-8'}, (err, code) ->
               {js, v3SourceMap} = coffeeScript.compile code,
                  bare: true
                  sourceMap: true
                  generatedFile: 'is.js'
                  sourceRoot: '/sources/'
                  sourceFiles: ['is.coffee']
               
               content = if request.url[-4..] == '.map' then v3SourceMap else js
               headers =
                  'Content-Type': 'application/javascript'
                  'Content-Length': Buffer.byteLength content
                  'ETag': "\"#{connect.utils.md5 content}\""
                  'Cache-Control': "public, max-age=86400"
               response.writeHead 200, headers
               response.end content
            
            next()
      next()
   
  .use(connect.static path.join(__dirname, 'public'), {maxAge: 86400 *1000})
   
  .use (request, response, next) ->
      fs.readFile path.join(__dirname, 'document.html'), {encoding: 'UTF-8'}, (err, document) ->
         builder = cheerio.load document
         renderRoute request.url, builder
         response.end builder.html()

renderRoute = (path, builder) ->
   iss.configure builder
   iss.fragments['header']()

require('http').createServer(app).listen 1337
