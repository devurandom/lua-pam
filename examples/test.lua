#!/usr/bin/lua

package.cpath = package.cpath .. ";lua-?/?.so"

local pam = require "pam"
local term = require "term"

local function conversation(messages)
	local responses = {}

	for i, message in ipairs(messages) do
		local msg_style, msg = message[1], message[2]

		if msg_style == pam.PROMPT_ECHO_OFF then
			-- Assume PAM asks us for the password
			io.write(msg)
			term.echo_off()
			responses[i] = {io.read(), 0}
			term.echo_on()
		elseif msg_style == pam.PROMPT_ECHO_ON then
			-- Assume PAM asks us for the username
			io.write(msg)
			responses[i] = {io.read(), 0}
		elseif msg_style == pam.ERROR_MSG then
			io.write("ERROR: ")
			io.write(msg)
			io.write("\n")
			responses[i] = {"", 0}
		elseif msg_style == pam.TEXT_INFO then
			io.write(msg)
			io.write("\n")
			responses[i] = {"", 0}
		else
			error("Unsupported conversation message style: " .. msg_style)
		end
	end

	return responses
end

local h, err = pam.start("system-auth", nil, {conversation, nil})
if not h then
	print("Start error:", err)
end

local a, err = pam.authenticate(h)
if not a then
	print("Authenticate error:", err)
end

local e, err = pam.endx(h, pam.SUCCESS)
if not e then
	print("End error:", err)
end
