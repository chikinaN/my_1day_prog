// カレンダーを決めるjavascript

const week = ["日", "月", "火", "水", "木", "金", "土"];
const today = new Date();
var showDate = new Date(today.getFullYear(), today.getMonth(), 1);

window.onload = function () {
    showProcess(today, calendar);
};

function prev(){
    showDate.setMonth(showDate.getMonth() - 1);
    showProcess(showDate);
}

function next(){
    showDate.setMonth(showDate.getMonth() + 1);
    showProcess(showDate);
}

function showProcess(date) {
    var year = date.getFullYear();
    var month = date.getMonth();
    document.querySelector('#header').innerHTML = year + "年 " + (month + 1) + "月";

    var calendar = createProcess(year, month);
    document.querySelector('#calendar_content').innerHTML = calendar;
}
function createProcess(year, month) {
    var calendar = "<table><tr class='dayOfWeek'>";
    for (var i = 0; i < week.length; i++) {
        calendar += "<th>" + week[i] + "</th>";
    }
    calendar += "</tr>";

    var count = 0;
    var startDayOfWeek = new Date(year, month, 1).getDay();
    var endDate = new Date(year, month + 1, 0).getDate();
    var lastMonthEndDate = new Date(year, month, 0).getDate();
    var row = Math.ceil((startDayOfWeek + endDate) / week.length);

    for (var i = 0; i < row; i++) {
        calendar += "<tr>";
        for (var j = 0; j < week.length; j++) {
            if (i == 0 && j < startDayOfWeek) {
                calendar += "<td class='disabled'>" + (lastMonthEndDate - startDayOfWeek + j + 1) + "</td>";
            } else if (count >= endDate) {
                count++;
                calendar += "<td class='disabled'>" + (count - endDate) + "</td>";
            } else {
                count++;
                if(year == today.getFullYear()
                    && month == (today.getMonth())
                    && count == today.getDate()){
                    calendar += "<td class='today'>" + count + "</td>";
                } else {
                    dayDate = count.toString()
                    monthDate = month+ 1
                    monthDate.toString()
                    yearDate = year.toString()
                    searchDay = document.querySelector('section[years="'+CSS.escape(yearDate)+'"][month="'+CSS.escape(monthDate)+'"][day="'+CSS.escape(dayDate)+'"]') != null
                    if(searchDay == true) {
                        calendar += "<td>" + count + "<br>" + "<a href= #" + yearDate + "/" + monthDate + "/" + dayDate + ">有り</a>" +  "</td>";
                    } else {
                        calendar += "<td>" + count +  "</td>";
                    }
                }
            }
        }
        calendar += "</tr>";
    }
    return calendar;
}