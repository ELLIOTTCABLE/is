wrapper = ($, iss) ->
   
   iss.VERSION = 1
   
   iss.configure = (builder) ->
      $ = builder
   
   iss.fragments = F = new Object
      
   F.header = ->
      $('html > body').prepend "<header id='head'></header>"
      $('#head').append "<h1 id='title'></h1>"
      $('#title').append is.name + ' is …' # TODO: make name dynamic
      
      F.navigation()
   
   F.navigation = ->
      $('#head').append "<nav id='nav'></nav>"



`
wrapper(typeof $ != 'undefined' ? $ : undefined,
       (typeof module != 'undefined' ? module : module = { exports: new Object }).exports)
;(function(){ return this }).call(null).is = module.exports
`
