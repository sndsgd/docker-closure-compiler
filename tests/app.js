import * as lib from "./lib.js";

console.log(lib.foobar("+"));
console.log(lib.foobar(lib.foobar("--")));
console.log(lib.kilogramsToPounds(100));

document.body.appendChild(lib.createDiv("help"))
document.body.appendChild(lib.createDiv("help1"))
document.body.appendChild(lib.createDiv("help2"))
document.body.appendChild(lib.createDiv("help3"))
document.body.appendChild(lib.createDiv("help4", "foo"))