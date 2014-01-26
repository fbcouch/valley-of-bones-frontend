'use strict'

describe 'Controller: UnitsCtrl', () ->

  # load the controller's module
  beforeEach module 'valleyOfBonesFrontendApp'

  UnitsCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    UnitsCtrl = $controller 'UnitsCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', () ->
    expect(scope.awesomeThings.length).toBe 3
