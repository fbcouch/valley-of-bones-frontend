'use strict'

describe 'Controller: DownloadCtrl', () ->

  # load the controller's module
  beforeEach module 'valleyOfBonesFrontendApp'

  DownloadCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    DownloadCtrl = $controller 'DownloadCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', () ->
    expect(scope.awesomeThings.length).toBe 3
