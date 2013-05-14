app.constant "XCHGLAB_CONFIG",
    API_KEY: "CPRprCRzIbJ_GLKtT9eitH2knfZnzuRJ"
    DB_NAME: "of1"

describe "xchglab resource", ->
    beforeEach module("xchglabResourceHttp")
    beforeEach inject(($injector) ->
        $xchglabResourceHttp = $injector.get("$xchglabResourceHttp")
        XCHGLAB_CONFIG = $injector.get("app.XCHGLAB_CONFIG")
    )
    describe "Testing", ->
        it "getById", ->
            expect($xchglabResourceHttp.getById('51709ec7831c4b18ea866ef5')).toEqual 2

        it "should add 2 + 2", ->
            expect(2).toEqual 2

