

//:todo: This will be converted to unit tests later.



//Since promises are frame or loop based you must call
//Promises step manually to step the microtasks. call this once per frame
//or multiple times if you have sections you want to split up.
//Without calling it - the functions will never trigger.

function every_frame() {
    Promises.step();
}


function run() {


//usage 1
//resolve, single then

        var u1 = new Promise(
            function(resolve, reject) {
                resolve('u1-val');
            }
        );
        trace(u1);

        u1.then(
            function(val:String) {
                trace('u1 then: $val');
            }
        );

//usage 2
//resolve, multiple then

        var u2 = new Promise(
            function(resolve, reject) {
                resolve('u2-val');
            }
        );
        trace(u2);

        u2.then(
            function(val:String) {
                trace('u2 then: $val');
            }
        ).then(
            function(val:String){
                trace('u2 then again: $val');
            }
        );

//usage 3
//reject, single catch

        var u3 = new Promise(
            function(resolve, reject) {
                reject('u3-val');
            }
        );
        trace(u3);

        u3.error(
            function(val:String) {
                trace('u3 catch: $val');
            }
        );

//usage 4
//reject, single then, single catch

        var u4 = new Promise(
            function(resolve, reject) {
                reject('u4-val');
            }
        );
        trace(u4);

        u4.then(
            function(val:String){
                trace('u4');
            }
        ).error(
            function(reason:String) {
                trace('u4 catch: $reason');
            }
        );

//usage 5
//reject, then and after then, single catch

        var u5 = new Promise(
            function(resolve, reject) {
                reject('u5-val');
            }
        );
        trace(u5);

        u5.then(
            function(val:String){
                trace('u5-val');
            }
        ).error(
            function(reason:String) {
                trace('u5 catch: $reason');
            }
        ).then(
            function() {
                trace('u5 always');
            }
        ).then(
            function() {
                trace('u5 always2');
            }
        );

//usage 6
//basic all

        var a = Promise.resolve('a');
        var b = Promise.resolve('b');
        var u6 = Promise.all('u6',[a,b]);

        trace(u6);
        u6.then(
            function(vals:Array<String>){
                trace('u6-vals $vals');
            }
        );

//usage 7
//basic all reject

        var a = Promise.resolve('a');
        var b = Promise.reject('b');
        var c = Promise.resolve('c');
        var u7 = Promise.all('u7',[a,b,c]);

        trace(u7);
        u7.then(
            function(vals:Array<String>){
                trace('u7-vals $vals');
            }
        ).error(
            function(rejected){
                trace('u7-error: $rejected');
            }
        ).then(
            function(none){
                trace('u7-always: $none');
            }
        );


        var a = new Promise(function(ok,no){
            trace('a start');
            throw "errhere";
        }).error(function(errhere){
            trace('a error:'+errhere); //from throw
        });

        var b = new Promise(function(_,_){

            trace('b start');

            var c = new Promise(function(_,_){
                trace('c start');
                throw "c fail";
            }); //no catch, rejection is ignored

        }).error(function(bfail){
            trace('b fail:'+bfail);
        });

}