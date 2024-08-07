tau = 6.283185307
tau_fx = 6.1160fx
__s = 1e-6
__b = 1e+6

function abs(a)
	return a < 0 and -a or a
end

function floor(a)
	return a // 1
end
	
function ceil(a)
	return (a + 1) // 1
end
	
function round(a)
	return (a + 0.5) // 1
end

function to_fx(a)
	return fmath.to_fixedpoint(floor(a)) + fmath.to_fixedpoint(floor(4096 * (a % 1))) / 4096fx
end

function to_int(a)
	return fmath.to_int(a * 4096fx) / 4096
end