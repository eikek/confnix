{ nginx }:

nginx.override {
  fullWebDAV = true;
  rtmp = true;
  moreheaders = false;
  ngx_lua = true;
}
