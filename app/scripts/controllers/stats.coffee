'use strict'

angular.module('valleyOfBonesFrontendApp')
  .controller 'StatsCtrl', ($scope, $resource) ->

    gamePieChart = new PieChart('#versionPieChart')
    mapPieChart = new PieChart('#mapPieChart', 'PER MAP')
    winPctPieChart = new PieChart('#winPctPieChart', 'WINNER')

    totalUnitsPieChart = new PieChart('#totalUnitsPieChart', 'TOTAL', 'units built')
    unitsP1PieChart = new PieChart('#unitsP1PieChart', 'P1', 'units built')
    unitsP2PieChart = new PieChart('#unitsP2PieChart', 'P2', 'units built')
    unitsWinnerPieChart = new PieChart('#unitsWinnerPieChart', 'WINNER', 'units built')
    unitsLoserPieChart = new PieChart('#unitsLoserPieChart', 'LOSER', 'units built')

    data = $resource('http://secure-caverns-9874.herokuapp.com/game').query () ->
      for game in data
        if !isNaN(parseFloat(game.version)) and isFinite(game.version)
          game.version = "0.0.#{game.version}"
        game.game = JSON.parse(game.game.replace(',]', ']'))
        game.game.map or= "valley.json" # default map before 0.1.8


      # remove short games (< 10 turns)

      data = data.map( (game) ->
        if game.game.history.length >= 10 then game else null
      )

      data = (game for game in data when game?)

      $scope.versions = []
      $scope.maps = []
      for game in data
        $scope.versions.push game.version if not (game.version in $scope.versions)
        $scope.maps.push game.game.map if not (game.game.map in $scope.maps)

      $scope.update()

    filter = (game) ->
      return false if $scope.filterVersion? and game.version isnt $scope.filterVersion
      return false if $scope.filterMap? and game.game.map isnt $scope.filterMap
      true

    $scope.update = () ->
      games_per_version = {}

      console.log data.length
      filteredData = (game for game in data when filter(game))
      console.log filteredData.length

      for game in filteredData
        games_per_version[game.version] or= 0
        games_per_version[game.version]++

      gameData = ({"label": version, "value": value} for version, value of games_per_version)

      gamePieChart.update(gameData)

      total_games = 0
      total_games += val for key, val of games_per_version

      wins_first_player = 0

      for game in filteredData
        i = 0
        i++ while game.game.history[i].owner is -1 and i < game.game.history.length

        wins_first_player++ if game.game.history[i].owner is game.game.result

      pctData = [
        {label: "P1", value: wins_first_player}
        {label: "P2", value: (total_games - wins_first_player)}
      ]

      winPctPieChart.update(pctData)

      games_per_map = {}

      for game in filteredData
        map = game.game.map or "valley.json"

        games_per_map[map] or= 0
        games_per_map[map]++

      mapData = ({"label": map, "value": value} for map, value of games_per_map)

      mapPieChart.update(mapData)

      unit_data = {}

      for game in filteredData
        for cmd in game.game.history when cmd.type is "Build"
          unit_data[cmd.building] or=
            count: 0
            p1_count: 0
            p2_count: 0
            w_count: 0
            l_count: 0
          unit_data[cmd.building].count++
          if cmd.owner is game.game.history[1].owner
            unit_data[cmd.building].p1_count++
          else
            unit_data[cmd.building].p2_count++
          if cmd.owner is game.game.result
            unit_data[cmd.building].w_count++
          else
            unit_data[cmd.building].l_count++


