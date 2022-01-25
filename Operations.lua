local Operations = {}


function Operations.neg(value)
    return -value
end


function Operations.add(x, y)
    return x + y
end


function Operations.sub(x, y)
    return x - y
end


function Operations.mul(x, y)
    return x * y
end


function Operations.div(x, y)
    return x / y
end


function Operations.pow(x, y)
    return x ^ y
end


return Operations
