# This file defines functions that generate plotly traces

function get_netx_trace(period)

    netx_period = netx[netx.Period .== period, :]

    range = netx_zmax - netx_zmin

    choropleth(
        locations = netx_period[:, :Country],
        z = netx_period[:, :Qty],
        zmin = netx_zmin,
        zmax = netx_zmax,
        colorscale = netx_cs,
        colorbar = Dict(
            :thickness => 10,
            :title => Dict(
                :text => "net export"
            ),
            :tickmode => "array",
            :ticktext => ["Exporter", "Importer"],
            :tickvals => [netx_zmax - 0.1*range, netx_zmin + 0.1*range],
        ),
        hoverinfo="location"
    )
end


function get_active_trace(
    active,
    netx,
    period,
)

    active_df = netx[in(active).(netx.Country), :]

    choropleth(
        locations = active_df[active_df.Period .== period, "Country"],
        z = active_df[active_df.Period .== period, 1], # can be anything
        colorscale = [[0, "rgba(0,0,0,0)"], [1, "rgba(0,0,0,0)"]],
        marker =  Dict(:line => Dict(:color => "#FFFFFF", :width => 2)),
        showscale = false,
        hoverinfo="location"
    )
end

function get_tradeline_traces(
    df,
    active,
    period,
)
    relations_df_E = df[in(active).(df.Exporter) .& (df.Period .== period), :]
    relations_df_I = df[in(active).(df.Importer) .& (df.Period .== period), :]

    export_tradeline_traces = [
        scattergeo(
            lon = [relations_df_E[i, :lon_E], relations_df_E[i, :lon_I]],
            lat = [relations_df_E[i, :lat_E], relations_df_E[i, :lat_I]],
            mode = "lines",
            line_width = 1,
            line_color = "red",
            showscale = false,
            hoverinfo="skip",
        )
        for i in 1:nrow(relations_df_E)
    ]

    import_tradeline_traces = [
        scattergeo(
            lon = [relations_df_I[i, :lon_E], relations_df_I[i, :lon_I]],
            lat = [relations_df_I[i, :lat_E], relations_df_I[i, :lat_I]],
            mode = "lines",
            line_width = 1,
            line_color = "blue",
            showscale = false,
            hoverinfo="skip",
        )
        for i in 1:nrow(relations_df_I)
    ]

    vcat(export_tradeline_traces, import_tradeline_traces)
end
