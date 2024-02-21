function reset_form(event){
    radio_btns = document.getElementsByName('day_period')
    for (let button of radio_btns)
        button.checked = false
    checkbox = document.getElementById('show_closed_gyms')
    checkbox.checked = false
}

window.onload = function() {
    btns = document.getElementsByClassName('clean-btn')
    for (let button of btns){
        button.addEventListener('click', reset_form)
    }
}