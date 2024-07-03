const browserify = require('browserify');
const fs = require('fs');

browserify('index.js', { standalone: 'ComplianceLib' })
  .bundle()
  .pipe(fs.createWriteStream('dist/bundle.js'));
