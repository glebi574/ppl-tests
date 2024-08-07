fx_abs = fmath.abs_fixedpoint
to_fx = fmath.to_fixedpoint
to_int = fmath.to_int
fx_tau = fmath.tau()
ti = table.insert

ps = 2.2048fx
bl = 14fx
psi = to_int(ps // 1fx) + to_int((ps % 1fx) * 4096fx) / 4096
bli = to_int(bl)