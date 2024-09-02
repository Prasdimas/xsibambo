
function one_money(inp, format) {
    if (!inp)
        return 0
    return numeral(inp).format(format ? format : '0,000')
}
window.one_money = one_money

function one_mask_money(xx) {
    let x = 0
    if (!!xx)
        x = xx;

    let l = x.toString().length
    let y = []
    for (let i = 0; i < l; i++) {
        y.push('#')
        if (i % 3 == 2 && (i + 1) < l) y.push(',')
    }

    let z = y.reverse()
    z.push('#')
    return z.join('')
}

function phone_format(phone) {
    let x = false;
    let matches = [/^\+/];
    for (let m of matches)
        if (!x) x = phone.match(m)

    if (!x && !!phone.match(/^08/))
        return "+62 " + phone.substr(1, 99)

    if (!x)
        return "+62 " + phone;

    return phone;
}

window.one_mask_money = one_mask_money
window.phone_format = phone_format

function vf_commafy(strNumber, decimalplaces, roundupinteger) {
    strNumber = strNumber.toString()
    if (strNumber != '') {
        var intValue = '';
        var decimalValue = '';
        var cparts = new Array();
        if (strNumber.indexOf('.') >= 0) {
            cparts = strNumber.split('.');
        } else {
            cparts[0] = strNumber;
        }
        if (cparts[0].length > 3) {
            var comma_iterator = 0;
            for (var i = cparts[0].length - 1; i >= 0; i--) {
                intValue = cparts[0].charAt(i) + intValue;
                comma_iterator++;
                if (comma_iterator == 3) {
                    comma_iterator = 0;
                    if (i != 0) {
                        intValue = ',' + intValue;
                    }
                }
            }
        } else {
            intValue = cparts[0];
        }

        if (cparts[1] > 0) {
            decimalValue = cparts[1];
        }
        if (decimalplaces > 0) {
            if (decimalValue.length > decimalplaces) {
                var remainder = decimalValue.substr(decimalplaces)
                if (remainder >= (10 ** remainder.length / 2)) {
                    decimalValue = decimalValue.substr(0, decimalplaces);
                    decimalValue = parseInt(decimalValue) + 1;
                } else {
                    decimalValue = decimalValue.substr(0, decimalplaces);
                }
            } else if (decimalValue.length < decimalplaces) {
                for (var i = decimalValue.length; i < decimalplaces; i++) {
                    decimalValue = decimalValue + '0';
                }
            }
        }
        if (roundupinteger) {
            var roundingFactor = 5;
            if (decimalValue.length > 1) {
                roundingFactor = roundingFactor * (10 * (decimalValue.length - 1));
            }
            if (decimalValue >= roundingFactor) {
                intValue = parseInt(intValue) + 1;
            }
            decimalValue = '';
        } else {
            intValue = intValue + '.' + decimalValue;
        }
        return intValue;
    }
    return 0
}

window.vf_commafy = vf_commafy

function parse_query_string(query) {
    // if (typeof query !== 'string') {
    //     throw new TypeError('Expected a string as the query parameter');
    // }

    var vars = query.split("&");
    var query_string = {};
    for (var i = 0; i < vars.length; i++) {
        var pair = vars[i].split("=");
        var key = decodeURIComponent(pair.shift());
        var value = decodeURIComponent(pair.join("="));
        // If first entry with this name
        if (typeof query_string[key] === "undefined") {
            query_string[key] = value;
            // If second entry with this name
        } else if (typeof query_string[key] === "string") {
            var arr = [query_string[key], value];
            query_string[key] = arr;
            // If third or later entry with this name
        } else {
            query_string[key].push(value);
        }
    }
    return query_string;
}


window.parse_query_string = parse_query_string

// DRAGGABLE DIALOG
    (function() { // make vuetify dialogs movable
    const d = {};
    document.addEventListener("mousedown", e => {
        const closestDialog = e.target.closest(".v-dialog.v-dialog--active");
        if (e.button === 0 && closestDialog != null && e.target.classList.contains("v-card__title")) { // element which can be used to move element
            d.el = closestDialog; // element which should be moved
            d.mouseStartX = e.clientX;
            d.mouseStartY = e.clientY;
            d.elStartX = d.el.getBoundingClientRect().left;
            d.elStartY = d.el.getBoundingClientRect().top;
            d.el.style.position = "fixed";
            d.el.style.margin = 0;
            d.oldTransition = d.el.style.transition;
            d.el.style.transition = "none"
        }
    });
    document.addEventListener("mousemove", e => {
        if (d.el === undefined) return;
        d.el.style.left = Math.min(
            Math.max(d.elStartX + e.clientX - d.mouseStartX, 0),
            window.innerWidth - d.el.getBoundingClientRect().width
        ) + "px";
        d.el.style.top = Math.min(
            Math.max(d.elStartY + e.clientY - d.mouseStartY, 0),
            window.innerHeight - d.el.getBoundingClientRect().height
        ) + "px";
    });
    document.addEventListener("mouseup", () => {
        if (d.el === undefined) return;
        d.el.style.transition = d.oldTransition;
        d.el = undefined
    });
    setInterval(() => { // prevent out of bounds
        const dialog = document.querySelector(".v-dialog.v-dialog--active");
        if (dialog === null) return;
        dialog.style.left = Math.min(parseInt(dialog.style.left), window.innerWidth - dialog.getBoundingClientRect().width) + "px";
        dialog.style.top = Math.min(parseInt(dialog.style.top), window.innerHeight - dialog.getBoundingClientRect().height) + "px";
    }, 100);
})();

function
getParameter(key) {

    // Address of the current window
    address = window.location.search

    // Returns a URLSearchParams object instance
    parameterList = new URLSearchParams(address)

    // Returning the respected value associated
    // with the provided key
    return parameterList.get(key)
}

window.getParameter = getParameter