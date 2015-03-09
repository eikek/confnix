{ nginx }:

nginx.override {
  fullWebDAV = true;
  ngx_lua = true;
}
