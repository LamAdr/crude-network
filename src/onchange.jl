# This file defines reactive functions

function onchange_data_click(country, params)
    if country in params.active
        filter!(e -> e ≠ country, params.active)
    else
        push!(params.active, country)
    end

    active_df = net_flow[in(params.active).(net_flow.Country), :]
    params.active_trace = choropleth(
        locations = active_df[active_df.Period .== params.period, "Country"],
        z = active_df[active_df.Period .== params.period, 1], # can be anything
        colorscale = [[0, "rgba(0,0,0,0)"], [1, "rgba(0,0,0,0)"]],
        marker =  Dict(:line => Dict(:color => "#FFFFFF", :width => 2)),
        showscale = false,
        hoverinfo="location"
    )

    return onchange_show_tradelines(params)
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

    return onchange_show_tradelines(params)
end


function onchange_show_tradelines(params)
    if params.show_tradelines
        tradeline_traces = get_tradeline_traces(transactions, params.active, params.period)
        traces = vcat(tradeline_traces, [params.exporters_trace, params.importers_trace, params.active_trace])
    else
        traces = [params.exporters_trace, params.importers_trace, params.active_trace]
    end
    traces
end
