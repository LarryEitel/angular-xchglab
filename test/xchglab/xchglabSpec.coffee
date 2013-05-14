angular.module("test", ["xchglabResource"]).factory "User", ($xchglabResource) ->
    $xchglabResource "users"

describe "xchglab resource scenario", ->
    it "should add 2 + 2", ->
        expect(1 + 2).toEqual 3

