local _M = {
	_VERSION = "0.0.1",
	password = "xxxxx",
}
_M.private = {
      host = "192.168.0.1",
      port = 22,
      user = "root",
      --ssh_dir = ""
      --known_hosts = "/home/nobody/.ssh/known_hosts",
}

return _M
