fs = require 'fs'
p = require 'path'

connect = require 'connect'

exports.touchIcon = (dir, o = {}) ->
   options =
      dir: dir ? p.resolve 'public'
      maxAge: o.maxAge ? 86400000
   icons = []
   
   (request, response, next) ->
      match = request.url.match /\/apple-touch-icon(-\d+x\d+)?(-precomposed)?\.png/
      if match
         [_, dimensions, precomposed] = match
         
         if icon = icons[dimensions]
            response.writeHead 200, icon.headers
            response.end icon.body
            return
         
         resolveIcon options.dir, dimensions, precomposed, (err, path) ->
            return next err if err
            fs.readFile path, (err, buffer) ->
               return next err if err
               icons[dimensions] = icon =
                  headers:
                     'Content-Type': 'image/png'
                     'Content-Length': buffer.length
                     'ETag': "\"#{connect.utils.md5 buffer}\""
                     'Cache-Control': "public, max-age=#{options.maxAge / 1000}"
                  body: buffer
               response.writeHead 200, icon.headers
               response.end icon.body
      
      else next()

resolveIcon = (dir, dimensions, precomposed, cb, previous_err) ->
   path = p.join dir, "apple-touch-icon#{dimensions ?''}#{precomposed ?''}.png"
   
   fs.stat path, (err, s) ->
      err = new Error "EEXIST, '#{path}' is not a file" unless err or s.isFile()
      if err
         return resolveIcon dir, '', precomposed, cb, previous_err ? err if dimensions
         return resolveIcon dir, '', '', cb, previous_err ? err if precomposed
         return cb previous_err ? err
      
      return cb err, path
