# This file contains the functions used to construct de DataFrames

function transactions_df()
	"""
	This function mirrors the data:
		construct the data for countries thta do not report it from their partner's reports
	"""

	df = CSV.read(joinpath("data", "comtrade.csv"), DataFrame)
	centroids = CSV.read(joinpath("data", "centroids.csv"), DataFrame)

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
					primaryValue_asperI
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
	        centroids[:, [:lat, :lon, :ISO3]], on = :Exporter => :ISO3),
	    :lat => :lat_E,
	    :lon => :lon_E
	)
	transactions = rename!(
	    leftjoin(
	        transactions,
	        centroids[:, [:lat, :lon, :ISO3]], on = :Importer => :ISO3),
	    :lat => :lat_I,
	    :lon => :lon_I
	)

	transactions

end


function net_flow_df(exporters, importers)
	"""
	This fonction returns a df containing the net export of countries
	"""

	net_flow = DataFrame(
	    Period = Int[],
	    Country = String[],
	    Net_flow = Char[],
	    Qty = Float64[]
	)

	for i in 1:nrow(exporters)
	    local period = exporters[i, :Period]
	    country = exporters[i, :Exporter]
	    export_qty = exporters[i, :Total_export]
	    import_qty = importers[(importers.Importer .== country) .& (importers.Period .== period), :Total_import]
	    if length(import_qty) == 0
	        net_export = export_qty
	    else
	        net_export = export_qty - import_qty[1]
	    end
	    if net_export < 0
	        continue
	    else
	        push!(net_flow, [period, country, 'X', net_export])
	    end
	end

	for i in 1:nrow(importers)
	    local period = importers[i, :Period]
	    country = importers[i, :Importer]
	    export_qty = exporters[(exporters.Exporter .== country) .& (exporters.Period .== period), :Total_export]
	    import_qty = importers[i, :Total_import]
	    if length(export_qty) == 0
	        net_import = import_qty
	    else
	        net_import = import_qty - export_qty[1]
	    end
	    if net_import <= 0
	        continue
	    else
	        push!(net_flow, [period, country, 'M', net_import])
	    end
	end

	net_flow

end