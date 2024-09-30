# This file defines the user interface (html/js)

function ui()
    mytabs = """
<div class="col-10 col-sm st-module">
    <q-tabs v-model="tab" align="justify" narrow-indicator="" class="q-mb-lg">
        <q-tab name="map" label="Map" class="text"></q-tab>
        <q-tab name="graph" label="Graph" class="text"></q-tab>
    </q-tabs>
    <q-tab-panels v-model="tab" animated="" transition-prev="scale" transition-next="scale" animated
        class="text-center">
        <q-tab-panel name="map">
            <div class="row justify-center" style="margin-top: -20px;">
    """ *
    """         <q-toggle label="Show trade lines" v-model="show_tradelines"></q-toggle>
            </div>
            <div class="row justify-center">""" *
    StipplePlotly.plot(
        :traces,
        layout=:plotlayout,
        syncevents = true,
        config=PlotlyJS.PlotConfig(
            displayModeBar=false,
            responsive=false
        ),
        class = "sync_data mb-4"
    ) *
    """
            </div>
        </q-tab-panel>
        <q-tab-panel name="graph">
            <div class="row justify-center">
            </div>
        </q-tab-panel>
    </q-tab-panels>
</div>"""
    # histograms = [StipplePlotly.plot(
    #     ht,
    #     layout=:histogram_layout,
    #     config=PlotlyJS.PlotConfig(
    #         displayModeBar=false,
    #         responsive=false
    #     )
    # ) for ht in :histogram_traces]
    # histograms = StipplePlotly.plot(
    #     :histogram_traces,
    #     layout=:histogram_layout,
    #     config=PlotlyJS.PlotConfig(
    #         displayModeBar=false,
    #         responsive=false
    #     )
    # )

    # final ui
    [
        row([
            cell(class="st-col col-3",[
                p("Period", class="row justify-center"),
                slider(2019:1:2023, :period, color="grey-5"),
                p("{{period}}", class="row justify-center"),
            ]),
            # cell(class="st-col col-3",[
            #     p("Grouping", class="row justify-center"),
            #     GenieFramework.select(
            #         :grouping,
            #         options = :list_of_groupings
            #     ),
            # ]),
        ], class="row justify-center"),
        # mytabs,
        """<div class="row justify-center" style="margin-top: -20px;">
                <q-toggle label="Show trade lines" v-model="show_tradelines"></q-toggle>
            </div>""",
        StipplePlotly.plot(
            :traces,
            layout=:plotlayout,
            syncevents = true,
            config=PlotlyJS.PlotConfig(
                displayModeBar=false,
                responsive=false
            ),
            class="row justify-center sync_data mb-4"
        ),
        # row([
        #     cell(class="st-col col-3",
        #         btn("Generate histograms", @click("generate_histograms=!generate_histograms"))
        #     )
        # ]),
        # histograms
    ]
end
