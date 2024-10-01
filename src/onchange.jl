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

    onchange_show_tradelines(params)
end


function onchange_period(params)
    params.netx_trace = get_netx_trace(params.period)

    onchange_show_tradelines(params)
end


function onchange_show_tradelines(params)
    traces = [params.netx_trace, params.active_trace]

    if params.show_tradelines
        tradeline_traces = get_tradeline_traces(transactions, params.active, params.period)
        traces = vcat(tradeline_traces, traces)
    end

    traces
end
