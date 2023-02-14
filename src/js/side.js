// サイドバーの生成とそれに追従してくれるもの

// サイドバーの生成

// 完成イメージ図
// <div id="side">
// 	<ul>
// 		<li><a href="#">初めに</a></li>
// 		<li><a href="#">概要</a></li>
// 		<li><a href="#">宣言</a></li>
// 		<li><a href="#time_calendar">進捗カレンダー</a></li>
// 		<li><a href="#2023/2/8">1.チュートリアル</a></li>
// 	</ul>
// </div>
let side = document.getElementById("side");
let sideContent = "<ul>";
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
