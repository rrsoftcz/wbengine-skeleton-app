(() => {
    'use strict';

    const commandNames = new Set([
        'apt', 'apt-get', 'brew', 'cat', 'cd', 'chmod', 'chown', 'composer', 'cp', 'curl',
        'docker', 'echo', 'exec', 'find', 'git', 'grep', 'ln', 'make', 'mkdir', 'mkcert',
        'mv', 'mysql', 'npx', 'npm', 'openssl', 'php', 'printf', 'pwd', 'rm', 'sh', 'sudo',
        'tail', 'tar', 'tee', 'vendor/bin/wbengine.php', 'vendor/bin/migrate-content.php',
    ]);
    const shellKeywords = new Set(['if', 'then', 'else', 'elif', 'fi', 'for', 'in', 'do', 'done', 'case', 'esac']);

    function add(parent, text, className) {
        if (!text) return;
        if (!className) {
            parent.append(document.createTextNode(text));
            return;
        }
        const span = document.createElement('span');
        span.className = className;
        span.textContent = text;
        parent.append(span);
    }

    function highlightShell(code) {
        const lines = code.textContent.split('\n');
        const fragment = document.createDocumentFragment();
        const tokenPattern = /\s+|#.*$|'(?:\\.|[^'\\])*'|"(?:\\.|[^"\\])*"|--?[A-Za-z][\w-]*|\$[A-Za-z_][\w]*|\|\||&&|[|;]|[^\s]+/gm;

        for (let lineIndex = 0; lineIndex < lines.length; lineIndex++) {
            const line = lines[lineIndex];
            let expectCommand = true;
            let offset = 0;
            tokenPattern.lastIndex = 0;
            let match;

            while ((match = tokenPattern.exec(line)) !== null) {
                const token = match[0];
                if (match.index > offset) {
                    const word = line.slice(offset, match.index);
                    const cls = expectCommand && commandNames.has(word) ? 'syntax-command' : '';
                    add(fragment, word, cls);
                    expectCommand = false;
                }

                if (/^\s+$/.test(token)) {
                    add(fragment, token, '');
                } else if (token[0] === '#') {
                    add(fragment, token, 'syntax-comment');
                    offset = tokenPattern.lastIndex;
                    break;
                } else if (token[0] === "'" || token[0] === '"') {
                    add(fragment, token, 'syntax-string');
                    expectCommand = false;
                } else if (token[0] === '$') {
                    add(fragment, token, 'syntax-keyword');
                    expectCommand = false;
                } else if (token[0] === '-') {
                    add(fragment, token, 'syntax-keyword');
                    expectCommand = false;
                } else if (token === '&&' || token === '||' || token === '|' || token === ';') {
                    add(fragment, token, 'syntax-keyword');
                    expectCommand = true;
                } else if (token === '$' || token === '%') {
                    add(fragment, token, 'syntax-comment');
                    expectCommand = true;
                } else if (expectCommand && commandNames.has(token)) {
                    add(fragment, token, 'syntax-command');
                    expectCommand = false;
                } else if (shellKeywords.has(token)) {
                    add(fragment, token, 'syntax-keyword');
                    expectCommand = true;
                } else {
                    add(fragment, token, '');
                    expectCommand = false;
                }
                offset = tokenPattern.lastIndex;
            }

            if (offset < line.length) {
                const word = line.slice(offset);
                const cls = expectCommand && commandNames.has(word) ? 'syntax-command' : '';
                add(fragment, word, cls);
            }
            if (lineIndex < lines.length - 1) add(fragment, '\n', '');
        }

        code.replaceChildren(fragment);
    }

    document.querySelectorAll('pre code[class*="language-"]').forEach((code) => {
        const match = code.className.match(/(?:^|\s)language-([\w-]+)/);
        if (match && ['bash', 'sh', 'shell', 'console', 'shell-session'].includes(match[1].toLowerCase())) {
            highlightShell(code);
        }
    });
})();
