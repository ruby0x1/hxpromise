

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

    static var nodes: Array<Promise> = [];
    static var calls: Array<Dynamic> = [];

    public static function step() {

        // for(node in nodes) {
            // node.impl( promise.onresolve, promise.onreject );
        // }

        for(call in calls) {
            call();
        }

        calls.splice(0,calls.length);
        // nodes.splice(0,nodes.length);

    }

    static function queue(f) {
        if(f == null) return;
        calls.push(f);
    }

    // static function add(p) {
    //     if(p == null) return;
    //     nodes.push(p);
    // }

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

        Promises.queue( implcall );

    } //new

    function addok(f) {
        if(f!=null) fulfill_reactions.push( f );
        // trace('add ${fulfill_reactions.length}');
    }

    function addno(f) {
        if(f!=null) reject_reactions.push( f );
        // trace('add ${fulfill_reactions.length}');
    }

    public function then<T,T1>( res:T, ?rej:T ) : Promise {

        addok(cast res);
        addno(cast rej);

        if(state == fulfilled) {
            trace('then resolves');
            return Promise.resolve(result);
        } else if(state == rejected) {
            trace('then rejects');
            return Promise.reject(result);
        }

        return new Promise(function(ok,no){
            if(state == fulfilled) {
                ok(result);
            } else if(state == rejected) {
                no(result);
            }
        });

    } //then

    public function error<T>( func:T ) : Promise {

        addno(cast func);

        if(state == fulfilled) {
            return Promise.resolve(result);
        } else if(state == rejected) {
            return Promise.reject(result);
        }

        return new Promise(function(ok,no){
            ok();
        });

    } //error

    public static function all( list:Array<Promise> ) {

        return new Promise('all',function(ok, no) {
            trace('all');

            var total = list.length;
            var current = 0;
            var results = [];
            var settled = false;

            var singleok = function(val) {
                if(settled) return;
                trace('$current / $total');
                current++;
                results.push(val);
                if(total == current) {
                    settled = true;
                    ok(results);
                }
            }

            var singleno = function(val) {
                settled = true;
                no(val);
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

//Sync management

    function implcall() {
        impl(onresolve, onreject);
    }

    function onresolve<T,T1>( val:T ) {

        trace('resolve: $tag, to $val, with ${fulfill_reactions.length} reactions');

        state = fulfilled;
        result = val;

        for(f in fulfill_reactions) {
            f(result);
        }

    } //onresolve

    function onreject<T,T1>( reason:T ) {

        // trace('reject: $tag, to $reason, with ${reject_reactions.length} reactions');

        state = rejected;
        result = reason;

        for(f in reject_reactions) {
            f(result);
        }

    } //onreject

} //Promise

