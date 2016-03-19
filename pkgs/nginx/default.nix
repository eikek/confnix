{ nginx }:

nginx.override {
  fullWebDAV = true;
  rtmp = true;
  moreheaders = true;
  ngx_lua = true;
}
