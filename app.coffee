app = angular.module("xchglab", ['ui.bootstrap', "xchglabResourceHttp"], ($routeProvider) ->
    $routeProvider.when "/list",
        templateUrl: "list.html"
        controller: "ListCtrl"
        resolve:
#            plcs: (Plc) ->
#                Plc.all()
            users: (User) ->
                User.all()

    $routeProvider.when "/edit/:id",
        templateUrl: "form.html"
        controller: "FormCtrl"
        resolve:
            user: (User, $route) ->
                User.getById $route.current.params.id

    $routeProvider.when "/new",
        templateUrl: "form.html"
        controller: "FormCtrl"
        resolve:
            user: (User) ->
                new User()

    $routeProvider.otherwise redirectTo: "/list"
)
app.constant "XCHGLAB_CONFIG",
    API_KEY: "CPRprCRzIbJ_GLKtT9eitH2knfZnzuRJ"
    DB_NAME: "of1"
#
#app.factory "Plc", ($xchglabResourceHttp) ->
#    $xchglabResourceHttp "plcs"

app.factory "User", ($xchglabResourceHttp) ->
    $xchglabResourceHttp "users"

app.controller "ListCtrl", ($scope, $location, users) ->
    try
        $scope.users = users['_items']
    catch error
        $scope.users = []
#
#    try
#        $scope.plcs = plcs['_items']
#    catch error
#        $scope.plcs = []

    $scope.new = ->
        $location.path "/new"

    $scope.edit = (user) ->
        $location.path "/edit/" + user._id

app.controller "FormCtrl", ($scope, $location, user) ->
    userCopy = angular.copy(user)
    changeSuccess = ->
        $location.path "/list"

    changeError = ->
        throw new Error("Sth went wrong...")

    $scope.user = user

    $scope.post = ->
        actions = {"$set":{"flds":{"uNam":user.uNam, "fNam":user.fNam,"lNam": user.lNam}}}
        $scope.user.$put JSON.stringify({"actions":actions}), changeSuccess, changeError

    $scope.save = ->
        $scope.user.$saveOrUpdate changeSuccess, changeSuccess, changeError, changeError

    $scope.remove = ->
        $scope.user.$remove changeSuccess, changeError

    $scope.abandonChanges = ->
        $location.path "/list"

    $scope.hasChanges = ->
        not angular.equals($scope.user, userCopy)