#      unit_data_per_game = JSON.parse JSON.stringify unit_data
#
#      games = 0
#      games++ for game in data when game.version is "0.0.17"
#      for unit of unit_data_per_game
#        unit_data_per_game[unit].count /= games
#        unit_data_per_game[unit].p1_count /= games
#        unit_data_per_game[unit].p2_count /= games
#        unit_data_per_game[unit].w_count /= games
#        unit_data_per_game[unit].l_count /= games

      totalUnitsPieChart.update(({"label": unit.replace("-base", ""), "value": value.count} for unit, value of unit_data))
      unitsP1PieChart.update(({"label": unit.replace("-base", ""), "value": value.p1_count} for unit, value of unit_data))
      unitsP2PieChart.update(({"label": unit.replace("-base", ""), "value": value.p2_count} for unit, value of unit_data))
      unitsWinnerPieChart.update(({"label": unit.replace("-base", ""), "value": value.w_count} for unit, value of unit_data))
      unitsLoserPieChart.update(({"label": unit.replace("-base", ""), "value": value.l_count} for unit, value of unit_data))
#
#      units_per_game = {}
#      units_per_game[unit] = udata.count for unit, udata of unit_data_per_game
#      $scope.createChart(units_per_game, '#unitsBuiltPerGame', 1)
#
#      units_per_game[unit] = udata.p1_count for unit, udata of unit_data_per_game
#      $scope.createChart(units_per_game, '#unitsP1BuiltPerGame', 1)
#
#      units_per_game[unit] = udata.p2_count for unit, udata of unit_data_per_game
#      $scope.createChart(units_per_game, '#unitsP2BuiltPerGame', 1)
#
#      units_per_game[unit] = udata.w_count for unit, udata of unit_data_per_game
#      $scope.createChart(units_per_game, '#unitsWBuiltPerGame', 1)
#
#      units_per_game[unit] = udata.l_count for unit, udata of unit_data_per_game
#      $scope.createChart(units_per_game, '#unitsLBuiltPerGame', 1)

    $scope.setVersionFilter = (version) ->
      console.log 'version filter applied'
      $scope.filterVersion = version
      $scope.update()

    $scope.setMapFilter = (map) ->
      console.log 'map filter applied'
      $scope.filterMap = map
      $scope.update()

    $scope.createChart = (data, selector, decimal_places) ->
      points = []
      labels = []

      for key, val of data
        points.push val
        labels.push key

      width = 420
      barHeight = 20

      x = d3.scale.linear().domain([0, d3.max(points)]).range([0, width])

      chart = d3.select(selector).attr('width', width).attr('height', barHeight * points.length)

      bar = chart.selectAll('g').data(points).enter().append('g').attr('transform', (d, i) -> "translate(0,#{i * barHeight})")

      bar.append('rect').attr('width', x).attr('height', barHeight - 1)

      bar.append('text')
      .attr('x', (d) -> x(d) - 3)
      .attr('y', barHeight / 2)
      .attr('dy', '.35em')
      .text((d, i) -> "#{labels[i]}: #{d.toFixed(decimal_places or 0)}")


