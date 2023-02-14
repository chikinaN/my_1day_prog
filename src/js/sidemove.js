const boxes = document.querySelectorAll(".content");
const options = {
	root: null,
	rootMargin: "-50% 0px",
	threshold: 0
};
const observer = new IntersectionObserver(doWhenIntersect, options);
boxes.forEach(box => {
	observer.observe(box);
});
function doWhenIntersect(entries) {
	entries.forEach(entry => {
		if (entry.isIntersecting) {
			activateIndex(entry.target);
		}
	});
}
function activateIndex(element) {
	const currentActiveIndex = document.querySelector("#sideList .active");
	if (currentActiveIndex !== null) {
		currentActiveIndex.classList.remove("active");
	}
	const newActiveIndex = document.querySelector(`a[href='#${element.id}']`);
	newActiveIndex.classList.add("active");
}