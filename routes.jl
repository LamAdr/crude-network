module App
using GenieFramework, PlotlyBase, StipplePlotly, CSV, DataFrames, PlotlyJS
@genietools

include(joinpath("src", "traces.jl"))
include(joinpath("src", "onchange.jl"))
include(joinpath("src", "init.jl"))
include(joinpath("src", "ui.jl"))

@app begin

    @in data_click = Dict{String, Any}()
    @in active = []
    @in period = 2023
    @in show_relations = false
    # @in grouping = "None"
    # @in generate_histograms = false

    @out traces = traces
    @out plotlayout = PlotlyBase.Layout(
        showlegend=false,
        margin = Dict(
            :autoexpand => false,
            :b => 0,
            :l => 0,
            :t => 0,
            :r => 0,
            :pad => 0
        ),
        width = 800,
        height = 400,
    )
    # @out list_of_groupings = ["None", "All", "Selected", "Continents" , "Graph"]
    # @out histogram_traces = []
    # @out histogram_layout = PlotlyBase.Layout(
    #     width = 500,
    #     height = 300
    # )
    # @out tab = "map"

    @mixin traces::PlotlyEvents

    @onchange data_click begin
        if haskey(data_click, "points") && haskey(data_click["points"][1], "location")
            traces = onchange_data_click(data_click["points"][1]["location"], params)
        end
    end

    @onchange period begin
        params.period = period
        traces = onchange_period(params)
    end

    @onchange show_relations begin
        params.show_relations = show_relations
        traces = onchange_show_relations(params)
    end

    # @onchange grouping begin
    # end

    # @onchange generate_histograms begin
    #     histogram_traces = [
    #         scatter(; x=1:4, y=[0, 2, 3, 5], fill="tozeroy"),
    #         scatter(; x=1:4, y=[3, 5, 1, 7], fill="tonexty")
    #     ]
    # end

end

@mounted watchplots()

route("/") do
    global model
    model = @init
    page(model, ui()) |> html
end

Server.isrunning() || Server.up()
end
