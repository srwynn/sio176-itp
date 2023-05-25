using MAT, GibbsSeaWater, Dates

cd(@__DIR__)

datafile = "itp121_data.mat"

data = matread(datafile)

pressure = data["pres"]

depth = -1 .* gsw_z_from_p.(pressure, data["latitude"], 0, 0)

abs_sal = gsw_sa_from_sp.(data["salinity"], pressure, data["longitude"], data["latitude"])

cons_temp = gsw_ct_from_t.(abs_sal, data["temperature"], pressure)

pot_dens_anom = gsw_sigma0.(abs_sal, cons_temp)

matwrite("derived_variables.mat", Dict("abs_sal"=>abs_sal, "cons_temp"=>cons_temp, "pot_dens_anom"=>pot_dens_anom, "depth"=>depth))