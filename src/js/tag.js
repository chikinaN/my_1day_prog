// タグを決めるjavascript

const content = document.getElementById('main');
const tagData = content.getElementsByClassName('tag');
const tagNum = tagData.length
for (let tagI = 0; tagI < tagNum; tagI++ ) {
	tagDetail = tagData.item(tagI);
	const tagContents = tagDetail.getAttribute('tag');
	const space = " ";
	let tagItem = tagContents.split(space);
	let tag = "<div class='showTag'>"
	let tagCount = tagItem.length;
	for (let i = 0; i < tagCount; i++){
		tag += "<span class=" + tagItem[i] + ">" + tagItem[i] + "</span>";
	}
	tag += "</div>";
	tagDetail.innerHTML = tag;
}