'use strict'

angular.module('valleyOfBonesFrontendApp')
  .controller 'DownloadCtrl', ($scope) ->
    $scope.stable =
      version: '0.1.13'
      date: 'Jan 30'
    $scope.nightly =
      version: '0.2.0'
      date: 'Feb 7'
