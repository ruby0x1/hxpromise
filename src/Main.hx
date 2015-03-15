
import luxe.Input;

import Promise;

class Main extends luxe.Game {

    override function config(c:luxe.AppConfig) {

        return c;

    }

    override function ready() {

        Luxe.showConsole(true);

//usage 1
//resolve, single then

        var u1 = new Promise('u1',
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

        var u2 = new Promise('u2',
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

        var u3 = new Promise('u3',
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

        var u4 = new Promise('u4',
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

        var u5 = new Promise('u5',
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
        );
        u7.error(
            function(rejected){
                trace('u7-error: $rejected');
            }
        );

    } //ready

    override function onkeyup( e:KeyEvent ) {

        if(e.keycode == Key.escape) {
            Luxe.shutdown();
        }

    } //onkeyup

    override function update(dt:Float) {

        Promises.step();

    } //update


} //Main
