// サイドバーの生成

let side = document.getElementById("side");
let sideContent = "<ul id='sideList'>";
const mainContent = document.getElementById('main');
const mainCount = mainContent.getElementsByClassName('content');
const contentCount = mainCount.length
for ( let i = 0; i < contentCount; i++) {
	let contentDate = mainCount[i].getAttribute('content')
	let contentId = mainCount[i].getAttribute('id')
	sideContent += "<li><a href=#" + contentId + ">" + contentDate + "</a></li>"
}
sideContent += "</ul>";
side.innerHTML = sideContent;