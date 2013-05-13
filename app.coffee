app = angular.module("xchglab", ["xchglabResourceHttp"], ($routeProvider) ->
    $routeProvider.when "/list",
        templateUrl: "list.html"
        controller: "ListCtrl"
        resolve:
            plcs: (Plc) ->
                Plc.all()
            users: (User) ->
                User.all()

    $routeProvider.when "/edit/:id",
        templateUrl: "form.html"
        controller: "FormCtrl"
        resolve:
            plc: (Plc, $route) ->
                Plc.getById $route.current.params.id

    $routeProvider.when "/new",
        templateUrl: "form.html"
        controller: "FormCtrl"
        resolve:
            plc: (Plc) ->
                new Plc()

    $routeProvider.otherwise redirectTo: "/list"
)
app.constant "XCHGLAB_CONFIG",
    API_KEY: "CPRprCRzIbJ_GLKtT9eitH2knfZnzuRJ"
    DB_NAME: "of1"

app.factory "Plc", ($xchglabResourceHttp) ->
    $xchglabResourceHttp "plcs"

app.factory "User", ($xchglabResourceHttp) ->
    $xchglabResourceHttp "users"

app.controller "ListCtrl", ($scope, $location, plcs, users) ->
    try
        $scope.users = users['_items']
    catch error
        $scope.users = []

    try
        $scope.plcs = plcs['_items']
    catch error
        $scope.plcs = []

    $scope.new = ->
        $location.path "/new"

    $scope.edit = (plc) ->
        $location.path "/edit/" + plc._id

app.controller "FormCtrl", ($scope, $location, plc) ->
    plcCopy = angular.copy(plc)
    changeSuccess = ->
        $location.path "/list"

    changeError = ->
        throw new Error("Sth went wrong...")

    $scope.plc = plc

    $scope.put = ->
        # Old 9.982545852317527,-84.16940103940297
        pt = @plc.pts.split ","
        actions = {"$set":{"flds":{"lbl":@plc.lbl,"pts": [Number(pt[0]), Number(pt[0])]}}}
        $scope.plc.$put JSON.stringify({"actions":actions}), changeSuccess, changeError

    $scope.save = ->
        $scope.plc.$saveOrUpdate changeSuccess, changeSuccess, changeError, changeError

    $scope.remove = ->
        $scope.plc.$remove changeSuccess, changeError

    $scope.abandonChanges = ->
        $location.path "/list"

    $scope.hasChanges = ->
        not angular.equals($scope.plc, plcCopy)
