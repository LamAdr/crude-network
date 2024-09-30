# This file defines reactive functions

function onchange_data_click(country, params)

    if country in params.active
        filter!(e -> e ≠ country, params.active)
    else
        push!(params.active, country)
    end

    params.active_trace = get_active_trace(
        params.active,
        net_flow,
        params.period
    )

    onchange_show_tradelines(params)
end


function onchange_period(params)
    params.exporters_trace = get_trade_trace(
        net_flow,
        "Country",
        "Qty",
        export_cs,
        Dict("Period" => params.period, "Net_flow" => 'X'),
        nothing,
        [0, export_zmax]
    )
    params.importers_trace = get_trade_trace(
        net_flow,
        "Country",
        "Qty",
        import_cs,
        Dict("Period" => params.period, "Net_flow" => 'M'),
        nothing,
        [0, import_zmax]
    )

    onchange_show_tradelines(params)
end


function onchange_show_tradelines(params)
    traces = [params.exporters_trace, params.importers_trace, params.active_trace]

    if params.show_tradelines
        tradeline_traces = get_tradeline_traces(transactions, params.active, params.period)
        traces = vcat(tradeline_traces, traces)
    end

    traces
end
