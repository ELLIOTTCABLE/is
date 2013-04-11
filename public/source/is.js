~function(jQuery){ var $, F

if (typeof module == 'undefined')
           module = { exports: new Object }
;(function(){ return this }).call(null).is = module.exports

is.VERSION = 1

                                  $ = jQuery
is.configure = function(builder){ $ = builder }

is.fragments = F = new Object
   
F.header = function(){
   $('html > body').prepend("<header id='head'></header>")
   $('#head').append("<h1 id='title'></h1>")
   $('#title').append(is.name + ' is …') // TODO: make name dynamic
   
   F.navigation() }

F.navigation = function(){
   $('#head').append("<nav id='nav'></nav>")
   
}
   
}(typeof $ != 'undefined' ? $ : undefined)
