function darkSwitch() {
	const current = getComputedStyle(document.documentElement).getPropertyValue('--color-scheme').trim();
	document.documentElement.classList.remove('color-scheme-' + current);
	const automatic = getComputedStyle(document.documentElement).getPropertyValue('--color-scheme').trim();

	if (current != automatic) {
		localStorage.removeItem('color-scheme');
	} else {
		const next = current == 'dark' ? 'light' : 'dark';
		document.documentElement.classList.add('color-scheme-' + next);
		localStorage.setItem('color-scheme', next);
	}
}
