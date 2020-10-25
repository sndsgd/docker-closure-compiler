const foo = "FOO";
const bar = "BAR";

/**
 * @param {string} join
 * @return {string}
 */
function foobar(join) {
    return foo + join + bar;
}

/**
 * @param {!number} kg
 * @return {!number}
 */
function kilogramsToPounds(kg) {
    return Math.round(kg * 2.20462);
}

function createElement(tagName, className = "") {
    let el = document.createElement(tagName)
    if (className !== "") {
        el.classList.add(className);
    }
    return el;
}

/**
 * @param {!string} className
 * @param {!string} textContent
 * @return {Node}
 */
function createDiv(className, textContent = "") {
    let div = document.createElement("div")
    div.className = className

    if (textContent !== "") {
        div.innerHTML = textContent
    }

    return div
}

export { foobar, kilogramsToPounds, createDiv }
