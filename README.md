# hxpromise

An ES6 based [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise
) library for [Haxe](http://haxe.org).

Documentation can be found in the code file, but mirrors the documentation from [MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), licensed under CC-BY-SA 2.5. by Mozilla Contributors.

## Examples

See [Examples.hx](https://github.com/underscorediscovery/hxpromise/blob/master/tests/Example.hx)
See also: [es6 promises tutorial](http://www.html5rocks.com/en/tutorials/es6/promises/)

```haxe
new Promise(
    function(resolve, reject) {
        //call one or the other, not both
        //reject('uh oh');
        //resolve('u5-val');
    }
).then(
    function(val:String){
        //if success
        trace('u5-val');
    }
).error(
    function(reason:String) {
        //if failure
        trace('u5 catch: $reason');
    }
).then(
    function() {
        //no matter what the state was
        trace('u5 always');
    }
)
```

## flags/defines

- `hxpromise_dont_throw_unhandled_rejection`
    - define this to prevent unhandled rejections from calling `throw`

## Differences from spec

- `catch` function is called `error`. catch is a keyword in Haxe.
- No event loop implicit. Call `Promises.step` to propagate.
    - You must call it somewhere. This library will not try to guess your intent.
    - Call once per frame, or multiple times per "microtask" if you want
    - `Promises` instead of `Promise` for user facing API, as the step is "internal" almost.
- `throw`/exceptions are not spec based:
    - exceptions thrown in a promise body will reject the promise
    - exceptions not handled with `error` will bubble to the next frame and throw
        - (this can be disabled, but not a good idea, since ghost exceptions are awful)
        - `hxpromise_dont_throw_unhandled_rejection`
    - exceptions thrown in `error` will not be captured and throw properly
    - there is no connection between promises by proximity
        - (i.e nesting promises by scope alone means nothing, as in the spec)

- `resolve` doesn't chain if the value handed in is a promise (:todo: 1.1.0)

## todo
- Externs for js Promise to use native type.
    - This isn't widely supported in major browsers yet.
- Tests: will add more tests in an automated form soon
- Test more targets (tested: cpp, js, neko)
    - Just basic haxe functions, so should work elsewhere
