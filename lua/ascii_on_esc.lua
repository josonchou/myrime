local function ascii_on_esc(key, env)
	if key:repr() == "Escape" then
		local context = env.engine.context

		-- 1. 清除当前输入（相当于取消 composing）
		if context:is_composing() then
			context:clear()
		end

		-- 2. 强制切换到英文模式
		context:set_option("ascii_mode", true)

		-- 3. 继续将 Esc 发送给应用程序（返回 2）
		return 2
		-- env.engine.context:set_option("ascii_mode", true)
		-- return 1  -- 拦截 Esc，不传递给应用
	end
end

return ascii_on_esc
