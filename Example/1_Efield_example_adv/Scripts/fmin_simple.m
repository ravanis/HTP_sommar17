function [ bestx ] = fmin_simple( f, a, b)
x = linspace(a,b,10);
best = -100000;
bestx = 0;
for x = linspace(a,b,10)
    fx = f(x);
    if fx>best
        bestx = x;
        best = fx;
    end
end



end

