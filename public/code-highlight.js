(() => {
    'use strict';

    const shellKeywords = new Set(['if', 'then', 'else', 'elif', 'fi', 'for', 'in', 'do', 'done', 'case', 'esac']);
    const wrappers = new Set(['command', 'exec', 'env', 'nohup', 'sudo', 'time']);
    const subcommands = {
        docker: new Set(['build', 'compose', 'down', 'exec', 'logs', 'run', 'up']),
        git: new Set(['add', 'checkout', 'clone', 'commit', 'diff', 'pull', 'push', 'status']),
        npm: new Set(['install', 'run', 'test', 'update']),
        composer: new Set(['install', 'require', 'update', 'validate']),
        php: new Set(['-l']),
        'vendor/bin/wbengine.php': new Set(['config:check', 'doctor', 'help', 'migration:status']),
    };

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
            let commandRoot = '';
            let offset = 0;
            tokenPattern.lastIndex = 0;
            let match;

            while ((match = tokenPattern.exec(line)) !== null) {
                const token = match[0];
                if (match.index > offset) {
                    const word = line.slice(offset, match.index);
                    const cls = expectCommand ? 'syntax-command' : '';
                    add(fragment, word, cls);
                    if (expectCommand && !wrappers.has(word)) commandRoot = word;
                    expectCommand = expectCommand && wrappers.has(word);
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
                } else if (shellKeywords.has(token)) {
                    add(fragment, token, 'syntax-keyword');
                    expectCommand = ['if', 'then', 'else', 'elif', 'do'].includes(token);
                    commandRoot = '';
                } else if (expectCommand) {
                    add(fragment, token, 'syntax-command');
                    if (wrappers.has(token)) {
                        expectCommand = true;
                    } else {
                        commandRoot = token;
                        expectCommand = false;
                    }
                } else if (commandRoot && subcommands[commandRoot]?.has(token)) {
                    add(fragment, token, 'syntax-command');
                    commandRoot = '';
                } else {
                    add(fragment, token, '');
                    if (commandRoot) commandRoot = '';
                }
                offset = tokenPattern.lastIndex;
            }

            if (offset < line.length) {
                const word = line.slice(offset);
                const cls = expectCommand ? 'syntax-command' : '';
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
