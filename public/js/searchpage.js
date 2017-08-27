$("#search_main").click(function() {
  $("#loading").show();
  window.location = "/search?start=0&number=10&command=" + $("#keyword_main").val();
});

$(".document").click(function(e) {
  $("#loading").show();
  target = $(e.target).parents(".document")
  id = target.attr("document_id");
  keywords = target.attr("keywords");
  window.location = "/documents/" + id + "?" + keywords;
});