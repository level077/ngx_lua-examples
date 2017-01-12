#!/usr/bin/env python
# coding: utf-8

import struct
from socket import inet_aton
import os

_unpack_V = lambda b: struct.unpack("<L", b)
_unpack_N = lambda b: struct.unpack(">L", b)
_unpack_C = lambda b: struct.unpack("B", b)

class IPSTATION:
    binary = ""
    index = 0
    offset = 0

    @staticmethod
    def load(file):
        try:
            path = os.path.abspath(file)
            with open(path, "rb") as f:
                IPSTATION.binary = f.read()
                IPSTATION.offset, = _unpack_N(IPSTATION.binary[:4])
                IPSTATION.index = IPSTATION.binary[4:IPSTATION.offset]
        except Exception as ex:
            print "cannot open file %s" % file
            print ex.message
            exit(0)

    @staticmethod
    def find(ip):
        index = IPSTATION.index
        offset = IPSTATION.offset
        binary = IPSTATION.binary
        nip = inet_aton(ip)
        ipdot = ip.split('.')
        if int(ipdot[0]) < 0 or int(ipdot[0]) > 255 or len(ipdot) != 4:
            return "N/A"

        tmp_offset = (int(ipdot[0]) * 256 + int(ipdot[1])) * 4
        start, = _unpack_V(index[tmp_offset:tmp_offset + 4])

        index_offset = index_length = -1
        max_comp_len = offset - 262144 - 4
        start = start * 13 + 262144

        while start < max_comp_len:
            if index[start:start + 4] <= nip:
		if index[start + 4:start + 8] >= nip:
                    index_offset, = _unpack_V(index[start + 8:start + 12])
                    index_length, = _unpack_C(index[start + 12])
                    break
	    else:
		    break
            start += 13

        if index_offset == -1 and index_length == -1:
            return "N/A"

        res_offset = offset + index_offset - 262144
        return binary[res_offset:res_offset + index_length].decode('utf-8')
