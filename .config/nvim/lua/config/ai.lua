-- vim.api.nvim_create_augroup("ImageViewer", { clear = true })
-- vim.api.nvim_create_autocmd("BufReadPost", {
--   pattern = { "*.png", "*.jpg", "*.jpeg", "*.webp", "*.gif" ,"*.ico"},
--   callback = function()
--     vim.cmd("silent !feh " .. vim.fn.expand("%"))
--     vim.cmd("bwipeout")
--   end,
--   group = "ImageViewer",
-- })
--
--

local function generate_uuid()
	local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
	return string.gsub(template, "[xy]", function(c)
		local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)
		return string.format("%x", v)
	end)
end

local curl = require("plenary.curl")
local ai_Plugin = {}
ai_Plugin.histroy = {}
---@param prompt string ai prompt
---@param code_insert function ai prompt
ai_Plugin.ai_fetch = function(prompt, code_insert)
	local messages = ai_Plugin.histroy
	table.insert(messages, {
		role = "user",
		content = prompt,
	})
	---@type table
	local body = {
		messages = messages,
		codeModelMode = true,
		agentMode = {},
		trendingAgentMode = {},
		isMicMode = false,
		maxTokens = 1024,
		playgroundTopP = 0.9,
		playgroundTemperature = 0.5,
		validated = generate_uuid(),
	}
	---@type table
	local headers = {
		["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64; rv:132.0) Gecko/20100101 Firefox/132.0",
		["Accept-Language"] = "en-US,en;q=0.5",
		["Accept"] = "*/*",
		["Accept-Encoding"] = "",
		["Content-Type"] = "application/json",
		["Referer"] = "https://www.blackbox.ai",
		["Sec-Fetch-Dest"] = "empty",
		["Sec-Fetch-Mode"] = "cors",
		["Sec-Fetch-Site"] = "same-origin",
		["Referrer-Policy"] = "strict-origin-when-cross-origin",
		["Priority"] = "u=0",
		["Pragma"] = "no-cache",
		["Cache-Control"] = "no-cache",
	}
	---@type string
	local json_body = vim.json.encode(body)
	local job_active = curl.post("https://api.blackbox.ai/api/chat", {
		headers = headers,
		body = json_body,
		stream = function(err, data, _)
			if err then
				print("Error")
				return
			end
			if not data then
				error("Error no reqsponse from api_call")
			end
		end,
		callback = function(result)
			print(vim.json.encode(result))
			-- 	if not (result.status == 200) then
			-- 		error("Error code: " .. result.status .. ",\nFailed to fetch ai reqsponse")
			-- 	end
			-- 	vim.schedule(function()
			-- 		code_insert(result.body)
			-- 	end)
			-- end,
			-- on_error = function(error)
			-- 	error("Error while fetching ai response: " .. vim.inspect(error))
		end,
	})
	return job_active
end

ai_Plugin.get_code_completion = function()
	---@type string
	local filetype = vim.fn.expand("%:e")
	---@type string
	local codes = vim.inspect(vim.fn.getline(1, "$"))
	---@type string
	local prompts = vim.fn.getline(".")
	ai_Plugin.histroy = {
		{
			role = "user",
			content = [[
        hello this is a system prompt, your a bot to make all users doubt clear about code 
        your must provide 1 code (with ```)
        the comment in the code ehich also given to u as a prompt is the line of the code from which u r response gonna be appended so response acording to if possible
        if u cant just do what ever the uset said but every time respond with a code block even if it empty
        dont add code after ``` like : ```lua ``` or ```cpp ``` just use ``` ```
        ]],
		},
		{ role = "assistance", content = "Ok" },
		{ role = "user", content = "fileExtension:" .. filetype .. "\nmyCode:" .. codes },
		{ role = "assistance", content = "Ok" },
	}

	local code_insert = function(ai_response)
		local row = vim.api.nvim_win_get_cursor(0)[1]
		print(ai_response)
		print(ai_response:gsub("```.-```", ""))
		local ai_writen_code = ai_response:match("```(.-)```")
		local responses = vim.split(ai_writen_code, "\n")
		vim.api.nvim_buf_set_lines(0, row, row, false, responses)
	end
	local job_active = ai_Plugin.ai_fetch(prompts, code_insert)
end
vim.api.nvim_create_user_command("Ai", function()
	ai_Plugin.get_code_completion()
end, {})
-- hello
