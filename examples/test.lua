#!/usr/bin/lua

package.cpath = package.cpath .. ";lua-?/?.so"

local pam = require "pam"
local pam_util = require "pam_util"
local term = require "term"

local function conversation(t)
	local resp = {}

	for i,m in ipairs(t) do
		local k, v = m[1], m[2]

		if k == pam.PAM_PROMPT_ECHO_OFF then
			io.write(v)
			term.echo_off()
			resp[i] = {io.read(), 0}
			term.echo_on()
		elseif k == pam.PAM_PROMPT_ECHO_ON then
			io.write(v)
			resp[i] = {io.read(), 0}
		elseif k == pam.PAM_ERROR_MSG then
			io.write("ERROR: ")
			io.write(v)
			io.write("\n")
			resp[i] = {"", 0}
		elseif k == pam.PAM_TEXT_INFO then
			io.write(v)
			io.write("\n")
			resp[i] = {"", 0}
		else
			error("Unsupported conversation message type")
		end
	end

	return resp
end

local h, err = pam.start("system-auth", "test", {pam_util.conversation, nil})
if not h then
	print("Start error:", err)
end

local i, err = pam.set_item(h, pam.PAM_AUTHTOK, "test")
if not i then
	print("Item error:", err)
end

local a, err = pam.authenticate(h)
if not a then
	print("Authenticate error:", err)
end

local e, err = pam.endx(h, pam.PAM_SUCCESS)
if not e then
	print("End error:", err)
end
