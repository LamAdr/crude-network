# This file initializes the dataframes and parameters

### dataframes ###
include("df.jl")

transactions = transactions_df()

exporters = combine(
    groupby(transactions, [:Exporter, :Period]),
    :Qty_mean => sum => :Total_export
)
importers = combine(
    groupby(transactions, [:Importer, :Period]),
    :Qty_mean => sum => :Total_import
)

net_flow = net_flow_df(exporters, importers)

### params ###
period = 2023
show_tradelines = false
export_zmax = maximum(exporters[:, "Total_export"])
import_zmax = maximum(importers[:, "Total_import"])
export_cs = [[0, "#FFE9E9"], [1, "#FE9797"]]
import_cs = [[0, "#E9EAFF"], [1, "#767FFF"]]

### traces ###
exporters_trace = get_trade_trace(
    net_flow,
    "Country",
    "Qty",
    export_cs,
    Dict("Period" => period, "Net_flow" => 'X'),
    nothing,
    [0, export_zmax]
)
importers_trace = get_trade_trace(
    net_flow,
    "Country",
    "Qty",
    import_cs,
    Dict("Period" => period, "Net_flow" => 'M'),
    nothing,
    [0, import_zmax]
)

active = []
active_trace = get_active_trace(
    active,
    net_flow,
    period
)

### more params ###
mutable struct CrudeTrade_params
    active::Array{String}
    period::Int
    show_tradelines::Bool
    active_trace::Any
    exporters_trace::Any
    importers_trace::Any
end

params = CrudeTrade_params(
    active,
    period,
    show_tradelines,
    active_trace,
    exporters_trace,
    importers_trace,
)

traces = [exporters_trace, importers_trace]
