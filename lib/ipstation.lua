local bit32 = require('bit')
local ipBinaryFilePath = "/path/to/stationdb.datx"
local indexBuffer = ''
local offset_len = 0
local areaList = {}
local _M = {
        _VERSION = '0.0.1',
}

local function byteToUint32(a,b,c,d)
	local _int = 0
        if a then
                _int = _int +  bit32.lshift(a, 24)
        end
        _int = _int + bit32.lshift(b, 16)
        _int = _int + bit32.lshift(c, 8)
        _int = _int + d
        if _int >= 0 then
        	return _int
    	else
        	return _int + math.pow(2, 32)
    end
end

local function loadAreaListX()
	local file = io.open(ipBinaryFilePath)
	local str = file:read(4)
	offset_len = byteToUint32(string.byte(str, 1), string.byte(str, 2),string.byte(str, 3),string.byte(str, 4))
	indexBuffer = file:read(offset_len - 4)
	file:seek("set",4)
	local indexPrefixBuf = file:read(262144)
	local indexBuf = file:read(offset_len - 4 - 262144)
	local index_offset = -1
	local index_lenght = -1
	local index = 1
	while index < string.len(indexBuf) do
		index_offset = byteToUint32(string.byte(indexBuf, index+11) or 0,string.byte(indexBuf, index+10) or 0,string.byte(indexBuf, index+9) or 0,string.byte(indexBuf, index+8) or 0)
		index_length = string.byte(indexBuf, index + 12) or 0 
		index = index + 13
		file:seek("set",offset_len - 262144 + index_offset)
		areaList[index_offset] = file:read(index_length)
	end
end

local function IpOffsetX(ipstr)
	local ip1,ip2,ip3,ip4 = string.match(ipstr,"(%d+).(%d+).(%d+).(%d+)")
	local ip_unit32 = byteToUint32(ip1,ip2,ip3,ip4)
	local tmp_offset = (ip1 * 256 + ip2) * 4
	local start_len = byteToUint32(string.byte(indexBuffer,tmp_offset + 4),string.byte(indexBuffer, tmp_offset + 3), string.byte(indexBuffer, tmp_offset + 2), string.byte(indexBuffer, tmp_offset + 1))
	local max_comp_len = offset_len - 4 - 262144
	start = start_len * 13 + 262144 + 1
	local find_unit32 = 0
	local index_offset = -1
	local index_length = -1
	while start < max_comp_len do
		find_unit32 = byteToUint32(string.byte(indexBuffer, start), string.byte(indexBuffer, start+1),string.byte(indexBuffer, start+2),string.byte(indexBuffer, start+3))
		if find_unit32 <= ip_unit32 then
			local t  = byteToUint32(string.byte(indexBuffer, start+4), string.byte(indexBuffer, start+5),string.byte(indexBuffer, start+6),string.byte(indexBuffer, start+7))
			if t >= ip_unit32 then
				index_offset = byteToUint32(string.byte(indexBuffer, start+11),string.byte(indexBuffer, start+10),string.byte(indexBuffer, start+9),string.byte(indexBuffer, start+8))
				index_length = string.byte(indexBuffer, start + 12)
				break
			end
		else
			break
		end
		start = start + 13
	end

	if index_offset == -1 and index_length == -1 then
		return nil
	end
	return index_offset
end

function _M.IpLocationX(ipstr)
	return areaList[IpOffsetX(ipstr)]
end

loadAreaListX()
return _M
