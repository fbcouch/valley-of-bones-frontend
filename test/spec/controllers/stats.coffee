'use strict'

describe 'Controller: StatsCtrl', () ->

  # load the controller's module
  beforeEach module 'valleyOfBonesFrontendApp'

  StatsCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    StatsCtrl = $controller 'StatsCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', () ->
    expect(scope.awesomeThings.length).toBe 3
