# This file defines reactive functions

function onchange_data_click(country, params)
    if country in params.active
        filter!(e -> e ≠ country, params.active)
    else
        push!(params.active, country)
    end

    params.active_trace = get_active_trace(
        params.active,
        netx,
        params.period
    )

    onchange_show_relations(params)
end


function onchange_period(params)
    params.netx_traces = get_netx_traces(params.period)

    onchange_show_relations(params)
end


function onchange_show_relations(params)
    traces = vcat(params.netx_traces, params.active_trace)

    if params.show_relations
        tradeline_traces = get_tradeline_traces(transactions, params.active, params.period)
        traces = vcat(tradeline_traces, traces)
    end

    traces
end
