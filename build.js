const browserify = require('browserify');
const fs = require('fs');

browserify('index.js', { standalone: 'CompliantContract' })
  .bundle()
  .pipe(fs.createWriteStream('dist/bundle.js'));
