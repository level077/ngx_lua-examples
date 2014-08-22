ssh client，连接远端机器，执行命令。

conf/private_conf.lua
---------------------
相关信息配置文件

test.lua
---------------------
ssh client代码。配置文件里虽然写了密码，但其实在代码里并没有使用密码认证。使用的是key，会自动扫描服务器上ssh目录下的key进行验证。具体细节参看：http://api.libssh.org/master/libssh_tutor_authentication.html 

usage
--------------------
curl -d "host=192.168.0.1&cmd=uptime" '127.0.0.1/ssh'，相关nginx.conf配置如下：
<pre><code>
http {
   lua_package_path '/usr/local/app/nginx/html/lib/?.lua;/usr/local/app/nginx/html/ssh/conf/?.lua;;';
   ......
   
   server {
      .......
      location /ssh {
         content_by_lua_file /usr/local/nginx/html/ssh/test.lua;
      }	
  }
}
