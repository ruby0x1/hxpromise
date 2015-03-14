
import luxe.Input;

import Promise;

class Main extends luxe.Game {

    override function config(c:luxe.AppConfig) {

        c.has_window = false;

        return c;

    }

    override function ready() {

        // var a = Promise.resolve('a');
        // var b = Promise.resolve('b');

        // var s = Promise.all([a, b]);

        // s.then(function(v){
        //     trace(v);
        // });

        new Promise(function(resolve, reject) {
            reject('val');
        }).then(function(val:String) {
            trace('then: $val');
        }).error(function(err) {
            trace('huh: ' + err);
        }).then(function(val) {
            trace('then: always');
        });

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
