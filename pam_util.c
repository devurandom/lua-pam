#include <stdio.h>
#include <string.h>

#include <security/pam_appl.h>

#include <lua.h>
#include <lauxlib.h>

#include "lextlib/lextlib.h"


#define PAM_UTIL_INPUT_MAX 256


extern int term_echo_off(lua_State *L);
extern int term_echo_on(lua_State *L);


int lua_pam_util_conversation(lua_State *L) {
	int messages = 1;
	int num_msg = lua_rawlen(L, messages);

	lua_createtable(L, num_msg, 0);
	int responses = lua_gettop(L);

	for (int i = 0; i < num_msg; i++) {
		lua_rawgeti(L, messages, i+1);
		int message = lua_gettop(L);

		lua_rawgeti(L, message, 1);
		int msg_style = luaX_checkinteger(L, -1, "msg[i].msg_style");

		lua_rawgeti(L, message, 2);
		const char *msg = luaX_checkstring(L, -1, "msg[i].msg");

		lua_pop(L, 3);

		lua_createtable(L, 2, 0);
		int response = lua_gettop(L);

		char input[PAM_UTIL_INPUT_MAX] = "";
		int input_len = 0;
		switch (msg_style) {
		case PAM_PROMPT_ECHO_OFF:
			fprintf(stderr, "%s", msg);

			luaX_passerr(L, term_echo_off);
			fgets(input, PAM_UTIL_INPUT_MAX, stdin);
			luaX_passerr(L, term_echo_on);

			input_len = strlen(input);
			if (input_len > 0 && input[input_len-1] == '\n') {
				input[input_len-1] = '\0';
			}

			lua_pushstring(L, input);
			lua_rawseti(L, response, 1);

			lua_pushinteger(L, 0);
			lua_rawseti(L, response, 2);

			break;
		case PAM_PROMPT_ECHO_ON:
			fprintf(stderr, "%s", msg);

			fgets(input, PAM_UTIL_INPUT_MAX, stdin);

			lua_pushstring(L, input);
			lua_rawseti(L, response, 1);

			lua_pushinteger(L, 0);
			lua_rawseti(L, response, 2);

			break;
		case PAM_ERROR_MSG:
			fprintf(stderr, "ERROR: %s\n", msg);

			lua_pushstring(L, "");
			lua_rawseti(L, response, 1);

			lua_pushinteger(L, 0);
			lua_rawseti(L, response, 2);

			break;
		case PAM_TEXT_INFO:
			fprintf(stderr, "%s\n", msg);

			lua_pushstring(L, "");
			lua_rawseti(L, response, 1);

			lua_pushinteger(L, 0);
			lua_rawseti(L, response, 2);

			break;
		default:
			return luaL_error(L, "Unsupported conversation message style");
		}

		lua_rawseti(L, responses, i+1);
	}

	return 1;
}


static const luaL_Reg lua_pam_util_lib[] = {
	{ "conversation", lua_pam_util_conversation },

	{ NULL, NULL }
};


int luaopen_pam_util(lua_State *L) {
	luaL_newlib(L, lua_pam_util_lib);

	return 1;
}
