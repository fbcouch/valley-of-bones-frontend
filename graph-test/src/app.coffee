

$.ajax("http://secure-caverns-9874.herokuapp.com/game").done(
  (data) ->
    for game in data
      if !isNaN(parseFloat(game.version)) and isFinite(game.version)
        game.version = "0.0.#{game.version}"
      game.game = JSON.parse(game.game.replace(',]', ']'))

    # remove short games (< 5 turns)

    data = data.map( (game) ->
      if game.game.history.length > 5 then game else null
    )

    data = (game for game in data when game?)

    games_per_version = {}

    for game in data
      games_per_version[game.version] or= 0
      games_per_version[game.version]++

    createChart(games_per_version, '#gamesPerVersion')

    marines_per_version = {}
    for game in data
      marines_per_version[game.version] or= 0
      for cmd in game.game.history
        marines_per_version[game.version]++ if cmd.type is "Build" and cmd.building is "marine-base"

    for key of games_per_version
      marines_per_version[key] /= games_per_version[key]

    createChart(marines_per_version, '#marinesPerVersion', 2)

    win_pct_first_player = {}

    for game in data
      win_pct_first_player[game.version] or= 0

      i = 0
      while game.game.history[i].owner is -1 and i < game.game.history.length
        i++

      console.log '-----'
      console.log game.version
      console.log game.game.history[i].owner
      console.log game.game.result
      win_pct_first_player[game.version]++ if game.game.history[i].owner is game.game.result

    for key of games_per_version
      win_pct_first_player[key] = win_pct_first_player[key] / games_per_version[key] * 100

    createChart(win_pct_first_player, '#winPctFirstPerVersion', 1)



).fail(
  (xhr, textStatus, err) ->
    console.log err
)


createChart = (data, selector, decimal_places) ->
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
