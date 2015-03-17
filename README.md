# hxpromise

An ES6 based [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise
) library for [Haxe](http://haxe.org).

Documentation can be found in the code file, but mirrors the documentation from [MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), licensed under CC-BY-SA 2.5. by Mozilla Contributors.

## Examples

## flags/defines

- `hxpromise_no_throw_unhandled_rejection`
    - define this to prevent unhandled rejections from calling `throw`

## Differences from spec

- `catch` function is called `error`. catch is a keyword in Haxe.
- `resolve` doesn't chain if the value handed in is a promise (:todo: 1.1.0)

## todo
- Externs for js Promise to use native type.
    - This isn't widely supported in major browsers yet.
- Test more targets (tested: cpp, js, neko)
    - Just basic haxe functions, so should work elsewhere