require.config({
  baseUrl: "/",
  paths: {
    underscore: "js/underscore-1.8.3",
    Backbone: "js/backbone",
    jquery: "js/jquery.min-2.1.4",
    TEXT: "js/text-2.0.14",
    Document: "js/model/document.model",
    DocumentList: "js/model/documents.collection",
    ResultView: "js/index/result.view"
  },
  waitSeconds: 10
})

require(['ResultView'], function(ResultView) {

  var result_view = new ResultView();

  $("#search_main").click(function() {
    result_view.search($("#input_main").val());
  });

  $("#search_global").click(function() {
    result_view.search($("#input_global").val());
    $("#input_global").val("");
  });

});

