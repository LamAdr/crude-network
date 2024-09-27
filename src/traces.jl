# This file defines functions that generate plotly traces

function get_trade_trace(df, locations, z, colorscale, filters, active, z_min_max)

    if !isnothing(active)
        df = df[in(active).(df.Country), :]
    end

    if !isnothing(filters)
        for (key, value) in filters
            df = df[(df[:, key] .== value), :]
        end
    end

    choropleth(
        locations = df[:, locations],
        z = df[:, z],
        zmin = z_min_max[1],
        zmax = z_min_max[2],
        colorscale = colorscale,
        showscale = false,
        hoverinfo="location"
    )
end


function get_tradeline_traces(df, active, period)
    
    tradelines_df_E = df[in(active).(df.Exporter) .& (df.Period .== period), :]
    tradelines_df_I = df[in(active).(df.Importer) .& (df.Period .== period), :]

    export_tradeline_traces = [
        scattergeo(
            lon = [tradelines_df_E[i, :lon_E], tradelines_df_E[i, :lon_I]],
            lat = [tradelines_df_E[i, :lat_E], tradelines_df_E[i, :lat_I]],
            mode = "lines",
            line_width = 1,
            line_color = "red",
            showscale = false
        )
        for i in 1:nrow(tradelines_df_E)
    ]

    import_tradeline_traces = [
        scattergeo(
            lon = [tradelines_df_I[i, :lon_E], tradelines_df_I[i, :lon_I]],
            lat = [tradelines_df_I[i, :lat_E], tradelines_df_I[i, :lat_I]],
            mode = "lines",
            line_width = 1,
            line_color = "blue",
            showscale = false
        )
        for i in 1:nrow(tradelines_df_I)
    ]

    vcat(export_tradeline_traces, import_tradeline_traces)
end
