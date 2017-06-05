function q = M_1(P, tumor)

power_in_h_t = Yggdrasil.Math.integral(P)/1e9;
power_in_tumor = Yggdrasil.Math.scalar_prod_integral(P, tumor)/1e9;
q = power_in_h_t/power_in_tumor;

end