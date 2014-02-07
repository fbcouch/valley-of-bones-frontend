'use strict'

angular.module('valleyOfBonesFrontendApp', [
  'ngResource',
  'ngSanitize',
  'ngRoute',
  'exp.markdown'
])
  .config ($routeProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .when '/download',
        templateUrl: 'views/download.html'
        controller: 'DownloadCtrl'
      .when '/units',
        templateUrl: 'views/units.html'
        controller: 'UnitsCtrl'
      .when '/stats',
        templateUrl: 'views/stats.html'
        controller: 'StatsCtrl'
      .otherwise
        redirectTo: '/'
