local mysql  = require "resty.mysql"
local say = ngx.say
local log = ngx.log
local ERR = ngx.ERR
local exit = ngx.exit

local _M = {
	_VERSION = '0.0.1',	
}

function _M.mysql_query(db_conf,sql)
	local db,err = mysql:new()
	if not db then
        	log(ERR,"failed to instantinate mysql:",err)
        	return nil
	end

	db:set_timeout(5000)

	local ok,err,errno,sqlstate = db:connect{
        	host = db_conf["host"],
      		port = db_conf["port"],
        	database = db_conf["dbname"],
        	user = db_conf["user"],
        	password = db_conf["passwd"],
	}

	if not ok then
		log(ERR,"failed to connect: ", err, ": ", errno, " ", sqlstate)
		exit(500)
	end

	local res,err,errno,sqlstate = db:query(sql)
	if not res then
		log(ERR,err,sql)
		exit(500)
	end
	if err == 'again' then
		log(ERR,"more result returned")
	end
	local ok, err = db:set_keepalive(60000, 100)
       	if not ok then
       		log(ERR,"failed to set keepalive: ", err)
      	end
	--[[
      	local ok, err = db:close()
	if not ok then
		log(ERR,"failed to close: ", err)
	end
	]]--
	return res
end

function _M.split(szFullString, szSeparator)
        local nFindStartIndex = 1
        local nSplitIndex = 1
        local nSplitArray = {}
        while true do
                local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
                if not nFindLastIndex then
                        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
                        break
                end
        	nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
       		nFindStartIndex = nFindLastIndex + string.len(szSeparator)
        	nSplitIndex = nSplitIndex + 1
        end
        return nSplitArray
end
return _M
