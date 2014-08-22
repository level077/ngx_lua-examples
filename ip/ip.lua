local ipdat = require "ipdat"
local util = require "util"
local ip_map = require "ip_map"
local cjson = require "cjson"
local args = ngx.req.get_uri_args()
local ip = args["ip"]
if not ip or ip == "" then
	ngx.exit(400)
end

local ip_cache = ngx.shared.ip_cache
local value,err = ip_cache:get(ip)
if value then
	ngx.say(value)
	ngx.exit(200)	
end

local info=(util.split(ipdat.IpLocation(ip),"\t"))
local code = ip_map.map[info[3]] or ip_map.map[info[2]] or -1
local value = cjson.encode({code=code,country=info[1],province=info[2],city=info[3]})

local succ,err,force = ip_cache:set(ip,value,43200)
if not succ then
	ngx.log(ERR,err)
end

ngx.say(value)

