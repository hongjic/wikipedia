define(['Backbone', 'Document'], function(Backbone, Document) {

  var DocumentList = Backbone.Collection.extend({
      
    url: function() {
      return '/api/v1/search'
    },

    model: Document,

    

  });
});