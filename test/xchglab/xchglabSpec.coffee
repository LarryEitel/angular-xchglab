describe "xchglab resource", ->
    beforeEach module("xchglabResourceHttp")

    describe "Testing", ->
        it "getById", ->
            expect($xchglabResourceHttp.getById('51709ec7831c4b18ea866ef5')).toEqual 2

        it "should add 2 + 2", ->
            expect(2).toEqual 2

