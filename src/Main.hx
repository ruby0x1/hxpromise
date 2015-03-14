
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

        var u1 = new Promise(
            function(resolve, reject) {
                resolve('val');
            }
        );

        u1.then(
            function(val:String) {
                trace('u1 then: $val');
            }
        );

//usage 2
//resolve, multiple then

        var u2 = new Promise(
            function(resolve, reject) {
                resolve('val');
            }
        );

        u2.then(
            function(val:String) {
                trace('u2 then: $val');
            }
        ).then(
            function(val:String){
                trace('u2 then again: $val');
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
