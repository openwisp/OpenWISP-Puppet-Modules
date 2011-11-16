function redirectOnSubmit(rdrArg, rdrFieldSelector){
  var goToUrl = $.url.param(rdrArg);
  if (goToUrl) {
    $(rdrFieldSelector).attr('value', goToUrl);
  } 
}

function redirectOnClick(rdrArg, rdrFieldSelector){
  var goToUrl = $.url.param(rdrArg);
  if (goToUrl) {
    var newHref = $(rdrFieldSelector).attr('href');
    newHref += '?'+rdrArg+'='+goToUrl;
    $(rdrFieldSelector).attr('href', newHref);
  } 
}

function redirectOnClick2(rdrFieldSelector){
  var url = window.location.toString();
  if (url) {
    var eUrl = url.split("?");
    var newHref = $(rdrFieldSelector).attr('href');
    newHref += '?' + eUrl[1];
    $(rdrFieldSelector).attr('href', newHref);
  } 
}
