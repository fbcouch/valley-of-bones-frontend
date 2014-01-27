'use strict'

angular.module('valleyOfBonesFrontendApp')
  .controller 'StatsCtrl', ($scope, $resource) ->

    r = 100
    w = 450
    h = 300
    ir = 45
    textOffset = 14
    tweenDuration = 250

    # vis & groups

    vis = d3.select("#versionPieChart").attr("width", w).attr("height", h) #.append("svg:g").attr("transform", "translate(#{w/2},#{h/2})")

    arc_group = vis.append("svg:g").attr("class", "arc").attr("transform", "translate(#{w/2},#{h/2})")

    label_group = vis.append("svg:g").attr("class", "label_group").attr("transform", "translate(#{w/2},#{h/2})")

    center_group = vis.append("svg:g").attr("class", "center_group").attr("transform", "translate(#{w/2},#{h/2})")

    paths = arc_group.append("svg:circle").attr("fill", "#EFEFEF").attr("r", r)

    # center text

    whiteCircle = center_group.append("svg:circle").attr("fill", "white").attr("r", ir)

    totalLabel = center_group.append("svg:text").attr("class", "label").attr("dy", -15).attr("text-anchor", "middle").text("TOTAL")

    totalValue = center_group.append("svg:text").attr("class", "total").attr("dy", 7).attr("text-anchor", "middle").text("Waiting...")

    totalUnits = center_group.append("svg:text").attr("class", "units").attr("dy", 21).attr("text-anchor", "middle").text("games")

    data = $resource('http://secure-caverns-9874.herokuapp.com/game').query () ->
      for game in data
        if !isNaN(parseFloat(game.version)) and isFinite(game.version)
          game.version = "0.0.#{game.version}"
        game.game = JSON.parse(game.game.replace(',]', ']'))

      # remove short games (< 10 turns)

      data = data.map( (game) ->
        if game.game.history.length >= 10 then game else null
      )

      data = (game for game in data when game?)

      games_per_version = {}

      for game in data
        games_per_version[game.version] or= 0
        games_per_version[game.version]++

      $scope.createChart(games_per_version, '#gamesPerVersion')

      # variables and helper things for pie chart

      pieData = []
      oldPieData = []
      filteredPieData = []

      pieData = ({"label": version, "value": value} for version, value of games_per_version)

      color = d3.scale.category20c()

      arc = d3.svg.arc().outerRadius(r).innerRadius(r/2).startAngle((d) -> d.startAngle).endAngle((d) -> d.endAngle)

      pie = d3.layout.pie().value((d) -> d.value)

      pieTween = (d, i) ->
        s0 = null
        e0 = null

        if (oldPieData[i]?)
          s0 = oldPieData[i].startAngle
          e0 = oldPieData[i].endAngle
        else if not (oldPieData[i]?) and oldPieData[i-1]?
          s0 = oldPieData[i - 1].endAngle
          e0 = oldPieData[i - 1].endAngle
        else if not (oldPieData[i - 1]?) and oldPieData.length > 0
          s0 = oldPieData[oldPieData.length - 1].endAngle
          e0 = oldPieData[oldPieData.length - 1].endAngle
        else
          s0 = 0
          e0 = 0
        i = d3.interpolate({startAngle: s0, endAngle: e0}, {startAngle: d.startAngle, endAngle: d.endAngle})
        return (t) -> arc(i(t))


      if (pieData.length > 0)
        arc_group.selectAll("circle").remove()

        totalGames = 0
        totalGames += point.value for point in pieData

        totalValue.text(totalGames)

        realPieData = pie(pieData)

        paths = arc_group.selectAll("path").data(realPieData)
        paths.enter().append("svg:path")
        .attr("stroke", "white")
        .attr("stroke-width", 0.5)
        .attr("fill", (d, i) -> color(i))
        .transition().duration(tweenDuration).attrTween("d", pieTween)

        #.attr("d", arc)


        valueLabels = label_group.selectAll("text.value").data(realPieData)
        valueLabels.enter().append("svg:text").attr("class", "value")
        .attr("transform", (d) ->
          d.innerRadius = 0
          d.outerRadius = r
          return "translate(#{arc.centroid(d)})"
        )
        .attr("dy", 5)
        .attr("text-anchor", "middle")
        .text( (d) -> d.value )

        nameLabels = label_group.selectAll("text.label").data(realPieData)
        nameLabels.enter().append("svg:text").attr("class", "label")
#        .attr("transform", (d) ->
#          "translate(" + Math.cos((d.startAngle + d.endAngle - Math.PI)/2) * (r + textOffset) + "," + Math.sin((d.startAngle + d.endAngle - Math.PI) / 2) * (r + textOffset) + ")"
#        )
        .attr("transform", (d) ->
          d.innerRadius = r
          d.outerRadius = r + textOffset * 2
          return "translate(#{d3.svg.arc().centroid(d)})"
        )
        .attr("dy", (d) ->
          angle = (d.startAngle + d.endAngle) / 2
          if Math.PI / 4 < angle < 7/4 * Math.PI
            5
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
          pieData[i].label
        )

        lines = label_group.selectAll("line").data(realPieData)
        lines.enter().append("svg:line")
        .attr("x1", 0)
        .attr("x2", 0)
        .attr("y1", -r-3)
        .attr("y2", -r-8)
        .attr("stroke", "gray")
        .attr("transform", (d) ->
          'rotate(' + (d.startAngle + d.endAngle) / 2 * (180 / Math.PI) + ')'
        )


#      win_pct_first_player = {}
#
#      for game in data
#        win_pct_first_player[game.version] or= 0
#
#        i = 0
#        while game.game.history[i].owner is -1 and i < game.game.history.length
#          i++
#
#        win_pct_first_player[game.version]++ if game.game.history[i].owner is game.game.result
#
#      for key of games_per_version
#        win_pct_first_player[key] = win_pct_first_player[key] / games_per_version[key] * 100
#
#      $scope.createChart(win_pct_first_player, '#winPctFirstPerVersion', 1)
#
#      unit_data = {}
#
#      for game in data
#        for cmd in game.game.history when cmd.type is "Build" and game.version is "0.0.17"
#          unit_data[cmd.building] or=
#            count: 0
#            p1_count: 0
#            p2_count: 0
#            w_count: 0
#            l_count: 0
#          unit_data[cmd.building].count++
#          if cmd.owner is game.game.history[1].owner
#            unit_data[cmd.building].p1_count++
#          else
#            unit_data[cmd.building].p2_count++
#          if cmd.owner is game.game.result
#            unit_data[cmd.building].w_count++
#          else
#            unit_data[cmd.building].l_count++
#
#
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
