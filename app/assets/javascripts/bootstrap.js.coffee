jQuery ->
  $("a[rel=popover]").popover()
  $(".tooltip").tooltip()
  $("a[rel=tooltip]").tooltip()
  $('.selectpicker').selectpicker();
  $('.popover-with-html').popover({ html : true });
