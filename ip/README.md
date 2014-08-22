ip解析模块，基于17mon的ip库,ip库请到http://tool.17mon.cn/ipdb.html下载

conf/ip_map.lua
-----------------
基于地点的ip映射表，只做了国内城市的映射。这些属于个人随手编辑。

ip.lua
----------------
调用lib/ip_dat模块的ip解析代码。返回是json串，如{"city":"","country":"GOOGLE","code":-1,"province":"GOOGLE"}。目前只做了国内城市的映射，因此国外的ip，code返回均为-1。同时利用ngx.shared.dict做缓存，大大提高了处理能力。缓存过期时间 12小时。

usage
---------------
请求方式为：curl '127.0.0.1/ip?ip=1.1.1.1',nginx.conf相关配置如下：
<pre><code>
http {
   lua_package_path '/usr/local/app/nginx/html/lib/?.lua;/usr/local/app/nginx/html/ip/conf/?.lua;;';
   ......
   server {
       ......
       location /ip {
           content_by_lua_file /usr/local/app/nginx/html/sa/ip/ip.lua;
       }	
   }
}
