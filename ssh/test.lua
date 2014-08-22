local ssh = require "ssh"
local private = require "private_conf"

ngx.req.read_body()
local args = ngx.req.get_post_args()
local host = args["host"]
local cmd = args["cmd"]
if not host or host == "" then
	ngx.log(ERR,"bad request,need\' host\' args")
	ngx.exit(400)
end

if not cmd or cmd == "" then
	ngx.log(ERR,"bad request,need\' cmd\' args")
	ngx.exit(400)
end

local session, err = ssh.new()
if not session then
	ngx.log(ERR,err)
	ngx.exit(500)
end

for k,v in pairs(private.private) do
	ssh.set_option(session,k,v)
end

ssh.set_option(session,"host",host)

ssh.connect(session)

local ok ,err = ssh.auth_autopubkey(session)
if not ok then
	ngx.log(ERR,err)
	ngx.exit(500)
end
ssh.request_exec(session,cmd,ngx.print)
ssh.close(session)
