

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

        next();

        for(defer in defers) defer.f(defer.a);
        defers.splice(0,defers.length);

    }

    static function next() {
        if(calls.length > 0) (calls.shift())();
    }

    static function defer<T,T1>(f:T, ?a:T1) {
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
    var settle_reactions: Array<Dynamic>;

    var tag:String = 'auto';

    public function new<T>( _tag:String='auto', func:T ) {

        reject_reactions = [];
        fulfill_reactions = [];
        settle_reactions = [];

        tag = _tag;
        state = pending;
        impl = func;

        Promises.queue(function() {
            impl(onfulfill, onreject);
            Promises.defer(Promises.next);
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

        return new_linked_promise();

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

        return new_linked_resolve_empty();

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

        //add a settle reaction unless
        //this promise is already settled,
        //at which it calls right away
    function addsettle(f) {
        if(state == pending) {
            settle_reactions.push(f);
        } else {
            Promises.defer(f,result);
        }
    }

        //return a new linked promise that
        //will wait on this one settling and
        //settle the linked promise with the state
    function new_linked_promise() {

        return new Promise(tag+':link',function(f, r) {
            addsettle(function(_){
                if(state == fulfilled){
                    f(result);
                } else {
                    r(result);
                }
            });
        }); //promise

    } //new_linked_promise


        //return an already resolved
        //promise that will wait on this one
    function new_linked_resolve() {
        return new Promise(function (f,r) {
            addsettle(function(val) {
                f(val);
            });
        });
    }

        //return an already resolved
        //promise that will wait on this one
    function new_linked_reject() {
        return new Promise(function (f,r) {
            addsettle(function(val){
                r(val);
            });
        });
    }

        //return an already resolved
        //promise that will wait on this one
        //but have no value fulfilled
    function new_linked_resolve_empty() {
        return new Promise(function(f,r) {
            addsettle(function(_){
                f();
            });
        });
    }

        //return an already resolved
        //promise that will wait on this one
        //but have no value fulfilled
    function new_linked_reject_empty() {
        return new Promise(function(f,r) {
            addsettle(function(_){
                r();
            });
        });
    }


    function addfulfill<T>(f:T)
        if(f!=null) fulfill_reactions.push( cast f );

    function addreject<T>(f:T)
        if(f!=null) reject_reactions.push( cast f );

//Sync management

    function onfulfill<T,T1>( val:T ) {

        // trace('resolve: $tag, to $val, with ${fulfill_reactions.length} reactions');

        state = fulfilled;
        result = val;

        while(fulfill_reactions.length > 0) {
            var fn = fulfill_reactions.shift();
            fn(result);
        }

        onsettle();

    } //onfulfill

    function onreject<T,T1>( reason:T ) {

        // trace('reject: $tag, to $reason, with ${reject_reactions.length} reactions');

        state = rejected;
        result = reason;

        while(reject_reactions.length > 0) {
            var fn = reject_reactions.shift();
            fn(result);
        }

        onsettle();

    } //onreject

    function onsettle() {

        while(settle_reactions.length > 0) {
            var fn = settle_reactions.shift();
            fn(result);
        }

    } //onsettle

} //Promise

