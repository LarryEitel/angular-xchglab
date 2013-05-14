angular.module("xchglabResourceHttp", []).factory "$xchglabResourceHttp",
    ["XCHGLAB_CONFIG", "$http", (XCHGLAB_CONFIG, $http) ->
        XchgLabResourceFactory = (collectionName) ->
            config = angular.extend(
                # BASE_URL: "http://localhost:5000/api"
                BASE_URL: "http://exi.xchg.com/api"
            , XCHGLAB_CONFIG)
            url = config.BASE_URL
            collectionUrl = url + "/" + collectionName
            defaultParams = {} #apiKey: config.API_KEY
            $http.defaults.headers.common['Authorization'] = 'Basic admin@orgtec.com:xxxxxx'
            resourceRespTransform = (data) ->
                new Resource(data)

            # Add Resource Methods to returned items
            resourcesArrayRespTransform = (data) ->

                console.log('hello')
                console.log(data)
                if data?._items?
                    items = []
                    i = 0
                    while i < data['_items'].length
                        items.push new Resource(data['_items'][i])
                        i++
                    data['_items'] = items

                return data

            promiseThen = (httpPromise, successcb, errorcb, fransformFn) ->
                httpPromise.then ((response) ->
                    # console.log response
                    result = fransformFn(response.data)
                    (successcb or angular.noop) result, response.status, response.headers, response.config
                    result
                ), (response) ->
                    (errorcb or angular.noop) `undefined`, response.status, response.headers, response.config
                    `undefined`


            preparyQueryParam = (queryJson) ->
                (if angular.isObject(queryJson) and not angular.equals(queryJson,
                    {})
                then q: JSON.stringify(queryJson) else {})

            Resource = (data) ->
                angular.extend this, data

            Resource.query = (queryJson, options, successcb, errorcb) ->
                prepareOptions = (options) ->
                    optionsMapping =
                        sort: "s"
                        limit: "l"
                        fields: "f"
                        skip: "sk"

                    optionsTranslated = {}
                    if options and not angular.equals(options, {})
                        angular.forEach optionsMapping, (targetOption, sourceOption) ->
                            if angular.isDefined(options[sourceOption])
                                if angular.isObject(options[sourceOption])
                                    optionsTranslated[targetOption] = JSON.stringify(options[sourceOption])
                                else
                                    optionsTranslated[targetOption] = options[sourceOption]

                    optionsTranslated

                if angular.isFunction(options)
                    errorcb = successcb
                    successcb = options
                    options =
                        {}
                requestParams = angular.extend({}, defaultParams, preparyQueryParam(queryJson), prepareOptions(options))
                httpPromise = $http.get(collectionUrl)
                promiseThen httpPromise, successcb, errorcb, resourcesArrayRespTransform

            Resource.all = (options, successcb, errorcb) ->
                if angular.isFunction(options)
                    errorcb = successcb
                    successcb = options
                    options = {}
                Resource.query {}, options, successcb, errorcb

            Resource.count = (queryJson, successcb, errorcb) ->
                httpPromise = $http.get(collectionUrl,
                    params: angular.extend({}, defaultParams, preparyQueryParam(queryJson),
                        c: true
                    )
                )
                promiseThen httpPromise, successcb, errorcb, (data) ->
                    data


            Resource.distinct = (field, queryJson, successcb, errorcb) ->
                httpPromise = $http.post(dbUrl + "/runCommand", angular.extend({}, queryJson or {},
                    distinct: collectionName
                    key: field
                ),
                    params: defaultParams
                )
                promiseThen httpPromise, successcb, errorcb, (data) ->
                    data.values


            Resource.getById = (id, successcb, errorcb) ->
                httpPromise = $http.get(collectionUrl + "/" + id,
                    params: defaultParams
                )
                promiseThen httpPromise, successcb, errorcb, resourceRespTransform

            Resource.getByObjectIds = (ids, successcb, errorcb) ->
                qin = []
                angular.forEach ids, (id) ->
                    qin.push $oid: id

                Resource.query
                    _id:
                        $in: qin
                , successcb, errorcb


            #instance methods
            Resource::$id = ->
                if @_id and @_id.$oid
                    @_id.$oid
                else @_id  if @_id

            Resource::$save = (successcb, errorcb) ->
                httpPromise = $http.post(collectionUrl, this,
                    params: defaultParams
                )
                promiseThen httpPromise, successcb, errorcb, resourceRespTransform

            Resource::$update = (successcb, errorcb) ->
                httpPromise = $http.put(collectionUrl + "/" + @$id(), angular.extend({}, this,
                    _id: `undefined`
                ),
                    params: defaultParams
                )
                promiseThen httpPromise, successcb, errorcb, resourceRespTransform




            Resource::$post = (data, successcb, errorcb) ->
                console.log data
                httpPromise = $http.post(collectionUrl, data, config)
                promiseThen httpPromise, successcb, errorcb, resourceRespTransform






            Resource::$put = (data, successcb, errorcb) ->
                # httpPromise = $http.put(collectionUrl + "/" + @$id(), angular.extend({}, this,
                # httpPromise = $http(headers = {'Authorization': 'Basic admin@orgtec.com:xxxxxx'}).put(collectionUrl + "/" + @$id(), data)
                config = {'headers': {'If-Match': @etag}}
                console.log @etag
                httpPromise = $http.put(collectionUrl + "/" + @$id(), data, config)
                promiseThen httpPromise, successcb, errorcb, resourceRespTransform








            Resource::$remove = (successcb, errorcb) ->
                httpPromise = $http["delete"](collectionUrl + "/" + @$id(),
                    params: defaultParams
                )
                promiseThen httpPromise, successcb, errorcb, resourceRespTransform

            Resource::$saveOrUpdate = (savecb, updatecb, errorSavecb, errorUpdatecb) ->
                if @$id()
                    # @$update updatecb, errorUpdatecb
                    @$put updatecb, errorUpdatecb
                else
                    @$save savecb, errorSavecb

            Resource
        XchgLabResourceFactory
    ]