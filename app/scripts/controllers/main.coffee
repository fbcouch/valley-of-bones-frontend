'use strict'

angular.module('valleyOfBonesFrontendApp')
  .controller 'MainCtrl', ($scope) ->
    $scope.posts = [
      {
        date: 'Jan 30'
        title: 'Update 0.1.13'
        body: """
* Units no longer get an extra move by moving through tower
* Pause/unpause notifications no longer show at start of game
* Some artwork changes
              """
      },
      {
        date: 'Jan 30'
        title: 'Update 0.1.12'
        body: """
* removed center tower from Starship map
              """
      },
      {
        date: 'Jan 29'
        title: 'Update 0.1.11'
        body: """
* New map: Starship
* Pause/unpause
* Some artwork updates
                """
      },
      {
        date: 'Jan 29'
        title: 'Update 0.1.10'
        body: """
* Sniper cloak rule change: can only enter if haven't fired or moved more than one space
              """
      },
      {
        date: 'Jan 28'
        title: 'Update 0.1.9'
        body: """
* Fixed sniper movement bug, view update bug
              """
      },
      {
        date: 'Jan 27'
        title: 'Update 0.1.8'
        body: """
* Added new map: radial
* Changed Light Mech from $125 to $120
* Changed Tank from $150, 5 food to $130, 4 food
* Changed Artillery from $175, 5 food to $140, 4 food
              """
      }
    ]
