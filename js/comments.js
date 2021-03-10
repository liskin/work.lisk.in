{
	const theme = getComputedStyle(document.documentElement).getPropertyValue('--color-scheme').trim();
	const issue_number = document.currentScript.getAttribute('issue-number');

	const s = document.createElement('script');
	s.async = true;
	s.crossOrigin = 'anonymous';
	s.setAttribute('repo', 'liskin/work.lisk.in');
	s.setAttribute('issue-number', issue_number);
	s.setAttribute('theme', 'github-' + theme);
	s.src = 'https://utteranc.es/client.js';
	document.body.insertBefore(s, document.currentScript);
	document.body.removeChild(document.currentScript);
}
