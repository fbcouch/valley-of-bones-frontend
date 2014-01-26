'use strict'

angular.module('valleyOfBonesFrontendApp')
  .controller 'StatsCtrl', ($scope, $resource) ->
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

      win_pct_first_player = {}

      for game in data
        win_pct_first_player[game.version] or= 0

        i = 0
        while game.game.history[i].owner is -1 and i < game.game.history.length
          i++

        win_pct_first_player[game.version]++ if game.game.history[i].owner is game.game.result

      for key of games_per_version
        win_pct_first_player[key] = win_pct_first_player[key] / games_per_version[key] * 100

      $scope.createChart(win_pct_first_player, '#winPctFirstPerVersion', 1)

      unit_data = {}

      for game in data
        for cmd in game.game.history when cmd.type is "Build" and game.version is "0.0.17"
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


      unit_data_per_game = JSON.parse JSON.stringify unit_data

      games = 0
      games++ for game in data when game.version is "0.0.17"
      for unit of unit_data_per_game
        unit_data_per_game[unit].count /= games
        unit_data_per_game[unit].p1_count /= games
        unit_data_per_game[unit].p2_count /= games
        unit_data_per_game[unit].w_count /= games
        unit_data_per_game[unit].l_count /= games

      units_per_game = {}
      units_per_game[unit] = udata.count for unit, udata of unit_data_per_game
      $scope.createChart(units_per_game, '#unitsBuiltPerGame', 1)

      units_per_game[unit] = udata.p1_count for unit, udata of unit_data_per_game
      $scope.createChart(units_per_game, '#unitsP1BuiltPerGame', 1)

      units_per_game[unit] = udata.p2_count for unit, udata of unit_data_per_game
      $scope.createChart(units_per_game, '#unitsP2BuiltPerGame', 1)

      units_per_game[unit] = udata.w_count for unit, udata of unit_data_per_game
      $scope.createChart(units_per_game, '#unitsWBuiltPerGame', 1)

      units_per_game[unit] = udata.l_count for unit, udata of unit_data_per_game
      $scope.createChart(units_per_game, '#unitsLBuiltPerGame', 1)

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

      bar.append('text').attr('x', (d) -> x(d) - 3).attr('y', barHeight / 2).attr('dy', '.35em').text((d, i) -> "#{labels[i]}: #{d.toFixed(decimal_places or 0)}")
