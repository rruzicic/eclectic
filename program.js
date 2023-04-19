const fs = require('fs');


var memory = new WebAssembly.Memory({ initial: 1 });

function consoleLogString(offset, length) {
    var bytes = new Uint8Array(memory.buffer, offset, length);
    var string = new TextDecoder('utf8').decode(bytes);
    console.log(string);
};

function consoleLogNumber(num) {
    console.log(num);
}

function consoleLogBool(bool) {
    console.log(Boolean(bool));
}

var importObject = {
    console: {
        log_string: consoleLogString,
        log_number: consoleLogNumber,
        log_bool: consoleLogBool,
    },
    js: {
        mem: memory
    }
};

const wasmBuffer = fs.readFileSync('program.wasm');

WebAssembly.instantiate(wasmBuffer, importObject).then(wasmModule => {
    wasmModule.instance.exports.main();
});