define(["Backbone", "Document", "DocumentList", "underscore", "TEXT!js/index/document_list.tpl.html"], 
  function (Backbone, Document, DocumentList, _, DocumentTpl) {

  var ResultView = Backbone.View.extend({
    el: "#document",

    events: {
      'click #load_more': 'load_more',
    },

    template: _.template(DocumentTpl),

    initialize: function() {
      this.documents = new DocumentList();
      
    },

    search: function(keyword) {

    },

    load_more: function() {

    }

  });

  return ResultView;

});