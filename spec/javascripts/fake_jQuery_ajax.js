var FakeJQueryRequest = function(params) {
  var that = this;
  this.params = params;
  this.http_request = new FakeHttpRequest();
  this.headers = this.http_request.headers;

  this.type = this.params.type;
  this.url = this.params.url;
  this.data = this.params.data;
  this.content_type = this.params.contentType;

  this.success = function(response) {
    if(that.params.beforeSend) {
      that.params.beforeSend(that.http_request);
    }
    if(that.params.success) {
      that.params.success(response);
    };
  };
};

var FakeHttpRequest = function() {
  var that = this;
  this.headers = {};

  this.setRequestHeader = function(key, value) {
    that.headers[key] = value;
  }
};

var ActiveAjaxRequests = [];

jQuery.real_ajax = jQuery.ajax;

jQuery.ajax = function(params) {
  ActiveAjaxRequests.push(new FakeJQueryRequest(params));
};
