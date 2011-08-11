#!/usr/bin/env node

var sys = require('sys');

// TODO: clean up globals
var Map = [ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C',
            'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
            'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c',
            'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p',
            'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '_', '-' ];

function base_conv(num, base) {
	var chars = [];
	while (num > 0) {
		chars.unshift( Map[(num % base)] );
		num = Math.floor(num/base);
	}

	return chars.join('');
}

var Bases = [60,16,12,10,8,2];
process.argv.forEach( function (val, idx, arry) {
	// TODO: usage: if num args is 0... map? select?
	if (idx > 0 && val != __filename ) {
		var num = parseInt(val);
		var arr = [];
		for (var i in Bases) {
			arr.push( base_conv(num, Bases[i]) );
		}

		process.stdout.write(arr.join("\t") + "\n");
	}
} );
