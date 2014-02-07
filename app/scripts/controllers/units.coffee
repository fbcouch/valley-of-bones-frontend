'use strict'

angular.module('valleyOfBonesFrontendApp')
  .controller 'UnitsCtrl', ($scope, $resource) ->

    $scope.units = $resource('units.json').get()