class PieChart
  constructor: (@selector, @center_label, @center_units) ->
    @center_label or= "TOTAL"
    @center_units or= "games"
    @r = 100
    @w = 295
    @h = 250
    @ir = 45
    @textOffset = 14
    @tweenDuration = 250

    # vis & groups

    @vis = d3.select(@selector).attr("width", @w).attr("height", @h)
    @arc_group = @vis.append("svg:g").attr("class", "arc").attr("transform", "translate(#{@w/2},#{@h/2})")
    @label_group = @vis.append("svg:g").attr("class", "label_group").attr("transform", "translate(#{@w/2},#{@h/2})")
    @center_group = @vis.append("svg:g").attr("class", "center_group").attr("transform", "translate(#{@w/2},#{@h/2})")
    @paths = @arc_group.append("svg:circle").attr("fill", "#EFEFEF").attr("r", @r)

    # center text

    @whiteCircle = @center_group.append("svg:circle").attr("fill", "white").attr("r", @ir)
    @totalLabel = @center_group.append("svg:text").attr("class", "label").attr("dy", -15).attr("text-anchor", "middle").text(@center_label)
    @totalValue = @center_group.append("svg:text").attr("class", "total").attr("dy", 7).attr("text-anchor", "middle").text("Waiting...")
    @totalUnits = @center_group.append("svg:text").attr("class", "units").attr("dy", 21).attr("text-anchor", "middle").text(@center_units)

    @pieData = []
    @oldPieData = []

  update: (data) ->

    @arc_group.selectAll("path").remove()
    @label_group.selectAll("text").remove()
    @label_group.selectAll("line").remove()


    color = d3.scale.category20c()

    arc = d3.svg.arc().outerRadius(@r).innerRadius(@r/2).startAngle((d) -> d.startAngle).endAngle((d) -> d.endAngle)

    pie = d3.layout.pie().value((d) -> d.value)

    @oldPieData = @pieData
    @pieData = pie(data)

    pieTween = (d, i) =>
      s0 = null
      e0 = null

      if (@oldPieData[i]?)
        s0 = @oldPieData[i].startAngle
        e0 = @oldPieData[i].endAngle
      else if not (@oldPieData[i]?) and @oldPieData[i-1]?
        s0 = @oldPieData[i - 1].endAngle
        e0 = @oldPieData[i - 1].endAngle
      else if not (@oldPieData[i - 1]?) and @oldPieData.length > 0
        s0 = @oldPieData[@oldPieData.length - 1].endAngle
        e0 = @oldPieData[@oldPieData.length - 1].endAngle
      else
        s0 = 0
        e0 = 0
      i = d3.interpolate({startAngle: s0, endAngle: e0}, {startAngle: d.startAngle, endAngle: d.endAngle})
      return (t) -> arc(i(t))


    if (@pieData.length > 0)
      @arc_group.selectAll("circle").remove()

      totalGames = 0
      totalGames += point.value for point in @pieData

      @totalValue.text(totalGames)

      paths = @arc_group.selectAll("path").data(@pieData)
      paths.enter().append("svg:path")
      .attr("stroke", "white")
      .attr("stroke-width", 0.5)
      .attr("fill", (d, i) -> color(i))
      .transition().duration(@tweenDuration).attrTween("d", pieTween)

      #.attr("d", arc)


      valueLabels = @label_group.selectAll("text.value").data(@pieData)
      valueLabels.enter().append("svg:text").attr("class", "value")
      .attr("transform", (d) ->
          d.innerRadius = 0
          d.outerRadius = @r
          return "translate(#{arc.centroid(d)})"
        )
      .attr("dy", 5)
      .attr("text-anchor", "middle")
      .text( (d) -> d.value )

      nameLabels = @label_group.selectAll("text.label").data(@pieData)
      nameLabels.enter().append("svg:text").attr("class", "small-label")
#        .attr("transform", (d) ->
#          "translate(" + Math.cos((d.startAngle + d.endAngle - Math.PI)/2) * (r + textOffset) + "," + Math.sin((d.startAngle + d.endAngle - Math.PI) / 2) * (r + textOffset) + ")"
#        )
      .attr("transform", (d) =>
          d.innerRadius = @r
          d.outerRadius = @r + @textOffset * 2
          return "translate(#{d3.svg.arc().centroid(d)})"
        )
      .attr("dy", (d) ->
          angle = (d.startAngle + d.endAngle) / 2
          if Math.PI / 4 < angle < 7/4 * Math.PI
            3
          else
            0
        )
      .attr("text-anchor", (d) ->
          angle = (d.startAngle + d.endAngle) / 2
          if 3 / 4 * Math.PI > angle > Math.PI / 4
            return "beginning"
          else if 7 / 4 * Math.PI > angle > 5 / 4 * Math.PI
            return "end"
          "middle"
        )
      .text( (d, i) ->
          data[i].label
        )

      lines = @label_group.selectAll("line").data(@pieData)
      lines.enter().append("svg:line")
      .attr("x1", 0)
      .attr("x2", 0)
      .attr("y1", -@r-3)
      .attr("y2", -@r-8)
      .attr("stroke", "gray")
      .attr("transform", (d) ->
          'rotate(' + (d.startAngle + d.endAngle) / 2 * (180 / Math.PI) + ')'
        )

