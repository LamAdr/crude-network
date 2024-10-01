# This file initializes the dataframes and parameters

### dataframes ###
include("df.jl")

transactions = transactions_df()

netx = netx_df(transactions)

### params ###
period = 2023
show_relations = false
netx_zmax = maximum(netx[:, "Qty"])
netx_zmin = minimum(netx[:, "Qty"])

zero = -netx_zmin / (netx_zmax - netx_zmin)
netx_cs = [[0, "rgb(0, 0, 255)"], [zero, "rgb(255, 255, 255)"], [1, "rgb(255, 0, 0)"]]

### traces ###
netx_trace = get_netx_trace(period)

active = []
active_trace = get_active_trace(
    active,
    netx,
    period
)

### more params ###
mutable struct CrudeTrade_params
    active::Array{String}
    period::Int
    show_relations::Bool
    active_trace::Any
    netx_trace::Any
end

params = CrudeTrade_params(
    active,
    period,
    show_relations,
    active_trace,
    netx_trace,
)

traces = [netx_trace]
