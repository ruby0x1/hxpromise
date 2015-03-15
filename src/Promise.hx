

@:enum
abstract PromiseState(Int) from Int to Int {
        //initial state, not fulfilled or rejected
    var pending = 0;
        //successful operation
    var fulfilled = 1;
        //failed operation
    var rejected = 2;

}

@:allow(Promise)
class Promises {

    static var calls: Array<Dynamic> = [];
    static var defers: Array<{f:Dynamic,a:Dynamic}> = [];

    public static function step() {

        for(call in calls) call();
        for(defer in defers) defer.f(defer.a);

        calls.splice(0,calls.length);
        defers.splice(0,defers.length);

    }

    static function defer<T,T1>(f:T, a:T1) {
        if(f == null) return;
        defers.push({f:f, a:a});
    }

    static function queue<T>(f:T) {
        if(f == null) return;
        calls.push(cast f);
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

    var result : Dynamic;
    var reject_reactions: Array<Dynamic>;
    var fulfill_reactions: Array<Dynamic>;

    var tag:String = 'auto';

    public function new<T>( _tag:String='auto', func:T ) {

        reject_reactions = [];
        fulfill_reactions = [];

        tag = _tag;
        state = pending;
        impl = func;

        Promises.queue(function() {
            impl(onresolve, onreject);
        });

    } //new

    public function then<T,T1>( res:T, ?rej:T ) : Promise {

        if(state != pending) {
            if(state == fulfilled) {
                Promises.defer(res, result);
                return Promise.resolve(result);
            } else if(state == rejected) {
                Promises.defer(rej, result);
                return Promise.reject(result);
            }
        }

        addfulfill(res);
        addreject(rej);

        return new Promise('then', function(ok,no){
            if(state == fulfilled) {
                ok(result);
            } else if(state == rejected) {
                no(result);
            }
        });

    } //then

    public function error<T>( func:T ) : Promise {

        if(state != pending) {
            if(state == fulfilled) {
                return Promise.resolve(result);
            } else if(state == rejected) {
                Promises.defer(func, result);
                return Promise.reject(result);
            }
        }

        addreject(func);

        return Promise.resolve();

    } //error

    public static function all( _tag='all', list:Array<Promise> ) {

        return new Promise(_tag,function(ok, no) {

            var total = list.length;
            var current = 0;
            var fulfill_result = [];
            var reject_result = null;
            var all_state:PromiseState = pending;

            var singleok = function(val) {
                if(all_state != pending) return;

                current++;
                fulfill_result.push(val);

                if(total == current) {
                    all_state = fulfilled;
                    ok(fulfill_result);
                }
            } //singleok

            var singleno = function(val) {
                if(all_state != pending) return;
                all_state = rejected;
                reject_result = val;
                no(reject_result);
            }

            for(promise in list) {
                promise.then(singleok).error(singleno);
            }

        }); //promise

    } //all

    public static function race( list:Array<Promise> ) {

        return new Promise('race', function(ok,no) {

            var settled = false;
            var singleok = function(val) {
                if(settled) return;
                settled = true;
                ok(val);
            }

            var singleerr = function(val) {
                if(settled) return;
                settled = true;
                no(val);
            }

            for(promise in list) {
                promise.then(singleok).error(singleerr);
            }
        });

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
        return 'Promise { tag:$tag, state:$state, result:$result }';
    }

//Internal

    function addfulfill<T>(f:T)
        if(f!=null) fulfill_reactions.push( cast f );

    function addreject<T>(f:T)
        if(f!=null) reject_reactions.push( cast f );

//Sync management

    function onresolve<T,T1>( val:T ) {

        // trace('resolve: $tag, to $val, with ${fulfill_reactions.length} reactions');

        state = fulfilled;
        result = val;

        for(f in fulfill_reactions) f(result);

    } //onresolve

    function onreject<T,T1>( reason:T ) {

        // trace('reject: $tag, to $reason, with ${reject_reactions.length} reactions');

        state = rejected;
        result = reason;

        for(f in reject_reactions) f(result);

    } //onreject

} //Promise

