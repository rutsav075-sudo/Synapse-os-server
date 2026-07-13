const fs = require('fs');
const path = require('path');

// The exact SVG string for the knot logo the user provided
const SYNAPSE_LOGO_SVG = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200" fill="none" stroke="currentColor" stroke-width="8" stroke-linecap="round" stroke-linejoin="round">
  <path d="M100 20 C140 20, 180 60, 180 100 C180 140, 140 180, 100 180 C60 180, 20 140, 20 100 C20 60, 60 20, 100 20 Z" stroke="none" />
  <path d="M100 20 C140 20, 140 100, 100 100 C60 100, 60 20, 100 20" fill="none" />
  <path d="M100 180 C140 180, 140 100, 100 100 C60 100, 60 180, 100 180" fill="none" />
  <path d="M20 100 C20 60, 100 60, 100 100 C100 140, 20 140, 20 100" fill="none" />
  <path d="M180 100 C180 60, 100 60, 100 100 C100 140, 180 140, 180 100" fill="none" />
</svg>`;

// We search for the n8n-editor-ui dist directory
const searchPaths = [
    path.join(__dirname, 'node_modules', 'n8n', 'node_modules', 'n8n-editor-ui', 'dist'),
    path.join(__dirname, 'node_modules', 'n8n-editor-ui', 'dist'),
    path.join(__dirname, 'node_modules', 'n8n', 'dist', 'public'),
    path.join(__dirname, 'node_modules', '@n8n', 'design-system', 'dist'),
    // Paths for inside the official n8n Docker image
    '/usr/local/lib/node_modules/n8n/node_modules/n8n-editor-ui/dist',
    '/usr/local/lib/node_modules/n8n/dist/public',
    '/usr/local/lib/node_modules/n8n/node_modules/@n8n/design-system/dist'
];

let targetDirs = [];
for (const p of searchPaths) {
    if (fs.existsSync(p)) {
        targetDirs.push(p);
    }
}

if (targetDirs.length === 0) {
    console.error("Could not find n8n-editor-ui compiled assets. Skipping patch.");
    process.exit(0);
}

console.log(`Found n8n UI directories at: \n${targetDirs.join('\n')}`);

function walkDir(dir, callback) {
    fs.readdirSync(dir).forEach(f => {
        let dirPath = path.join(dir, f);
        let isDirectory = fs.statSync(dirPath).isDirectory();
        isDirectory ? walkDir(dirPath, callback) : callback(dirPath);
    });
}

// Targeted string replacements to avoid breaking variables!
const replacements = [
    { regex: /<title>.*<\/title>/gi, replace: "<title>Synapse OS</title><script>localStorage.setItem('n8n-theme', 'light');</script>" },
    { regex: />\s*Welcome to n8n\s*</gi, replace: ">Welcome to Synapse<" },
    { regex: /title: *"n8n"/gi, replace: 'title:"Synapse"' },
    { regex: /title: *'n8n'/gi, replace: "title:'Synapse'" },
    { regex: />\s*n8n\s*</gi, replace: ">Synapse<" },
    { regex: /alt="n8n"/gi, replace: 'alt="Synapse"' },
    { regex: /"n8n"/gi, replace: '"Synapse"' },
    { regex: />\s*n8n API\s*</gi, replace: ">Synapse API<" },
    { regex: /'n8n'/gi, replace: "'Synapse'" },
    { regex: /n8n API/gi, replace: "Synapse API" }
];

targetDirs.forEach(targetDir => {
    console.log(`Patching directory: ${targetDir}`);
    
    walkDir(targetDir, (filePath) => {
        if (filePath.endsWith('.js') || filePath.endsWith('.html')) {
            let content = fs.readFileSync(filePath, 'utf8');
            let modified = false;

            // Apply text branding replacements
            replacements.forEach(r => {
                const newContent = content.replace(r.regex, r.replace);
                if (newContent !== content) {
                    content = newContent;
                    modified = true;
                }
            });

            // Patch the inline SVG logos in the JS bundles
            if (content.includes('d="M32 17.587V57h')) { 
                content = content.replace(/<svg[^>]*>.*?<\/svg>/g, (match) => {
                    if (match.includes('d="M32 17.587V57h')) {
                        return SYNAPSE_LOGO_SVG;
                    }
                    return match;
                });
                modified = true;
            }

            if (modified) {
                fs.writeFileSync(filePath, content, 'utf8');
                console.log(`[PATCHED] ${path.basename(filePath)}`);
            }
        }
    });
});

console.log("n8n Deep Patching Complete! All UI strings branded to Synapse.");
