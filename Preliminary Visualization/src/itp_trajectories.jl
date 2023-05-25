using MAT, PyCall, GibbsSeaWater, Dates, ColorSchemes, StatsBase
@pyimport cartopy.crs as ccrs
@pyimport matplotlib.pyplot as plt
@pyimport cartopy.mpl.ticker as cmplt
@pyimport cartopy.mpl.gridliner as cmplg
@pyimport matplotlib.ticker as mticker

LongitudeFormatter, LatitudeFormatter = cmplt.LongitudeFormatter, cmplt.LatitudeFormatter
LONGITUDE_FORMATTER, LATITUDE_FORMATTER = cmplg.LONGITUDE_FORMATTER, cmplg.LATITUDE_FORMATTER

cd(@__DIR__)

data = matread("../../data/itp121_data.mat")

times = @. Millisecond(round(Int, data["time"] * Dates.value(Millisecond(Day(1))))) + DateTime(0,1,1)

lats = data["latitude"]

lons = data["longitude"]

proj = ccrs.Orthographic(central_longitude = mean(lons), central_latitude = mean(lats))

ax = plt.subplot(111, projection = proj)
ax.coastlines()

mappable = ax.scatter(lons, lats; c = Dates.value.(times), transform = ccrs.PlateCarree())

tick_dates = range(extrema(times)...; step = Month(3))
tick_vals = Dates.value.(tick_dates)
tick_labels = Dates.format.(tick_dates, dateformat"yyyy-mm-dd")

cbar = plt.colorbar(mappable; ticks = tick_vals)
cbar.ax.set_yticklabels(tick_labels)

label_lats = range(extrema(lats)...; length = 4)
label_lons = range(extrema(lons)...; length = 4)

gl = ax.gridlines(crs=ccrs.PlateCarree(), color="black", linewidth=1, linestyle="dotted")
gl.ylocator = mticker.FixedLocator(label_lats)
gl.xlocator = mticker.FixedLocator(label_lons)
gl.xformatter = LONGITUDE_FORMATTER
gl.yformatter = LATITUDE_FORMATTER

minlat = mean(label_lats)
minlon = mean(label_lons)

for lon in label_lons
    ax.text(lon, minlat, "$(round(lon, digits=1))ºE", transform = ccrs.PlateCarree())
end

for lat in label_lats
    ax.text(minlon, lat, "$(round(lat, digits=1))ºN", transform = ccrs.PlateCarree())
end

plt.scatter([lons[begin]],[lats[begin]]; label="Start", color="pink", transform = ccrs.PlateCarree())
plt.scatter([lons[end]],[lats[end]]; label="End", color="red", transform = ccrs.PlateCarree())
plt.legend()

plt.title("Drifter Positions as a function of time")
plt.tight_layout()

plt.savefig("../vis/drifter_path.png")

plt.close()
