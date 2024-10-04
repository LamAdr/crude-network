# This file contains the functions used to construct the DataFrames

function transactions_df()
	"""
	This function mirrors the data:
		construct the data for countries that do not report it from their partner's reports
	"""

	df = CSV.read(joinpath("data", "comtrade.csv"), DataFrame)
	countries_info = CSV.read(joinpath("data", "countries_info.csv"), DataFrame)

	# drop aggregate rows
	df = df[df.isAggregate .== false, :]

	transactions = DataFrame(
		Period = Int[],
		Exporter = String[],
		Importer = String[],
		Qty_asperE = Float64[],
		Qty_asperI = Float64[],
		PrimaryValue_asperE = Float64[],
		PrimaryValue_asperI = Float64[]
	)

	# takes note of the row index of every (period, exporter, importer) combination inside transactions
	ii = 1
	records = Dict{Vector{String}, Int}()

	for i in 1:nrow(df)

		# get values
		period = df[i, :period]
		if df[i, :flowCode] == "M"
			exporter = df[i, :partnerISO]
			importer = df[i, :reporterISO]
			qty_asperE = 0
			qty_asperI = df[i, :qty]
			primaryValue_asperE = 0
			primaryValue_asperI = df[i, :primaryValue]
		else
			exporter = df[i, :reporterISO]
			importer = df[i, :partnerISO]
			qty_asperE = df[i, :qty]
			qty_asperI = 0
			primaryValue_asperE = df[i, :primaryValue]
			primaryValue_asperI = 0
		end

		# set values
		if haskey(records, [string(period), exporter, importer])
			# a transaction involving the same partners in the same period has already been seen
			# simply add the values
			record_i = records[[string(period), exporter, importer]]
			transactions[record_i, :Qty_asperE] += qty_asperE
			transactions[record_i, :Qty_asperI] += qty_asperI
			transactions[record_i, :PrimaryValue_asperE] += primaryValue_asperE
			transactions[record_i, :PrimaryValue_asperI] += primaryValue_asperI
		else
			# first time we see such a transaction
			push!(
				transactions,
				[
					period,
					exporter,
					importer,
					qty_asperE,
					qty_asperI,
					primaryValue_asperE,
					primaryValue_asperI,
				]
			)
			records[[string(period), exporter, importer]] = ii
			ii += 1
		end
	end

	function mean_if_non_zero(a, b)
		a == 0 && return b
		b == 0 && return a
		return (a + b) / 2
	end

	# take the mean of the two partner's reports
	transactions.Qty_mean = mean_if_non_zero.(transactions.Qty_asperE, transactions.Qty_asperI)

	# add centroids to df
	transactions = rename!(
	    leftjoin(
	        transactions,
	        countries_info[:, [:centroid_lat, :centroid_lon, :ISO3]], on = :Exporter => :ISO3),
	    :centroid_lat => :lat_E,
	    :centroid_lon => :lon_E
	)
	transactions = rename!(
	    leftjoin(
	        transactions,
	        countries_info[:, [:centroid_lat, :centroid_lon, :ISO3]], on = :Importer => :ISO3),
	    :centroid_lat => :lat_I,
	    :centroid_lon => :lon_I
	)

	transactions

end


function netx_df(transactions)
	"""
	This fonction returns a df containing the net export of countries
	"""

	# groupby exports / imports
	exporters = combine(
		groupby(transactions, [:Exporter, :Period]),
		:Qty_mean => sum => :Total_export
	)
	importers = combine(
	    groupby(transactions, [:Importer, :Period]),
	    :Qty_mean => sum => :Total_import
	)

	netx = DataFrame(
	    Period = Int[],
	    Country = String[],
	    Qty = Float64[]
	)

	for i in 1:nrow(exporters)
	    country = exporters[i, :Exporter]
	    period = exporters[i, :Period]
	    export_qty = exporters[i, :Total_export]
	    # get the imports of `country`
	    import_qty = importers[(importers.Importer .== country) .& (importers.Period .== period), :Total_import]

	    if length(import_qty) == 0
	        net_export = export_qty
	    else
	        net_export = export_qty - import_qty[1]
	    end

        push!(netx, [period, country, net_export])
	end

	# importers that have no export
	for i in 1:nrow(importers)
	    country = importers[i, :Importer]
	    if country in netx.Country
			continue
	    end
	    period = importers[i, :Period]
        push!(netx, [period, country, importers[i, :Total_import]])
	end

	# add countries not present
	countries_info = CSV.read(joinpath("data", "countries_info.csv"), DataFrame)

	from_period = minimum(netx[:, :Period])
	to_period = maximum(netx[:, :Period])
	all_countries = convert(Array, countries_info[:, :ISO3])

	for p in from_period:to_period
		countries_at_p = convert(Array, netx[netx.Period .== p, :Country])
		diff = setdiff(all_countries, countries_at_p)
		tmp_df = DataFrame(
			Period = p,
			Country = diff,
			Qty = missing
		)
		netx = vcat(netx, tmp_df)
	end

	netx

end
