

@:enum
abstract PromiseState(Int) from Int to Int {
        //initial state, not fulfilled or rejected
    var pending = 0;
        //successful operation
    var fulfilled = 1;
        //failed operation
    var rejected = 2;

}

class Promises {

    @:allow(Promise)
    static var nodes: Array<Promise> = [];

    public static function step() {
        for(promise in nodes) {
            if(promise.impl != null) {
                trace('step on ${promise.tag}');
                promise.impl( promise.onresolve, promise.onreject );
            }
        }
    }

}

class D {
    public static function pos( v, pos:haxe.PosInfos ) {
        // Sys.println(v + ' / ${pos.fileName}:${pos.lineNumber}:(${pos.className}:${pos.methodName})');
    }
}

@:allow(Promises)
class Promise {

    public var state : PromiseState;

    var impl : Dynamic;
    var value : Dynamic;

    var error_calls : Array<Dynamic>;
    var then_calls : Array<Dynamic>;
    var tag:String = 'auto';

    public function new<T>( _tag:String='auto', func:T ) {

        error_calls = [];
        then_calls = [];

        tag = _tag;
        state = pending;
        impl = func;

        Promises.nodes.push(this);

    } //new

    public function then<T,T1>( res:T, ?rej:T1 ) : Promise {

        then_calls.push(cast res);

        return Promise.resolve();

    } //then

    public function error<T>( func:T ) : Promise {

        // if(state == rejected) {
        //     untyped func(value);
        // } else if(state == pending) {
            error_calls.push(cast func);
        // }

        return Promise.resolve();

    } //error

    public static function all( list:Array<Promise> ) {

        return new Promise('all',function(ok, no) {

            var total = list.length;
            var current = 0;
            var results = [];

            var single = function(val) {
                trace('$current / $total');
                current++;
                results.push(val);
                if(total == current) {
                    ok(results);
                }
            }

            for(promise in list) {
                promise.then(single).error(no);
            }

        }); //promise

    } //all

    public static function race( list:Array<Promise> ) {

    } //race

    public static function reject<T>( ?reason:T ) {

        return new Promise('auto:rejected', function(ok, no){
            no(reason);
        });

    } //reject

    public static function resolve<T>( ?val:T ) {

        return new Promise('auto:resolved', function(ok, no){
            ok(val);
        });

    } //resolve

//Debug

    function toString() {
        return 'Promise { tag:$tag, state:$state, value:$value }';
    }

//Sync management

    @:allow(Promises)
    function onresolve<T,T1>( val:T ) {

        trace('resolve: $tag, ${then_calls.length} thens, to $val');

        state = fulfilled;
        value = val;

        for(t in then_calls) {
            t(value);
        }

        return null;

    } //onresolve

    @:allow(Promises)
    function onreject<T,T1>( reason:T ) {

        trace('reject: $tag');

        state = rejected;
        value = reason;

        for(e in error_calls) {
            e(reason);
        }

        return null;

    } //onreject

} //Promise

