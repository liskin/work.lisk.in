function darkSwitch() {
	const current = getComputedStyle(document.documentElement).getPropertyValue('--color-scheme').trim();
	const next = current == 'dark' ? 'light' : 'dark';
	document.documentElement.classList.remove('color-scheme-' + current);
	document.documentElement.classList.add('color-scheme-' + next);
	localStorage.setItem('color-scheme', next);
}
