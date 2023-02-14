const mainData = document.getElementById('main');
const mainTitleCount = mainData.getElementsByClassName('content');
const dataCount = mainTitleCount.length;
for ( let i = 0; i < dataCount; i++) {
	const title = mainTitleCount[i].getElementsByClassName('title')[0];
	let contentDate = mainCount[i].getAttribute('content');
	let mainTitle = contentDate;
	title.innerHTML = mainTitle;
}